"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.StoredProcTestDataGenerator = void 0;
const pg_1 = require("pg");
const PersonaGenerator_1 = require("./generators/PersonaGenerator");
const EnhancedAssetGenerator_1 = require("./generators/EnhancedAssetGenerator");
const faker_1 = require("@faker-js/faker");
/**
 * Enhanced Test Data Generator using Forward Inheritance Platform Stored Procedures
 *
 * This generator creates realistic test data using the database-first architecture
 * approach with all operations going through stored procedures as defined in
 * architecture.md
 */
class StoredProcTestDataGenerator {
    pool;
    personaGenerator;
    assetGenerator;
    constructor(dbConfig) {
        this.pool = new pg_1.Pool(dbConfig);
        this.personaGenerator = new PersonaGenerator_1.PersonaGenerator();
        this.assetGenerator = new EnhancedAssetGenerator_1.EnhancedAssetGenerator();
    }
    /**
     * Generate 10 FFCs with 3-5 members each, ensuring all 13 asset categories
     * are covered multiple times across families
     */
    async generateForwardTestScenario() {
        const startTime = Date.now();
        console.log('🚀 Starting Forward Inheritance Platform test data generation...');
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');
            const stats = {
                tenants: 0,
                personas: 0,
                ffcs: 0,
                assets: 0,
                ownerships: 0,
                permissions: 0,
                memberships: 0,
                executionTime: 0
            };
            // Create single tenant for this test scenario
            console.log('📊 Creating test tenant...');
            const tenantId = await this.createTenant(client, 'Forward Test Tenant');
            stats.tenants = 1;
            // Generate 10 FFCs with 3-5 members each (total 35-50 personas)
            console.log('👥 Generating 10 Forward Family Circles...');
            const ffcs = await this.generateTenFFcsWithMembers(client, tenantId);
            stats.ffcs = ffcs.length;
            stats.personas = ffcs.reduce((sum, ffc) => sum + ffc.memberCount, 0);
            stats.memberships = stats.personas; // Each persona is a member
            // Generate comprehensive asset coverage across all FFCs
            console.log('💰 Generating comprehensive asset portfolio...');
            const assetResults = await this.generateComprehensiveAssets(client, tenantId, ffcs);
            stats.assets = assetResults.totalAssets;
            stats.ownerships = assetResults.totalOwnerships;
            stats.permissions = assetResults.totalPermissions;
            await client.query('COMMIT');
            const endTime = Date.now();
            stats.executionTime = endTime - startTime;
            console.log('✅ Forward test scenario generation completed successfully!');
            console.log(`📈 Generated: ${stats.tenants} tenant, ${stats.personas} personas, ${stats.ffcs} FFCs, ${stats.assets} assets`);
            console.log(`⏱️  Execution time: ${stats.executionTime}ms`);
            return stats;
        }
        catch (error) {
            await client.query('ROLLBACK');
            console.error('❌ Error generating test data:', error);
            throw error;
        }
        finally {
            client.release();
        }
    }
    /**
     * Create a tenant using the tenant creation process
     */
    async createTenant(client, name) {
        const tenantName = name.toLowerCase().replace(/\s+/g, '_');
        // First check if tenant ID 1 exists (default Forward tenant)
        const tenant1Result = await client.query(`SELECT id, name FROM tenants WHERE id = 1`);
        if (tenant1Result.rows.length > 0) {
            console.log(`📋 Using existing tenant: ${tenant1Result.rows[0].name} (ID: 1)`);
            return 1;
        }
        // Check if tenant with this name already exists
        const existingResult = await client.query(`SELECT id FROM tenants WHERE name = $1`, [tenantName]);
        if (existingResult.rows.length > 0) {
            console.log(`📋 Using existing tenant: ${name} (ID: ${existingResult.rows[0].id})`);
            return existingResult.rows[0].id;
        }
        // Create new tenant with explicit ID 1 for Forward tenant
        const result = await client.query(`INSERT INTO tenants (id, name, display_name, is_active, created_at, updated_at) 
       VALUES (1, $1, $2, true, NOW(), NOW()) 
       RETURNING id`, [tenantName, name]);
        console.log(`✅ Created new tenant: ${name} (ID: ${result.rows[0].id})`);
        return result.rows[0].id;
    }
    /**
     * Generate exactly 10 FFCs with 3-5 members each using stored procedures
     */
    async generateTenFFcsWithMembers(client, tenantId) {
        const ffcs = [];
        for (let i = 0; i < 10; i++) {
            const memberCount = faker_1.faker.number.int({ min: 3, max: 5 });
            const language = faker_1.faker.helpers.weightedArrayElement([
                { value: 'en', weight: 85 },
                { value: 'es', weight: 15 }
            ]);
            console.log(`🏠 Creating FFC ${i + 1}/10 with ${memberCount} members (${language})...`);
            // Generate family members
            const familyMembers = this.personaGenerator.generateFamilyGroup(memberCount, tenantId.toString(), language);
            const ownerPersona = familyMembers.patriarch || familyMembers.matriarch || familyMembers.children[0];
            // Ensure we have a valid owner persona
            if (!ownerPersona) {
                throw new Error(`Failed to generate owner persona for FFC ${i + 1}`);
            }
            // Register users and create personas using stored procedures
            const memberPersonaIds = [];
            // Collect all valid family members
            const allMembers = [ownerPersona];
            if (familyMembers.children && familyMembers.children.length > 0) {
                allMembers.push(...familyMembers.children.slice(0, memberCount - 1));
            }
            for (const member of allMembers) {
                if (!member || !member.first_name || !member.last_name) {
                    console.warn('Skipping invalid member:', member);
                    continue;
                }
                const personaId = await this.registerUserAndCreatePersona(client, tenantId, member);
                memberPersonaIds.push(personaId);
            }
            const ownerPersonaId = memberPersonaIds[0];
            // Create FFC using stored procedure
            const ffcId = await this.createFfc(client, tenantId, ownerPersona, ownerPersonaId);
            // Add additional members to FFC
            for (let j = 1; j < memberPersonaIds.length; j++) {
                await this.addFfcMember(client, ffcId, memberPersonaIds[j], ownerPersonaId);
            }
            ffcs.push({
                ffcId,
                memberCount,
                ownerPersonaId,
                memberPersonaIds
            });
        }
        return ffcs;
    }
    /**
     * Register user and create persona using sp_create_user_from_cognito stored procedure
     * In test environment, we simulate Cognito user creation
     */
    async registerUserAndCreatePersona(client, tenantId, persona) {
        // Simulate Cognito user ID and username (in production, these come from Cognito)
        const cognitoUserId = `test-${faker_1.faker.string.uuid()}`;
        const cognitoUsername = persona.email.split('@')[0] + faker_1.faker.number.int({ min: 100, max: 999 });
        const result = await client.query(`SELECT * FROM sp_create_user_from_cognito($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`, [
            tenantId,
            cognitoUserId,
            cognitoUsername,
            persona.email,
            persona.phone,
            persona.first_name,
            persona.last_name,
            true, // email_verified (for testing, assume verified)
            true, // phone_verified (for testing, assume verified)
            '+1' // US country code
        ]);
        return result.rows[0].persona_id;
    }
    /**
     * Create FFC using sp_create_ffc stored procedure
     */
    async createFfc(client, tenantId, ownerPersona, ownerPersonaId) {
        const ffcName = this.generateFfcName(ownerPersona.last_name, ownerPersona.language_preference);
        const description = this.generateFfcDescription(ownerPersona.language_preference);
        // Get the user_id from the persona to pass to sp_create_ffc
        const userResult = await client.query(`SELECT user_id FROM personas WHERE id = $1`, [ownerPersonaId]);
        if (!userResult.rows[0]?.user_id) {
            throw new Error(`User not found for persona ${ownerPersonaId}`);
        }
        const ownerUserId = userResult.rows[0].user_id;
        const result = await client.query(`SELECT sp_create_ffc($1, $2, $3, $4) as ffc_id`, [tenantId, ownerUserId, ffcName, description]);
        return result.rows[0].ffc_id;
    }
    /**
     * Add member to FFC using sp_add_persona_to_ffc stored procedure
     * Updated to match new stored procedure signature
     */
    async addFfcMember(client, ffcId, personaId, invitedByPersonaId) {
        const role = faker_1.faker.helpers.weightedArrayElement([
            { value: 'beneficiary', weight: 60 },
            { value: 'non_beneficiary', weight: 30 },
            { value: 'advisor', weight: 10 }
        ]);
        // Get tenant_id from the FFC
        const tenantResult = await client.query(`SELECT tenant_id FROM fwd_family_circles WHERE id = $1`, [ffcId]);
        const tenantId = tenantResult.rows[0]?.tenant_id;
        if (!tenantId) {
            throw new Error(`FFC ${ffcId} not found`);
        }
        // Get the user_id of the person adding the member
        const adderUserResult = await client.query(`SELECT user_id FROM personas WHERE id = $1`, [invitedByPersonaId]);
        const addedBy = adderUserResult.rows[0]?.user_id;
        await client.query(`SELECT sp_add_persona_to_ffc($1, $2, $3, $4, $5)`, [tenantId, ffcId, personaId, role, addedBy]);
    }
    /**
     * Generate comprehensive asset coverage across all 13 categories
     * Ensures each category appears multiple times across the 10 FFCs
     */
    async generateComprehensiveAssets(client, tenantId, ffcs) {
        const assetCategories = [
            'personal_directives', 'trust', 'will', 'personal_property',
            'operational_property', 'inventory', 'real_estate', 'life_insurance',
            'financial_accounts', 'recurring_income', 'digital_assets',
            'ownership_interests', 'loans'
        ];
        let totalAssets = 0;
        let totalOwnerships = 0;
        let totalPermissions = 0;
        // Generate 8-12 assets per FFC to ensure comprehensive coverage
        for (const ffc of ffcs) {
            const assetsPerFfc = faker_1.faker.number.int({ min: 8, max: 12 });
            console.log(`💼 Generating ${assetsPerFfc} assets for FFC...`);
            // Ensure each FFC has at least one asset from different categories
            const selectedCategories = faker_1.faker.helpers.arrayElements(assetCategories, Math.min(assetsPerFfc, assetCategories.length));
            // Fill remaining slots with random categories to ensure coverage
            while (selectedCategories.length < assetsPerFfc) {
                selectedCategories.push(faker_1.faker.helpers.arrayElement(assetCategories));
            }
            for (let i = 0; i < assetsPerFfc; i++) {
                const category = selectedCategories[i];
                const createdBy = faker_1.faker.helpers.arrayElement(ffc.memberPersonaIds);
                try {
                    const assetId = await this.createAssetByCategory(client, tenantId, ffc.ffcId, category, createdBy, 'mixed' // Use mixed wealth scenario
                    );
                    totalAssets++;
                    // Note: sp_create_asset already creates 100% ownership for the owner_persona_id
                    // so we don't need to call createAssetOwnership separately
                    // const ownershipCount = await this.createAssetOwnership(client, tenantId, assetId, ffc.memberPersonaIds, createdBy);
                    const ownershipCount = 1; // Already created by sp_create_asset
                    // Create asset permissions for other family members
                    const permissionCount = await this.createAssetPermissions(client, tenantId, assetId, ffc.memberPersonaIds, createdBy);
                    totalOwnerships += ownershipCount;
                    totalPermissions += permissionCount;
                }
                catch (error) {
                    console.warn(`⚠️  Failed to create ${category} asset: ${error}`);
                }
            }
        }
        return { totalAssets, totalOwnerships, totalPermissions };
    }
    /**
     * Create asset using sp_create_asset stored procedure with category-specific data
     * Updated to match new stored procedure signature with owner_persona_id and asset_type
     */
    async createAssetByCategory(client, tenantId, ffcId, category, createdBy, scenario) {
        const assetData = this.assetGenerator.generateAssetByCategory(category, tenantId.toString(), ffcId, createdBy, scenario === 'mixed' ? (faker_1.faker.datatype.boolean(0.3) ? 'high_net_worth' : 'mass_affluent') : scenario);
        // Map category to asset_type_enum values - these must match the enum definition exactly
        const assetTypeMap = {
            'personal_directives': 'personal_directives',
            'trust': 'trust',
            'will': 'will',
            'personal_property': 'personal_property',
            'operational_property': 'operational_property',
            'inventory': 'inventory',
            'real_estate': 'real_estate',
            'life_insurance': 'life_insurance',
            'financial_accounts': 'financial_accounts',
            'recurring_income': 'recurring_income',
            'digital_assets': 'digital_assets',
            'ownership_interests': 'ownership_interests',
            'loans': 'loans'
        };
        const assetType = assetTypeMap[category];
        if (!assetType) {
            throw new Error(`Invalid asset category: ${category}`);
        }
        // Get the user_id for the creator
        const userResult = await client.query(`SELECT user_id FROM personas WHERE id = $1`, [createdBy]);
        const createdByUserId = userResult.rows[0]?.user_id;
        const result = await client.query(`SELECT sp_create_asset($1, $2, $3, $4, $5, $6, $7) as asset_id`, [
            tenantId,
            createdBy, // owner_persona_id
            assetType, // asset_type enum
            assetData.name,
            assetData.description || `${category} asset`,
            100.00, // ownership_percentage (default 100%)
            createdByUserId // created_by_user_id
        ]);
        const assetId = result.rows[0].asset_id;
        // Update asset with estimated value using sp_update_asset_value
        await this.updateAssetValue(client, assetId, assetData.estimated_value, createdBy);
        return assetId;
    }
    /**
     * Update asset value using sp_update_asset_value stored procedure
     */
    async updateAssetValue(client, assetId, value, updatedBy) {
        // Get the user_id for the updater
        const userResult = await client.query(`SELECT user_id FROM personas WHERE id = $1`, [updatedBy]);
        const updatedByUserId = userResult.rows[0]?.user_id;
        await client.query(`SELECT sp_update_asset_value($1, $2, $3, $4, $5)`, [assetId, value, new Date(), 'market', updatedByUserId]);
    }
    /**
     * Create asset ownership using sp_assign_asset_to_persona stored procedure
     */
    async createAssetOwnership(client, tenantId, assetId, memberPersonaIds, assignedBy) {
        const ownerCount = faker_1.faker.number.int({ min: 1, max: Math.min(3, memberPersonaIds.length) });
        const selectedOwners = faker_1.faker.helpers.arrayElements(memberPersonaIds, ownerCount);
        let totalPercentage = 0;
        let ownershipCount = 0;
        for (let i = 0; i < selectedOwners.length; i++) {
            const owner = selectedOwners[i];
            const isLastOwner = i === selectedOwners.length - 1;
            const percentage = isLastOwner
                ? (100 - totalPercentage)
                : faker_1.faker.number.int({ min: 10, max: Math.floor((100 - totalPercentage) / (selectedOwners.length - i)) });
            const ownershipType = faker_1.faker.helpers.weightedArrayElement([
                { value: 'owner', weight: 70 },
                { value: 'beneficiary', weight: 20 },
                { value: 'trustee', weight: 10 }
            ]);
            // Get the user_id for the assigner
            const assignerUserResult = await client.query(`SELECT user_id FROM personas WHERE id = $1`, [assignedBy]);
            const assignedByUserId = assignerUserResult.rows[0]?.user_id;
            try {
                await client.query(`SELECT sp_assign_asset_to_persona($1, $2, $3, $4, $5, $6)`, [
                    assetId,
                    owner,
                    ownershipType,
                    percentage,
                    i === 0, // is_primary for first owner
                    assignedByUserId
                ]);
                totalPercentage += percentage;
                ownershipCount++;
            }
            catch (error) {
                console.warn(`⚠️  Failed to assign asset ownership: ${error}`);
            }
        }
        return ownershipCount;
    }
    /**
     * Create asset permissions (simplified - would use permission stored procedures if available)
     */
    async createAssetPermissions(client, tenantId, assetId, memberPersonaIds, grantedBy) {
        // For now, create basic read permissions for all family members
        // In a real implementation, this would use permission management stored procedures
        const permissionCount = faker_1.faker.number.int({ min: 2, max: memberPersonaIds.length });
        const selectedViewers = faker_1.faker.helpers.arrayElements(memberPersonaIds, permissionCount);
        let permissions = 0;
        for (const viewer of selectedViewers) {
            const permissionLevel = faker_1.faker.helpers.weightedArrayElement([
                { value: 'read', weight: 60 },
                { value: 'edit', weight: 30 },
                { value: 'admin', weight: 10 }
            ]);
            try {
                // This would use a proper permission stored procedure when available
                await client.query(`INSERT INTO asset_permissions (tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id, created_at) 
           VALUES ($1, $2, $3, $4, $5, NOW())`, [tenantId, assetId, viewer, permissionLevel, grantedBy]);
                permissions++;
            }
            catch (error) {
                console.warn(`⚠️  Failed to create asset permission: ${error}`);
            }
        }
        return permissions;
    }
    /**
     * Generate FFC name based on language preference
     */
    generateFfcName(lastName, language) {
        if (language === 'es') {
            const spanishTerms = ['Familia', 'Casa', 'Círculo Familiar', 'Herencia'];
            const term = faker_1.faker.helpers.arrayElement(spanishTerms);
            return `${term} ${lastName}`;
        }
        else {
            const englishTerms = ['Family', 'Family Circle', 'Family Trust', 'Heritage'];
            const term = faker_1.faker.helpers.arrayElement(englishTerms);
            return `${lastName} ${term}`;
        }
    }
    /**
     * Generate FFC description based on language preference
     */
    generateFfcDescription(language) {
        if (language === 'es') {
            const descriptions = [
                'Círculo familiar para la planificación de herencias y gestión de patrimonio',
                'Grupo familiar dedicado a la transparencia financiera y planificación sucesoria',
                'Organización familiar para la administración colaborativa de activos'
            ];
            return faker_1.faker.helpers.arrayElement(descriptions);
        }
        else {
            const descriptions = [
                'Family circle for inheritance planning and wealth management',
                'Family group dedicated to financial transparency and estate planning',
                'Family organization for collaborative asset management'
            ];
            return faker_1.faker.helpers.arrayElement(descriptions);
        }
    }
    /**
     * Clean all test data using proper stored procedures or cascading deletes
     */
    async cleanTestData() {
        console.log('🧹 Cleaning Forward test data...');
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');
            // Delete in proper dependency order
            await client.query('DELETE FROM asset_permissions WHERE TRUE');
            await client.query('DELETE FROM asset_ownerships WHERE TRUE');
            await client.query('DELETE FROM assets WHERE TRUE');
            await client.query('DELETE FROM ffc_personas WHERE TRUE');
            await client.query('DELETE FROM fwd_family_circles WHERE TRUE');
            await client.query('DELETE FROM personas WHERE TRUE');
            await client.query('DELETE FROM users WHERE TRUE');
            await client.query('DELETE FROM tenants WHERE name LIKE \'%Test%\'');
            await client.query('COMMIT');
            console.log('✅ Forward test data cleaned successfully!');
        }
        catch (error) {
            await client.query('ROLLBACK');
            console.error('❌ Error cleaning test data:', error);
            throw error;
        }
        finally {
            client.release();
        }
    }
    async close() {
        await this.pool.end();
    }
}
exports.StoredProcTestDataGenerator = StoredProcTestDataGenerator;
