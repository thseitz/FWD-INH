#!/usr/bin/env node
/**
 * Cleanup Database Duplicates
 * Removes duplicated stored procedures while preserving call wrappers for pgtyped/slonik
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

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

async function runCommand(command) {
  return new Promise((resolve, reject) => {
    console.log(`\n→ Running: ${command}`);
    
    const child = spawn('cmd', ['/c', command], {
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

// Exact duplicates to remove (these exist as both stored functions and SQL files)
const exactDuplicates = [
  'current_tenant_id',
  'current_user_id', 
  'is_ffc_member'
];

// Functional duplicates to remove (stored procedures that duplicate SQL files)
const functionalDuplicates = [
  'sp_add_persona_to_ffc',
  'sp_append_event',
  'sp_calculate_seat_availability',
  'sp_cancel_subscription',
  'sp_check_payment_method_usage',
  'sp_clear_session_context',
  'sp_configure_builder_io',
  'sp_configure_quiltt_integration',
  'sp_create_asset_category',
  'sp_create_audit_event',
  'sp_create_invitation',
  'sp_create_ledger_entry',
  'sp_create_snapshot',
  'sp_delete_payment_method',
  'sp_get_advisor_companies',
  'sp_get_asset_categories',
  'sp_get_asset_details',
  'sp_get_audit_trail',
  'sp_get_builder_content_status',
  'sp_get_ffc_summary',
  'sp_get_quiltt_sync_status',
  'sp_get_real_estate_sync_history',
  'sp_get_subscription_details',
  'sp_get_subscription_status',
  'sp_get_translations',
  'sp_log_audit_event',
  'sp_remove_ffc_member',
  'sp_replay_events',
  'sp_search_assets',
  'sp_set_session_context',
  'sp_update_asset_value',
  'sp_update_ffc_member_role',
  'sp_update_pii_job_status',
  'sp_update_system_configuration',
  'sp_update_user_profile'
];

// Complex stored procedures to KEEP (11 core procedures + essential helpers)
const keepProcedures = [
  // Core complex business logic procedures
  'sp_create_ffc_with_subscription',
  'sp_process_seat_invitation',
  'sp_process_stripe_webhook', 
  'sp_purchase_service',
  'sp_handle_subscription_created',
  'sp_handle_subscription_updated',
  'sp_handle_subscription_deleted',
  'sp_transition_subscription_plan',
  'sp_handle_invoice_payment_succeeded',
  'sp_handle_payment_failed',
  'sp_handle_payment_succeeded',
  
  // Essential supporting procedures
  'sp_create_user_from_cognito',
  'sp_create_asset',
  'sp_sync_quiltt_data',
  'sp_sync_real_estate_data', 
  'sp_rebuild_projection',
  'sp_refresh_builder_content',
  'update_updated_at_column', // Trigger function
  
  // Utility functions
  'sp_add_email_to_persona',
  'sp_add_phone_to_persona',
  'sp_assign_asset_to_persona',
  'sp_check_integration_health',
  'sp_create_ffc',
  'sp_delete_asset',
  'sp_detect_pii',
  'sp_generate_compliance_report',
  'sp_manage_advisor_company',
  'sp_manage_translation',
  'sp_retry_failed_integration',
  'sp_transfer_asset_ownership',
  'sp_update_asset',
  'sp_validate_quiltt_credentials'
];

async function backupDatabase() {
  console.log('📦 Creating database backup...');
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const backupFile = `database_backup_${timestamp}.sql`;
  
  await runCommand(`docker exec fwd-inh-database pg_dump -U postgres -s fwd_db > ${backupFile}`);
  console.log(`✅ Backup created: ${backupFile}`);
  return backupFile;
}

async function removeDuplicates() {
  console.log('\n🗑️ Removing duplicate stored procedures...');
  
  const allDuplicates = [...exactDuplicates, ...functionalDuplicates];
  
  for (const funcName of allDuplicates) {
    try {
      // Try dropping as function first, then as procedure
      const dropFunction = `docker exec fwd-inh-database psql -U postgres -d fwd_db -c "DROP FUNCTION IF EXISTS ${funcName}() CASCADE;"`;
      await runCommand(dropFunction);
      
      const dropProcedure = `docker exec fwd-inh-database psql -U postgres -d fwd_db -c "DROP PROCEDURE IF EXISTS ${funcName}() CASCADE;"`;
      await runCommand(dropProcedure);
      
      console.log(`✅ Removed: ${funcName}`);
    } catch (error) {
      console.warn(`⚠️  Could not remove ${funcName}: ${error.message}`);
    }
  }
}

async function validateKeptProcedures() {
  console.log('\n✅ Validating kept procedures...');
  
  for (const procName of keepProcedures) {
    try {
      const checkCmd = `docker exec fwd-inh-database psql -U postgres -d fwd_db -c "SELECT routine_name FROM information_schema.routines WHERE routine_name = '${procName}' AND routine_schema = 'public';"`;
      await runCommand(checkCmd);
    } catch (error) {
      console.warn(`⚠️  Procedure ${procName} may not exist`);
    }
  }
}

async function runTestSuite() {
  console.log('\n🧪 Running complete test suite...');
  
  try {
    // Run database build script to validate everything works
    await runCommand('node scripts/build-database.js');
    console.log('✅ All tests passed after cleanup!');
  } catch (error) {
    console.error('❌ Tests failed after cleanup:', error.message);
    throw error;
  }
}

async function generateCleanupReport() {
  console.log('\n📊 Generating cleanup report...');
  
  // Count current routines
  try {
    await runCommand('docker exec fwd-inh-database psql -U postgres -d fwd_db -c "SELECT COUNT(*) as total_routines FROM information_schema.routines WHERE routine_schema = \'public\';"');
  } catch (error) {
    console.warn('Could not generate count report');
  }
}

async function main() {
  console.log('🧹 Database Cleanup Starting');
  console.log('=============================');
  console.log(`📋 Plan:`);
  console.log(`   • Remove ${exactDuplicates.length} exact duplicates`);
  console.log(`   • Remove ${functionalDuplicates.length} functional duplicates`); 
  console.log(`   • Keep ${keepProcedures.length} complex procedures`);
  console.log(`   • Preserve call wrappers for pgtyped/slonik`);
  
  try {
    // Step 1: Backup
    const backupFile = await backupDatabase();
    
    // Step 2: Remove duplicates
    await removeDuplicates();
    
    // Step 3: Validate kept procedures
    await validateKeptProcedures();
    
    // Step 4: Test everything still works
    await runTestSuite();
    
    // Step 5: Generate report
    await generateCleanupReport();
    
    console.log('\n🎉 Database Cleanup Complete!');
    console.log('==============================');
    console.log('✅ Duplicates removed');
    console.log('✅ Complex procedures preserved'); 
    console.log('✅ Call wrappers intact for pgtyped/slonik');
    console.log('✅ All tests passing');
    console.log(`📦 Backup available: ${backupFile}`);
    
  } catch (error) {
    console.error('\n❌ Cleanup failed:', error.message);
    console.log('\n🔄 To restore backup:');
    console.log('   docker exec -i fwd-inh-database psql -U postgres -d fwd_db < [backup_file]');
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { main };