-- ================================================================
-- Forward Inheritance Platform - SQL Test Script 4
-- Contains all SQL from architecture.md
-- Tables 1-38 including all asset category tables
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

-- Contact entity type enum
CREATE TYPE contact_entity_type_enum AS ENUM ('advisor', 'company', 'institution', 'attorney', 'accountant', 'financial_advisor', 'insurance_agent', 'other');

-- Asset ownership type enum (already created)
-- CREATE TYPE ownership_type_enum AS ENUM ('owner', 'beneficiary', 'trustee', 'executor');

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

-- Will enum
CREATE TYPE will_status_enum AS ENUM (
    'draft',
    'executed',
    'active',
    'superseded',
    'revoked',
    'probated'
);

-- Personal property enums
CREATE TYPE personal_property_type_enum AS ENUM (
    'jewelry',
    'precious_metals',
    'collectibles',
    'pets_animals',
    'art',
    'furniture'
);

CREATE TYPE valuation_method_enum AS ENUM (
    'appraisal',
    'market_estimate',
    'purchase_price',
    'insurance_value'
);

-- Operational property enums
CREATE TYPE operational_property_type_enum AS ENUM (
    'vehicle',
    'boat',
    'yacht',
    'equipment',
    'machinery',
    'appliances_gear'
);

CREATE TYPE operational_status_enum AS ENUM (
    'operational',
    'inactive',
    'needs_repair',
    'in_storage',
    'sold'
);

-- Inventory enum
CREATE TYPE inventory_type_enum AS ENUM (
    'tool',
    'appliance',
    'fixture',
    'supply',
    'equipment',
    'material',
    'other'
);

-- Real estate enums
CREATE TYPE property_type_enum AS ENUM (
    'primary_residence',
    'secondary_residence',
    'rental',
    'commercial',
    'vacant_land',
    'agricultural',
    'industrial'
);

CREATE TYPE deed_type_enum AS ENUM (
    'sole_ownership',
    'joint_tenancy',
    'tenancy_in_common',
    'community_property',
    'trust_owned',
    'llc_owned'
);

CREATE TYPE mortgage_status_enum AS ENUM (
    'none',
    'active',
    'paid_off',
    'refinanced'
);

-- Life insurance enums
CREATE TYPE life_insurance_policy_type_enum AS ENUM (
    'term',
    'whole_life',
    'universal_life',
    'variable_life',
    'indexed_universal',
    'group_life',
    'final_expense'
);

CREATE TYPE life_insurance_policy_status_enum AS ENUM (
    'active',
    'lapsed',
    'surrendered',
    'paid_up',
    'matured',
    'death_claim_pending',
    'death_claim_paid'
);

CREATE TYPE payment_frequency_enum AS ENUM (
    'monthly',
    'quarterly',
    'semi_annually',
    'annually'
);

-- Financial account enum
CREATE TYPE financial_account_type_enum AS ENUM (
    'checking',
    'savings',
    'money_market',
    'cd',
    'brokerage',
    'ira',
    'roth_ira',
    '401k',
    '403b',
    '529',
    'hsa',
    'crypto',
    'other'
);

-- Recurring income enums
CREATE TYPE recurring_income_type_enum AS ENUM (
    'royalty',
    'residual',
    'annuity',
    'pension',
    'rental_income',
    'dividend',
    'distribution',
    'licensing',
    'franchise_fee',
    'other'
);

CREATE TYPE payer_type_enum AS ENUM (
    'publisher',
    'studio',
    'insurance_company',
    'pension_plan',
    'distributor',
    'licensing_agent',
    'tenant',
    'investment_firm',
    'other'
);

-- Digital asset enums
CREATE TYPE digital_asset_type_enum AS ENUM (
    'patent',
    'trademark',
    'copyright',
    'trade_secret',
    'domain',
    'website',
    'software',
    'nft',
    'cryptocurrency',
    'social_media_account',
    'online_service_account',
    'digital_content',
    'other'
);

CREATE TYPE registration_status_enum AS ENUM (
    'pending',
    'registered',
    'published',
    'granted',
    'expired',
    'abandoned',
    'cancelled'
);

-- Ownership Interest Enums
CREATE TYPE ownership_interest_type_enum AS ENUM (
    'llc',
    'c_corp',
    's_corp',
    'partnership',
    'limited_partnership',
    'franchise',
    'joint_venture',
    'sole_proprietorship',
    'professional_corp',
    'benefit_corp',
    'cooperative',
    'non_profit',
    'timeshare',
    'other'
);

CREATE TYPE ownership_structure_enum AS ENUM (
    'single_member',
    'multi_member',
    'publicly_traded',
    'privately_held',
    'family_owned',
    'institutional',
    'mixed'
);

CREATE TYPE ownership_valuation_method_enum AS ENUM (
    'market_estimate',
    'professional_appraisal',
    'book_value',
    'revenue_multiple',
    'dcf_analysis',
    'asset_based',
    'recent_transaction'
);

-- Loan Enums
CREATE TYPE loan_type_enum AS ENUM (
    'personal',
    'mortgage',
    'interfamily',
    'business',
    'auto',
    'student',
    'credit_line',
    'home_equity',
    'hei',
    'other'
);

CREATE TYPE loan_lender_type_enum AS ENUM (
    'individual',
    'family_member',
    'bank',
    'credit_union',
    'mortgage_company',
    'private_lender',
    'hei_provider',
    'trust',
    'other_institution'
);

CREATE TYPE loan_interest_type_enum AS ENUM (
    'fixed',
    'variable',
    'afr_based',
    'zero',
    'deferred'
);

CREATE TYPE loan_payment_status_enum AS ENUM (
    'current',
    'late',
    'delinquent',
    'paid_off',
    'defaulted',
    'in_forbearance'
);

-- ================================================================
-- SUPPORTING TABLES
-- ================================================================

