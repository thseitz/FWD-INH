-- =====================================================
-- Forward Inheritance Platform - SQL Test Script 2
-- Purpose: Create all tables from reorganized architecture.md (Tables 1-20)
-- Date: Generated from reorganized architecture document
-- Note: Run SQL_Test_0.sql first to create database
-- =====================================================

-- Connect to the database
\connect fwd_db

-- =====================================================
-- SUPPORTING TABLES
-- =====================================================

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

-- Note: media_storage references users(id) for uploaded_by, so we'll create it after users
-- But we need to create the table structure first, then add foreign key constraints later

-- Table 2: media_storage (without uploaded_by foreign key initially)
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
    storage_provider VARCHAR(50) NOT NULL DEFAULT 's3', -- s3, azure, gcs
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
    processing_status VARCHAR(50) DEFAULT 'uploaded', -- uploaded, processing, ready, failed
    processing_error TEXT,
    
    -- Retention and lifecycle
    retention_policy VARCHAR(50), -- permanent, 7_years, 3_years, etc.
    expires_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Multi-tenancy and audit (uploaded_by will be added later)
    uploaded_by UUID NOT NULL, -- Will add foreign key constraint later
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CHECK (file_size > 0),
    CHECK (NOT is_deleted OR deleted_at IS NOT NULL)
);

-- Table 3: document_metadata (depends on media_storage and users)
-- Purpose: Additional metadata for documents stored in media_storage
CREATE TABLE document_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    media_storage_id UUID NOT NULL REFERENCES media_storage(id) ON DELETE CASCADE,
    
    -- Document classification
    document_type VARCHAR(100) NOT NULL, -- will, trust, insurance_policy, etc.
    document_category VARCHAR(100), -- legal, financial, personal, etc.
    
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
    
    -- Multi-tenancy and audit (will add foreign key constraints later)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
    -- Constraints
    UNIQUE(media_storage_id)
);

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Table 4: users (depends on email_address and phone_number which come later)
-- Purpose: Authentication and user account management
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Normalized contact references (will add foreign keys later)
    primary_email_id UUID, -- Will add foreign key constraint later
    primary_phone_id UUID, -- Will add foreign key constraint later
    
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
    status VARCHAR(50) NOT NULL DEFAULT 'pending_verification',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Self-referencing, will add constraint later
    updated_by UUID  -- Self-referencing, will add constraint later
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
    gender VARCHAR(20),
    marital_status VARCHAR(50),
    nationality VARCHAR(100),
    
    -- Profile
    profile_picture_id UUID REFERENCES media_storage(id),
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
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
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(tenant_id, name)
);

-- =====================================================
-- CONTACT TABLES
-- =====================================================

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
    phone_type VARCHAR(50), -- mobile, landline, voip, toll_free
    carrier_name VARCHAR(100),
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
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
    email_type VARCHAR(50), -- personal, business, temporary, alias
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
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
    address_type VARCHAR(50), -- residential, business, mailing, etc.
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID  -- Will add foreign key constraint later
);

-- Table 10: social_media
-- Purpose: Normalized social media account storage
CREATE TABLE social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Social media details
    platform VARCHAR(50) NOT NULL, -- facebook, twitter, linkedin, instagram, etc.
    username VARCHAR(255) NOT NULL,
    profile_url VARCHAR(500),
    account_id VARCHAR(255), -- Platform-specific ID
    
    -- Account metadata
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    follower_count INTEGER,
    is_business_account BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
    -- Constraints
    UNIQUE(tenant_id, platform, username)
);

-- =====================================================
-- RELATIONSHIP TABLES
-- =====================================================

-- Table 11: usage_email
-- Purpose: Links entities (users/personas) to multiple email addresses
CREATE TABLE usage_email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    email_id UUID NOT NULL REFERENCES email_address(id),
    
    -- Usage details
    usage_type VARCHAR(50) NOT NULL, -- primary, work, personal, backup, etc.
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    can_receive_notifications BOOLEAN DEFAULT TRUE,
    can_receive_marketing BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
    -- Constraints
    UNIQUE(entity_type, entity_id, email_id)
);

