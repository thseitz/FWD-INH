# Forward Inheritance Platform - Complete Stored Procedures & Functions Specification

**Document Type:** Database Functions & Procedures Reference  
**Version:** 1.0  
**Date:** December 2024  
**Status:** Comprehensive Specification

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Authentication & User Management](#authentication--user-management)
3. [FFC & Persona Management](#ffc--persona-management)
4. [Asset Management](#asset-management)
5. [Financial Calculations](#financial-calculations)
6. [Integration & Synchronization](#integration--synchronization)
7. [Security & Permissions](#security--permissions)
8. [Audit & Logging](#audit--logging)
9. [PII Processing](#pii-processing)
10. [Utility Functions](#utility-functions)

---

## Architecture Overview

The Forward Inheritance Platform uses a **"Stored Procedure Only"** architecture where all database operations must go through stored procedures with `SECURITY DEFINER` privileges. This ensures:

- **Security**: Complete control over data access patterns
- **Performance**: Optimized database operations
- **Auditability**: Comprehensive logging of all operations
- **Multi-tenancy**: Consistent tenant isolation across all operations

### Common Patterns

**Parameter Naming Convention:**
- Input parameters: `p_` prefix (e.g., `p_user_id`, `p_tenant_id`)
- Local variables: `v_` prefix (e.g., `v_result`, `v_count`)

**Return Types:**
- `VOID` - For operations that modify data
- `UUID` - For functions that create new records
- `TABLE(...)` - For data retrieval functions
- `BOOLEAN` - For validation functions
- `JSONB` - For complex data structures

**Security:**
- All functions use `SECURITY DEFINER`
- Tenant isolation through `p_tenant_id` parameter
- Permission verification within function logic
- Comprehensive audit logging

---

## Authentication & User Management

### 1. **authenticate_user**
```sql
CREATE OR REPLACE FUNCTION authenticate_user(
    p_email VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_fingerprint VARCHAR(255)
) RETURNS TABLE (
    user_id UUID,
    session_token VARCHAR(255),
    requires_mfa BOOLEAN,
    account_locked BOOLEAN,
    failed_attempts INTEGER
) SECURITY DEFINER
```
**Purpose:** Authenticates user login with security tracking  
**Returns:** User ID, session token, and security status

### 2. **create_user_session**
```sql
CREATE OR REPLACE FUNCTION create_user_session(
    p_user_id UUID,
    p_session_token VARCHAR(255),
    p_refresh_token VARCHAR(255),
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_fingerprint VARCHAR(255),
    p_geographic_info JSONB DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Creates new user session with device tracking  
**Returns:** Session ID

### 3. **verify_user_session**
```sql
CREATE OR REPLACE FUNCTION verify_user_session(
    p_session_token VARCHAR(255),
    p_ip_address INET
) RETURNS TABLE (
    user_id UUID,
    tenant_id UUID,
    is_valid BOOLEAN,
    expires_at TIMESTAMP WITH TIME ZONE,
    requires_refresh BOOLEAN
) SECURITY DEFINER
```
**Purpose:** Validates active user session  
**Returns:** Session validation details

### 4. **setup_user_mfa**
```sql
CREATE OR REPLACE FUNCTION setup_user_mfa(
    p_user_id UUID,
    p_tenant_id UUID,
    p_totp_secret VARCHAR(255),
    p_sms_phone_id UUID,
    p_backup_codes TEXT[]
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Configures multi-factor authentication  
**Returns:** Success status

### 5. **verify_mfa_code**
```sql
CREATE OR REPLACE FUNCTION verify_mfa_code(
    p_user_id UUID,
    p_code VARCHAR(10),
    p_ip_address INET
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Verifies MFA code during authentication  
**Returns:** Verification success status

---

## FFC & Persona Management

### 6. **create_ffc**
```sql
CREATE OR REPLACE FUNCTION create_ffc(
    p_tenant_id UUID,
    p_name VARCHAR(255),
    p_description TEXT,
    p_head_persona_id UUID,
    p_created_by UUID,
    p_family_picture_s3_key VARCHAR(255) DEFAULT NULL,
    p_family_picture_url VARCHAR(500) DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Creates new Forward Family Circle  
**Returns:** FFC ID

### 7. **add_persona_to_ffc**
```sql
CREATE OR REPLACE FUNCTION add_persona_to_ffc(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_role ffc_role_enum,
    p_permissions JSONB DEFAULT '{}',
    p_added_by UUID
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Links persona to FFC with specified role  
**Returns:** FFC persona relationship ID

### 8. **create_persona**
```sql
CREATE OR REPLACE FUNCTION create_persona(
    p_tenant_id UUID,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_persona_type persona_type_enum,
    p_contact_info_id UUID DEFAULT NULL,
    p_profile_picture_s3_key VARCHAR(255) DEFAULT NULL,
    p_profile_picture_url VARCHAR(500) DEFAULT NULL,
    p_created_by UUID
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Creates new persona record  
**Returns:** Persona ID

### 9. **invite_ffc_member**
```sql
CREATE OR REPLACE FUNCTION invite_ffc_member(
    p_ffc_id UUID,
    p_invitee_email_id UUID,
    p_invitee_phone_id UUID,
    p_invited_by UUID,
    p_role ffc_role_enum,
    p_invitation_message TEXT DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Sends invitation to join FFC  
**Returns:** Invitation ID

### 10. **verify_ffc_invitation**
```sql
CREATE OR REPLACE FUNCTION verify_ffc_invitation(
    p_invitation_token VARCHAR(255),
    p_phone_verification_code VARCHAR(10),
    p_email_verification_code VARCHAR(10)
) RETURNS TABLE (
    invitation_id UUID,
    ffc_id UUID,
    is_valid BOOLEAN,
    expires_at TIMESTAMP WITH TIME ZONE
) SECURITY DEFINER
```
**Purpose:** Verifies dual-channel FFC invitation  
**Returns:** Invitation validation details

---

## Asset Management

### 11. **create_asset**
```sql
CREATE OR REPLACE FUNCTION create_asset(
    p_tenant_id UUID,
    p_category_id UUID,
    p_name VARCHAR(255),
    p_description TEXT,
    p_estimated_value DECIMAL(19,4),
    p_metadata JSONB DEFAULT '{}',
    p_created_by UUID
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Creates new asset record  
**Returns:** Asset ID

### 12. **assign_asset_ownership**
```sql
CREATE OR REPLACE FUNCTION assign_asset_ownership(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_percentage DECIMAL(5,2),
    p_ownership_type ownership_type_enum,
    p_assigned_by UUID
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Assigns ownership percentage to persona  
**Returns:** Ownership assignment ID

### 13. **set_asset_permissions**
```sql
CREATE OR REPLACE FUNCTION set_asset_permissions(
    p_asset_id UUID,
    p_persona_id UUID,
    p_permission_level permission_level_enum,
    p_granted_by UUID
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Grants asset-level permissions  
**Returns:** Permission ID

### 14. **get_user_assets**
```sql
CREATE OR REPLACE FUNCTION get_user_assets(
    p_user_id UUID,
    p_tenant_id UUID,
    p_category_filter UUID DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    asset_id UUID,
    category_name VARCHAR,
    asset_name VARCHAR,
    estimated_value DECIMAL,
    ownership_percentage DECIMAL,
    permission_level VARCHAR,
    last_updated TIMESTAMP WITH TIME ZONE
) SECURITY DEFINER
```
**Purpose:** Retrieves assets accessible to user  
**Returns:** Asset list with permissions

### 15. **update_asset_valuation**
```sql
CREATE OR REPLACE FUNCTION update_asset_valuation(
    p_asset_id UUID,
    p_new_value DECIMAL(19,4),
    p_valuation_method VARCHAR(100),
    p_valuation_date DATE,
    p_updated_by UUID,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Updates asset valuation with audit trail  
**Returns:** Valuation record ID

---

## Financial Calculations

### 16. **calculate_loan_interest**
```sql
CREATE OR REPLACE FUNCTION calculate_loan_interest(
    p_loan_id UUID,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    accrued_interest DECIMAL(19,4),
    daily_interest DECIMAL(19,4),
    days_since_last_payment INTEGER
) SECURITY DEFINER
```
**Purpose:** Calculates accrued loan interest  
**Returns:** Interest calculations

### 17. **generate_amortization_schedule**
```sql
CREATE OR REPLACE FUNCTION generate_amortization_schedule(
    p_loan_id UUID
) RETURNS VOID SECURITY DEFINER
```
**Purpose:** Generates loan amortization schedule  
**Returns:** Nothing (populates schedule table)

### 18. **process_loan_payment**
```sql
CREATE OR REPLACE FUNCTION process_loan_payment(
    p_loan_id UUID,
    p_payment_amount DECIMAL(19,4),
    p_payment_date DATE,
    p_payment_method VARCHAR(50),
    p_reference_number VARCHAR(100) DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Processes loan payment with allocation  
**Returns:** Payment record ID

### 19. **calculate_portfolio_value**
```sql
CREATE OR REPLACE FUNCTION calculate_portfolio_value(
    p_tenant_id UUID,
    p_persona_id UUID DEFAULT NULL,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS TABLE (
    total_value DECIMAL(19,4),
    liquid_assets DECIMAL(19,4),
    real_estate_value DECIMAL(19,4),
    investment_value DECIMAL(19,4),
    personal_property DECIMAL(19,4),
    debt_obligations DECIMAL(19,4),
    net_worth DECIMAL(19,4)
) SECURITY DEFINER
```
**Purpose:** Calculates comprehensive portfolio valuation  
**Returns:** Portfolio value breakdown

### 20. **get_income_review_dashboard**
```sql
CREATE OR REPLACE FUNCTION get_income_review_dashboard(
    p_tenant_id UUID,
    p_user_id UUID
) RETURNS TABLE (
    income_id UUID,
    income_name VARCHAR,
    income_type VARCHAR,
    source_name VARCHAR,
    status VARCHAR,
    last_payment_date DATE,
    last_payment_amount DECIMAL,
    next_payment_date DATE,
    ytd_gross DECIMAL,
    ytd_net DECIMAL,
    projected_annual DECIMAL,
    needs_review BOOLEAN,
    review_reasons TEXT[],
    days_until_next_payment INTEGER,
    payment_trend VARCHAR
) SECURITY DEFINER
```
**Purpose:** Provides income dashboard with analytics  
**Returns:** Comprehensive income review data

---

## Integration & Synchronization

### 21. **sync_quillt_accounts**
```sql
CREATE OR REPLACE FUNCTION sync_quillt_accounts(
    p_persona_id UUID,
    p_quillt_profile_id VARCHAR(255),
    p_api_data JSONB
) RETURNS TABLE (
    accounts_added INTEGER,
    accounts_updated INTEGER,
    accounts_removed INTEGER,
    sync_status VARCHAR,
    error_count INTEGER
) SECURITY DEFINER
```
**Purpose:** Synchronizes financial accounts via Quillt API  
**Returns:** Synchronization results

### 22. **sync_hei_loan_data**
```sql
CREATE OR REPLACE FUNCTION sync_hei_loan_data(
    p_loan_id UUID,
    p_api_data JSONB
) RETURNS VOID SECURITY DEFINER
```
**Purpose:** Updates HEI loan data from external provider  
**Returns:** Nothing (updates loan record)

### 23. **process_webhook**
```sql
CREATE OR REPLACE FUNCTION process_webhook(
    p_endpoint_url VARCHAR(500),
    p_event_type VARCHAR(100),
    p_payload JSONB,
    p_signature VARCHAR(255)
) RETURNS TABLE (
    processed BOOLEAN,
    response_status INTEGER,
    error_message TEXT
) SECURITY DEFINER
```
**Purpose:** Processes incoming webhook events  
**Returns:** Processing results

### 24. **sync_real_estate_valuations**
```sql
CREATE OR REPLACE FUNCTION sync_real_estate_valuations(
    p_property_id UUID,
    p_provider VARCHAR(50),
    p_api_response JSONB
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Updates property valuations from external APIs  
**Returns:** Valuation record ID

### 25. **refresh_external_data_cache**
```sql
CREATE OR REPLACE FUNCTION refresh_external_data_cache(
    p_cache_key VARCHAR(255),
    p_data_source VARCHAR(100)
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Refreshes cached external API data  
**Returns:** Refresh success status

---

## Security & Permissions

### 26. **verify_user_permissions**
```sql
CREATE OR REPLACE FUNCTION verify_user_permissions(
    p_user_id UUID,
    p_tenant_id UUID,
    p_resource_type VARCHAR(100),
    p_resource_id UUID,
    p_required_permission VARCHAR(100)
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Verifies user has required permissions  
**Returns:** Permission granted status

### 27. **assign_user_role**
```sql
CREATE OR REPLACE FUNCTION assign_user_role(
    p_user_id UUID,
    p_role_id UUID,
    p_ffc_id UUID,
    p_assigned_by UUID,
    p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Assigns role to user within FFC scope  
**Returns:** Role assignment ID

### 28. **check_asset_access**
```sql
CREATE OR REPLACE FUNCTION check_asset_access(
    p_user_id UUID,
    p_asset_id UUID,
    p_access_type VARCHAR(50)
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Verifies user can access specific asset  
**Returns:** Access granted status

### 29. **log_security_event**
```sql
CREATE OR REPLACE FUNCTION log_security_event(
    p_user_id UUID,
    p_event_type VARCHAR(100),
    p_risk_score INTEGER,
    p_ip_address INET,
    p_details JSONB
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Logs security-related events  
**Returns:** Security log ID

---

## Audit & Logging

### 30. **log_user_action**
```sql
CREATE OR REPLACE FUNCTION log_user_action(
    p_user_id UUID,
    p_action VARCHAR(100),
    p_resource_type VARCHAR(100),
    p_resource_id UUID,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_ip_address INET,
    p_session_id VARCHAR(255)
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Comprehensive audit logging  
**Returns:** Audit log ID

### 31. **get_audit_trail**
```sql
CREATE OR REPLACE FUNCTION get_audit_trail(
    p_tenant_id UUID,
    p_resource_type VARCHAR(100),
    p_resource_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
) RETURNS TABLE (
    audit_id UUID,
    user_id UUID,
    action VARCHAR,
    changed_at TIMESTAMP WITH TIME ZONE,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_name VARCHAR
) SECURITY DEFINER
```
**Purpose:** Retrieves audit trail for resources  
**Returns:** Audit trail records

### 32. **generate_audit_report**
```sql
CREATE OR REPLACE FUNCTION generate_audit_report(
    p_tenant_id UUID,
    p_report_type VARCHAR(50),
    p_start_date DATE,
    p_end_date DATE,
    p_include_details BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    report_section VARCHAR,
    metric_name VARCHAR,
    metric_value BIGINT,
    details JSONB
) SECURITY DEFINER
```
**Purpose:** Generates comprehensive audit reports  
**Returns:** Audit report data

---

## PII Processing

### 33. **detect_pii_in_document**
```sql
CREATE OR REPLACE FUNCTION detect_pii_in_document(
    p_document_id UUID,
    p_s3_key VARCHAR(255),
    p_file_content TEXT
) RETURNS TABLE (
    pii_detected BOOLEAN,
    pii_types VARCHAR[],
    confidence_scores DECIMAL[],
    masked_content TEXT,
    processing_status VARCHAR
) SECURITY DEFINER
```
**Purpose:** Detects PII in uploaded documents  
**Returns:** PII detection results

### 34. **mask_sensitive_data**
```sql
CREATE OR REPLACE FUNCTION mask_sensitive_data(
    p_data_type VARCHAR(50),
    p_original_value TEXT,
    p_mask_type VARCHAR(50) DEFAULT 'partial'
) RETURNS TEXT SECURITY DEFINER
```
**Purpose:** Masks sensitive data for display  
**Returns:** Masked data string

### 35. **create_pii_processing_job**
```sql
CREATE OR REPLACE FUNCTION create_pii_processing_job(
    p_asset_id UUID,
    p_document_id UUID,
    p_job_type VARCHAR(50),
    p_priority INTEGER DEFAULT 5
) RETURNS UUID SECURITY DEFINER
```
**Purpose:** Creates PII processing job  
**Returns:** Job ID

### 36. **process_pii_job**
```sql
CREATE OR REPLACE FUNCTION process_pii_job(
    p_job_id UUID
) RETURNS TABLE (
    job_status VARCHAR,
    pii_found BOOLEAN,
    entities_detected INTEGER,
    processing_time INTERVAL,
    error_message TEXT
) SECURITY DEFINER
```
**Purpose:** Processes PII detection job  
**Returns:** Processing results

---

## Utility Functions

### 37. **generate_invitation_token**
```sql
CREATE OR REPLACE FUNCTION generate_invitation_token()
RETURNS VARCHAR(255) SECURITY DEFINER
```
**Purpose:** Generates secure invitation tokens  
**Returns:** Cryptographically secure token

### 38. **generate_verification_code**
```sql
CREATE OR REPLACE FUNCTION generate_verification_code(
    p_code_type VARCHAR(20) DEFAULT 'numeric',
    p_length INTEGER DEFAULT 6
) RETURNS VARCHAR(20) SECURITY DEFINER
```
**Purpose:** Generates verification codes  
**Returns:** Verification code

### 39. **validate_email_address**
```sql
CREATE OR REPLACE FUNCTION validate_email_address(
    p_email VARCHAR(255)
) RETURNS BOOLEAN SECURITY DEFINER
```
**Purpose:** Validates email address format  
**Returns:** Validation result

### 40. **validate_phone_number**
```sql
CREATE OR REPLACE FUNCTION validate_phone_number(
    p_phone VARCHAR(50),
    p_country_code VARCHAR(5)
) RETURNS TABLE (
    is_valid BOOLEAN,
    formatted_number VARCHAR(50),
    country_code VARCHAR(5),
    national_number VARCHAR(50)
) SECURITY DEFINER
```
**Purpose:** Validates and formats phone numbers  
**Returns:** Validation and formatting results

### 41. **encrypt_sensitive_field**
```sql
CREATE OR REPLACE FUNCTION encrypt_sensitive_field(
    p_plaintext TEXT,
    p_field_type VARCHAR(50)
) RETURNS TEXT SECURITY DEFINER
```
**Purpose:** Encrypts sensitive data using pgcrypto  
**Returns:** Encrypted data

### 42. **decrypt_sensitive_field**
```sql
CREATE OR REPLACE FUNCTION decrypt_sensitive_field(
    p_encrypted_text TEXT,
    p_field_type VARCHAR(50)
) RETURNS TEXT SECURITY DEFINER
```
**Purpose:** Decrypts sensitive data  
**Returns:** Decrypted plaintext

### 43. **refresh_digital_asset_summary**
```sql
CREATE OR REPLACE FUNCTION refresh_digital_asset_summary()
RETURNS VOID SECURITY DEFINER
```
**Purpose:** Refreshes digital asset materialized view  
**Returns:** Nothing (refreshes view)

### 44. **forgive_loan**
```sql
CREATE OR REPLACE FUNCTION forgive_loan(
    p_loan_id UUID,
    p_forgiveness_date DATE,
    p_forgiveness_amount DECIMAL(19,4) DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
) RETURNS VOID SECURITY DEFINER
```
**Purpose:** Processes loan forgiveness  
**Returns:** Nothing (updates loan status)

### 45. **calculate_tax_liability**
```sql
CREATE OR REPLACE FUNCTION calculate_tax_liability(
    p_tenant_id UUID,
    p_tax_year INTEGER,
    p_jurisdiction VARCHAR(100)
) RETURNS TABLE (
    estimated_federal_tax DECIMAL(19,4),
    estimated_state_tax DECIMAL(19,4),
    gift_tax_liability DECIMAL(19,4),
    estate_tax_liability DECIMAL(19,4),
    generation_skipping_tax DECIMAL(19,4)
) SECURITY DEFINER
```
**Purpose:** Calculates tax liability estimates  
**Returns:** Tax calculation breakdown

---

## Performance & Maintenance Functions

### 46. **analyze_table_statistics**
```sql
CREATE OR REPLACE FUNCTION analyze_table_statistics(
    p_table_name VARCHAR(100)
) RETURNS TABLE (
    table_size BIGINT,
    row_count BIGINT,
    index_usage_stats JSONB,
    performance_recommendations TEXT[]
) SECURITY DEFINER
```
**Purpose:** Analyzes table performance metrics  
**Returns:** Performance analysis

### 47. **cleanup_expired_sessions**
```sql
CREATE OR REPLACE FUNCTION cleanup_expired_sessions(
    p_retention_days INTEGER DEFAULT 30
) RETURNS INTEGER SECURITY DEFINER
```
**Purpose:** Removes expired user sessions  
**Returns:** Number of sessions cleaned

### 48. **archive_old_audit_logs**
```sql
CREATE OR REPLACE FUNCTION archive_old_audit_logs(
    p_archive_date DATE,
    p_batch_size INTEGER DEFAULT 1000
) RETURNS TABLE (
    logs_archived BIGINT,
    logs_deleted BIGINT,
    processing_time INTERVAL
) SECURITY DEFINER
```
**Purpose:** Archives old audit log entries  
**Returns:** Archival statistics

---

## Summary

This comprehensive specification includes **48 stored procedures and functions** covering all major functional areas of the Forward Inheritance Platform:

- **Authentication & Sessions**: 5 functions
- **FFC & Persona Management**: 5 functions  
- **Asset Management**: 5 functions
- **Financial Calculations**: 5 functions
- **Integration & Sync**: 5 functions
- **Security & Permissions**: 4 functions
- **Audit & Logging**: 3 functions
- **PII Processing**: 4 functions
- **Utilities**: 9 functions
- **Performance & Maintenance**: 3 functions

All functions follow the **"Security Definer"** pattern for controlled access, include comprehensive parameter validation, tenant isolation, and audit logging. The functions are designed to support a multi-tenant SaaS architecture with enterprise-grade security and compliance features.

---

*This document represents the complete stored procedure and function specifications for the Forward Inheritance Platform database architecture. All functions include proper error handling, transaction management, and security controls as required for financial services applications.*