# 08 - Security, Audit & Session Management Tables

## Table of Contents
1. [Overview](#overview)
2. [Security Architecture](#security-architecture)
3. [Authentication & Session Management](#authentication--session-management)
4. [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)
5. [Audit & Compliance Tables](#audit--compliance-tables)
6. [Document & Media Security](#document--media-security)
7. [PII Processing & Compliance](#pii-processing--compliance)
8. [Integration & External Systems](#integration--external-systems)
9. [Security Constraints & Validation](#security-constraints--validation)
10. [Security Best Practices](#security-best-practices)

## Overview

The Forward Inheritance Platform implements a comprehensive **multi-layered security architecture** that covers authentication, authorization, audit logging, compliance tracking, and data protection. The system supports **19 security-related tables** organized into functional groups for maximum security coverage.

### Security Architecture Components
- **Authentication Layer**: User sessions, verification workflows, password management
- **Authorization Layer**: Role-based access control with granular permissions
- **Audit Layer**: Complete activity logging and business event tracking
- **Compliance Layer**: PII processing, data retention, regulatory compliance
- **Document Security**: Media storage access control and versioning
- **Integration Security**: External system authentication and sync logging

### Key Statistics
- **Authentication Tables**: 8 tables for user authentication and security
- **RBAC Tables**: 4 tables for role-based access control
- **Audit Tables**: 6 tables for comprehensive audit and compliance
- **Integration Tables**: 6 tables for external system security
- **Total Security Tables**: 19 tables covering all security aspects

## Security Architecture

### Multi-Layer Security Model
```
Application Layer
├── Authentication & Sessions (8 tables)
├── Role-Based Access Control (4 tables)
├── Audit & Compliance (6 tables)
└── Integration Security (6 tables)

Data Protection Layer
├── Encryption at Rest
├── PII Detection & Masking
├── Audit Trail Integrity
└── Tenant Isolation
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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Session details
    session_token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    refresh_token UUID DEFAULT gen_random_uuid(),
    
    -- Session metadata
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_info JSONB DEFAULT '{}',
    
    -- Session lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'),
    
    -- Session status
    is_active BOOLEAN DEFAULT TRUE,
    logout_reason VARCHAR(100), -- manual, timeout, security, admin
    
    -- Security tracking
    login_method VARCHAR(50), -- password, sso, mfa
    mfa_verified BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- **Secure Tokens**: Cryptographically secure session and refresh tokens
- **Device Tracking**: IP address, user agent, and device fingerprinting
- **Automatic Expiration**: 7-day default with configurable timeouts
- **Security Context**: Login method and MFA verification status
- **Activity Tracking**: Last activity timestamp for idle timeout

### email_verifications table
Manages email verification workflow for user registration and email changes.

```sql
CREATE TABLE email_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email_id UUID NOT NULL REFERENCES email_address(id),
    
    -- Verification details
    verification_token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    verification_code VARCHAR(6), -- Optional 6-digit code
    
    -- Verification lifecycle
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '24 hours'),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Attempt tracking
    attempt_count INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 5,
    
    -- Status
    is_verified BOOLEAN DEFAULT FALSE,
    is_expired BOOLEAN GENERATED ALWAYS AS (NOW() > expires_at) STORED,
    
    -- Security tracking
    verification_ip INET,
    verification_user_agent TEXT,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### phone_verifications table
Manages SMS-based phone verification with rate limiting and security controls.

```sql
CREATE TABLE phone_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    phone_id UUID NOT NULL REFERENCES phone_number(id),
    
    -- Verification details
    verification_code VARCHAR(6) NOT NULL,
    code_hash VARCHAR(255) NOT NULL, -- Hashed verification code
    
    -- Verification lifecycle
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '10 minutes'),
    verified_at TIMESTAMP WITH TIME ZONE,
    
    -- Rate limiting
    attempt_count INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    daily_send_count INTEGER DEFAULT 1,
    max_daily_sends INTEGER DEFAULT 5,
    
    -- Status
    is_verified BOOLEAN DEFAULT FALSE,
    is_expired BOOLEAN GENERATED ALWAYS AS (NOW() > expires_at) STORED,
    
    -- Security tracking
    verification_ip INET,
    verification_user_agent TEXT,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### password_reset_tokens table
Secure password reset token management with expiration and single-use enforcement.

```sql
CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Token details
    reset_token UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    token_hash VARCHAR(255) NOT NULL, -- Hashed token for security
    
    -- Token lifecycle
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '1 hour'),
    used_at TIMESTAMP WITH TIME ZONE,
    
    -- Usage tracking
    is_used BOOLEAN DEFAULT FALSE,
    is_expired BOOLEAN GENERATED ALWAYS AS (NOW() > expires_at) STORED,
    
    -- Security tracking
    request_ip INET,
    request_user_agent TEXT,
    reset_ip INET,
    reset_user_agent TEXT,
    
    -- Audit
    created_by UUID REFERENCES users(id)
);
```

### user_login_history table
Comprehensive login attempt tracking for security analysis and forensics.

```sql
CREATE TABLE user_login_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id), -- NULL for failed attempts with invalid user
    
    -- Login attempt details
    email_attempted VARCHAR(255) NOT NULL,
    login_successful BOOLEAN NOT NULL,
    failure_reason VARCHAR(100), -- invalid_credentials, account_locked, etc.
    
    -- Session information
    session_id UUID REFERENCES user_sessions(id),
    
    -- Security context
    ip_address INET NOT NULL,
    user_agent TEXT,
    device_info JSONB DEFAULT '{}',
    geolocation JSONB, -- Optional geolocation data
    
    -- Authentication details
    authentication_method VARCHAR(50), -- password, sso, mfa
    mfa_used BOOLEAN DEFAULT FALSE,
    
    -- Timing
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Risk assessment
    risk_score INTEGER, -- 0-100 risk assessment
    is_suspicious BOOLEAN DEFAULT FALSE,
    
    -- Tenant context
    tenant_id INTEGER REFERENCES tenants(id)
);
```

### mfa_settings table
Multi-factor authentication configuration and backup codes.

```sql
CREATE TABLE mfa_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- MFA configuration
    is_enabled BOOLEAN DEFAULT FALSE,
    mfa_method VARCHAR(50) NOT NULL, -- totp, sms, email
    
    -- TOTP settings
    totp_secret_encrypted TEXT, -- Encrypted TOTP secret
    totp_verified BOOLEAN DEFAULT FALSE,
    
    -- Backup codes
    backup_codes_encrypted TEXT[], -- Array of encrypted backup codes
    backup_codes_used INTEGER DEFAULT 0,
    
    -- Recovery settings
    recovery_email VARCHAR(255),
    recovery_phone VARCHAR(20),
    
    -- Status
    enabled_at TIMESTAMP WITH TIME ZONE,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### user_preferences table
User security preferences and privacy settings.

```sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Security preferences
    session_timeout_minutes INTEGER DEFAULT 480, -- 8 hours
    require_mfa_for_sensitive BOOLEAN DEFAULT TRUE,
    allow_multiple_sessions BOOLEAN DEFAULT TRUE,
    
    -- Privacy preferences
    share_activity_with_family BOOLEAN DEFAULT TRUE,
    allow_family_member_visibility BOOLEAN DEFAULT TRUE,
    
    -- Notification preferences
    email_security_alerts BOOLEAN DEFAULT TRUE,
    sms_security_alerts BOOLEAN DEFAULT FALSE,
    login_notifications BOOLEAN DEFAULT TRUE,
    
    -- Data preferences
    data_retention_preference retention_policy_enum DEFAULT '7_years',
    allow_analytics BOOLEAN DEFAULT TRUE,
    
    -- UI preferences
    theme VARCHAR(20) DEFAULT 'light',
    language VARCHAR(5) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### security_questions table
Security question management for account recovery and additional authentication.

```sql
CREATE TABLE security_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Question details
    question_id INTEGER NOT NULL, -- Reference to predefined questions
    question_text VARCHAR(500) NOT NULL,
    answer_hash VARCHAR(255) NOT NULL, -- Hashed and salted answer
    answer_salt VARCHAR(255) NOT NULL,
    
    -- Usage tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE,
    correct_attempts INTEGER DEFAULT 0,
    failed_attempts INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Role-Based Access Control (RBAC)

### user_roles table
Defines available roles in the system with hierarchical support.

```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Role definition
    name VARCHAR(100) NOT NULL UNIQUE, -- platform_admin, ffc_owner, ffc_member, etc.
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Role hierarchy
    parent_role_id UUID REFERENCES user_roles(id),
    hierarchy_level INTEGER NOT NULL DEFAULT 0,
    
    -- Role properties
    is_system_role BOOLEAN NOT NULL DEFAULT FALSE,
    is_default_role BOOLEAN NOT NULL DEFAULT FALSE,
    max_permissions INTEGER, -- Optional limit on permissions
    
    -- Role scope
    applies_to_tenant BOOLEAN DEFAULT TRUE,
    applies_to_ffc BOOLEAN DEFAULT TRUE,
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### user_permissions table
Defines granular permissions for system functionality.

```sql
CREATE TABLE user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Permission definition
    name VARCHAR(100) NOT NULL UNIQUE, -- asset.create, user.invite, etc.
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    category permission_category_enum NOT NULL,
    
    -- Permission properties
    is_dangerous BOOLEAN NOT NULL DEFAULT FALSE, -- For destructive operations
    requires_2fa BOOLEAN NOT NULL DEFAULT FALSE,
    requires_approval BOOLEAN DEFAULT FALSE,
    
    -- Permission scope
    resource_type VARCHAR(100), -- asset, user, ffc, document, etc.
    action_type VARCHAR(100), -- create, read, update, delete, etc.
    
    -- Dependencies
    depends_on_permissions UUID[], -- Array of permission IDs
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### role_permissions table
Junction table linking roles to their specific permissions.

```sql
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL REFERENCES user_roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES user_permissions(id) ON DELETE CASCADE,
    
    -- Grant details
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    granted_by UUID REFERENCES users(id),
    
    -- Permission modifiers
    is_denied BOOLEAN DEFAULT FALSE, -- Explicit denial (overrides grants)
    conditions JSONB, -- Conditional permissions
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(role_id, permission_id)
);
```

### user_role_assignments table
Assigns roles to users within specific contexts (tenant/FFC scope).

```sql
CREATE TABLE user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES user_roles(id),
    
    -- Assignment scope
    tenant_id INTEGER REFERENCES tenants(id), -- NULL for global assignments
    ffc_id UUID REFERENCES fwd_family_circles(id), -- NULL for tenant-wide assignments
    
    -- Assignment details
    assigned_by UUID NOT NULL REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Assignment conditions
    conditions JSONB, -- Conditional role assignments
    
    -- Assignment properties
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_temporary BOOLEAN DEFAULT FALSE,
    notes TEXT,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Constraints
    UNIQUE(user_id, role_id, tenant_id, ffc_id),
    CHECK (expires_at IS NULL OR expires_at > assigned_at)
);
```

## Audit & Compliance Tables

### audit_log table
Comprehensive action-level audit logging for compliance and security analysis.

```sql
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Action context
    user_id UUID REFERENCES users(id), -- NULL for system actions
    session_id UUID REFERENCES user_sessions(id),
    
    -- Action details
    action VARCHAR(100) NOT NULL, -- CREATE, UPDATE, DELETE, LOGIN, etc.
    entity_type VARCHAR(100) NOT NULL, -- user, asset, persona, etc.
    entity_id UUID, -- ID of the affected entity
    
    -- Change tracking
    old_values JSONB,
    new_values JSONB,
    
    -- Request context
    ip_address INET,
    user_agent TEXT,
    request_id UUID, -- For correlating related actions
    
    -- Additional context
    additional_data JSONB DEFAULT '{}',
    error_message TEXT, -- For failed actions
    
    -- Compliance
    compliance_tags VARCHAR(100)[], -- SOC2, HIPAA, GDPR, etc.
    retention_policy retention_policy_enum DEFAULT '7_years',
    
    -- Timing
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Integrity
    checksum VARCHAR(64), -- For audit log integrity
    
    -- Indexes for performance
    CONSTRAINT valid_occurred_at CHECK (occurred_at <= NOW())
);
```

### audit_events table
Business-level event tracking for weekly reports and high-level monitoring.

```sql
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    ffc_id UUID REFERENCES fwd_family_circles(id),
    
    -- Event details
    event_type VARCHAR(100) NOT NULL, -- asset_created, ownership_transferred, etc.
    event_category VARCHAR(50) NOT NULL, -- security, business, compliance
    
    -- Event context
    triggered_by_user_id UUID REFERENCES users(id),
    affected_persona_ids UUID[], -- Array of affected persona IDs
    
    -- Event data
    event_summary TEXT NOT NULL,
    event_details JSONB DEFAULT '{}',
    
    -- Severity and impact
    severity_level VARCHAR(20) DEFAULT 'info', -- critical, warning, info
    business_impact VARCHAR(100),
    
    -- Related entities
    related_asset_ids UUID[],
    related_document_ids UUID[],
    
    -- Timing
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Reporting
    include_in_weekly_report BOOLEAN DEFAULT TRUE,
    report_category VARCHAR(100),
    
    -- Resolution (for issues)
    is_resolved BOOLEAN DEFAULT TRUE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolution_notes TEXT
);
```

### pii_processing_jobs table
Tracks PII detection and masking operations for compliance.

```sql
CREATE TABLE pii_processing_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Job details
    job_type VARCHAR(50) NOT NULL, -- detection, masking, anonymization
    status pii_status_enum DEFAULT 'pending',
    
    -- Target information
    target_entity_type VARCHAR(100) NOT NULL, -- document, asset, user
    target_entity_id UUID NOT NULL,
    
    -- Processing details
    initiated_by UUID NOT NULL REFERENCES users(id),
    processor_version VARCHAR(50),
    
    -- Results
    pii_types_found VARCHAR(100)[],
    pii_count INTEGER DEFAULT 0,
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    
    -- Processing metadata
    processing_options JSONB DEFAULT '{}',
    processing_results JSONB DEFAULT '{}',
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    processing_duration_ms INTEGER,
    
    -- Status tracking
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    
    -- Compliance
    regulatory_context VARCHAR(100)[], -- GDPR, CCPA, HIPAA
    retention_period INTEGER -- Days to retain results
);
```

### compliance_reports table
Automated compliance report generation and storage.

```sql
CREATE TABLE compliance_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Report details
    report_type VARCHAR(100) NOT NULL, -- weekly_activity, soc2_audit, gdpr_compliance
    report_period_start DATE NOT NULL,
    report_period_end DATE NOT NULL,
    
    -- Generation details
    generated_by UUID REFERENCES users(id), -- NULL for automated reports
    generation_triggered_by VARCHAR(100), -- scheduled, manual, compliance_request
    
    -- Report content
    report_summary TEXT,
    report_data JSONB NOT NULL,
    
    -- File storage
    report_file_id UUID REFERENCES media_storage(id),
    report_format VARCHAR(20) DEFAULT 'pdf', -- pdf, json, csv
    
    -- Distribution
    distributed_to UUID[], -- Array of user IDs who received the report
    distribution_method VARCHAR(50), -- email, download, api
    
    -- Status
    status VARCHAR(50) DEFAULT 'completed',
    
    -- Timing
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    distributed_at TIMESTAMP WITH TIME ZONE,
    
    -- Compliance tracking
    compliance_frameworks VARCHAR(100)[], -- SOC2, GDPR, HIPAA
    external_audit_reference VARCHAR(200)
);
```

### data_retention_policies table
Manages data retention policies for different data types and compliance requirements.

```sql
CREATE TABLE data_retention_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Policy details
    policy_name VARCHAR(200) NOT NULL,
    data_type VARCHAR(100) NOT NULL, -- audit_logs, documents, user_data
    
    -- Retention rules
    retention_period retention_policy_enum NOT NULL,
    retention_period_days INTEGER, -- Computed from enum
    
    -- Policy scope
    applies_to_entity_type VARCHAR(100), -- All, or specific entity types
    policy_conditions JSONB DEFAULT '{}',
    
    -- Actions
    action_on_expiry VARCHAR(50) DEFAULT 'soft_delete', -- soft_delete, hard_delete, archive
    archive_location VARCHAR(200),
    
    -- Legal holds
    legal_hold_exempt BOOLEAN DEFAULT FALSE,
    compliance_requirements VARCHAR(100)[],
    
    -- Automation
    is_automated BOOLEAN DEFAULT TRUE,
    last_executed_at TIMESTAMP WITH TIME ZONE,
    next_execution_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### system_configurations table
System-wide security and operational configuration settings.

```sql
CREATE TABLE system_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER REFERENCES tenants(id), -- NULL for global settings
    
    -- Configuration details
    config_key VARCHAR(200) NOT NULL,
    config_value TEXT NOT NULL,
    config_type VARCHAR(50) NOT NULL, -- string, integer, boolean, json
    
    -- Configuration metadata
    display_name VARCHAR(200),
    description TEXT,
    category VARCHAR(100), -- security, compliance, integration, ui
    
    -- Validation
    allowed_values TEXT[], -- For enumerated values
    validation_regex VARCHAR(500),
    min_value DECIMAL,
    max_value DECIMAL,
    
    -- Security
    is_sensitive BOOLEAN DEFAULT FALSE, -- Encrypted in database
    requires_restart BOOLEAN DEFAULT FALSE,
    
    -- Change management
    previous_value TEXT,
    changed_by UUID REFERENCES users(id),
    change_reason TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(tenant_id, config_key)
);
```

## Document & Media Security

### document_versions table
Version control and change tracking for documents.

```sql
CREATE TABLE document_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    media_storage_id UUID NOT NULL REFERENCES media_storage(id),
    
    -- Version details
    version_number INTEGER NOT NULL,
    version_label VARCHAR(100), -- v1.0, draft, final
    
    -- Change tracking
    change_summary TEXT,
    changed_by UUID NOT NULL REFERENCES users(id),
    change_type VARCHAR(50), -- minor, major, content, metadata
    
    -- Version metadata
    file_size BIGINT NOT NULL,
    checksum VARCHAR(64) NOT NULL,
    
    -- Status
    is_current BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    
    -- Timing
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(document_id, version_number)
);
```

### document_access_log table
Tracks document access for compliance and security monitoring.

```sql
CREATE TABLE document_access_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Access details
    document_id UUID NOT NULL REFERENCES documents(id),
    media_storage_id UUID REFERENCES media_storage(id),
    accessed_by UUID NOT NULL REFERENCES users(id),
    
    -- Access context
    access_type VARCHAR(50) NOT NULL, -- view, download, print, share
    access_method VARCHAR(50), -- web, api, mobile
    
    -- Request context
    session_id UUID REFERENCES user_sessions(id),
    ip_address INET,
    user_agent TEXT,
    
    -- Access results
    access_granted BOOLEAN NOT NULL,
    denial_reason VARCHAR(200),
    
    -- Document state at access
    document_version INTEGER,
    is_pii_masked BOOLEAN DEFAULT FALSE,
    
    -- Timing
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Compliance
    compliance_tags VARCHAR(100)[],
    retention_days INTEGER DEFAULT 2555 -- 7 years
);
```

## PII Processing & Compliance

The PII processing system automatically detects and optionally masks personally identifiable information in documents and text data to ensure compliance with privacy regulations.

### PII Detection Types
- **Personal Identifiers**: SSN, driver's license numbers, passport numbers
- **Financial Information**: Credit card numbers, bank account numbers
- **Contact Information**: Email addresses, phone numbers, physical addresses
- **Medical Information**: Medical record numbers, health insurance IDs
- **Biometric Data**: Fingerprints, facial recognition data (in images)

### PII Processing Workflow
```sql
-- Automatic PII detection on document upload
INSERT INTO pii_processing_jobs (
    tenant_id, target_entity_type, target_entity_id,
    job_type, initiated_by
) VALUES (
    current_tenant_id(), 'document', new_document_id,
    'detection', current_user_id()
);
```

## Integration & External Systems

### quillt_integrations table
Financial data integration configuration and credentials.

```sql
CREATE TABLE quillt_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    user_id UUID NOT NULL REFERENCES users(id),
    
    -- Integration details
    integration_name VARCHAR(200) NOT NULL,
    provider_name VARCHAR(100) NOT NULL, -- Plaid, Yodlee, etc.
    
    -- Authentication
    api_credentials_encrypted TEXT NOT NULL,
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Configuration
    sync_frequency VARCHAR(50) DEFAULT 'daily', -- hourly, daily, weekly
    auto_sync_enabled BOOLEAN DEFAULT TRUE,
    
    -- Connected accounts
    connected_accounts JSONB DEFAULT '[]',
    account_count INTEGER DEFAULT 0,
    
    -- Status
    integration_status VARCHAR(50) DEFAULT 'active',
    last_successful_sync TIMESTAMP WITH TIME ZONE,
    last_error_message TEXT,
    
    -- Security
    webhook_secret_encrypted TEXT,
    ip_whitelist INET[],
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    configured_by UUID REFERENCES users(id)
);
```

### quillt_sync_logs table
Detailed logging of financial data synchronization operations.

```sql
CREATE TABLE quillt_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    integration_id UUID NOT NULL REFERENCES quillt_integrations(id),
    
    -- Sync details
    sync_type VARCHAR(50) NOT NULL, -- full, incremental, manual
    sync_status VARCHAR(50) NOT NULL, -- started, completed, failed
    
    -- Sync metrics
    accounts_processed INTEGER DEFAULT 0,
    transactions_added INTEGER DEFAULT 0,
    transactions_updated INTEGER DEFAULT 0,
    assets_updated INTEGER DEFAULT 0,
    
    -- Timing
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_ms INTEGER,
    
    -- Results
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    error_details JSONB DEFAULT '{}',
    
    -- Data quality
    data_quality_score DECIMAL(3,2), -- 0.00 to 1.00
    validation_errors JSONB DEFAULT '[]',
    
    -- Compliance
    pii_detected BOOLEAN DEFAULT FALSE,
    compliance_flags VARCHAR(100)[]
);
```

### builder_io_integrations table
Content management system integration for dynamic content delivery.

```sql
CREATE TABLE builder_io_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Builder.io configuration
    space_id VARCHAR(100) NOT NULL,
    api_key_encrypted TEXT NOT NULL,
    model_name VARCHAR(100) DEFAULT 'page',
    
    -- Content configuration
    page_name VARCHAR(200) NOT NULL UNIQUE,
    content_url VARCHAR(500),
    
    -- Caching
    cache_duration_minutes INTEGER DEFAULT 60,
    last_cache_refresh TIMESTAMP WITH TIME ZONE,
    
    -- Content metadata
    content_version VARCHAR(50),
    content_checksum VARCHAR(64),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    last_successful_fetch TIMESTAMP WITH TIME ZONE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### real_estate_sync_logs table
