import { Pool } from 'pg';
import * as fs from 'fs';
import * as path from 'path';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

async function applyFixes() {
  const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'fwd_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
  };

  console.log('📋 Applying procedure fixes...');
  console.log(`   Database: ${dbConfig.database}`);

  const pool = new Pool(dbConfig);

  try {
    const client = await pool.connect();
    
    // Read the fixes SQL file
    const sqlPath = path.join(
      'C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts',
      'procedure_fixes.sql'
    );
    
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    // Execute the SQL
    console.log('🔄 Executing fixes...');
    await client.query(sql);
    
    console.log('✅ All procedure fixes applied successfully!');
    
    client.release();
  } catch (error) {
    console.error('❌ Error applying fixes:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

// Run if executed directly
if (require.main === module) {
  applyFixes().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export { applyFixes };