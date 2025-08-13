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
- **Core Contact Tables**: 4 tables (email_address, phone_number, address, social_media)
- **Usage Junction Tables**: 4 tables linking contacts to entities
- **External Contact Tables**: 1 table (contact_info) for external relationship management
- **Total Tables**: 9 contact management tables
- **Supported Entity Types**: users, personas, assets (polymorphic via entity_type enum)

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
└── contact_info (external entities)
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
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
International phone number storage with country code support.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT valid_phone_format CHECK (phone_number ~ '^[0-9]{10,15}$'),
    CONSTRAINT valid_country_code CHECK (country_code ~ '^\+[0-9]{1,4}$')
);
```

**Phone Types:**
- **mobile** - Mobile/cellular phones
- **landline** - Traditional landline phones
- **voip** - Voice over IP numbers
- **toll_free** - Toll-free numbers
- **fax** - Fax numbers

**Key Features:**
- **Country Code Support**: Separate country code field with default '+1'
- **Extension Support**: Optional extension field for business numbers
- **SMS Capability**: Track whether number can receive SMS
- **Mobile Detection**: Flag to indicate mobile vs landline
- **Carrier Information**: Optional carrier name tracking

### address table
Physical address storage with geocoding support and validation.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT valid_country_code CHECK (country ~ '^[A-Z]{2}$'),
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
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
- **Geocoding Support**: Latitude/longitude with accuracy tracking
- **Address Validation**: Track validation status and source
- **Coordinate Validation**: Ensures valid lat/long ranges
- **Flexible Structure**: Supports various international address formats

### social_media table
Social media account and profile information storage.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT valid_username CHECK (username != ''),
    CONSTRAINT valid_follower_count CHECK (follower_count >= 0 OR follower_count IS NULL)
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
Links entities (users/personas/assets) to email addresses with usage context.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint for entity-email combination
    CONSTRAINT usage_email_entity_email_unique UNIQUE (entity_type, entity_id, email_id)
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Unique constraint for entity-phone combination
    CONSTRAINT usage_phone_entity_phone_unique UNIQUE (entity_type, entity_id, phone_id)
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date > effective_date)
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
Links entities to social media accounts with access details.

```sql  
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT valid_license_state CHECK (license_state ~ '^[A-Z]{2}$' OR license_state IS NULL)
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

### Usage Relationship Patterns (Polymorphic)
```sql
-- Entity contact usage through polymorphic entity_type_enum
entity (via entity_type + entity_id) → usage_email ← email_address
entity (via entity_type + entity_id) → usage_phone ← phone_number  
entity (via entity_type + entity_id) → usage_address ← address
entity (via entity_type + entity_id) → usage_social_media ← social_media

-- Where entity_type can be: 'user', 'persona', 'asset'
-- This allows flexible contact association without separate junction tables
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
    email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
);

-- Phone number format (10-15 digits)
CONSTRAINT valid_phone_format CHECK (
    phone_number ~ '^[0-9]{10,15}$'
);

-- Country code format for phone
CONSTRAINT valid_country_code CHECK (
    country_code ~ '^\+[0-9]{1,4}$'
);

-- Country code validation for address (ISO 3166-1 alpha-2)
CONSTRAINT valid_country_code CHECK (
    country ~ '^[A-Z]{2}$'
);

-- Coordinate validation for geocoding
CONSTRAINT valid_coordinates CHECK (
    (latitude IS NULL AND longitude IS NULL) OR
    (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
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

-- No unique constraint on social media username in implementation
-- Each record is unique by ID only
```

### Data Integrity
```sql
-- Ensure date ranges are valid for addresses
ALTER TABLE usage_address ADD CONSTRAINT valid_date_range
CHECK (end_date IS NULL OR end_date > effective_date);

-- Ensure follower count is positive
ALTER TABLE social_media ADD CONSTRAINT valid_follower_count
CHECK (follower_count >= 0 OR follower_count IS NULL);

-- Ensure usernames are not empty
ALTER TABLE social_media ADD CONSTRAINT valid_username
CHECK (username != '');

-- Ensure license state is valid format
ALTER TABLE contact_info ADD CONSTRAINT valid_license_state
CHECK (license_state ~ '^[A-Z]{2}$' OR license_state IS NULL);
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

#### Contact Privacy and Access
```sql
-- Get social media accounts with login credentials
SELECT 
    sm.platform,
    sm.username,
    usm.usage_type,
    usm.has_login_credentials
FROM personas p
JOIN usage_social_media usm ON usm.entity_id = p.id AND usm.entity_type = 'persona'
JOIN social_media sm ON usm.social_media_id = sm.id
WHERE p.id = ? 
AND usm.has_login_credentials = true;
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
    RETURN phone ~ '^[0-9]{10,15}$';
END;
$$ LANGUAGE plpgsql;
```

---

*This normalized contact management system provides the Forward Inheritance Platform with flexible, consistent, and privacy-aware contact information handling across all user types and entities, supporting complex family relationship management while maintaining data integrity and avoiding duplication.*