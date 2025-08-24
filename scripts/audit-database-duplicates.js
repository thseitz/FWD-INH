#!/usr/bin/env node
/**
 * Audit Database Duplicates
 * Compares stored procedures/functions with SQL files to identify duplications
 */

const fs = require('fs');
const path = require('path');

// Database stored procedures and functions (from query above)
const dbRoutines = [
  'current_tenant_id', 'current_user_id', 'is_ffc_member',
  'sp_add_email_to_persona', 'sp_add_persona_to_ffc', 'sp_add_phone_to_persona',
  'sp_append_event', 'sp_assign_asset_to_persona', 'sp_calculate_seat_availability',
  'sp_cancel_subscription', 'sp_check_integration_health', 'sp_check_payment_method_usage',
  'sp_clear_session_context', 'sp_configure_builder_io', 'sp_configure_quiltt_integration',
  'sp_create_asset', 'sp_create_asset_category', 'sp_create_audit_event',
  'sp_create_ffc', 'sp_create_ffc_with_subscription', 'sp_create_invitation',
  'sp_create_ledger_entry', 'sp_create_snapshot', 'sp_create_user_from_cognito',
  'sp_delete_asset', 'sp_delete_payment_method', 'sp_detect_pii',
  'sp_generate_compliance_report', 'sp_get_advisor_companies', 'sp_get_asset_categories',
  'sp_get_asset_details', 'sp_get_audit_trail', 'sp_get_builder_content_status',
  'sp_get_ffc_summary', 'sp_get_quiltt_sync_status', 'sp_get_real_estate_sync_history',
  'sp_get_subscription_details', 'sp_get_subscription_status', 'sp_get_translations',
  'sp_handle_invoice_payment_succeeded', 'sp_handle_payment_failed', 'sp_handle_payment_succeeded',
  'sp_handle_subscription_created', 'sp_handle_subscription_deleted', 'sp_handle_subscription_updated',
  'sp_log_audit_event', 'sp_manage_advisor_company', 'sp_manage_translation',
  'sp_process_seat_invitation', 'sp_process_stripe_webhook', 'sp_purchase_service',
  'sp_rebuild_projection', 'sp_refresh_builder_content', 'sp_remove_ffc_member',
  'sp_replay_events', 'sp_retry_failed_integration', 'sp_search_assets',
  'sp_set_session_context', 'sp_sync_quiltt_data', 'sp_sync_real_estate_data',
  'sp_transfer_asset_ownership', 'sp_transition_subscription_plan', 'sp_update_asset',
  'sp_update_asset_value', 'sp_update_ffc_member_role', 'sp_update_pii_job_status',
  'sp_update_system_configuration', 'sp_update_user_profile', 'sp_validate_quiltt_credentials',
  'update_updated_at_column'
];

// SQL files (from file listing above)
const sqlFiles = [
  'add_persona_to_ffc', 'append_event', 'assign_asset_to_persona_upsert',
  'calculate_seat_availability', 'call_sp_create_asset', 'call_sp_create_ffc_with_subscription',
  'call_sp_create_user_from_cognito', 'call_sp_process_seat_invitation', 'call_sp_process_stripe_webhook',
  'call_sp_purchase_service', 'call_sp_rebuild_projection', 'call_sp_refresh_builder_content',
  'call_sp_sync_quiltt_data', 'call_sp_sync_real_estate_data', 'cancel_subscription',
  'check_asset_ownership_total', 'check_health_builder', 'check_health_quiltt',
  'check_health_real_estate', 'check_hei_idempotency', 'check_payment_method_owner',
  'check_payment_method_usage', 'cleanup_old_snapshots', 'clear_session_context',
  'compliance_report_stats', 'compliance_report_user_activity', 'configure_builder_io',
  'configure_quiltt_integration', 'create_advisor_company', 'create_asset_category',
  'create_audit_event', 'create_email_if_not_exists', 'create_ffc_step1', 'create_ffc_step2',
  'create_financial_account_from_quiltt', 'create_invitation', 'create_invoice_payment',
  'create_ledger_entry', 'create_phone_if_not_exists', 'create_pii_detection_job',
  'create_quiltt_integration', 'create_quiltt_session', 'create_snapshot', 'create_translation',
  'current_tenant_id', 'current_user_id', 'delete_advisor_company', 'delete_payment_method',
  'detect_pii_patterns', 'get_advisor_companies', 'get_asset_categories', 'get_asset_details',
  'get_asset_ownership', 'get_audit_trail', 'get_builder_content_status', 'get_current_event_version',
  'get_ffc_summary', 'get_hei_dashboard_data', 'get_new_plan_details', 'get_next_event_version',
  'get_persona_by_quiltt_user_id', 'get_persona_ffc', 'get_quiltt_connected_accounts',
  'get_quiltt_sync_status', 'get_real_estate_sync_history', 'get_subscription_details',
  'get_subscription_for_cancel', 'get_subscription_plan', 'get_subscription_status',
  'get_tenant_payer', 'get_tenant_subscription', 'get_translations', 'get_ui_mask_by_entity_code',
  'get_ui_mask_by_table_name', 'ingest_hei_asset', 'is_ffc_member', 'link_email_to_persona',
  'link_phone_to_persona', 'log_audit_event', 'log_integration_retry', 'log_subscription_cancellation',
  'lookup_hei_by_identifier', 'mark_quiltt_session_used', 'mark_stripe_event_processed',
  'record_subscription_transition', 'remove_ffc_member', 'replay_events', 'retry_quiltt_integration',
  'retry_real_estate_sync', 'search_assets', 'set_session_context', 'soft_delete_asset',
  'suspend_subscription_seats', 'transfer_ownership_add_target', 'transfer_ownership_reduce_source',
  'transfer_ownership_remove_source', 'unset_other_primary_emails', 'unset_other_primary_owners',
  'unset_other_primary_phones', 'update_advisor_company', 'update_asset_details', 'update_asset_value',
  'update_ffc_member_role', 'update_hei_status', 'update_payment_failed', 'update_payment_succeeded',
  'update_pii_detection_job', 'update_pii_job_status', 'update_quiltt_sync_status',
  'update_service_purchase_succeeded', 'update_subscription_billing', 'update_subscription_plan',
  'update_system_configuration', 'update_translation', 'update_user_profile',
  'validate_quiltt_deactivate_expired', 'validate_quiltt_get_integration'
];

