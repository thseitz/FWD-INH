import { Pool, PoolClient } from 'pg';
import { faker } from '@faker-js/faker';

export interface ProcedureTestResult {
  procedureName: string;
  category: string;
  status: 'success' | 'failure' | 'skipped';
  error?: string;
  executionTime: number;
  testData?: any;
  result?: any;
}

export interface TestSummary {
  totalProcedures: number;
  successful: number;
  failed: number;
  skipped: number;
  totalExecutionTime: number;
  results: ProcedureTestResult[];
}

export class StoredProcedureTester {
  private pool: Pool;
  private tenantId: number = 1;
  private testUserId: string = '';
  private testPersonaId: string = '';
  private testFfcId: string = '';
  private testAssetId: string = '';

  constructor(pool: Pool) {
    this.pool = pool;
  }

  /**
   * Main test execution method - tests all 50 stored procedures
   */
  async testAllProcedures(): Promise<TestSummary> {
    console.log('🚀 Starting comprehensive stored procedure testing...\n');
    
    const summary: TestSummary = {
      totalProcedures: 50,
      successful: 0,
      failed: 0,
      skipped: 0,
      totalExecutionTime: 0,
      results: []
    };

    const client = await this.pool.connect();
    
    try {
      // Setup test data
      await this.setupTestData(client);

      // Test Core Procedures (28)
      await this.testCoreProcedures(client, summary);
      
      // Test Event Sourcing Procedures (4)
      await this.testEventSourcingProcedures(client, summary);
      
      // Test Integration Procedures (18)
      await this.testIntegrationProcedures(client, summary);

      // Print summary
      this.printTestSummary(summary);
      
      return summary;
      
    } catch (error) {
      console.error('❌ Critical error during testing:', error);
      throw error;
    } finally {
      // Cleanup test data
      await this.cleanupTestData(client);
      client.release();
    }
  }

