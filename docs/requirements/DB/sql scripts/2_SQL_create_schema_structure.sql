-- ================================================================
-- Forward Inheritance Platform - Schema Structure (Phase 1)
-- Creates all ENUM types and tables WITHOUT foreign key constraints
-- This allows tables to be created in any order without dependency issues
-- ================================================================

-- ================================================================
-- ENUM DEFINITIONS
-- ================================================================

-- General status enum used across multiple tables
CREATE TYPE status_enum AS ENUM ('active', 'inactive', 'pending', 'suspended', 'deleted');

-- User-specific status enum
CREATE TYPE user_status_enum AS ENUM ('pending_verification', 'active', 'inactive', 'suspended', 'locked');

-- Media storage enums
CREATE TYPE processing_status_enum AS ENUM ('uploaded', 'processing', 'ready', 'failed');
CREATE TYPE retention_policy_enum AS ENUM ('permanent', '7_years', '5_years', '3_years', '1_year', '6_months');

-- Document enums
CREATE TYPE document_type_enum AS ENUM ('will', 'trust', 'insurance_policy', 'deed', 'contract', 'statement', 'certificate', 'directive', 'other');
CREATE TYPE document_category_enum AS ENUM ('legal', 'financial', 'personal', 'medical', 'business', 'tax', 'insurance');

-- Personal demographics enums
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'non_binary', 'prefer_not_to_say', 'other');
CREATE TYPE marital_status_enum AS ENUM ('single', 'married', 'divorced', 'widowed', 'separated', 'domestic_partnership');

-- Contact information enums
CREATE TYPE phone_type_enum AS ENUM ('mobile', 'landline', 'voip', 'toll_free', 'fax');
CREATE TYPE email_type_enum AS ENUM ('personal', 'business', 'temporary', 'alias', 'shared');
CREATE TYPE address_type_enum AS ENUM ('residential', 'business', 'mailing', 'billing', 'property', 'temporary');
CREATE TYPE social_media_platform_enum AS ENUM ('facebook', 'twitter', 'linkedin', 'instagram', 'youtube', 'tiktok', 'snapchat', 'other');

-- Usage/Relationship enums
CREATE TYPE entity_type_enum AS ENUM ('user', 'persona', 'asset');
CREATE TYPE email_usage_type_enum AS ENUM ('primary', 'work', 'personal', 'backup', 'billing', 'notifications');
CREATE TYPE phone_usage_type_enum AS ENUM ('primary', 'work', 'home', 'mobile', 'emergency', 'fax');
CREATE TYPE address_usage_type_enum AS ENUM ('primary', 'mailing', 'billing', 'property', 'work', 'emergency');
CREATE TYPE social_media_usage_type_enum AS ENUM ('personal', 'professional', 'business', 'public', 'private');
CREATE TYPE contact_time_enum AS ENUM ('morning', 'afternoon', 'evening', 'anytime', 'business_hours');

-- Family relationship enum
CREATE TYPE family_relationship_enum AS ENUM ('spouse', 'child', 'parent', 'sibling', 'grandparent', 'grandchild', 'aunt_uncle', 'cousin', 'in_law', 'step_family', 'other');

-- FFC role enum
CREATE TYPE ffc_role_enum AS ENUM ('owner', 'beneficiary', 'non_beneficiary', 'advisor');

-- Security/RBAC enums
CREATE TYPE permission_category_enum AS ENUM ('asset', 'user', 'admin', 'report', 'document', 'ffc', 'system');

-- Audit entity type enum (extended for subscriptions)
CREATE TYPE audit_entity_type_enum AS ENUM ('user', 'persona', 'asset', 'document', 'ffc', 'permission', 'system', 'subscription', 'payment', 'service_purchase', 'payment_method');

-- Contact entity type enum
CREATE TYPE contact_entity_type_enum AS ENUM ('advisor', 'company', 'institution', 'attorney', 'accountant', 'financial_advisor', 'insurance_agent', 'other');

-- Asset ownership type enum
CREATE TYPE ownership_type_enum AS ENUM ('owner', 'beneficiary', 'trustee', 'executor');

-- Invitation system enum
CREATE TYPE invitation_status_enum AS ENUM ('sent', 'phone_verified', 'accepted', 'approved', 'expired', 'cancelled', 'declined');

-- Personal directive enums
CREATE TYPE directive_type_enum AS ENUM (
    'power_of_attorney', 
    'healthcare_directive', 
    'living_will', 
    'hipaa_authorization', 
    'guardianship_designation',
    'family_directive'
);

CREATE TYPE directive_status_enum AS ENUM (
    'draft', 
    'executed', 
    'active', 
    'suspended', 
    'revoked', 
    'expired', 
    'superseded'
);

-- Trust enums
CREATE TYPE trust_type_enum AS ENUM (
    'revocable', 
    'irrevocable', 
    'living', 
    'testamentary',
    'charitable',
    'special_needs',
    'generation_skipping',
    'asset_protection'
);

CREATE TYPE trust_role_enum AS ENUM (
    'grantor',
    'trustee',
    'successor_trustee',
    'beneficiary',
    'trust_protector',
    'trust_advisor'
);

-- Trust administration enums
CREATE TYPE trust_administration_type_enum AS ENUM (
    'distribution',
    'investment',
    'accounting',
    'tax_filing',
    'beneficiary_communication',
    'compliance_review'
);

-- Asset category enum
CREATE TYPE asset_type_enum AS ENUM (
    'personal_directives',
    'trust',
    'will',
    'personal_property',
    'operational_property',
    'inventory',
    'real_estate',
    'life_insurance',
    'financial_accounts',
    'recurring_income',
    'digital_assets',
    'ownership_interests',
    'loans'
);

-- Personal property related enums
CREATE TYPE personal_property_type_enum AS ENUM (
    'jewelry',
    'precious_metals',
    'collectibles',
    'art',
    'furniture',
    'pets_animals',
    'memorabilia',
    'other'
);

CREATE TYPE pet_type_enum AS ENUM ('dog', 'cat', 'bird', 'reptile', 'fish', 'horse', 'livestock', 'exotic', 'other');
CREATE TYPE pet_care_status_enum AS ENUM ('self_care', 'needs_basic_care', 'needs_special_care', 'needs_medical_care');

-- Operational property enums
CREATE TYPE operational_property_type_enum AS ENUM (
    'vehicle',
    'boat_yacht',
    'aircraft',
    'equipment_machinery',
    'appliances_gear',
    'recreational_vehicle',
    'other'
);

CREATE TYPE vehicle_type_enum AS ENUM ('car', 'truck', 'suv', 'motorcycle', 'rv', 'trailer', 'other');
CREATE TYPE vehicle_condition_enum AS ENUM ('excellent', 'good', 'fair', 'poor', 'non_operational');

-- Real estate enums
CREATE TYPE property_type_enum AS ENUM (
    'single_family',
    'multi_family',
    'condo',
    'townhouse',
    'commercial',
    'land',
    'farm_ranch',
    'vacation_property',
    'other'
);

CREATE TYPE property_ownership_enum AS ENUM (
    'sole_ownership',
    'joint_tenancy',
    'tenancy_in_common',
    'community_property',
    'trust_owned',
    'llc_owned'
);

CREATE TYPE property_use_enum AS ENUM ('primary_residence', 'rental', 'vacation', 'commercial', 'investment', 'vacant');

-- Financial account enums
CREATE TYPE account_type_enum AS ENUM (
    'checking',
    'savings',
    'investment',
    'retirement_401k',
    'retirement_ira',
    'retirement_roth',
    'retirement_pension',
    'college_529',
    'college_coverdell',
    'hsa',
    'trust_account',
    'business_account',
    'cryptocurrency'
);

CREATE TYPE investment_risk_profile_enum AS ENUM ('conservative', 'moderate', 'aggressive', 'speculative');

-- Income and payment enums
CREATE TYPE income_type_enum AS ENUM (
    'royalty',
    'pension',
    'social_security',
    'annuity',
    'rental_income',
    'dividend',
    'trust_distribution',
    'business_income',
    'other'
);

CREATE TYPE payment_frequency_enum AS ENUM ('weekly', 'bi_weekly', 'monthly', 'quarterly', 'semi_annual', 'annual', 'irregular');

-- Digital asset enums
CREATE TYPE digital_asset_type_enum AS ENUM (
    'domain_name',
    'website',
    'social_media_account',
    'digital_content',
    'cryptocurrency',
    'nft',
    'online_business',
    'intellectual_property',
    'software_license',
    'cloud_storage',
    'email_account',
    'other'
);

CREATE TYPE ip_type_enum AS ENUM ('patent', 'trademark', 'copyright', 'trade_secret');

-- Business and ownership enums
CREATE TYPE business_entity_type_enum AS ENUM (
    'sole_proprietorship',
    'partnership',
    'llc',
    'corporation',
    's_corp',
    'c_corp',
    'non_profit',
    'trust',
    'other'
);

CREATE TYPE ownership_interest_type_enum AS ENUM (
    'stock',
    'membership_interest',
    'partnership_interest',
    'beneficial_interest',
    'option',
    'warrant',
    'convertible_note'
);

-- Loan enums
CREATE TYPE loan_type_enum AS ENUM (
    'mortgage',
    'heloc',
    'personal',
    'business',
    'auto',
    'student',
    'family_loan',
    'hard_money',
    'other'
);

CREATE TYPE loan_status_enum AS ENUM ('active', 'paid_off', 'defaulted', 'in_forbearance', 'refinanced');
CREATE TYPE interest_type_enum AS ENUM ('fixed', 'variable', 'hybrid');

-- Audit and logging enums
CREATE TYPE audit_action_enum AS ENUM (
    'create',
    'read',
    'update',
    'delete',
    'login',
    'logout',
    'export',
    'share',
    'permission_change',
    'status_change'
);

-- PII detection enums
CREATE TYPE pii_type_enum AS ENUM (
    'ssn',
    'credit_card',
    'bank_account',
    'drivers_license',
    'passport',
    'medical_record',
    'tax_id',
    'other'
);

CREATE TYPE pii_risk_level_enum AS ENUM ('low', 'medium', 'high', 'critical');