-- Table 12: usage_phone
-- Purpose: Links entities (users/personas) to multiple phone numbers
CREATE TABLE usage_phone (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    phone_id UUID NOT NULL REFERENCES phone_number(id),
    
    -- Usage details
    usage_type VARCHAR(50) NOT NULL, -- primary, work, home, mobile, emergency, etc.
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Preferences
    can_receive_sms BOOLEAN DEFAULT TRUE,
    can_receive_calls BOOLEAN DEFAULT TRUE,
    preferred_contact_time VARCHAR(50), -- morning, afternoon, evening, anytime
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
    -- Constraints
    UNIQUE(entity_type, entity_id, phone_id)
);

-- Table 13: usage_address
-- Purpose: Links entities (users/personas/assets) to multiple addresses
CREATE TABLE usage_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'persona', 'asset')),
    entity_id UUID NOT NULL,
    address_id UUID NOT NULL REFERENCES address(id),
    
    -- Usage details
    usage_type VARCHAR(50) NOT NULL, -- primary, mailing, billing, property, etc.
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Date ranges for temporary addresses
    effective_from DATE,
    effective_to DATE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
    -- Constraints
    UNIQUE(entity_type, entity_id, address_id, usage_type)
);

-- Table 14: usage_social_media
-- Purpose: Links entities (users/personas) to social media accounts
CREATE TABLE usage_social_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('user', 'persona')),
    entity_id UUID NOT NULL,
    social_media_id UUID NOT NULL REFERENCES social_media(id),
    
    -- Usage details
    usage_type VARCHAR(50) NOT NULL, -- personal, professional, business, etc.
    is_primary BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT TRUE,
    
    -- Privacy settings
    share_with_family BOOLEAN DEFAULT TRUE,
    share_with_advisors BOOLEAN DEFAULT FALSE,
    
    -- Multi-tenancy and audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID, -- Will add foreign key constraint later
    
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
    entity_type VARCHAR(50) NOT NULL, -- advisor, company, institution, etc.
    
    -- Contact references
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    primary_address_id UUID REFERENCES address(id),
    
    -- Additional info
    website_url VARCHAR(500),
    notes TEXT,
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, -- Will add foreign key constraint later
    updated_by UUID  -- Will add foreign key constraint later
);

-- Table 16: ffc_personas
-- Purpose: Links personas to FFCs with their business role
CREATE TABLE ffc_personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Business role in FFC
    role VARCHAR(50) NOT NULL CHECK (role IN ('owner', 'beneficiary', 'non_beneficiary', 'advisor')),
    
    -- Relationship details
    relationship_to_owner VARCHAR(100), -- spouse, child, parent, sibling, etc.
    joined_date DATE DEFAULT CURRENT_DATE,
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(ffc_id, persona_id)
);

-- =====================================================
-- SECURITY TABLES (RBAC)
-- =====================================================

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
    status VARCHAR(50) NOT NULL DEFAULT 'active',
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
    category VARCHAR(50) NOT NULL, -- asset, user, admin, report, etc.
    
    -- Permission properties
    is_dangerous BOOLEAN NOT NULL DEFAULT false, -- For destructive operations
    requires_2fa BOOLEAN NOT NULL DEFAULT false,
    
    -- Multi-tenancy and audit
    status VARCHAR(50) NOT NULL DEFAULT 'active',
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
    granted_by UUID, -- Will add foreign key constraint later
    
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

-- =====================================================
-- ADD DEFERRED FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Add foreign key constraints that were deferred due to circular dependencies

-- media_storage foreign keys
ALTER TABLE media_storage ADD CONSTRAINT fk_media_storage_uploaded_by 
    FOREIGN KEY (uploaded_by) REFERENCES users(id);

-- document_metadata foreign keys
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE document_metadata ADD CONSTRAINT fk_document_metadata_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- users foreign keys (self-referencing)
ALTER TABLE users ADD CONSTRAINT fk_users_primary_email 
    FOREIGN KEY (primary_email_id) REFERENCES email_address(id);