  /**
   * Test Core Procedures (28 procedures)
   */
  private async testCoreProcedures(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Core Procedures...\n');

    // RLS Helper Functions (3)
    await this.testProcedure(client, summary, 'RLS Helper', 'current_user_id', async () => {
      await client.query(`SET LOCAL app.current_user_id = '${this.testUserId}'`);
      const result = await client.query('SELECT current_user_id()');
      return result.rows[0];
    });

    await this.testProcedure(client, summary, 'RLS Helper', 'current_tenant_id', async () => {
      await client.query(`SET LOCAL app.current_tenant_id = '${this.tenantId}'`);
      const result = await client.query('SELECT current_tenant_id()');
      return result.rows[0];
    });

    await this.testProcedure(client, summary, 'RLS Helper', 'is_ffc_member', async () => {
      const result = await client.query('SELECT is_ffc_member($1, $2)', [this.testFfcId, this.testUserId]);
      return result.rows[0];
    });

    // User Management (2)
    await this.testProcedure(client, summary, 'User Management', 'sp_create_user_from_cognito', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_cognito_user_id: faker.string.uuid(),
        p_cognito_username: faker.internet.userName(),
        p_email: faker.internet.email(),
        p_phone: faker.phone.number('+1##########'),
        p_first_name: faker.person.firstName(),
        p_last_name: faker.person.lastName()
      };
      
      const result = await client.query(
        'CALL sp_create_user_from_cognito($1, $2, $3, $4, $5, $6, $7, NULL)',
        [
          testData.p_tenant_id,
          testData.p_cognito_user_id,
          testData.p_cognito_username,
          testData.p_email,
          testData.p_phone,
          testData.p_first_name,
          testData.p_last_name
        ]
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'User Management', 'sp_update_user_profile', async () => {
      const testData = {
        p_user_id: this.testUserId,
        p_first_name: faker.person.firstName(),
        p_last_name: faker.person.lastName(),
        p_display_name: faker.person.fullName(),
        p_profile_picture_url: faker.image.avatar(),
        p_preferred_language: 'en',
        p_timezone: 'America/New_York'
      };
      
      const result = await client.query(
        'CALL sp_update_user_profile($1, $2, $3, $4, $5, $6, $7)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // FFC Management (4)
    await this.testProcedure(client, summary, 'FFC Management', 'sp_create_ffc', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_owner_user_id: this.testUserId,
        p_name: `Test FFC ${faker.company.name()}`,
        p_description: faker.lorem.sentence()
      };
      
      const result = await client.query(
        'CALL sp_create_ffc($1, $2, $3, $4, NULL)',
        [testData.p_tenant_id, testData.p_owner_user_id, testData.p_name, testData.p_description]
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'FFC Management', 'sp_add_persona_to_ffc', async () => {
      const testData = {
        p_ffc_id: this.testFfcId,
        p_persona_id: this.testPersonaId,
        p_role: 'beneficiary'
      };
      
      const result = await client.query(
        'CALL sp_add_persona_to_ffc($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'FFC Management', 'sp_update_ffc_member_role', async () => {
      const testData = {
        p_ffc_id: this.testFfcId,
        p_persona_id: this.testPersonaId,
        p_new_role: 'owner'
      };
      
      const result = await client.query(
        'CALL sp_update_ffc_member_role($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'FFC Management', 'sp_remove_ffc_member', async () => {
      // Create a temp persona to remove
      const tempPersonaResult = await client.query(
        `INSERT INTO personas (tenant_id, user_id, first_name, last_name) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [this.tenantId, this.testUserId, 'Temp', 'Persona']
      );
      const tempPersonaId = tempPersonaResult.rows[0].id;

      // Add to FFC
      await client.query(
        'INSERT INTO ffc_personas (tenant_id, ffc_id, persona_id, ffc_role) VALUES ($1, $2, $3, $4)',
        [this.tenantId, this.testFfcId, tempPersonaId, 'beneficiary']
      );

      // Test removal
      const result = await client.query(
        'CALL sp_remove_ffc_member($1, $2)',
        [this.testFfcId, tempPersonaId]
      );
      return { result: result.rows };
    });

    // Asset Management (8)
    await this.testProcedure(client, summary, 'Asset Management', 'sp_create_asset', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_category_id: faker.string.uuid(),
        p_name: `Test Asset ${faker.commerce.productName()}`,
        p_description: faker.lorem.sentence(),
        p_value: faker.number.float({ min: 1000, max: 100000, fractionDigits: 2 }),
        p_owner_persona_id: this.testPersonaId,
        p_metadata: JSON.stringify({ test: true })
      };
      
      const result = await client.query(
        'CALL sp_create_asset($1, $2, $3, $4, $5, $6, $7, NULL)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_update_asset', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_name: `Updated Asset ${faker.commerce.productName()}`,
        p_description: faker.lorem.sentence(),
        p_value: faker.number.float({ min: 1000, max: 100000, fractionDigits: 2 }),
        p_metadata: JSON.stringify({ updated: true })
      };
      
      const result = await client.query(
        'CALL sp_update_asset($1, $2, $3, $4, $5)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_delete_asset', async () => {
      // Get the category ID we created earlier
      const categoryResult = await client.query(
        `SELECT id FROM asset_categories WHERE name = $1`,
        ['Test Category']
      );
      const categoryId = categoryResult.rows[0].id;

      // Create a temp asset to delete
      const tempAssetResult = await client.query(
        `INSERT INTO assets (tenant_id, name, category_id, estimated_value) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [this.tenantId, 'Temp Asset', categoryId, 1000]
      );
      const tempAssetId = tempAssetResult.rows[0].id;

      const result = await client.query(
        'CALL sp_delete_asset($1)',
        [tempAssetId]
      );
      return { result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_transfer_asset_ownership', async () => {
      // Create a new persona for transfer
      const newPersonaResult = await client.query(
        `INSERT INTO personas (tenant_id, user_id, first_name, last_name) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [this.tenantId, this.testUserId, 'New', 'Owner']
      );
      const newPersonaId = newPersonaResult.rows[0].id;

      const testData = {
        p_asset_id: this.testAssetId,
        p_from_persona_id: this.testPersonaId,
        p_to_persona_id: newPersonaId,
        p_ownership_percentage: 100
      };
      
      const result = await client.query(
        'CALL sp_transfer_asset_ownership($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_update_asset_value', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_new_value: faker.number.float({ min: 1000, max: 100000, fractionDigits: 2 }),
        p_valuation_date: new Date().toISOString().split('T')[0],
        p_notes: 'Test valuation update'
      };
      
      const result = await client.query(
        'CALL sp_update_asset_value($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_get_asset_details', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_asset_details($1)',
        [this.testAssetId]
      );
      return { result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_search_assets', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_search_term: 'Test',
        p_category_id: null,
        p_min_value: null,
        p_max_value: null,
        p_owner_persona_id: null
      };
      
      const result = await client.query(
        'SELECT * FROM sp_search_assets($1, $2, $3, $4, $5, $6)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Asset Management', 'sp_assign_asset_to_persona', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_persona_id: this.testPersonaId,
        p_ownership_type: 'beneficiary',
        p_ownership_percentage: 50
      };
      
      const result = await client.query(
        'CALL sp_assign_asset_to_persona($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Contact Management (2)
    await this.testProcedure(client, summary, 'Contact Management', 'sp_add_email_to_persona', async () => {
      const testData = {
        p_persona_id: this.testPersonaId,
        p_email: faker.internet.email(),
        p_email_type: 'personal',
        p_usage_type: 'primary',
        p_is_primary: true
      };
      
      const result = await client.query(
        'CALL sp_add_email_to_persona($1, $2, $3, $4, $5)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Contact Management', 'sp_add_phone_to_persona', async () => {
      const testData = {
        p_persona_id: this.testPersonaId,
        p_phone: faker.phone.number('+1##########'),
        p_phone_type: 'mobile',
        p_usage_type: 'primary',
        p_is_primary: true
      };
      
      const result = await client.query(
        'CALL sp_add_phone_to_persona($1, $2, $3, $4, $5)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Invitation Management (1)
    await this.testProcedure(client, summary, 'Invitation Management', 'sp_create_invitation', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_ffc_id: this.testFfcId,
        p_invited_by_user_id: this.testUserId,
        p_invitee_email: faker.internet.email(),
        p_invitee_phone: faker.phone.number('+1##########'),
        p_invitee_first_name: faker.person.firstName(),
        p_invitee_last_name: faker.person.lastName(),
        p_role: 'beneficiary'
      };
      
      const result = await client.query(
        'CALL sp_create_invitation($1, $2, $3, $4, $5, $6, $7, $8, NULL, NULL, NULL)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Audit & Compliance (4)
    await this.testProcedure(client, summary, 'Audit', 'sp_log_audit_event', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_user_id: this.testUserId,
        p_action: 'update',
        p_entity_type: 'asset',
        p_entity_id: this.testAssetId,
        p_details: JSON.stringify({ test: true }),
        p_ip_address: '192.168.1.1'
      };
      
      const result = await client.query(
        'CALL sp_log_audit_event($1, $2, $3, $4, $5, $6, $7)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Audit', 'sp_create_audit_event', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_event_type: 'asset_created',
        p_event_data: JSON.stringify({ asset_id: this.testAssetId }),
        p_user_id: this.testUserId,
        p_metadata: JSON.stringify({ source: 'test' })
      };
      
      const result = await client.query(
        'CALL sp_create_audit_event($1, $2, $3, $4, $5)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Audit', 'sp_get_audit_trail', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_entity_type: 'asset',
        p_entity_id: this.testAssetId,
        p_start_date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
        p_end_date: new Date().toISOString()
      };
      
      const result = await client.query(
        'SELECT * FROM sp_get_audit_trail($1, $2, $3, $4, $5)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Audit', 'sp_generate_compliance_report', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_report_type: 'weekly_activity',
        p_start_date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
        p_end_date: new Date().toISOString()
      };
      
      const result = await client.query(
        'SELECT * FROM sp_generate_compliance_report($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Reporting (1)
    await this.testProcedure(client, summary, 'Reporting', 'sp_get_ffc_summary', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_ffc_summary($1)',
        [this.testFfcId]
      );
      return { result: result.rows };
    });

    // Session Context (2)
    await this.testProcedure(client, summary, 'Session', 'sp_set_session_context', async () => {
      const testData = {
        p_user_id: this.testUserId,
        p_tenant_id: this.tenantId
      };
      
      const result = await client.query(
        'CALL sp_set_session_context($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Session', 'sp_clear_session_context', async () => {
      const result = await client.query('CALL sp_clear_session_context()');
      return { result: result.rows };
    });

    // Utility Functions (1)
    await this.testProcedure(client, summary, 'Utility', 'update_updated_at_column', async () => {
      // This is a trigger function, test by updating a record
      const result = await client.query(
        'UPDATE users SET first_name = $1 WHERE id = $2 RETURNING updated_at',
        ['Updated Name', this.testUserId]
      );
      return { result: result.rows };
    });
  }

  /**
   * Test Event Sourcing Procedures (4 procedures)
   */
  private async testEventSourcingProcedures(client: PoolClient, summary: TestSummary) {
    console.log('\n📊 Testing Event Sourcing Procedures...\n');

    await this.testProcedure(client, summary, 'Event Sourcing', 'sp_append_event', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_aggregate_id: this.testAssetId,
        p_aggregate_type: 'asset',
        p_event_type: 'asset_updated',
        p_event_data: JSON.stringify({ value: 50000 }),
        p_user_id: this.testUserId,
        p_metadata: JSON.stringify({ source: 'test' })
      };
      
      const result = await client.query(
        'CALL sp_append_event($1, $2, $3, $4, $5, $6, $7, NULL)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Event Sourcing', 'sp_replay_events', async () => {
      const testData = {
        p_aggregate_id: this.testAssetId,
        p_from_version: 1,
        p_to_version: null
      };
      
      const result = await client.query(
        'SELECT * FROM sp_replay_events($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Event Sourcing', 'sp_create_snapshot', async () => {
      const testData = {
        p_aggregate_id: this.testAssetId,
        p_aggregate_type: 'asset',
        p_version: 1,
        p_state: JSON.stringify({ current_value: 50000 })
      };
      
      const result = await client.query(
        'CALL sp_create_snapshot($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Event Sourcing', 'sp_rebuild_projection', async () => {
      const testData = {
        p_projection_name: 'asset_summary',
        p_aggregate_type: 'asset',
        p_aggregate_id: this.testAssetId
      };
      
      const result = await client.query(
        'CALL sp_rebuild_projection($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });
  }

  /**
   * Test Integration Procedures (18 procedures)
   */
  private async testIntegrationProcedures(client: PoolClient, summary: TestSummary) {
    console.log('\n📊 Testing Integration Procedures...\n');

    // PII Management (2)
    await this.testProcedure(client, summary, 'PII Management', 'sp_detect_pii', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_text_content: 'My SSN is 123-45-6789 and credit card 4111111111111111',
        p_entity_type: 'document',
        p_entity_id: faker.string.uuid()
      };
      
      const result = await client.query(
        'SELECT * FROM sp_detect_pii($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'PII Management', 'sp_update_pii_job_status', async () => {
      // First create a PII job (no entity_type/entity_id columns)
      const jobResult = await client.query(
        `INSERT INTO pii_processing_jobs (tenant_id, job_type, status, processing_options) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [this.tenantId, 'scan', 'pending', JSON.stringify({entity_type: 'document', entity_id: faker.string.uuid()})]
      );
      const jobId = jobResult.rows[0].id;

      const testData = {
        p_job_id: jobId,
        p_status: 'completed',
        p_results: JSON.stringify({ pii_found: true })
      };
      
      const result = await client.query(
        'CALL sp_update_pii_job_status($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Quillt Integration (4)
    await this.testProcedure(client, summary, 'Quillt Integration', 'sp_configure_quillt_integration', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_user_id: this.testUserId,
        p_connection_id: faker.string.uuid(),
        p_configuration: JSON.stringify({ api_key: 'test-key' })
      };
      
      const result = await client.query(
        'CALL sp_configure_quillt_integration($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Quillt Integration', 'sp_sync_quillt_data', async () => {
      // First create integration (use quillt_connection_id not connection_id)
      const integrationResult = await client.query(
        `INSERT INTO quillt_integrations (tenant_id, user_id, quillt_connection_id, connection_status) 
         VALUES ($1, $2, $3, $4) RETURNING id`,
        [this.tenantId, this.testUserId, faker.string.uuid(), 'connected']
      );
      const integrationId = integrationResult.rows[0].id;

      const testData = {
        p_integration_id: integrationId,
        p_sync_type: 'accounts'
      };
      
      const result = await client.query(
        'CALL sp_sync_quillt_data($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Quillt Integration', 'sp_validate_quillt_credentials', async () => {
      const testData = {
        p_user_id: this.testUserId,
        p_connection_id: faker.string.uuid()
      };
      
      const result = await client.query(
        'SELECT * FROM sp_validate_quillt_credentials($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Quillt Integration', 'sp_get_quillt_sync_status', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_quillt_sync_status($1)',
        [this.testUserId]
      );
      return { result: result.rows };
    });

    // Real Estate (2)
    await this.testProcedure(client, summary, 'Real Estate', 'sp_sync_real_estate_data', async () => {
      // First create or get existing integration (unique per tenant/provider)
      const integrationResult = await client.query(
        `INSERT INTO real_estate_provider_integrations (tenant_id, provider_name, api_endpoint, is_active) 
         VALUES ($1, $2, $3, $4) 
         ON CONFLICT (tenant_id, provider_name) 
         DO UPDATE SET api_endpoint = EXCLUDED.api_endpoint
         RETURNING id`,
        [this.tenantId, 'zillow', 'https://api.zillow.com', true]
      );
      const integrationId = integrationResult.rows[0].id;

      const testData = {
        p_integration_id: integrationId,
        p_property_address: '123 Main St, Anytown, USA'
      };
      
      const result = await client.query(
        'CALL sp_sync_real_estate_data($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Real Estate', 'sp_get_real_estate_sync_history', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_days_back: 30
      };
      
      const result = await client.query(
        'SELECT * FROM sp_get_real_estate_sync_history($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Advisor Companies (2)
    await this.testProcedure(client, summary, 'Advisor Companies', 'sp_manage_advisor_company', async () => {
      const testData = {
        p_operation: 'create',
        p_tenant_id: this.tenantId,
        p_company_name: faker.company.name(),
        p_company_type: 'financial_advisor',
        p_contact_info: JSON.stringify({ phone: faker.phone.number() }),
        p_company_id: null
      };
      
      const result = await client.query(
        'CALL sp_manage_advisor_company($1, $2, $3, $4, $5, $6, NULL)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Advisor Companies', 'sp_get_advisor_companies', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_company_type: null,
        p_is_active: true
      };
      
      const result = await client.query(
        'SELECT * FROM sp_get_advisor_companies($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Integration Health (2)
    await this.testProcedure(client, summary, 'Integration Health', 'sp_check_integration_health', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_integration_type: 'quillt'
      };
      
      const result = await client.query(
        'SELECT * FROM sp_check_integration_health($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Integration Health', 'sp_retry_failed_integration', async () => {
      const testData = {
        p_integration_type: 'quillt',
        p_integration_id: faker.string.uuid(),
        p_retry_count: 1
      };
      
      const result = await client.query(
        'CALL sp_retry_failed_integration($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // Builder.io (3)
    await this.testProcedure(client, summary, 'Builder.io', 'sp_configure_builder_io', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_api_key: faker.string.alphanumeric(32),
        p_space_id: faker.string.uuid(),
        p_environment: 'production'
      };
      
      const result = await client.query(
        'CALL sp_configure_builder_io($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Builder.io', 'sp_refresh_builder_content', async () => {
      // First create or get existing integration (unique per tenant)
      const integrationResult = await client.query(
        `INSERT INTO builder_io_integrations (tenant_id, api_key, space_id, environment, is_active) 
         VALUES ($1, $2, $3, $4, $5) 
         ON CONFLICT (tenant_id) 
         DO UPDATE SET api_key = EXCLUDED.api_key, updated_at = NOW()
         RETURNING id`,
        [this.tenantId, 'test-key', faker.string.uuid(), 'production', true]
      );
      const integrationId = integrationResult.rows[0].id;

      const testData = {
        p_integration_id: integrationId,
        p_content_type: 'page'
      };
      
      const result = await client.query(
        'CALL sp_refresh_builder_content($1, $2)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Builder.io', 'sp_get_builder_content_status', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_builder_content_status($1)',
        [this.tenantId]
      );
      return { result: result.rows };
    });

    // Translation (2)
    await this.testProcedure(client, summary, 'Translation', 'sp_manage_translation', async () => {
      const testData = {
        p_operation: 'create',
        p_entity_type: 'asset',
        p_entity_id: this.testAssetId,
        p_language_code: 'es',
        p_field_name: 'description',
        p_original_text: 'Test asset description',
        p_translated_text: 'Descripción del activo de prueba',
        p_translation_id: null
      };
      
      const result = await client.query(
        'CALL sp_manage_translation($1, $2, $3, $4, $5, $6, $7, $8, NULL)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testProcedure(client, summary, 'Translation', 'sp_get_translations', async () => {
      const testData = {
        p_entity_type: 'asset',
        p_entity_id: this.testAssetId,
        p_language_code: 'es'
      };
      
      const result = await client.query(
        'SELECT * FROM sp_get_translations($1, $2, $3)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    // System Configuration (1)
    await this.testProcedure(client, summary, 'System', 'sp_update_system_configuration', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_config_key: 'test_setting',
        p_config_value: JSON.stringify({ enabled: true }),
        p_updated_by: this.testUserId
      };
      
      const result = await client.query(
        'CALL sp_update_system_configuration($1, $2, $3, $4)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });
  }

  /**
   * Execute a single procedure test
   */
  private async testProcedure(
    client: PoolClient,
    summary: TestSummary,
    category: string,
    procedureName: string,
    testFunc: () => Promise<any>
  ): Promise<void> {
    const startTime = Date.now();
    const result: ProcedureTestResult = {
      procedureName,
      category,
      status: 'skipped',
      executionTime: 0
    };

    try {
      const testResult = await testFunc();
      result.status = 'success';
      result.result = testResult;
      summary.successful++;
      console.log(`✅ ${category} - ${procedureName}: SUCCESS`);
    } catch (error: any) {
      result.status = 'failure';
      result.error = error.message;
      summary.failed++;
      console.log(`❌ ${category} - ${procedureName}: FAILED`);
      console.log(`   Error: ${error.message}`);
    }

    result.executionTime = Date.now() - startTime;
    summary.totalExecutionTime += result.executionTime;
    summary.results.push(result);
  }

  /**
   * Setup initial test data
   */
  private async setupTestData(client: PoolClient): Promise<void> {
    console.log('🔧 Setting up test data...\n');

    // Ensure tenant exists
    const tenantResult = await client.query(
      `INSERT INTO tenants (id, name, display_name) 
       VALUES ($1, $2, $3) 
       ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name 
       RETURNING id`,
      [this.tenantId, 'test-tenant', 'Test Tenant']
    );

    // Create test user
    const userResult = await client.query(
      `INSERT INTO users (tenant_id, cognito_user_id, first_name, last_name, status) 
       VALUES ($1, $2, $3, $4, $5) 
       RETURNING id`,
      [this.tenantId, faker.string.uuid(), 'Test', 'User', 'active']
    );
    this.testUserId = userResult.rows[0].id;

    // Create test persona
    const personaResult = await client.query(
      `INSERT INTO personas (tenant_id, user_id, first_name, last_name) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id`,
      [this.tenantId, this.testUserId, 'Test', 'Persona']
    );
    this.testPersonaId = personaResult.rows[0].id;

    // Create test FFC
    const ffcResult = await client.query(
      `INSERT INTO fwd_family_circles (tenant_id, owner_user_id, name, description) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id`,
      [this.tenantId, this.testUserId, 'Test FFC', 'Test Family Circle']
    );
    this.testFfcId = ffcResult.rows[0].id;

    // Add persona to FFC
    await client.query(
      `INSERT INTO ffc_personas (tenant_id, ffc_id, persona_id, ffc_role) 
       VALUES ($1, $2, $3, $4)`,
      [this.tenantId, this.testFfcId, this.testPersonaId, 'owner']
    );

    // Create test asset category first (global table, no tenant_id)
    const categoryResult = await client.query(
      `INSERT INTO asset_categories (name, code, description, sort_order) 
       VALUES ($1, $2, $3, $4) 
       ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
       RETURNING id`,
      ['Test Category', 'TEST_CAT', 'Test category for procedures', 1]
    );
    const categoryId = categoryResult.rows[0].id;

    // Create test asset
    const assetResult = await client.query(
      `INSERT INTO assets (tenant_id, name, category_id, estimated_value) 
       VALUES ($1, $2, $3, $4) 
       RETURNING id`,
      [this.tenantId, 'Test Asset', categoryId, 10000]
    );
    this.testAssetId = assetResult.rows[0].id;

    // Create asset ownership
    await client.query(
      `INSERT INTO asset_persona (tenant_id, asset_id, persona_id, ownership_type, ownership_percentage) 
       VALUES ($1, $2, $3, $4, $5)`,
      [this.tenantId, this.testAssetId, this.testPersonaId, 'owner', 100]
    );

    console.log('✅ Test data setup complete\n');
  }

  /**
   * Cleanup test data
   */
  private async cleanupTestData(client: PoolClient): Promise<void> {
    console.log('\n🧹 Cleaning up test data...');

    try {
      // Clean in reverse dependency order
      await client.query('DELETE FROM audit_log WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM audit_events WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM asset_persona WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM assets WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM ffc_personas WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM fwd_family_circles WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM personas WHERE tenant_id = $1', [this.tenantId]);
      await client.query('DELETE FROM users WHERE tenant_id = $1', [this.tenantId]);
      
      console.log('✅ Test data cleanup complete');
    } catch (error) {
      console.log('⚠️  Cleanup encountered errors (non-critical)');
    }
  }

  /**
   * Print test summary
   */
  private printTestSummary(summary: TestSummary): void {
    console.log('\n' + '='.repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('='.repeat(60));
    console.log(`Total Procedures: ${summary.totalProcedures}`);
    console.log(`✅ Successful: ${summary.successful}`);
    console.log(`❌ Failed: ${summary.failed}`);
    console.log(`⏭️  Skipped: ${summary.skipped}`);
    console.log(`⏱️  Total Execution Time: ${summary.totalExecutionTime}ms`);
    console.log('='.repeat(60));

    if (summary.failed > 0) {
      console.log('\n❌ FAILED PROCEDURES:');
      summary.results
        .filter(r => r.status === 'failure')
        .forEach(r => {
          console.log(`  - ${r.category} / ${r.procedureName}`);
          console.log(`    Error: ${r.error}`);
        });
    }
  }
}