-- Translation and language enums
CREATE TYPE language_code_enum AS ENUM ('en', 'es', 'fr', 'de', 'pt', 'zh', 'ja', 'ko', 'ar', 'hi', 'ru');
CREATE TYPE translation_status_enum AS ENUM ('pending', 'in_progress', 'completed', 'approved', 'rejected');

-- Integration enums
CREATE TYPE integration_status_enum AS ENUM ('connected', 'disconnected', 'error', 'pending', 'expired');
CREATE TYPE sync_status_enum AS ENUM ('pending', 'in_progress', 'completed', 'failed', 'partial');
CREATE TYPE webhook_status_enum AS ENUM ('pending', 'delivered', 'failed', 'retrying');

-- ================================================================
-- TABLE DEFINITIONS (Without Foreign Key Constraints)
-- ================================================================

-- Table 1: tenants
-- Purpose: Multi-tenancy foundation - isolates data between different organizations
CREATE TABLE tenants (
    id INTEGER PRIMARY KEY,
    
    -- Tenant identification
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    domain TEXT,
    
    -- Branding
    logo_url TEXT,
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    
    -- Configuration
    settings JSONB DEFAULT '{}',
    feature_flags JSONB DEFAULT '{}',
    
    -- System fields
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_primary_color CHECK (primary_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT valid_secondary_color CHECK (secondary_color ~ '^#[0-9A-Fa-f]{6}$')
);

-- Table 2: media_storage
-- Purpose: Centralized storage for all uploaded files and documents
CREATE TABLE media_storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- File identification
    file_name TEXT NOT NULL,
    original_file_name TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    
    -- Storage details
    storage_provider VARCHAR(50) NOT NULL DEFAULT 'aws_s3',
    storage_bucket TEXT NOT NULL,
    storage_key TEXT NOT NULL,
    storage_region VARCHAR(50),
    cdn_url TEXT,
    
    -- File metadata
    checksum VARCHAR(64),
    encryption_key_id TEXT,
    is_encrypted BOOLEAN DEFAULT true,
    
    -- Processing
    processing_status processing_status_enum DEFAULT 'uploaded',
    processing_error TEXT,
    thumbnail_url TEXT,
    
    -- Content analysis
    has_pii BOOLEAN DEFAULT false,
    pii_types TEXT[],
    content_classification VARCHAR(50),
    
    -- Lifecycle
    retention_policy retention_policy_enum DEFAULT '7_years',
    retention_until DATE,
    is_archived BOOLEAN DEFAULT false,
    archived_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit
    uploaded_by UUID NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_file_size CHECK (file_size_bytes > 0),
    CONSTRAINT valid_mime_type CHECK (mime_type != '')
);

-- Table 3: document_metadata
-- Purpose: Additional metadata for documents stored in media_storage
CREATE TABLE document_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    media_storage_id UUID NOT NULL,
    
    -- Document classification
    document_type document_type_enum NOT NULL,
    document_category document_category_enum NOT NULL,
    
    -- Document details
    title TEXT NOT NULL,
    description TEXT,
    document_date DATE,
    expiration_date DATE,
    
    -- Document attributes
    is_original BOOLEAN DEFAULT true,
    is_certified_copy BOOLEAN DEFAULT false,
    certification_details TEXT,
    
    -- Legal metadata
    notarized BOOLEAN DEFAULT false,
    notary_details JSONB,
    witnessed BOOLEAN DEFAULT false,
    witness_details JSONB,
    
    -- Searchable content
    extracted_text TEXT,
    ocr_processed BOOLEAN DEFAULT false,
    searchable_content TSVECTOR,
    
    -- Tags and categorization
    tags TEXT[],
    custom_metadata JSONB DEFAULT '{}',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_title CHECK (title != '')
);

-- Table 4: users
-- Purpose: Core user authentication and profile information
-- UPDATED: Integrated with AWS Cognito for authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Cognito integration (replaces password fields)
    cognito_user_id TEXT UNIQUE NOT NULL, -- Cognito sub/user ID
    cognito_username TEXT UNIQUE, -- Cognito username if different from email
    
    -- Normalized contact references
    primary_email_id UUID,
    primary_phone_id UUID,
    
    -- Email/Phone verification status (managed by Cognito but cached here)
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    phone_verified BOOLEAN DEFAULT FALSE,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Account metadata (no passwords - handled by Cognito)
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,
    
    -- Profile Information
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    display_name TEXT,
    profile_picture_url TEXT,
    
    -- Preferences
    preferred_language CHAR(2) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    
    -- System Fields
    status user_status_enum NOT NULL DEFAULT 'pending_verification',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 5: personas
-- Purpose: Business identity layer representing family members (living or deceased)
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    user_id UUID, -- NULL for deceased or non-user personas
    
    -- Personal identification
    first_name TEXT NOT NULL,
    middle_name TEXT,
    last_name TEXT NOT NULL,
    suffix TEXT,
    nickname TEXT,
    
    -- Demographics
    date_of_birth DATE,
    date_of_death DATE,
    place_of_birth TEXT,
    gender gender_enum,
    marital_status marital_status_enum,
    
    -- Documentation
    ssn_last_four VARCHAR(4),
    has_full_ssn_on_file BOOLEAN DEFAULT FALSE,
    drivers_license_state VARCHAR(2),
    drivers_license_number_last_four VARCHAR(4),
    
    -- Professional information
    occupation TEXT,
    employer TEXT,
    
    -- Profile
    profile_photo_url TEXT,
    bio TEXT,
    
    -- System fields
    is_living BOOLEAN NOT NULL DEFAULT TRUE,
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_dates CHECK (date_of_death IS NULL OR date_of_death > date_of_birth),
    CONSTRAINT valid_ssn_format CHECK (ssn_last_four ~ '^[0-9]{4}$' OR ssn_last_four IS NULL),
    CONSTRAINT valid_living_status CHECK (
        (is_living = FALSE AND date_of_death IS NOT NULL) OR
        (is_living = TRUE AND date_of_death IS NULL)
    )
);

-- Table 6: fwd_family_circles
-- Purpose: Family groups that organize personas and assets
CREATE TABLE fwd_family_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- FFC identification
    name TEXT NOT NULL,
    description TEXT,
    
    -- Owner must be a user (has login credentials)
    owner_user_id UUID NOT NULL,
    
    -- FFC metadata
    family_photo_url TEXT,
    established_date DATE DEFAULT CURRENT_DATE,
    
    -- Settings
    settings JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    
    -- System fields
    is_active BOOLEAN DEFAULT TRUE,
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_ffc_name CHECK (name != '')
);

-- Table 7: phone_number
-- Purpose: Centralized phone number storage with validation
CREATE TABLE phone_number (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Phone number components
    country_code VARCHAR(5) NOT NULL DEFAULT '+1',
    phone_number VARCHAR(20) NOT NULL,
    extension VARCHAR(10),
    
    -- Phone metadata
    phone_type phone_type_enum,
    is_primary BOOLEAN DEFAULT FALSE,
    can_receive_sms BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Carrier information
    carrier_name TEXT,
    is_mobile BOOLEAN,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_phone_format CHECK (phone_number ~ '^[0-9]{10,15}$'),
    CONSTRAINT phones_valid_country_code CHECK (country_code ~ '^\+[0-9]{1,4}$')
);

-- Table 8: email_address
-- Purpose: Centralized email address storage with validation
CREATE TABLE email_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Email details
    email_address TEXT NOT NULL,
    domain TEXT, -- Extracted domain part
    
    -- Email metadata
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    email_type email_type_enum,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Table 9: address
-- Purpose: Normalized physical address storage
CREATE TABLE address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Address components
    address_line_1 TEXT NOT NULL,
    address_line_2 TEXT,
    city TEXT NOT NULL,
    state_province TEXT NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(2) NOT NULL DEFAULT 'US',
    
    -- Address metadata
    address_type address_type_enum,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Geocoding
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    geocoding_accuracy VARCHAR(50),
    
    -- Validation
    is_validated BOOLEAN DEFAULT FALSE,
    validation_source VARCHAR(50),
    validated_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT addresses_valid_country_code CHECK (country ~ '^[A-Z]{2}$'),
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- Table 10: social_media
-- Purpose: Social media account information
CREATE TABLE social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Platform details
    platform social_media_platform_enum NOT NULL,
    platform_user_id TEXT,
    username TEXT NOT NULL,
    profile_url TEXT,
    
    -- Account metadata
    display_name TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_business_account BOOLEAN DEFAULT FALSE,
    follower_count INTEGER,
    
    -- Privacy settings
    is_public BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_username CHECK (username != ''),
    CONSTRAINT valid_follower_count CHECK (follower_count >= 0 OR follower_count IS NULL)
);

-- Table 11: usage_email
-- Purpose: Links email addresses to entities (users, personas, assets) with usage context
CREATE TABLE usage_email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Entity reference (polymorphic)
    entity_type entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Email reference
    email_id UUID NOT NULL,
    
    -- Usage details
    usage_type email_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    preferred_contact_time contact_time_enum,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint for entity-email combination
    CONSTRAINT usage_email_entity_email_unique UNIQUE (entity_type, entity_id, email_id)
);

-- Table 12: usage_phone
-- Purpose: Links phone numbers to entities with usage context
CREATE TABLE usage_phone (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Entity reference (polymorphic)
    entity_type entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Phone reference
    phone_id UUID NOT NULL,
    
    -- Usage details
    usage_type phone_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    preferred_contact_time contact_time_enum,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint for entity-phone combination
    CONSTRAINT usage_phone_entity_phone_unique UNIQUE (entity_type, entity_id, phone_id)
);

-- Table 13: usage_address
-- Purpose: Links addresses to entities with usage context
CREATE TABLE usage_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Entity reference (polymorphic)
    entity_type entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Address reference
    address_id UUID NOT NULL,
    
    -- Usage details
    usage_type address_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Validity period
    effective_date DATE,
    end_date DATE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT ffc_members_valid_date_range CHECK (end_date IS NULL OR end_date > effective_date)
);

-- Table 14: usage_social_media
-- Purpose: Links social media accounts to entities with usage context
CREATE TABLE usage_social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Entity reference (polymorphic)
    entity_type entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    
    -- Social media reference
    social_media_id UUID NOT NULL,
    
    -- Usage details
    usage_type social_media_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Access details
    has_login_credentials BOOLEAN DEFAULT FALSE,
    recovery_email_id UUID,
    recovery_phone_id UUID,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 15: contact_info
