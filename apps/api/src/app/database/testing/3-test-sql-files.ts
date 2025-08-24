/**
 * Test 3: Test All SQL Files
 * Tests all converted SQL query files in the 5_SQL_files directory
 */

import { Client } from 'pg';
import chalk from 'chalk';
import fs from 'fs';
import path from 'path';
import { faker } from '@faker-js/faker';

const DB_CONFIG = {
  host: 'localhost',
  port: 5432,
  database: 'fwd_db',
  user: 'postgres',
  password: 'FGt!3reGTdt5BG!'
};

const SQL_FILES_DIR = 'C:\\Users\\bob\\github-thseitz\\fwd-inh\\docs\\requirements\\DB\\sql scripts\\5_SQL_files';

interface TestResult {
  file: string;
  queryType: 'SELECT' | 'INSERT' | 'UPDATE' | 'DELETE' | 'CALL' | 'OTHER';
  status: 'passed' | 'failed' | 'skipped';
  error?: string;
  executionTime?: number;
  rowCount?: number;
}

// Files to skip (documentation, test files, etc.)
const SKIP_FILES = [
  'ANALYSIS_23_REMAINING.md',
  'COMPLETE_70_PROCEDURE_MAPPING.md',
  'STORED_PROC_PGTYPED_GUIDE.md',
  'converted.txt',
  'test_converted_queries.ts',
  'test_new_queries.ts',
  'test_specific_queries.ts'
];

// Categorize SQL files by their operation type
function categorizeQuery(content: string): TestResult['queryType'] {
  const upperContent = content.toUpperCase();
  if (upperContent.includes('SELECT')) return 'SELECT';
  if (upperContent.includes('INSERT INTO')) return 'INSERT';
  if (upperContent.includes('UPDATE')) return 'UPDATE';
  if (upperContent.includes('DELETE')) return 'DELETE';
  if (upperContent.includes('CALL')) return 'CALL';
  return 'OTHER';
}

