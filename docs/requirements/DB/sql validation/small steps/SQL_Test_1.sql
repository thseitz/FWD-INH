-- =====================================================
-- Forward Inheritance Platform - SQL Test Script 1
-- Purpose: Validate Core Tables and Usage Tables
-- Tables: 1-11 (Core normalized tables and relationships)
-- Date: Generated from architecture.md
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- CORE TABLES
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

-- Table 2: phone_number
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
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_e164_format CHECK (phone_number ~ '^\+[1-9]\d{1,14}$')
);

-- Table 3: email_address
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
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Table 4: address
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
    created_by UUID,
    updated_by UUID
);

-- Note: We need to create users table before we can add foreign key references
-- Temporarily create users table without created_by/updated_by references
-- Table 5: users
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
    status VARCHAR(50) NOT NULL DEFAULT 'pending_verification',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Now add the foreign key constraints for created_by/updated_by
ALTER TABLE phone_number ADD CONSTRAINT fk_phone_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE phone_number ADD CONSTRAINT fk_phone_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE email_address ADD CONSTRAINT fk_email_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE email_address ADD CONSTRAINT fk_email_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE address ADD CONSTRAINT fk_address_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE address ADD CONSTRAINT fk_address_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);

ALTER TABLE users ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);

-- Table 6: social_media
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(tenant_id, platform, username)
);

-- =====================================================
-- RELATIONSHIP TABLES
-- =====================================================

-- Note: personas table will be created later, so we'll create usage tables
-- without the CHECK constraint for now

-- Table 7: usage_email
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(entity_type, entity_id, email_id)
);

-- Table 8: usage_phone
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(entity_type, entity_id, phone_id)
);

-- Table 9: usage_address
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(entity_type, entity_id, address_id, usage_type)
);

-- Table 10: usage_social_media
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(entity_type, entity_id, social_media_id)
);

-- Table 11: contact_info
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
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

-- =====================================================
-- Create indexes for better performance
-- =====================================================

-- Tenant indexes
CREATE INDEX idx_phone_tenant ON phone_number(tenant_id);
CREATE INDEX idx_email_tenant ON email_address(tenant_id);
CREATE INDEX idx_address_tenant ON address(tenant_id);
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_social_media_tenant ON social_media(tenant_id);
CREATE INDEX idx_contact_info_tenant ON contact_info(tenant_id);

-- Usage table indexes
CREATE INDEX idx_usage_email_entity ON usage_email(entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity ON usage_phone(entity_type, entity_id);
CREATE INDEX idx_usage_address_entity ON usage_address(entity_type, entity_id);
CREATE INDEX idx_usage_social_media_entity ON usage_social_media(entity_type, entity_id);

-- Email domain index for analytics
CREATE INDEX idx_email_domain ON email_address(domain);

-- Phone country code index
CREATE INDEX idx_phone_country ON phone_number(country_code);

-- =====================================================
-- Test data to validate structure
-- =====================================================

-- Insert test tenant
-- Insert default Forward tenant (ID = 1)
INSERT INTO tenants (id, name, display_name, primary_color, secondary_color, is_active) VALUES
(1, 'forward-inheritance', 'Forward Inheritance Platform', '#1f2937', '#3b82f6', true);

-- Get the tenant ID for subsequent inserts
DO $$
DECLARE
    test_tenant_id UUID;
    test_user_id UUID;
    test_email_id UUID;
    test_phone_id UUID;
BEGIN
    -- Get tenant ID
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
    INSERT INTO users (tenant_id, primary_email_id, primary_phone_id, 
                      password_hash, password_salt, first_name, last_name)
    VALUES (test_tenant_id, test_email_id, test_phone_id, 
            'dummy_hash', 'dummy_salt', 'Test', 'User')
    RETURNING id INTO test_user_id;
    
    -- Link email to user
    INSERT INTO usage_email (entity_type, entity_id, email_id, usage_type, is_primary)
    VALUES ('user', test_user_id, test_email_id, 'primary', true);
    
    -- Link phone to user
    INSERT INTO usage_phone (entity_type, entity_id, phone_id, usage_type, is_primary)
    VALUES ('user', test_user_id, test_phone_id, 'primary', true);
    
    RAISE NOTICE 'Test data inserted successfully';
END $$;

-- =====================================================
-- Validation queries
-- =====================================================

-- Check all tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check foreign key relationships
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
ORDER BY tc.table_name;

-- Verify test data
SELECT 
    u.first_name || ' ' || u.last_name as user_name,
    e.email_address,
    p.phone_number
FROM users u
LEFT JOIN email_address e ON u.primary_email_id = e.id
LEFT JOIN phone_number p ON u.primary_phone_id = p.id;