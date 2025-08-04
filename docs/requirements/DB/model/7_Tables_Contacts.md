# 07 - Contact & Address Management Tables

## Table of Contents
1. [Overview](#overview)
2. [Normalized Contact Architecture](#normalized-contact-architecture)
3. [Core Contact Tables](#core-contact-tables)
4. [Usage Junction Tables](#usage-junction-tables)
5. [External Contact Management](#external-contact-management)
6. [Contact Relationships](#contact-relationships)
7. [Data Validation & Constraints](#data-validation--constraints)
8. [Usage Patterns](#usage-patterns)

## Overview

The Forward Inheritance Platform implements a **normalized contact management system** that separates contact information storage from usage context. This approach eliminates data duplication, ensures consistency, and provides flexible contact management across users, personas, and external entities.

### Contact Management Architecture
- **Normalized Storage**: Contact information stored once, referenced multiple times
- **Usage Context**: Junction tables define how contacts are used by different entities
- **Multi-Entity Support**: Users, personas, and external contacts supported
- **Flexible Types**: Email, phone, address, and social media contacts
- **Privacy Controls**: Granular privacy and sharing settings

### Key Statistics
- **Core Contact Tables**: 4 tables (email, phone, address, social_media)
- **Usage Junction Tables**: 4 tables linking contacts to entities
- **External Contact Tables**: 2 tables for external relationship management
- **Total Tables**: 10 contact management tables
- **Supported Entity Types**: users, personas, assets (for addresses)

## Normalized Contact Architecture

### Contact Storage Model
```
Core Contact Tables (normalized storage):
├── email_address
├── phone_number  
├── address
└── social_media

Usage Junction Tables (context):
├── usage_email (entity → email_address)
├── usage_phone (entity → phone_number)
├── usage_address (entity → address)
└── usage_social_media (entity → social_media)

External Contact Management:
├── contact_info (external entities)
└── contact_relationships (relationship tracking)
```

### Entity Relationship Pattern
```
Entity (user/persona/asset) ←→ Usage Junction ←→ Contact Table
```

**Benefits:**
- **No Duplication**: Email "john@example.com" stored once, used by multiple entities
- **Consistency**: Updates to contact info automatically reflect everywhere
- **Flexible Usage**: Same contact can have different purposes for different entities
- **Audit Trail**: Clear tracking of who uses which contact information

## Core Contact Tables

### email_address table
Centralized email address storage with verification and type classification.

```sql
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
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
);
```

**Email Types:**
- **personal** - Personal email addresses
- **business** - Work or business email addresses  
- **temporary** - Temporary or disposable email addresses
- **alias** - Email aliases or forwarding addresses
- **shared** - Shared family or group email addresses

**Key Features:**
- **Format Validation**: Regex validation for email format
- **Domain Extraction**: Automatic domain extraction for filtering/analysis
- **Verification Tracking**: Email verification status and timestamp
- **Type Classification**: Categorization for appropriate usage

### phone_number table
International phone number storage with E.164 format support.

```sql
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
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_e164_format CHECK (phone_number ~ '^\\+[1-9]\\d{1,14}$')
);
```

**Phone Types:**
- **mobile** - Mobile/cellular phones
- **landline** - Traditional landline phones
- **voip** - Voice over IP numbers
- **toll_free** - Toll-free numbers
- **fax** - Fax numbers

**Key Features:**
- **E.164 Format**: International standard phone number format
- **Component Extraction**: Separate country code and national number
- **Carrier Information**: Optional carrier name for mobile numbers
- **Verification Support**: SMS verification tracking

### address table
Physical address storage with geocoding support and international format handling.

```sql
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
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);
```

**Address Types:**
- **residential** - Home addresses
- **business** - Work or business addresses
- **mailing** - Mailing addresses (may differ from residential)
- **billing** - Billing addresses for financial purposes
- **property** - Property addresses (for real estate assets)
- **temporary** - Temporary addresses

**Key Features:**  
- **International Support**: ISO 3166-1 alpha-2 country codes
- **Geocoding Ready**: Latitude/longitude fields for mapping
- **Formatted Address**: Pre-formatted address for display
- **Flexible Structure**: Supports various international address formats

### social_media table
Social media account and profile information storage.

```sql
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
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(tenant_id, platform, username)
);
```

**Social Media Platforms:**
- **facebook** - Facebook profiles and pages
- **twitter** - Twitter/X accounts
- **linkedin** - LinkedIn profiles
- **instagram** - Instagram accounts
- **youtube** - YouTube channels
- **tiktok** - TikTok accounts
- **snapchat** - Snapchat accounts
- **other** - Other social media platforms

## Usage Junction Tables

### usage_email table
Links entities (users/personas) to email addresses with usage context.

```sql
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
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, email_id),
    CHECK ((entity_type = 'user' AND entity_id IN (SELECT id FROM users)) OR 
           (entity_type = 'persona' AND entity_id IN (SELECT id FROM personas)))
);
```

**Email Usage Types:**
- **primary** - Primary email address
- **work** - Work or professional email
- **personal** - Personal communications
- **backup** - Backup or secondary email
- **billing** - Billing and financial communications
- **notifications** - System notifications only

### usage_phone table  
Links entities to phone numbers with communication preferences.

```sql
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
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, phone_id)
);
```

**Phone Usage Types:**
- **primary** - Primary phone number
- **work** - Work or business phone
- **home** - Home phone number
- **mobile** - Mobile/cell phone
- **emergency** - Emergency contact number
- **fax** - Fax number

**Contact Time Preferences:**
- **morning** - Morning contact preferred
- **afternoon** - Afternoon contact preferred  
- **evening** - Evening contact preferred
- **anytime** - Any time is acceptable
- **business_hours** - Business hours only

### usage_address table
Links entities (users/personas/assets) to addresses with usage context.

```sql
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
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),  
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, address_id, usage_type)
);
```

**Address Usage Types:**
- **primary** - Primary residence or location
- **mailing** - Mailing address (may differ from primary)
- **billing** - Billing address for financial purposes
- **property** - Property location (for assets)
- **work** - Work or business address
- **emergency** - Emergency contact address

### usage_social_media table
Links entities to social media accounts with privacy controls.

```sql  
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
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    UNIQUE(entity_type, entity_id, social_media_id)
);
```

**Social Media Usage Types:**
- **personal** - Personal social media accounts
- **professional** - Professional or business accounts
- **business** - Business-specific accounts
- **public** - Public-facing accounts
- **private** - Private personal accounts

## External Contact Management

### contact_info table
Manages external contacts like advisors, companies, and institutions.

```sql
CREATE TABLE contact_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Entity identification
    entity_name VARCHAR(255) NOT NULL,
    entity_type contact_entity_type_enum NOT NULL,
    
    -- Contact references (linking to normalized contact tables)
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    primary_address_id UUID REFERENCES address(id),
    
    -- Additional info
    website_url VARCHAR(500),
    notes TEXT,
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);
```

**Contact Entity Types:**
- **advisor** - Financial or legal advisors
- **company** - Companies or corporations
- **institution** - Financial institutions
- **attorney** - Legal attorneys
- **accountant** - Accounting professionals
- **financial_advisor** - Financial advisory professionals
- **insurance_agent** - Insurance agents
- **other** - Other external entities

### contact_relationships table
Tracks relationships between family members and external contacts.

```sql
CREATE TABLE contact_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Relationship participants
    persona_id UUID NOT NULL REFERENCES personas(id),
    contact_info_id UUID NOT NULL REFERENCES contact_info(id),
    
    -- Relationship details
    relationship_type VARCHAR(100) NOT NULL, -- attorney, financial_advisor, insurance_agent, etc.
    relationship_status VARCHAR(50) DEFAULT 'active',
    
    -- Relationship dates
    relationship_start_date DATE DEFAULT CURRENT_DATE,
    relationship_end_date DATE,
    
    -- Service details
    services_provided TEXT,
    contract_terms TEXT,
    
    -- Notes
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(persona_id, contact_info_id, relationship_type)
);
```

## Contact Relationships

### Primary Contact Relationships
The platform establishes primary contact relationships for key entities:

```sql
-- Users have primary email and phone
users.primary_email_id → email_address.id
users.primary_phone_id → phone_number.id

-- External contacts have primary contact methods  
contact_info.primary_email_id → email_address.id
contact_info.primary_phone_id → phone_number.id
contact_info.primary_address_id → address.id
```

### Usage Relationship Patterns
```sql
-- User contact usage
users → usage_email ← email_address
users → usage_phone ← phone_number  
users → usage_address ← address

-- Persona contact usage
personas → usage_email ← email_address
personas → usage_phone ← phone_number
personas → usage_address ← address
personas → usage_social_media ← social_media

-- Asset address usage (for property assets)
assets → usage_address ← address
```

### Cross-Reference Patterns
```sql
-- Find all emails used by a persona
SELECT ea.email_address
FROM personas p
JOIN usage_email ue ON ue.entity_id = p.id AND ue.entity_type = 'persona'
JOIN email_address ea ON ue.email_id = ea.id
WHERE p.id = ? AND ue.is_primary = true;

-- Find all addresses for a user (direct and through personas)
SELECT DISTINCT a.formatted_address, ua.usage_type
FROM users u
LEFT JOIN usage_address ua1 ON ua1.entity_id = u.id AND ua1.entity_type = 'user'
LEFT JOIN personas p ON p.user_id = u.id
LEFT JOIN usage_address ua2 ON ua2.entity_id = p.id AND ua2.entity_type = 'persona'  
JOIN address a ON a.id = COALESCE(ua1.address_id, ua2.address_id)
WHERE u.id = ?;
```

## Data Validation & Constraints

### Format Validation
```sql
-- Email format validation
CONSTRAINT valid_email_format CHECK (
    email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
);

-- E.164 phone number format
CONSTRAINT valid_e164_format CHECK (
    phone_number ~ '^\\+[1-9]\\d{1,14}$'
);

-- Country code validation (ISO 3166-1 alpha-2)
CONSTRAINT valid_country_code CHECK (
    country ~ '^[A-Z]{2}$'
);
```

### Business Rules
```sql
-- Only one primary contact per entity per contact type
CREATE UNIQUE INDEX idx_usage_email_primary 
ON usage_email (entity_type, entity_id) 
WHERE is_primary = true;

CREATE UNIQUE INDEX idx_usage_phone_primary
ON usage_phone (entity_type, entity_id)
WHERE is_primary = true;

CREATE UNIQUE INDEX idx_usage_address_primary
ON usage_address (entity_type, entity_id)
WHERE is_primary = true;

-- Social media username uniqueness per platform per tenant
ALTER TABLE social_media ADD CONSTRAINT uq_social_media_platform_username 
UNIQUE (tenant_id, platform, username);
```

### Data Integrity
```sql
-- Ensure entity references are valid
ALTER TABLE usage_email ADD CONSTRAINT chk_valid_entity_reference
CHECK (
    (entity_type = 'user' AND EXISTS (SELECT 1 FROM users WHERE id = entity_id)) OR
    (entity_type = 'persona' AND EXISTS (SELECT 1 FROM personas WHERE id = entity_id))
);

-- Ensure effective date ranges are valid
ALTER TABLE usage_address ADD CONSTRAINT chk_valid_date_range
CHECK (effective_to IS NULL OR effective_to >= effective_from);
```

## Usage Patterns

### Common Contact Operations

#### Getting All Contact Info for a Persona
```sql
SELECT 
    'email' as contact_type,
    ea.email_address as contact_value,
    ue.usage_type,
    ue.is_primary
FROM personas p
JOIN usage_email ue ON ue.entity_id = p.id AND ue.entity_type = 'persona'
JOIN email_address ea ON ue.email_id = ea.id
WHERE p.id = ?

UNION ALL

SELECT 
    'phone' as contact_type,
    pn.phone_number as contact_value,
    up.usage_type,
    up.is_primary
FROM personas p  
JOIN usage_phone up ON up.entity_id = p.id AND up.entity_type = 'persona'
JOIN phone_number pn ON up.phone_id = pn.id
WHERE p.id = ?

UNION ALL

SELECT
    'address' as contact_type,
    a.formatted_address as contact_value,
    ua.usage_type,
    ua.is_primary
FROM personas p
JOIN usage_address ua ON ua.entity_id = p.id AND ua.entity_type = 'persona'  
JOIN address a ON ua.address_id = a.id
WHERE p.id = ?;
```

#### Finding Contact Duplicates
```sql
-- Find duplicate email addresses
SELECT email_address, COUNT(*) as usage_count
FROM email_address
WHERE tenant_id = ?
GROUP BY email_address
HAVING COUNT(*) > 1;

-- Find duplicate phone numbers  
SELECT phone_number, COUNT(*) as usage_count
FROM phone_number
WHERE tenant_id = ?
GROUP BY phone_number
HAVING COUNT(*) > 1;
```

#### Contact Privacy and Sharing
```sql
-- Get contacts shared with family
SELECT 
    sm.platform,
    sm.username,
    usm.usage_type
FROM personas p
JOIN usage_social_media usm ON usm.entity_id = p.id AND usm.entity_type = 'persona'
JOIN social_media sm ON usm.social_media_id = sm.id
WHERE p.id = ? 
AND usm.share_with_family = true;
```

### Performance Optimization

#### Recommended Indexes
```sql
-- Contact lookup indexes
CREATE INDEX idx_email_address_lookup ON email_address (tenant_id, email_address);
CREATE INDEX idx_phone_number_lookup ON phone_number (tenant_id, phone_number);
CREATE INDEX idx_address_tenant ON address (tenant_id);

-- Usage junction indexes  
CREATE INDEX idx_usage_email_entity ON usage_email (entity_type, entity_id);
CREATE INDEX idx_usage_phone_entity ON usage_phone (entity_type, entity_id);
CREATE INDEX idx_usage_address_entity ON usage_address (entity_type, entity_id);

-- Social media platform index
CREATE INDEX idx_social_media_platform ON social_media (tenant_id, platform);
```

### Contact Validation Procedures
```sql
-- Validate email format
CREATE OR REPLACE FUNCTION fn_validate_email(email TEXT) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql;

-- Validate phone number format  
CREATE OR REPLACE FUNCTION fn_validate_phone(phone TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN phone ~ '^\+[1-9]\d{1,14}$';
END;
$$ LANGUAGE plpgsql;
```

---

*This normalized contact management system provides the Forward Inheritance Platform with flexible, consistent, and privacy-aware contact information handling across all user types and entities, supporting complex family relationship management while maintaining data integrity and avoiding duplication.*