-- Table 1: tenants
-- Purpose: Multi-tenant support for white-label deployments
CREATE TABLE tenants (
    id INTEGER PRIMARY KEY,
    
    -- Tenant identification
    name VARCHAR(255) NOT NULL UNIQUE, -- URL-safe identifier
    display_name VARCHAR(255) NOT NULL,
    
    -- Branding
    domain VARCHAR(255), -- For white-label domains
    logo_url VARCHAR(500),
    primary_color VARCHAR(7), -- Hex color for branding
    secondary_color VARCHAR(7),
    
    -- Configuration
    settings JSONB DEFAULT '{}',
    feature_flags JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 2: media_storage
-- Purpose: Centralized storage for all uploaded files (images, documents, etc.)
CREATE TABLE media_storage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- File identification
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_extension VARCHAR(20),
    file_size BIGINT NOT NULL, -- in bytes
    
    -- Storage location
    storage_bucket VARCHAR(255) NOT NULL,
    storage_key VARCHAR(500) NOT NULL UNIQUE, -- Full path in storage
    storage_url VARCHAR(1000), -- Pre-signed URL or CDN URL
    
    -- File metadata
    checksum VARCHAR(64) NOT NULL, -- SHA-256 hash
    is_encrypted BOOLEAN NOT NULL DEFAULT true,
    encryption_key_id VARCHAR(100),
    
    -- Image-specific metadata
    width INTEGER,
    height INTEGER,
    
    -- Document-specific metadata
    page_count INTEGER,
    
    -- PII handling
    contains_pii BOOLEAN DEFAULT NULL, -- NULL = not scanned yet
    pii_types VARCHAR[], -- Array of PII types found
    masked_version_id UUID REFERENCES media_storage(id), -- Link to PII-masked version
    
    -- Processing status
    processing_status processing_status_enum DEFAULT 'uploaded',
    processing_error TEXT,
    
    -- Retention and lifecycle
    retention_policy retention_policy_enum,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-tenancy and audit
    uploaded_by UUID NOT NULL REFERENCES users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CHECK (file_size > 0),
    CHECK (NOT is_deleted OR deleted_at IS NOT NULL)
);

-- Table 3: document_metadata
-- Purpose: Additional metadata for documents stored in media_storage
CREATE TABLE document_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_storage_id UUID NOT NULL REFERENCES media_storage(id) ON DELETE CASCADE,
    
    -- Document classification
    document_type document_type_enum NOT NULL,
    document_category document_category_enum,
    
    -- Document details
    document_date DATE,
    effective_date DATE,
    expiry_date DATE,
    
    -- Version control
    version_number VARCHAR(50),
    is_current_version BOOLEAN DEFAULT true,
    previous_version_id UUID REFERENCES document_metadata(id),
    
    -- Legal/Compliance
    is_legally_binding BOOLEAN DEFAULT false,
    requires_witness BOOLEAN DEFAULT false,
    is_notarized BOOLEAN DEFAULT false,
    notary_details JSONB,
    
    -- Search and organization
    tags VARCHAR[],
    full_text_content TEXT, -- Extracted text for search
    summary TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(media_storage_id)
);

-- ================================================================
-- CORE TABLES
-- ================================================================

-- Table 4: users
-- Purpose: Authentication and user account management
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Normalized contact references
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    
    -- Email/Phone verification status tracked here for authentication
    email_verified BOOLEAN DEFAULT FALSE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    phone_verified BOOLEAN DEFAULT FALSE,
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Authentication
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    password_last_changed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    must_change_password BOOLEAN DEFAULT FALSE,
    
    -- Account Security
    failed_login_attempts INTEGER DEFAULT 0,
    account_locked BOOLEAN DEFAULT FALSE,
    account_locked_until TIMESTAMP WITH TIME ZONE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,
    
    -- Profile Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    profile_picture_url VARCHAR(500),
    
    -- System Fields
    status user_status_enum NOT NULL DEFAULT 'pending_verification',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Table 5: personas
-- Purpose: Business identity layer representing family members (living or deceased)
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    user_id UUID REFERENCES users(id), -- NULL for deceased or non-user personas
    
    -- Personal identification
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    last_name VARCHAR(255) NOT NULL,
    maiden_name VARCHAR(255),
    name_suffix VARCHAR(20), -- Jr., Sr., III, etc.
    preferred_name VARCHAR(255),
    
    -- Life events
    date_of_birth DATE,
    date_of_death DATE,
    is_living BOOLEAN NOT NULL DEFAULT true,
    
    -- Demographics
    gender gender_enum,
    marital_status marital_status_enum,
    nationality VARCHAR(100),
    
    -- Profile
    profile_picture_id UUID REFERENCES media_storage(id),
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (date_of_death IS NULL OR date_of_birth < date_of_death),
    CHECK (is_living = false OR date_of_death IS NULL)
);

-- Table 6: fwd_family_circles
-- Purpose: Family groups for organizing inheritance planning
CREATE TABLE fwd_family_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- FFC identification
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Family details
    family_picture_id UUID REFERENCES media_storage(id),
    established_date DATE DEFAULT CURRENT_DATE,
    
    -- Settings
    settings JSONB DEFAULT '{}',
    preferences JSONB DEFAULT '{}',
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(tenant_id, name)
);

-- ================================================================
-- CONTACT TABLES
-- ================================================================

-- Table 7: phone_number
-- Purpose: Normalized phone storage with international support
CREATE TABLE phone_number (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Phone number details
    phone_number VARCHAR(20) NOT NULL, -- E.164 format: +1234567890
    country_code VARCHAR(5), -- Extracted country code
    national_number VARCHAR(15), -- National format without country code
    
    -- Phone metadata
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    phone_type phone_type_enum,
    carrier_name VARCHAR(100),
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_e164_format CHECK (phone_number ~ '^\+[1-9]\d{1,14}$')
);

-- Table 8: email_address
-- Purpose: Normalized email storage for multi-use across system
CREATE TABLE email_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Email details
    email_address VARCHAR(255) NOT NULL,
    domain VARCHAR(255), -- Extracted domain part
    
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
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Address components
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_or_province VARCHAR(50),
    postal_code VARCHAR(20),
    country CHAR(2) NOT NULL DEFAULT 'US', -- ISO 3166-1 alpha-2
    
    -- Formatted versions
    formatted_address TEXT, -- Full formatted address
    
    -- Geocoding (optional)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Address metadata
    address_type address_type_enum,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 10: social_media
