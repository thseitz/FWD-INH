#!/usr/bin/env node
/**
 * Database Population Script
 * Populates the FWD-INH database with comprehensive test data
 * Run with: npx tsx populate-database.ts
 */

import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import chalk from 'chalk';
import ora from 'ora';
import { TestDataGenerator } from './src/TestDataGenerator';

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

async function populateDatabase() {
    const spinner = ora('Initializing database connection...').start();
    const pool = new Pool(dbConfig);
    
    try {
        // Test connection
        const client = await pool.connect();
        await client.query('SELECT NOW()');
        client.release();
        
        spinner.succeed('Database connected successfully');
        
        // Initialize test data generator
        const generator = new TestDataGenerator(pool);
        
        console.log(chalk.blue('\n📊 Starting Database Population\n'));
        console.log(chalk.gray('This will create:'));
        console.log(chalk.gray('  • 1 Tenant'));
        console.log(chalk.gray('  • 10 Forward Family Circles'));
        console.log(chalk.gray('  • 40-50 Personas'));
        console.log(chalk.gray('  • 100+ Assets across all 13 categories'));
        console.log(chalk.gray('  • Complex ownership structures'));
        console.log(chalk.gray('  • Comprehensive permissions\n'));
        
        // Clear existing test data
        spinner.start('Clearing existing test data...');
        await clearTestData(pool);
        spinner.succeed('Existing test data cleared');
        
        // Generate comprehensive test data
        spinner.start('Generating test data...');
        const results = await generator.generateCompleteScenario();
        spinner.succeed('Test data generation complete');
        
        // Display results
        console.log(chalk.green('\n✅ Database Population Complete!\n'));
        console.log(chalk.white('Summary:'));
        console.log(chalk.gray(`  • Tenant: ${results.tenant.name}`));
        console.log(chalk.gray(`  • FFCs Created: ${results.ffcs.length}`));
        console.log(chalk.gray(`  • Personas Created: ${results.personas.length}`));
        console.log(chalk.gray(`  • Assets Created: ${results.assets.length}`));
        console.log(chalk.gray(`  • Total Portfolio Value: $${results.totalValue.toLocaleString()}`));
        
    } catch (error) {
        spinner.fail('Database population failed');
        console.error(chalk.red('\n❌ Error:'), error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

async function clearTestData(pool: Pool) {
    const queries = [
        'DELETE FROM audit_log WHERE tenant_id = 1',
        'DELETE FROM asset_permissions WHERE tenant_id = 1',
        'DELETE FROM asset_persona WHERE tenant_id = 1',
        'DELETE FROM assets WHERE tenant_id = 1',
        'DELETE FROM ffc_personas WHERE tenant_id = 1',
        'DELETE FROM fwd_family_circles WHERE tenant_id = 1',
        'DELETE FROM personas WHERE tenant_id = 1',
        'DELETE FROM users WHERE tenant_id = 1',
        'DELETE FROM tenants WHERE id = 1'
    ];
    
    for (const query of queries) {
        try {
            await pool.query(query);
        } catch (error) {
            // Ignore errors if tables don't have data
        }
    }
}

// Run the population script
if (require.main === module) {
    populateDatabase().catch(console.error);
}

export { populateDatabase };