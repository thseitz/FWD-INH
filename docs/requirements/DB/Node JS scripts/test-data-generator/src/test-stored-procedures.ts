import { Pool } from 'pg';
import { StoredProcedureTester } from './StoredProcedureTester';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

/**
 * Main test execution script for all 50 stored procedures
 */
async function main() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  FORWARD INHERITANCE PLATFORM - STORED PROCEDURE TESTING  ');
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

  const pool = new Pool(dbConfig);

  try {
    // Test database connection
    console.log('🔌 Testing database connection...');
    const client = await pool.connect();
    const result = await client.query('SELECT version()');
    console.log('✅ Connected to PostgreSQL:', result.rows[0].version);
    client.release();
    console.log();

    // Initialize tester
    const tester = new StoredProcedureTester(pool);

    // Run all tests
    const summary = await tester.testAllProcedures();

    // Exit with appropriate code
    if (summary.failed > 0) {
      console.log('\n⚠️  Some tests failed. Please review the errors above.');
      process.exit(1);
    } else {
      console.log('\n🎉 All tests passed successfully!');
      process.exit(0);
    }

  } catch (error) {
    console.error('\n💥 Fatal error:', error);
    process.exit(1);
  } finally {
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

export { main as testStoredProcedures };