-- Purpose: Normalized social media account storage
CREATE TABLE social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Social media details
    platform social_media_platform_enum NOT NULL,
    username VARCHAR(255) NOT NULL,
    profile_url VARCHAR(500),
    account_id VARCHAR(255), -- Platform-specific ID
    
    -- Account metadata
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    follower_count INTEGER,
    is_business_account BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(tenant_id, platform, username)
);

-- ================================================================
-- RELATIONSHIP TABLES
-- ================================================================

-- Table 11: usage_email
-- Purpose: Links entities (users/personas) to multiple email addresses
CREATE TABLE usage_email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    email_id UUID NOT NULL REFERENCES email_address(id),
    
    -- Usage details
    usage_type email_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    can_receive_notifications BOOLEAN DEFAULT TRUE,
    can_receive_marketing BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, email_id),
    CHECK ((entity_type = 'user' AND entity_id IN (SELECT id FROM users)) OR 
           (entity_type = 'persona' AND entity_id IN (SELECT id FROM personas)))
);

-- Table 12: usage_phone
-- Purpose: Links entities (users/personas) to multiple phone numbers
CREATE TABLE usage_phone (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    phone_id UUID NOT NULL REFERENCES phone_number(id),
    
    -- Usage details
    usage_type phone_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    can_receive_sms BOOLEAN DEFAULT TRUE,
    can_receive_calls BOOLEAN DEFAULT TRUE,
    preferred_contact_time contact_time_enum,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, phone_id)
);

-- Table 13: usage_address
-- Purpose: Links entities (users/personas/assets) to multiple addresses
CREATE TABLE usage_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL CHECK (entity_type IN ('user', 'persona', 'asset')),
    entity_id UUID NOT NULL,
    address_id UUID NOT NULL REFERENCES address(id),
    
    -- Usage details
    usage_type address_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Date ranges for temporary addresses
    effective_from DATE,
    effective_to DATE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, address_id, usage_type)
);

-- Table 14: usage_social_media
-- Purpose: Links entities (users/personas) to social media accounts
CREATE TABLE usage_social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type entity_type_enum NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    social_media_id UUID NOT NULL REFERENCES social_media(id),
    
    -- Usage details
    usage_type social_media_usage_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    
    -- Privacy settings
    share_with_family BOOLEAN DEFAULT TRUE,
    share_with_advisors BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, social_media_id)
);

-- Table 15: contact_info
-- Purpose: Unified contact information for entities (advisors, companies, etc.)
CREATE TABLE contact_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Entity identification
    entity_name VARCHAR(255) NOT NULL,
    entity_type contact_entity_type_enum NOT NULL,
    
    -- Contact references
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    primary_address_id UUID REFERENCES address(id),
    
    -- Additional info
    website_url VARCHAR(500),
    notes TEXT,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Table 16: ffc_personas
-- Purpose: Links personas to FFCs with their business role
CREATE TABLE ffc_personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Business role in FFC
    role ffc_role_enum NOT NULL,
    
    -- Relationship details
    relationship_to_owner family_relationship_enum,
    joined_date DATE DEFAULT CURRENT_DATE,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(ffc_id, persona_id)
);

-- ================================================================
-- SECURITY TABLES (RBAC)
-- ================================================================

-- Table 17: user_roles
-- Purpose: Define available roles in the system
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Role definition
    name VARCHAR(100) NOT NULL UNIQUE, -- platform_admin, ffc_owner, ffc_member, ffc_viewer
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Role hierarchy
    parent_role_id UUID REFERENCES user_roles(id),
    hierarchy_level INTEGER NOT NULL DEFAULT 0,
    
    -- Role properties
    is_system_role BOOLEAN NOT NULL DEFAULT false,
    is_default_role BOOLEAN NOT NULL DEFAULT false,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 18: user_permissions
-- Purpose: Define granular permissions
CREATE TABLE user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Permission definition
    name VARCHAR(100) NOT NULL UNIQUE, -- asset.create, user.invite, etc.
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    category permission_category_enum NOT NULL,
    
    -- Permission properties
    is_dangerous BOOLEAN NOT NULL DEFAULT false, -- For destructive operations
    requires_2fa BOOLEAN NOT NULL DEFAULT false,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 19: role_permissions
-- Purpose: Links roles to their permissions
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES user_permissions(id),
    
    -- Grant details
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    granted_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(role_id, permission_id)
);

-- Table 20: user_role_assignments
-- Purpose: Assigns roles to users within specific FFCs (multi-tenant RBAC)
CREATE TABLE user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    role_id UUID NOT NULL REFERENCES user_roles(id),
    ffc_id UUID REFERENCES fwd_family_circles(id), -- NULL for platform_admin
    
    -- Assignment details
    assigned_by UUID NOT NULL REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Assignment properties
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(user_id, role_id, ffc_id),
    CHECK (expires_at IS NULL OR expires_at > assigned_at)
);

-- ================================================================
-- INVITATION TABLES
-- ================================================================

-- Table 21: ffc_invitations
-- Purpose: Manage invitations to join Forward Family Circles
CREATE TABLE ffc_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(id) ON DELETE CASCADE,
    
    -- Inviter information
    inviter_persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Invitee information
    invitee_email_id UUID NOT NULL REFERENCES email_address(id),
    invitee_phone_id UUID NOT NULL REFERENCES phone_number(id),
    invitee_name VARCHAR(255) NOT NULL,
    proposed_role ffc_role_enum NOT NULL DEFAULT 'beneficiary',
    
    -- Invitation mechanism
    invitation_token VARCHAR(255) UNIQUE NOT NULL,
    sms_verification_code VARCHAR(6),
    verification_code_sent_at TIMESTAMP WITH TIME ZONE,
    
    -- Status and lifecycle
    status invitation_status_enum NOT NULL DEFAULT 'sent',
    personal_message TEXT,
    
    -- Timeline
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'),
    phone_verified_at TIMESTAMP WITH TIME ZONE,
    accepted_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Approval workflow
    approved_by_persona_id UUID REFERENCES personas(id),
    approval_notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (expires_at > invited_at),
    CHECK (phone_verified_at IS NULL OR phone_verified_at >= invited_at),
    CHECK (accepted_at IS NULL OR accepted_at >= invited_at),
    CHECK (approved_at IS NULL OR approved_at >= accepted_at)
);