-- Purpose: External contacts (advisors, companies, institutions)
CREATE TABLE contact_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Contact identification
    entity_type contact_entity_type_enum NOT NULL,
    company_name TEXT,
    contact_name TEXT,
    title TEXT,
    
    -- Contact references
    primary_email_id UUID,
    primary_phone_id UUID,
    primary_address_id UUID,
    
    -- Additional info
    website TEXT,
    notes TEXT,
    
    -- Professional details
    license_number TEXT,
    license_state VARCHAR(2),
    specialties TEXT[],
    
    -- System fields
    is_preferred BOOLEAN DEFAULT FALSE,
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT must_have_name CHECK (company_name IS NOT NULL OR contact_name IS NOT NULL)
);

-- Table 16: ffc_personas
-- Purpose: Links personas to FFCs with their role
CREATE TABLE ffc_personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Relationships
    ffc_id UUID NOT NULL,
    persona_id UUID NOT NULL,
    
    -- Role and relationship
    ffc_role ffc_role_enum NOT NULL,
    family_relationship family_relationship_enum,
    relationship_details TEXT,
    
    -- Permissions and access
    can_view_all_assets BOOLEAN DEFAULT FALSE,
    can_manage_assets BOOLEAN DEFAULT FALSE,
    custom_permissions JSONB DEFAULT '{}',
    
    -- Status
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    invited_at TIMESTAMP WITH TIME ZONE,
    invitation_accepted_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_persona_per_ffc UNIQUE (ffc_id, persona_id)
);

-- Table 17: user_roles
-- Purpose: Define roles for RBAC system
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Role definition
    name TEXT NOT NULL,
    description TEXT,
    
    -- Role metadata
    is_system_role BOOLEAN DEFAULT FALSE,
    is_assignable BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 100,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_role_name_per_tenant UNIQUE (tenant_id, name)
);

-- Table 18: user_permissions
-- Purpose: Define granular permissions
CREATE TABLE user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Permission definition
    name TEXT NOT NULL,
    category permission_category_enum NOT NULL,
    description TEXT,
    
    -- Permission metadata
    resource TEXT,
    action VARCHAR(50) NOT NULL,
    conditions JSONB DEFAULT '{}',
    
    -- System fields
    is_system_permission BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_permission_per_tenant UNIQUE (tenant_id, category, resource, action)
);

-- Table 19: role_permissions
-- Purpose: Link roles to permissions
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    
    -- Grant details
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    granted_by UUID,
    
    -- Constraints
    CONSTRAINT unique_permission_per_role UNIQUE (role_id, permission_id)
);

-- Table 20: user_role_assignments
-- Purpose: Assign roles to users with optional FFC scope
CREATE TABLE user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    ffc_id UUID, -- NULL for platform_admin
    
    -- Assignment details
    assigned_by UUID NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Assignment metadata
    assignment_reason TEXT,
    conditions JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by UUID,
    revocation_reason TEXT,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 21: ffc_invitations
-- Purpose: Manage invitations to join FFCs
CREATE TABLE ffc_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Invitation details
    ffc_id UUID NOT NULL,
    inviter_user_id UUID NOT NULL,
    invitee_email_id UUID NOT NULL,
    invitee_phone_id UUID NOT NULL,
    invitee_name TEXT NOT NULL,
    proposed_role ffc_role_enum NOT NULL DEFAULT 'beneficiary',
    
    -- Invitation message
    personal_message TEXT,
    
    -- Verification
    email_verification_code VARCHAR(6),
    email_verification_attempts INTEGER DEFAULT 0,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    
    phone_verification_code VARCHAR(6),
    phone_verification_attempts INTEGER DEFAULT 0,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Status tracking
    status invitation_status_enum NOT NULL DEFAULT 'sent',
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by_user_id UUID,
    declined_at TIMESTAMP WITH TIME ZONE,
    declined_reason TEXT,
    
    -- Expiration
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days'),
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_verification_codes CHECK (
        email_verification_code ~ '^[0-9]{6}$' AND
        phone_verification_code ~ '^[0-9]{6}$'
    )
);

-- Table 22: invitation_verification_attempts
-- Purpose: Track verification attempts for security
CREATE TABLE invitation_verification_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invitation_id UUID NOT NULL,
    
    -- Attempt details
    verification_type VARCHAR(10) NOT NULL CHECK (verification_type IN ('email', 'phone')),
    attempted_code VARCHAR(6),
    ip_address INET,
    user_agent TEXT,
    
    -- Result
    was_successful BOOLEAN NOT NULL DEFAULT FALSE,
    failure_reason TEXT,
    
    -- Tracking
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Phone specific
    phone_id UUID NOT NULL,
    
    -- Multi-tenancy and audit
    tenant_id INTEGER NOT NULL
);

-- Table 23: asset_categories
-- Purpose: Define the types of assets that can be tracked
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Category definition
    name TEXT NOT NULL UNIQUE,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    
    -- Hierarchy
    parent_category_id UUID,
    sort_order INTEGER DEFAULT 0,
    
    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    requires_valuation BOOLEAN DEFAULT TRUE,
    requires_documentation BOOLEAN DEFAULT FALSE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 24: assets
-- Purpose: Core asset tracking - assets are owned by personas through asset_persona table
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Asset identification
    category_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    
    -- Valuation
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    last_valued_date DATE,
    
    -- Metadata
    tags JSONB DEFAULT '[]',
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_currency CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT valid_values CHECK (
        (estimated_value >= 0 OR estimated_value IS NULL)
    )
);

-- Table 25: asset_persona
-- Purpose: Link assets to personas with ownership details
CREATE TABLE asset_persona (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Relationships
    asset_id UUID NOT NULL,
    persona_id UUID NOT NULL,
    
    -- Ownership details
    ownership_type ownership_type_enum NOT NULL,
    ownership_percentage DECIMAL(5, 2),
    
    -- Legal details
    legal_title TEXT,
    transfer_on_death_to_persona_id UUID,
    
    -- Documentation
    ownership_document_id UUID,
    
    -- Status
    is_primary BOOLEAN DEFAULT FALSE,
    effective_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_percentage CHECK (ownership_percentage BETWEEN 0 AND 100),
    CONSTRAINT asset_personas_valid_date_range CHECK (end_date IS NULL OR end_date > effective_date)
);

-- Table 25.1: asset_permissions
-- Purpose: Simple asset-level permissions for personas
CREATE TABLE asset_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    asset_id UUID NOT NULL,
    persona_id UUID NOT NULL,
    permission_level VARCHAR(20) NOT NULL CHECK (permission_level IN ('read', 'edit', 'admin')),
    granted_by_persona_id UUID,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_asset_persona_permission UNIQUE (asset_id, persona_id)
);

-- Table 26: personal_directives
-- Purpose: Store healthcare directives, POAs, and other personal directives
CREATE TABLE personal_directives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Directive details
    directive_type directive_type_enum NOT NULL,
    directive_subtype TEXT,
    
    -- Principal/Grantor
    principal_persona_id UUID NOT NULL,
    
    -- Agents (primary and successor)
    agent_persona_id UUID,
    agent_name TEXT,
    agent_email_id UUID,
    agent_phone_id UUID,
    
    -- Successor agents (backup agents)
    successor_agent_1_persona_id UUID,
    successor_agent_1_name TEXT,
    successor_agent_2_persona_id UUID,
    successor_agent_2_name TEXT,
    
    -- Healthcare specific fields
    healthcare_wishes TEXT,
    life_support_preferences TEXT,
    organ_donation_preferences TEXT,
    
    -- POA specific fields
    powers_granted TEXT[],
    powers_excluded TEXT[],
    special_instructions TEXT,
    
    -- Execution details
    execution_date DATE,
    effective_date DATE,
    expiration_date DATE,
    
    -- Legal details
    state_of_execution VARCHAR(2),
    county_of_execution TEXT,
    notarized BOOLEAN DEFAULT FALSE,
    witnesses INTEGER DEFAULT 0,
    
    -- Document references
    primary_document_id UUID,
    supporting_documents UUID[],
    
    -- Status
    status directive_status_enum NOT NULL DEFAULT 'draft',
    revoked_date DATE,
    revocation_document_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_execution_state CHECK (state_of_execution ~ '^[A-Z]{2}$' OR state_of_execution IS NULL),
    CONSTRAINT valid_date_sequence CHECK (
        (expiration_date IS NULL OR expiration_date > effective_date) AND
        (revoked_date IS NULL OR revoked_date >= execution_date)
    )
);

-- Table 27: trusts
-- Purpose: Store trust information
CREATE TABLE trusts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Trust identification
    trust_name TEXT NOT NULL,
    trust_type trust_type_enum NOT NULL,
    tax_id VARCHAR(20),
    
    -- Parties
    grantor_persona_id UUID NOT NULL,
    grantor_name TEXT NOT NULL,
    
    -- Primary Trustee
    trustee_persona_id UUID,
    trustee_name TEXT NOT NULL,
    trustee_email_id UUID,
    trustee_phone_id UUID,
    
    -- Successor Trustees (up to 2)
    successor_trustee_1_persona_id UUID,
    successor_trustee_1_name TEXT,
    successor_trustee_2_persona_id UUID,
    successor_trustee_2_name TEXT,
    
    -- Trust details
    execution_date DATE NOT NULL,
    effective_date DATE,
    termination_date DATE,
    state_of_formation VARCHAR(2),
    
    -- Trust provisions
    distribution_provisions TEXT,
    special_provisions TEXT,
    amendment_provisions TEXT,
    
    -- Financial details
    initial_funding_amount DECIMAL(15, 2),
    current_value DECIMAL(15, 2),
    value_as_of_date DATE,
    
    -- Document references
    trust_document_id UUID,
    amendments UUID[],
    
    -- Status
    is_funded BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_trust_name CHECK (trust_name != ''),
    CONSTRAINT trusts_valid_state CHECK (state_of_formation ~ '^[A-Z]{2}$' OR state_of_formation IS NULL),
    CONSTRAINT valid_trust_dates CHECK (
        (termination_date IS NULL OR termination_date > execution_date) AND
        (effective_date IS NULL OR effective_date >= execution_date)
    )
);

