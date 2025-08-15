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

async function testSingleProc() {
    const client = await pool.connect();
    
    try {
        // First apply the fix
        const fixSql = fs.readFileSync('C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts\\fix_sp_get_quillt_sync_status.sql', 'utf8');
        await client.query(fixSql);
        console.log('✅ Applied fix for sp_get_quillt_sync_status');
        
        // Test the procedure
        console.log('\nTesting sp_get_quillt_sync_status...');
        
        // Set session variables for testing
        await client.query("SET LOCAL auth.user_id = '11111111-1111-1111-1111-111111111111'");
        await client.query("SET LOCAL auth.tenant_id = '1'");
        
        // Test the function
        const result = await client.query(`
            SELECT * FROM sp_get_quillt_sync_status(
                '11111111-1111-1111-1111-111111111111',
                7
            )
        `);
        
        console.log('✅ sp_get_quillt_sync_status passed');
        console.log('Result:', JSON.stringify(result.rows[0], null, 2));
        
    } catch (error: any) {
        console.error('❌ sp_get_quillt_sync_status failed:', error.message);
        if (error.detail) console.error('Detail:', error.detail);
        if (error.hint) console.error('Hint:', error.hint);
    } finally {
        client.release();
        await pool.end();
    }
}

testSingleProc().catch(console.error);