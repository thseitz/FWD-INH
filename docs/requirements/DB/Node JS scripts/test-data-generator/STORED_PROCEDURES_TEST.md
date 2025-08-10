# Stored Procedures Testing Framework

## Overview

This testing framework validates all 50 stored procedures in the Forward Inheritance Platform database. It provides comprehensive testing coverage for:

- **28 Core Procedures**: User management, FFC operations, asset management, audit logging
- **4 Event Sourcing Procedures**: Event store management and projections
- **18 Integration Procedures**: External system integrations (Quillt, Builder.io, Real Estate providers)

## Prerequisites

1. PostgreSQL 14+ installed and running
2. Node.js 16+ installed
3. The FWD-INH database created and initialized with:
   - `1_SQL_create_fwd_db.sql`
   - `2_SQL_create_schema_structure.sql`
   - `3_SQL_create_schema_relationships.sql`
   - `4_SQL_create_procs.sql`

## Setup

1. **Install dependencies:**
   ```bash
   cd "C:\Users\bob\github-thseitz\fwd-inh\docs\requirements\DB\Node JS scripts\test-data-generator"
   npm install
   ```

2. **Configure database connection:**
   ```bash
   # Copy the example environment file
   cp .env.example .env

   # Edit .env with your database credentials
   # Set DB_PASSWORD to your actual password
   ```

3. **Build the TypeScript files:**
   ```bash
   npm run build
   ```

## Running Tests

### Test All Procedures
```bash
npm run test-procedures
```

### Quick Test (using tsx)
```bash
npm run test-procs
```

## Test Categories

### Core Procedures (28)

#### RLS Helper Functions (3)
- `current_user_id()` - Get current user ID from session
- `current_tenant_id()` - Get current tenant ID from session
- `is_ffc_member()` - Check if user is FFC member

#### User Management (2)
- `sp_create_user_from_cognito` - Create user from AWS Cognito
- `sp_update_user_profile` - Update user profile information

#### FFC Management (4)
- `sp_create_ffc` - Create new Forward Family Circle
- `sp_add_persona_to_ffc` - Add persona to FFC
- `sp_update_ffc_member_role` - Update member role in FFC
- `sp_remove_ffc_member` - Remove member from FFC

#### Asset Management (8)
- `sp_create_asset` - Create new asset
- `sp_update_asset` - Update asset details
- `sp_delete_asset` - Delete asset
- `sp_transfer_asset_ownership` - Transfer ownership between personas
- `sp_update_asset_value` - Update asset valuation
- `sp_get_asset_details` - Get detailed asset information
- `sp_search_assets` - Search assets with filters
- `sp_assign_asset_to_persona` - Assign asset to persona

#### Contact Management (2)
- `sp_add_email_to_persona` - Add email to persona
- `sp_add_phone_to_persona` - Add phone to persona

#### Invitation Management (1)
- `sp_create_invitation` - Create FFC invitation

#### Audit & Compliance (4)
- `sp_log_audit_event` - Log audit event
- `sp_create_audit_event` - Create business event
- `sp_get_audit_trail` - Get audit trail for entity
- `sp_generate_compliance_report` - Generate compliance report

#### Reporting (1)
- `sp_get_ffc_summary` - Get FFC summary report

#### Session Management (2)
- `sp_set_session_context` - Set session context
- `sp_clear_session_context` - Clear session context

#### Utility (1)
- `update_updated_at_column` - Trigger function for timestamps

### Event Sourcing Procedures (4)
- `sp_append_event` - Append event to event store
- `sp_replay_events` - Replay events for aggregate
- `sp_create_snapshot` - Create aggregate snapshot
- `sp_rebuild_projection` - Rebuild projection from events

### Integration Procedures (18)

#### PII Management (2)
- `sp_detect_pii` - Detect PII in text
- `sp_update_pii_job_status` - Update PII processing job status

#### Quillt Integration (4)
- `sp_configure_quillt_integration` - Configure Quillt connection
- `sp_sync_quillt_data` - Sync financial data
- `sp_validate_quillt_credentials` - Validate credentials
- `sp_get_quillt_sync_status` - Get sync status