ALTER TABLE users ADD CONSTRAINT fk_users_primary_phone 
    FOREIGN KEY (primary_phone_id) REFERENCES phone_number(id);
ALTER TABLE users ADD CONSTRAINT fk_users_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- contact tables foreign keys
ALTER TABLE phone_number ADD CONSTRAINT fk_phone_number_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE phone_number ADD CONSTRAINT fk_phone_number_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE email_address ADD CONSTRAINT fk_email_address_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE email_address ADD CONSTRAINT fk_email_address_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE address ADD CONSTRAINT fk_address_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE address ADD CONSTRAINT fk_address_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE social_media ADD CONSTRAINT fk_social_media_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE social_media ADD CONSTRAINT fk_social_media_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- usage tables foreign keys
ALTER TABLE usage_email ADD CONSTRAINT fk_usage_email_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE usage_email ADD CONSTRAINT fk_usage_email_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE usage_phone ADD CONSTRAINT fk_usage_phone_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE usage_phone ADD CONSTRAINT fk_usage_phone_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE usage_address ADD CONSTRAINT fk_usage_address_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE usage_address ADD CONSTRAINT fk_usage_address_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE usage_social_media ADD CONSTRAINT fk_usage_social_media_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_created_by 
    FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE contact_info ADD CONSTRAINT fk_contact_info_updated_by 
    FOREIGN KEY (updated_by) REFERENCES users(id);

-- role_permissions foreign key
ALTER TABLE role_permissions ADD CONSTRAINT fk_role_permissions_granted_by 
    FOREIGN KEY (granted_by) REFERENCES users(id);

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

-- Tenant-based indexes (for multi-tenancy)
CREATE INDEX idx_media_storage_tenant ON media_storage(tenant_id);
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_personas_tenant ON personas(tenant_id);
CREATE INDEX idx_fwd_family_circles_tenant ON fwd_family_circles(tenant_id);
CREATE INDEX idx_phone_number_tenant ON phone_number(tenant_id);
CREATE INDEX idx_email_address_tenant ON email_address(tenant_id);
CREATE INDEX idx_address_tenant ON address(tenant_id);
CREATE INDEX idx_social_media_tenant ON social_media(tenant_id);
CREATE INDEX idx_contact_info_tenant ON contact_info(tenant_id);