// Generate appropriate test parameters based on file name and content
function generateTestParams(fileName: string, content: string, testData: any): any[] {
  const params: any[] = [];
  
  // Count parameter placeholders in actual SQL (not comments)
  const sqlOnlyLines = content.split('\n')
    .filter(line => !line.trim().startsWith('--'))
    .join('\n');
  const paramMatches = sqlOnlyLines.match(/\$\d+/g);
  if (!paramMatches) return params;
  
  const paramCount = Math.max(...paramMatches.map(p => parseInt(p.substring(1))));
  
  // Generate parameters based on file name patterns
  for (let i = 1; i <= paramCount; i++) {
    // Check for enum types first
    if (content.includes(`$${i}::persona_type`)) {
      params.push('individual');
    } else if (content.includes(`$${i}::ownership_type_enum`)) {
      params.push('owner');
    } else if (content.includes(`$${i}::asset_type_enum`)) {
      params.push('real_estate');
    } else if (content.includes(`$${i}::account_type_enum`)) {
      params.push('checking');
    } else if (content.includes(`$${i}::subscription_status_enum`)) {
      params.push('active');
    } else if (content.includes(`$${i}::user_status_enum`)) {
      params.push('active');
    } else if (content.includes(`$${i}::status_enum`)) {
      params.push('active');
    } else if (content.includes(`$${i}::invitation_status_enum`)) {
      params.push('sent');
    } else if (content.includes(`$${i}::ffc_role_enum`)) {
      params.push('owner');
    } else if (content.includes(`$${i}::sync_status_enum`)) {
      params.push('pending');
    } else if (content.includes(`$${i}::integration_status_enum`)) {
      params.push('connected');
    } else if (content.includes(`$${i}::audit_action_enum`)) {
      params.push('create');
    } else if (content.includes(`$${i}::audit_entity_type_enum`)) {
      params.push('user');
    } else if (content.includes(`$${i}::transaction_type_enum`)) {
      params.push('charge');
    } else if (content.includes(`$${i}::seat_type_enum`)) {
      params.push('pro');
    } else if (content.includes(`$${i}::language_code_enum`)) {
      params.push('en');
    } else if (content.includes(`$${i}::email_usage_type_enum`)) {
      params.push('primary');
    } else if (content.includes(`$${i}::phone_usage_type_enum`)) {
      params.push('primary');
    } else if (content.includes(`$${i}::hei_valuation_method_enum`)) {
      params.push('avm');
    } else if (content.includes(`$${i}::hei_funding_method_enum`)) {
      params.push('ach');
    } else if (content.includes(`$${i}::hei_status_enum`)) {
      params.push('active');
    } else if (content.includes(`$${i}::UUID[]`)) {
      // Check UUID arrays before simple UUID - moved up
      // Array of UUIDs - optional parameters can be null
      if (fileName.includes('real_estate') || fileName.includes('sync')) {
        params.push(null);  // Optional array parameter
      } else {
        params.push([faker.string.uuid(), faker.string.uuid()]);
      }
    } else if (content.includes(`$${i}::UUID`)) {
      // Use existing IDs based on parameter position and context
      // Check parameter comments for better context
      const paramLines = content.split('\n');
      let paramName = '';
      for (const line of paramLines) {
        // Match lines like: --   $1: p_owner_user_id UUID - Description
        const match = line.match(new RegExp(`\\$${i}:\\s*(p_)?([\\w_]+)\\s+UUID`));
        if (match) {
          paramName = match[2].toLowerCase();
          break;
        }
      }
      
      
      if (paramName.includes('ffc') && paramName.includes('id')) {
        params.push(testData.ffcId);
      } else if (paramName.includes('persona') && paramName.includes('id')) {
        params.push(testData.personaId);
      } else if (paramName.includes('owner') && paramName.includes('persona')) {
        params.push(testData.personaId);
      } else if (paramName.includes('owner') && paramName.includes('user')) {
        params.push(testData.userId);
      } else if (paramName.includes('user') || paramName.includes('created_by') || paramName.includes('updated_by') || paramName.includes('added_by')) {
        params.push(testData.userId);
      } else if (paramName.includes('asset') && paramName.includes('id')) {
        params.push(testData.assetId);
      } else if (paramName.includes('subscription') && paramName.includes('id')) {
        params.push(testData.subscriptionId);
      } else if (paramName.includes('email') && paramName.includes('id')) {
        params.push(testData.emailId);
      } else if (paramName.includes('phone') && paramName.includes('id')) {
        params.push(testData.phoneId);
      } else if (paramName.includes('plan')) {
        params.push(testData.planId);
      } else if (paramName.includes('payment') && paramName.includes('method')) {
        params.push(testData.paymentMethodId);
      } else if (paramName.includes('quiltt') && paramName.includes('integration')) {
        params.push(testData.quilttIntegrationId);
      } else if (paramName.includes('hei') && paramName.includes('asset')) {
        params.push(testData.heiAssetId);
      } else if (paramName.includes('property') && paramName.includes('asset')) {
        params.push(testData.propertyAssetId);
      } else if (paramName.includes('hei') && paramName.includes('id')) {
        params.push(testData.heiDetailId);
      } else {
        // Default to userId for unknown UUIDs
        params.push(testData.userId);
      }
    } else if (content.includes(`$${i}::INTEGER`)) {
      // Always use actual tenant_id for tenant parameters
      if (fileName.includes('tenant') || content.includes('p_tenant_id') || content.includes('$1::INTEGER')) {
        params.push(testData.tenantId || 1);
      } else {
        params.push(faker.number.int({ min: 1, max: 100 }));
      }
    } else if (content.includes(`$${i}::TEXT[]`)) {
      // Check arrays before simple TEXT type
      // Array of text values - optional parameters can be null
      if (fileName.includes('builder') || fileName.includes('quiltt')) {
        params.push(null);  // Optional array parameter
      } else {
        params.push([faker.lorem.word(), faker.lorem.word()]);
      }
    } else if (content.includes(`$${i}::VARCHAR`)) {
      // Check parameter name from comments
      const paramLines = content.split('\n');
      let paramName = '';
      for (const line of paramLines) {
        // Match lines like: --   $5: p_phone VARCHAR(20) - Description
        const match = line.match(new RegExp(`\\$${i}:\\s*(p_)?([\\w_]+)\\s+VARCHAR`));
        if (match) {
          paramName = match[2].toLowerCase();
          break;
        }
      }
      
      // Check if it's a phone number or country code based on parameter name
      if (paramName.includes('country_code') || (fileName.includes('create_user') && i === 10)) {
        params.push('+1');
      } else if (paramName.includes('phone')) {
        // Check if we're dealing with create_phone_if_not_exists which needs just the number
        if (fileName.includes('create_phone')) {
          params.push(faker.string.numeric(10));  // Just the number without country code
        } else if (fileName.includes('create_user') && i === 5) {
          params.push('+1' + faker.string.numeric(10));  // Full phone with country code
        } else {
          params.push('+1' + faker.string.numeric(10));  // Full phone with country code
        }
      } else if (fileName.includes('email') || paramName.includes('email')) {
        params.push(faker.internet.email());
      } else if (paramName.includes('name')) {
        params.push(faker.person.fullName());
      } else if (fileName.includes('builder') && paramName.includes('space_id')) {
        params.push('test_space');
      } else if (content.includes('p_account_last_four')) {
        params.push(faker.string.numeric(4));  // Exactly 4 digits for account constraint
      } else {
        params.push(faker.lorem.word());
      }
    } else if (content.includes(`$${i}::TEXT`)) {
      if (fileName.includes('email') || content.includes('p_email')) {
        params.push(faker.internet.email());
      } else if (fileName.includes('name')) {
        params.push(faker.person.fullName());
      } else if (fileName.includes('builder') && content.includes('p_space_id')) {
        params.push('test_space');  // Use known Builder.io space ID
      } else if (fileName.includes('quiltt')) {
        // Handle Quiltt-specific text parameters
        if (content.includes('p_session_token')) {
          params.push('test_session_' + faker.string.alphanumeric(32));
        } else if (content.includes('p_quiltt_user_id')) {
          params.push(testData.personaId || faker.string.uuid());
        } else if (content.includes('p_quiltt_connection_id')) {
          params.push('conn_' + faker.string.alphanumeric(16));
        } else if (content.includes('p_quiltt_account_id')) {
          params.push('acct_' + faker.string.alphanumeric(16));
        } else if (content.includes('p_access_token')) {
          params.push('access_' + faker.string.alphanumeric(40));
        } else if (content.includes('p_refresh_token')) {
          params.push('refresh_' + faker.string.alphanumeric(40));
        } else {
          params.push(faker.lorem.word());
        }
      } else if (fileName.includes('ui_mask_by_table_name')) {
        // UI collection mask query by table name
        params.push('assets');  // Use known table name
      } else if (fileName.includes('ui_mask_by_entity_code')) {
        // UI collection mask query by entity code
        params.push('ASSETS');  // Use known entity code
      } else if (fileName.includes('lookup_hei') && content.includes('identifier')) {
        // HEI lookup identifier - can be loan number, external ID, or address
        const identifiers = [
          'HEI-' + faker.string.alphanumeric(8),
          faker.location.streetAddress(),
          'APP-' + faker.string.alphanumeric(6)
        ];
        params.push(faker.helpers.arrayElement(identifiers));
      } else if (fileName.includes('ingest_hei') && (content.includes('source_system') || i === 5)) {
        params.push('test_hei_system');
      } else if (fileName.includes('ingest_hei') && (content.includes('source_application_id') || i === 6)) {
        params.push('APP-' + faker.string.alphanumeric(8));
      } else if (fileName.includes('update_hei') && content.includes('notes')) {
        params.push('Status updated via test');
      } else if (fileName.includes('seat_invitation')) {
        // For seat invitation, we need valid IDs that exist in the database
        if (i === 1) {
          // Use the created invitation ID
          params.push(testData.invitationId);
        } else if (i === 2) {
          // Use subscription ID from database
          params.push(testData.subscriptionId);
        } else if (i === 3) {
          // Use persona ID from database  
          params.push(testData.personaId);
        } else {
          params.push('pro'); // seat_type
        }
      } else {
        params.push(faker.lorem.word());
      }
    } else if (content.includes(`$${i}::BOOLEAN`)) {
      params.push(true);
    } else if (content.includes(`$${i}::DATE`) || content.includes(`$${i}::TIMESTAMP`) || content.includes(`$${i}::TIMESTAMPTZ`)) {
      // Handle date/timestamp parameters
      if (fileName.includes('quiltt') && content.includes('p_expires_at')) {
        // Quiltt session expires in 1 hour
        const expiresAt = new Date();
        expiresAt.setHours(expiresAt.getHours() + 1);
        params.push(expiresAt);
      } else {
        params.push(new Date());
      }
    } else if (content.includes(`$${i}::DECIMAL(5,2)`)) {
      // For ownership percentage - use smaller values for transfers
      if (fileName.includes('transfer')) {
        params.push(faker.number.float({ min: 1, max: 10, fractionDigits: 2 }));
      } else {
        params.push(faker.number.float({ min: 0, max: 100, fractionDigits: 2 }));
      }
    } else if (content.includes(`$${i}::DECIMAL`) || content.includes(`$${i}::NUMERIC`)) {
      // Check for specific decimal precision
      if (content.includes(`$${i}::NUMERIC(10,2)`)) {
        // For amounts - max 99999999.99 (10 digits, 2 decimal)
        params.push(faker.number.float({ min: 0, max: 9999.99, fractionDigits: 2 }));
      } else {
        params.push(faker.number.float({ min: 0, max: 10000, fractionDigits: 2 }));
      }
    } else if (content.includes(`$${i}::ledger_account_type_enum`)) {
      params.push('revenue');
    } else if (content.includes(`$${i}::JSONB`) || content.includes(`$${i}::JSON`)) {
      // Check if it's for PII types which should be an array
      if (fileName.includes('pii') && content.includes('p_pii_types')) {
        params.push(JSON.stringify(['email', 'phone', 'ssn']));
      } else if (fileName.includes('ingest_hei')) {
        // HEI ingestion JSONB parameters - check position first
        if (i === 2) {
          // $2: property_data 
          params.push(JSON.stringify({
            address_line1: faker.location.streetAddress(),
            city: faker.location.city(),
            state: faker.location.state({ abbreviated: true }),
            postal_code: faker.location.zipCode(),
            parcel_number: 'APN' + faker.string.alphanumeric(8)
          }));
        } else if (i === 3) {
          // $3: hei_data
          params.push(JSON.stringify({
            amount_funded: faker.number.float({ min: 50000, max: 500000, fractionDigits: 2 }),
            equity_share_pct: faker.number.float({ min: 10, max: 30, fractionDigits: 2 }),
            effective_date: '2024-01-15',
            valuation_amount: faker.number.float({ min: 300000, max: 800000, fractionDigits: 2 }),
            valuation_method: 'avm',
            valuation_effective_date: '2024-01-10',
            maturity_terms: {
              term_years: faker.number.int({ min: 5, max: 15 }),
              buyout_options: ['full_buyout', 'partial_buyout']
            },
            first_mortgage_balance: faker.number.float({ min: 200000, max: 400000, fractionDigits: 2 }),
            junior_liens_balance: faker.number.float({ min: 0, max: 50000, fractionDigits: 2 }),
            cltv_at_close: faker.number.float({ min: 70, max: 90, fractionDigits: 2 })
          }));
        } else if (i === 4) {
          // $4: owner_data
          params.push(JSON.stringify({
            legal_name: faker.person.fullName(),
            email: faker.internet.email()
          }));
        } else {
          params.push(JSON.stringify({ test: true, data: faker.lorem.word() }));
        }
      } else {
        params.push(JSON.stringify({ test: true, data: faker.lorem.word() }));
      }
    } else {
      // Default to string
      params.push(faker.lorem.word());
    }
  }
  
  return params;
}