Property valuation and data synchronization tracking.

```sql
CREATE TABLE real_estate_sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    real_estate_id UUID NOT NULL REFERENCES real_estate(id),
    
    -- Sync details
    provider VARCHAR(100) NOT NULL, -- Zillow, Redfin, MLS
    sync_type VARCHAR(50) NOT NULL, -- valuation, details, images
    
    -- Updated data
    previous_value DECIMAL(15,2),
    new_value DECIMAL(15,2),
    value_change_percentage DECIMAL(5,2),
    
    -- Sync results
    sync_successful BOOLEAN NOT NULL,
    error_message TEXT,
    
    -- Data sources
    data_sources JSONB DEFAULT '[]',
    data_confidence DECIMAL(3,2), -- 0.00 to 1.00
    
    -- Timing
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_as_of_date DATE,
    
    -- Compliance
    data_usage_terms TEXT,
    attribution_required BOOLEAN DEFAULT FALSE
);
```

### translations table
Multi-language support and localization data.

```sql
CREATE TABLE translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER REFERENCES tenants(id), -- NULL for global translations
    
    -- Translation details
    language_code VARCHAR(5) NOT NULL, -- en-US, es-ES, etc.
    translation_key VARCHAR(200) NOT NULL,
    translation_value TEXT NOT NULL,
    
    -- Context
    context VARCHAR(100), -- ui, email, report, etc.
    page_or_component VARCHAR(100),
    
    -- Translation metadata
    translator VARCHAR(200),
    translation_quality VARCHAR(20) DEFAULT 'professional', -- machine, human, professional
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    requires_review BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    UNIQUE(tenant_id, language_code, translation_key)
);
```

