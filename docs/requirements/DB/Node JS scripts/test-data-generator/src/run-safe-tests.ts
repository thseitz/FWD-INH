import { Pool } from 'pg';
import { SafeProcedureTester } from './SafeProcedureTester';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

/**
 * Main test execution script for all stored procedures with safe transaction handling
 */
async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  FORWARD INHERITANCE PLATFORM - SAFE PROCEDURE TESTING    ');
  console.log('═══════════════════════════════════════════════════════════');
  console.log();

  // Database configuration
  const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    connectionTimeoutMillis: 10000,
    query_timeout: 30000,
    statement_timeout: 30000,
    idle_in_transaction_session_timeout: 30000
  };

  console.log('📋 Database Configuration:');
  console.log(`   Host: ${dbConfig.host}:${dbConfig.port}`);
  console.log(`   Database: ${dbConfig.database}`);
  console.log(`   User: ${dbConfig.user}`);
  console.log();

  const pool = new Pool(dbConfig);

  try {
    // Test database connection
    console.log('🔌 Testing database connection...');
    const client = await pool.connect();
    const result = await client.query('SELECT version()');
    console.log('✅ Connected to PostgreSQL:', result.rows[0].version);
    
    // Check if database has the required schema
    const schemaCheck = await client.query(`
      SELECT COUNT(*) as table_count 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_type = 'BASE TABLE'
    `);
    console.log(`📊 Found ${schemaCheck.rows[0].table_count} tables in database`);
    
    // Check for stored procedures
    const procCheck = await client.query(`
      SELECT COUNT(*) as proc_count 
      FROM information_schema.routines 
      WHERE routine_schema = 'public'
    `);
    console.log(`🔧 Found ${procCheck.rows[0].proc_count} stored procedures/functions`);
    
    client.release();
    console.log();

    // Initialize tester
    const tester = new SafeProcedureTester(pool);

    // Run all tests
    const startTime = Date.now();
    const summary = await tester.testAllProcedures();
    const totalTime = Date.now() - startTime;

    // Save test results to file
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const resultsDir = path.join(__dirname, '..', 'test-results');
    
    // Create results directory if it doesn't exist
    if (!fs.existsSync(resultsDir)) {
      fs.mkdirSync(resultsDir, { recursive: true });
    }

    // Save JSON results
    const jsonFile = path.join(resultsDir, `safe-test-results-${timestamp}.json`);
    fs.writeFileSync(jsonFile, JSON.stringify(summary, null, 2));
    console.log(`\n📁 Test results saved to: ${jsonFile}`);

    // Save markdown report
    const mdFile = path.join(resultsDir, `safe-test-results-${timestamp}.md`);
    const mdContent = generateMarkdownReport(summary, totalTime);
    fs.writeFileSync(mdFile, mdContent);
    console.log(`📄 Markdown report saved to: ${mdFile}`);

    // Also save as latest
    const latestJsonFile = path.join(resultsDir, `latest-safe-test-results.json`);
    fs.writeFileSync(latestJsonFile, JSON.stringify(summary, null, 2));
    
    const latestMdFile = path.join(resultsDir, `latest-safe-test-results.md`);
    fs.writeFileSync(latestMdFile, mdContent);

    // Exit with appropriate code
    if (summary.failed > 0) {
      console.log(`\n⚠️  ${summary.failed} tests failed. Please review the errors above.`);
      process.exit(1);
    } else if (summary.skipped > 0) {
      console.log(`\n✅ All runnable tests passed! (${summary.skipped} tests were skipped)`);
      process.exit(0);
    } else {
      console.log('\n🎉 All tests passed successfully!');
      process.exit(0);
    }

  } catch (error) {
    console.error('\n💥 Fatal error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

/**
 * Generate markdown report
 */
function generateMarkdownReport(summary: any, totalTime: number): string {
  const timestamp = new Date().toISOString();
  let md = `# Forward Inheritance Platform - Safe Test Results\n\n`;
  md += `**Generated:** ${timestamp}\n`;
  md += `**Total Execution Time:** ${(totalTime / 1000).toFixed(2)} seconds\n\n`;
  
  md += `## Summary\n\n`;
  md += `| Metric | Count | Percentage |\n`;
  md += `|--------|-------|------------|\n`;
  md += `| Total Procedures | ${summary.totalProcedures} | 100% |\n`;
  md += `| ✅ Successful | ${summary.successful} | ${((summary.successful/summary.totalProcedures)*100).toFixed(1)}% |\n`;
  md += `| ❌ Failed | ${summary.failed} | ${((summary.failed/summary.totalProcedures)*100).toFixed(1)}% |\n`;
  md += `| ⏭️ Skipped | ${summary.skipped} | ${((summary.skipped/summary.totalProcedures)*100).toFixed(1)}% |\n\n`;

  if (summary.failed > 0) {
    md += `## Failed Tests\n\n`;
    summary.results
      .filter((r: any) => r.status === 'failure')
      .forEach((r: any) => {
        md += `### ❌ ${r.procedureName}\n`;
        md += `- **Category:** ${r.category}\n`;
        md += `- **Error:** \`${r.error}\`\n`;
        md += `- **Execution Time:** ${r.executionTime}ms\n\n`;
      });
  }

  if (summary.skipped > 0) {
    md += `## Skipped Tests\n\n`;
    summary.results
      .filter((r: any) => r.status === 'skipped')
      .forEach((r: any) => {
        md += `### ⏭️ ${r.procedureName}\n`;
        md += `- **Category:** ${r.category}\n`;
        md += `- **Reason:** ${r.error}\n\n`;
      });
  }

  md += `## Test Results by Category\n\n`;
  
  // Group by category
  const categories = [...new Set(summary.results.map((r: any) => r.category))];
  
  categories.forEach(cat => {
    const catResults = summary.results.filter((r: any) => r.category === cat);
    const catSuccess = catResults.filter((r: any) => r.status === 'success').length;
    const catFailed = catResults.filter((r: any) => r.status === 'failure').length;
    const catSkipped = catResults.filter((r: any) => r.status === 'skipped').length;
    
    md += `### ${cat}\n`;
    md += `- Total: ${catResults.length}\n`;
    md += `- ✅ Success: ${catSuccess}\n`;
    md += `- ❌ Failed: ${catFailed}\n`;
    md += `- ⏭️ Skipped: ${catSkipped}\n\n`;
  });

  md += `## All Test Results\n\n`;
  md += `| Procedure | Category | Status | Time (ms) | Notes |\n`;
  md += `|-----------|----------|--------|-----------|-------|\n`;
  
  summary.results.forEach((r: any) => {
    const status = r.status === 'success' ? '✅' : r.status === 'failure' ? '❌' : '⏭️';
    const notes = r.error ? r.error.substring(0, 50) + (r.error.length > 50 ? '...' : '') : '-';
    md += `| ${r.procedureName} | ${r.category} | ${status} | ${r.executionTime} | ${notes} |\n`;
  });

  return md;
}

// Execute if run directly
if (require.main === module) {
  main().catch(error => {
    console.error('Unhandled error:', error);
    process.exit(1);
  });
}

export { main as runSafeTests };