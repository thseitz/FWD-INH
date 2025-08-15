// Forward Inheritance Test Data Types

export interface GenerationConfig {
  tenants: number;
  personasPerTenant: number;
  ffcsPerTenant: number;
  assetsPerFfc: number;
  language: 'en' | 'es' | 'mixed';
  scenario: 'high_net_worth' | 'mass_affluent' | 'mixed';
  includePii: boolean;
}

export interface DatabaseConfig {
  host: string;
  port: number;
  database: string;
  user: string;
  password: string;
}

export interface TestPersona {
  tenant_id: number;
  first_name: string;
  last_name: string;
  date_of_birth: Date;
  is_living: boolean;
  status: string;
  language_preference?: 'en' | 'es'; // Not in DB but used for generation
  created_at: Date;
  updated_at: Date;
}

export interface TestFfc {
  tenant_id: number;
  name: string;
  description?: string;
  family_photo_url?: string;
  owner_user_id: string;
  status: string;
  created_at: Date;
  updated_at: Date;
}

export interface TestAsset {
  tenant_id: number;
  category_id: string;
  name: string;
  description?: string;
  estimated_value: number;
  currency_code: string;
  status: string;
  created_at: Date;
  updated_at: Date;
}

export type AssetCategory = 
  | 'personal_directives'
  | 'trust'
  | 'will'
  | 'personal_property'
  | 'operational_property'
  | 'inventory'
  | 'real_estate'
  | 'life_insurance'
  | 'financial_accounts'
  | 'recurring_income'
  | 'digital_assets'
  | 'ownership_interests'
  | 'loans';

export interface TestAssetOwnership {
  tenant_id: number;
  asset_id: string;
  persona_id: string;
  ownership_percentage: number;
  ownership_type: string;
  created_at: Date;
}

export interface TestAssetPermission {
  tenant_id: number;
  asset_id: string;
  persona_id: string;
  permission_level: string;
  granted_by_persona_id: string;
  granted_at: Date;
  created_at: Date;
}

export interface TestFfcMembership {
  tenant_id: number;
  ffc_id: string;
  persona_id: string;
  ffc_role: string;
  joined_at?: Date;
  invited_at: Date;
  is_active: boolean;
  created_at: Date;
}

export interface GenerationStats {
  tenants: number;
  personas: number;
  ffcs: number;
  assets: number;
  ownerships: number;
  permissions: number;
  memberships: number;
  executionTime: number;
}