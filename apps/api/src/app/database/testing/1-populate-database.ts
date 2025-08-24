/**
 * Test 1: Populate Database
 * Populates the database with comprehensive test data for testing stored procedures and SQL queries
 * 
 * This script creates:
 * - Tenant and test users
 * - Personas for users  
 * - Email addresses and phone numbers
 * - FFC (Forward Family Circles)
 * - Assets and ownership
 * - Subscriptions and plans
 * - Payment methods
 * - Integration configurations
 */

import { Client } from 'pg';
import chalk from 'chalk';
import { faker } from '@faker-js/faker';

const DB_CONFIG = {
  host: 'localhost',
  port: 5432,
  database: 'fwd_db',
  user: 'postgres',
  password: 'FGt!3reGTdt5BG!'
};

async function populateTestData(client: Client, tenantId: number) {
  console.log(chalk.blue('Populating database with test data...'));
  
  // Start transaction
  await client.query('BEGIN');
  
  try {
    // 1. Create test users with emails and phones
    const users = [];
    for (let i = 0; i < 5; i++) {
      // First create email
      const emailResult = await client.query(`
        INSERT INTO email_address (tenant_id, email_address, email_type, is_verified, status)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id
      `, [tenantId, faker.internet.email(), 'personal', true, 'active']);
      
      // Then create phone
      const phoneResult = await client.query(`
        INSERT INTO phone_number (tenant_id, country_code, phone_number, phone_type, is_verified, is_primary)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id
      `, [tenantId, '+1', faker.phone.number().replace(/\D/g, '').substring(0, 10), 'mobile', true, true]);
      
      // Now create user
      const userResult = await client.query(`
        INSERT INTO users (
          tenant_id, cognito_user_id, cognito_username, 
          primary_email_id, primary_phone_id,
          first_name, last_name, status
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id
      `, [
        tenantId,
        'cognito_' + faker.string.uuid(),
        faker.internet.userName(),
        emailResult.rows[0].id,
        phoneResult.rows[0].id,
        faker.person.firstName(),
        faker.person.lastName(),
        'active'
      ]);
      
      users.push(userResult.rows[0].id);
      
      // Create usage records
      await client.query(`
        INSERT INTO usage_email (tenant_id, entity_type, entity_id, email_id, usage_type, is_primary)
        VALUES ($1, 'user', $2, $3, 'primary', true)
      `, [tenantId, userResult.rows[0].id, emailResult.rows[0].id]);
      
      await client.query(`
        INSERT INTO usage_phone (tenant_id, entity_type, entity_id, phone_id, usage_type, is_primary)
        VALUES ($1, 'user', $2, $3, 'primary', true)
      `, [tenantId, userResult.rows[0].id, phoneResult.rows[0].id]);
    }
    console.log(chalk.green('✓ Created ' + users.length + ' users with emails and phones'));
    
    // 2. Create personas for users
    const personas = [];
    for (const userId of users) {
      const personaResult = await client.query(`
        INSERT INTO personas (
          tenant_id, user_id, first_name, last_name, is_living, status
        )
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id
      `, [
        tenantId, userId,
        faker.person.firstName(), faker.person.lastName(),
        true, 'active'
      ]);
      personas.push(personaResult.rows[0].id);
    }
    console.log(chalk.green('✓ Created ' + personas.length + ' personas'));
    
    // 3. Create FFCs
    const ffcs = [];
    for (let i = 0; i < 3; i++) {
      const ffcResult = await client.query(`
        INSERT INTO fwd_family_circles (
          tenant_id, owner_user_id, name, description, is_active
        )
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id
      `, [
        tenantId, users[i],
        faker.company.name() + ' Family',
        faker.lorem.sentence(),
        true
      ]);
      ffcs.push(ffcResult.rows[0].id);
      
      // Add owner to FFC
      await client.query(`
        INSERT INTO ffc_personas (
          tenant_id, ffc_id, persona_id, ffc_role, joined_at
        )
        VALUES ($1, $2, $3, $4, NOW())
      `, [tenantId, ffcResult.rows[0].id, personas[i], 'owner']);
    }
    console.log(chalk.green('✓ Created ' + ffcs.length + ' FFCs'));
    
    // 4. Ensure asset categories exist
    const assetTypes = ['real_estate', 'vehicle', 'financial_account', 'personal_property', 'business'];
    for (const assetType of assetTypes) {
      await client.query(`
        INSERT INTO asset_categories (name, code, description)
        VALUES ($1, $2, $3)
        ON CONFLICT (code) DO NOTHING
      `, [
        assetType.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase()),
        assetType,
        'Category for ' + assetType.replace('_', ' ')
      ]);
    }
    
    // 5. Create assets
    const assets = [];
    
    for (let i = 0; i < 10; i++) {
      // Get category ID for asset type
      const assetType = faker.helpers.arrayElement(assetTypes);
      const categoryResult = await client.query(
        'SELECT id FROM asset_categories WHERE code = $1',
        [assetType]
      );
      
      const assetResult = await client.query(`
        INSERT INTO assets (
          tenant_id, category_id, name, description, status, created_by, updated_by
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id
      `, [
        tenantId,
        categoryResult.rows[0].id,
        faker.commerce.productName(),
        faker.commerce.productDescription(),
        'active',
        users[0],
        users[0]
      ]);
      assets.push(assetResult.rows[0].id);
      
      // Create ownership
      await client.query(`
        INSERT INTO asset_persona (
          tenant_id, asset_id, persona_id, ownership_type, ownership_percentage, is_primary
        )
        VALUES ($1, $2, $3, $4, $5, $6)
      `, [
        tenantId,
        assetResult.rows[0].id,
        personas[i % personas.length],
        'owner',
        faker.number.float({ min: 10, max: 100, fractionDigits: 2 }),
        true
      ]);
    }
    console.log(chalk.green('✓ Created ' + assets.length + ' assets'));
    
    // 5a. Create financial_accounts for financial_account type assets
    const financialAssetResult = await client.query(`
      SELECT a.id as asset_id, qi.id as quiltt_integration_id
      FROM assets a
      JOIN asset_categories ac ON a.category_id = ac.id
      LEFT JOIN asset_persona ap ON a.id = ap.asset_id AND ap.is_primary = true
      LEFT JOIN quiltt_integrations qi ON qi.persona_id = ap.persona_id
      WHERE a.tenant_id = $1 AND ac.code = 'financial_account'
      LIMIT 5
    `, [tenantId]);
    
    for (const row of financialAssetResult.rows) {
      const isQuilttConnected = row.quiltt_integration_id !== null && Math.random() > 0.5;
      await client.query(`
        INSERT INTO financial_accounts (
          asset_id, institution_name, account_type, account_number_last_four,
          current_balance, balance_as_of_date,
          quiltt_integration_id, quiltt_account_id, quiltt_connection_id,
          is_quiltt_connected, last_quiltt_sync_at, quiltt_sync_status
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
        ON CONFLICT (asset_id) DO NOTHING
      `, [
        row.asset_id,
        faker.company.name() + ' Bank',
        faker.helpers.arrayElement(['checking', 'savings', 'investment', 'retirement_401k', 'retirement_ira', 'hsa']),
        faker.string.numeric(4),
        faker.number.float({ min: 1000, max: 100000, fractionDigits: 2 }),
        new Date(),
        isQuilttConnected ? row.quiltt_integration_id : null,
        isQuilttConnected ? 'acct_' + faker.string.alphanumeric(16) : null,
        isQuilttConnected ? 'conn_' + faker.string.alphanumeric(10) : null,
        isQuilttConnected,
        isQuilttConnected ? new Date() : null,
        isQuilttConnected ? 'completed' : 'pending'
      ]);
    }
    if (financialAssetResult.rows.length > 0) {
      console.log(chalk.green('✓ Created financial account details'));
    }
    
    // 6. Ensure we have a subscription plan
    const planResult = await client.query('SELECT id FROM plans WHERE tenant_id = $1 LIMIT 1', [tenantId]);
    let planId = planResult.rows[0]?.id;
    
    if (!planId) {
      const newPlan = await client.query(`
        INSERT INTO plans (
          tenant_id, name, description, price_monthly, price_yearly, 
          max_users, max_assets, max_storage_gb, features, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING id
      `, [
        tenantId, 'Test Plan', 'Test plan for testing', 
        9.99, 99.99, 10, 100, 10, 
        JSON.stringify(['feature1', 'feature2']), true
      ]);
      planId = newPlan.rows[0].id;
      console.log(chalk.green('✓ Created subscription plan'));
    }
    
    // 7. Create subscriptions
    const subscriptions = [];
    for (let i = 0; i < 2; i++) {
      const subResult = await client.query(`
        INSERT INTO subscriptions (
          tenant_id, ffc_id, plan_id, owner_user_id, 
          payer_id, payer_type, status
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id
      `, [
        tenantId, ffcs[i], planId, users[i],
        users[i], 'owner', 'active'
      ]);
      subscriptions.push(subResult.rows[0].id);
    }
    console.log(chalk.green('✓ Created ' + subscriptions.length + ' subscriptions'));
    
    // 8. Add payment methods for users
    let paymentMethodCount = 0;
    for (const userId of users) {
      const pmResult = await client.query('SELECT id FROM payment_methods WHERE user_id = $1 LIMIT 1', [userId]);
      if (!pmResult.rows[0]) {
        await client.query(`
          INSERT INTO payment_methods (
            tenant_id, user_id, stripe_payment_method_id, stripe_customer_id,
            payment_type, last_four, brand, is_default, status
          ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        `, [
          tenantId, userId, 'pm_' + faker.string.alphanumeric(24), 'cus_' + faker.string.alphanumeric(14),
          'card', '4242', 'visa', true, 'active'
        ]);
        paymentMethodCount++;
      }
    }
    console.log(chalk.green('✓ Created ' + paymentMethodCount + ' payment methods'));
    
    // 9. Create integration configs
    // Get first persona for Quiltt integration
    const personaResult = await client.query('SELECT id FROM personas WHERE tenant_id = $1 LIMIT 1', [tenantId]);
    const personaId = personaResult.rows[0]?.id;
    
    if (personaId) {
      await client.query(`
        INSERT INTO quiltt_integrations (
          tenant_id, persona_id, quiltt_user_id, quiltt_connection_id, quiltt_profile_id, is_active, sync_accounts, sync_transactions
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (tenant_id, persona_id) DO NOTHING
      `, [tenantId, personaId, personaId, 'conn_' + faker.string.alphanumeric(10), 'prof_' + faker.string.alphanumeric(10), true, true, true]);
      
      // Create a Quiltt session for testing
      await client.query(`
        INSERT INTO quiltt_sessions (
          tenant_id, persona_id, session_token, expires_at
        )
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (persona_id) WHERE NOT is_used DO NOTHING
      `, [tenantId, personaId, 'sess_' + faker.string.alphanumeric(32), new Date(Date.now() + 3600000)]); // 1 hour from now
    }
    
    // Add builder.io integration for testing sp_refresh_builder_content
    await client.query(`
      INSERT INTO builder_io_integrations (
        tenant_id, space_id, api_key, environment, is_active, connection_status
      )
      VALUES ($1, $2, $3, $4, $5, $6)
      ON CONFLICT (tenant_id, space_id) DO NOTHING
    `, [tenantId, 'test_space', 'test_api_key_encrypted', 'development', true, 'connected']);
    
    console.log(chalk.green('✓ Created integration configs'));
    
    // 9. Create HEI assets for testing
    const heiCategoryResult = await client.query('SELECT id FROM asset_categories WHERE code = $1', ['hei']);
    const realEstateCategoryResult = await client.query('SELECT id FROM asset_categories WHERE code = $1', ['real_estate']);
    
    if (heiCategoryResult.rows.length > 0 && realEstateCategoryResult.rows.length > 0) {
      for (let i = 0; i < 2; i++) {
        // Create real estate asset first
        const propertyResult = await client.query(`
          INSERT INTO assets (
            tenant_id, category_id, name, description, estimated_value, status, created_by, updated_by
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING id
        `, [
          tenantId,
          realEstateCategoryResult.rows[0].id,
          faker.location.streetAddress() + ', ' + faker.location.city(),
          'Real Estate Property for HEI',
          faker.number.float({ min: 300000, max: 800000, fractionDigits: 2 }),
          'active',
          users[0],
          users[0]
        ]);
        
        // Create address for the property
        const addressResult = await client.query(`
          INSERT INTO address (
            tenant_id, address_line_1, city, state_province, postal_code, country, address_type
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7)
          RETURNING id
        `, [
          tenantId,
          faker.location.streetAddress(),
          faker.location.city(),
          faker.location.state({ abbreviated: true }),
          faker.location.zipCode(),
          'US',
          'residential'
        ]);

        // Create real estate details
        await client.query(`
          INSERT INTO real_estate (
            asset_id, property_type, property_address_id, parcel_number,
            ownership_type, property_use
          )
          VALUES ($1, $2, $3, $4, $5, $6)
        `, [
          propertyResult.rows[0].id,
          'single_family',
          addressResult.rows[0].id,
          'APN' + faker.string.alphanumeric(8),
          'sole_ownership',
          'primary_residence'
        ]);
        
        // Create HEI asset
        const heiAssetResult = await client.query(`
          INSERT INTO assets (
            tenant_id, category_id, name, description, estimated_value, status, created_by, updated_by
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING id
        `, [
          tenantId,
          heiCategoryResult.rows[0].id,
          'HEI Investment - ' + faker.location.streetAddress(),
          'Home Equity Investment',
          faker.number.float({ min: 50000, max: 200000, fractionDigits: 2 }),
          'active',
          users[0],
          users[0]
        ]);
        
        // Create HEI details with proper date ordering
        const effectiveDate = faker.date.past({ years: 1 });
        const valuationDate = faker.date.between({ 
          from: new Date(effectiveDate.getTime() - 30 * 24 * 60 * 60 * 1000), // 30 days before
          to: effectiveDate 
        });
        
        await client.query(`
          INSERT INTO hei_assets (
            asset_id, amount_funded, equity_share_pct, effective_date, 
            property_asset_id, valuation_amount, valuation_method, 
            valuation_effective_date, source_system, source_application_id,
            hei_status, created_by, updated_by
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        `, [
          heiAssetResult.rows[0].id,
          faker.number.float({ min: 50000, max: 200000, fractionDigits: 2 }),
          faker.number.float({ min: 15, max: 25, fractionDigits: 2 }),
          effectiveDate,
          propertyResult.rows[0].id,
          faker.number.float({ min: 300000, max: 800000, fractionDigits: 2 }),
          'avm',
          valuationDate,
          'test_hei_system',
          'APP-' + faker.string.alphanumeric(8),
          'active',
          users[0],
          users[0]
        ]);
        
        // Link property asset to persona
        await client.query(`
          INSERT INTO asset_persona (
            tenant_id, asset_id, persona_id, ownership_type, ownership_percentage
          )
          VALUES ($1, $2, $3, $4, $5)
        `, [
          tenantId,
          propertyResult.rows[0].id,
          personas[i],
          'owner',
          100.00
        ]);
        
        // Link HEI asset to persona  
        await client.query(`
          INSERT INTO asset_persona (
            tenant_id, asset_id, persona_id, ownership_type, ownership_percentage
          )
          VALUES ($1, $2, $3, $4, $5)
        `, [
          tenantId,
          heiAssetResult.rows[0].id,
          personas[i],
          'owner',
          100.00
        ]);
      }
      console.log(chalk.green('✓ Created HEI assets and properties'));
    }
    
    // Commit transaction
    await client.query('COMMIT');
    
    console.log(chalk.gray('================================'));
    console.log(chalk.green('✅ Database populated successfully!'));
    
    // Show summary
    const summary = await client.query(`
      SELECT 
        (SELECT COUNT(*) FROM users WHERE tenant_id = $1) as users,
        (SELECT COUNT(*) FROM personas WHERE tenant_id = $1) as personas,
        (SELECT COUNT(*) FROM fwd_family_circles WHERE tenant_id = $1) as ffcs,
        (SELECT COUNT(*) FROM assets WHERE tenant_id = $1) as assets,
        (SELECT COUNT(*) FROM assets a JOIN asset_categories ac ON a.category_id = ac.id WHERE a.tenant_id = $1 AND ac.code = 'hei') as hei_assets,
        (SELECT COUNT(*) FROM assets a JOIN asset_categories ac ON a.category_id = ac.id WHERE a.tenant_id = $1 AND ac.code = 'real_estate') as real_estate_assets,
        (SELECT COUNT(*) FROM hei_assets ha JOIN assets a ON ha.asset_id = a.id WHERE a.tenant_id = $1) as hei_records,
        (SELECT COUNT(*) FROM subscriptions WHERE tenant_id = $1) as subscriptions,
        (SELECT COUNT(*) FROM plans WHERE tenant_id = $1) as plans,
        (SELECT COUNT(*) FROM payment_methods WHERE user_id IN (SELECT id FROM users WHERE tenant_id = $1)) as payment_methods
    `, [tenantId]);
    
    console.log(chalk.blue('\n📊 Data Summary:'));
    console.log(chalk.gray('  Users: ' + summary.rows[0].users));
    console.log(chalk.gray('  Personas: ' + summary.rows[0].personas));
    console.log(chalk.gray('  FFCs: ' + summary.rows[0].ffcs));
    console.log(chalk.gray('  Assets (Total): ' + summary.rows[0].assets));
    console.log(chalk.gray('  HEI Assets: ' + summary.rows[0].hei_assets));
    console.log(chalk.gray('  Real Estate Assets: ' + summary.rows[0].real_estate_assets));
    console.log(chalk.gray('  HEI Records: ' + summary.rows[0].hei_records));
    console.log(chalk.gray('  Subscriptions: ' + summary.rows[0].subscriptions));
    console.log(chalk.gray('  Plans: ' + summary.rows[0].plans));
    console.log(chalk.gray('  Payment Methods: ' + summary.rows[0].payment_methods));
    
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  }
}

async function populateDatabase() {
  const client = new Client(DB_CONFIG);
  
  try {
    console.log(chalk.blue('📁 Test 1: Populate Database'));
    console.log(chalk.gray('================================'));
    
    await client.connect();
    console.log(chalk.green('✓ Connected to database'));
    
    // Get or create tenant
    const tenantResult = await client.query('SELECT id FROM tenants LIMIT 1');
    let tenantId = tenantResult.rows[0]?.id;
    
    if (!tenantId) {
      const newTenant = await client.query(`
        INSERT INTO tenants (name, subdomain, status)
        VALUES ('Test Tenant', 'test', 'active')
        RETURNING id
      `);
      tenantId = newTenant.rows[0].id;
      console.log(chalk.green('✓ Created tenant'));
    } else {
      console.log(chalk.green('✓ Using existing tenant: ' + tenantId));
    }
    
    // Populate test data
    await populateTestData(client, tenantId);
    
  } catch (error) {
    console.error(chalk.red('❌ Error populating database:'), error);
    throw error;
  } finally {
    await client.end();
  }
}

// Run if called directly
if (require.main === module) {
  populateDatabase()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

export { populateDatabase };