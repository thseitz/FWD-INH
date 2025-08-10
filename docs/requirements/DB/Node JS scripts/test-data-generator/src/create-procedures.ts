import { Pool } from 'pg';
import * as fs from 'fs';
import * as path from 'path';
import * as dotenv from 'dotenv';

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

  const pool = new Pool(dbConfig);

  try {
    const client = await pool.connect();
    
    // Read the SQL file
    const sqlPath = path.join(
      'C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts',
      '4_SQL_create_procs.sql'
    );
    
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    // Execute the SQL
    console.log('🔄 Executing SQL...');
    await client.query(sql);
    
    console.log('✅ All procedures created successfully!');
    
    // Test a simple function
    const testResult = await client.query('SELECT current_user_id()');
    console.log('🧪 Test function call successful');
    
    client.release();
  } catch (error) {
    console.error('❌ Error creating procedures:', error);
    throw error;
  } finally {
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

export { createProcedures };