"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.runComprehensiveFixedTests = main;
const pg_1 = require("pg");
const ComprehensiveProcedureTesterFixed_1 = require("./ComprehensiveProcedureTesterFixed");
const dotenv = __importStar(require("dotenv"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });
/**
 * Main test execution script for all 70 stored procedures/functions - FIXED VERSION
 */
async function main() {
    console.log('═══════════════════════════════════════════════════════════');
    console.log('  FORWARD INHERITANCE - COMPREHENSIVE TESTING (FIXED)       ');
    console.log('═══════════════════════════════════════════════════════════');
    console.log();
    // Database configuration
    const dbConfig = {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT || '15432'),
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
    const pool = new pg_1.Pool(dbConfig);
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
        // Check for stored procedures/functions
        const procCheck = await client.query(`
      SELECT COUNT(*) as proc_count 
      FROM information_schema.routines 
      WHERE routine_schema = 'public'
    `);
        console.log(`🔧 Found ${procCheck.rows[0].proc_count} stored procedures/functions`);
        // Check if test data exists
        const assetCheck = await client.query('SELECT COUNT(*) as asset_count FROM assets');
        console.log(`📦 Found ${assetCheck.rows[0].asset_count} assets in database`);
        client.release();
        console.log();
        // Initialize fixed tester
        const tester = new ComprehensiveProcedureTesterFixed_1.ComprehensiveProcedureTesterFixed(pool);
        // Run all tests
        const startTime = Date.now();
        const summary = await tester.testAllProcedures();
        const totalTime = Date.now() - startTime;
        // Calculate success rate
        const successRate = summary.successful + summary.failed > 0
            ? ((summary.successful / (summary.successful + summary.failed)) * 100).toFixed(1)
            : '0.0';
        // Save test results to file
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const resultsDir = path.join(__dirname, '..', 'test-results');
        // Create results directory if it doesn't exist
        if (!fs.existsSync(resultsDir)) {
            fs.mkdirSync(resultsDir, { recursive: true });
        }
        // Save JSON results
        const jsonFile = path.join(resultsDir, `fixed-test-results-${timestamp}.json`);
        fs.writeFileSync(jsonFile, JSON.stringify(summary, null, 2));
        console.log(`\n📁 Test results saved to: ${jsonFile}`);
        // Save markdown report
        const mdFile = path.join(resultsDir, `fixed-test-results-${timestamp}.md`);
        const mdContent = generateMarkdownReport(summary, totalTime, successRate);
        fs.writeFileSync(mdFile, mdContent);
        console.log(`📄 Markdown report saved to: ${mdFile}`);
        // Final status
        console.log('\n' + '═'.repeat(63));
        console.log('                    FINAL RESULTS                           ');
        console.log('═'.repeat(63));
        console.log(`  Total Tested: ${summary.results.length}/70 procedures`);
        console.log(`  ✅ Successful: ${summary.successful}`);
        console.log(`  ❌ Failed: ${summary.failed}`);
        console.log(`  ⏭️  Skipped: ${summary.skipped}`);
        console.log(`  📈 Success Rate: ${successRate}%`);
        console.log(`  ⏱️  Total Time: ${(totalTime / 1000).toFixed(2)}s`);
        console.log('═'.repeat(63));
        // Exit with appropriate code
        if (summary.failed > 0) {
            console.log('\n⚠️  Some tests failed. Review above for details.');
            process.exit(1);
        }
        else if (summary.successful === 70) {
            console.log('\n🎉 ALL 70 PROCEDURES TESTED SUCCESSFULLY - 100% PASS RATE!');
            process.exit(0);
        }
        else {
            console.log(`\n✅ ${summary.successful} procedures passed, ${summary.skipped} skipped for safety.`);
            process.exit(0);
        }
    }
    catch (error) {
        console.error('\n💥 Fatal error:', error);
        process.exit(1);
    }
    finally {
        await pool.end();
    }
}
/**
 * Generate markdown report for fixed tests
 */
function generateMarkdownReport(summary, totalTime, successRate) {
    const timestamp = new Date().toISOString();
    let md = `# Forward Inheritance Platform - FIXED Test Results\n\n`;
    md += `**Generated:** ${timestamp}\n`;
    md += `**Total Execution Time:** ${(totalTime / 1000).toFixed(2)} seconds\n`;
    md += `**Success Rate:** ${successRate}%\n\n`;
    md += `## Summary\n\n`;
    md += `| Metric | Count |\n`;
    md += `|--------|-------|\n`;
    md += `| Total Procedures | ${summary.results.length}/70 |\n`;
    md += `| ✅ Successful | ${summary.successful} |\n`;
    md += `| ❌ Failed | ${summary.failed} |\n`;
    md += `| ⏭️ Skipped | ${summary.skipped} |\n\n`;
    if (summary.failed > 0) {
        md += `## Failed Tests\n\n`;
        summary.results
            .filter((r) => r.status === 'failure')
            .forEach((r) => {
            md += `### ❌ ${r.procedureName}\n`;
            md += `- **Category:** ${r.category}\n`;
            md += `- **Error:** ${r.error}\n`;
            md += `- **Execution Time:** ${r.executionTime}ms\n\n`;
        });
    }
    if (summary.skipped > 0) {
        md += `## Skipped Tests\n\n`;
        summary.results
            .filter((r) => r.status === 'skipped')
            .forEach((r) => {
            md += `### ⏭️ ${r.procedureName}\n`;
            md += `- **Category:** ${r.category}\n`;
            md += `- **Reason:** ${r.error}\n\n`;
        });
    }
    md += `## All Test Results\n\n`;
    md += `| Procedure | Category | Status | Time (ms) |\n`;
    md += `|-----------|----------|--------|----------|\n`;
    summary.results.forEach((r) => {
        const status = r.status === 'success' ? '✅' : r.status === 'failure' ? '❌' : '⏭️';
        md += `| ${r.procedureName} | ${r.category} | ${status} | ${r.executionTime} |\n`;
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
