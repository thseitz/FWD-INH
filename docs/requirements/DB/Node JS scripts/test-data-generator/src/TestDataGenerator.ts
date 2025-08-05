import { Pool, PoolClient } from 'pg';
import { PersonaGenerator } from './generators/PersonaGenerator';
import { AssetGenerator } from './generators/AssetGenerator';
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
  private assetGenerator: AssetGenerator;

  constructor(dbConfig: DatabaseConfig) {
    this.pool = new Pool(dbConfig);
    this.personaGenerator = new PersonaGenerator();
    this.assetGenerator = new AssetGenerator();
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
      await client.query('DELETE FROM asset_ownerships WHERE TRUE');
      await client.query('DELETE FROM asset_documents WHERE TRUE');
      await client.query('DELETE FROM assets WHERE TRUE');
      await client.query('DELETE FROM ffc_memberships WHERE TRUE');
      await client.query('DELETE FROM ffcs WHERE TRUE');
      await client.query('DELETE FROM personas WHERE TRUE');
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

  private async generateTenants(client: PoolClient, count: number): Promise<string[]> {
    const tenantIds: string[] = [];
    
    for (let i = 0; i < count; i++) {
      const tenantId = this.generateTenantId();
      const name = `${faker.company.name()} Family Trust`;
      const domain = `${faker.internet.domainWord()}.forwardinheritance.com`;
      
      await client.query(
        `INSERT INTO tenants (id, name, domain, created_at, updated_at) 
         VALUES ($1, $2, $3, NOW(), NOW())`,
        [tenantId, name, domain]
      );
      
      tenantIds.push(tenantId);
    }
    
    return tenantIds;
  }

  private async generatePersonasForTenant(
    client: PoolClient,
    tenantId: string,
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
        id, tenant_id, first_name, last_name, email, phone, 
        date_of_birth, language_preference, timezone, profile_picture_url,
        created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      [
        personaId,
        persona.tenant_id,
        persona.first_name,
        persona.last_name,
        persona.email,
        persona.phone,
        persona.date_of_birth,
        persona.language_preference,
        persona.timezone,
        persona.profile_picture_url,
        persona.created_at,
        persona.updated_at
      ]
    );
    
    // Store the generated ID back in the persona object
    (persona as any).id = personaId;
  }

  private async generateFfcsForTenant(
    client: PoolClient,
    tenantId: string,
    personas: TestPersona[],
    count: number
  ): Promise<TestFfc[]> {
    const ffcs: TestFfc[] = [];
    
    for (let i = 0; i < count; i++) {
      const creator = faker.helpers.arrayElement(personas);
      const ffc: TestFfc = {
        tenant_id: tenantId,
        name: this.generateFfcName(creator.last_name, creator.language_preference),
        description: this.generateFfcDescription(creator.language_preference),
        family_picture_url: faker.datatype.boolean(0.4) ? faker.image.avatar() : undefined,
        created_by_persona_id: (creator as any).id,
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
      `INSERT INTO ffcs (
        id, tenant_id, name, description, family_picture_url,
        created_by_persona_id, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        ffcId,
        ffc.tenant_id,
        ffc.name,
        ffc.description,
        ffc.family_picture_url,
        ffc.created_by_persona_id,
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
      // Add creator as owner
      const creatorMembership = await this.insertFfcMembership(client, {
        ffc_id: (ffc as any).id,
        persona_id: ffc.created_by_persona_id,
        role: 'owner',
        invited_by_persona_id: ffc.created_by_persona_id,
        invitation_status: 'accepted',
        verified_at: ffc.created_at,
        created_at: ffc.created_at
      });
      memberships.push(creatorMembership);
      
      // Add 3-8 additional members
      const additionalMemberCount = faker.number.int({ min: 3, max: 8 });
      const availablePersonas = personas.filter(p => (p as any).id !== ffc.created_by_persona_id);
      const selectedMembers = faker.helpers.arrayElements(availablePersonas, additionalMemberCount);
      
      for (const member of selectedMembers) {
        const membership = await this.insertFfcMembership(client, {
          ffc_id: (ffc as any).id,
          persona_id: (member as any).id,
          role: faker.helpers.weightedArrayElement([
            { value: 'beneficiary', weight: 60 },
            { value: 'non_beneficiary', weight: 30 },
            { value: 'advisor', weight: 10 }
          ]),
          invited_by_persona_id: ffc.created_by_persona_id,
          invitation_status: faker.helpers.weightedArrayElement([
            { value: 'accepted', weight: 85 },
            { value: 'pending', weight: 15 }
          ]),
          verified_at: faker.date.recent({ days: 30 }),
          created_at: faker.date.between({ from: ffc.created_at, to: new Date() })
        });
        memberships.push(membership);
      }
    }
    
    return memberships;
  }

  private async insertFfcMembership(client: PoolClient, membership: TestFfcMembership): Promise<TestFfcMembership> {
    await client.query(
      `INSERT INTO ffc_memberships (
        ffc_id, persona_id, role, invited_by_persona_id,
        invitation_status, verified_at, created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [
        membership.ffc_id,
        membership.persona_id,
        membership.role,
        membership.invited_by_persona_id,
        membership.invitation_status,
        membership.verified_at,
        membership.created_at
      ]
    );
    
    return membership;
  }

  private async generateAssetsForFfc(
    client: PoolClient,
    tenantId: string,
    ffc: TestFfc,
    personas: TestPersona[],
    count: number,
    scenario: 'high_net_worth' | 'mass_affluent' | 'mixed'
  ): Promise<TestAsset[]> {
    const assets = this.assetGenerator.generateAssets(
      count,
      tenantId,
      (ffc as any).id,
      ffc.created_by_persona_id,
      scenario
    );
    
    const insertedAssets: TestAsset[] = [];
    
    for (const asset of assets) {
      const assetId = await this.insertAsset(client, asset);
      (asset as any).id = assetId;
      insertedAssets.push(asset);
    }
    
    return insertedAssets;
  }

  private async insertAsset(client: PoolClient, asset: TestAsset): Promise<string> {
    const assetId = this.generateUuid();
    
    await client.query(
      `INSERT INTO assets (
        id, tenant_id, ffc_id, category, name, description,
        estimated_value, currency, category_specific_data,
        created_by_persona_id, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
      [
        assetId,
        asset.tenant_id,
        asset.ffc_id,
        asset.category,
        asset.name,
        asset.description,
        asset.estimated_value,
        asset.currency,
        JSON.stringify(asset.category_specific_data),
        asset.created_by_persona_id,
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
      const totalPercentage = 100;
      
      for (let i = 0; i < selectedOwners.length; i++) {
        const owner = selectedOwners[i];
        const isLastOwner = i === selectedOwners.length - 1;
        const percentage = isLastOwner 
          ? totalPercentage - ownerships.filter(o => o.asset_id === (asset as any).id).reduce((sum, o) => sum + o.ownership_percentage, 0)
          : faker.number.int({ min: 10, max: 60 });
        
        const ownership: TestAssetOwnership = {
          asset_id: (asset as any).id,
          persona_id: (owner as any).id,
          ownership_percentage: percentage,
          ownership_type: faker.helpers.weightedArrayElement([
            { value: 'direct', weight: 70 },
            { value: 'trust', weight: 20 },
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
          asset_id: (asset as any).id,
          persona_id: (viewer as any).id,
          permission_level: faker.helpers.weightedArrayElement([
            { value: 'read', weight: 60 },
            { value: 'edit', weight: 30 },
            { value: 'admin', weight: 10 }
          ]),
          granted_by_persona_id: asset.created_by_persona_id,
          created_at: faker.date.between({ from: asset.created_at, to: new Date() })
        };
        
        await this.insertAssetPermission(client, permission);
        permissions.push(permission);
      }
    }
    
    return { ownerships, permissions };
  }

  private async insertAssetOwnership(client: PoolClient, ownership: TestAssetOwnership): Promise<void> {
    await client.query(
      `INSERT INTO asset_ownerships (
        asset_id, persona_id, ownership_percentage, ownership_type, created_at
      ) VALUES ($1, $2, $3, $4, $5)`,
      [
        ownership.asset_id,
        ownership.persona_id,
        ownership.ownership_percentage,
        ownership.ownership_type,
        ownership.created_at
      ]
    );
  }

  private async insertAssetPermission(client: PoolClient, permission: TestAssetPermission): Promise<void> {
    await client.query(
      `INSERT INTO asset_permissions (
        asset_id, persona_id, permission_level, granted_by_persona_id, created_at
      ) VALUES ($1, $2, $3, $4, $5)`,
      [
        permission.asset_id,
        permission.persona_id,
        permission.permission_level,
        permission.granted_by_persona_id,
        permission.created_at
      ]
    );
  }

  // Utility methods

  private generateTenantId(): string {
    return `tenant_${faker.string.alphanumeric(8)}`;
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