-- Table 22: invitation_verification_attempts
-- Purpose: Track verification attempts for invitation security
CREATE TABLE invitation_verification_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invitation_id UUID NOT NULL REFERENCES ffc_invitations(id) ON DELETE CASCADE,
    
    -- Attempt details
    verification_code VARCHAR(6) NOT NULL,
    attempt_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_successful BOOLEAN DEFAULT false,
    
    -- Security tracking
    ip_address INET,
    user_agent TEXT,
    
    -- Rate limiting
    phone_id UUID NOT NULL REFERENCES phone_number(id),
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================================
-- ASSET TABLES
-- ================================================================

-- Table 23: asset_categories
-- Purpose: Define the 13 main asset categories for the platform
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Insert default Forward tenant (ID = 1)
INSERT INTO tenants (id, name, display_name, primary_color, secondary_color, is_active) VALUES
(1, 'forward-inheritance', 'Forward Inheritance Platform', '#1f2937', '#3b82f6', true);

-- Insert the 13 asset categories
INSERT INTO asset_categories (name, code, description, sort_order) VALUES
('Personal Directives', 'personal_directives', 'Power of Attorney, Healthcare Directive/Living will, Letter of Intent/Family Directive, HIPAA Authorization', 1),
('Trust', 'trust', 'Trust documents and agreements', 2),
('Will', 'will', 'Will documents', 3),
('Personal Property', 'personal_property', 'Jewelry, Precious Metals, Collectibles, Pets/Animals, Art, Furniture', 4),
('Operational Property', 'operational_property', 'Vehicles, Boats/Yacht, Equipment/Machinery, Appliances/Gear', 5),
('Inventory', 'inventory', 'Business inventory and fixtures', 6),
('Real Estate', 'real_estate', 'Property and Real Estate holdings', 7),
('Life Insurance', 'life_insurance', 'Life Insurance policies', 8),
('Financial Accounts', 'financial_accounts', 'Investments, Bank accounts, Retirement Accounts, College Savings', 9),
('Recurring Income', 'recurring_income', 'Royalties and recurring income streams', 10),
('Digital Assets', 'digital_assets', 'Intellectual Property, Digital Assets', 11),
('Ownership Interests', 'ownership_interests', 'Business and Franchise ownership', 12),
('Loans', 'loans', 'HEI and Interfamily Loans', 13);

-- Table 24: assets
-- Purpose: Core asset registry - assets connect to FFCs via personas, not directly
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    category_id UUID NOT NULL REFERENCES asset_categories(id),
    
    -- Asset identification
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Valuation
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    last_valued_date DATE,
    
    -- Metadata
    tags JSONB DEFAULT '[]',
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (estimated_value IS NULL OR estimated_value >= 0)
);

-- Create ownership type enum
CREATE TYPE ownership_type_enum AS ENUM ('owner', 'beneficiary', 'trustee', 'executor');

-- Table 25: asset_persona
-- Purpose: Links assets to personas (who then link to FFCs) - this is the key relationship
CREATE TABLE asset_persona (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES personas(id) ON DELETE CASCADE,
    
    -- Ownership details
    ownership_type ownership_type_enum NOT NULL DEFAULT 'owner',
    ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    
    -- Additional info
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(asset_id, persona_id, ownership_type),
    CHECK (ownership_percentage > 0 AND ownership_percentage <= 100)
);

-- ================================================================
-- ASSET CATEGORY SPECIFIC TABLES
-- ================================================================

-- Table 26: personal_directives
-- Purpose: Stores power of attorney, healthcare directives, living wills, and other personal directive documents
CREATE TABLE personal_directives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Directive type and identification
    directive_type directive_type_enum NOT NULL,
    directive_name VARCHAR(255) NOT NULL,
    
    -- Principal (person creating the directive)
    principal_persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Agent/Recipient information (person receiving authority)
    agent_persona_id UUID REFERENCES personas(id),
    agent_name VARCHAR(255), -- For non-persona agents
    agent_email_id UUID REFERENCES email_address(id),
    agent_phone_id UUID REFERENCES phone_number(id),
    
    -- Successor agents (backup agents)
    successor_agent_1_persona_id UUID REFERENCES personas(id),
    successor_agent_1_name VARCHAR(255),
    successor_agent_2_persona_id UUID REFERENCES personas(id),
    successor_agent_2_name VARCHAR(255),
    
    -- Execution and effectiveness
    execution_date DATE NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE,
    jurisdiction VARCHAR(100) NOT NULL, -- State/Country
    
    -- Authority scope (what powers are granted)
    financial_authority BOOLEAN DEFAULT false,
    healthcare_authority BOOLEAN DEFAULT false,
    real_estate_authority BOOLEAN DEFAULT false,
    digital_assets_authority BOOLEAN DEFAULT false,
    
    -- Healthcare specific preferences (for healthcare directives/living wills)
    life_sustaining_treatment BOOLEAN,
    artificial_nutrition BOOLEAN,
    organ_donation BOOLEAN,
    
    -- Guardian designation (for guardianship directives)
    guardian_persona_id UUID REFERENCES personas(id),
    guardian_name VARCHAR(255),
    
    -- Document references
    document_id UUID REFERENCES media_storage(id), -- Link to actual document
    
    -- Legal requirements
    is_notarized BOOLEAN DEFAULT false,
    witness_1_name VARCHAR(255),
    witness_2_name VARCHAR(255),
    
    -- Status tracking
    status directive_status_enum NOT NULL DEFAULT 'draft',
    revocation_date DATE,
    superseded_by_id UUID REFERENCES personal_directives(id),
    
    -- HIPAA specific (for HIPAA authorizations)
    includes_mental_health BOOLEAN DEFAULT false,
    includes_substance_abuse BOOLEAN DEFAULT false,
    
    -- Notes and instructions
    special_instructions TEXT,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (expiration_date IS NULL OR expiration_date > effective_date),
    CHECK (revocation_date IS NULL OR status = 'revoked')
);

