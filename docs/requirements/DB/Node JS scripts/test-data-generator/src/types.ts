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
  tenant_id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  date_of_birth: Date;
  language_preference: 'en' | 'es';
  timezone: string;
  profile_picture_url?: string;
  created_at: Date;
  updated_at: Date;
}

export interface TestFfc {
  tenant_id: string;
  name: string;
  description?: string;
  family_picture_url?: string;
  created_by_persona_id: string;
  created_at: Date;
  updated_at: Date;
}

export interface TestAsset {
  tenant_id: string;
  ffc_id: string;
  category: AssetCategory;
  name: string;
  description?: string;
  estimated_value: number;
  currency: string;
  category_specific_data: Record<string, any>;
  created_by_persona_id: string;
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
  asset_id: string;
  persona_id: string;
  ownership_percentage: number;
  ownership_type: 'direct' | 'trust' | 'beneficiary';
  created_at: Date;
}

export interface TestAssetPermission {
  asset_id: string;
  persona_id: string;
  permission_level: 'read' | 'edit' | 'admin';
  granted_by_persona_id: string;
  created_at: Date;
}

export interface TestFfcMembership {
  ffc_id: string;
  persona_id: string;
  role: 'owner' | 'beneficiary' | 'non_beneficiary' | 'advisor';
  invited_by_persona_id: string;
  invitation_status: 'pending' | 'accepted' | 'declined';
  verified_at?: Date;
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