-- Table 28: wills
-- Purpose: Store will information
CREATE TABLE wills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Testator information
    testator_persona_id UUID NOT NULL,
    testator_name TEXT NOT NULL,
    
    -- Executor information
    executor_persona_id UUID,
    executor_name TEXT NOT NULL,
    executor_email_id UUID,
    executor_phone_id UUID,
    
    -- Successor Executors (up to 2)
    successor_executor_1_persona_id UUID,
    successor_executor_1_name TEXT,
    successor_executor_2_persona_id UUID,
    successor_executor_2_name TEXT,
    
    -- Will details
    will_type TEXT DEFAULT 'Last Will and Testament',
    execution_date DATE NOT NULL,
    
    -- Legal details
    state_of_execution VARCHAR(2) NOT NULL,
    county_of_execution TEXT,
    
    -- Witnesses
    witness_1_name TEXT,
    witness_2_name TEXT,
    notarized BOOLEAN DEFAULT FALSE,
    self_proving BOOLEAN DEFAULT FALSE,
    
    -- Will provisions
    guardian_provisions TEXT,
    distribution_provisions TEXT,
    special_bequests TEXT,
    residuary_clause TEXT,
    
    -- Codicils and amendments
    has_codicils BOOLEAN DEFAULT FALSE,
    codicil_dates DATE[],
    codicil_documents UUID[],
    
    -- Document storage
    original_location TEXT,
    copies_location TEXT,
    will_document_id UUID,
    
    -- Status
    is_current BOOLEAN DEFAULT TRUE,
    revoked_date DATE,
    revocation_method TEXT,
    superseded_by_will_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT personal_directives_valid_state CHECK (state_of_execution ~ '^[A-Z]{2}$'),
    CONSTRAINT valid_revocation CHECK (
        (is_current = TRUE AND revoked_date IS NULL) OR
        (is_current = FALSE AND revoked_date IS NOT NULL)
    )
);

-- Table 29: personal_property
-- Purpose: Jewelry, collectibles, pets, art, furniture, etc.
CREATE TABLE personal_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property classification
    property_type personal_property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Item details
    item_name TEXT NOT NULL,
    brand_manufacturer TEXT,
    model_style TEXT,
    serial_number TEXT,
    year_acquired INTEGER,
    
    -- Physical characteristics
    material_composition TEXT,
    dimensions TEXT,
    weight TEXT,
    color TEXT,
    condition_description TEXT,
    
    -- Location
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Master bedroom safe", "Living room", etc.
    
    -- Insurance
    is_insured BOOLEAN DEFAULT FALSE,
    insurance_company TEXT,
    insurance_policy_number TEXT,
    insurance_value DECIMAL(15, 2),
    insurance_contact_phone_id UUID,
    insurance_contact_email_id UUID,
    
    -- Documentation
    receipt_document_id UUID,
    appraisal_document_id UUID,
    photo_ids UUID[],
    certificate_of_authenticity_id UUID,
    
    -- Special handling (for pets)
    pet_name TEXT,
    pet_type pet_type_enum,
    pet_breed TEXT,
    pet_age INTEGER,
    pet_microchip_id VARCHAR(50),
    pet_care_instructions TEXT,
    pet_veterinarian_contact_id UUID,
    pet_care_status pet_care_status_enum,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 30: operational_property  
-- Purpose: Vehicles, boats, equipment, machinery, appliances
CREATE TABLE operational_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property classification
    property_type operational_property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Identification
    make TEXT,
    model TEXT,
    year INTEGER,
    vin_hull_serial TEXT,
    registration_number TEXT,
    registration_state VARCHAR(2),
    
    -- Specifications
    engine_details TEXT,
    mileage_hours INTEGER,
    fuel_type VARCHAR(50),
    transmission_type VARCHAR(50),
    color VARCHAR(50),
    
    -- Location and storage
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Garage", "Marina slip 42", etc.
    
    -- Insurance
    is_insured BOOLEAN DEFAULT FALSE,
    insurance_company TEXT,
    insurance_policy_number TEXT,
    insurance_contact_phone_id UUID,
    insurance_contact_email_id UUID,
    
    -- Operational details
    is_operational BOOLEAN DEFAULT TRUE,
    last_service_date DATE,
    next_service_due DATE,
    service_provider_contact_id UUID,
    
    -- Financial
    loan_balance DECIMAL(15, 2),
    loan_account_number TEXT,
    loan_institution TEXT,
    
    -- Documentation
    title_document_id UUID,
    registration_document_id UUID,
    service_records UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_year CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2),
    CONSTRAINT valid_registration_state CHECK (registration_state ~ '^[A-Z]{2}$' OR registration_state IS NULL)
);

-- Table 31: inventory
-- Purpose: Business inventory, supplies, fixtures
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Inventory identification
    inventory_type TEXT NOT NULL,
    category TEXT,
    
    -- Quantities
    total_units INTEGER,
    unit_of_measure VARCHAR(50),
    units_per_package INTEGER DEFAULT 1,
    
    -- Valuation
    cost_per_unit DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    market_value_per_unit DECIMAL(15, 2),
    total_market_value DECIMAL(15, 2),
    
    -- Location
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Warehouse A, Shelf 3", etc.
    
    -- Supplier information
    supplier_name TEXT,
    supplier_contact_id UUID,
    supplier_email_id UUID,
    supplier_phone_id UUID,
    
    -- Documentation
    inventory_list_document_id UUID,
    purchase_orders UUID[],
    
    -- Status
    last_inventory_date DATE,
    next_inventory_date DATE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_units CHECK (total_units >= 0 OR total_units IS NULL),
    CONSTRAINT valid_costs CHECK (
        (cost_per_unit >= 0 OR cost_per_unit IS NULL) AND
        (total_cost >= 0 OR total_cost IS NULL)
    )
);

-- Table 32: real_estate
-- Purpose: Real property - homes, land, commercial property
CREATE TABLE real_estate (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property identification
    property_type property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Location (required - property must have address)
    property_address_id UUID NOT NULL,
    parcel_number TEXT, -- Assessor's parcel number
    
    -- Property details
    lot_size_acres DECIMAL(10, 4),
    building_size_sqft INTEGER,
    bedrooms INTEGER,
    bathrooms DECIMAL(3, 1),
    year_built INTEGER,
    
    -- Ownership details
    ownership_type property_ownership_enum NOT NULL,
    deed_type TEXT,
    title_company TEXT,
    title_policy_number TEXT,
    
    -- Usage
    property_use property_use_enum NOT NULL,
    rental_income_monthly DECIMAL(15, 2),
    
    -- Mortgage information
    has_mortgage BOOLEAN DEFAULT FALSE,
    mortgage_balance DECIMAL(15, 2),
    mortgage_payment DECIMAL(15, 2),
    mortgage_institution TEXT,
    mortgage_account_number TEXT,
    
    -- Insurance
    homeowners_insurance_company TEXT,
    homeowners_policy_number TEXT,
    insurance_annual_premium DECIMAL(15, 2),
    insurance_contact_email_id UUID,
    insurance_contact_phone_id UUID,
    
    -- Tax information
    annual_property_tax DECIMAL(15, 2),
    tax_assessment_value DECIMAL(15, 2),
    tax_assessment_year INTEGER,
    
    -- HOA/Condo information
    has_hoa BOOLEAN DEFAULT FALSE,
    hoa_fee_monthly DECIMAL(15, 2),
    hoa_contact_id UUID,
    
    -- Documentation
    deed_document_id UUID,
    survey_document_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_year_built CHECK (year_built >= 1600 AND year_built <= EXTRACT(YEAR FROM CURRENT_DATE)),
    CONSTRAINT valid_property_values CHECK (
        (lot_size_acres >= 0 OR lot_size_acres IS NULL) AND
        (building_size_sqft >= 0 OR building_size_sqft IS NULL) AND
        (bedrooms >= 0 OR bedrooms IS NULL) AND
        (bathrooms >= 0 OR bathrooms IS NULL)
    )
);

-- Table 33: life_insurance
-- Purpose: Life insurance policies
CREATE TABLE life_insurance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Policy details
    insurance_company TEXT NOT NULL,
    policy_number TEXT NOT NULL,
    policy_type TEXT NOT NULL, -- Term, Whole, Universal, Variable
    
    -- Coverage
    death_benefit_amount DECIMAL(15, 2) NOT NULL,
    cash_value DECIMAL(15, 2),
    cash_value_as_of_date DATE,
    
    -- Policy dates
    issue_date DATE NOT NULL,
    maturity_date DATE,
    
    -- Insured and owner
    insured_persona_id UUID NOT NULL,
    policy_owner_persona_id UUID NOT NULL,
    
    -- Beneficiaries (stored in asset_persona with ownership_type='beneficiary')
    
    -- Premium information
    annual_premium DECIMAL(15, 2),
    premium_frequency payment_frequency_enum,
    premium_paid_to_date DATE,
    
    -- Riders and options
    has_riders BOOLEAN DEFAULT FALSE,
    rider_details TEXT,
    
    -- Agent/Company contact
    agent_name TEXT,
    agent_contact_id UUID,
    insurer_contact_email_id UUID,
    insurer_contact_phone_id UUID,
    
    -- Documentation
    policy_document_id UUID,
    beneficiary_designation_document_id UUID,
    
    -- Status
    policy_status VARCHAR(50) DEFAULT 'active', -- active, lapsed, paid-up, surrendered
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT life_insurance_valid_amounts CHECK (
        death_benefit_amount > 0 AND
        (cash_value >= 0 OR cash_value IS NULL) AND
        (annual_premium >= 0 OR annual_premium IS NULL)
    )
);

