#!/usr/bin/env node

const { Client } = require('pg');

// Test connection to external pg17 PostgreSQL server
async function testConnection() {
  const client = new Client({
    host: 'localhost',
    port: 15432,
    user: 'postgres',
    password: 'FGt!3reGTdt5BG!',
    database: 'fwd_db'
  });

  try {
    console.log('🔗 Connecting to pg17 PostgreSQL server...');
    await client.connect();
    console.log('✅ Connected successfully!');
    
    // Test basic query
    const result = await client.query('SELECT NOW(), version()');
    console.log('⏰ Server time:', result.rows[0].now);
    console.log('🗄️  Version:', result.rows[0].version.split(',')[0]);
    
    // Test database and schema exist
    const dbCheck = await client.query(`
      SELECT schemaname, tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      ORDER BY tablename
      LIMIT 5
    `);
    
    console.log('📋 Sample tables:', dbCheck.rows.map(r => r.tablename).join(', '));
    console.log(`📊 Total tables found: ${dbCheck.rowCount}`);
    
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    process.exit(1);
  } finally {
    await client.end();
    console.log('🔌 Connection closed');
  }
}

testConnection();