-- Core entity indexes
CREATE INDEX idx_personas_user ON personas(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_personas_living ON personas(is_living);
CREATE INDEX idx_personas_name ON personas(last_name, first_name);
CREATE INDEX idx_ffc_status ON fwd_family_circles(status);
CREATE INDEX idx_users_email_verified ON users(email_verified);
CREATE INDEX idx_users_status ON users(status);

-- Relationship indexes
CREATE INDEX idx_ffc_personas_ffc ON ffc_personas(ffc_id);
CREATE INDEX idx_ffc_personas_persona ON ffc_personas(persona_id);
CREATE INDEX idx_ffc_personas_role ON ffc_personas(role);

-- Usage table indexes
CREATE INDEX idx_usage_email_entity ON usage_email(entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity ON usage_phone(entity_type, entity_id);
CREATE INDEX idx_usage_address_entity ON usage_address(entity_type, entity_id);
CREATE INDEX idx_usage_social_media_entity ON usage_social_media(entity_type, entity_id);

-- RBAC indexes
CREATE INDEX idx_user_roles_name ON user_roles(name);
CREATE INDEX idx_user_permissions_name ON user_permissions(name);
CREATE INDEX idx_user_permissions_category ON user_permissions(category);
CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);
CREATE INDEX idx_user_role_assignments_user ON user_role_assignments(user_id);
CREATE INDEX idx_user_role_assignments_ffc ON user_role_assignments(ffc_id) WHERE ffc_id IS NOT NULL;
CREATE INDEX idx_user_role_assignments_active ON user_role_assignments(is_active) WHERE is_active = true;

-- Media and document indexes
CREATE INDEX idx_media_storage_mime ON media_storage(mime_type);
CREATE INDEX idx_media_storage_processing ON media_storage(processing_status) WHERE processing_status != 'ready';
CREATE INDEX idx_media_storage_pii ON media_storage(contains_pii) WHERE contains_pii = true;
CREATE INDEX idx_document_metadata_type ON document_metadata(document_type);
CREATE INDEX idx_document_metadata_category ON document_metadata(document_category);

-- Contact indexes
CREATE INDEX idx_email_domain ON email_address(domain);
CREATE INDEX idx_phone_country ON phone_number(country_code);

-- =====================================================
-- INSERT TEST DATA
-- =====================================================

DO $$
DECLARE
    test_tenant_id UUID;
    test_user_id UUID;
    test_email_id UUID;
    test_phone_id UUID;
    test_media_id UUID;
    test_persona_id UUID;
    test_ffc_id UUID;
    test_role_id UUID;
    test_permission_id UUID;
BEGIN
    -- Insert default Forward tenant (ID = 1)
    INSERT INTO tenants (id, name, display_name, primary_color, secondary_color, is_active) VALUES
    (1, 'forward-inheritance', 'Forward Inheritance Platform', '#1f2937', '#3b82f6', true);
    
    test_tenant_id := 1;  -- Forward tenant ID
    
    -- Insert test email
    INSERT INTO email_address (tenant_id, email_address, domain, email_type)
    VALUES (test_tenant_id, 'test@example.com', 'example.com', 'personal')
    RETURNING id INTO test_email_id;
    
    -- Insert test phone
    INSERT INTO phone_number (tenant_id, phone_number, country_code, phone_type)
    VALUES (test_tenant_id, '+12125551234', '+1', 'mobile')
    RETURNING id INTO test_phone_id;
    
    -- Insert test user
    INSERT INTO users (
        tenant_id, primary_email_id, primary_phone_id, 
        password_hash, password_salt, first_name, last_name
    ) VALUES (
        test_tenant_id, test_email_id, test_phone_id, 
        'dummy_hash', 'dummy_salt', 'Test', 'User'
    ) RETURNING id INTO test_user_id;
    
    -- Insert test media file
    INSERT INTO media_storage (
        tenant_id, original_filename, mime_type, file_extension, file_size,
        storage_provider, storage_bucket, storage_key, checksum, uploaded_by
    ) VALUES (
        test_tenant_id, 'profile.jpg', 'image/jpeg', 'jpg', 1024000,
        's3', 'fwd-media-bucket', 'profiles/test-profile.jpg', 
        'abc123def456', test_user_id
    ) RETURNING id INTO test_media_id;
    
    -- Insert test persona
    INSERT INTO personas (
        tenant_id, user_id, first_name, middle_name, last_name,
        date_of_birth, is_living, profile_picture_id, created_by
    ) VALUES (
        test_tenant_id, test_user_id, 'John', 'Michael', 'Smith',
        '1980-05-15', true, test_media_id, test_user_id
    ) RETURNING id INTO test_persona_id;
    
    -- Insert test FFC
    INSERT INTO fwd_family_circles (
        tenant_id, name, description, created_by
    ) VALUES (
        test_tenant_id, 'Smith Family Trust', 
        'Primary family inheritance planning circle', test_user_id
    ) RETURNING id INTO test_ffc_id;
    
    -- Link persona to FFC
    INSERT INTO ffc_personas (
        ffc_id, persona_id, role, relationship_to_owner, created_by
    ) VALUES (
        test_ffc_id, test_persona_id, 'owner', 'self', test_user_id
    );
    
    -- Insert system roles
    INSERT INTO user_roles (name, display_name, description, hierarchy_level, is_system_role)
    VALUES 
        ('platform_admin', 'Platform Administrator', 'Full system access', 0, true),
        ('ffc_owner', 'FFC Owner', 'Full control of family circle', 1, true),
        ('ffc_member', 'FFC Member', 'Standard member access', 2, true),
        ('ffc_viewer', 'FFC Viewer', 'Read-only access', 3, true);
    
    -- Insert sample permissions
    INSERT INTO user_permissions (name, display_name, category, is_dangerous)
    VALUES 
        ('asset.create', 'Create Assets', 'asset', false),
        ('asset.view', 'View Assets', 'asset', false),
        ('asset.edit', 'Edit Assets', 'asset', false),
        ('asset.delete', 'Delete Assets', 'asset', true),
        ('user.invite', 'Invite Users', 'user', false),
        ('ffc.delete', 'Delete Family Circle', 'admin', true);
    
    -- Get role and permission IDs
    SELECT id INTO test_role_id FROM user_roles WHERE name = 'ffc_owner';
    
    -- Link role to permissions
    INSERT INTO role_permissions (role_id, permission_id, granted_by)
    SELECT test_role_id, id, test_user_id
    FROM user_permissions;
    
    -- Assign role to user
    INSERT INTO user_role_assignments (
        user_id, role_id, ffc_id, assigned_by, is_active
    ) VALUES (
        test_user_id, test_role_id, test_ffc_id, test_user_id, true
    );
    
    -- Link email and phone to user
    INSERT INTO usage_email (entity_type, entity_id, email_id, usage_type, is_primary, created_by)
    VALUES ('user', test_user_id, test_email_id, 'primary', true, test_user_id);
    
    INSERT INTO usage_phone (entity_type, entity_id, phone_id, usage_type, is_primary, created_by)
    VALUES ('user', test_user_id, test_phone_id, 'primary', true, test_user_id);
    
    RAISE NOTICE 'Test data for all 20 tables inserted successfully';
END $$;

-- =====================================================
-- VALIDATION QUERIES
-- =====================================================

-- Verify all tables were created
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns 
        WHERE table_name = t.table_name AND table_schema = 'public') as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