-- Table 27: trusts  
-- Purpose: Stores trust documents and relationships between personas and trusts
CREATE TABLE trusts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Trust identification
    trust_name VARCHAR(255) NOT NULL,
    trust_type trust_type_enum NOT NULL,
    
    -- Legal details
    establishment_date DATE NOT NULL,
    jurisdiction VARCHAR(100) NOT NULL, -- State/Country
    tax_id_masked VARCHAR(20), -- e.g., "**-***1234"
    
    -- Document reference
    document_id UUID REFERENCES media_storage(id), -- Link to trust document
    
    -- Grantor/Settlor (person who created the trust)
    grantor_persona_id UUID NOT NULL REFERENCES personas(id),
    grantor_name VARCHAR(255), -- For display/override purposes
    
    -- Primary Trustee
    trustee_persona_id UUID REFERENCES personas(id),
    trustee_name VARCHAR(255), -- For non-persona trustees
    trustee_email_id UUID REFERENCES email_address(id),
    trustee_phone_id UUID REFERENCES phone_number(id),
    
    -- Successor Trustees (up to 2)
    successor_trustee_1_persona_id UUID REFERENCES personas(id),
    successor_trustee_1_name VARCHAR(255),
    successor_trustee_2_persona_id UUID REFERENCES personas(id),
    successor_trustee_2_name VARCHAR(255),
    
    -- Beneficiaries (array of persona IDs)
    beneficiary_persona_ids UUID[] NOT NULL DEFAULT '{}',
    
    -- Trust Protector/Advisor (optional roles)
    trust_protector_persona_id UUID REFERENCES personas(id),
    trust_protector_name VARCHAR(255),
    trust_advisor_persona_id UUID REFERENCES personas(id),
    trust_advisor_name VARCHAR(255),
    
    -- Financial summary
    initial_funding_amount DECIMAL(15,2),
    
    -- Status
    is_funded BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    termination_date DATE,
    
    -- Amendments
    amendment_count INTEGER DEFAULT 0,
    last_amendment_date DATE,
    amendments_summary TEXT,
    
    -- Notes
    special_provisions TEXT,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (termination_date IS NULL OR termination_date > establishment_date)
);

-- Index for beneficiary persona IDs array
CREATE INDEX idx_trusts_beneficiaries ON trusts USING gin(beneficiary_persona_ids);

-- Table 28: wills
-- Purpose: Stores will documents and relationships between personas involved in the will
CREATE TABLE wills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Will identification
    will_name VARCHAR(255) NOT NULL DEFAULT 'Last Will and Testament',
    
    -- Testator (person creating the will)
    testator_persona_id UUID NOT NULL REFERENCES personas(id),
    testator_name VARCHAR(255) NOT NULL, -- Legal name at time of execution
    
    -- Will execution details
    execution_date DATE NOT NULL,
    jurisdiction VARCHAR(100) NOT NULL, -- State/Country
    
    -- Document reference
    document_id UUID REFERENCES media_storage(id), -- Link to will document
    
    -- Executor(s)
    executor_persona_id UUID REFERENCES personas(id),
    executor_name VARCHAR(255), -- For non-persona executors
    executor_email_id UUID REFERENCES email_address(id),
    executor_phone_id UUID REFERENCES phone_number(id),
    
    -- Successor Executors (up to 2)
    successor_executor_1_persona_id UUID REFERENCES personas(id),
    successor_executor_1_name VARCHAR(255),
    successor_executor_2_persona_id UUID REFERENCES personas(id),
    successor_executor_2_name VARCHAR(255),
    
    -- Beneficiaries (array of persona IDs)
    beneficiary_persona_ids UUID[] NOT NULL DEFAULT '{}',
    
    -- Guardian designation for minors
    guardian_persona_id UUID REFERENCES personas(id),
    guardian_name VARCHAR(255), -- For non-persona guardians
    guardian_for_minors TEXT, -- Names of minors
    
    -- Witnesses
    witness_1_name VARCHAR(255),
    witness_2_name VARCHAR(255),
    
    -- Status and versions
    status will_status_enum NOT NULL DEFAULT 'draft',
    version_number INTEGER DEFAULT 1,
    supersedes_will_id UUID REFERENCES wills(id), -- Previous version
    
    -- Revocation
    revocation_date DATE,
    revocation_method VARCHAR(100), -- How it was revoked
    
    -- Special provisions
    has_no_contest_clause BOOLEAN DEFAULT false,
    has_self_proving_affidavit BOOLEAN DEFAULT false,
    survivorship_days INTEGER DEFAULT 30, -- Days beneficiary must survive
    
    -- Probate information
    probate_filed_date DATE,
    probate_court VARCHAR(255),
    probate_case_number VARCHAR(100),
    
    -- Notes
    special_instructions TEXT,
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (revocation_date IS NULL OR revocation_date >= execution_date),
    CHECK (probate_filed_date IS NULL OR probate_filed_date >= execution_date)
);

-- Index for beneficiary persona IDs array
CREATE INDEX idx_wills_beneficiaries ON wills USING gin(beneficiary_persona_ids);

-- Table 29: personal_property
-- Purpose: Stores personal property items like jewelry, art, collectibles, pets, etc.
CREATE TABLE personal_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Item identification
    item_type personal_property_type_enum NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Physical details
    brand_manufacturer VARCHAR(255),
    model_number VARCHAR(100),
    serial_number VARCHAR(100),
    
    -- Valuation
    estimated_value DECIMAL(15,2),
    valuation_method valuation_method_enum,
    valuation_date DATE,
    
    -- Acquisition
    purchase_date DATE,
    purchase_price DECIMAL(15,2),
    purchased_from VARCHAR(255),
    
    -- Storage location  
    storage_address_id UUID REFERENCES address(id),
    storage_location_detail VARCHAR(255), -- "Master bedroom safe", "Living room", etc.
    
    -- Insurance information
    is_insured BOOLEAN DEFAULT false,
    insurance_company VARCHAR(255),
    insurance_policy_number VARCHAR(100),
    insurance_contact_name VARCHAR(255),
    insurance_contact_phone_id UUID REFERENCES phone_number(id),
    insurance_contact_email_id UUID REFERENCES email_address(id),
    
    -- Documentation
    primary_image_id UUID REFERENCES media_storage(id), -- Main photo
    additional_image_ids UUID[] DEFAULT '{}', -- Array of additional photos
    appraisal_document_id UUID REFERENCES media_storage(id),
    receipt_document_id UUID REFERENCES media_storage(id),
    
    -- For pets/animals
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100),
    pet_age_years INTEGER,
    veterinarian_contact_id UUID REFERENCES contact_info(id),
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Index for additional images array
CREATE INDEX idx_personal_property_images ON personal_property USING gin(additional_image_ids);