async function testSqlFiles() {
  const client = new Client(DB_CONFIG);
  const results: TestResult[] = [];
  
  try {
    console.log(chalk.blue('📁 Test 3: Testing All SQL Files'));
    console.log(chalk.gray('================================'));
    
    await client.connect();
    console.log(chalk.green('✓ Connected to database'));
    
    // Get test data IDs for parameter generation
    const testData: any = {};
    
    const tenantResult = await client.query('SELECT id FROM tenants LIMIT 1');
    testData.tenantId = tenantResult.rows[0]?.id || 1;
    
    // Get user with Quiltt integration if exists, otherwise first user
    const userResult = await client.query(`
      SELECT u.id 
      FROM users u
      LEFT JOIN personas p ON p.user_id = u.id
      LEFT JOIN quiltt_integrations qi ON qi.persona_id = p.id AND qi.is_active = true
      WHERE u.tenant_id = $1
      ORDER BY qi.id IS NOT NULL DESC, u.created_at
      LIMIT 1
    `, [testData.tenantId]);
    testData.userId = userResult.rows[0]?.id;
    
    const personaResult = await client.query('SELECT id FROM personas LIMIT 1');
    testData.personaId = personaResult.rows[0]?.id;
    
    const ffcResult = await client.query('SELECT id FROM fwd_family_circles LIMIT 1');
    testData.ffcId = ffcResult.rows[0]?.id;
    
    const assetResult = await client.query('SELECT id FROM assets LIMIT 1');
    testData.assetId = assetResult.rows[0]?.id;
    
    const subResult = await client.query('SELECT id FROM subscriptions LIMIT 1');
    testData.subscriptionId = subResult.rows[0]?.id;
    
    // Get email and phone IDs
    const emailResult = await client.query('SELECT id FROM email_address LIMIT 1');
    testData.emailId = emailResult.rows[0]?.id;
    
    const phoneResult = await client.query('SELECT id FROM phone_number LIMIT 1');
    testData.phoneId = phoneResult.rows[0]?.id;
    
    // Get subscription plan ID
    const planResult = await client.query('SELECT id FROM plans LIMIT 1');
    testData.planId = planResult.rows[0]?.id;
    
    // Get payment method ID
    const pmResult = await client.query('SELECT id FROM payment_methods LIMIT 1');
    testData.paymentMethodId = pmResult.rows[0]?.id;
    
    // Get quiltt integration ID
    const qiResult = await client.query('SELECT id FROM quiltt_integrations LIMIT 1');
    testData.quilttIntegrationId = qiResult.rows[0]?.id;
    
    // Get HEI-specific test data
    const heiAssetResult = await client.query('SELECT id FROM assets WHERE category_id = (SELECT id FROM asset_categories WHERE code = \'hei\') LIMIT 1');
    testData.heiAssetId = heiAssetResult.rows[0]?.id;
    
    const realEstateAssetResult = await client.query('SELECT id FROM assets WHERE category_id = (SELECT id FROM asset_categories WHERE code = \'real_estate\') LIMIT 1');
    testData.propertyAssetId = realEstateAssetResult.rows[0]?.id;
    
    const heiDetailResult = await client.query('SELECT id FROM hei_assets LIMIT 1');
    testData.heiDetailId = heiDetailResult.rows[0]?.id;
    
    // Create test invitation for seat invitation tests
    const invitationResult = await client.query(`
      INSERT INTO ffc_invitations (
        tenant_id, ffc_id, inviter_user_id, invitee_email_id, invitee_phone_id, invitee_name,
        proposed_role, status, sent_at, approved_at, approved_by_user_id,
        seat_type, subscription_id, created_by, updated_by
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), $3, $9, $10, $3, $3
      ) 
      ON CONFLICT DO NOTHING
      RETURNING id
    `, [
      testData.tenantId, testData.ffcId, testData.userId, testData.emailId, testData.phoneId,
      'Test Invitee', 'beneficiary', 'approved', 'pro', testData.subscriptionId
    ]);
    testData.invitationId = invitationResult.rows[0]?.id || faker.string.uuid();
    
    // Read all SQL files
    const files = fs.readdirSync(SQL_FILES_DIR)
      .filter(f => f.endsWith('.sql'))
      .filter(f => !SKIP_FILES.includes(f))
      .sort();
    
    console.log(chalk.blue(`\nFound ${files.length} SQL files to test\n`));
    
    // Test each file
    let testCount = 0;
    for (const file of files) {
      testCount++;
      const filePath = path.join(SQL_FILES_DIR, file);
      const content = fs.readFileSync(filePath, 'utf-8');
      
      // Skip empty files
      if (!content.trim()) {
        results.push({
          file,
          queryType: 'OTHER',
          status: 'skipped',
          error: 'Empty file'
        });
        console.log(chalk.yellow(`⊘ ${file} - Empty file`));
        continue;
      }
      
      // Extract the actual SQL query (skip comments)
      const sqlLines = content.split('\n')
        .filter(line => !line.trim().startsWith('--'))
        .join('\n')
        .trim();
      
      if (!sqlLines) {
        results.push({
          file,
          queryType: 'OTHER',
          status: 'skipped',
          error: 'No SQL content'
        });
        console.log(chalk.yellow(`⊘ ${file} - No SQL content`));
        continue;
      }
      
      const queryType = categorizeQuery(sqlLines);
      const startTime = Date.now();
      
      try {
        // Begin transaction for safety
        await client.query('BEGIN');
        
        // Set session context for tenant and user
        await client.query(`SET LOCAL app.current_tenant_id = '${testData.tenantId}'`);
        await client.query(`SET LOCAL app.current_user_id = '${testData.userId}'`);
        
        // Generate test parameters (use full content with comments for parameter detection)
        const params = generateTestParams(file, content, testData);
        
        // Special handling for call_ wrapper files
        if (file.startsWith('call_sp_')) {
          // These are procedure calls, test them properly
          if (queryType === 'CALL') {
            console.log(chalk.gray(`${testCount}/${files.length} Testing ${file} (PROCEDURE)...`));
            // Execute the procedure call
            const result = await client.query(sqlLines, params);
            await client.query('COMMIT');
            
            const executionTime = Date.now() - startTime;
            results.push({
              file,
              queryType,
              status: 'passed',
              executionTime,
              rowCount: result.rowCount
            });
            
            console.log(chalk.green(`✓ ${file} (${executionTime}ms, procedure executed)`));
            continue;
          }
        }
        
        // Execute the query
        console.log(chalk.gray(`${testCount}/${files.length} Testing ${file} (${queryType})...`));
        const result = await client.query(sqlLines, params);
        
        // Rollback to avoid side effects
        await client.query('ROLLBACK');
        
        const executionTime = Date.now() - startTime;
        
        results.push({
          file,
          queryType,
          status: 'passed',
          executionTime,
          rowCount: result.rowCount
        });
        
        console.log(chalk.green(`✓ ${file} (${executionTime}ms, ${result.rowCount || 0} rows)`));
        
      } catch (error) {
        await client.query('ROLLBACK');
        const executionTime = Date.now() - startTime;
        const errorMessage = error instanceof Error ? error.message : String(error);
        
        // All errors are failures - we want 100% pass rate
        results.push({
          file,
          queryType,
          status: 'failed',
          error: errorMessage,
          executionTime
        });
        
        console.log(chalk.red(`✗ ${file} - ${errorMessage.split('\n')[0]}`));
      }
    }
    
    // Summary
    console.log(chalk.gray('\n================================'));
    const passed = results.filter(r => r.status === 'passed').length;
    const failed = results.filter(r => r.status === 'failed').length;
    const skipped = results.filter(r => r.status === 'skipped').length;
    
    // Group by query type
    const byType = results.reduce((acc, r) => {
      acc[r.queryType] = (acc[r.queryType] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
    
    console.log(chalk.blue('📊 Test Summary:'));
    console.log(chalk.green(`  ✓ Passed: ${passed}/${results.length}`));
    if (failed > 0) {
      console.log(chalk.red(`  ✗ Failed: ${failed}/${results.length}`));
    }
    if (skipped > 0) {
      console.log(chalk.yellow(`  ⊘ Skipped: ${skipped}/${results.length}`));
    }
    
    console.log(chalk.blue('\n📈 By Query Type:'));
    Object.entries(byType).forEach(([type, count]) => {
      console.log(chalk.gray(`  ${type}: ${count}`));
    });
    
    // Save results
    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const resultsDir = path.join(__dirname, 'test-results');
    if (!fs.existsSync(resultsDir)) {
      fs.mkdirSync(resultsDir, { recursive: true });
    }
    
    const resultsFile = path.join(resultsDir, `sql-files-${timestamp}.json`);
    fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
    console.log(chalk.gray(`\nResults saved to: ${resultsFile}`));
    
    // Show failed queries for debugging
    if (failed > 0) {
      console.log(chalk.red('\n❌ Failed Queries:'));
      results.filter(r => r.status === 'failed').forEach(r => {
        console.log(chalk.red(`  - ${r.file}: ${r.error?.split('\n')[0]}`));
      });
    }
    
    // Return results
    return { passed, total: results.length };
    
  } catch (error) {
    console.error(chalk.red('❌ Test execution error:'), error);
    throw error;
  } finally {
    await client.end();
  }
}

// Run if called directly
if (require.main === module) {
  testSqlFiles()
    .then(results => process.exit(results.passed === results.total ? 0 : 1))
    .catch(() => process.exit(1));
}

export { testSqlFiles };