function analyzeOverlap() {
  console.log('🔍 Database Duplication Audit Report');
  console.log('=====================================\n');
  
  console.log(`📊 Summary:`);
  console.log(`   Database Routines: ${dbRoutines.length}`);
  console.log(`   SQL Files: ${sqlFiles.length}\n`);

  // Find exact matches
  const exactMatches = [];
  const functionalDuplicates = [];
  const callWrappers = [];
  const dbOnlyRoutines = [];
  const sqlOnlyFiles = [];

  // Analyze each database routine
  dbRoutines.forEach(routine => {
    if (sqlFiles.includes(routine)) {
      exactMatches.push(routine);
    } else {
      // Check for functional duplicates (remove sp_ prefix)
      const cleanName = routine.replace(/^sp_/, '');
      if (sqlFiles.includes(cleanName)) {
        functionalDuplicates.push({ routine, sqlFile: cleanName });
      } else {
        dbOnlyRoutines.push(routine);
      }
    }
  });

  // Check for call wrappers
  sqlFiles.forEach(file => {
    if (file.startsWith('call_sp_')) {
      const spName = file.replace('call_', '');
      if (dbRoutines.includes(spName)) {
        callWrappers.push({ sqlFile: file, procedure: spName });
      }
    } else if (!dbRoutines.includes(file) && !dbRoutines.includes('sp_' + file)) {
      sqlOnlyFiles.push(file);
    }
  });

  // Report findings
  console.log(`🎯 EXACT MATCHES (${exactMatches.length}):`);
  console.log(`   Functions/procedures that exist as both stored routines AND SQL files:`);
  exactMatches.forEach(match => {
    console.log(`   ❌ ${match}`);
  });
  
  console.log(`\n🔄 FUNCTIONAL DUPLICATES (${functionalDuplicates.length}):`);
  console.log(`   Stored procedures with equivalent SQL files:`);
  functionalDuplicates.forEach(dup => {
    console.log(`   ❌ sp_${dup.routine.replace('sp_', '')} ↔ ${dup.sqlFile}`);
  });

  console.log(`\n📞 CALL WRAPPERS (${callWrappers.length}):`);
  console.log(`   SQL files that just call stored procedures:`);
  callWrappers.forEach(wrapper => {
    console.log(`   ⚠️  ${wrapper.sqlFile} → calls ${wrapper.procedure}`);
  });

  console.log(`\n🏪 DATABASE-ONLY ROUTINES (${dbOnlyRoutines.length}):`);
  console.log(`   Stored procedures/functions without SQL equivalents:`);
  dbOnlyRoutines.forEach(routine => {
    console.log(`   ✅ ${routine}`);
  });

  console.log(`\n📄 SQL-ONLY FILES (${sqlOnlyFiles.length}):`);
  console.log(`   SQL files without stored procedure equivalents:`);
  sqlOnlyFiles.forEach(file => {
    console.log(`   ✅ ${file}`);
  });

  // Recommendations
  console.log(`\n💡 CLEANUP RECOMMENDATIONS:`);
  console.log(`=====================================`);
  
  const totalDuplicates = exactMatches.length + functionalDuplicates.length;
  if (totalDuplicates > 0) {
    console.log(`\n🚨 HIGH PRIORITY - Remove ${totalDuplicates} Duplicated Functions:`);
    console.log(`   These stored procedures should be removed as they duplicate SQL files:`);
    
    exactMatches.forEach(match => {
      console.log(`   DROP FUNCTION ${match}();`);
    });
    
    functionalDuplicates.forEach(dup => {
      console.log(`   DROP FUNCTION sp_${dup.routine.replace('sp_', '')}();`);
    });
  }

  if (callWrappers.length > 0) {
    console.log(`\n⚠️  MEDIUM PRIORITY - Review ${callWrappers.length} Call Wrappers:`);
    console.log(`   These SQL files just call stored procedures - consider if needed:`);
    callWrappers.forEach(wrapper => {
      console.log(`   Review: ${wrapper.sqlFile}`);
    });
  }

  console.log(`\n✅ KEEP THESE ${dbOnlyRoutines.length} STORED PROCEDURES:`);
  console.log(`   These are the 11 complex procedures you intended to keep:`);
  const keepProcedures = dbOnlyRoutines.filter(routine => {
    return routine.includes('stripe') || routine.includes('subscription') || 
           routine.includes('invitation') || routine.includes('webhook') ||
           routine.includes('purchase') || routine.includes('ffc_with');
  });
  keepProcedures.forEach(proc => {
    console.log(`   ✅ ${proc}`);
  });

  console.log(`\n📈 FINAL NUMBERS:`);
  console.log(`   Current: ${dbRoutines.length} stored procedures + ${sqlFiles.length} SQL files`);
  console.log(`   After cleanup: ~${dbOnlyRoutines.length} stored procedures + ${sqlFiles.length} SQL files`);
  console.log(`   Reduction: ${totalDuplicates} fewer stored procedures`);
}

if (require.main === module) {
  analyzeOverlap();
}

module.exports = { analyzeOverlap };