-- Table 30: operational_property
-- Purpose: Stores operational property like vehicles, boats, equipment, machinery
CREATE TABLE operational_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Item identification
    property_type operational_property_type_enum NOT NULL,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER,
    
    -- Unique identifiers
    serial_or_vin VARCHAR(100), -- VIN for vehicles, serial for equipment
    registration_number VARCHAR(50),
    license_plate VARCHAR(20),
    
    -- Valuation
    purchase_date DATE,
    purchase_price DECIMAL(15,2),
    estimated_value DECIMAL(15,2),
    
    -- Storage location
    storage_address_id UUID REFERENCES address(id),
    storage_location_detail VARCHAR(255), -- "Garage", "Marina slip 42", etc.
    
    -- Insurance information
    is_insured BOOLEAN DEFAULT false,
    insurance_company VARCHAR(255),
    insurance_policy_number VARCHAR(100),
    insurance_contact_name VARCHAR(255),
    insurance_contact_phone_id UUID REFERENCES phone_number(id),
    insurance_contact_email_id UUID REFERENCES email_address(id),
    
    -- Operational details
    operational_status operational_status_enum NOT NULL DEFAULT 'operational',
    last_service_date DATE,
    next_service_date DATE,
    odometer_reading INTEGER, -- For vehicles
    operating_hours DECIMAL(10,2), -- For equipment/machinery
    
    -- Documentation
    primary_image_id UUID REFERENCES media_storage(id),
    additional_image_ids UUID[] DEFAULT '{}',
    title_document_id UUID REFERENCES media_storage(id),
    registration_document_id UUID REFERENCES media_storage(id),
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (year IS NULL OR (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 2))
);

-- Index for additional images array
CREATE INDEX idx_operational_property_images ON operational_property USING gin(additional_image_ids);

-- Table 31: inventory
-- Purpose: Stores business inventory, fixtures, tools, and supplies
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Item identification
    item_type inventory_type_enum NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    sku VARCHAR(100), -- Stock Keeping Unit
    
    -- Quantity tracking
    quantity DECIMAL(15,2) NOT NULL DEFAULT 0,
    unit_of_measure VARCHAR(50) DEFAULT 'each', -- each, box, case, etc.
    unit_cost DECIMAL(15,2),
    total_value DECIMAL(15,2) GENERATED ALWAYS AS (quantity * COALESCE(unit_cost, 0)) STORED,
    
    -- Inventory management
    reorder_threshold DECIMAL(15,2),
    last_inventory_date DATE,
    
    -- Storage location
    storage_address_id UUID REFERENCES address(id),
    storage_location_detail VARCHAR(255), -- "Warehouse A, Shelf 3", etc.
    
    -- Supplier information
    supplier_name VARCHAR(255),
    supplier_contact_name VARCHAR(255),
    supplier_email_id UUID REFERENCES email_address(id),
    supplier_phone_id UUID REFERENCES phone_number(id),
    
    -- Documentation
    primary_image_id UUID REFERENCES media_storage(id),
    inventory_list_document_id UUID REFERENCES media_storage(id),
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (quantity >= 0),
    CHECK (unit_cost IS NULL OR unit_cost >= 0),
    CHECK (reorder_threshold IS NULL OR reorder_threshold >= 0)
);

-- Table 32: real_estate
-- Purpose: Stores real estate and property assets
CREATE TABLE real_estate (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Property identification
    property_type property_type_enum NOT NULL,
    property_name VARCHAR(255), -- "Main House", "Beach Condo", etc.
    
    -- Location (using normalized address)
    property_address_id UUID NOT NULL REFERENCES address(id),
    parcel_number VARCHAR(100), -- Assessor's parcel number
    
    -- Ownership details
    title_holder_name VARCHAR(255) NOT NULL,
    deed_type deed_type_enum NOT NULL,
    
    -- Acquisition and valuation
    acquisition_date DATE,
    purchase_price DECIMAL(15,2),
    estimated_value DECIMAL(15,2),
    valuation_method valuation_method_enum,
    last_appraisal_date DATE,
    
    -- Property details
    lot_size_acres DECIMAL(10,4),
    building_sq_ft INTEGER,
    year_built INTEGER,
    bedrooms INTEGER,
    bathrooms DECIMAL(3,1), -- e.g., 2.5
    
    -- Mortgage information
    mortgage_status mortgage_status_enum NOT NULL DEFAULT 'none',
    mortgage_lender VARCHAR(255),
    mortgage_balance DECIMAL(15,2),
    mortgage_payment DECIMAL(15,2),
    
    -- Rental income (if applicable)
    is_rental BOOLEAN DEFAULT false,
    monthly_rental_income DECIMAL(15,2),
    
    -- Insurance information
    insurance_company VARCHAR(255),
    insurance_policy_number VARCHAR(100),
    insurance_contact_name VARCHAR(255),
    insurance_contact_email_id UUID REFERENCES email_address(id),
    insurance_contact_phone_id UUID REFERENCES phone_number(id),
    
    -- Tax information
    annual_property_tax DECIMAL(15,2),
    tax_assessment_value DECIMAL(15,2),
    
    -- Documentation
    deed_document_id UUID REFERENCES media_storage(id),
    insurance_document_id UUID REFERENCES media_storage(id),
    appraisal_document_id UUID REFERENCES media_storage(id),
    property_images UUID[] DEFAULT '{}', -- Array of media_storage IDs
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (bedrooms IS NULL OR bedrooms >= 0),
    CHECK (bathrooms IS NULL OR bathrooms >= 0)
);

-- Index for property images array
CREATE INDEX idx_real_estate_images ON real_estate USING gin(property_images);

