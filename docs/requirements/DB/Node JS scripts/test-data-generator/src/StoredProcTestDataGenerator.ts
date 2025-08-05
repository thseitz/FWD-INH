import { Pool, PoolClient } from 'pg';
import { PersonaGenerator } from './generators/PersonaGenerator';
import { EnhancedAssetGenerator } from './generators/EnhancedAssetGenerator';
import { 
  GenerationConfig, 
  DatabaseConfig, 
  TestPersona, 
  TestFfc, 
  TestAsset,
  TestAssetOwnership,
  TestAssetPermission,
  TestFfcMembership,
  GenerationStats
} from './types';
import { faker } from '@faker-js/faker';

/**
 * Enhanced Test Data Generator using Forward Inheritance Platform Stored Procedures
 * 
 * This generator creates realistic test data using the database-first architecture
 * approach with all operations going through stored procedures as defined in 
 * architecture.md
 */
export class StoredProcTestDataGenerator {
  private pool: Pool;
  private personaGenerator: PersonaGenerator;
  private assetGenerator: EnhancedAssetGenerator;

  constructor(dbConfig: DatabaseConfig) {
    this.pool = new Pool(dbConfig);
    this.personaGenerator = new PersonaGenerator();
    this.assetGenerator = new EnhancedAssetGenerator();
  }

