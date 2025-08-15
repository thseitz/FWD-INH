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
exports.testFixedStoredProcedures = main;
const pg_1 = require("pg");
const FixedStoredProcedureTester_1 = require("./FixedStoredProcedureTester");
const dotenv = __importStar(require("dotenv"));
const path = __importStar(require("path"));
// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });
/**
 * Main test execution script for all stored procedures - FIXED VERSION
 */
async function main() {
    console.log('═══════════════════════════════════════════════════════════');
    console.log('  FORWARD INHERITANCE PLATFORM - FIXED PROCEDURE TESTING   ');
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
    const pool = new pg_1.Pool(dbConfig);
    try {
        // Test database connection
        console.log('🔌 Testing database connection...');
        const client = await pool.connect();
        const result = await client.query('SELECT version()');
        console.log('✅ Connected to PostgreSQL:', result.rows[0].version);
        client.release();
        console.log();
        // Initialize tester
        const tester = new FixedStoredProcedureTester_1.FixedStoredProcedureTester(pool);
        // Run all tests
        const summary = await tester.testAllProcedures();
        // Exit with appropriate code
        if (summary.failed > 0) {
            console.log('\n⚠️  Some tests failed. Please review the errors above.');
            process.exit(1);
        }
        else {
            console.log('\n🎉 All tests passed successfully!');
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
// Execute if run directly
if (require.main === module) {
    main().catch(error => {
        console.error('Unhandled error:', error);
        process.exit(1);
    });
}
