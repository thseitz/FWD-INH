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
const pg_1 = require("pg");
const dotenv = __importStar(require("dotenv"));
const path = __importStar(require("path"));
dotenv.config({ path: path.join(__dirname, '..', '.env') });
const pool = new pg_1.Pool({
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
            }
            catch (error) {
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
    }
    finally {
        client.release();
        await pool.end();
    }
}
findFailingProcedures().catch(console.error);
