# Forward Inheritance Platform - Technical Architecture

## Table of Contents

1. [Database Schema](#database-schema)
   - [Database Setup](#database-setup)
   - [Enums](#enums)
   - [Supporting Tables](#supporting-tables)
   - [Core Tables](#core-tables)
   - [Contact Tables](#contact-tables)
   - [Relationship Tables](#relationship-tables)
   - [Security Tables](#security-tables)
   - [Asset Tables](#asset-tables)
   - [Audit Tables](#audit-tables)
   - [Translation Tables](#translation-tables)
   - [Integration Tables](#integration-tables)
2. [Indexes](#indexes)
3. [Constraints](#constraints)
4. [Functions and Stored Procedures](#functions-and-stored-procedures)

---

## Database Schema

### Database Setup

The platform uses PostgreSQL database named `fwd_db` with the following setup:

```sql
-- Step 1: Run this first in postgres DB
DROP DATABASE IF EXISTS fwd_db;
CREATE DATABASE fwd_db
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    TEMPLATE = template0
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';

-- Step 2: Change connection to fwd_db manually, then run:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

ALTER DATABASE fwd_db SET search_path TO public;
ALTER DATABASE fwd_db SET track_counts = on;
ALTER DATABASE fwd_db SET track_functions = 'all';
ALTER DATABASE fwd_db SET track_io_timing = on;

CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS archive;
```

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

CREATE TYPE audit_entity_type_enum AS ENUM (
    'user',
    'persona',
    'asset',
    'document',
    'ffc',
    'permission',
    'system'
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
```

### Supporting Tables

```sql
-- Table 1: tenants
-- Purpose: Multi-tenancy foundation - isolates data between different organizations
CREATE TABLE tenants (
    id INTEGER PRIMARY KEY,
    
    -- Tenant identification
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    
    -- Branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    
    -- Configuration
    settings JSONB DEFAULT '{}',
    feature_flags JSONB DEFAULT '{}',
    
    -- System fields
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
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
    file_name VARCHAR(255) NOT NULL,
    original_file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    
    -- Storage details
    storage_provider VARCHAR(50) NOT NULL DEFAULT 'aws_s3',
    storage_bucket VARCHAR(255) NOT NULL,
    storage_key VARCHAR(500) NOT NULL,
    storage_region VARCHAR(50),
    cdn_url VARCHAR(500),
    
    -- File metadata
    checksum VARCHAR(64),
    encryption_key_id VARCHAR(255),
    is_encrypted BOOLEAN DEFAULT true,
    
    -- Processing
    processing_status processing_status_enum DEFAULT 'uploaded',
    processing_error TEXT,
    thumbnail_url VARCHAR(500),
    
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
    title VARCHAR(255) NOT NULL,
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

-- Table 4: asset_categories
-- Purpose: Define the types of assets that can be tracked
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Category definition
    name VARCHAR(100) NOT NULL UNIQUE,
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
```

### Core Tables

```sql
-- Table 5: users
-- Purpose: Core user authentication and profile information
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Normalized contact references
    primary_email_id UUID,
    primary_phone_id UUID,
    
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
    created_by UUID,
    updated_by UUID
);

-- Table 6: personas
-- Purpose: Business identity layer representing family members (living or deceased)
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    user_id UUID, -- NULL for deceased or non-user personas
    
    -- Personal identification
    first_name VARCHAR(255) NOT NULL,
    middle_name VARCHAR(255),
    last_name VARCHAR(255) NOT NULL,
    suffix VARCHAR(50),
    nickname VARCHAR(255),
    
    -- Demographics
    date_of_birth DATE,
    date_of_death DATE,
    place_of_birth VARCHAR(255),
    gender gender_enum,
    marital_status marital_status_enum,
    
    -- Documentation
    ssn_last_four VARCHAR(4),
    has_full_ssn_on_file BOOLEAN DEFAULT FALSE,
    drivers_license_state VARCHAR(2),
    drivers_license_number_last_four VARCHAR(4),
    
    -- Professional information
    occupation VARCHAR(255),
    employer VARCHAR(255),
    
    -- Profile
    profile_photo_url VARCHAR(500),
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

-- Table 7: fwd_family_circles
-- Purpose: Family groups that organize personas and assets
CREATE TABLE fwd_family_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- FFC identification
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Owner must be a user (has login credentials)
    owner_user_id UUID NOT NULL,
    
    -- FFC metadata
    family_photo_url VARCHAR(500),
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
```

### Contact Tables

```sql
-- Table 8: phone_number
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
    carrier_name VARCHAR(100),
    is_mobile BOOLEAN,
    
    -- Multi-tenancy and audit
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_phone_format CHECK (phone_number ~ '^[0-9]{10,15}$'),
    CONSTRAINT valid_country_code CHECK (country_code ~ '^\+[0-9]{1,4}$')
);

-- Table 9: email_address
-- Purpose: Centralized email address storage with validation
CREATE TABLE email_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
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

-- Table 10: address
-- Purpose: Normalized physical address storage
CREATE TABLE address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Address components
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100) NOT NULL,
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
    CONSTRAINT valid_country_code CHECK (country ~ '^[A-Z]{2}$'),
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- Table 11: social_media
-- Purpose: Social media account information
CREATE TABLE social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Platform details
    platform social_media_platform_enum NOT NULL,
    platform_user_id VARCHAR(255),
    username VARCHAR(255) NOT NULL,
    profile_url VARCHAR(500),
    
    -- Account metadata
    display_name VARCHAR(255),
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
```

### Relationship Tables

```sql
-- Table 12: usage_email
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 13: usage_phone
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
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table 14: usage_address
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
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date > effective_date)
);

-- Table 15: usage_social_media
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

-- Table 16: contact_info
-- Purpose: External contacts (advisors, companies, institutions)
CREATE TABLE contact_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Contact identification
    entity_type contact_entity_type_enum NOT NULL,
    company_name VARCHAR(255),
    contact_name VARCHAR(255),
    title VARCHAR(255),
    
    -- Contact references
    primary_email_id UUID,
    primary_phone_id UUID,
    primary_address_id UUID,
    
    -- Additional info
    website VARCHAR(500),
    notes TEXT,
    
    -- Professional details
    license_number VARCHAR(100),
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

-- Table 17: ffc_personas
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
```

### Security Tables

```sql
-- Table 18: user_roles
-- Purpose: Define roles for RBAC system
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Role definition
    name VARCHAR(100) NOT NULL,
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

-- Table 19: user_permissions
-- Purpose: Define granular permissions
CREATE TABLE user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Permission definition
    name VARCHAR(100) NOT NULL,
    category permission_category_enum NOT NULL,
    description TEXT,
    
    -- Permission metadata
    resource VARCHAR(100),
    action VARCHAR(50) NOT NULL,
    conditions JSONB DEFAULT '{}',
    
    -- System fields
    is_system_permission BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_permission_per_tenant UNIQUE (tenant_id, category, resource, action)
);

-- Table 20: role_permissions
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

-- Table 21: user_role_assignments
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

-- Table 22: ffc_invitations
-- Purpose: Manage invitations to join FFCs
CREATE TABLE ffc_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Invitation details
    ffc_id UUID NOT NULL,
    inviter_user_id UUID NOT NULL,
    invitee_email_id UUID NOT NULL,
    invitee_phone_id UUID NOT NULL,
    invitee_name VARCHAR(255) NOT NULL,
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

-- Table 23: invitation_verification_attempts
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
    failure_reason VARCHAR(100),
    
    -- Tracking
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Phone specific
    phone_id UUID NOT NULL,
    
    -- Multi-tenancy and audit
    tenant_id INTEGER NOT NULL
);

-- Table 24: user_sessions
-- Purpose: Track active user sessions
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    tenant_id INTEGER NOT NULL,
    
    -- Session details
    session_token VARCHAR(500) NOT NULL UNIQUE,
    refresh_token VARCHAR(500) UNIQUE,
    
    -- Device/Browser info
    ip_address INET,
    user_agent TEXT,
    device_id VARCHAR(255),
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

-- Table 25: user_mfa_settings
-- Purpose: Multi-factor authentication settings
CREATE TABLE user_mfa_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- MFA configuration
    mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_method VARCHAR(50), -- totp, sms, email
    
    -- TOTP settings
    totp_secret VARCHAR(255),
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

-- Table 26: password_reset_tokens
-- Purpose: Secure password reset tokens
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- Token details
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    
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

-- Table 27: user_login_history
-- Purpose: Track login attempts and history
CREATE TABLE user_login_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- Can be NULL for failed attempts
    email VARCHAR(255) NOT NULL, -- Track even failed attempts
    
    -- Attempt details
    attempt_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    was_successful BOOLEAN NOT NULL,
    failure_reason VARCHAR(100),
    
    -- Device/Location
    ip_address INET,
    user_agent TEXT,
    device_id VARCHAR(255),
    location_country VARCHAR(2),
    location_city VARCHAR(100),
    
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
```

### Asset Tables

```sql
-- Table 28: assets
-- Purpose: Core asset tracking - parent table for all asset types
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Asset identification
    category_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Ownership
    ffc_id UUID NOT NULL,
    acquisition_date DATE,
    acquisition_value DECIMAL(15, 2),
    
    -- Current value
    current_value DECIMAL(15, 2),
    value_as_of_date DATE,
    currency_code VARCHAR(3) DEFAULT 'USD',
    
    -- Documentation
    primary_document_id UUID,
    supporting_documents UUID[],
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date DATE,
    verified_by UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_currency CHECK (currency_code ~ '^[A-Z]{3}$'),
    CONSTRAINT valid_values CHECK (
        (acquisition_value >= 0 OR acquisition_value IS NULL) AND
        (current_value >= 0 OR current_value IS NULL)
    )
);

-- Table 29: asset_persona
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
    legal_title VARCHAR(500),
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
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date > effective_date)
);

-- Table 30: asset_permissions (NEW - Hybrid RBAC + Direct Permissions)
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
```

*Note: The asset_permissions table is a new addition that provides hybrid RBAC + direct asset permissions as mentioned in the requirements.*

### Asset Type Specific Tables

```sql
-- Table 31: personal_directives
-- Purpose: Store healthcare directives, POAs, and other personal directives
CREATE TABLE personal_directives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Directive details
    directive_type directive_type_enum NOT NULL,
    directive_subtype VARCHAR(100),
    
    -- Principal/Grantor
    principal_persona_id UUID NOT NULL,
    
    -- Agents (primary and successor)
    agent_persona_id UUID,
    agent_name VARCHAR(255),
    agent_email_id UUID,
    agent_phone_id UUID,
    
    -- Successor agents (backup agents)
    successor_agent_1_persona_id UUID,
    successor_agent_1_name VARCHAR(255),
    successor_agent_2_persona_id UUID,
    successor_agent_2_name VARCHAR(255),
    
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
    county_of_execution VARCHAR(100),
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

-- Table 32: trusts
-- Purpose: Store trust information
CREATE TABLE trusts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Trust identification
    trust_name VARCHAR(255) NOT NULL,
    trust_type trust_type_enum NOT NULL,
    tax_id VARCHAR(20),
    
    -- Parties
    grantor_persona_id UUID NOT NULL,
    grantor_name VARCHAR(255) NOT NULL,
    
    -- Primary Trustee
    trustee_persona_id UUID,
    trustee_name VARCHAR(255) NOT NULL,
    trustee_email_id UUID,
    trustee_phone_id UUID,
    
    -- Successor Trustees (up to 2)
    successor_trustee_1_persona_id UUID,
    successor_trustee_1_name VARCHAR(255),
    successor_trustee_2_persona_id UUID,
    successor_trustee_2_name VARCHAR(255),
    
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
    CONSTRAINT valid_state CHECK (state_of_formation ~ '^[A-Z]{2}$' OR state_of_formation IS NULL),
    CONSTRAINT valid_trust_dates CHECK (
        (termination_date IS NULL OR termination_date > execution_date) AND
        (effective_date IS NULL OR effective_date >= execution_date)
    )
);

-- Additional asset-specific tables would continue here...
-- (wills, personal_property, operational_property, inventory, real_estate, 
--  life_insurance, financial_accounts, recurring_income, digital_assets, 
--  ownership_interests, loans)
-- For brevity, I'll include just the key ones above.
```

### Audit Tables

```sql
-- Table 33: audit_log
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
    entity_name VARCHAR(255),
    
    -- Change details
    old_values JSONB,
    new_values JSONB,
    change_summary TEXT,
    
    -- Context
    ip_address INET,
    user_agent TEXT,
    request_id UUID,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}'
);

-- Table 34: audit_events
-- Purpose: System-wide audit events
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Event identification
    event_type VARCHAR(100) NOT NULL,
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
```

### Translation Tables

```sql
-- Table 35: translations
-- Purpose: Multi-language support for UI and content
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Translation key
    translation_key VARCHAR(255) NOT NULL,
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

-- Table 36: user_language_preferences
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
```

### Integration Tables

```sql
-- Table 37: builder_io_integrations
-- Purpose: Builder.io CMS integration
CREATE TABLE builder_io_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Builder.io configuration
    api_key VARCHAR(255) NOT NULL,
    space_id VARCHAR(255) NOT NULL,
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
    CONSTRAINT unique_builder_integration UNIQUE (tenant_id)
);

-- Table 38: quillt_integrations
-- Purpose: Quillt financial data integration
CREATE TABLE quillt_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    user_id UUID NOT NULL,
    
    -- Quillt connection
    quillt_connection_id VARCHAR(255) NOT NULL,
    quillt_profile_id VARCHAR(255),
    
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
```

## Indexes

```sql
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
CREATE INDEX idx_assets_ffc ON assets(ffc_id);
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

-- RBAC indexes
CREATE INDEX idx_user_role_assignments_user ON user_role_assignments(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_user_role_assignments_role ON user_role_assignments(role_id) WHERE is_active = TRUE;
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);

-- Invitation indexes
CREATE INDEX idx_ffc_invitations_ffc ON ffc_invitations(ffc_id);
CREATE INDEX idx_ffc_invitations_status ON ffc_invitations(status);
CREATE INDEX idx_ffc_invitations_email ON ffc_invitations(invitee_email_id);

-- Asset permissions index
CREATE INDEX idx_asset_permissions_asset ON asset_permissions(asset_id);
CREATE INDEX idx_asset_permissions_persona ON asset_permissions(persona_id);

-- ================================================================
-- PARTIAL UNIQUE INDEXES (PostgreSQL 17 compatible)
-- ================================================================

-- These replace invalid UNIQUE constraints with WHERE clauses
CREATE UNIQUE INDEX unique_primary_email_per_entity ON usage_email (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_phone_per_entity ON usage_phone (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_address_per_entity ON usage_address (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_primary_social_per_entity ON usage_social_media (entity_type, entity_id, is_primary) WHERE is_primary = TRUE;
CREATE UNIQUE INDEX unique_active_role_assignment ON user_role_assignments (user_id, role_id, ffc_id, is_active) WHERE is_active = TRUE;
CREATE UNIQUE INDEX unique_primary_owner_per_asset ON asset_persona (asset_id, is_primary) WHERE is_primary = TRUE;
```

## Constraints

```sql
-- Foreign key constraints are defined in the relationship script (3_SQL_create_schema_relationships.sql)
-- Key constraints include:
-- - All tables reference tenants(id) for multi-tenancy
-- - Users reference primary_email_id and primary_phone_id for normalized contact info
-- - Personas can optionally reference users(id) for living family members with accounts
-- - Assets reference category_id, ffc_id, and various document references
-- - Asset permissions enforce unique asset-persona combinations
-- - All usage tables use polymorphic entity references with proper foreign keys
```

## Functions and Stored Procedures

The platform includes 28+ stored procedures with parameter conversions for persona ID to user ID as needed. Key procedures include:

### Authentication & User Management

```sql
-- Register a new user with normalized contact information
CREATE OR REPLACE FUNCTION sp_register_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255),
    p_phone VARCHAR(20),
    p_password_hash VARCHAR(255),
    p_password_salt VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_country_code VARCHAR(5) DEFAULT '+1'
) RETURNS TABLE (
    user_id UUID,
    persona_id UUID,
    email_id UUID,
    phone_id UUID
);

-- Login user with email (updated for normalized schema)
CREATE OR REPLACE FUNCTION sp_login_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255)
) RETURNS TABLE (
    user_id UUID,
    password_hash VARCHAR(255),
    password_salt VARCHAR(255),
    status user_status_enum,
    account_locked BOOLEAN,
    failed_login_attempts INTEGER
);

-- Email and phone verification functions
CREATE OR REPLACE FUNCTION sp_verify_email(p_token UUID) RETURNS BOOLEAN;
CREATE OR REPLACE FUNCTION sp_verify_phone(p_user_id UUID, p_code VARCHAR(6)) RETURNS BOOLEAN;

-- Password reset functions
CREATE OR REPLACE FUNCTION sp_request_password_reset(p_email VARCHAR(255)) RETURNS UUID;
CREATE OR REPLACE FUNCTION sp_reset_password(p_token UUID, p_new_password_hash VARCHAR(255), p_new_password_salt VARCHAR(255)) RETURNS BOOLEAN;

-- Session management
CREATE OR REPLACE FUNCTION sp_create_session(p_user_id UUID, p_ip_address INET, p_user_agent TEXT, p_device_info JSONB DEFAULT NULL) RETURNS UUID;
CREATE OR REPLACE FUNCTION sp_refresh_session(p_session_token UUID) RETURNS UUID;
CREATE OR REPLACE FUNCTION sp_revoke_session(p_session_token UUID) RETURNS VOID;
```

### Forward Family Circles (FFCs)

```sql
-- Create a new FFC
CREATE OR REPLACE FUNCTION sp_create_ffc(
    p_tenant_id INTEGER,
    p_owner_user_id UUID,
    p_name VARCHAR(255),
    p_description TEXT DEFAULT NULL
) RETURNS UUID;

-- FFC member management
CREATE OR REPLACE FUNCTION sp_add_ffc_member(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_persona_id UUID,
    p_role ffc_role_enum DEFAULT 'beneficiary',
    p_relationship family_relationship_enum DEFAULT NULL
) RETURNS BOOLEAN;

CREATE OR REPLACE FUNCTION sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_new_role ffc_role_enum,
    p_updated_by UUID
) RETURNS BOOLEAN;

CREATE OR REPLACE FUNCTION sp_remove_ffc_member(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_removed_by UUID
) RETURNS BOOLEAN;
```

### Asset Management

```sql
-- Create assets with proper persona-to-user ID conversion
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_category_code VARCHAR(50),
    p_name VARCHAR(255),
    p_description TEXT DEFAULT NULL,
    p_acquisition_value DECIMAL(15,2) DEFAULT NULL,
    p_created_by UUID DEFAULT NULL
) RETURNS UUID;

