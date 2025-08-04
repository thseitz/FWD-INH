-- ================================================================
-- SQL_Test_3.sql
-- Complete SQL script from architecture.md
-- Creates all enums, tables, and data for Forward Inheritance Platform
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

-- Asset ownership type enum
CREATE TYPE ownership_type_enum AS ENUM ('owner', 'beneficiary', 'trustee', 'executor');

-- Invitation system enum
CREATE TYPE invitation_status_enum AS ENUM ('sent', 'phone_verified', 'accepted', 'approved', 'expired', 'cancelled', 'declined');

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
-- FIX CIRCULAR DEPENDENCIES
-- ================================================================

-- Add deferred foreign key constraints to handle circular dependencies
ALTER TABLE media_storage ADD CONSTRAINT fk_media_storage_uploaded_by 
    FOREIGN KEY (uploaded_by) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE users ADD CONSTRAINT fk_users_primary_email_id 
    FOREIGN KEY (primary_email_id) REFERENCES email_address(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE users ADD CONSTRAINT fk_users_primary_phone_id 
    FOREIGN KEY (primary_phone_id) REFERENCES phone_number(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE personas ADD CONSTRAINT fk_personas_profile_picture_id 
    FOREIGN KEY (profile_picture_id) REFERENCES media_storage(id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE fwd_family_circles ADD CONSTRAINT fk_fwd_family_circles_family_picture_id 
    FOREIGN KEY (family_picture_id) REFERENCES media_storage(id) DEFERRABLE INITIALLY DEFERRED;

-- ================================================================
-- SAMPLE DATA FOR TESTING
-- ================================================================

-- Insert default Forward tenant (ID = 1)
INSERT INTO tenants (id, name, display_name, primary_color, secondary_color, is_active) VALUES
(1, 'forward-inheritance', 'Forward Inheritance Platform', '#1f2937', '#3b82f6', true);

-- Get tenant ID for use in other inserts
-- (Note: In real implementation, you'd use the actual UUID)
-- This is a placeholder for testing purposes

-- ================================================================
-- VALIDATION QUERIES
-- ================================================================

-- Verify all tables were created
SELECT schemaname, tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Verify all enums were created
SELECT typname 
FROM pg_type 
WHERE typtype = 'e' 
ORDER BY typname;

-- Verify asset categories were inserted
SELECT * FROM asset_categories ORDER BY sort_order;

-- Show table count
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';

-- Show enum count
SELECT COUNT(*) as enum_count FROM pg_type WHERE typtype = 'e';

COMMIT;