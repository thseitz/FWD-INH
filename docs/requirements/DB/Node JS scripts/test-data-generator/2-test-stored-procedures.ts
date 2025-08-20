/**
 * Test 2: Test 11 Retained Stored Procedures
 * Tests the 11 complex stored procedures that remain in the database
 */

import { Client } from 'pg';
import chalk from 'chalk';
import { faker } from '@faker-js/faker';
import fs from 'fs';
import path from 'path';

const DB_CONFIG = {
  host: 'localhost',
  port: 15432,
  database: 'fwd_db',
  user: 'postgres',
  password: 'FGt!3reGTdt5BG!'
};

interface TestResult {
  procedure: string;
  status: 'passed' | 'failed' | 'skipped';
  error?: string;
  executionTime?: number;
  result?: any;
}

async function testStoredProcedures() {
  const client = new Client(DB_CONFIG);
  const results: TestResult[] = [];
  
  try {
    console.log(chalk.blue('🧪 Test 2: Testing 11 Retained Stored Procedures'));
    console.log(chalk.gray('================================================'));
    
    await client.connect();
    console.log(chalk.green('✓ Connected to database'));
    
    // Get test data IDs
    const tenantResult = await client.query('SELECT id FROM tenants LIMIT 1');
    // Get user with Quiltt integration if exists
    const userResult = await client.query(`
      SELECT u.id 
      FROM users u
      LEFT JOIN quiltt_integrations qi ON qi.user_id = u.id AND qi.is_active = true
      WHERE u.tenant_id = $1
      ORDER BY qi.id IS NOT NULL DESC, u.created_at
      LIMIT 1
    `, [tenantResult.rows[0]?.id]);
    const personaResult = await client.query('SELECT id FROM personas LIMIT 1');
    const ffcResult = await client.query('SELECT id FROM fwd_family_circles LIMIT 1');
    
    if (!tenantResult.rows[0]) {
      console.log(chalk.red('❌ No test data found. Run populate-database first.'));
      return;
    }
    
    const tenantId = tenantResult.rows[0].id;
    const userId = userResult.rows[0]?.id;
    const personaId = personaResult.rows[0]?.id;
    const ffcId = ffcResult.rows[0]?.id;
    
    // List of 11 procedures to test (excluding update_updated_at_column as it's a trigger)
    const procedures = [
      {
        name: 'sp_create_user_from_cognito',
        test: async () => {
          // Start transaction to use SET LOCAL
          await client.query('BEGIN');
          await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
          
          const result = await client.query(
            'SELECT * FROM sp_create_user_from_cognito($1, $2, $3, $4, $5, $6, $7)',
            [
              tenantId,
              faker.string.uuid(),
              faker.internet.userName(),
              faker.internet.email(),
              '+1' + faker.string.numeric(10),  // Format: +1XXXXXXXXXX
              faker.person.firstName(),
              faker.person.lastName()
            ]
          );
          await client.query('COMMIT');
          return result.rows[0];
        }
      },
      {
        name: 'sp_create_asset',
        test: async () => {
          // Start transaction for session context
          await client.query('BEGIN');
          await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
          await client.query(`SET LOCAL app.current_user_id = '${userId}'`);
          
          const result = await client.query(
            'SELECT * FROM sp_create_asset($1, $2, $3, $4, $5, $6, $7)',
            [
              tenantId,                                     // p_tenant_id
              personaId,                                    // p_owner_persona_id
              'real_estate',                                // p_asset_type
              'Test Property ' + faker.string.alphanumeric(5), // p_name
              'Test asset created by procedure test',      // p_description
              100.00,                                       // p_ownership_percentage
              userId                                        // p_created_by_user_id
            ]
          );
          await client.query('COMMIT');
          return result.rows[0];
        }
      },
      {
        name: 'sp_rebuild_projection',
        test: async () => {
          // Start transaction for session context
          await client.query('BEGIN');
          await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
          await client.query(`SET LOCAL app.current_user_id = '${userId}'`);
          
          // First create an event to rebuild from
          const aggregateId = faker.string.uuid();
          await client.query(`
            INSERT INTO event_store (tenant_id, aggregate_id, aggregate_type, event_type, event_version, event_data, created_by, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
          `, [tenantId, aggregateId, 'test_aggregate', 'test_event', 1, JSON.stringify({test: true}), userId]);
          
          await client.query(
            'SELECT sp_rebuild_projection($1, $2, $3)',
            [tenantId, 'test_projection', aggregateId]
          );
          await client.query('COMMIT');
          return { success: true, aggregateId };
        }
      },
      {
        name: 'sp_sync_quiltt_data',
        test: async () => {
          // Start transaction for session context
          await client.query('BEGIN');
          await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
          await client.query(`SET LOCAL app.current_user_id = '${userId}'`);
          
          const result = await client.query(
            'SELECT * FROM sp_sync_quiltt_data($1, $2, $3)',
            [userId, 'full', JSON.stringify(['accounts', 'transactions'])]
          );
          await client.query('COMMIT');
          return result.rows[0];
        }
      },
      {
        name: 'sp_sync_real_estate_data',
        test: async () => {
          // First check if we need to create a real estate property
          const propCheck = await client.query('SELECT id FROM real_estate LIMIT 1');
          
          if (propCheck.rows.length === 0) {
            // Get or create a real estate category
            const catResult = await client.query(`
              INSERT INTO asset_categories (name, code, description, is_active, created_at, updated_at)
              VALUES ($1, $2, $3, $4, NOW(), NOW())
              ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
              RETURNING id
            `, ['real_estate', 'RE', 'Real Estate Properties', true]);
            
            // Create an asset with category
            const assetResult = await client.query(`
              INSERT INTO assets (tenant_id, category_id, name, description, status, created_at, updated_at, created_by)
              VALUES ($1, $2, $3, $4, $5, NOW(), NOW(), $6)
              RETURNING id
            `, [tenantId, catResult.rows[0].id, 'Test Property for Sync', 'Property for testing sync', 'active', userId]);
            
            // Create an address
            const addressResult = await client.query(`
              INSERT INTO address (tenant_id, address_line_1, city, state_province, postal_code, country, address_type, is_primary, status, created_at, updated_at)
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())
              RETURNING id
            `, [tenantId, '456 Test Ave', 'Test City', 'CA', '90211', 'US', 'property', true, 'active']);
            
            // Create the real estate property
            await client.query(`
              INSERT INTO real_estate (
                asset_id, property_type, property_address_id, ownership_type, property_use,
                parcel_number, lot_size_acres, building_size_sqft, bedrooms, bathrooms, year_built,
                created_at, updated_at
              )
              VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), NOW())
            `, [assetResult.rows[0].id, 'single_family', addressResult.rows[0].id, 'sole_ownership', 
                'primary_residence', 'TEST-SYNC-123', 0.5, 2500, 4, 3, 2020]);
          }
          
          // Get the real estate property we just created
          const reResult = await client.query('SELECT id FROM real_estate LIMIT 1');
          
          if (reResult.rows.length > 0) {
            // Pass the specific property ID to sync
            const result = await client.query(
              'SELECT * FROM sp_sync_real_estate_data($1, $2, $3, $4)',
              ['zillow', [reResult.rows[0].id], false, userId]
            );
            return result.rows;
          } else {
            // No properties, just return empty
            return [];
          }
        }
      },
      {
        name: 'sp_refresh_builder_content',
        test: async () => {
          const result = await client.query(
            'SELECT * FROM sp_refresh_builder_content($1, $2, $3)',
            ['test_space', 'page', null]  // Use the actual space_id we created
          );
          return result.rows;
        }
      },
      {
        name: 'sp_create_ffc_with_subscription',
        test: async () => {
          // Start transaction for session context
          await client.query('BEGIN');
          await client.query(`SET LOCAL app.current_tenant_id = '${tenantId}'`);
          await client.query(`SET LOCAL app.current_user_id = '${userId}'`);
          
          await client.query(
            'CALL sp_create_ffc_with_subscription($1, $2, $3, $4, $5, NULL, NULL)',
            [
              tenantId,
              'Test FFC ' + faker.string.alphanumeric(5),
              'Created by test procedure',
              userId,
              personaId
            ]
          );
          await client.query('COMMIT');
          return { success: true };
        }
      },
      {
        name: 'sp_process_seat_invitation',
        test: async () => {
          // First create an email and phone for the invitee
          const emailResult = await client.query(`
            INSERT INTO email_address (tenant_id, email_address, is_verified, status, created_at, updated_at)
            VALUES ($1, $2, $3, $4, NOW(), NOW())
            RETURNING id
          `, [tenantId, faker.internet.email(), false, 'active']);
          
          const phoneResult = await client.query(`
            INSERT INTO phone_number (tenant_id, country_code, phone_number, is_verified, created_at, updated_at)
            VALUES ($1, $2, $3, $4, NOW(), NOW())
            RETURNING id
          `, [tenantId, '+1', '5559876543', false]);
          
          // Now create an invitation with normalized email/phone references
          const inviteResult = await client.query(`
            INSERT INTO ffc_invitations (
              tenant_id, ffc_id, inviter_user_id, invitee_email_id, invitee_phone_id, 
              invitee_name, proposed_role, status, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
            RETURNING id
          `, [tenantId, ffcId, userId, emailResult.rows[0].id, phoneResult.rows[0].id, 
              faker.person.fullName(), 'beneficiary', 'approved']);  // Set to approved for processing
          
          const subResult = await client.query(
            'SELECT id FROM subscriptions WHERE ffc_id = $1 LIMIT 1',
            [ffcId]
          );
          
          if (subResult.rows[0]) {
            await client.query(
              'CALL sp_process_seat_invitation($1, $2, $3, $4)',
              [inviteResult.rows[0].id, subResult.rows[0].id, personaId, 'pro']
            );
          }
          return { success: true, invitationId: inviteResult.rows[0].id };
        }
      },
      {
        name: 'sp_purchase_service',
        test: async () => {
          // First create a payment method with required Stripe fields
          const pmResult = await client.query(`
            INSERT INTO payment_methods (
              tenant_id, user_id, stripe_payment_method_id, stripe_customer_id,
              payment_type, is_default, status, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
            RETURNING id
          `, [tenantId, userId, 'pm_test_' + faker.string.alphanumeric(10), 
              'cus_test_' + faker.string.alphanumeric(10), 'card', true, 'active']);
          
          await client.query(
            'CALL sp_purchase_service($1, $2, $3, $4, $5, $6)',
            [tenantId, 'premium_report', 9999, 'USD', userId, pmResult.rows[0].id]
          );
          return { success: true };
        }
      },
      {
        name: 'sp_process_stripe_webhook',
        test: async () => {
          const eventId = 'evt_test_' + faker.string.alphanumeric(10);
          await client.query(
            'CALL sp_process_stripe_webhook($1, $2, $3)',
            [
              eventId,
              'payment_intent.succeeded',
              JSON.stringify({
                id: 'pi_test_' + faker.string.alphanumeric(10),
                amount: 10000,
                currency: 'usd'
              })
            ]
          );
          return { success: true, eventId };
        }
      },
      {
        name: 'update_updated_at_column (trigger)',
        test: async () => {
          // Test the trigger by updating a record
          const before = await client.query(
            'SELECT updated_at FROM users WHERE id = $1',
            [userId]
          );
          
          await new Promise(resolve => setTimeout(resolve, 10)); // Small delay
          
          await client.query(
            'UPDATE users SET first_name = first_name WHERE id = $1',
            [userId]
          );
          
          const after = await client.query(
            'SELECT updated_at FROM users WHERE id = $1',
            [userId]
          );
          
          const triggerWorked = after.rows[0].updated_at > before.rows[0].updated_at;
          return { 
            success: triggerWorked,
            before: before.rows[0].updated_at,
            after: after.rows[0].updated_at
          };
        }
      }
    ];
    
    // Run tests
    console.log(chalk.blue('\nRunning tests...\n'));
    
    for (const proc of procedures) {
      const startTime = Date.now();
      
      try {
        console.log(chalk.gray(`Testing ${proc.name}...`));
        const result = await proc.test();
        const executionTime = Date.now() - startTime;
        
        results.push({
          procedure: proc.name,
          status: 'passed',
          executionTime,
          result
        });
        
        console.log(chalk.green(`✓ ${proc.name} (${executionTime}ms)`));
      } catch (error) {
        const executionTime = Date.now() - startTime;
        const errorMessage = error instanceof Error ? error.message : String(error);
        
        // Rollback any failed transaction
        try {
          await client.query('ROLLBACK');
        } catch (rollbackError) {
          // Ignore rollback errors
        }
        
        results.push({
          procedure: proc.name,
          status: 'failed',
          error: errorMessage,
          executionTime
        });
        
        console.log(chalk.red(`✗ ${proc.name} - ${errorMessage}`));
      }
    }
    
    // Summary
    console.log(chalk.gray('\n================================================'));
    const passed = results.filter(r => r.status === 'passed').length;
    const failed = results.filter(r => r.status === 'failed').length;
    
    console.log(chalk.blue('📊 Test Summary:'));
    console.log(chalk.green(`  ✓ Passed: ${passed}/${results.length}`));
    if (failed > 0) {
      console.log(chalk.red(`  ✗ Failed: ${failed}/${results.length}`));
    }
    
    // Save results
    const timestamp = new Date().toISOString().replace(/:/g, '-');
    const resultsDir = path.join(__dirname, 'test-results');
    if (!fs.existsSync(resultsDir)) {
      fs.mkdirSync(resultsDir, { recursive: true });
    }
    
    const resultsFile = path.join(resultsDir, `stored-procedures-${timestamp}.json`);
    fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
    console.log(chalk.gray(`\nResults saved to: ${resultsFile}`));
    
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
  testStoredProcedures()
    .then(results => process.exit(results.passed === results.total ? 0 : 1))
    .catch(() => process.exit(1));
}

export { testStoredProcedures };