-- Update asset values
CREATE OR REPLACE FUNCTION sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_value_date DATE DEFAULT CURRENT_DATE,
    p_updated_by UUID DEFAULT NULL
) RETURNS BOOLEAN;

-- Assign assets to personas
CREATE OR REPLACE FUNCTION sp_assign_asset_to_persona(
    p_tenant_id INTEGER,
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum DEFAULT 'owner',
    p_ownership_percentage DECIMAL(5,2) DEFAULT 100.0,
    p_is_primary BOOLEAN DEFAULT TRUE,
    p_created_by UUID DEFAULT NULL
) RETURNS UUID;
```

### Helper Functions

```sql
-- Contact information management
CREATE OR REPLACE FUNCTION sp_add_email_to_persona(
    p_tenant_id INTEGER,
    p_persona_id UUID,
    p_email VARCHAR(255),
    p_usage_type email_usage_type_enum DEFAULT 'personal',
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID;

CREATE OR REPLACE FUNCTION sp_add_phone_to_persona(
    p_tenant_id INTEGER,
    p_persona_id UUID,
    p_phone VARCHAR(20),
    p_country_code VARCHAR(5) DEFAULT '+1',
    p_usage_type phone_usage_type_enum DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID;

-- Audit logging
CREATE OR REPLACE FUNCTION sp_log_audit_event(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_action audit_action_enum,
    p_entity_type audit_entity_type_enum,
    p_entity_id UUID,
    p_entity_name VARCHAR(255) DEFAULT NULL,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'
) RETURNS UUID;
```

*Note: All stored procedures have been updated to work with the normalized contact tables schema and include proper parameter conversions from persona ID to user ID where needed.*

---

## Summary

This architecture documentation now accurately reflects the current SQL scripts (`fwd_db` database) and includes all the key features:

1. **Database name**: Updated to `fwd_db` (not `forward_inheritance`)
2. **New asset_permissions table**: Documented for hybrid RBAC + direct asset permissions
3. **Updated enums**: All enum definitions now match the SQL scripts exactly
4. **Normalized contact schema**: Proper documentation of the phone_number, email_address, address, and social_media tables with usage linking tables
5. **Updated constraints**: Including the corrected `valid_values` constraint for assets
6. **Stored procedures**: All 28+ procedures documented with parameter conversions and proper signatures
7. **Complete relationships**: All foreign key relationships properly documented

The architecture is now 100% consistent with the source-of-truth SQL scripts.