# 08 - Security, Audit & Session Management Tables

## Table of Contents
1. [Overview](#overview)
2. [Security Architecture](#security-architecture)
3. [Authentication & Session Management](#authentication--session-management)
4. [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)
5. [Asset-Level Permissions](#asset-level-permissions)
6. [Audit & Compliance Tables](#audit--compliance-tables)
7. [Document & Media Security](#document--media-security)
8. [PII Processing & Compliance](#pii-processing--compliance)
9. [Integration & External Systems](#integration--external-systems)
10. [Security Constraints & Validation](#security-constraints--validation)
11. [Security Best Practices](#security-best-practices)

## Overview

The Forward Inheritance Platform implements a comprehensive **multi-layered security architecture** that covers authentication, authorization, audit logging, compliance tracking, and data protection. The system supports **20 security-related tables** organized into functional groups for maximum security coverage.

### Security Architecture Components
- **Authentication Layer**: User sessions, verification workflows, password management
- **Authorization Layer**: Hybrid RBAC + asset-level permissions for enterprise and family scenarios
- **Asset Permissions**: Direct asset access control optimized for family inheritance management
- **Audit Layer**: Complete activity logging and business event tracking
- **Compliance Layer**: PII processing, data retention, regulatory compliance
- **Document Security**: Media storage access control and versioning
- **Integration Security**: External system authentication and sync logging

### Key Statistics
- **Authentication Tables**: 4 tables for user authentication and security
- **RBAC Tables**: 4 tables for role-based access control
- **Asset Permissions**: 1 table for direct asset access control
- **Audit Tables**: 2 tables for audit logging
- **PII Processing**: 4 tables for PII detection and masking
- **Integration Tables**: 3 tables for external system integration
- **Translation Table**: 1 table for multi-language support
- **Total Security Tables**: 19 tables covering all security aspects

## Security Architecture

### Multi-Layer Security Model
```
Application Layer
├── Authentication & Sessions (8 tables)
├── Role-Based Access Control (4 tables)
├── Asset-Level Permissions (1 table)
├── Audit & Compliance (6 tables)
└── Integration Security (6 tables)

Data Protection Layer
├── Encryption at Rest
├── PII Detection & Masking
├── Audit Trail Integrity
└── Tenant Isolation

Permission Resolution
├── System Admin (Override All)
├── RBAC Roles (FFC-level)
├── Asset Permissions (Direct)
└── Default Deny
```

### Security Flow
```
User Request → Authentication → Authorization → Action → Audit Log
     ↓              ↓              ↓           ↓         ↓
Session Validation → Permission Check → Business Logic → Compliance Tracking
```

## Authentication & Session Management

### user_sessions table
Manages active user sessions with security tracking and automatic expiration.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
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
```

**Key Features:**
- **Secure Tokens**: Cryptographically secure session and refresh tokens
- **Device Tracking**: IP address, user agent, and device fingerprinting
- **Automatic Expiration**: 7-day default with configurable timeouts
- **Security Context**: Login method and MFA verification status
- **Activity Tracking**: Last activity timestamp for idle timeout

### user_mfa_settings table
Multi-factor authentication settings for users.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_user_mfa UNIQUE (user_id)
);
```

### password_reset_tokens table
Secure password reset token management with expiration and single-use enforcement.

```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    
    -- Token details
    token_hash TEXT NOT NULL UNIQUE,
    
    -- Token lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
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
```

**Key Features:**
- **Token Security**: Hashed tokens for storage
- **Single Use**: Enforced through constraints
- **Request Tracking**: IP and user agent logging
- **Automatic Invalidation**: Status tracking with reasons
```

### user_login_history table
Comprehensive login attempt tracking for security analysis and forensics.

```sql
CREATE TABLE user_login_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- Can be NULL for failed attempts
    email TEXT NOT NULL, -- Track even failed attempts
    
    -- Attempt details
    attempt_timestamp TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
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
```

**Key Features:**
- **Comprehensive Tracking**: All login attempts logged
- **Risk Assessment**: Risk scoring with factor tracking
- **Location Tracking**: Country and city level geo-tracking
- **MFA Status**: Tracks whether MFA was required and completed
- **Device Fingerprinting**: Device ID tracking for pattern analysis

## Role-Based Access Control (RBAC)

### user_roles table
Defines available roles in the system with hierarchical support.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT unique_role_name_per_tenant UNIQUE (tenant_id, name)
);
```

### user_permissions table
Defines granular permissions for system functionality.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT unique_permission_per_tenant UNIQUE (tenant_id, category, resource, action)
);
```

### role_permissions table
Junction table linking roles to their specific permissions.

```sql
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    
    -- Grant details
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    granted_by UUID,
    
    -- Constraints
    CONSTRAINT unique_permission_per_role UNIQUE (role_id, permission_id)
);
```

### user_role_assignments table
Assigns roles to users within specific contexts (tenant/FFC scope).

```sql
CREATE TABLE user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    ffc_id UUID, -- NULL for platform_admin
    
    -- Assignment details
    assigned_by UUID NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

## Asset-Level Permissions

The Forward Inheritance Platform implements a **hybrid permission system** that combines enterprise-grade RBAC with family-friendly asset-level permissions. This dual approach provides both sophisticated organizational security and intuitive permission management for family asset scenarios.

### asset_permissions table
Direct asset-to-persona permission mapping for granular access control.

```sql
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

**Key Features:**
- **Direct Permissions**: Simple asset-to-persona permission mapping
- **Three Permission Levels**: Read, edit, and admin access levels
- **Family-Friendly**: Intuitive "who can see what" model
- **High Performance**: Optimized for common "show my assets" queries
- **Audit Trail**: Tracks who granted permissions and when

### Hybrid Permission Model

The platform uses a **two-tier permission architecture**:

#### 1. RBAC System (Enterprise Operations)
- **Use Cases**: FFC management, role-based operations, system administration
- **Benefits**: Scalable, maintainable, enterprise-grade security
- **Scope**: FFC-level roles with fine-grained permissions

#### 2. Asset Permissions (Family Scenarios)
- **Use Cases**: Individual asset access, family inheritance scenarios
- **Benefits**: Fast queries, intuitive management, granular control
- **Scope**: Direct asset-to-persona relationships

### Permission Resolution Order
1. **System Admin**: Overrides all other permissions
2. **RBAC Roles**: Applied at FFC level (e.g., "Family Admin")
3. **Asset Permissions**: Specific overrides for individual assets
4. **Default Deny**: No access if no explicit permission

### Common Usage Patterns

#### Family Asset Management
```sql
-- Give kids read access to family home
INSERT INTO asset_permissions (tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id)
VALUES (1, 'family-home-uuid', 'child1-persona-uuid', 'read', 'parent-persona-uuid');

-- Allow spouse to edit financial accounts
INSERT INTO asset_permissions (tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id)
VALUES (1, 'bank-account-uuid', 'spouse-persona-uuid', 'edit', 'owner-persona-uuid');
```

#### Financial Advisor Access
```sql
-- Grant advisor read access to all assets except personal items
-- (Combined with RBAC role limiting to financial categories)
SELECT a.id, a.name, ap.permission_level
FROM assets a
JOIN asset_permissions ap ON a.id = ap.asset_id
WHERE ap.persona_id = 'advisor-persona-uuid'
  AND ap.permission_level IN ('read', 'edit', 'admin');
```

#### Performance-Optimized Queries
```sql
-- Fast "show all assets this user can access" query
SELECT DISTINCT a.*
FROM assets a
JOIN asset_permissions ap ON a.id = ap.asset_id
WHERE ap.persona_id = 'user-persona-uuid'
  AND ap.permission_level IN ('read', 'edit', 'admin')
ORDER BY a.name;
```

### Integration with RBAC

The asset permissions system **complements** rather than **replaces** the RBAC system:

- **RBAC**: Handles broad permissions like "can create assets" or "can invite family members"
- **Asset Permissions**: Handles specific access like "can view the family home details"
- **Combined Power**: Family Admin role + specific asset permissions = comprehensive access control

## Audit & Compliance Tables

### audit_log table
Comprehensive action-level audit logging for compliance and security analysis.

```sql
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
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}'
);
```

### audit_events table
Business-level event tracking for weekly reports and high-level monitoring.

```sql
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
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    detected_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Response
    response_action TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID,
    
    -- Constraints
    CONSTRAINT valid_severity CHECK (severity IN ('info', 'warning', 'error', 'critical'))
);
```

### pii_detection_rules table
Rules for detecting and handling PII in documents and data.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### pii_processing_jobs table
Tracks PII scanning and processing jobs.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    scheduled_by UUID,
    
    -- Constraints
    CONSTRAINT valid_job_status CHECK (status IN ('pending', 'running', 'completed', 'failed'))
);
```

### masking_configurations table
Configure data masking rules for PII protection.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_masking_rule UNIQUE (tenant_id, table_name, column_name)
);
```

### pii_access_logs table
Track access to PII data for compliance.

```sql
CREATE TABLE pii_access_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Access details
    user_id UUID NOT NULL,
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
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
```

## Translation Support

### translations table
Multi-language support for UI and content.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_translation_key UNIQUE (translation_key, language_code)
);
```

## Integration & External Systems

### advisor_companies table
Professional service providers management.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT valid_rating CHECK (service_rating BETWEEN 1 AND 5 OR service_rating IS NULL),
    CONSTRAINT valid_license_state CHECK (license_state ~ '^[A-Z]{2}$' OR license_state IS NULL)
);
```

### builder_io_integrations table
Builder.io CMS integration for dynamic content.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT unique_builder_integration UNIQUE (tenant_id)
);
```

### quillt_integrations table
Quillt financial data integration.

```sql
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    
    -- Constraints
    CONSTRAINT unique_quillt_user UNIQUE (tenant_id, user_id)
);
```

### real_estate_sync_logs table
Track real estate data synchronization.

```sql
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
    confidence_score DECIMAL(3,2),
    
    -- Status
    sync_status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT,
    
    -- Timing
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    processing_time_ms INTEGER,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC')
);
```

## Key Security Features

### Authentication & Sessions
- **AWS Cognito Integration**: Authentication handled by AWS Cognito
- **Session Management**: Secure session tokens with device tracking
- **MFA Support**: TOTP, SMS, and email-based multi-factor authentication
- **Password Reset**: Secure token-based password reset flow

### Role-Based Access Control
- **Flexible Roles**: Tenant-scoped roles with customizable permissions
- **FFC-Level Assignment**: Roles can be assigned at family circle level
- **Permission Categories**: Granular permissions organized by category
- **Revocation Support**: Time-based and manual role revocation

### Audit & Compliance
- **Comprehensive Logging**: All actions logged with actor, entity, and changes
- **Event Tracking**: Business-level events for reporting
- **Immutable Audit Trail**: Append-only audit log with metadata

### PII Protection
- **Detection Rules**: Configurable PII detection patterns
- **Data Masking**: Flexible masking configurations per table/column
- **Access Logging**: Track all PII data access for compliance
- **Processing Jobs**: Batch PII scanning and masking operations

### Integration Security
- **Encrypted Credentials**: All API keys and tokens encrypted
- **Connection Status Tracking**: Monitor integration health
- **Sync Logging**: Detailed logs of all synchronization operations

---

*This comprehensive security architecture provides the Forward Inheritance Platform with enterprise-grade security, audit, and compliance capabilities, ensuring the protection of sensitive family financial data while meeting regulatory requirements and industry best practices.*