#### Real Estate (2)
- `sp_sync_real_estate_data` - Sync property data
- `sp_get_real_estate_sync_history` - Get sync history

#### Advisor Companies (2)
- `sp_manage_advisor_company` - Manage advisor companies
- `sp_get_advisor_companies` - Get advisor companies list

#### Integration Health (2)
- `sp_check_integration_health` - Check integration health
- `sp_retry_failed_integration` - Retry failed integration

#### Builder.io (3)
- `sp_configure_builder_io` - Configure Builder.io
- `sp_refresh_builder_content` - Refresh CMS content
- `sp_get_builder_content_status` - Get content status

#### Translation (2)
- `sp_manage_translation` - Manage translations
- `sp_get_translations` - Get translations

#### System (1)
- `sp_update_system_configuration` - Update system config

## Test Output

The test runner provides detailed output for each procedure:

```
✅ User Management - sp_create_user_from_cognito: SUCCESS
❌ Asset Management - sp_delete_asset: FAILED
   Error: permission denied for table assets
```

### Summary Report

At the end of testing, you'll see a comprehensive summary:

```
══════════════════════════════════════════════════════════
📊 TEST SUMMARY
══════════════════════════════════════════════════════════
Total Procedures: 50
✅ Successful: 48
❌ Failed: 2
⏭️  Skipped: 0
⏱️  Total Execution Time: 3456ms
══════════════════════════════════════════════════════════
```

## Troubleshooting

### Common Issues

1. **Connection refused error:**
   - Ensure PostgreSQL is running
   - Check host and port in .env file
   - Verify firewall settings

2. **Permission denied errors:**
   - Ensure user has necessary privileges
   - Grant execute permissions on procedures:
   ```sql
   GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO your_user;
   ```

3. **Procedure not found:**
   - Ensure `4_SQL_create_procs_50.sql` has been executed
   - Check for any errors during SQL execution

4. **Test data conflicts:**
   - The framework includes automatic cleanup
   - If tests fail midway, manually clean test data:
   ```sql
   DELETE FROM audit_log WHERE tenant_id = 1;
   DELETE FROM audit_events WHERE tenant_id = 1;
   DELETE FROM asset_persona WHERE tenant_id = 1;
   DELETE FROM assets WHERE tenant_id = 1;
   DELETE FROM ffc_personas WHERE tenant_id = 1;
   DELETE FROM fwd_family_circles WHERE tenant_id = 1;
   DELETE FROM personas WHERE tenant_id = 1;
   DELETE FROM users WHERE tenant_id = 1;
   ```

## Fixing Failed Procedures

When a procedure fails testing:

1. **Check the error message** in the test output
2. **Review the procedure** in `4_SQL_create_procs_50.sql`
3. **Fix the issue** in the SQL file
4. **Re-run the procedure creation:**
   ```bash
   psql -U postgres -d fwd_db -f "4_SQL_create_procs_50.sql"
   ```
5. **Re-run the tests:**
   ```bash
   npm run test-procedures
   ```

## Adding New Procedures

To add a new procedure to the test suite:

1. Add the procedure to `4_SQL_create_procs_50.sql`
2. Add a test case in `StoredProcedureTester.ts` in the appropriate category
3. Update the procedure count in the test summary
4. Run the tests to verify

## Performance Notes

- Tests run sequentially to avoid transaction conflicts
- Each test uses its own test data to ensure isolation
- Cleanup happens automatically after all tests complete
- Average execution time: 50-100ms per procedure

## CI/CD Integration

To integrate with CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Test Stored Procedures
  run: |
    npm install
    npm run build
    npm run test-procedures
  env:
    DB_HOST: localhost
    DB_PORT: 5432
    DB_NAME: fwd_db
    DB_USER: postgres
    DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

## Support

For issues or questions:
1. Check the error logs in the test output
2. Review the stored procedure definitions
3. Ensure all database migrations have been applied
4. Verify user permissions and database connectivity