-- Table 34: financial_accounts
-- Purpose: Bank accounts, investment accounts, retirement accounts
CREATE TABLE financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Account identification
    institution_name TEXT NOT NULL,
    account_type account_type_enum NOT NULL,
    account_number_last_four VARCHAR(4),
    
    -- Institution details
    routing_number_last_four VARCHAR(4),
    swift_code VARCHAR(11),
    institution_contact_email_id UUID,
    institution_contact_phone_id UUID,
    
    -- Account details
    account_title TEXT, -- How account is titled
    date_opened DATE,
    
    -- Balances
    current_balance DECIMAL(15, 2),
    balance_as_of_date DATE,
    available_balance DECIMAL(15, 2),
    
    -- Investment specific
    total_contributions DECIMAL(15, 2),
    vested_balance DECIMAL(15, 2),
    investment_risk_profile investment_risk_profile_enum,
    
    -- Financial advisor
    has_advisor BOOLEAN DEFAULT FALSE,
    advisor_name TEXT,
    advisor_email_id UUID,
    advisor_phone_id UUID,
    advisor_contact_id UUID,
    
    -- Online access
    online_access_url TEXT,
    online_username TEXT,
    
    -- Features
    has_checks BOOLEAN DEFAULT FALSE,
    has_debit_card BOOLEAN DEFAULT FALSE,
    has_overdraft_protection BOOLEAN DEFAULT FALSE,
    
    -- Documentation
    statement_document_ids UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_account_last_four CHECK (account_number_last_four ~ '^[0-9]{4}$'),
    CONSTRAINT valid_routing_last_four CHECK (routing_number_last_four ~ '^[0-9]{4}$' OR routing_number_last_four IS NULL),
    CONSTRAINT valid_balances CHECK (
        (current_balance >= 0 OR current_balance IS NULL) AND
        (available_balance >= 0 OR available_balance IS NULL)
    )
);

-- Table 35: recurring_income
-- Purpose: Royalties, pensions, annuities, rental income
CREATE TABLE recurring_income (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Income identification
    income_type income_type_enum NOT NULL,
    income_source TEXT NOT NULL,
    description TEXT,
    
    -- Payment details
    payment_amount DECIMAL(15, 2),
    payment_frequency payment_frequency_enum NOT NULL,
    
    -- Payment dates
    start_date DATE,
    end_date DATE, -- NULL for perpetual
    next_payment_date DATE,
    last_payment_date DATE,
    
    -- Payer information
    payer_name TEXT,
    payer_tax_id VARCHAR(20),
    contact_email_id UUID,
    contact_phone_id UUID,
    
    -- Documentation
    contract_document_id UUID,
    payment_history_document_id UUID,
    
    -- Tax information
    is_taxable BOOLEAN DEFAULT TRUE,
    tax_form_type VARCHAR(20), -- 1099-MISC, 1099-R, etc.
    
    -- Direct deposit
    deposit_account_id UUID, -- Reference to financial_accounts
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT pensions_valid_payment_amount CHECK (payment_amount > 0),
    CONSTRAINT pensions_valid_date_range CHECK (end_date IS NULL OR end_date > start_date)
);

-- Table 36: digital_assets
-- Purpose: Domains, IP, online accounts, crypto
CREATE TABLE digital_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Asset classification
    asset_type digital_asset_type_enum NOT NULL,
    asset_subtype TEXT,
    
    -- Digital asset details
    asset_name TEXT NOT NULL,
    asset_identifier TEXT, -- URL, wallet address, etc.
    platform_name TEXT,
    
    -- Access information
    access_url TEXT,
    username TEXT,
    recovery_email_id UUID,
    recovery_phone_id UUID,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    
    -- Intellectual property specific
    ip_type ip_type_enum,
    registration_number TEXT,
    registration_date DATE,
    expiration_date DATE,
    jurisdiction TEXT,
    
    -- Crypto specific
    wallet_type VARCHAR(50), -- hot, cold, exchange
    blockchain VARCHAR(50),
    wallet_address TEXT,
    approximate_balance DECIMAL(20, 8),
    balance_as_of_date DATE,
    
    -- Documentation
    backup_codes_document_id UUID,
    registration_document_id UUID,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    renewal_required BOOLEAN DEFAULT FALSE,
    auto_renew_enabled BOOLEAN DEFAULT FALSE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_asset_name CHECK (asset_name != '')
);

-- Table 37: ownership_interests
-- Purpose: Business ownership, partnerships, franchises
CREATE TABLE ownership_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Business identification
    entity_name TEXT NOT NULL,
    entity_type business_entity_type_enum NOT NULL,
    tax_id VARCHAR(20),
    state_of_formation VARCHAR(2),
    
    -- Ownership details
    ownership_type ownership_interest_type_enum NOT NULL,
    ownership_percentage DECIMAL(5, 2),
    number_of_shares INTEGER,
    share_class VARCHAR(50),
    
    -- Valuation
    initial_investment DECIMAL(15, 2),
    current_valuation DECIMAL(15, 2),
    valuation_date DATE,
    valuation_method TEXT,
    
    -- Business details
    business_description TEXT,
    industry TEXT,
    annual_revenue DECIMAL(15, 2),
    number_of_employees INTEGER,
    
    -- Management
    is_active_participant BOOLEAN DEFAULT FALSE,
    management_role TEXT,
    
    -- Distributions
    receives_distributions BOOLEAN DEFAULT FALSE,
    distribution_frequency payment_frequency_enum,
    last_distribution_amount DECIMAL(15, 2),
    last_distribution_date DATE,
    
    -- Key contacts
    primary_contact_name TEXT,
    primary_contact_title TEXT,
    primary_contact_email_id UUID,
    primary_contact_phone_id UUID,
    primary_contact_address_id UUID,
    
    -- Governance
    has_operating_agreement BOOLEAN DEFAULT FALSE,
    has_buy_sell_agreement BOOLEAN DEFAULT FALSE,
    
    -- Documentation
    formation_document_id UUID,
    operating_agreement_document_id UUID,
    financial_statements_document_ids UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_ownership_percentage CHECK (ownership_percentage BETWEEN 0 AND 100),
    CONSTRAINT businesses_valid_state CHECK (state_of_formation ~ '^[A-Z]{2}$' OR state_of_formation IS NULL),
    CONSTRAINT valid_shares CHECK (number_of_shares >= 0 OR number_of_shares IS NULL)
);

-- Table 38: loans
-- Purpose: Loans receivable, family loans, business loans owed to the persona
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Loan identification
    loan_type loan_type_enum NOT NULL,
    loan_number TEXT,
    
    -- Parties
    lender_persona_id UUID NOT NULL,
    lender_name TEXT NOT NULL,
    lender_contact_email_id UUID,
    lender_contact_phone_id UUID,
    
    borrower_name TEXT NOT NULL,
    borrower_tax_id VARCHAR(20),
    borrower_contact_id UUID,
    
    -- Loan terms
    original_amount DECIMAL(15, 2) NOT NULL,
    current_balance DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 3),
    interest_type interest_type_enum,
    
    -- Dates
    origination_date DATE NOT NULL,
    maturity_date DATE,
    last_payment_date DATE,
    next_payment_date DATE,
    
    -- Payment details
    payment_amount DECIMAL(15, 2),
    payment_frequency payment_frequency_enum,
    payments_remaining INTEGER,
    
    -- Collateral
    is_secured BOOLEAN DEFAULT FALSE,
    collateral_description TEXT,
    collateral_value DECIMAL(15, 2),
    
    -- Documentation
    loan_agreement_document_id UUID,
    promissory_note_document_id UUID,
    payment_history_document_id UUID,
    
    -- Status
    loan_status loan_status_enum NOT NULL DEFAULT 'active',
    
    -- Collection information
    is_in_collections BOOLEAN DEFAULT FALSE,
    collection_agency_contact_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT loans_valid_amounts CHECK (
        original_amount > 0 AND
        current_balance >= 0 AND
        current_balance <= original_amount
    ),
    CONSTRAINT valid_interest_rate CHECK (interest_rate >= 0 AND interest_rate <= 100),
    CONSTRAINT valid_maturity CHECK (maturity_date IS NULL OR maturity_date > origination_date)
);

-- Table 39: user_sessions
-- Purpose: Track active user sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    tenant_id INTEGER NOT NULL,
    
    -- Session details
    session_token TEXT NOT NULL UNIQUE,
    refresh_token TEXT UNIQUE,
    
    -- Device/Browser info
    ip_address INET,
    user_agent TEXT,
    device_id TEXT,
    device_type VARCHAR(50),
    browser VARCHAR(50),
    os VARCHAR(50),
    
    -- Session lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Session metadata
    is_active BOOLEAN DEFAULT TRUE,
    login_method VARCHAR(50), -- password, sso, mfa
    
    -- Revocation
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by UUID,
    revocation_reason TEXT,
    
    -- Constraints
    CONSTRAINT valid_expiration CHECK (expires_at > created_at)
);

-- Table 40: user_mfa_settings
-- Purpose: Multi-factor authentication settings
CREATE TABLE user_mfa_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- MFA configuration
    mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_method VARCHAR(50), -- totp, sms, email
    
    -- TOTP settings
    totp_secret TEXT,
    totp_verified BOOLEAN DEFAULT FALSE,
    totp_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- SMS/Phone settings
    mfa_phone_id UUID,
    
    -- Email settings
    mfa_email_id UUID,
    
    -- Target contact points
    target_phone_id UUID,
    target_email_id UUID,
    
    -- Backup codes
    backup_codes TEXT[],
    backup_codes_generated_at TIMESTAMP WITH TIME ZONE,
    backup_codes_used INTEGER DEFAULT 0,
    
    -- Recovery
    recovery_codes TEXT[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_user_mfa UNIQUE (user_id)
);

-- Table 41: password_reset_tokens
-- Purpose: Secure password reset tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- Token details
    token_hash TEXT NOT NULL UNIQUE,
    
    -- Token lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    
    -- Request metadata
    requested_ip INET,
    requested_user_agent TEXT,
    
    -- Usage metadata
    used_ip INET,
    used_user_agent TEXT,
    
    -- Status
    is_valid BOOLEAN DEFAULT TRUE,
    invalidated_reason TEXT,
    
    -- Constraints
    CONSTRAINT valid_token_expiration CHECK (expires_at > created_at),
    CONSTRAINT token_single_use CHECK (
        (used_at IS NULL AND is_valid = TRUE) OR
        (used_at IS NOT NULL AND is_valid = FALSE)
    )
);

