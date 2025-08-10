import { Pool } from 'pg';
import { StoredProcedureTester } from './StoredProcedureTester';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

/**
 * Main test execution script for all 50 stored procedures with file output
 */
async function main() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const outputDir = path.join(__dirname, '..', 'test-results');
  
  // Create output directory if it doesn't exist
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  console.log('═══════════════════════════════════════════════════════════');
  console.log('  FORWARD INHERITANCE PLATFORM - STORED PROCEDURE TESTING  ');
  console.log('═══════════════════════════════════════════════════════════');
  console.log();

  // Database configuration
  const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
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
    client.release();
    console.log();

    // Initialize tester
    const tester = new StoredProcedureTester(pool);

    // Run all tests
    const summary = await tester.testAllProcedures();

    // Generate output files
    const jsonOutput = path.join(outputDir, `test-results-${timestamp}.json`);
    const markdownOutput = path.join(outputDir, `test-results-${timestamp}.md`);
    const latestOutput = path.join(outputDir, 'latest-test-results.json');
    const latestMarkdown = path.join(outputDir, 'latest-test-results.md');

    // Save JSON results
    fs.writeFileSync(jsonOutput, JSON.stringify(summary, null, 2));
    fs.writeFileSync(latestOutput, JSON.stringify(summary, null, 2));
    console.log(`\n📄 JSON results saved to: ${jsonOutput}`);

    // Generate and save Markdown report
    const markdownReport = generateMarkdownReport(summary, timestamp);
    fs.writeFileSync(markdownOutput, markdownReport);
    fs.writeFileSync(latestMarkdown, markdownReport);
    console.log(`📄 Markdown report saved to: ${markdownOutput}`);

    // Generate CSV for failed tests if any
    if (summary.failed > 0) {
      const csvOutput = path.join(outputDir, `failed-tests-${timestamp}.csv`);
      const csvContent = generateCSV(summary);
      fs.writeFileSync(csvOutput, csvContent);
      console.log(`📄 Failed tests CSV saved to: ${csvOutput}`);
    }

    // Exit with appropriate code
    if (summary.failed > 0) {
      console.log('\n⚠️  Some tests failed. Please review the errors above.');
      process.exit(1);
    } else {
      console.log('\n🎉 All tests passed successfully!');
      process.exit(0);
    }

  } catch (error) {
    console.error('\n💥 Fatal error:', error);
    
    // Save error log
    const errorLog = path.join(outputDir, `error-log-${timestamp}.txt`);
    fs.writeFileSync(errorLog, `Fatal Error: ${error}\n\nStack: ${(error as Error).stack}`);
    console.log(`📄 Error log saved to: ${errorLog}`);
    
    process.exit(1);
  } finally {
    await pool.end();
  }
}

/**
 * Generate Markdown report from test summary
 */
function generateMarkdownReport(summary: any, timestamp: string): string {
  const date = new Date().toLocaleString();
  let markdown = `# Stored Procedure Test Results\n\n`;
  markdown += `**Test Run:** ${date}\n`;
  markdown += `**Timestamp:** ${timestamp}\n\n`;
  
  markdown += `## Summary\n\n`;
  markdown += `| Metric | Value |\n`;
  markdown += `|--------|-------|\n`;
  markdown += `| Total Procedures | ${summary.totalProcedures} |\n`;
  markdown += `| ✅ Successful | ${summary.successful} |\n`;
  markdown += `| ❌ Failed | ${summary.failed} |\n`;
  markdown += `| ⏭️ Skipped | ${summary.skipped} |\n`;
  markdown += `| ⏱️ Execution Time | ${summary.totalExecutionTime}ms |\n`;
  markdown += `| Success Rate | ${((summary.successful / summary.totalProcedures) * 100).toFixed(1)}% |\n\n`;

  // Group results by category
  const categories: { [key: string]: any[] } = {};
  summary.results.forEach((result: any) => {
    if (!categories[result.category]) {
      categories[result.category] = [];
    }
    categories[result.category].push(result);
  });

  markdown += `## Results by Category\n\n`;
  for (const [category, results] of Object.entries(categories)) {
    const passed = results.filter(r => r.status === 'success').length;
    const total = results.length;
    markdown += `### ${category} (${passed}/${total})\n\n`;
    
    markdown += `| Procedure | Status | Time (ms) | Error |\n`;
    markdown += `|-----------|--------|-----------|-------|\n`;
    
    results.forEach(result => {
      const status = result.status === 'success' ? '✅' : '❌';
      const error = result.error ? result.error.substring(0, 50) + '...' : '-';
      markdown += `| ${result.procedureName} | ${status} | ${result.executionTime} | ${error} |\n`;
    });
    markdown += '\n';
  }

  if (summary.failed > 0) {
    markdown += `## Failed Procedures Details\n\n`;
    summary.results
      .filter((r: any) => r.status === 'failure')
      .forEach((result: any) => {
        markdown += `### ❌ ${result.category} / ${result.procedureName}\n`;
        markdown += `**Error:** ${result.error}\n`;
        markdown += `**Execution Time:** ${result.executionTime}ms\n\n`;
      });
  }

  return markdown;
}

/**
 * Generate CSV for failed tests
 */
function generateCSV(summary: any): string {
  let csv = 'Category,Procedure,Error,ExecutionTime\n';
  summary.results
    .filter((r: any) => r.status === 'failure')
    .forEach((result: any) => {
      const error = result.error.replace(/"/g, '""'); // Escape quotes
      csv += `"${result.category}","${result.procedureName}","${error}",${result.executionTime}\n`;
    });
  return csv;
}

// Execute if run directly
if (require.main === module) {
  main().catch(error => {
    console.error('Unhandled error:', error);
    process.exit(1);
  });
}

export { main as testStoredProceduresWithOutput };