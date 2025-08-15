import { Pool, PoolClient } from 'pg';
import { PersonaGenerator } from './generators/PersonaGenerator';
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

export class TestDataGenerator {
  private pool: Pool;
  private personaGenerator: PersonaGenerator;

  constructor(dbConfig: DatabaseConfig) {
    this.pool = new Pool(dbConfig);
    this.personaGenerator = new PersonaGenerator();
  }

  /**
   * Main generation method - orchestrates all test data creation
   */
  async generateTestData(config: GenerationConfig): Promise<GenerationStats> {
    const startTime = Date.now();
    console.log('🚀 Starting test data generation...');
    
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

      // Generate tenants
      console.log('📊 Generating tenants...');
      const tenantIds = await this.generateTenants(client, config.tenants);
      stats.tenants = tenantIds.length;

      for (const tenantId of tenantIds) {
        console.log(`👥 Generating data for tenant: ${tenantId}`);
        
        // Generate users for this tenant
        const users = await this.generateUsersForTenant(client, tenantId, 2);
        
        // Generate personas for this tenant
        const personas = await this.generatePersonasForTenant(
          client, 
          tenantId, 
          config.personasPerTenant, 
          config.language
        );
        stats.personas += personas.length;

        // Generate FFCs for this tenant
        const ffcs = await this.generateFfcsForTenant(
          client, 
          tenantId, 
          personas, 
          users,
          config.ffcsPerTenant
        );
        stats.ffcs += ffcs.length;

        // Generate FFC memberships
        const memberships = await this.generateFfcMemberships(
          client, 
          ffcs, 
          personas
        );
        stats.memberships += memberships.length;

        // Generate assets for each FFC
        for (const ffc of ffcs) {
          const assets = await this.generateAssetsForFfc(
            client,
            tenantId,
            ffc,
            personas,
            config.assetsPerFfc,
            config.scenario
          );
          stats.assets += assets.length;

          // Generate asset ownerships and permissions
          const { ownerships, permissions } = await this.generateAssetRelationships(
            client,
            assets,
            personas
          );
          stats.ownerships += ownerships.length;
          stats.permissions += permissions.length;
        }
      }

      await client.query('COMMIT');
      
      const endTime = Date.now();
      stats.executionTime = endTime - startTime;
      
      console.log('✅ Test data generation completed successfully!');
      console.log(`📈 Generated: ${stats.tenants} tenants, ${stats.personas} personas, ${stats.ffcs} FFCs, ${stats.assets} assets`);
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
   * Clean all test data
   */
  async cleanTestData(): Promise<void> {
    console.log('🧹 Cleaning test data...');
    
    const client = await this.pool.connect();
    
    try {
      await client.query('BEGIN');
      
      // Delete in reverse dependency order
      await client.query('DELETE FROM asset_permissions WHERE TRUE');
      await client.query('DELETE FROM asset_persona WHERE TRUE');
      await client.query('DELETE FROM assets WHERE TRUE');
      await client.query('DELETE FROM ffc_personas WHERE TRUE');
      await client.query('DELETE FROM fwd_family_circles WHERE TRUE');
      await client.query('DELETE FROM personas WHERE TRUE');
      await client.query('DELETE FROM users WHERE TRUE');
      await client.query('DELETE FROM plans WHERE TRUE');
      await client.query('DELETE FROM tenants WHERE TRUE');
      
      await client.query('COMMIT');
      console.log('✅ Test data cleaned successfully!');
      
    } catch (error) {
      await client.query('ROLLBACK');
      console.error('❌ Error cleaning test data:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  private async generateTenants(client: PoolClient, count: number): Promise<number[]> {
    const tenantIds: number[] = [];
    
    for (let i = 0; i < count; i++) {
      const tenantId = this.generateTenantId();
      const name = `${faker.company.name()} Family Trust`;
      const domain = `${faker.internet.domainWord()}.forwardinheritance.com`;
      
      await client.query(
        `INSERT INTO tenants (id, name, display_name, domain, is_active, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, NOW(), NOW())`,
        [tenantId, name, name, domain, true]
      );
      
      tenantIds.push(tenantId);
    }
    
    return tenantIds;
  }

  private async generateUsersForTenant(client: PoolClient, tenantId: number, count: number): Promise<string[]> {
    const userIds: string[] = [];
    
    for (let i = 0; i < count; i++) {
      const userId = this.generateUuid();
      const firstName = faker.person.firstName();
      const lastName = faker.person.lastName();
      
      await client.query(
        `INSERT INTO users (id, tenant_id, cognito_user_id, cognito_username, first_name, last_name, status, created_at, updated_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())`,
        [userId, tenantId, `${userId}-cognito`, `${firstName.toLowerCase()}${lastName.toLowerCase()}`, firstName, lastName, 'active']
      );
      
      userIds.push(userId);
    }
    
    return userIds;
  }

  private async generatePersonasForTenant(
    client: PoolClient,
    tenantId: number,
    count: number,
    language: 'en' | 'es' | 'mixed'
  ): Promise<TestPersona[]> {
    // Generate a mix of individual personas and family groups
    const familyGroupCount = Math.floor(count * 0.3); // 30% in family groups
    const individualCount = count - (familyGroupCount * 4); // Assume 4 per family group
    
    const personas: TestPersona[] = [];
    
    // Generate family groups
    for (let i = 0; i < familyGroupCount; i++) {
      const family = this.personaGenerator.generateFamilyGroup(4, tenantId, language);
      const familyMembers = [
        family.patriarch!,
        family.matriarch!,
        ...family.children.slice(0, 2)
      ];
      
      for (const persona of familyMembers) {
        await this.insertPersona(client, persona);
        personas.push(persona);
      }
    }
    
    // Generate individual personas
    const individuals = this.personaGenerator.generatePersonas(individualCount, tenantId, language);
    for (const persona of individuals) {
      await this.insertPersona(client, persona);
      personas.push(persona);
    }
    
    return personas;
  }

  private async insertPersona(client: PoolClient, persona: TestPersona): Promise<void> {
    const personaId = this.generateUuid();
    
    await client.query(
      `INSERT INTO personas (
        id, tenant_id, first_name, last_name, 
        date_of_birth, is_living, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())`,
      [
        personaId,
        persona.tenant_id,
        persona.first_name,
        persona.last_name,
        persona.date_of_birth,
        true, // is_living
        'active' // status
      ]
    );
    
    // Store the generated ID back in the persona object
    (persona as any).id = personaId;
  }

  private async generateFfcsForTenant(
    client: PoolClient,
    tenantId: number,
    personas: TestPersona[],
    users: string[],
    count: number
  ): Promise<TestFfc[]> {
    const ffcs: TestFfc[] = [];
    
    for (let i = 0; i < count; i++) {
      const creator = faker.helpers.arrayElement(personas);
      const ownerUser = faker.helpers.arrayElement(users);
      const ffc: TestFfc = {
        tenant_id: tenantId,
        name: this.generateFfcName(creator.last_name, creator.language_preference || 'en'),
        description: this.generateFfcDescription(creator.language_preference || 'en'),
        family_photo_url: faker.datatype.boolean(0.4) ? faker.image.avatar() : undefined,
        owner_user_id: ownerUser,
        status: 'active',
        created_at: faker.date.recent({ days: 180 }),
        updated_at: new Date()
      };
      
      const ffcId = await this.insertFfc(client, ffc);
      (ffc as any).id = ffcId;
      ffcs.push(ffc);
    }
    
    return ffcs;
  }

  private async insertFfc(client: PoolClient, ffc: TestFfc): Promise<string> {
    const ffcId = this.generateUuid();
    
    await client.query(
      `INSERT INTO fwd_family_circles (
        id, tenant_id, name, description, family_photo_url,
        owner_user_id, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        ffcId,
        ffc.tenant_id,
        ffc.name,
        ffc.description,
        ffc.family_photo_url,
        ffc.owner_user_id,
        ffc.status,
        ffc.created_at,
        ffc.updated_at
      ]
    );
    
    return ffcId;
  }

  private async generateFfcMemberships(
    client: PoolClient,
    ffcs: TestFfc[],
    personas: TestPersona[]
  ): Promise<TestFfcMembership[]> {
    const memberships: TestFfcMembership[] = [];
    
    for (const ffc of ffcs) {
      // Add creator as owner - use first persona as the owner
      const ownerPersona = personas[0];
      const creatorMembership = await this.insertFfcMembership(client, {
        tenant_id: 1,
        ffc_id: (ffc as any).id,
        persona_id: (ownerPersona as any).id,
        ffc_role: 'owner',
        joined_at: ffc.created_at,
        invited_at: ffc.created_at,
        is_active: true,
        created_at: ffc.created_at
      });
      memberships.push(creatorMembership);
      
      // Add 3-8 additional members
      const additionalMemberCount = faker.number.int({ min: 3, max: 8 });
      const availablePersonas = personas.filter(p => (p as any).id !== (ownerPersona as any).id);
      const selectedMembers = faker.helpers.arrayElements(availablePersonas, additionalMemberCount);
      
      for (const member of selectedMembers) {
        const membership = await this.insertFfcMembership(client, {
          tenant_id: 1,
          ffc_id: (ffc as any).id,
          persona_id: (member as any).id,
          ffc_role: faker.helpers.weightedArrayElement([
            { value: 'beneficiary', weight: 60 },
            { value: 'non_beneficiary', weight: 30 },
            { value: 'advisor', weight: 10 }
          ]),
          joined_at: faker.date.recent({ days: 30 }),
          invited_at: faker.date.between({ from: ffc.created_at, to: new Date() }),
          is_active: faker.helpers.weightedArrayElement([
            { value: true, weight: 85 },
            { value: false, weight: 15 }
          ]),
          created_at: faker.date.between({ from: ffc.created_at, to: new Date() })
        });
        memberships.push(membership);
      }
    }
    
    return memberships;
  }

  private async insertFfcMembership(client: PoolClient, membership: TestFfcMembership): Promise<TestFfcMembership> {
    const membershipId = this.generateUuid();
    
    await client.query(
      `INSERT INTO ffc_personas (
        id, tenant_id, ffc_id, persona_id, ffc_role, 
        joined_at, invited_at, is_active, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        membershipId,
        membership.tenant_id,
        membership.ffc_id,
        membership.persona_id,
        membership.ffc_role,
        membership.joined_at,
        membership.invited_at,
        membership.is_active,
        membership.created_at
      ]
    );
    
    return membership;
  }

  private async generateAssetsForFfc(
    client: PoolClient,
    tenantId: number,
    ffc: TestFfc,
    personas: TestPersona[],
    count: number,
    scenario: 'high_net_worth' | 'mass_affluent' | 'mixed'
  ): Promise<TestAsset[]> {
    // Generate simple assets that match the database structure
    const assets: TestAsset[] = [];
    
    for (let i = 0; i < count; i++) {
      const asset: TestAsset = {
        tenant_id: tenantId,
        category_id: await this.getRandomCategoryId(client),
        name: faker.finance.accountName(),
        description: faker.lorem.sentence(),
        estimated_value: faker.number.int({ min: 10000, max: 1000000 }),
        currency_code: 'USD',
        status: 'active',
        created_at: faker.date.recent({ days: 90 }),
        updated_at: new Date()
      };
      assets.push(asset);
    }
    
    const insertedAssets: TestAsset[] = [];
    
    for (const asset of assets) {
      const assetId = await this.insertAsset(client, asset);
      (asset as any).id = assetId;
      insertedAssets.push(asset);
    }
    
    return insertedAssets;
  }

  private async getRandomCategoryId(client: PoolClient): Promise<string> {
    const categoryResult = await client.query('SELECT id FROM asset_categories ORDER BY RANDOM() LIMIT 1');
    return categoryResult.rows[0]?.id;
  }

  private async insertAsset(client: PoolClient, asset: TestAsset): Promise<string> {
    const assetId = this.generateUuid();
    
    await client.query(
      `INSERT INTO assets (
        id, tenant_id, category_id, name, description,
        estimated_value, currency_code, status, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        assetId,
        asset.tenant_id,
        asset.category_id,
        asset.name,
        asset.description,
        asset.estimated_value,
        asset.currency_code,
        asset.status,
        asset.created_at,
        asset.updated_at
      ]
    );
    
    return assetId;
  }

  private async generateAssetRelationships(
    client: PoolClient,
    assets: TestAsset[],
    personas: TestPersona[]
  ): Promise<{ ownerships: TestAssetOwnership[], permissions: TestAssetPermission[] }> {
    const ownerships: TestAssetOwnership[] = [];
    const permissions: TestAssetPermission[] = [];
    
    for (const asset of assets) {
      // Generate ownership (1-3 owners per asset)
      const ownerCount = faker.number.int({ min: 1, max: 3 });
      const selectedOwners = faker.helpers.arrayElements(personas, ownerCount);
      
      // Generate percentages that add up to 100
      let remainingPercentage = 100;
      const percentages: number[] = [];
      
      for (let i = 0; i < selectedOwners.length; i++) {
        const isLastOwner = i === selectedOwners.length - 1;
        let percentage: number;
        
        if (isLastOwner) {
          percentage = remainingPercentage;
        } else {
          // Ensure each owner gets at least 5% and leave enough for remaining owners
          const minPercentage = 5;
          const maxPercentage = Math.max(minPercentage, remainingPercentage - (selectedOwners.length - i - 1) * minPercentage);
          percentage = faker.number.int({ min: minPercentage, max: maxPercentage });
          remainingPercentage -= percentage;
        }
        
        percentages.push(percentage);
      }
      
      for (let i = 0; i < selectedOwners.length; i++) {
        const owner = selectedOwners[i];
        
        const ownership: TestAssetOwnership = {
          tenant_id: 1,
          asset_id: (asset as any).id,
          persona_id: (owner as any).id,
          ownership_percentage: percentages[i],
          ownership_type: faker.helpers.weightedArrayElement([
            { value: 'owner', weight: 70 },
            { value: 'trustee', weight: 20 },
            { value: 'beneficiary', weight: 10 }
          ]),
          created_at: asset.created_at
        };
        
        await this.insertAssetOwnership(client, ownership);
        ownerships.push(ownership);
      }
      
      // Generate permissions (2-5 people with various permission levels)
      const permissionCount = faker.number.int({ min: 2, max: 5 });
      const selectedViewers = faker.helpers.arrayElements(personas, permissionCount);
      
      for (const viewer of selectedViewers) {
        const permission: TestAssetPermission = {
          tenant_id: 1,
          asset_id: (asset as any).id,
          persona_id: (viewer as any).id,
          permission_level: faker.helpers.weightedArrayElement([
            { value: 'read', weight: 60 },
            { value: 'edit', weight: 30 },
            { value: 'admin', weight: 10 }
          ]),
          granted_by_persona_id: (viewer as any).id, // Use viewer as grantor for simplicity
          granted_at: faker.date.between({ from: asset.created_at, to: new Date() }),
          created_at: faker.date.between({ from: asset.created_at, to: new Date() })
        };
        
        await this.insertAssetPermission(client, permission);
        permissions.push(permission);
      }
    }
    
    return { ownerships, permissions };
  }

  private async insertAssetOwnership(client: PoolClient, ownership: TestAssetOwnership): Promise<void> {
    const ownershipId = this.generateUuid();
    
    await client.query(
      `INSERT INTO asset_persona (
        id, tenant_id, asset_id, persona_id, ownership_percentage, ownership_type, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [
        ownershipId,
        ownership.tenant_id,
        ownership.asset_id,
        ownership.persona_id,
        ownership.ownership_percentage,
        ownership.ownership_type,
        ownership.created_at
      ]
    );
  }

  private async insertAssetPermission(client: PoolClient, permission: TestAssetPermission): Promise<void> {
    const permissionId = this.generateUuid();
    
    await client.query(
      `INSERT INTO asset_permissions (
        id, tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id, granted_at, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        permissionId,
        permission.tenant_id,
        permission.asset_id,
        permission.persona_id,
        permission.permission_level,
        permission.granted_by_persona_id,
        permission.granted_at,
        permission.created_at
      ]
    );
  }

  // Utility methods

  private generateTenantId(): number {
    return faker.number.int({ min: 1, max: 999999 });
  }

  private generateUuid(): string {
    return faker.string.uuid();
  }

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

  async close(): Promise<void> {
    await this.pool.end();
  }
}