-- Table 42: user_login_history
-- Purpose: Track login attempts and history
CREATE TABLE user_login_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- Can be NULL for failed attempts
    email TEXT NOT NULL, -- Track even failed attempts
    
    -- Attempt details
    attempt_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    was_successful BOOLEAN NOT NULL,
    failure_reason TEXT,
    
    -- Device/Location
    ip_address INET,
    user_agent TEXT,
    device_id TEXT,
    location_country VARCHAR(2),
    location_city TEXT,
    
    -- Security
    required_mfa BOOLEAN DEFAULT FALSE,
    mfa_completed BOOLEAN DEFAULT FALSE,
    risk_score INTEGER,
    risk_factors TEXT[],
    
    -- Session created
    session_id UUID,
    
    -- Constraints
    CONSTRAINT valid_risk_score CHECK (risk_score BETWEEN 0 AND 100 OR risk_score IS NULL)
);

-- Table 43: audit_log
-- Purpose: Comprehensive audit trail
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Actor
    user_id UUID,
    persona_id UUID,
    session_id UUID,
    
    -- Action
    action audit_action_enum NOT NULL,
    entity_type audit_entity_type_enum NOT NULL,
    entity_id UUID,
    entity_name TEXT,
    
    -- Change details
    old_values JSONB,
    new_values JSONB,
    change_summary TEXT,
    
    -- Context
    ip_address INET,
    user_agent TEXT,
    request_id UUID,
    
    -- TIMESTAMPTZ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}'
);

-- Table 44: audit_events
-- Purpose: System-wide audit events
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Event identification
    event_type TEXT NOT NULL,
    event_category VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL, -- info, warning, error, critical
    
    -- Event details
    description TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    
    -- Source
    source_system VARCHAR(50),
    source_ip INET,
    
    -- User context
    user_id UUID,
    session_id UUID,
    
    -- Timing
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Response
    response_action TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID,
    
    -- Constraints
    CONSTRAINT valid_severity CHECK (severity IN ('info', 'warning', 'error', 'critical'))
);

-- Table 45: pii_detection_rules
-- Purpose: Rules for detecting and handling PII
CREATE TABLE pii_detection_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Rule definition
    rule_name TEXT NOT NULL UNIQUE,
    pii_type pii_type_enum NOT NULL,
    
    -- Pattern matching
    detection_pattern TEXT NOT NULL,
    pattern_type VARCHAR(20) NOT NULL, -- regex, keyword, ml_model
    
    -- Rule configuration
    confidence_threshold DECIMAL(3, 2) DEFAULT 0.90,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Actions
    action_on_detection VARCHAR(50) NOT NULL, -- mask, encrypt, alert, block
    masking_pattern TEXT,
    
    -- Risk assessment
    risk_level pii_risk_level_enum NOT NULL,
    
    -- Metadata
    description TEXT,
    examples TEXT[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 46: pii_processing_jobs
-- Purpose: Track PII scanning and processing jobs
CREATE TABLE pii_processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Job details
    job_type VARCHAR(50) NOT NULL, -- scan, mask, encrypt, delete
    target_table TEXT,
    target_columns TEXT[],
    
    -- Execution
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, running, completed, failed
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Results
    records_processed INTEGER DEFAULT 0,
    pii_found_count INTEGER DEFAULT 0,
    pii_masked_count INTEGER DEFAULT 0,
    errors_count INTEGER DEFAULT 0,
    
    -- Error handling
    error_details JSONB DEFAULT '[]',
    
    -- Configuration
    rules_applied UUID[],
    processing_options JSONB DEFAULT '{}',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    scheduled_by UUID,
    
    -- Constraints
    CONSTRAINT valid_job_status CHECK (status IN ('pending', 'running', 'completed', 'failed'))
);

-- Table 47: masking_configurations
-- Purpose: Configure data masking rules
CREATE TABLE masking_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Target
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    
    -- Masking configuration
    masking_type VARCHAR(50) NOT NULL, -- partial, full, hash, encrypt
    masking_pattern TEXT,
    preserve_format BOOLEAN DEFAULT TRUE,
    
    -- Conditions
    apply_condition TEXT, -- SQL WHERE clause
    user_roles TEXT[], -- Roles that see masked data
    
    -- Options
    show_last_n_chars INTEGER,
    show_first_n_chars INTEGER,
    replacement_char VARCHAR(1) DEFAULT '*',
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_masking_rule UNIQUE (tenant_id, table_name, column_name)
);

-- Table 48: pii_access_logs
-- Purpose: Track access to PII data
CREATE TABLE pii_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Access details
    user_id UUID NOT NULL,
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- What was accessed
    table_name TEXT NOT NULL,
    column_names TEXT[] NOT NULL,
    record_identifiers JSONB, -- Primary keys of accessed records
    
    -- PII details
    pii_types pii_type_enum[] NOT NULL,
    data_classification VARCHAR(50),
    
    -- Access context
    access_reason TEXT,
    access_method VARCHAR(50), -- api, ui, export, report
    
    -- Document reference
    document_id UUID NOT NULL,
    
    -- Session info
    session_id UUID,
    ip_address INET,
    
    -- Compliance
    consent_verified BOOLEAN DEFAULT FALSE,
    legal_basis TEXT,
    
    -- Alert status
    requires_review BOOLEAN DEFAULT FALSE,
    reviewed_by UUID,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT valid_column_names CHECK (array_length(column_names, 1) > 0)
);

-- Table 49: translations
-- Purpose: Multi-language support for UI and content
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Translation key
    translation_key TEXT NOT NULL,
    language_code language_code_enum NOT NULL,
    
    -- Content
    translated_text TEXT NOT NULL,
    context_notes TEXT,
    
    -- Metadata
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID,
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Version control
    version INTEGER DEFAULT 1,
    previous_text TEXT,
    
    -- Usage
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_translation_key UNIQUE (translation_key, language_code)
);

-- Table 50: user_language_preferences
-- Purpose: Track user language preferences
CREATE TABLE user_language_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- Language settings
    preferred_language language_code_enum NOT NULL DEFAULT 'en',
    fallback_language language_code_enum DEFAULT 'en',
    
    -- Regional settings
    date_format VARCHAR(20) DEFAULT 'MM/DD/YYYY',
    time_format VARCHAR(20) DEFAULT '12h',
    currency_code VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    
    -- Accessibility
    high_contrast_mode BOOLEAN DEFAULT FALSE,
    large_text_mode BOOLEAN DEFAULT FALSE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_user_language_pref UNIQUE (user_id),
    CONSTRAINT valid_currency_code CHECK (currency_code ~ '^[A-Z]{3}$')
);

-- Table 51: advisor_companies
-- Purpose: Professional service providers
CREATE TABLE advisor_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Company details
    company_name TEXT NOT NULL,
    company_type TEXT NOT NULL,
    tax_id VARCHAR(20),
    
    -- Contact information
    primary_contact_name TEXT,
    primary_email_id UUID,
    primary_phone_id UUID,
    primary_address_id UUID,
    website_url TEXT,
    
    -- Licensing
    license_number TEXT,
    license_state VARCHAR(2),
    license_expiration DATE,
    
    -- Service details
    services_provided TEXT[],
    specialties TEXT[],
    
    -- Relationship
    client_since DATE,
    last_review_date DATE,
    next_review_date DATE,
    
    -- Ratings
    service_rating INTEGER,
    would_recommend BOOLEAN,
    notes TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_rating CHECK (service_rating BETWEEN 1 AND 5 OR service_rating IS NULL),
    CONSTRAINT valid_license_state CHECK (license_state ~ '^[A-Z]{2}$' OR license_state IS NULL)
);

-- Table 52: builder_io_integrations
-- Purpose: Builder.io CMS integration
CREATE TABLE builder_io_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Builder.io configuration
    api_key TEXT NOT NULL,
    space_id TEXT NOT NULL,
    environment VARCHAR(50) DEFAULT 'production',
    
    -- Content mapping
    content_model_mappings JSONB DEFAULT '{}',
    
    -- Sync settings
    auto_sync_enabled BOOLEAN DEFAULT FALSE,
    sync_frequency_hours INTEGER DEFAULT 24,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    next_sync_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    connection_status integration_status_enum DEFAULT 'disconnected',
    last_error TEXT,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_builder_integration UNIQUE (tenant_id, space_id)
);

-- Table 53: quillt_integrations
-- Purpose: Quillt financial data integration
CREATE TABLE quillt_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    user_id UUID NOT NULL,
    
    -- Quillt connection
    quillt_connection_id TEXT NOT NULL,
    quillt_profile_id TEXT,
    
    -- OAuth tokens
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Sync configuration
    sync_accounts BOOLEAN DEFAULT TRUE,
    sync_transactions BOOLEAN DEFAULT TRUE,
    sync_investments BOOLEAN DEFAULT TRUE,
    
    -- Sync status
    last_sync_at TIMESTAMP WITH TIME ZONE,
    last_successful_sync_at TIMESTAMP WITH TIME ZONE,
    sync_status sync_status_enum DEFAULT 'pending',
    sync_error TEXT,
    
    -- Connected accounts
    connected_account_ids TEXT[],
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    connection_status integration_status_enum DEFAULT 'disconnected',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_quillt_user UNIQUE (tenant_id, user_id)
);

-- Table 54: quillt_webhook_logs
-- Purpose: Track Quillt webhook events
CREATE TABLE quillt_webhook_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Webhook details
    webhook_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    
    -- Payload
    payload JSONB NOT NULL,
    headers JSONB,
    
    -- Processing
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    processing_status webhook_status_enum DEFAULT 'pending',
    processing_error TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Related entities
    user_id UUID,
    integration_id UUID,
    
    -- Constraints
    CONSTRAINT valid_retry_count CHECK (retry_count >= 0)
);

-- Table 55: real_estate_provider_integrations
-- Purpose: Real estate data provider integration
CREATE TABLE real_estate_provider_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Provider details
    provider_name TEXT NOT NULL,
    api_key_encrypted TEXT,
    api_endpoint TEXT,
    
    -- Configuration
    update_frequency_days INTEGER DEFAULT 30,
    property_data_fields TEXT[],
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_provider_per_tenant UNIQUE (tenant_id, provider_name)
);