  /**
   * Generate 10 FFCs with 3-5 members each, ensuring all 13 asset categories 
   * are covered multiple times across families
   */
  async generateForwardTestScenario(): Promise<GenerationStats> {
    const startTime = Date.now();
    console.log('🚀 Starting Forward Inheritance Platform test data generation...');
    
    const client = await this.pool.connect();
    
    try {
      await client.query('BEGIN');
      
      const stats: GenerationStats = {
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
      
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('❌ Error generating test data:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Create a tenant using the tenant creation process
   */
  private async createTenant(client: PoolClient, name: string): Promise<number> {
    // Check if tenant already exists, if so return existing ID
    const existingResult = await client.query(
      `SELECT id FROM tenants WHERE name = $1`,
      [name.toLowerCase().replace(/\s+/g, '_')]
    );
    
    if (existingResult.rows.length > 0) {
      console.log(`📋 Using existing tenant: ${name} (ID: ${existingResult.rows[0].id})`);
      return existingResult.rows[0].id;
    }
    
    // Create new tenant with explicit ID (use 1 for Forward tenant)
    const testTenantId = 1;
    const result = await client.query(
      `INSERT INTO tenants (id, name, display_name, is_active, created_at, updated_at) 
       VALUES ($1, $2, $3, true, NOW(), NOW()) 
       RETURNING id`,
      [testTenantId, name.toLowerCase().replace(/\s+/g, '_'), name]
    );
    
    return result.rows[0].id;
  }

  /**
   * Generate exactly 10 FFCs with 3-5 members each using stored procedures
   */
  private async generateTenFFcsWithMembers(
    client: PoolClient, 
    tenantId: number
  ): Promise<Array<{ ffcId: string; memberCount: number; ownerPersonaId: string; memberPersonaIds: string[] }>> {
    const ffcs = [];
    
    for (let i = 0; i < 10; i++) {
      const memberCount = faker.number.int({ min: 3, max: 5 });
      const language = faker.helpers.weightedArrayElement([
        { value: 'en' as const, weight: 85 },
        { value: 'es' as const, weight: 15 }
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
      const memberPersonaIds: string[] = [];
      
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
   * Register user and create persona using sp_register_user stored procedure
   */
  private async registerUserAndCreatePersona(
    client: PoolClient,
    tenantId: number,
    persona: TestPersona
  ): Promise<string> {
    const password = faker.internet.password({ length: 12 });
    const passwordSalt = faker.string.alphanumeric(32);
    const passwordHash = faker.string.alphanumeric(64); // In real app, this would be hashed with salt
    
    const result = await client.query(
      `SELECT * FROM sp_register_user($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        tenantId,
        persona.email,
        persona.phone,
        passwordHash,
        passwordSalt,
        persona.first_name,
        persona.last_name,
        '+1' // US country code
      ]
    );
    
    return result.rows[0].persona_id;
  }

  /**
   * Create FFC using sp_create_ffc stored procedure
   */
  private async createFfc(
    client: PoolClient,
    tenantId: number,
    ownerPersona: TestPersona,
    ownerPersonaId: string
  ): Promise<string> {
    const ffcName = this.generateFfcName(ownerPersona.last_name, ownerPersona.language_preference);
    const description = this.generateFfcDescription(ownerPersona.language_preference);
    
    // Get the user_id from the persona to pass to sp_create_ffc
    const userResult = await client.query(
      `SELECT user_id FROM personas WHERE id = $1`,
      [ownerPersonaId]
    );
    
    if (!userResult.rows[0]?.user_id) {
      throw new Error(`User not found for persona ${ownerPersonaId}`);
    }
    
    const ownerUserId = userResult.rows[0].user_id;
    
    const result = await client.query(
      `SELECT sp_create_ffc($1, $2, $3, $4) as ffc_id`,
      [tenantId, ownerUserId, ffcName, description]
    );
    
    return result.rows[0].ffc_id;
  }

  /**
   * Add member to FFC using sp_add_ffc_member stored procedure
   */
  private async addFfcMember(
    client: PoolClient,
    ffcId: string,
    personaId: string,
    invitedByPersonaId: string
  ): Promise<void> {
    const role = faker.helpers.weightedArrayElement([
      { value: 'beneficiary', weight: 60 },
      { value: 'non_beneficiary', weight: 30 },
      { value: 'advisor', weight: 10 }
    ]);
    
    // Get tenant_id from the FFC
    const tenantResult = await client.query(
      `SELECT tenant_id FROM fwd_family_circles WHERE id = $1`,
      [ffcId]
    );
    
    const tenantId = tenantResult.rows[0]?.tenant_id;
    if (!tenantId) {
      throw new Error(`FFC ${ffcId} not found`);
    }
    
    await client.query(
      `SELECT sp_add_ffc_member($1, $2, $3, $4)`,
      [tenantId, ffcId, personaId, role]
    );
  }

  /**
   * Generate comprehensive asset coverage across all 13 categories
   * Ensures each category appears multiple times across the 10 FFCs
   */
  private async generateComprehensiveAssets(
    client: PoolClient,
    tenantId: number,
    ffcs: Array<{ ffcId: string; memberCount: number; ownerPersonaId: string; memberPersonaIds: string[] }>
  ): Promise<{ totalAssets: number; totalOwnerships: number; totalPermissions: number }> {
    
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
      const assetsPerFfc = faker.number.int({ min: 8, max: 12 });
      console.log(`💼 Generating ${assetsPerFfc} assets for FFC...`);
      
      // Ensure each FFC has at least one asset from different categories
      const selectedCategories = faker.helpers.arrayElements(assetCategories, Math.min(assetsPerFfc, assetCategories.length));
      
      // Fill remaining slots with random categories to ensure coverage
      while (selectedCategories.length < assetsPerFfc) {
        selectedCategories.push(faker.helpers.arrayElement(assetCategories));
      }
      
      for (let i = 0; i < assetsPerFfc; i++) {
        const category = selectedCategories[i];
        const createdBy = faker.helpers.arrayElement(ffc.memberPersonaIds);
        
        try {
          const assetId = await this.createAssetByCategory(
            client,
            tenantId,
            ffc.ffcId,
            category,
            createdBy,
            'mixed' // Use mixed wealth scenario
          );
          
          totalAssets++;
          
          // Create asset ownership and permissions
          const ownershipCount = await this.createAssetOwnership(client, tenantId, assetId, ffc.memberPersonaIds, createdBy);
          const permissionCount = await this.createAssetPermissions(client, tenantId, assetId, ffc.memberPersonaIds, createdBy);
          
          totalOwnerships += ownershipCount;
          totalPermissions += permissionCount;
          
        } catch (error) {
          console.warn(`⚠️  Failed to create ${category} asset: ${error}`);
        }
      }
    }
    
    return { totalAssets, totalOwnerships, totalPermissions };
  }

  /**
   * Create asset using sp_create_asset stored procedure with category-specific data
   */
  private async createAssetByCategory(
    client: PoolClient,
    tenantId: number,
    ffcId: string,
    category: string,
    createdBy: string,
    scenario: 'high_net_worth' | 'mass_affluent' | 'mixed'
  ): Promise<string> {
    
    const assetData = this.assetGenerator.generateAssetByCategory(
      category as any,
      tenantId.toString(),
      ffcId,
      createdBy,
      scenario === 'mixed' ? (faker.datatype.boolean(0.3) ? 'high_net_worth' : 'mass_affluent') : scenario
    );
    
    // Convert category name to category code (lowercase with underscores)
    const categoryCode = category.toLowerCase().replace(/\s+/g, '_');
    
    const result = await client.query(
      `SELECT sp_create_asset($1, $2, $3, $4, $5, $6, $7) as asset_id`,
      [
        tenantId,
        ffcId,
        categoryCode,
        assetData.name,
        assetData.description || `${category} asset`,
        assetData.estimated_value,
        createdBy
      ]
    );
    
    const assetId = result.rows[0].asset_id;
    
    // Update asset with estimated value using sp_update_asset_value
    await this.updateAssetValue(client, assetId, assetData.estimated_value, createdBy);
    
    return assetId;
  }

  /**
   * Update asset value using sp_update_asset_value stored procedure
   */
  private async updateAssetValue(
    client: PoolClient,
    assetId: string,
    value: number,
    updatedBy: string
  ): Promise<void> {
    await client.query(
      `SELECT sp_update_asset_value($1, $2, $3, $4)`,
      [assetId, value, new Date(), updatedBy]
    );
  }

  /**
   * Create asset ownership using sp_assign_asset_to_persona stored procedure
   */
  private async createAssetOwnership(
    client: PoolClient,
    tenantId: number,
    assetId: string,
    memberPersonaIds: string[],
    assignedBy: string
  ): Promise<number> {
    const ownerCount = faker.number.int({ min: 1, max: Math.min(3, memberPersonaIds.length) });
    const selectedOwners = faker.helpers.arrayElements(memberPersonaIds, ownerCount);
    
    let totalPercentage = 0;
    let ownershipCount = 0;
    
    for (let i = 0; i < selectedOwners.length; i++) {
      const owner = selectedOwners[i];
      const isLastOwner = i === selectedOwners.length - 1;
      
      const percentage = isLastOwner 
        ? (100 - totalPercentage)
        : faker.number.int({ min: 10, max: Math.floor((100 - totalPercentage) / (selectedOwners.length - i)) });
      
      const ownershipType = faker.helpers.weightedArrayElement([
        { value: 'owner', weight: 70 },
        { value: 'beneficiary', weight: 20 },
        { value: 'trustee', weight: 10 }
      ]);
      
      try {
        await client.query(
          `SELECT sp_assign_asset_to_persona($1, $2, $3, $4, $5, $6, $7)`,
          [
            tenantId,
            assetId, 
            owner, 
            ownershipType, 
            percentage,
            i === 0, // is_primary for first owner
            assignedBy
          ]
        );
        
        totalPercentage += percentage;
        ownershipCount++;
      } catch (error) {
        console.warn(`⚠️  Failed to assign asset ownership: ${error}`);
      }
    }
    
    return ownershipCount;
  }

  /**
   * Create asset permissions (simplified - would use permission stored procedures if available)
   */
  private async createAssetPermissions(
    client: PoolClient,
    tenantId: number,
    assetId: string,
    memberPersonaIds: string[],
    grantedBy: string
  ): Promise<number> {
    // For now, create basic read permissions for all family members
    // In a real implementation, this would use permission management stored procedures
    
    const permissionCount = faker.number.int({ min: 2, max: memberPersonaIds.length });
    const selectedViewers = faker.helpers.arrayElements(memberPersonaIds, permissionCount);
    
    let permissions = 0;
    
    for (const viewer of selectedViewers) {
      const permissionLevel = faker.helpers.weightedArrayElement([
        { value: 'read', weight: 60 },
        { value: 'edit', weight: 30 },
        { value: 'admin', weight: 10 }
      ]);
      
      try {
        // This would use a proper permission stored procedure when available
        await client.query(
          `INSERT INTO asset_permissions (tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id, created_at) 
           VALUES ($1, $2, $3, $4, $5, NOW())`,
          [tenantId, assetId, viewer, permissionLevel, grantedBy]
        );
        permissions++;
      } catch (error) {
        console.warn(`⚠️  Failed to create asset permission: ${error}`);
      }
    }
    
    return permissions;
  }

  /**
   * Generate FFC name based on language preference
   */
  private generateFfcName(lastName: string, language: 'en' | 'es'): string {
    if (language === 'es') {
      const spanishTerms = ['Familia', 'Casa', 'Círculo Familiar', 'Herencia'];
      const term = faker.helpers.arrayElement(spanishTerms);
      return `${term} ${lastName}`;
    } else {
      const englishTerms = ['Family', 'Family Circle', 'Family Trust', 'Heritage'];
      const term = faker.helpers.arrayElement(englishTerms);
      return `${lastName} ${term}`;
    }
  }

  /**
   * Generate FFC description based on language preference
   */
  private generateFfcDescription(language: 'en' | 'es'): string {
    if (language === 'es') {
      const descriptions = [
        'Círculo familiar para la planificación de herencias y gestión de patrimonio',
        'Grupo familiar dedicado a la transparencia financiera y planificación sucesoria',
        'Organización familiar para la administración colaborativa de activos'
      ];
      return faker.helpers.arrayElement(descriptions);
    } else {
      const descriptions = [
        'Family circle for inheritance planning and wealth management',
        'Family group dedicated to financial transparency and estate planning',
        'Family organization for collaborative asset management'
      ];
      return faker.helpers.arrayElement(descriptions);
    }
  }

  /**
   * Clean all test data using proper stored procedures or cascading deletes
   */
  async cleanTestData(): Promise<void> {
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
      
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('❌ Error cleaning test data:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  async close(): Promise<void> {
    await this.pool.end();
  }
}