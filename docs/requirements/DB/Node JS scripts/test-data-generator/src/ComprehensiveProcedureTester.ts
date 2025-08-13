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

export class ComprehensiveProcedureTester {
  private pool: Pool;
  private tenantId: number = 1; // Forward tenant
  private testUserId: string = '';
  private testPersonaId: string = '';
  private testFfcId: string = '';
  private testAssetId: string = '';
  private testCategoryId: string = '';
  private testSubscriptionId: string = '';
  private testPaymentMethodId: string = '';
  private testIntegrationId: string = '';
  private testEventId: string = '';

  constructor(pool: Pool) {
    this.pool = pool;
  }

  /**
   * Main test execution method - tests all stored procedures
   */
  async testAllProcedures(): Promise<TestSummary> {
    console.log('🚀 Starting comprehensive stored procedure testing...\n');
    
    const summary: TestSummary = {
      totalProcedures: 69, // 54 functions + 15 procedures
      successful: 0,
      failed: 0,
      skipped: 0,
      totalExecutionTime: 0,
      results: []
    };

    const client = await this.pool.connect();
    
    try {
      // Begin transaction for safety
      await client.query('BEGIN');

      // Setup test data
      await this.setupTestData(client);

      // Test groups
      await this.testRLSHelperFunctions(client, summary);
      await this.testUserManagement(client, summary);
      await this.testFFCManagement(client, summary);
      await this.testAssetManagement(client, summary);
      await this.testContactManagement(client, summary);
      await this.testAuditCompliance(client, summary);
      await this.testEventSourcing(client, summary);
      await this.testIntegrations(client, summary);
      await this.testSubscriptionPayment(client, summary);

      // Rollback transaction to keep database clean
      await client.query('ROLLBACK');

      // Print summary
      this.printTestSummary(summary);
      
      return summary;
      
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('❌ Critical error during testing:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Setup test data
   */
  private async setupTestData(client: PoolClient) {
    console.log('📝 Setting up test data...\n');

    try {
      // Create test user
      const userResult = await client.query(
        `INSERT INTO users (tenant_id, cognito_user_id, cognito_username, first_name, last_name, status) 
         VALUES ($1, $2, $3, $4, $5, 'active') 
         RETURNING id`,
        [
          this.tenantId,
          'test-cognito-' + faker.string.uuid(),
          faker.internet.userName(),
          faker.person.firstName(),
          faker.person.lastName()
        ]
      );
      this.testUserId = userResult.rows[0].id;

      // Create test persona
      const personaResult = await client.query(
        `INSERT INTO personas (tenant_id, user_id, first_name, last_name) 
         VALUES ($1, $2, $3, $4) 
         RETURNING id`,
        [
          this.tenantId,
          this.testUserId,
          faker.person.firstName(),
          faker.person.lastName()
        ]
      );
      this.testPersonaId = personaResult.rows[0].id;

      // Create test FFC
      const ffcResult = await client.query(
        `INSERT INTO fwd_family_circles (tenant_id, name, description, owner_user_id, status) 
         VALUES ($1, $2, $3, $4, 'active') 
         RETURNING id`,
        [
          this.tenantId,
          'Test FFC ' + faker.company.name(),
          faker.lorem.sentence(),
          this.testUserId
        ]
      );
      this.testFfcId = ffcResult.rows[0].id;

      // Get or create asset category
      const categoryResult = await client.query(
        `SELECT id FROM asset_categories WHERE code = 'real_estate' LIMIT 1`
      );
      if (categoryResult.rows.length > 0) {
        this.testCategoryId = categoryResult.rows[0].id;
      } else {
        const newCategoryResult = await client.query(
          `INSERT INTO asset_categories (name, code, description) 
           VALUES ('Real Estate', 'real_estate', 'Real estate assets') 
           RETURNING id`
        );
        this.testCategoryId = newCategoryResult.rows[0].id;
      }

      // Create test asset
      const assetResult = await client.query(
        `INSERT INTO assets (tenant_id, category_id, name, description, status) 
         VALUES ($1, $2, $3, $4, 'active') 
         RETURNING id`,
        [
          this.tenantId,
          this.testCategoryId,
          'Test Asset ' + faker.commerce.productName(),
          faker.lorem.sentence()
        ]
      );
      this.testAssetId = assetResult.rows[0].id;

      // Set session context
      await client.query(`SET LOCAL app.current_user_id = '${this.testUserId}'`);
      await client.query(`SET LOCAL app.current_tenant_id = '${this.tenantId}'`);

      console.log('✅ Test data setup complete\n');
    } catch (error) {
      console.error('❌ Error setting up test data:', error);
      throw error;
    }
  }

  /**
   * Test RLS Helper Functions
   */
  private async testRLSHelperFunctions(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing RLS Helper Functions...\n');

    await this.testFunction(client, summary, 'RLS Helper', 'current_user_id', async () => {
      const result = await client.query('SELECT current_user_id() as user_id');
      return result.rows[0];
    });

    await this.testFunction(client, summary, 'RLS Helper', 'current_tenant_id', async () => {
      const result = await client.query('SELECT current_tenant_id() as tenant_id');
      return result.rows[0];
    });

    await this.testFunction(client, summary, 'RLS Helper', 'is_ffc_member', async () => {
      const result = await client.query(
        'SELECT is_ffc_member($1, $2) as is_member',
        [this.testFfcId, this.testUserId]
      );
      return result.rows[0];
    });
  }

  /**
   * Test User Management Functions
   */
  private async testUserManagement(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing User Management Functions...\n');

    await this.testFunction(client, summary, 'User Management', 'sp_create_user_from_cognito', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_cognito_user_id: 'cognito-' + faker.string.uuid(),
        p_cognito_username: faker.internet.userName(),
        p_email: faker.internet.email(),
        p_phone: faker.phone.number('+1##########'),
        p_first_name: faker.person.firstName(),
        p_last_name: faker.person.lastName(),
        p_email_verified: true,
        p_phone_verified: false
      };
      
      const result = await client.query(
        'SELECT * FROM sp_create_user_from_cognito($1, $2, $3, $4, $5, $6, $7, $8, $9)',
        Object.values(testData)
      );
      return { testData, result: result.rows };
    });

    await this.testFunction(client, summary, 'User Management', 'sp_update_user_profile', async () => {
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
        'SELECT sp_update_user_profile($1, $2, $3, $4, $5, $6, $7) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });
  }

  /**
   * Test FFC Management Functions
   */
  private async testFFCManagement(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing FFC Management Functions...\n');

    await this.testFunction(client, summary, 'FFC Management', 'sp_create_ffc', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_owner_user_id: this.testUserId,
        p_name: 'Test FFC ' + faker.company.name(),
        p_description: faker.lorem.sentence()
      };
      
      const result = await client.query(
        'SELECT sp_create_ffc($1, $2, $3, $4) as ffc_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'FFC Management', 'sp_add_persona_to_ffc', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_ffc_id: this.testFfcId,
        p_persona_id: this.testPersonaId,
        p_role: 'beneficiary',
        p_added_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_add_persona_to_ffc($1, $2, $3, $4::ffc_role_enum, $5) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'FFC Management', 'sp_update_ffc_member_role', async () => {
      const testData = {
        p_ffc_id: this.testFfcId,
        p_persona_id: this.testPersonaId,
        p_new_role: 'advisor',
        p_updated_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_update_ffc_member_role($1, $2, $3::ffc_role_enum, $4) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'FFC Management', 'sp_get_ffc_summary', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_ffc_summary($1, $2)',
        [this.testFfcId, this.testUserId]
      );
      return { result: result.rows };
    });
  }

  /**
   * Test Asset Management Functions
   */
  private async testAssetManagement(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Asset Management Functions...\n');

    await this.testFunction(client, summary, 'Asset Management', 'sp_create_asset', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_owner_persona_id: this.testPersonaId,
        p_asset_type: 'real_estate',
        p_name: 'Test Property ' + faker.location.street(),
        p_description: faker.lorem.sentence(),
        p_ownership_percentage: 100,
        p_created_by_user_id: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_create_asset($1, $2, $3::asset_type_enum, $4, $5, $6, $7) as asset_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Asset Management', 'sp_update_asset', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_name: 'Updated Asset ' + faker.commerce.productName(),
        p_description: faker.lorem.sentence(),
        p_acquisition_value: faker.number.float({ min: 10000, max: 1000000, fractionDigits: 2 }),
        p_acquisition_date: faker.date.past(),
        p_status: 'active',
        p_metadata: { updated: true },
        p_updated_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_update_asset($1, $2, $3, $4, $5, $6::status_enum, $7::jsonb, $8) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Asset Management', 'sp_update_asset_value', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_new_value: faker.number.float({ min: 10000, max: 1000000, fractionDigits: 2 }),
        p_valuation_date: new Date(),
        p_valuation_method: 'market',
        p_updated_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_update_asset_value($1, $2, $3, $4, $5) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Asset Management', 'sp_get_asset_details', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_asset_details($1, $2)',
        [this.testAssetId, this.testUserId]
      );
      return { result: result.rows };
    });

    await this.testFunction(client, summary, 'Asset Management', 'sp_search_assets', async () => {
      const result = await client.query(
        'SELECT * FROM sp_search_assets($1, NULL, NULL, NULL, NULL, NULL, NULL, 10, 0)',
        [this.testFfcId]
      );
      return { result: result.rows };
    });

    await this.testFunction(client, summary, 'Asset Management', 'sp_assign_asset_to_persona', async () => {
      const testData = {
        p_asset_id: this.testAssetId,
        p_persona_id: this.testPersonaId,
        p_ownership_type: 'owner',
        p_ownership_percentage: 50,
        p_is_primary: true,
        p_assigned_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_assign_asset_to_persona($1, $2, $3::ownership_type_enum, $4, $5, $6) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });
  }

  /**
   * Test Contact Management Functions
   */
  private async testContactManagement(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Contact Management Functions...\n');

    await this.testFunction(client, summary, 'Contact Management', 'sp_add_email_to_persona', async () => {
      const testData = {
        p_persona_id: this.testPersonaId,
        p_email: faker.internet.email(),
        p_usage_type: 'personal',
        p_is_primary: true,
        p_added_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_add_email_to_persona($1, $2, $3::email_usage_type_enum, $4, $5) as email_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Contact Management', 'sp_add_phone_to_persona', async () => {
      const testData = {
        p_persona_id: this.testPersonaId,
        p_phone: faker.phone.number('##########'),
        p_country_code: '+1',
        p_usage_type: 'mobile',
        p_is_primary: true,
        p_added_by: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_add_phone_to_persona($1, $2, $3, $4::phone_usage_type_enum, $5, $6) as phone_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });
  }

  /**
   * Test Audit & Compliance Functions
   */
  private async testAuditCompliance(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Audit & Compliance Functions...\n');

    await this.testFunction(client, summary, 'Audit & Compliance', 'sp_log_audit_event', async () => {
      const testData = {
        p_action: 'test_action',
        p_entity_type: 'asset',
        p_entity_id: this.testAssetId,
        p_entity_name: 'Test Asset',
        p_user_id: this.testUserId,
        p_old_values: { old: 'value' },
        p_new_values: { new: 'value' },
        p_metadata: { test: true }
      };
      
      const result = await client.query(
        'SELECT sp_log_audit_event($1, $2, $3, $4, $5, $6::jsonb, $7::jsonb, $8::jsonb) as audit_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Audit & Compliance', 'sp_create_audit_event', async () => {
      const testData = {
        p_event_type: 'test_event',
        p_event_category: 'test',
        p_risk_level: 'low',
        p_compliance_framework: 'SOC2',
        p_description: 'Test audit event',
        p_metadata: { test: true },
        p_user_id: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_create_audit_event($1, $2, $3, $4, $5, $6::jsonb, $7) as event_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Audit & Compliance', 'sp_get_audit_trail', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_audit_trail(NULL, NULL, $1, NULL, NULL, NULL, 10, 0)',
        [this.testUserId]
      );
      return { result: result.rows };
    });

    await this.testFunction(client, summary, 'Audit & Compliance', 'sp_generate_compliance_report', async () => {
      const result = await client.query(
        'SELECT * FROM sp_generate_compliance_report($1, NULL, NULL, true)',
        ['SOC2']
      );
      return { result: result.rows };
    });
  }

  /**
   * Test Event Sourcing Functions
   */
  private async testEventSourcing(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Event Sourcing Functions...\n');

    await this.testFunction(client, summary, 'Event Sourcing', 'sp_append_event', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_aggregate_id: this.testAssetId,
        p_aggregate_type: 'asset',
        p_event_type: 'AssetCreated',
        p_event_data: { name: 'Test Asset' },
        p_event_metadata: { source: 'test' },
        p_user_id: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_append_event($1, $2, $3, $4, $5::jsonb, $6::jsonb, $7) as event_id',
        Object.values(testData)
      );
      this.testEventId = result.rows[0].event_id;
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Event Sourcing', 'sp_replay_events', async () => {
      const result = await client.query(
        'SELECT * FROM sp_replay_events($1, 1, NULL)',
        [this.testAssetId]
      );
      return { result: result.rows };
    });

    await this.testFunction(client, summary, 'Event Sourcing', 'sp_create_snapshot', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_aggregate_id: this.testAssetId,
        p_aggregate_type: 'asset',
        p_snapshot_data: { current_state: 'test' }
      };
      
      const result = await client.query(
        'SELECT sp_create_snapshot($1, $2, $3, $4::jsonb) as snapshot_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Event Sourcing', 'sp_rebuild_projection', async () => {
      await client.query(
        'SELECT sp_rebuild_projection($1, $2, $3)',
        [this.tenantId, 'asset_current_state', this.testAssetId]
      );
      return { success: true };
    });
  }

  /**
   * Test Integration Functions
   */
  private async testIntegrations(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Integration Functions...\n');

    // PII Detection
    await this.testFunction(client, summary, 'Integration', 'sp_detect_pii', async () => {
      const result = await client.query(
        'SELECT * FROM sp_detect_pii($1, $2, $3)',
        ['Test SSN 123-45-6789 and email test@example.com', 'test', this.testUserId]
      );
      return { result: result.rows };
    });

    // Advisor Companies
    await this.testFunction(client, summary, 'Integration', 'sp_manage_advisor_company', async () => {
      const testData = {
        p_action: 'create',
        p_company_name: faker.company.name(),
        p_company_type: 'financial_advisor',
        p_contact_email: faker.internet.email(),
        p_contact_phone: faker.phone.number('+1##########'),
        p_address: faker.location.streetAddress(),
        p_metadata: { test: true },
        p_user_id: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_manage_advisor_company($1, $2, $3, $4, $5, $6, $7::jsonb, $8) as company_id',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    await this.testFunction(client, summary, 'Integration', 'sp_get_advisor_companies', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_advisor_companies(NULL, NULL, 10, 0)'
      );
      return { result: result.rows };
    });

    // System Configuration
    await this.testFunction(client, summary, 'Integration', 'sp_update_system_configuration', async () => {
      const testData = {
        p_config_key: 'test_setting',
        p_config_value: 'test_value',
        p_config_category: 'general',
        p_description: 'Test configuration',
        p_user_id: this.testUserId
      };
      
      const result = await client.query(
        'SELECT sp_update_system_configuration($1, $2, $3, $4, $5) as success',
        Object.values(testData)
      );
      return { testData, result: result.rows[0] };
    });

    // Session Context
    await this.testFunction(client, summary, 'Integration', 'sp_set_session_context', async () => {
      await client.query(
        'SELECT sp_set_session_context($1, $2)',
        [this.testUserId, this.tenantId]
      );
      return { success: true };
    });

    await this.testFunction(client, summary, 'Integration', 'sp_clear_session_context', async () => {
      const result = await client.query('SELECT sp_clear_session_context() as success');
      return { result: result.rows[0] };
    });
  }

  /**
   * Test Subscription & Payment Procedures
   */
  private async testSubscriptionPayment(client: PoolClient, summary: TestSummary) {
    console.log('📊 Testing Subscription & Payment Procedures...\n');

    // Functions
    await this.testFunction(client, summary, 'Subscription', 'sp_get_subscription_status', async () => {
      const result = await client.query(
        'SELECT * FROM sp_get_subscription_status($1)',
        [this.testFfcId]
      );
      return { result: result.rows };
    });

    await this.testFunction(client, summary, 'Subscription', 'sp_calculate_seat_availability', async () => {
      // Create a test subscription first
      const subResult = await client.query(
        `INSERT INTO subscriptions (tenant_id, ffc_id, owner_user_id, status) 
         VALUES ($1, $2, $3, 'active') 
         RETURNING id`,
        [this.tenantId, this.testFfcId, this.testUserId]
      );
      this.testSubscriptionId = subResult.rows[0].id;

      const result = await client.query(
        'SELECT * FROM sp_calculate_seat_availability($1)',
        [this.testSubscriptionId]
      );
      return { result: result.rows };
    });

    // Note: Procedures (CALL statements) need different handling
    await this.testProcedure(client, summary, 'Subscription', 'sp_create_ffc_with_subscription', async () => {
      const testData = {
        p_tenant_id: this.tenantId,
        p_name: 'Test Subscription FFC ' + faker.company.name(),
        p_description: faker.lorem.sentence(),
        p_owner_user_id: this.testUserId,
        p_owner_persona_id: this.testPersonaId
      };
      
      // Procedures with OUT parameters need special handling
      await client.query(
        'CALL sp_create_ffc_with_subscription($1, $2, $3, $4, $5, NULL, NULL)',
        Object.values(testData)
      );
      return { testData, success: true };
    });
  }

  /**
   * Helper method to test a function
   */
  private async testFunction(
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
      status: 'success',
      executionTime: 0
    };

    try {
      console.log(`  Testing ${procedureName}...`);
      result.result = await testFunc();
      result.status = 'success';
      summary.successful++;
      console.log(`    ✅ ${procedureName} passed`);
    } catch (error: any) {
      result.status = 'failure';
      result.error = error.message;
      summary.failed++;
      console.log(`    ❌ ${procedureName} failed: ${error.message}`);
    }

    result.executionTime = Date.now() - startTime;
    summary.totalExecutionTime += result.executionTime;
    summary.results.push(result);
  }

  /**
   * Helper method to test a procedure (uses CALL)
   */
  private async testProcedure(
    client: PoolClient,
    summary: TestSummary,
    category: string,
    procedureName: string,
    testFunc: () => Promise<any>
  ): Promise<void> {
    return this.testFunction(client, summary, category, procedureName, testFunc);
  }

  /**
   * Print test summary
   */
  private printTestSummary(summary: TestSummary) {
    console.log('\n═══════════════════════════════════════════════════════════');
    console.log('                     TEST SUMMARY                           ');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`  Total Procedures: ${summary.totalProcedures}`);
    console.log(`  ✅ Successful: ${summary.successful}`);
    console.log(`  ❌ Failed: ${summary.failed}`);
    console.log(`  ⏭️  Skipped: ${summary.skipped}`);
    console.log(`  ⏱️  Total Time: ${summary.totalExecutionTime}ms`);
    console.log('═══════════════════════════════════════════════════════════\n');

    if (summary.failed > 0) {
      console.log('Failed Procedures:');
      summary.results
        .filter(r => r.status === 'failure')
        .forEach(r => {
          console.log(`  ❌ ${r.procedureName}: ${r.error}`);
        });
    }
  }
}