-- Table 56: real_estate_sync_logs
-- Purpose: Track real estate data synchronization
CREATE TABLE real_estate_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Sync details
    integration_id UUID NOT NULL,
    property_id UUID NOT NULL,
    
    -- Sync data
    sync_type VARCHAR(50) NOT NULL, -- valuation, tax_assessment, market_data
    
    -- Results
    old_value JSONB,
    new_value JSONB,
    data_source TEXT,
    
    -- Status
    sync_status sync_status_enum NOT NULL,
    error_message TEXT,
    
    -- Timing
    initiated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT valid_sync_type CHECK (sync_type IN ('valuation', 'tax_assessment', 'market_data', 'property_details'))
);

-- ================================================================
-- EVENT SOURCING TABLES
-- ================================================================

-- Table 57: event_store
-- Purpose: Immutable event log for complete audit trail and system state reconstruction
CREATE TABLE event_store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Aggregate identification
    aggregate_id UUID NOT NULL,
    aggregate_type TEXT NOT NULL,  -- e.g., 'asset', 'ffc', 'user'
    
    -- Event details
    event_type TEXT NOT NULL,      -- e.g., 'AssetCreated', 'OwnershipTransferred'
    event_data JSONB NOT NULL,     -- Event payload with all relevant data
    event_metadata JSONB,           -- Context information (user, IP, reason, etc.)
    event_version INTEGER NOT NULL, -- Order of events for an aggregate
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL,
    
    -- Constraints
    CONSTRAINT event_version_positive CHECK (event_version > 0),
    CONSTRAINT unique_aggregate_version UNIQUE (aggregate_id, event_version)
);

-- Table 58: event_snapshots
-- Purpose: Periodic snapshots of aggregate state for performance optimization
CREATE TABLE event_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Aggregate identification
    aggregate_id UUID NOT NULL,
    aggregate_type TEXT NOT NULL,
    
    -- Snapshot details
    snapshot_version INTEGER NOT NULL,  -- Event version this snapshot represents
    snapshot_data JSONB NOT NULL,       -- Complete state at this version
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_aggregate_snapshot UNIQUE (aggregate_id, snapshot_version)
);

-- Table 59: event_projections
-- Purpose: Materialized views for query optimization
CREATE TABLE event_projections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Projection identification
    projection_name TEXT NOT NULL,      -- Name of the projection
    aggregate_id UUID,                  -- Optional aggregate this projection relates to
    
    -- Projection data
    projection_data JSONB NOT NULL,     -- Denormalized query-optimized data
    last_event_version INTEGER NOT NULL, -- Last processed event version
    
    -- Metadata
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_projection UNIQUE (tenant_id, projection_name, aggregate_id)
);

-- ================================================================
-- PARTIAL UNIQUE INDEXES (PostgreSQL 17 compatible)
-- ================================================================

-- These replace the invalid UNIQUE constraints with WHERE clauses
CREATE UNIQUE INDEX unique_primary_email_per_entity ON usage_email (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_phone_per_entity ON usage_phone (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_address_per_entity ON usage_address (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_social_per_entity ON usage_social_media (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_active_role_assignment ON user_role_assignments (user_id, role_id, ffc_id, is_active) WHERE is_active = TRUE;
CREATE UNIQUE INDEX unique_primary_owner_per_asset ON asset_persona (asset_id, is_primary) WHERE is_primary = TRUE;

-- ================================================================
-- INDEXES FOR PERFORMANCE
-- ================================================================

-- Tenant isolation indexes
CREATE INDEX idx_media_storage_tenant ON media_storage(tenant_id);
CREATE INDEX idx_document_metadata_tenant ON document_metadata(tenant_id);
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_personas_tenant ON personas(tenant_id);
CREATE INDEX idx_fwd_family_circles_tenant ON fwd_family_circles(tenant_id);
CREATE INDEX idx_assets_tenant ON assets(tenant_id);

-- Authentication and session indexes
CREATE INDEX idx_users_email_verified ON users(email_verified) WHERE email_verified = FALSE;
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token) WHERE is_active = TRUE;
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id, is_active);
CREATE INDEX idx_password_reset_tokens_hash ON password_reset_tokens(token_hash) WHERE is_valid = TRUE;

-- Contact information lookup indexes
CREATE INDEX idx_email_address_email ON email_address(email_address);
CREATE INDEX idx_phone_number_phone ON phone_number(country_code, phone_number);
CREATE INDEX idx_address_postal ON address(postal_code, country);

-- Usage relationship indexes
CREATE INDEX idx_usage_email_entity ON usage_email(entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity ON usage_phone(entity_type, entity_id);
CREATE INDEX idx_usage_address_entity ON usage_address(entity_type, entity_id);
CREATE INDEX idx_usage_social_media_entity ON usage_social_media(entity_type, entity_id);

-- FFC and persona relationship indexes
CREATE INDEX idx_ffc_personas_ffc ON ffc_personas(ffc_id);
CREATE INDEX idx_ffc_personas_persona ON ffc_personas(persona_id);
CREATE INDEX idx_personas_user ON personas(user_id) WHERE user_id IS NOT NULL;

-- Asset relationship indexes
CREATE INDEX idx_assets_category ON assets(category_id);
CREATE INDEX idx_asset_persona_asset ON asset_persona(asset_id);
CREATE INDEX idx_asset_persona_persona ON asset_persona(persona_id);

-- Document and media indexes
CREATE INDEX idx_media_storage_processing ON media_storage(processing_status) WHERE processing_status != 'ready';
CREATE INDEX idx_document_metadata_media ON document_metadata(media_storage_id);
CREATE INDEX idx_document_metadata_type ON document_metadata(document_type, document_category);
CREATE INDEX idx_document_metadata_search ON document_metadata USING GIN(searchable_content);

-- Audit and compliance indexes
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at DESC);
CREATE INDEX idx_pii_access_logs_user ON pii_access_logs(user_id);
CREATE INDEX idx_pii_access_logs_document ON pii_access_logs(document_id);

-- RBAC indexes
CREATE INDEX idx_user_role_assignments_user ON user_role_assignments(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_user_role_assignments_role ON user_role_assignments(role_id) WHERE is_active = TRUE;
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);

-- Invitation indexes
CREATE INDEX idx_ffc_invitations_ffc ON ffc_invitations(ffc_id);
CREATE INDEX idx_ffc_invitations_status ON ffc_invitations(status);
CREATE INDEX idx_ffc_invitations_email ON ffc_invitations(invitee_email_id);

-- Financial and asset-specific indexes
CREATE INDEX idx_financial_accounts_asset ON financial_accounts(asset_id);
CREATE INDEX idx_real_estate_asset ON real_estate(asset_id);
CREATE INDEX idx_life_insurance_asset ON life_insurance(asset_id);
CREATE INDEX idx_personal_property_asset ON personal_property(asset_id);

-- Integration indexes
CREATE INDEX idx_quillt_integrations_user ON quillt_integrations(user_id);
CREATE INDEX idx_quillt_webhook_logs_status ON quillt_webhook_logs(processing_status) WHERE processing_status = 'pending';

-- Event sourcing indexes
CREATE INDEX idx_event_store_aggregate_lookup ON event_store(aggregate_id, event_version);
CREATE INDEX idx_event_store_type ON event_store(event_type, created_at);
CREATE INDEX idx_event_store_tenant ON event_store(tenant_id, created_at);
CREATE INDEX idx_event_store_created_by ON event_store(created_by, created_at);
CREATE INDEX idx_event_snapshots_aggregate ON event_snapshots(aggregate_id, snapshot_version DESC);
CREATE INDEX idx_event_snapshots_tenant ON event_snapshots(tenant_id);
CREATE INDEX idx_event_projections_name ON event_projections(projection_name, tenant_id);
CREATE INDEX idx_event_projections_aggregate ON event_projections(aggregate_id) WHERE aggregate_id IS NOT NULL;

-- ================================================================
-- SUBSCRIPTION AND PAYMENT ENUMS
-- ================================================================

-- Subscription and payment enums
CREATE TYPE plan_type_enum AS ENUM ('free', 'paid', 'sponsored');
CREATE TYPE billing_frequency_enum AS ENUM ('monthly', 'annual', 'one_time', 'lifetime');
CREATE TYPE subscription_status_enum AS ENUM ('active', 'trialing', 'past_due', 'canceled', 'pending', 'paused');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'succeeded', 'failed', 'refunded', 'partially_refunded');
CREATE TYPE payment_type_enum AS ENUM ('subscription', 'service', 'seat_upgrade', 'add_on');
CREATE TYPE transaction_type_enum AS ENUM ('charge', 'refund', 'credit', 'adjustment');
CREATE TYPE ledger_account_type_enum AS ENUM ('revenue', 'refund', 'credit', 'accounts_receivable');
CREATE TYPE seat_type_enum AS ENUM ('basic', 'pro', 'enterprise');
CREATE TYPE payer_type_enum AS ENUM ('owner', 'advisor', 'third_party', 'individual', 'none');
CREATE TYPE refund_reason_enum AS ENUM ('duplicate', 'fraudulent', 'requested_by_customer', 'other');
CREATE TYPE service_type_enum AS ENUM ('one_time', 'recurring');
CREATE TYPE card_brand_enum AS ENUM ('visa', 'mastercard', 'amex', 'discover', 'diners', 'jcb', 'unionpay', 'other');

-- ================================================================
-- SUBSCRIPTION AND PAYMENT MANAGEMENT TABLES
-- ================================================================

-- Plans table - Plan templates and catalog
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_description TEXT,
    plan_type plan_type_enum NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    billing_frequency billing_frequency_enum NOT NULL,
    trial_days INTEGER DEFAULT 0,
    features JSONB DEFAULT '{}',
    ui_config JSONB DEFAULT '{}',
    stripe_product_id VARCHAR(255),
    stripe_price_id VARCHAR(255),
    status status_enum NOT NULL DEFAULT 'active',
    is_public BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT unique_plan_code_per_tenant UNIQUE (tenant_id, plan_code),
    CONSTRAINT valid_base_price CHECK (base_price >= 0)
);

