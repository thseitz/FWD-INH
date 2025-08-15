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
const fs = __importStar(require("fs"));
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
    }
    catch (error) {
        console.error('❌ sp_get_quillt_sync_status failed:', error.message);
        if (error.detail)
            console.error('Detail:', error.detail);
        if (error.hint)
            console.error('Hint:', error.hint);
    }
    finally {
        client.release();
        await pool.end();
    }
}
testSingleProc().catch(console.error);
