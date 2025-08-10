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
exports.createProcedures = createProcedures;
const pg_1 = require("pg");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const dotenv = __importStar(require("dotenv"));
// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });
async function createProcedures() {
    const dbConfig = {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT || '5432'),
        database: process.env.DB_NAME || 'fwd_db',
        user: process.env.DB_USER || 'postgres',
        password: process.env.DB_PASSWORD || 'postgres',
    };
    console.log('📋 Creating stored procedures...');
    console.log(`   Database: ${dbConfig.database}`);
    const pool = new pg_1.Pool(dbConfig);
    try {
        const client = await pool.connect();
        // Read the SQL file
        const sqlPath = path.join('C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts', '4_SQL_create_procs.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8');
        // Execute the SQL
        console.log('🔄 Executing SQL...');
        await client.query(sql);
        console.log('✅ All procedures created successfully!');
        // Test a simple function
        const testResult = await client.query('SELECT current_user_id()');
        console.log('🧪 Test function call successful');
        client.release();
    }
    catch (error) {
        console.error('❌ Error creating procedures:', error);
        throw error;
    }
    finally {
        await pool.end();
    }
}
// Run if executed directly
if (require.main === module) {
    createProcedures().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}