-- Table 33: life_insurance
-- Purpose: Stores life insurance policies
CREATE TABLE life_insurance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Policy identification
    policy_number VARCHAR(100) NOT NULL,
    insurer_name VARCHAR(255) NOT NULL,
    policy_type life_insurance_policy_type_enum NOT NULL,
    policy_status life_insurance_policy_status_enum NOT NULL DEFAULT 'active',
    
    -- Policy holder and insured
    policy_holder_persona_id UUID NOT NULL REFERENCES personas(id),
    policy_holder_name VARCHAR(255) NOT NULL, -- For display
    insured_persona_id UUID NOT NULL REFERENCES personas(id),
    insured_name VARCHAR(255) NOT NULL, -- For display
    owner_relationship_to_insured VARCHAR(100),
    
    -- Note: Beneficiaries are tracked through asset_persona table with ownership_type = 'beneficiary'
    
    -- Policy values
    face_value DECIMAL(15,2) NOT NULL, -- Death benefit
    cash_value DECIMAL(15,2), -- Current cash value (whole/universal)
    loan_balance DECIMAL(15,2) DEFAULT 0,
    
    -- Premium information
    premium_amount DECIMAL(15,2) NOT NULL,
    payment_frequency payment_frequency_enum NOT NULL,
    
    -- Policy dates
    issue_date DATE NOT NULL,
    maturity_date DATE, -- For term policies
    policy_term_years INTEGER, -- For term life
    last_premium_paid_date DATE,
    
    -- Riders (simple text array)
    riders TEXT[], -- "Waiver of Premium", "Accidental Death", etc.
    
    -- Insurance company contact
    insurer_contact_name VARCHAR(255),
    insurer_contact_email_id UUID REFERENCES email_address(id),
    insurer_contact_phone_id UUID REFERENCES phone_number(id),
    
    -- Documentation
    policy_document_id UUID REFERENCES media_storage(id),
    beneficiary_form_document_id UUID REFERENCES media_storage(id),
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (face_value > 0),
    CHECK (cash_value IS NULL OR cash_value >= 0),
    CHECK (loan_balance >= 0),
    CHECK (premium_amount > 0),
    CHECK (policy_term_years IS NULL OR policy_term_years > 0)
);

-- Table 34: financial_accounts
-- Purpose: Stores investment accounts, bank accounts, retirement accounts, college savings
CREATE TABLE financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Account identification
    account_type financial_account_type_enum NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_number_masked VARCHAR(20), -- e.g., "****1234"
    
    -- Institution information
    institution_name VARCHAR(255) NOT NULL,
    institution_contact_name VARCHAR(255),
    institution_contact_email_id UUID REFERENCES email_address(id),
    institution_contact_phone_id UUID REFERENCES phone_number(id),
    
    -- Account details
    currency_code VARCHAR(3) DEFAULT 'USD',
    current_balance DECIMAL(15,2),
    balance_as_of_date DATE,
    
    -- Retirement account specifics
    contributions_to_date DECIMAL(15,2),
    employer_contributions DECIMAL(15,2),
    vested_percentage DECIMAL(5,2),
    
    -- Financial advisor
    advisor_name VARCHAR(255),
    advisor_email_id UUID REFERENCES email_address(id),
    advisor_phone_id UUID REFERENCES phone_number(id),
    advisor_contact_id UUID REFERENCES contact_info(id),
    
    -- Account access
    online_access BOOLEAN DEFAULT true,
    online_portal_url VARCHAR(500),
    
    -- Documentation
    statement_document_ids UUID[] DEFAULT '{}', -- Array of media_storage IDs
    
    -- External integration
    external_account_id VARCHAR(255), -- For financial aggregators
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (current_balance IS NULL OR current_balance >= 0),
    CHECK (contributions_to_date IS NULL OR contributions_to_date >= 0),
    CHECK (employer_contributions IS NULL OR employer_contributions >= 0),
    CHECK (vested_percentage IS NULL OR (vested_percentage >= 0 AND vested_percentage <= 100))
);

-- Index for statements array
CREATE INDEX idx_financial_accounts_statements ON financial_accounts USING gin(statement_document_ids);

-- Table 35: recurring_income
-- Purpose: Stores royalties, residuals, annuities, and other recurring income streams
CREATE TABLE recurring_income (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Income identification
    income_type recurring_income_type_enum NOT NULL,
    income_name VARCHAR(255) NOT NULL,
    source_name VARCHAR(255) NOT NULL, -- Entity paying the income
    payer_type payer_type_enum NOT NULL,
    
    -- Original work/source details
    original_work_title VARCHAR(500), -- Book title, song name, property address
    work_identifier VARCHAR(200), -- ISBN, ISRC, Patent #, etc.
    
    -- Payment details
    payment_frequency payment_frequency_enum NOT NULL,
    payment_amount DECIMAL(15,2), -- Typical payment amount
    payment_currency VARCHAR(3) DEFAULT 'USD',
    gross_income_ytd DECIMAL(15,2),
    
    -- Contract information
    contract_reference VARCHAR(200),
    contract_start_date DATE,
    contract_end_date DATE,
    contract_terms_summary TEXT,
    is_transferable BOOLEAN DEFAULT false,
    
    -- Payer contact information
    contact_name VARCHAR(255),
    contact_email_id UUID REFERENCES email_address(id),
    contact_phone_id UUID REFERENCES phone_number(id),
    
    -- Documentation
    contract_document_id UUID REFERENCES media_storage(id),
    statement_document_ids UUID[] DEFAULT '{}', -- Array of payment statements
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    termination_date DATE,
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (payment_amount IS NULL OR payment_amount >= 0),
    CHECK (gross_income_ytd IS NULL OR gross_income_ytd >= 0),
    CHECK (contract_end_date IS NULL OR contract_end_date >= contract_start_date)
);

-- Index for statement documents array
CREATE INDEX idx_recurring_income_statements ON recurring_income USING gin(statement_document_ids);

