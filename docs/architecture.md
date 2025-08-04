# Forward Inheritance Platform - Technical Architecture

## Table of Contents

1. [Database Schema](#database-schema)
   - [Enums](#enums)
   - [Supporting Tables](#supporting-tables)
   - [Core Tables](#core-tables)
   - [Contact Tables](#contact-tables)
   - [Relationship Tables](#relationship-tables)
   - [Security Tables](#security-tables)
   - [Asset Tables](#asset-tables)
   - [Audit Tables](#audit-tables)
2. [Indexes](#indexes)
3. [Constraints](#constraints)
4. [Functions and Stored Procedures](#functions-and-stored-procedures)

---

## Database Schema

### Enums

```sql
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

-- Security Enums
CREATE TYPE mfa_type_enum AS ENUM (
    'totp',
    'sms',
    'email',
    'backup_codes'
);

CREATE TYPE session_status_enum AS ENUM (
    'active',
    'expired',
    'revoked',
    'logged_out'
);

-- Audit Enums
CREATE TYPE audit_action_enum AS ENUM (
    'create',
    'read',
    'update',
    'delete',
    'login',
    'logout',
    'invite',
    'approve',
    'reject',
    'export',
    'import'
);

CREATE TYPE audit_entity_type_enum AS ENUM (
    'user',
    'persona',
    'asset',
    'ffc',
    'invitation',
    'document',
    'permission'
);

-- PII Enums
CREATE TYPE pii_type_enum AS ENUM (
    'ssn',
    'tax_id',
    'drivers_license',
    'passport',
    'bank_account',
    'credit_card',
    'date_of_birth',
    'full_name',
    'address',
    'phone',
    'email'
);

CREATE TYPE pii_confidence_enum AS ENUM (
    'high',
    'medium',
    'low'
);

CREATE TYPE masking_strategy_enum AS ENUM (
    'full_mask',
    'partial_mask',
    'tokenize',
    'encrypt',
    'redact'
);

-- Translation Enums
CREATE TYPE language_code_enum AS ENUM (
    'en',
    'es',
    'fr',
    'pt',
    'zh',
    'ar'
);

CREATE TYPE translation_status_enum AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'approved',
    'rejected'
);

-- Integration Enums
CREATE TYPE integration_type_enum AS ENUM (
    'builder_io',
    'quillt',
    'real_estate_provider',
    'hei_provider',
    'document_processor',
    'identity_verifier'
);

CREATE TYPE webhook_status_enum AS ENUM (
    'pending',
    'processing',
    'success',
    'failed',
    'retrying'
);

CREATE TYPE sync_status_enum AS ENUM (
    'never_synced',
    'syncing',
    'completed',
    'failed',
    'partial'
);
```

### Supporting Tables

```sql
-- ================================================================
-- SUPPORTING TABLES
-- ================================================================

-- Table 1: tenants
-- Purpose: Multi-tenant support for white-label deployments
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
```

### Core Tables

```sql
-- ================================================================
-- CORE TABLES
-- ================================================================

-- Table 4: users
-- Purpose: Authentication and user account management
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
```

### Contact Tables

```sql
-- ================================================================
-- CONTACT TABLES
-- ================================================================

-- Table 7: phone_number
-- Purpose: Normalized phone storage with international support
CREATE TABLE phone_number (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
```

### Relationship Tables

```sql
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
```

### Security Tables

```sql
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
```

### Invitation Tables

```sql
-- ================================================================
-- INVITATION TABLES
-- ================================================================

-- Table 21: ffc_invitations
-- Purpose: Manage invitations to join Forward Family Circles
CREATE TABLE ffc_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
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
```

### Asset Tables

```sql
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
    primary_contact_address_id UUID REFERENCES address(id),
    
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
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
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
```

### Audit Tables

```sql
-- ================================================================
-- SECURITY TABLES
-- ================================================================

-- Table 39: user_sessions
-- Purpose: Track active user sessions for security and single sign-on
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Session details
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    
    -- Session metadata
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_id VARCHAR(255),
    device_name VARCHAR(255),
    
    -- Session lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    refresh_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Session status
    status session_status_enum NOT NULL DEFAULT 'active',
    revoked_at TIMESTAMP WITH TIME ZONE,
    revoked_by UUID REFERENCES users(id),
    revocation_reason TEXT,
    
    -- Security tracking
    is_remember_me BOOLEAN DEFAULT false,
    mfa_verified BOOLEAN DEFAULT false,
    mfa_verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CHECK (expires_at > created_at),
    CHECK (refresh_expires_at IS NULL OR refresh_expires_at > expires_at)
);

-- Table 40: user_mfa_settings
-- Purpose: Multi-factor authentication configuration per user
CREATE TABLE user_mfa_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- MFA configuration
    mfa_type mfa_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    is_enabled BOOLEAN DEFAULT true,
    
    -- TOTP specific
    totp_secret VARCHAR(255), -- Encrypted
    totp_verified BOOLEAN DEFAULT false,
    
    -- SMS/Email specific
    target_phone_id UUID REFERENCES phone_number(id),
    target_email_id UUID REFERENCES email_address(id),
    
    -- Backup codes
    backup_codes TEXT[], -- Encrypted array
    backup_codes_generated_at TIMESTAMP WITH TIME ZONE,
    used_backup_codes TEXT[], -- Track used codes
    
    -- Configuration
    last_used_at TIMESTAMP WITH TIME ZONE,
    configured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(user_id, mfa_type),
    CHECK (
        (mfa_type = 'sms' AND target_phone_id IS NOT NULL) OR
        (mfa_type = 'email' AND target_email_id IS NOT NULL) OR
        (mfa_type IN ('totp', 'backup_codes'))
    )
);

-- Table 41: password_reset_tokens
-- Purpose: Secure password reset token management
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Token details
    token_hash VARCHAR(255) UNIQUE NOT NULL, -- SHA-256 hash of token
    
    -- Token lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (NOW() + INTERVAL '1 hour'),
    used_at TIMESTAMP WITH TIME ZONE,
    
    -- Request metadata
    requested_ip INET NOT NULL,
    requested_user_agent TEXT,
    
    -- Usage tracking
    is_used BOOLEAN DEFAULT false,
    used_ip INET,
    
    -- Security
    failed_attempts INTEGER DEFAULT 0,
    
    -- Constraints
    CHECK (expires_at > created_at),
    CHECK (NOT is_used OR used_at IS NOT NULL)
);

-- Table 42: user_login_history
-- Purpose: Track login attempts for security monitoring
CREATE TABLE user_login_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL, -- Track even failed attempts
    
    -- Login attempt details
    attempt_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN NOT NULL,
    failure_reason VARCHAR(100), -- 'invalid_password', 'account_locked', etc.
    
    -- Request metadata
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    
    -- Geographic info (from IP)
    country_code VARCHAR(2),
    region VARCHAR(100),
    city VARCHAR(100),
    
    -- MFA tracking
    mfa_required BOOLEAN DEFAULT false,
    mfa_success BOOLEAN,
    mfa_type mfa_type_enum,
    
    -- Session created
    session_id UUID REFERENCES user_sessions(id),
    
    -- Risk indicators
    is_suspicious BOOLEAN DEFAULT false,
    risk_score DECIMAL(3,2), -- 0.00 to 1.00
    risk_factors TEXT[]
);

-- ================================================================
-- AUDIT TABLES
-- ================================================================

-- Table 43: audit_log
-- Purpose: Comprehensive audit trail for all system actions
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Actor information
    user_id UUID REFERENCES users(id),
    persona_id UUID REFERENCES personas(id),
    session_id UUID REFERENCES user_sessions(id),
    
    -- Action details
    action audit_action_enum NOT NULL,
    entity_type audit_entity_type_enum NOT NULL,
    entity_id UUID NOT NULL,
    entity_name VARCHAR(255), -- For display purposes
    
    -- Change details
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Context
    ip_address INET,
    user_agent TEXT,
    request_id UUID, -- For correlating related actions
    
    -- Metadata
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes will be added for:
    -- tenant_id, user_id, entity_type, entity_id, occurred_at
);

-- Table 44: audit_events
-- Purpose: High-level business events for weekly reports
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    ffc_id UUID REFERENCES fwd_family_circles(id),
    
    -- Event classification
    event_category VARCHAR(50) NOT NULL, -- 'security', 'asset', 'membership', 'document'
    event_type VARCHAR(100) NOT NULL, -- 'new_member_joined', 'asset_added', etc.
    severity VARCHAR(20) DEFAULT 'info', -- 'info', 'warning', 'critical'
    
    -- Event details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    affected_users UUID[], -- Array of affected user IDs
    affected_personas UUID[], -- Array of affected persona IDs
    
    -- Event data
    event_data JSONB,
    
    -- Reporting
    included_in_weekly_report BOOLEAN DEFAULT true,
    report_sent_date DATE,
    
    -- Timestamps
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================================
-- PII PROCESSING TABLES
-- ================================================================

-- Table 45: pii_detection_rules
-- Purpose: Define rules for detecting PII in documents
CREATE TABLE pii_detection_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Rule identification
    rule_name VARCHAR(100) UNIQUE NOT NULL,
    pii_type pii_type_enum NOT NULL,
    
    -- Detection configuration
    pattern_regex TEXT,
    keywords TEXT[],
    confidence_threshold DECIMAL(3,2) DEFAULT 0.80,
    
    -- Rule settings
    is_active BOOLEAN DEFAULT true,
    applies_to_text BOOLEAN DEFAULT true,
    applies_to_images BOOLEAN DEFAULT false,
    
    -- Validation
    validation_function VARCHAR(255), -- Name of custom validation function
    example_matches TEXT[], -- Examples that should match
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Table 46: pii_processing_jobs
-- Purpose: Track PII detection and masking jobs on documents
CREATE TABLE pii_processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Document reference
    media_storage_id UUID NOT NULL REFERENCES media_storage(id),
    
    -- Job configuration
    job_type VARCHAR(50) NOT NULL, -- 'detection', 'masking', 'validation'
    priority INTEGER DEFAULT 5, -- 1-10, higher is more urgent
    
    -- Job status
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Results
    pii_detected JSONB, -- Array of detected PII with locations
    confidence_scores JSONB, -- Confidence for each detection
    masked_document_id UUID REFERENCES media_storage(id),
    
    -- Error handling
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    
    -- Processing metadata
    processing_time_ms INTEGER,
    processor_version VARCHAR(20),
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- Table 47: masking_configurations
-- Purpose: Configure how different PII types should be masked
CREATE TABLE masking_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Configuration scope
    pii_type pii_type_enum NOT NULL,
    document_type document_type_enum,
    
    -- Masking settings
    masking_strategy masking_strategy_enum NOT NULL,
    replacement_pattern VARCHAR(100), -- e.g., "XXX-XX-####" for SSN
    
    -- Retention settings
    retain_original BOOLEAN DEFAULT true,
    retention_days INTEGER DEFAULT 2555, -- 7 years default
    
    -- Access control
    unmask_permission VARCHAR(100), -- Required permission to unmask
    
    -- Configuration
    is_active BOOLEAN DEFAULT true,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(tenant_id, pii_type, document_type)
);

-- Table 48: pii_access_logs
-- Purpose: Track who accesses unmasked PII data
CREATE TABLE pii_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Access details
    user_id UUID NOT NULL REFERENCES users(id),
    document_id UUID NOT NULL REFERENCES media_storage(id),
    
    -- What was accessed
    pii_types_accessed pii_type_enum[],
    access_type VARCHAR(50), -- 'view', 'download', 'unmask'
    access_reason TEXT,
    
    -- Access context
    ip_address INET NOT NULL,
    session_id UUID REFERENCES user_sessions(id),
    
    -- Compliance
    legitimate_interest BOOLEAN DEFAULT true,
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamp
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ================================================================
-- TRANSLATION TABLES
-- ================================================================

-- Table 49: translations
-- Purpose: Store all UI and content translations
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Translation key
    translation_key VARCHAR(255) NOT NULL,
    namespace VARCHAR(100) DEFAULT 'common', -- 'common', 'assets', 'errors', etc.
    
    -- Language versions
    language_code language_code_enum NOT NULL,
    translation_text TEXT NOT NULL,
    
    -- Contextual information
    context_description TEXT, -- Help for translators
    max_length INTEGER, -- Character limit for UI constraints
    
    -- Status tracking
    status translation_status_enum DEFAULT 'pending',
    is_verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Version control
    version INTEGER DEFAULT 1,
    previous_text TEXT,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(translation_key, namespace, language_code)
);

-- Table 50: user_language_preferences
-- Purpose: Track user language preferences
CREATE TABLE user_language_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Language settings
    preferred_language language_code_enum NOT NULL DEFAULT 'en',
    fallback_language language_code_enum DEFAULT 'en',
    
    -- Regional settings
    date_format VARCHAR(20) DEFAULT 'MM/DD/YYYY',
    number_format VARCHAR(20) DEFAULT '1,234.56',
    currency_code VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    
    -- Accessibility
    prefer_simple_language BOOLEAN DEFAULT false,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(user_id)
);

-- ================================================================
-- ADVISOR AND INTEGRATION TABLES
-- ================================================================

-- Table 51: advisor_companies
-- Purpose: Simple advisor company information
CREATE TABLE advisor_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Company identification
    company_name VARCHAR(255) NOT NULL,
    company_type VARCHAR(100), -- 'law_firm', 'accounting_firm', 'financial_advisor', etc.
    
    -- Contact information
    primary_contact_name VARCHAR(255),
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    primary_address_id UUID REFERENCES address(id),
    website_url VARCHAR(500),
    
    -- Simple details
    specialties TEXT[], -- ['estate_planning', 'tax_planning', 'wealth_management']
    description TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- Table 52: builder_io_integrations
-- Purpose: Store Builder.io CMS content and configurations
CREATE TABLE builder_io_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Builder.io references
    builder_content_id VARCHAR(255) UNIQUE NOT NULL,
    builder_model_name VARCHAR(100) NOT NULL, -- 'landing-page', 'component', etc.
    
    -- Content versioning
    version INTEGER NOT NULL DEFAULT 1,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    
    -- A/B testing
    variant_name VARCHAR(100),
    is_control BOOLEAN DEFAULT false,
    traffic_percentage DECIMAL(5,2), -- 0.00 to 100.00
    
    -- Performance metrics
    impressions INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,4), -- Calculated field
    
    -- Content data
    content_data JSONB NOT NULL, -- Full Builder.io content
    meta_data JSONB, -- SEO, targeting, etc.
    
    -- Sync status
    last_synced_at TIMESTAMP WITH TIME ZONE,
    sync_status sync_status_enum DEFAULT 'never_synced',
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 53: quillt_integrations
-- Purpose: Quillt financial data aggregation integration
CREATE TABLE quillt_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Quillt connection
    quillt_connection_id VARCHAR(255) UNIQUE NOT NULL,
    quillt_profile_id VARCHAR(255) NOT NULL,
    
    -- Connection status
    connection_status VARCHAR(50) NOT NULL, -- 'active', 'expired', 'error'
    last_successful_sync TIMESTAMP WITH TIME ZONE,
    
    -- Linked accounts summary
    linked_institutions JSONB, -- Array of institution names and types
    total_accounts_linked INTEGER DEFAULT 0,
    
    -- Sync configuration
    sync_enabled BOOLEAN DEFAULT true,
    sync_frequency_hours INTEGER DEFAULT 24,
    next_sync_at TIMESTAMP WITH TIME ZONE,
    
    -- Error tracking
    last_error_code VARCHAR(50),
    last_error_message TEXT,
    consecutive_failures INTEGER DEFAULT 0,
    
    -- Security
    encrypted_access_token TEXT, -- Encrypted Quillt access token
    token_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    disconnected_at TIMESTAMP WITH TIME ZONE
);

-- Table 54: quillt_webhook_logs
-- Purpose: Track Quillt webhook events
CREATE TABLE quillt_webhook_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Webhook identification
    webhook_id VARCHAR(255) UNIQUE NOT NULL,
    event_type VARCHAR(100) NOT NULL, -- 'account.added', 'transaction.new', etc.
    
    -- Related entities
    quillt_integration_id UUID REFERENCES quillt_integrations(id),
    
    -- Webhook data
    payload JSONB NOT NULL,
    headers JSONB,
    
    -- Processing
    received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    status webhook_status_enum DEFAULT 'pending',
    
    -- Error handling
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Response
    response_code INTEGER,
    response_body TEXT
);

-- Table 55: real_estate_provider_integrations
-- Purpose: Integration with real estate data providers (Zillow, Redfin, etc.)
CREATE TABLE real_estate_provider_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    
    -- Provider details
    provider_name VARCHAR(100) NOT NULL, -- 'zillow', 'redfin', 'realtor', etc.
    api_version VARCHAR(20),
    
    -- API configuration
    api_endpoint VARCHAR(500) NOT NULL,
    api_key_encrypted TEXT, -- Encrypted API key
    
    -- Rate limiting
    rate_limit_requests INTEGER,
    rate_limit_window_seconds INTEGER,
    last_request_at TIMESTAMP WITH TIME ZONE,
    requests_this_window INTEGER DEFAULT 0,
    
    -- Integration status
    is_active BOOLEAN DEFAULT true,
    last_health_check TIMESTAMP WITH TIME ZONE,
    health_status VARCHAR(50), -- 'healthy', 'degraded', 'down'
    
    -- Usage tracking
    total_requests INTEGER DEFAULT 0,
    successful_requests INTEGER DEFAULT 0,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 56: real_estate_sync_logs
-- Purpose: Track property valuation syncs from external providers
CREATE TABLE real_estate_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Sync identification
    provider_integration_id UUID NOT NULL REFERENCES real_estate_provider_integrations(id),
    real_estate_id UUID NOT NULL REFERENCES real_estate(id),
    
    -- Property identification
    external_property_id VARCHAR(255), -- Provider's property ID
    property_address VARCHAR(500),
    
    -- Sync details
    sync_type VARCHAR(50), -- 'valuation', 'details', 'full'
    sync_triggered_by VARCHAR(50), -- 'scheduled', 'manual', 'webhook'
    
    -- Valuation data
    previous_value DECIMAL(15,2),
    new_value DECIMAL(15,2),
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    
    -- Additional data retrieved
    property_details JSONB, -- Beds, baths, sqft, etc.
    comparables JSONB, -- Nearby comparable sales
    market_trends JSONB, -- Local market data
    
    -- Sync status
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    status sync_status_enum DEFAULT 'syncing',
    
    -- Error tracking
    error_code VARCHAR(50),
    error_message TEXT,
    
    -- Response metadata
    api_response_time_ms INTEGER,
    data_freshness_days INTEGER -- How old the provider's data is
);

-- Create indexes for new tables
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_user_sessions_status ON user_sessions(status);

CREATE INDEX idx_login_history_user_id ON user_login_history(user_id);
CREATE INDEX idx_login_history_email ON user_login_history(email);
CREATE INDEX idx_login_history_attempt_time ON user_login_history(attempt_time);

CREATE INDEX idx_audit_log_tenant_user ON audit_log(tenant_id, user_id);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
CREATE INDEX idx_audit_log_occurred_at ON audit_log(occurred_at);

CREATE INDEX idx_audit_events_ffc ON audit_events(ffc_id);
CREATE INDEX idx_audit_events_category ON audit_events(event_category);
CREATE INDEX idx_audit_events_weekly_report ON audit_events(included_in_weekly_report, report_sent_date);

CREATE INDEX idx_pii_jobs_media ON pii_processing_jobs(media_storage_id);
CREATE INDEX idx_pii_jobs_status ON pii_processing_jobs(status);

CREATE INDEX idx_translations_key ON translations(translation_key, namespace);
CREATE INDEX idx_translations_language ON translations(language_code);

CREATE INDEX idx_builder_io_content ON builder_io_integrations(builder_content_id);
CREATE INDEX idx_quillt_user ON quillt_integrations(user_id);
CREATE INDEX idx_real_estate_sync_property ON real_estate_sync_logs(real_estate_id);
```

## Indexes

```sql
-- ================================================================
-- INDEXES
-- ================================================================

-- TODO: Add all indexes here
```

## Constraints

```sql
-- ================================================================
-- CONSTRAINTS
-- ================================================================

-- TODO: Add additional constraints, triggers, etc.
```

## Functions and Stored Procedures

```sql
-- ================================================================
-- FUNCTIONS AND STORED PROCEDURES
-- ================================================================

-- ================================================================
-- AUTHENTICATION AND USER MANAGEMENT PROCEDURES
-- ================================================================

-- Register new user
CREATE OR REPLACE FUNCTION sp_register_user(
    p_tenant_id UUID,
    p_email VARCHAR(255),
    p_phone VARCHAR(20),
    p_password_hash TEXT,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_referral_code VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    user_id UUID,
    persona_id UUID,
    verification_token UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_persona_id UUID;
    v_verification_token UUID;
BEGIN
    -- Create user
    INSERT INTO users (
        tenant_id, email, phone, password_hash, 
        email_verified, phone_verified, status
    ) VALUES (
        p_tenant_id, p_email, p_phone, p_password_hash,
        FALSE, FALSE, 'pending_verification'
    ) RETURNING users.user_id INTO v_user_id;
    
    -- Create default persona
    INSERT INTO personas (
        tenant_id, user_id, first_name, last_name,
        is_primary, status
    ) VALUES (
        p_tenant_id, v_user_id, p_first_name, p_last_name,
        TRUE, 'active'
    ) RETURNING personas.persona_id INTO v_persona_id;
    
    -- Create verification token
    v_verification_token := gen_random_uuid();
    INSERT INTO email_verifications (
        user_id, token, expires_at
    ) VALUES (
        v_user_id, v_verification_token, 
        CURRENT_TIMESTAMP + INTERVAL '24 hours'
    );
    
    -- Log registration event
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        p_tenant_id, v_user_id, 'user_registered', 'user', v_user_id,
        jsonb_build_object('referral_code', p_referral_code)
    );
    
    RETURN QUERY SELECT v_user_id, v_persona_id, v_verification_token;
END;
$$ LANGUAGE plpgsql;

-- User login
CREATE OR REPLACE FUNCTION sp_login_user(
    p_email VARCHAR(255),
    p_password_hash TEXT,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT NULL
) RETURNS TABLE (
    user_id UUID,
    tenant_id UUID,
    mfa_required BOOLEAN,
    session_token UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id UUID;
    v_mfa_required BOOLEAN;
    v_session_token UUID;
    v_password_valid BOOLEAN;
BEGIN
    -- Get user info
    SELECT u.user_id, u.tenant_id, u.mfa_enabled, 
           u.password_hash = p_password_hash
    INTO v_user_id, v_tenant_id, v_mfa_required, v_password_valid
    FROM users u
    WHERE u.email = p_email
    AND u.status = 'active';
    
    -- Log login attempt
    INSERT INTO user_login_history (
        user_id, ip_address, user_agent, device_info,
        attempt_time, success
    ) VALUES (
        v_user_id, p_ip_address, p_user_agent, p_device_info,
        CURRENT_TIMESTAMP, v_password_valid
    );
    
    IF NOT v_password_valid THEN
        RAISE EXCEPTION 'Invalid credentials';
    END IF;
    
    -- Create session if no MFA required
    IF NOT v_mfa_required THEN
        v_session_token := gen_random_uuid();
        INSERT INTO user_sessions (
            user_id, session_token, ip_address, user_agent,
            device_info, expires_at
        ) VALUES (
            v_user_id, v_session_token, p_ip_address, p_user_agent,
            p_device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
        );
    END IF;
    
    RETURN QUERY SELECT v_user_id, v_tenant_id, v_mfa_required, v_session_token;
END;
$$ LANGUAGE plpgsql;

-- Verify email
CREATE OR REPLACE FUNCTION sp_verify_email(
    p_token UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Find valid token
    SELECT user_id INTO v_user_id
    FROM email_verifications
    WHERE token = p_token
    AND expires_at > CURRENT_TIMESTAMP
    AND used_at IS NULL;
    
    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update user
    UPDATE users
    SET email_verified = TRUE,
        status = CASE 
            WHEN phone_verified THEN 'active'
            ELSE status
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = v_user_id;
    
    -- Mark token as used
    UPDATE email_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE token = p_token;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Verify phone
CREATE OR REPLACE FUNCTION sp_verify_phone(
    p_user_id UUID,
    p_code VARCHAR(6)
) RETURNS BOOLEAN AS $$
DECLARE
    v_valid BOOLEAN;
BEGIN
    -- Check if code is valid
    SELECT EXISTS (
        SELECT 1 FROM phone_verifications
        WHERE user_id = p_user_id
        AND code = p_code
        AND expires_at > CURRENT_TIMESTAMP
        AND used_at IS NULL
    ) INTO v_valid;
    
    IF NOT v_valid THEN
        RETURN FALSE;
    END IF;
    
    -- Update user
    UPDATE users
    SET phone_verified = TRUE,
        status = CASE 
            WHEN email_verified THEN 'active'
            ELSE status
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
    
    -- Mark code as used
    UPDATE phone_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id
    AND code = p_code;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Request password reset
CREATE OR REPLACE FUNCTION sp_request_password_reset(
    p_email VARCHAR(255)
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_token UUID;
BEGIN
    -- Get user
    SELECT user_id INTO v_user_id
    FROM users
    WHERE email = p_email
    AND status != 'deleted';
    
    IF v_user_id IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Create reset token
    v_token := gen_random_uuid();
    INSERT INTO password_reset_tokens (
        user_id, token, expires_at
    ) VALUES (
        v_user_id, v_token, 
        CURRENT_TIMESTAMP + INTERVAL '1 hour'
    );
    
    RETURN v_token;
END;
$$ LANGUAGE plpgsql;

-- Reset password
CREATE OR REPLACE FUNCTION sp_reset_password(
    p_token UUID,
    p_new_password_hash TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Find valid token
    SELECT user_id INTO v_user_id
    FROM password_reset_tokens
    WHERE token = p_token
    AND expires_at > CURRENT_TIMESTAMP
    AND used_at IS NULL;
    
    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update password
    UPDATE users
    SET password_hash = p_new_password_hash,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = v_user_id;
    
    -- Mark token as used
    UPDATE password_reset_tokens
    SET used_at = CURRENT_TIMESTAMP
    WHERE token = p_token;
    
    -- Invalidate all sessions
    UPDATE user_sessions
    SET is_active = FALSE
    WHERE user_id = v_user_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Check user permission
CREATE OR REPLACE FUNCTION fn_check_user_permission(
    p_user_id UUID,
    p_ffc_id UUID,
    p_permission_name VARCHAR(100)
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM ffc_members fm
        JOIN role_permissions rp ON rp.role_id = fm.role_id
        JOIN permissions p ON p.permission_id = rp.permission_id
        WHERE fm.user_id = p_user_id
        AND fm.ffc_id = p_ffc_id
        AND p.permission_name = p_permission_name
        AND fm.status = 'active'
    );
END;
$$ LANGUAGE plpgsql;

-- Create session
CREATE OR REPLACE FUNCTION sp_create_session(
    p_user_id UUID,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_session_token UUID;
BEGIN
    v_session_token := gen_random_uuid();
    
    INSERT INTO user_sessions (
        user_id, session_token, ip_address, user_agent,
        device_info, expires_at
    ) VALUES (
        p_user_id, v_session_token, p_ip_address, p_user_agent,
        p_device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
    );
    
    RETURN v_session_token;
END;
$$ LANGUAGE plpgsql;

-- Refresh session
CREATE OR REPLACE FUNCTION sp_refresh_session(
    p_session_token UUID
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_new_token UUID;
BEGIN
    -- Get user from valid session
    SELECT user_id INTO v_user_id
    FROM user_sessions
    WHERE session_token = p_session_token
    AND is_active = TRUE
    AND expires_at > CURRENT_TIMESTAMP;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid or expired session';
    END IF;
    
    -- Invalidate old session
    UPDATE user_sessions
    SET is_active = FALSE
    WHERE session_token = p_session_token;
    
    -- Create new session
    v_new_token := gen_random_uuid();
    INSERT INTO user_sessions (
        user_id, session_token, ip_address, user_agent,
        device_info, expires_at
    )
    SELECT user_id, v_new_token, ip_address, user_agent,
           device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
    FROM user_sessions
    WHERE session_token = p_session_token;
    
    RETURN v_new_token;
END;
$$ LANGUAGE plpgsql;

-- Validate session
CREATE OR REPLACE FUNCTION fn_validate_session(
    p_session_token UUID
) RETURNS TABLE (
    user_id UUID,
    tenant_id UUID,
    is_valid BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.user_id, u.tenant_id, TRUE AS is_valid
    FROM user_sessions s
    JOIN users u ON u.user_id = s.user_id
    WHERE s.session_token = p_session_token
    AND s.is_active = TRUE
    AND s.expires_at > CURRENT_TIMESTAMP
    AND u.status = 'active';
END;
$$ LANGUAGE plpgsql;

-- Revoke session
CREATE OR REPLACE FUNCTION sp_revoke_session(
    p_session_token UUID
) RETURNS VOID AS $$
BEGIN
    UPDATE user_sessions
    SET is_active = FALSE,
        revoked_at = CURRENT_TIMESTAMP
    WHERE session_token = p_session_token;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- UTILITY FUNCTIONS
-- ================================================================

-- Get current tenant ID from session
CREATE OR REPLACE FUNCTION fn_get_current_tenant_id() 
RETURNS UUID AS $$
BEGIN
    -- This would typically be set by the application layer
    -- using SET LOCAL or similar mechanism
    RETURN current_setting('app.current_tenant_id')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No tenant context set';
END;
$$ LANGUAGE plpgsql;

-- Get current user ID from session
CREATE OR REPLACE FUNCTION fn_get_current_user_id() 
RETURNS UUID AS $$
BEGIN
    -- This would typically be set by the application layer
    -- using SET LOCAL or similar mechanism
    RETURN current_setting('app.current_user_id')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No user context set';
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FFC MANAGEMENT PROCEDURES
-- ================================================================

-- Create FFC
CREATE OR REPLACE FUNCTION sp_create_ffc(
    p_tenant_id UUID,
    p_name VARCHAR(100),
    p_description TEXT,
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_ffc_id UUID;
BEGIN
    -- Create FFC
    INSERT INTO fwd_family_circles (
        tenant_id, name, description, created_by
    ) VALUES (
        p_tenant_id, p_name, p_description, p_created_by
    ) RETURNING ffc_id INTO v_ffc_id;
    
    -- Add creator as owner
    INSERT INTO ffc_members (
        ffc_id, user_id, role_id, invited_by, joined_at, status
    ) 
    SELECT v_ffc_id, p_created_by, role_id, p_created_by, CURRENT_TIMESTAMP, 'active'
    FROM roles 
    WHERE role_name = 'owner' AND tenant_id = p_tenant_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id
    ) VALUES (
        p_tenant_id, p_created_by, 'ffc_created', 'ffc', v_ffc_id
    );
    
    RETURN v_ffc_id;
END;
$$ LANGUAGE plpgsql;

-- Add FFC member
CREATE OR REPLACE FUNCTION sp_add_ffc_member(
    p_ffc_id UUID,
    p_user_id UUID,
    p_role_name VARCHAR(50),
    p_invited_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_role_id UUID;
    v_tenant_id UUID;
BEGIN
    -- Get tenant ID and role
    SELECT f.tenant_id, r.role_id 
    INTO v_tenant_id, v_role_id
    FROM fwd_family_circles f
    JOIN roles r ON r.tenant_id = f.tenant_id
    WHERE f.ffc_id = p_ffc_id
    AND r.role_name = p_role_name;
    
    -- Add member
    INSERT INTO ffc_members (
        ffc_id, user_id, role_id, invited_by, status
    ) VALUES (
        p_ffc_id, p_user_id, v_role_id, p_invited_by, 'active'
    );
    
    -- Log addition
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_invited_by, 'member_added', 'ffc', p_ffc_id,
        jsonb_build_object('new_member_id', p_user_id, 'role', p_role_name)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Update FFC member role
CREATE OR REPLACE FUNCTION sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_user_id UUID,
    p_new_role_name VARCHAR(50),
    p_updated_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_new_role_id UUID;
    v_old_role_name VARCHAR(50);
    v_tenant_id UUID;
BEGIN
    -- Get current role
    SELECT r.role_name, f.tenant_id
    INTO v_old_role_name, v_tenant_id
    FROM ffc_members fm
    JOIN roles r ON r.role_id = fm.role_id
    JOIN fwd_family_circles f ON f.ffc_id = fm.ffc_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.user_id = p_user_id;
    
    -- Get new role ID
    SELECT role_id INTO v_new_role_id
    FROM roles
    WHERE role_name = p_new_role_name
    AND tenant_id = v_tenant_id;
    
    -- Update role
    UPDATE ffc_members
    SET role_id = v_new_role_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND user_id = p_user_id;
    
    -- Log change
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_updated_by, 'member_role_changed', 'ffc', p_ffc_id,
        jsonb_build_object(
            'member_id', p_user_id, 
            'old_role', v_old_role_name,
            'new_role', p_new_role_name
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Remove FFC member
CREATE OR REPLACE FUNCTION sp_remove_ffc_member(
    p_ffc_id UUID,
    p_user_id UUID,
    p_removed_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM fwd_family_circles
    WHERE ffc_id = p_ffc_id;
    
    -- Soft delete member
    UPDATE ffc_members
    SET status = 'inactive',
        left_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND user_id = p_user_id;
    
    -- Log removal
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_removed_by, 'member_removed', 'ffc', p_ffc_id,
        jsonb_build_object('removed_member_id', p_user_id)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Get FFC members with roles
CREATE OR REPLACE FUNCTION fn_get_ffc_members(
    p_ffc_id UUID
) RETURNS TABLE (
    user_id UUID,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_name VARCHAR(50),
    joined_at TIMESTAMP,
    status status_enum
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.user_id,
        u.email,
        p.first_name,
        p.last_name,
        r.role_name,
        fm.joined_at,
        fm.status
    FROM ffc_members fm
    JOIN users u ON u.user_id = fm.user_id
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    JOIN roles r ON r.role_id = fm.role_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.status = 'active';
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- PERSONA MANAGEMENT PROCEDURES
-- ================================================================

-- Create persona
CREATE OR REPLACE FUNCTION sp_create_persona(
    p_tenant_id UUID,
    p_user_id UUID,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_date_of_birth DATE DEFAULT NULL,
    p_gender gender_enum DEFAULT NULL,
    p_marital_status marital_status_enum DEFAULT NULL,
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_persona_id UUID;
BEGIN
    -- Create persona
    INSERT INTO personas (
        tenant_id, user_id, first_name, last_name,
        date_of_birth, gender, marital_status, is_primary
    ) VALUES (
        p_tenant_id, p_user_id, p_first_name, p_last_name,
        p_date_of_birth, p_gender, p_marital_status, p_is_primary
    ) RETURNING persona_id INTO v_persona_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id
    ) VALUES (
        p_tenant_id, p_user_id, 'persona_created', 'persona', v_persona_id
    );
    
    RETURN v_persona_id;
END;
$$ LANGUAGE plpgsql;

-- Link personas (family relationships)
CREATE OR REPLACE FUNCTION sp_link_personas(
    p_persona1_id UUID,
    p_persona2_id UUID,
    p_relationship family_relationship_enum,
    p_created_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM personas
    WHERE persona_id = p_persona1_id;
    
    -- Create bidirectional relationship
    INSERT INTO persona_relationships (
        persona_id, related_persona_id, relationship_type
    ) VALUES
        (p_persona1_id, p_persona2_id, p_relationship),
        (p_persona2_id, p_persona1_id, p_relationship);
    
    -- Log relationship
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_created_by, 'personas_linked', 'persona', p_persona1_id,
        jsonb_build_object(
            'persona2_id', p_persona2_id,
            'relationship', p_relationship
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ASSET CRUD PROCEDURES
-- ================================================================

-- Create generic asset
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id UUID,
    p_asset_category VARCHAR(50),
    p_name VARCHAR(255),
    p_description TEXT,
    p_created_by UUID,
    p_metadata JSONB DEFAULT '{}'::JSONB
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
BEGIN
    -- Create asset
    INSERT INTO assets (
        tenant_id, asset_category, name, description, 
        created_by, metadata
    ) VALUES (
        p_tenant_id, p_asset_category, p_name, p_description,
        p_created_by, p_metadata
    ) RETURNING asset_id INTO v_asset_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        p_tenant_id, p_created_by, 'asset_created', 'asset', v_asset_id,
        jsonb_build_object('category', p_asset_category)
    );
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Assign asset to persona
CREATE OR REPLACE FUNCTION sp_assign_asset_to_persona(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum,
    p_ownership_percentage DECIMAL(5,2),
    p_assigned_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
    v_asset_category VARCHAR(50);
BEGIN
    -- Get asset info
    SELECT tenant_id, asset_category 
    INTO v_tenant_id, v_asset_category
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Create ownership record
    INSERT INTO asset_persona (
        asset_id, persona_id, ownership_type, ownership_percentage,
        assigned_date, assigned_by
    ) VALUES (
        p_asset_id, p_persona_id, p_ownership_type, p_ownership_percentage,
        CURRENT_TIMESTAMP, p_assigned_by
    );
    
    -- Log assignment
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_assigned_by, 'asset_assigned', 'asset', p_asset_id,
        jsonb_build_object(
            'persona_id', p_persona_id,
            'ownership_type', p_ownership_type,
            'ownership_percentage', p_ownership_percentage
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Create real estate asset
CREATE OR REPLACE FUNCTION sp_create_real_estate(
    p_tenant_id UUID,
    p_property_type property_type_enum,
    p_property_use property_use_enum,
    p_description TEXT,
    p_purchase_date DATE,
    p_purchase_price DECIMAL(15,2),
    p_current_value DECIMAL(15,2),
    p_address_id UUID,
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_real_estate_id UUID;
BEGIN
    -- Create base asset
    v_asset_id := sp_create_asset(
        p_tenant_id, 'real_estate', 
        p_property_type::TEXT || ' - ' || p_description,
        p_description, p_created_by
    );
    
    -- Create real estate record
    INSERT INTO real_estate (
        real_estate_id, asset_id, property_type, property_use,
        description, purchase_date, purchase_price, current_value,
        address_id
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_property_type, p_property_use,
        p_description, p_purchase_date, p_purchase_price, p_current_value,
        p_address_id
    ) RETURNING real_estate_id INTO v_real_estate_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Create financial account
CREATE OR REPLACE FUNCTION sp_create_financial_account(
    p_tenant_id UUID,
    p_account_type account_type_enum,
    p_institution_name VARCHAR(255),
    p_account_number VARCHAR(50),
    p_current_balance DECIMAL(15,2),
    p_currency VARCHAR(3),
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_account_id UUID;
BEGIN
    -- Create base asset
    v_asset_id := sp_create_asset(
        p_tenant_id, 'financial_account',
        p_account_type::TEXT || ' - ' || p_institution_name,
        'Financial account at ' || p_institution_name,
        p_created_by
    );
    
    -- Create financial account record
    INSERT INTO financial_accounts (
        financial_account_id, asset_id, account_type,
        institution_name, account_number, current_balance,
        currency
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_account_type,
        p_institution_name, p_account_number, p_current_balance,
        p_currency
    ) RETURNING financial_account_id INTO v_account_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Update asset value
CREATE OR REPLACE FUNCTION sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_valuation_date DATE,
    p_updated_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
    v_asset_category VARCHAR(50);
    v_old_value DECIMAL(15,2);
BEGIN
    -- Get asset info
    SELECT tenant_id, asset_category
    INTO v_tenant_id, v_asset_category
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Update based on category
    CASE v_asset_category
        WHEN 'real_estate' THEN
            UPDATE real_estate
            SET current_value = p_new_value,
                last_valuation_date = p_valuation_date
            WHERE asset_id = p_asset_id
            RETURNING current_value INTO v_old_value;
            
        WHEN 'financial_account' THEN
            UPDATE financial_accounts
            SET current_balance = p_new_value
            WHERE asset_id = p_asset_id
            RETURNING current_balance INTO v_old_value;
            
        WHEN 'vehicle' THEN
            UPDATE vehicles
            SET current_value = p_new_value
            WHERE asset_id = p_asset_id
            RETURNING current_value INTO v_old_value;
            
        ELSE
            -- Update metadata for other categories
            UPDATE assets
            SET metadata = metadata || 
                jsonb_build_object('current_value', p_new_value)
            WHERE asset_id = p_asset_id;
    END CASE;
    
    -- Log value update
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_updated_by, 'asset_value_updated', 'asset', p_asset_id,
        jsonb_build_object(
            'old_value', v_old_value,
            'new_value', p_new_value,
            'valuation_date', p_valuation_date
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Delete asset (soft delete)
CREATE OR REPLACE FUNCTION sp_delete_asset(
    p_asset_id UUID,
    p_deleted_by UUID,
    p_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Soft delete asset
    UPDATE assets
    SET is_deleted = TRUE,
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = p_deleted_by,
        updated_at = CURRENT_TIMESTAMP
    WHERE asset_id = p_asset_id;
    
    -- Log deletion
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_deleted_by, 'asset_deleted', 'asset', p_asset_id,
        jsonb_build_object('reason', p_reason)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Get assets by persona
CREATE OR REPLACE FUNCTION fn_get_persona_assets(
    p_persona_id UUID
) RETURNS TABLE (
    asset_id UUID,
    asset_category VARCHAR(50),
    name VARCHAR(255),
    description TEXT,
    ownership_type ownership_type_enum,
    ownership_percentage DECIMAL(5,2),
    estimated_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.asset_id,
        a.asset_category,
        a.name,
        a.description,
        ap.ownership_type,
        ap.ownership_percentage,
        CASE 
            WHEN a.asset_category = 'real_estate' THEN 
                (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'financial_account' THEN
                (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'vehicle' THEN
                (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
            ELSE
                (a.metadata->>'current_value')::DECIMAL(15,2)
        END AS estimated_value
    FROM assets a
    JOIN asset_persona ap ON ap.asset_id = a.asset_id
    WHERE ap.persona_id = p_persona_id
    AND a.is_deleted = FALSE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- AUDIT LOGGING FUNCTIONS
-- ================================================================

-- Generic audit log function
CREATE OR REPLACE FUNCTION fn_audit_log(
    p_action VARCHAR(100),
    p_entity_type entity_type_enum,
    p_entity_id UUID,
    p_metadata JSONB DEFAULT NULL,
    p_tenant_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        metadata,
        ip_address,
        user_agent
    ) VALUES (
        COALESCE(p_tenant_id, fn_get_current_tenant_id()),
        COALESCE(p_user_id, fn_get_current_user_id()),
        p_action,
        p_entity_type,
        p_entity_id,
        p_metadata,
        inet_client_addr(),
        current_setting('app.user_agent', TRUE)
    );
END;
$$ LANGUAGE plpgsql;

-- Log audit event for weekly reports
CREATE OR REPLACE FUNCTION fn_log_audit_event(
    p_ffc_id UUID,
    p_event_category VARCHAR(50),
    p_event_type VARCHAR(100),
    p_event_description TEXT,
    p_affected_entity_type entity_type_enum,
    p_affected_entity_id UUID,
    p_performed_by UUID,
    p_metadata JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_event_id UUID;
BEGIN
    INSERT INTO audit_events (
        ffc_id,
        event_category,
        event_type,
        event_description,
        affected_entity_type,
        affected_entity_id,
        performed_by,
        metadata
    ) VALUES (
        p_ffc_id,
        p_event_category,
        p_event_type,
        p_event_description,
        p_affected_entity_type,
        p_affected_entity_id,
        p_performed_by,
        p_metadata
    ) RETURNING event_id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;

-- Generate weekly audit report
CREATE OR REPLACE FUNCTION fn_generate_weekly_audit_report(
    p_ffc_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
) RETURNS TABLE (
    event_id UUID,
    event_date DATE,
    event_time TIME,
    event_category VARCHAR(50),
    event_type VARCHAR(100),
    event_description TEXT,
    performed_by_name TEXT,
    affected_entity TEXT
) AS $$
BEGIN
    -- Default to last 7 days if dates not provided
    p_start_date := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '7 days');
    p_end_date := COALESCE(p_end_date, CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        ae.event_id,
        ae.event_timestamp::DATE AS event_date,
        ae.event_timestamp::TIME AS event_time,
        ae.event_category,
        ae.event_type,
        ae.event_description,
        CONCAT(p.first_name, ' ', p.last_name) AS performed_by_name,
        CASE 
            WHEN ae.affected_entity_type = 'asset' THEN
                (SELECT name FROM assets WHERE asset_id = ae.affected_entity_id)
            WHEN ae.affected_entity_type = 'persona' THEN
                (SELECT CONCAT(first_name, ' ', last_name) 
                 FROM personas WHERE persona_id = ae.affected_entity_id)
            ELSE ae.affected_entity_id::TEXT
        END AS affected_entity
    FROM audit_events ae
    JOIN users u ON u.user_id = ae.performed_by
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    WHERE ae.ffc_id = p_ffc_id
    AND ae.event_timestamp::DATE BETWEEN p_start_date AND p_end_date
    AND ae.included_in_weekly_report = TRUE
    ORDER BY ae.event_timestamp DESC;
END;
$$ LANGUAGE plpgsql;

-- Mark audit events as sent
CREATE OR REPLACE FUNCTION sp_mark_audit_events_sent(
    p_ffc_id UUID,
    p_report_date DATE
) RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE audit_events
    SET report_sent_date = p_report_date
    WHERE ffc_id = p_ffc_id
    AND included_in_weekly_report = TRUE
    AND report_sent_date IS NULL
    AND event_timestamp < p_report_date;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for automatic audit logging
CREATE OR REPLACE FUNCTION fn_trigger_audit_log() 
RETURNS TRIGGER AS $$
DECLARE
    v_action VARCHAR(100);
    v_entity_type entity_type_enum;
    v_entity_id UUID;
    v_metadata JSONB;
BEGIN
    -- Determine action
    IF TG_OP = 'INSERT' THEN
        v_action := TG_TABLE_NAME || '_created';
        v_entity_id := NEW.asset_id; -- Adjust based on table
        v_metadata := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := TG_TABLE_NAME || '_updated';
        v_entity_id := NEW.asset_id; -- Adjust based on table
        v_metadata := jsonb_build_object(
            'old', to_jsonb(OLD),
            'new', to_jsonb(NEW)
        );
    ELSIF TG_OP = 'DELETE' THEN
        v_action := TG_TABLE_NAME || '_deleted';
        v_entity_id := OLD.asset_id; -- Adjust based on table
        v_metadata := to_jsonb(OLD);
    END IF;
    
    -- Determine entity type based on table
    v_entity_type := CASE 
        WHEN TG_TABLE_NAME LIKE '%asset%' THEN 'asset'
        WHEN TG_TABLE_NAME LIKE '%persona%' THEN 'persona'
        WHEN TG_TABLE_NAME LIKE '%user%' THEN 'user'
        ELSE 'asset'
    END;
    
    -- Log the action
    PERFORM fn_audit_log(
        v_action,
        v_entity_type,
        v_entity_id,
        v_metadata
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Get audit history for an entity
CREATE OR REPLACE FUNCTION fn_get_entity_audit_history(
    p_entity_type entity_type_enum,
    p_entity_id UUID,
    p_limit INTEGER DEFAULT 100
) RETURNS TABLE (
    log_id UUID,
    action VARCHAR(100),
    user_email VARCHAR(255),
    occurred_at TIMESTAMP,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.log_id,
        al.action,
        u.email AS user_email,
        al.occurred_at,
        al.metadata
    FROM audit_log al
    LEFT JOIN users u ON u.user_id = al.user_id
    WHERE al.entity_type = p_entity_type
    AND al.entity_id = p_entity_id
    ORDER BY al.occurred_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- SEARCH AND REPORTING FUNCTIONS
-- ================================================================

-- Search assets by name or description
CREATE OR REPLACE FUNCTION fn_search_assets(
    p_tenant_id UUID,
    p_search_term TEXT,
    p_category VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
) RETURNS TABLE (
    asset_id UUID,
    asset_category VARCHAR(50),
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP,
    total_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.asset_id,
        a.asset_category,
        a.name,
        a.description,
        a.created_at,
        CASE 
            WHEN a.asset_category = 'real_estate' THEN 
                (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'financial_account' THEN
                (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'vehicle' THEN
                (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
            ELSE
                (a.metadata->>'current_value')::DECIMAL(15,2)
        END AS total_value
    FROM assets a
    WHERE a.tenant_id = p_tenant_id
    AND a.is_deleted = FALSE
    AND (p_category IS NULL OR a.asset_category = p_category)
    AND (
        a.name ILIKE '%' || p_search_term || '%' OR
        a.description ILIKE '%' || p_search_term || '%'
    )
    ORDER BY a.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Get FFC net worth summary
CREATE OR REPLACE FUNCTION fn_get_ffc_net_worth(
    p_ffc_id UUID
) RETURNS TABLE (
    asset_category VARCHAR(50),
    total_count INTEGER,
    total_value DECIMAL(15,2),
    liability_value DECIMAL(15,2),
    net_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH ffc_personas AS (
        SELECT DISTINCT p.persona_id
        FROM ffc_members fm
        JOIN personas p ON p.user_id = fm.user_id
        WHERE fm.ffc_id = p_ffc_id
        AND fm.status = 'active'
    ),
    asset_values AS (
        SELECT 
            a.asset_category,
            COUNT(DISTINCT a.asset_id) AS asset_count,
            SUM(
                CASE 
                    WHEN a.asset_category = 'real_estate' THEN 
                        (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'financial_account' THEN
                        (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'vehicle' THEN
                        (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'loan' THEN
                        -(SELECT balance_remaining_usd FROM loans WHERE asset_id = a.asset_id)
                    ELSE
                        COALESCE((a.metadata->>'current_value')::DECIMAL(15,2), 0)
                END * (ap.ownership_percentage / 100)
            ) AS total_value
        FROM assets a
        JOIN asset_persona ap ON ap.asset_id = a.asset_id
        JOIN ffc_personas fp ON fp.persona_id = ap.persona_id
        WHERE a.is_deleted = FALSE
        GROUP BY a.asset_category
    )
    SELECT 
        av.asset_category,
        av.asset_count::INTEGER AS total_count,
        CASE 
            WHEN av.asset_category = 'loan' THEN 0
            ELSE COALESCE(av.total_value, 0)
        END AS total_value,
        CASE 
            WHEN av.asset_category = 'loan' THEN ABS(COALESCE(av.total_value, 0))
            ELSE 0
        END AS liability_value,
        COALESCE(av.total_value, 0) AS net_value
    FROM asset_values av
    ORDER BY av.asset_category;
END;
$$ LANGUAGE plpgsql;

-- Get persona document summary
CREATE OR REPLACE FUNCTION fn_get_persona_documents(
    p_persona_id UUID,
    p_category document_category_enum DEFAULT NULL
) RETURNS TABLE (
    document_id UUID,
    document_type document_type_enum,
    document_category document_category_enum,
    title VARCHAR(255),
    upload_date TIMESTAMP,
    file_size BIGINT,
    is_pii_processed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.document_id,
        d.document_type,
        d.document_category,
        d.title,
        d.created_at AS upload_date,
        ms.file_size,
        EXISTS(
            SELECT 1 FROM pii_processing_jobs ppj
            WHERE ppj.media_storage_id = d.media_storage_id
            AND ppj.status = 'completed'
        ) AS is_pii_processed
    FROM documents d
    JOIN media_storage ms ON ms.media_id = d.media_storage_id
    WHERE d.persona_id = p_persona_id
    AND (p_category IS NULL OR d.document_category = p_category)
    AND d.is_deleted = FALSE
    ORDER BY d.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Generate FFC activity report
CREATE OR REPLACE FUNCTION fn_generate_ffc_activity_report(
    p_ffc_id UUID,
    p_start_date DATE,
    p_end_date DATE
) RETURNS TABLE (
    activity_date DATE,
    activity_type VARCHAR(100),
    user_name TEXT,
    description TEXT,
    affected_assets INTEGER,
    affected_personas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.occurred_at::DATE AS activity_date,
        al.action AS activity_type,
        CONCAT(p.first_name, ' ', p.last_name) AS user_name,
        CASE 
            WHEN al.action LIKE '%asset%' THEN 
                'Asset operation: ' || COALESCE((al.metadata->>'name')::TEXT, al.entity_id::TEXT)
            WHEN al.action LIKE '%persona%' THEN 
                'Persona operation: ' || al.entity_id::TEXT
            ELSE al.action
        END AS description,
        CASE WHEN al.entity_type = 'asset' THEN 1 ELSE 0 END AS affected_assets,
        CASE WHEN al.entity_type = 'persona' THEN 1 ELSE 0 END AS affected_personas
    FROM audit_log al
    JOIN users u ON u.user_id = al.user_id
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    JOIN ffc_members fm ON fm.user_id = u.user_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.status = 'active'
    AND al.occurred_at::DATE BETWEEN p_start_date AND p_end_date
    ORDER BY al.occurred_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Search personas by name
CREATE OR REPLACE FUNCTION fn_search_personas(
    p_tenant_id UUID,
    p_search_term TEXT,
    p_limit INTEGER DEFAULT 50
) RETURNS TABLE (
    persona_id UUID,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    is_primary BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.persona_id,
        p.first_name,
        p.last_name,
        u.email,
        u.phone,
        p.date_of_birth,
        p.is_primary
    FROM personas p
    JOIN users u ON u.user_id = p.user_id
    WHERE p.tenant_id = p_tenant_id
    AND p.status = 'active'
    AND (
        p.first_name ILIKE '%' || p_search_term || '%' OR
        p.last_name ILIKE '%' || p_search_term || '%' OR
        u.email ILIKE '%' || p_search_term || '%'
    )
    ORDER BY p.last_name, p.first_name
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- INTEGRATION SYNC PROCEDURES
-- ================================================================

-- Sync Quillt financial data
CREATE OR REPLACE FUNCTION sp_sync_quillt_data(
    p_user_id UUID,
    p_quillt_data JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id UUID;
    v_sync_log_id UUID;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM users
    WHERE user_id = p_user_id;
    
    -- Get or create integration record
    SELECT integration_id INTO v_integration_id
    FROM quillt_integrations
    WHERE user_id = p_user_id;
    
    IF v_integration_id IS NULL THEN
        INSERT INTO quillt_integrations (
            user_id, quillt_user_id, connection_status
        ) VALUES (
            p_user_id, 
            p_quillt_data->>'quillt_user_id',
            'active'
        ) RETURNING integration_id INTO v_integration_id;
    END IF;
    
    -- Update last sync
    UPDATE quillt_integrations
    SET last_sync_at = CURRENT_TIMESTAMP,
        sync_data = p_quillt_data
    WHERE integration_id = v_integration_id;
    
    -- Log sync
    INSERT INTO quillt_sync_logs (
        integration_id, sync_type, sync_status, 
        records_synced, sync_metadata
    ) VALUES (
        v_integration_id, 'financial_accounts', 'completed',
        (p_quillt_data->>'account_count')::INTEGER,
        p_quillt_data
    ) RETURNING sync_log_id INTO v_sync_log_id;
    
    -- Create audit log
    PERFORM fn_audit_log(
        'quillt_data_synced',
        'user',
        p_user_id,
        jsonb_build_object(
            'sync_log_id', v_sync_log_id,
            'accounts_synced', p_quillt_data->>'account_count'
        ),
        v_tenant_id,
        p_user_id
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Sync real estate data from provider
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_real_estate_id UUID,
    p_provider_name VARCHAR(100),
    p_property_data JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    v_sync_log_id UUID;
    v_old_value DECIMAL(15,2);
    v_new_value DECIMAL(15,2);
    v_asset_id UUID;
BEGIN
    -- Get asset ID and current value
    SELECT asset_id, current_value 
    INTO v_asset_id, v_old_value
    FROM real_estate
    WHERE real_estate_id = p_real_estate_id;
    
    -- Update real estate data
    v_new_value := (p_property_data->>'estimated_value')::DECIMAL(15,2);
    
    UPDATE real_estate
    SET current_value = v_new_value,
        last_valuation_date = CURRENT_DATE,
        metadata = metadata || p_property_data
    WHERE real_estate_id = p_real_estate_id;
    
    -- Log sync
    INSERT INTO real_estate_sync_logs (
        real_estate_id, provider_name, sync_type,
        sync_status, property_data
    ) VALUES (
        p_real_estate_id, p_provider_name, 'valuation',
        'completed', p_property_data
    ) RETURNING sync_log_id INTO v_sync_log_id;
    
    -- Create audit event if value changed
    IF v_old_value != v_new_value THEN
        PERFORM fn_audit_log(
            'real_estate_value_synced',
            'asset',
            v_asset_id,
            jsonb_build_object(
                'provider', p_provider_name,
                'old_value', v_old_value,
                'new_value', v_new_value,
                'sync_log_id', v_sync_log_id
            )
        );
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Process PII masking job
CREATE OR REPLACE FUNCTION sp_process_pii_masking(
    p_job_id UUID,
    p_detected_pii JSONB,
    p_masked_file_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_media_id UUID;
    v_status pii_status_enum;
BEGIN
    -- Get media ID
    SELECT media_storage_id INTO v_media_id
    FROM pii_processing_jobs
    WHERE job_id = p_job_id;
    
    -- Update job status
    UPDATE pii_processing_jobs
    SET status = CASE 
            WHEN p_masked_file_id IS NOT NULL THEN 'completed'
            ELSE 'failed'
        END,
        detected_pii = p_detected_pii,
        masked_file_id = p_masked_file_id,
        completed_at = CURRENT_TIMESTAMP
    WHERE job_id = p_job_id;
    
    -- Update media storage PII flags
    UPDATE media_storage
    SET contains_pii = (p_detected_pii IS NOT NULL AND jsonb_array_length(p_detected_pii) > 0),
        pii_masked_version_id = p_masked_file_id
    WHERE media_id = v_media_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Update Builder.io content reference
CREATE OR REPLACE FUNCTION sp_update_builder_content(
    p_page_name VARCHAR(255),
    p_builder_content_id VARCHAR(255),
    p_content_data JSONB,
    p_updated_by UUID
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
BEGIN
    -- Upsert Builder.io integration record
    INSERT INTO builder_io_integrations (
        page_name, builder_content_id, content_data, 
        last_updated_by
    ) VALUES (
        p_page_name, p_builder_content_id, p_content_data,
        p_updated_by
    )
    ON CONFLICT (page_name) DO UPDATE
    SET builder_content_id = EXCLUDED.builder_content_id,
        content_data = EXCLUDED.content_data,
        last_sync_at = CURRENT_TIMESTAMP,
        last_updated_by = EXCLUDED.last_updated_by
    RETURNING integration_id INTO v_integration_id;
    
    -- Log update
    PERFORM fn_audit_log(
        'builder_content_updated',
        'asset',
        v_integration_id,
        jsonb_build_object(
            'page_name', p_page_name,
            'content_id', p_builder_content_id
        )
    );
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql;

-- Bulk update asset ownership
CREATE OR REPLACE FUNCTION sp_bulk_update_asset_ownership(
    p_updates JSONB
) RETURNS INTEGER AS $$
DECLARE
    v_update JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Process each update
    FOR v_update IN SELECT * FROM jsonb_array_elements(p_updates)
    LOOP
        UPDATE asset_persona
        SET ownership_percentage = (v_update->>'ownership_percentage')::DECIMAL(5,2),
            ownership_type = (v_update->>'ownership_type')::ownership_type_enum,
            updated_at = CURRENT_TIMESTAMP
        WHERE asset_id = (v_update->>'asset_id')::UUID
        AND persona_id = (v_update->>'persona_id')::UUID;
        
        v_count := v_count + 1;
    END LOOP;
    
    -- Log bulk update
    PERFORM fn_audit_log(
        'bulk_ownership_update',
        'asset',
        NULL,
        jsonb_build_object('updates_count', v_count)
    );
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Process invitation
CREATE OR REPLACE FUNCTION sp_process_invitation(
    p_invitation_id UUID,
    p_action VARCHAR(20), -- 'accept', 'decline', 'cancel'
    p_user_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_invitation RECORD;
    v_new_status invitation_status_enum;
BEGIN
    -- Get invitation details
    SELECT * INTO v_invitation
    FROM invitations
    WHERE invitation_id = p_invitation_id;
    
    -- Determine new status
    v_new_status := CASE p_action
        WHEN 'accept' THEN 'accepted'
        WHEN 'decline' THEN 'declined'
        WHEN 'cancel' THEN 'cancelled'
        ELSE v_invitation.status
    END;
    
    -- Update invitation
    UPDATE invitations
    SET status = v_new_status,
        responded_at = CASE 
            WHEN p_action IN ('accept', 'decline') THEN CURRENT_TIMESTAMP
            ELSE responded_at
        END
    WHERE invitation_id = p_invitation_id;
    
    -- If accepted, add to FFC
    IF p_action = 'accept' AND p_user_id IS NOT NULL THEN
        PERFORM sp_add_ffc_member(
            v_invitation.ffc_id,
            p_user_id,
            v_invitation.role,
            v_invitation.invited_by
        );
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- END OF STORED PROCEDURES
-- ================================================================
```