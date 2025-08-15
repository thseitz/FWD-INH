import { Pool } from 'pg';
import * as dotenv from 'dotenv';
import * as path from 'path';

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

async function findFailingProcedures() {
    const client = await pool.connect();
    
    try {
        // Set session variables for testing
        await client.query("SET LOCAL auth.user_id = '11111111-1111-1111-1111-111111111111'");
        await client.query("SET LOCAL auth.tenant_id = '1'");
        
        const failingProcs = [];
        
        // Test a few procedures that might be failing
        const proceduresToTest = [
            {
                name: 'sp_check_integration_health',
                query: "SELECT * FROM sp_check_integration_health()"
            },
            {
                name: 'sp_get_subscription_usage',
                query: "SELECT * FROM sp_get_subscription_usage('11111111-1111-1111-1111-111111111111')"
            },
            {
                name: 'sp_process_stripe_webhook',
                query: "SELECT sp_process_stripe_webhook('evt_test', 'customer.subscription.created', '{}'::jsonb)"
            },
            {
                name: 'sp_create_subscription',
                query: `SELECT sp_create_subscription(
                    '11111111-1111-1111-1111-111111111111',
                    'basic',
                    'monthly',
                    29.99
                )`
            },
            {
                name: 'sp_update_subscription_status',
                query: `SELECT sp_update_subscription_status(
                    '11111111-1111-1111-1111-111111111111',
                    'active'
                )`
            }
        ];
        
        for (const proc of proceduresToTest) {
            try {
                await client.query(proc.query);
                console.log(`✅ ${proc.name} passed`);
            } catch (error: any) {
                console.log(`❌ ${proc.name} failed: ${error.message}`);
                failingProcs.push({
                    name: proc.name,
                    error: error.message
                });
            }
        }
        
        console.log('\n\nSummary of failures:');
        failingProcs.forEach(p => {
            console.log(`- ${p.name}: ${p.error}`);
        });
        
    } finally {
        client.release();
        await pool.end();
    }
}

findFailingProcedures().catch(console.error);