-- Plan seats configuration
CREATE TABLE plan_seats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL,
    seat_type seat_type_enum NOT NULL,
    included_quantity INTEGER, -- NULL means unlimited
    max_quantity INTEGER, -- NULL means unlimited
    additional_seat_price DECIMAL(10, 2) DEFAULT 0.00,
    features JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_seat_type_per_plan UNIQUE (plan_id, seat_type),
    CONSTRAINT valid_quantities CHECK (
        (included_quantity IS NULL OR included_quantity >= 0) AND
        (max_quantity IS NULL OR max_quantity >= 0) AND
        (max_quantity IS NULL OR included_quantity IS NULL OR max_quantity >= included_quantity)
    ),
    CONSTRAINT valid_additional_price CHECK (additional_seat_price >= 0)
);

-- Subscriptions table - Active subscriptions for FFCs
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    ffc_id UUID NOT NULL,
    plan_id UUID NOT NULL,
    owner_user_id UUID NOT NULL,
    payer_id UUID, -- Can be user_id or null for free plans
    payer_type payer_type_enum NOT NULL DEFAULT 'owner',
    advisor_id UUID, -- For advisor-sponsored plans
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id VARCHAR(255),
    status subscription_status_enum NOT NULL DEFAULT 'active',
    trial_end_date DATE,
    current_period_start DATE,
    current_period_end DATE,
    canceled_at TIMESTAMPTZ,
    cancel_reason TEXT,
    next_billing_date DATE,
    billing_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_billing_amount CHECK (billing_amount >= 0)
);

-- Create unique partial index for one active subscription per FFC
CREATE UNIQUE INDEX idx_one_active_subscription_per_ffc 
ON subscriptions(ffc_id) 
WHERE status = 'active';

-- Seat assignments table
CREATE TABLE seat_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL,
    persona_id UUID NOT NULL,
    seat_type seat_type_enum NOT NULL,
    payer_id UUID, -- For individual seat upgrades
    is_self_paid BOOLEAN NOT NULL DEFAULT false,
    status status_enum NOT NULL DEFAULT 'active',
    invited_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    suspended_at TIMESTAMPTZ,
    invitation_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create unique partial index for one active seat per persona per subscription
CREATE UNIQUE INDEX idx_one_active_seat_per_persona_subscription 
ON seat_assignments(subscription_id, persona_id) 
WHERE status = 'active';

-- Payment methods table
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    user_id UUID NOT NULL,
    stripe_payment_method_id VARCHAR(255) NOT NULL,
    stripe_customer_id VARCHAR(255) NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    last_four VARCHAR(4),
    brand card_brand_enum,
    exp_month INTEGER,
    exp_year INTEGER,
    card_holder_name VARCHAR(255),
    is_default BOOLEAN NOT NULL DEFAULT false,
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_exp_month CHECK (exp_month IS NULL OR (exp_month >= 1 AND exp_month <= 12)),
    CONSTRAINT valid_exp_year CHECK (exp_year IS NULL OR exp_year >= EXTRACT(YEAR FROM NOW()))
);

-- Services table - One-time services catalog
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    service_code VARCHAR(50) NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    service_type service_type_enum NOT NULL DEFAULT 'one_time',
    stripe_product_id VARCHAR(255),
    stripe_price_id VARCHAR(255),
    features JSONB DEFAULT '{}',
    delivery_timeline VARCHAR(100),
    status status_enum NOT NULL DEFAULT 'active',
    is_public BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_service_code_per_tenant UNIQUE (tenant_id, service_code),
    CONSTRAINT valid_service_price CHECK (price >= 0)
);

-- Service purchases table
CREATE TABLE service_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    service_id UUID NOT NULL,
    ffc_id UUID NOT NULL,
    purchaser_user_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    stripe_payment_intent_id VARCHAR(255),
    payment_method_id UUID,
    status payment_status_enum NOT NULL DEFAULT 'pending',
    purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_purchase_amount CHECK (amount >= 0)
);

-- Payments table - Unified payment tracking
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    payer_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    payment_type payment_type_enum NOT NULL,
    reference_id UUID NOT NULL, -- Links to subscription_id or service_purchase_id
    payment_method_id UUID,
    stripe_charge_id VARCHAR(255),
    stripe_payment_intent_id VARCHAR(255),
    stripe_invoice_id VARCHAR(255),
    status payment_status_enum NOT NULL DEFAULT 'pending',
    failure_reason TEXT,
    processed_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT subscription_service_purchases_valid_payment_amount CHECK (amount >= 0)
);

CREATE OR REPLACE VIEW payment_methods_with_usage AS
SELECT
  pm.*,
  (
    EXISTS (
      SELECT 1
      FROM subscriptions s
      WHERE s.payer_id = pm.user_id
        AND s.status IN ('active','trialing','past_due')
    )
    OR EXISTS (
      SELECT 1
      FROM payments p
      WHERE p.payment_method_id = pm.id
        AND p.status = 'succeeded'
        AND p.created_at > now() - INTERVAL '30 days'
    )
  ) AS is_in_use
FROM payment_methods pm;

-- General ledger table - Single-entry bookkeeping
CREATE TABLE general_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    account_type ledger_account_type_enum NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    reference_type VARCHAR(50) NOT NULL, -- 'subscription', 'service', 'refund'
    reference_id UUID NOT NULL,
    stripe_reference VARCHAR(255),
    category VARCHAR(50) CHECK (category IN ('recurring_monthly', 'recurring_annual', 'one_time', 'refund')),
    description TEXT,
    internal_notes TEXT,
    reconciled BOOLEAN NOT NULL DEFAULT false,
    reconciled_at TIMESTAMPTZ,
    reconciled_by UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Refunds table
CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    payment_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason refund_reason_enum NOT NULL,
    reason_details TEXT,
    stripe_refund_id VARCHAR(255),
    status payment_status_enum NOT NULL DEFAULT 'pending',
    initiated_by UUID NOT NULL,
    processed_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_refund_amount CHECK (amount > 0)
);

-- Stripe events table - Webhook processing
CREATE TABLE stripe_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stripe_event_id VARCHAR(255) NOT NULL UNIQUE,
    event_type VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'processed', 'failed', 'ignored')),
    attempts INTEGER NOT NULL DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    payload JSONB NOT NULL,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscription transitions table
CREATE TABLE subscription_transitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL,
    from_plan_id UUID,
    to_plan_id UUID NOT NULL,
    transition_type VARCHAR(50) NOT NULL, -- 'upgrade', 'downgrade', 'renewal', 'cancellation'
    prorated_amount DECIMAL(10, 2),
    effective_date DATE NOT NULL,
    initiated_by UUID NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ================================================================
-- SUBSCRIPTION AND PAYMENT INDEXES
-- ================================================================

-- Plan indexes
CREATE INDEX idx_plans_tenant ON plans(tenant_id);
CREATE INDEX idx_plans_status ON plans(status) WHERE status = 'active';
CREATE INDEX idx_plans_public ON plans(is_public) WHERE is_public = true;

-- Subscription indexes
CREATE INDEX idx_subscriptions_tenant ON subscriptions(tenant_id);
CREATE INDEX idx_subscriptions_ffc ON subscriptions(ffc_id);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_advisor ON subscriptions(advisor_id) WHERE advisor_id IS NOT NULL;
CREATE INDEX idx_subscriptions_next_billing ON subscriptions(next_billing_date) WHERE status = 'active';

-- Seat assignment indexes
CREATE INDEX idx_seat_assignments_subscription ON seat_assignments(subscription_id);
CREATE INDEX idx_seat_assignments_persona ON seat_assignments(persona_id);
CREATE INDEX idx_seat_assignments_status ON seat_assignments(status);

-- Payment method indexes
CREATE INDEX idx_payment_methods_tenant ON payment_methods(tenant_id);
CREATE INDEX idx_payment_methods_user ON payment_methods(user_id);
CREATE INDEX idx_payment_methods_status ON payment_methods(status);

-- Service indexes
CREATE INDEX idx_services_tenant ON services(tenant_id);
CREATE INDEX idx_services_status ON services(status) WHERE status = 'active';

-- Payment indexes
CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_payer ON payments(payer_id);
CREATE INDEX idx_payments_reference ON payments(reference_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created ON payments(created_at DESC);
-- speeds the “active/trialing/past_due” lookup
CREATE INDEX IF NOT EXISTS idx_subscriptions_active_like
  ON subscriptions (payer_id)
  WHERE status IN ('active','trialing','past_due');

-- speeds the “succeeded in last 30 days by payment_method” lookup
CREATE INDEX IF NOT EXISTS idx_payments_recent_success_by_pm
  ON payments (payment_method_id, created_at)
  WHERE status = 'succeeded';

-- General ledger indexes
CREATE INDEX idx_general_ledger_tenant ON general_ledger(tenant_id);
CREATE INDEX idx_general_ledger_date ON general_ledger(transaction_date DESC);
CREATE INDEX idx_general_ledger_reference ON general_ledger(reference_id);
CREATE INDEX idx_general_ledger_reconciled ON general_ledger(reconciled) WHERE reconciled = false;

-- Stripe events indexes
CREATE INDEX idx_stripe_events_status ON stripe_events(status) WHERE status IN ('pending', 'processing');
CREATE INDEX idx_stripe_events_type ON stripe_events(event_type);

-- ================================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ================================================================

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update trigger to all tables with updated_at column
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_media_storage_updated_at BEFORE UPDATE ON media_storage FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_document_metadata_updated_at BEFORE UPDATE ON document_metadata FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_personas_updated_at BEFORE UPDATE ON personas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_fwd_family_circles_updated_at BEFORE UPDATE ON fwd_family_circles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_email_address_updated_at BEFORE UPDATE ON email_address FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_phone_number_updated_at BEFORE UPDATE ON phone_number FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_address_updated_at BEFORE UPDATE ON address FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_social_media_updated_at BEFORE UPDATE ON social_media FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON assets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_persona_updated_at BEFORE UPDATE ON asset_persona FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_permissions_updated_at BEFORE UPDATE ON asset_permissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Continue for all other tables with updated_at columns...

-- Subscription and payment table triggers
CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_plan_seats_updated_at BEFORE UPDATE ON plan_seats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_seat_assignments_updated_at BEFORE UPDATE ON seat_assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_service_purchases_updated_at BEFORE UPDATE ON service_purchases FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================================================
-- END OF SCHEMA STRUCTURE FILE
-- ================================================================