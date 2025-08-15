import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '15432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'FGt!3reGTdt5BG!',
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
});

async function runComprehensiveTest() {
    const client = await pool.connect();
    
    try {
        // First, reload all procedures from the fixed file
        console.log('Loading all procedures from 4_SQL_create_procs.sql...');
        const procsSQL = fs.readFileSync('C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts\\4_SQL_create_procs.sql', 'utf8');
        
        // Split by CREATE statements and execute each
        const statements = procsSQL.split(/(?=CREATE OR REPLACE)/);
        let loadedCount = 0;
        
        for (const statement of statements) {
            if (statement.trim()) {
                try {
                    await client.query(statement);
                    loadedCount++;
                } catch (err: any) {
                    // Ignore DROP FUNCTION errors
                    if (!statement.includes('DROP FUNCTION')) {
                        console.error('Error loading procedure:', err.message ? err.message.substring(0, 100) : String(err).substring(0, 100));
                    }
                }
            }
        }
        
        console.log(`Loaded ${loadedCount} procedure definitions.\n`);
        
        // Now run the comprehensive test
        const testFile = fs.readFileSync('C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\Node JS scripts\\test-data-generator\\src\\ComprehensiveProcedureTesterFixed.ts', 'utf8');
        
        // Extract the test logic and run it
        console.log('Running comprehensive test...\n');
        
        // Import and run the actual test
        const { ComprehensiveProcedureTesterFixed } = await import('./ComprehensiveProcedureTesterFixed');
        const tester = new ComprehensiveProcedureTesterFixed(pool);
        await tester.testAllProcedures();
        
    } catch (error: any) {
        console.error('Error in comprehensive test:', error.message);
    } finally {
        client.release();
        await pool.end();
    }
}

runComprehensiveTest().catch(console.error);