#!/usr/bin/env node
/**
 * Comprehensive Stored Procedure Test Suite
 * Tests all 70 stored procedures and functions in the FWD-INH database
 * Run with: npx tsx test-all-procedures.ts
 */

import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import chalk from 'chalk';
import ora from 'ora';
import { ComprehensiveProcedureTesterFixed } from './src/ComprehensiveProcedureTesterFixed';
import * as fs from 'fs';
import * as path from 'path';

// Load environment variables
dotenv.config();

const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '15432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'FGt!3reGTdt5BG!',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
};

interface TestResult {
    procedure: string;
    status: 'PASS' | 'FAIL' | 'SKIP';
    error?: string;
    duration?: number;
    category?: string;
}

async function testAllProcedures() {
    const spinner = ora('Initializing test suite...').start();
    const pool = new Pool(dbConfig);
    const results: TestResult[] = [];
    const startTime = Date.now();
    
    try {
        // Test connection
        const client = await pool.connect();
        await client.query('SELECT NOW()');
        client.release();
        
        spinner.succeed('Database connected successfully');
        
        // Get all procedures from database
        const proceduresQuery = `
            SELECT 
                p.proname as name,
                pg_get_function_identity_arguments(p.oid) as arguments,
                CASE 
                    WHEN p.proname LIKE 'sp_create%' THEN 'Creation'
                    WHEN p.proname LIKE 'sp_update%' THEN 'Update'
                    WHEN p.proname LIKE 'sp_delete%' THEN 'Deletion'
                    WHEN p.proname LIKE 'sp_get%' THEN 'Query'
                    WHEN p.proname LIKE 'sp_search%' THEN 'Search'
                    WHEN p.proname LIKE 'sp_sync%' THEN 'Integration'
                    WHEN p.proname LIKE 'sp_log%' THEN 'Audit'
                    WHEN p.proname IN ('current_user_id', 'current_tenant_id', 'is_ffc_member') THEN 'RLS Helper'
                    ELSE 'Other'
                END as category
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'public'
            AND (p.proname LIKE 'sp_%' OR p.proname IN ('current_user_id', 'current_tenant_id', 'is_ffc_member', 'update_updated_at_column'))
            ORDER BY category, p.proname;
        `;
        
        const { rows: procedures } = await pool.query(proceduresQuery);
        
        console.log(chalk.blue(`\n🧪 Testing ${procedures.length} Stored Procedures\n`));
        
        // Initialize tester
        const tester = new ComprehensiveProcedureTesterFixed(pool);
        
        // Group procedures by category
        const categories = [...new Set(procedures.map((p: any) => p.category))];
        
        for (const category of categories) {
            const categoryProcs = procedures.filter((p: any) => p.category === category);
            console.log(chalk.yellow(`\n📁 ${category} Procedures (${categoryProcs.length})`));
            
            for (const proc of categoryProcs) {
                const testSpinner = ora(`Testing ${proc.name}...`).start();
                const testStart = Date.now();
                
                try {
                    // Run the test based on the procedure name
                    const result = await tester.testProcedure(proc.name, proc.arguments);
                    
                    results.push({
                        procedure: proc.name,
                        status: 'PASS',
                        duration: Date.now() - testStart,
                        category: proc.category
                    });
                    
                    testSpinner.succeed(chalk.green(`✓ ${proc.name}`));
                } catch (error: any) {
                    results.push({
                        procedure: proc.name,
                        status: 'FAIL',
                        error: error.message,
                        duration: Date.now() - testStart,
                        category: proc.category
                    });
                    
                    testSpinner.fail(chalk.red(`✗ ${proc.name}: ${error.message}`));
                }
            }
        }
        
        // Generate summary report
        const duration = Date.now() - startTime;
        const passed = results.filter(r => r.status === 'PASS').length;
        const failed = results.filter(r => r.status === 'FAIL').length;
        const skipped = results.filter(r => r.status === 'SKIP').length;
        
        console.log(chalk.blue('\n' + '='.repeat(60)));
        console.log(chalk.blue.bold('TEST SUMMARY'));
        console.log(chalk.blue('='.repeat(60) + '\n'));
        
        console.log(chalk.white(`Total Procedures: ${procedures.length}`));
        console.log(chalk.green(`✓ Passed: ${passed} (${(passed/procedures.length*100).toFixed(1)}%)`));
        console.log(chalk.red(`✗ Failed: ${failed} (${(failed/procedures.length*100).toFixed(1)}%)`));
        if (skipped > 0) {
            console.log(chalk.yellow(`⊘ Skipped: ${skipped}`));
        }
        console.log(chalk.gray(`\nTotal Duration: ${(duration/1000).toFixed(2)}s`));
        
        // Show failed procedures if any
        if (failed > 0) {
            console.log(chalk.red('\n❌ Failed Procedures:'));
            results.filter(r => r.status === 'FAIL').forEach(r => {
                console.log(chalk.red(`  • ${r.procedure}: ${r.error}`));
            });
        }
        
        // Write detailed report to file
        const reportPath = path.join(__dirname, 'test-results', `test-report-${new Date().toISOString().replace(/:/g, '-')}.json`);
        const reportDir = path.dirname(reportPath);
        
        if (!fs.existsSync(reportDir)) {
            fs.mkdirSync(reportDir, { recursive: true });
        }
        
        fs.writeFileSync(reportPath, JSON.stringify({
            timestamp: new Date().toISOString(),
            duration: duration,
            summary: {
                total: procedures.length,
                passed: passed,
                failed: failed,
                skipped: skipped,
                successRate: (passed/procedures.length*100).toFixed(1) + '%'
            },
            results: results
        }, null, 2));
        
        console.log(chalk.gray(`\n📄 Detailed report saved to: ${reportPath}`));
        
        // Exit with appropriate code
        process.exit(failed > 0 ? 1 : 0);
        
    } catch (error) {
        spinner.fail('Test suite failed');
        console.error(chalk.red('\n❌ Fatal Error:'), error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

// Run the test suite
if (require.main === module) {
    testAllProcedures().catch(console.error);
}

export { testAllProcedures };