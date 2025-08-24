#!/usr/bin/env node
/**
 * Database Build Script
 * Runs migrations, populates test data, and tests database functionality
 */

const fs = require('fs');
const { spawn, exec } = require('child_process');
const path = require('path');

// Load environment variables from .env.local
const envFile = path.join(__dirname, '..', '.env.local');
if (fs.existsSync(envFile)) {
  const envContent = fs.readFileSync(envFile, 'utf8');
  const lines = envContent.split('\n');
  
  lines.forEach(line => {
    line = line.trim();
    if (line && !line.startsWith('#') && line.includes('=')) {
      const [key, ...valueParts] = line.split('=');
      const value = valueParts.join('=');
      process.env[key] = value;
    }
  });
}

const migrationsDir = path.join(__dirname, '..', 'apps', 'api', 'src', 'app', 'database', 'migrations');
const testingDir = path.join(__dirname, '..', 'apps', 'api', 'src', 'app', 'database', 'testing');

async function runCommand(command, cwd = process.cwd()) {
  return new Promise((resolve, reject) => {
    console.log(`\n→ Running: ${command}`);
    console.log(`→ Directory: ${cwd}`);
    
    const child = spawn('cmd', ['/c', command], {
      cwd,
      stdio: 'inherit',
      env: process.env
    });

    child.on('close', (code) => {
      if (code === 0) {
        console.log(`✓ Command completed successfully`);
        resolve();
      } else {
        console.error(`✗ Command failed with exit code ${code}`);
        reject(new Error(`Command failed: ${command}`));
      }
    });

    child.on('error', (error) => {
      console.error(`✗ Command error:`, error);
      reject(error);
    });
  });
}

async function runSqlFile(filePath, database = process.env.PGDATABASE) {
  // The migrations are already mounted in the container at /docker-entrypoint-initdb.d
  // Use the mounted path directly
  const fileName = path.basename(filePath);
  const containerPath = `/docker-entrypoint-initdb.d/${fileName}`;
  
  const command = `docker exec fwd-inh-database psql -U ${process.env.PGUSER} -d ${database} -f ${containerPath}`;
  await runCommand(command);
}

async function main() {
  console.log('🏗️ Database Build Script Starting');
  console.log('=====================================');
  
  try {
    // Step 1: Run migration files in order
    console.log('\n📋 Step 1: Running Database Migrations');
    const migrationFiles = [
      { file: '001_create_database.sql', database: 'postgres' }, // Connect to postgres db to create fwd_db
      '002_create_schema.sql', 
      '003_create_relationships.sql',
      '004_create_procedures.sql'
    ];
    
    for (const migration of migrationFiles) {
      const isObject = typeof migration === 'object';
      const fileName = isObject ? migration.file : migration;
      const database = isObject ? migration.database : process.env.PGDATABASE;
      
      const filePath = path.join(migrationsDir, fileName);
      if (fs.existsSync(filePath)) {
        console.log(`\n  → Executing ${fileName} on database: ${database}`);
        await runSqlFile(filePath, database);
      } else {
        console.warn(`⚠️  Migration file not found: ${fileName}`);
      }
    }
    
    // Step 2: Run test data population (skip clearing for idempotent script)
    console.log('\n📦 Step 2: Populating Test Data');
    await runCommand('npm run test:1:populate', testingDir);
    
    // Step 3: Test stored procedures
    console.log('\n🔧 Step 3: Testing Stored Procedures');
    await runCommand('npm run test:2:procedures', testingDir);
    
    // Step 4: Test SQL files
    console.log('\n📄 Step 4: Testing SQL Files');
    await runCommand('npm run test:3:sql-files', testingDir);
    
    console.log('\n🎉 Database Build Complete!');
    console.log('=====================================');
    
  } catch (error) {
    console.error('\n❌ Database build failed:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { main };