-- Table 36: digital_assets
-- Purpose: Stores intellectual property, digital assets, domains, crypto, NFTs, etc.
CREATE TABLE digital_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Asset identification
    asset_type digital_asset_type_enum NOT NULL,
    title_or_name VARCHAR(500) NOT NULL,
    description TEXT,
    
    -- Registration details
    registry_or_platform VARCHAR(255), -- USPTO, Ethereum, GoDaddy, Twitter, etc.
    registration_number VARCHAR(255),
    registration_date DATE,
    registration_status registration_status_enum,
    
    -- Expiration and renewal
    expiration_date DATE,
    renewal_date DATE,
    renewal_cost DECIMAL(15,2),
    auto_renewal BOOLEAN DEFAULT false,
    
    -- Valuation
    current_value DECIMAL(15,2),
    valuation_date DATE,
    valuation_method valuation_method_enum,
    
    -- Digital asset specifics
    linked_wallet_or_account VARCHAR(500), -- Wallet address, account handle
    blockchain_network VARCHAR(100), -- For crypto/NFT
    contract_address VARCHAR(255), -- For NFT/tokens
    token_id VARCHAR(255), -- For NFT
    
    -- Access and security
    access_credentials_location VARCHAR(500), -- "Password manager", "Safe deposit box"
    two_factor_enabled BOOLEAN DEFAULT false,
    recovery_codes_stored BOOLEAN DEFAULT false,
    
    -- Transfer and income
    is_transferable BOOLEAN DEFAULT true,
    generates_income BOOLEAN DEFAULT false,
    
    -- Documentation
    ownership_document_id UUID REFERENCES media_storage(id),
    backup_document_ids UUID[] DEFAULT '{}', -- Recovery codes, backups
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (current_value IS NULL OR current_value >= 0),
    CHECK (renewal_cost IS NULL OR renewal_cost >= 0),
    CHECK (expiration_date IS NULL OR expiration_date > registration_date)
);

-- Table 37: ownership_interests
-- Purpose: Stores business ownership interests, partnerships, franchises, timeshares, etc.
CREATE TABLE ownership_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Interest identification
    interest_type ownership_interest_type_enum NOT NULL,
    entity_name VARCHAR(255) NOT NULL,
    entity_description TEXT,
    
    -- Registration details
    registration_country VARCHAR(2) NOT NULL, -- ISO country code
    registration_state VARCHAR(100),
    registration_number VARCHAR(100),
    formation_date DATE,
    tax_id_ein VARCHAR(50),
    
    -- Ownership structure
    ownership_structure ownership_structure_enum,
    total_shares INTEGER,
    
    -- Valuation
    current_valuation DECIMAL(20,2),
    valuation_date DATE,
    valuation_method ownership_valuation_method_enum,
    valuation_source VARCHAR(255),
    
    -- Business details
    is_active_business BOOLEAN DEFAULT true,
    industry_code VARCHAR(10), -- NAICS or SIC
    industry_description VARCHAR(255),
    
    -- Legal and tax
    fiscal_year_end VARCHAR(5), -- MM-DD format
    generates_k1 BOOLEAN DEFAULT false,
    tax_classification VARCHAR(100),
    
    -- Contacts
    legal_representative VARCHAR(255),
    registered_agent VARCHAR(255),
    primary_contact_email_id UUID REFERENCES email_address(id),
    primary_contact_phone_id UUID REFERENCES phone_number(id),
    primary_contact_address_id UUID REFERENCES physical_address(id),
    
    -- Governance
    has_operating_agreement BOOLEAN DEFAULT false,
    has_buy_sell_agreement BOOLEAN DEFAULT false,
    transfer_restrictions TEXT,
    
    -- Documentation
    formation_document_id UUID REFERENCES media_storage(id),
    operating_agreement_id UUID REFERENCES media_storage(id),
    financial_statements_id UUID REFERENCES media_storage(id),
    
    -- Status
    business_status VARCHAR(50) DEFAULT 'active',
    dissolution_date DATE,
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (current_valuation IS NULL OR current_valuation >= 0),
    CHECK (total_shares IS NULL OR total_shares > 0),
    CHECK (dissolution_date IS NULL OR dissolution_date >= formation_date)
);

-- Table 38: loans
-- Purpose: Stores loans (given or received), interfamily loans, HEI agreements, etc.
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Loan identification
    loan_type loan_type_enum NOT NULL,
    loan_name VARCHAR(255) NOT NULL, -- "Loan to John Smith", "Home Equity Investment from Point"
    loan_description TEXT,
    
    -- Parties
    lender_type loan_lender_type_enum NOT NULL,
    lender_name VARCHAR(255) NOT NULL,
    lender_contact_email_id UUID REFERENCES email_address(id),
    lender_contact_phone_id UUID REFERENCES phone_number(id),
    
    borrower_name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100), -- For interfamily loans
    
    -- Loan terms
    principal_amount DECIMAL(19,2) NOT NULL,
    interest_rate DECIMAL(7,4), -- Annual percentage rate
    interest_type loan_interest_type_enum,
    afr_rate DECIMAL(7,4), -- Applicable Federal Rate if used
    
    -- Dates
    loan_date DATE NOT NULL,
    first_payment_date DATE,
    maturity_date DATE,
    
    -- Payment information
    payment_frequency payment_frequency_enum,
    payment_amount DECIMAL(19,2),
    balance_remaining DECIMAL(19,2),
    last_payment_date DATE,
    
    -- Status
    payment_status loan_payment_status_enum DEFAULT 'current',
    is_secured BOOLEAN DEFAULT false,
    collateral_description TEXT,
    
    -- Documentation
    loan_agreement_id UUID REFERENCES media_storage(id),
    promissory_note_id UUID REFERENCES media_storage(id),
    payment_history_id UUID REFERENCES media_storage(id),
    
    -- HEI specific fields
    hei_percentage DECIMAL(5,2), -- For HEI: percentage of home value
    hei_buyback_terms TEXT, -- Terms for buying back the HEI stake
    
    -- Notes
    notes TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    CHECK (principal_amount > 0),
    CHECK (interest_rate IS NULL OR interest_rate >= 0),
    CHECK (balance_remaining IS NULL OR balance_remaining >= 0),
    CHECK (hei_percentage IS NULL OR (hei_percentage > 0 AND hei_percentage <= 100)),
    CHECK (maturity_date IS NULL OR maturity_date > loan_date)
);

-- Index for backup documents array
CREATE INDEX idx_digital_assets_backups ON digital_assets USING gin(backup_document_ids);

-- ================================================================
-- AUDIT TABLES
-- ================================================================

-- TODO: Add audit tables here
-- audit_log, audit_events, etc.

-- ================================================================
-- INDEXES
-- ================================================================

-- TODO: Add all indexes here

-- ================================================================
-- CONSTRAINTS
-- ================================================================

-- TODO: Add foreign key constraints and other constraints here