AND table_name NOT LIKE '%audit%'
ORDER BY table_name;

-- Verify foreign key relationships
SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- Test the relationships with sample data
SELECT 
    u.first_name || ' ' || u.last_name as user_name,
    e.email_address,
    p.phone_number,
    per.first_name || ' ' || per.last_name as persona_name,
    ffc.name as family_circle,
    fp.role as business_role,
    ur.display_name as platform_role
FROM users u
LEFT JOIN email_address e ON u.primary_email_id = e.id
LEFT JOIN phone_number p ON u.primary_phone_id = p.id
LEFT JOIN personas per ON u.id = per.user_id
LEFT JOIN ffc_personas fp ON per.id = fp.persona_id
LEFT JOIN fwd_family_circles ffc ON fp.ffc_id = ffc.id
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id AND ffc.id = ura.ffc_id
LEFT JOIN user_roles ur ON ura.role_id = ur.id
WHERE ura.is_active = true OR ura.is_active IS NULL;

-- Count records in all tables
SELECT 
    'tenants' as table_name, COUNT(*) as record_count FROM tenants
UNION ALL SELECT 'media_storage', COUNT(*) FROM media_storage
UNION ALL SELECT 'document_metadata', COUNT(*) FROM document_metadata
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'personas', COUNT(*) FROM personas
UNION ALL SELECT 'fwd_family_circles', COUNT(*) FROM fwd_family_circles
UNION ALL SELECT 'phone_number', COUNT(*) FROM phone_number
UNION ALL SELECT 'email_address', COUNT(*) FROM email_address
UNION ALL SELECT 'address', COUNT(*) FROM address
UNION ALL SELECT 'social_media', COUNT(*) FROM social_media
UNION ALL SELECT 'usage_email', COUNT(*) FROM usage_email
UNION ALL SELECT 'usage_phone', COUNT(*) FROM usage_phone
UNION ALL SELECT 'usage_address', COUNT(*) FROM usage_address
UNION ALL SELECT 'usage_social_media', COUNT(*) FROM usage_social_media
UNION ALL SELECT 'contact_info', COUNT(*) FROM contact_info
UNION ALL SELECT 'ffc_personas', COUNT(*) FROM ffc_personas
UNION ALL SELECT 'user_roles', COUNT(*) FROM user_roles
UNION ALL SELECT 'user_permissions', COUNT(*) FROM user_permissions
UNION ALL SELECT 'role_permissions', COUNT(*) FROM role_permissions
UNION ALL SELECT 'user_role_assignments', COUNT(*) FROM user_role_assignments
ORDER BY table_name;