### advisor_companies table
External advisor and professional service provider management.

```sql
CREATE TABLE advisor_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- Company details
    company_name VARCHAR(200) NOT NULL,
    company_type VARCHAR(100) NOT NULL, -- law_firm, accounting_firm, financial_advisory
    
    -- Contact information
    contact_info_id UUID NOT NULL REFERENCES contact_info(id),
    
    -- Professional details
    license_numbers VARCHAR(200)[],
    certifications VARCHAR(200)[],
    specializations VARCHAR(200)[],
    
    -- Business information
    years_in_business INTEGER,
    employee_count INTEGER,
    aum DECIMAL(15,2), -- Assets Under Management (for financial advisors)
    
    -- Service areas
    service_areas VARCHAR(100)[],
    geographic_coverage VARCHAR(200)[],
    
    -- Rating and reviews
    rating DECIMAL(2,1), -- 0.0 to 5.0
    review_count INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_preferred BOOLEAN DEFAULT FALSE,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);
```

## Security Constraints & Validation

### Authentication Security
```sql
-- Enforce strong session tokens
ALTER TABLE user_sessions ADD CONSTRAINT chk_valid_session_duration 
    CHECK (expires_at > created_at);

-- Limit verification attempts
ALTER TABLE email_verifications ADD CONSTRAINT chk_attempt_limits
    CHECK (attempt_count <= max_attempts);

ALTER TABLE phone_verifications ADD CONSTRAINT chk_phone_attempt_limits
    CHECK (attempt_count <= max_attempts AND daily_send_count <= max_daily_sends);
```

