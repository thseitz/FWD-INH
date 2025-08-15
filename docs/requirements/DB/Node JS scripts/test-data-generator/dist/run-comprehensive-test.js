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
                }
                catch (err) {
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
        const { ComprehensiveProcedureTesterFixed } = await Promise.resolve().then(() => __importStar(require('./ComprehensiveProcedureTesterFixed')));
        const tester = new ComprehensiveProcedureTesterFixed(pool);
        await tester.testAllProcedures();
    }
    catch (error) {
        console.error('Error in comprehensive test:', error.message);
    }
    finally {
        client.release();
        await pool.end();
    }
}
runComprehensiveTest().catch(console.error);