### RBAC Security
```sql
-- Ensure role hierarchy consistency
ALTER TABLE user_roles ADD CONSTRAINT chk_role_hierarchy
    CHECK (parent_role_id != id); -- Prevent self-referencing

-- Validate permission assignments
CREATE OR REPLACE FUNCTION validate_role_permission_assignment()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure dangerous permissions require 2FA
    IF EXISTS (
        SELECT 1 FROM user_permissions up 
        WHERE up.id = NEW.permission_id 
        AND up.is_dangerous = TRUE
        AND NOT EXISTS (
            SELECT 1 FROM user_permissions up2 
            WHERE up2.id = NEW.permission_id 
            AND up2.requires_2fa = TRUE
        )
    ) THEN
        RAISE EXCEPTION 'Dangerous permissions must require 2FA';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_role_permission
    BEFORE INSERT OR UPDATE ON role_permissions
    FOR EACH ROW EXECUTE FUNCTION validate_role_permission_assignment();
```

### Audit Security
```sql
-- Audit log integrity constraints
ALTER TABLE audit_log ADD CONSTRAINT chk_audit_integrity
    CHECK (occurred_at <= NOW() AND occurred_at >= '2020-01-01'::timestamp);

-- Ensure critical actions are logged
CREATE OR REPLACE FUNCTION ensure_critical_audit_logging()
RETURNS TRIGGER AS $$
BEGIN
    -- Log all permission changes
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        old_values, new_values
    ) VALUES (
        fn_get_current_tenant_id(),
        fn_get_current_user_id(),
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP != 'DELETE' THEN to_jsonb(NEW) ELSE NULL END
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

## Security Best Practices

### Password Security
- **Strong Hashing**: Use bcrypt with appropriate cost factor (12+)
- **Salt**: Unique salt per password
- **Rotation**: Encourage periodic password changes
- **Complexity**: Enforce strong password requirements

### Session Management
- **Secure Tokens**: Cryptographically secure random tokens
- **Token Rotation**: Refresh tokens on activity
- **Timeout**: Configurable session timeouts
- **Single Session**: Optional single session per user

### Audit Logging
- **Complete Coverage**: Log all security-relevant actions
- **Immutable**: Audit logs should be append-only
- **Integrity**: Use checksums to detect tampering
- **Retention**: Follow compliance requirements for retention

### Data Protection
- **Encryption at Rest**: Encrypt sensitive data in database
- **Encryption in Transit**: Use TLS for all connections
- **PII Detection**: Automatic PII detection and masking
- **Access Control**: Role-based access to sensitive data

### Compliance
- **SOC 2**: Comprehensive audit logging and access controls
- **GDPR**: PII processing and data retention controls
- **HIPAA**: Healthcare data protection (if applicable)
- **Regular Audits**: Automated compliance reporting

---

*This comprehensive security architecture provides the Forward Inheritance Platform with enterprise-grade security, audit, and compliance capabilities, ensuring the protection of sensitive family financial data while meeting regulatory requirements and industry best practices.*