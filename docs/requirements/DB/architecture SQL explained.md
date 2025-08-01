# Forward Inheritance Platform - Database Architecture Explained

## Executive Summary

The Forward Inheritance Platform uses a sophisticated multi-tenant database architecture designed to support millions of families in managing wealth transfer, estate planning, and collaborative financial planning. The system implements a security-first approach with complete tenant isolation, normalized contact management, and comprehensive asset tracking across 13 categories.

---

## Core Architecture Principles

### 1. Security-First Design
- **Row-Level Security (RLS)**: Every table implements PostgreSQL RLS policies for tenant isolation
- **Stored Procedure Only Access**: All database operations must go through stored procedures (SECURITY DEFINER)
- **Encryption at Rest**: Sensitive data (SSNs, account numbers, tax IDs) encrypted using pgcrypto
- **PII Protection**: Dual storage with original encrypted and masked versions for privacy compliance
- **Comprehensive Audit Trails**: Every operation logged with user context, IP addresses, and risk scoring

### 2. Multi-Tenant SaaS Architecture
- **Tenant Isolation**: tenant_id field in every table with RLS policies preventing cross-tenant data access
- **FFC-Based Multi-Tenancy**: Forward Family Circles (FFCs) serve as primary tenant containers
- **Scalable Design**: Built to support millions of families with consistent performance
- **Zero Data Leakage**: Complete segregation between different family circles

### 3. Normalized Contact Management
- **Single Source of Truth**: Email, phone, and address data stored once and referenced via foreign keys
- **Polymorphic Relationships**: Contact data can be linked to any entity type through usage tables
- **Flexible Associations**: Same contact info can be shared across multiple entities
- **Communication Preferences**: Usage context and preferences tracked per relationship

### 4. Event-Driven Architecture
- **Webhook Integration**: Real-time updates for external systems
- **Async Processing**: Background job queues for PII detection, document processing
- **Integration Ready**: API framework for financial institutions, real estate providers, tax services

---

## Database Structure by Domain

### IDENTITY & ACCESS MANAGEMENT DOMAIN (10 tables)

#### Core Authentication Tables

**users**
- Purpose: Authentication and account security
- Key Fields: primary_email_id, primary_phone_id, password_hash, verification status
- Relationships: Links to email_address and phone_number tables for contact normalization
- Security: Account lockout, failed login tracking, password history

**user_sessions**
- Purpose: Session management with device tracking
- Key Fields: session_token, refresh_token, device_fingerprint, geographic_info
- Relationships: user_id � users(id)
- Features: Maximum 5 concurrent sessions, 24-hour absolute timeout, device anomaly detection

**user_mfa_settings**
- Purpose: Multi-factor authentication configuration
- Key Fields: totp_secret, sms_phone_id, backup_codes
- Relationships: user_id � users(id), sms_phone_id � phone_number(id)
- Security: TOTP support, SMS backup, recovery codes, admin override

#### Role-Based Access Control (RBAC)

**user_roles**
- Purpose: Defines available roles in the system
- Key Fields: name, display_name, parent_role_id, hierarchy_level
- System Roles: platform_admin, ffc_owner, ffc_admin, ffc_member, ffc_viewer
- Features: Hierarchical roles, system vs custom roles

**user_role_assignments** (CRITICAL TABLE)
- Purpose: Assigns roles to users within specific FFCs
- Key Fields: user_id, role_id, ffc_id (THE KEY TO MULTI-TENANCY)
- Relationships: Multi-way join between users, roles, and FFCs
- Features: FFC-scoped permissions, time-based assignments, expiration support

**user_permissions**
- Purpose: Granular permission definitions
- Key Fields: name (e.g., 'asset.create'), category, is_dangerous
- Categories: asset, user, admin, integration

**role_permissions**
- Purpose: Links roles to their permitted actions
- Relationships: role_id � user_roles(id), permission_id � user_permissions(id)

#### Forward Family Circles (FFCs)

**ffcs (forward_family_circles)**
- Purpose: Primary tenant containers for family groups
- Key Fields: name, description, created_by, ffc_settings, family_picture_url, family_picture_s3_key
- Features: Unique naming, customizable settings, ownership tracking, family picture uploads with S3 storage

**ffc_personas**
- Purpose: Links personas to FFCs with roles
- Key Fields: ffc_id, persona_id, role (owner/beneficiary/non_beneficiary)
- Relationships: Many-to-many between FFCs and personas
- Business Rules: Defines who can access which family circles

**personas**
- Purpose: Represents individuals within family circles (living or deceased)
- Key Fields: user_id (nullable), personal_info, date_of_death, is_living, profile_picture_url, profile_picture_s3_key
- Relationships: Optionally linked to users for authentication
- Features: Profile picture uploads with S3 storage, supports both living and deceased family members
- Use Cases: Deceased family members, minors, trust beneficiaries

---

### ASSET MANAGEMENT DOMAIN (35+ tables)

#### Universal Asset Framework

**asset_categories**
- Purpose: Defines the 13 primary asset categories
- Categories: Personal Directives, Trust, Will, Personal Property, Operational Property, Inventory, Real Estate, Life Insurance, Financial Accounts, Recurring Income, Digital Assets, Ownership Interests, Loans
- Key Fields: name, code, sort_order

**assets (Central Hub Table)**
- Purpose: Core asset registry linking all category-specific tables
- Key Fields: tenant_id, category_id, name, estimated_value
- Relationships: Referenced by all category-specific asset tables
- Features: Multi-tenancy, tagging, metadata storage (JSONB)

**asset_persona_ownership**
- Purpose: Defines who owns what percentage of each asset
- Key Fields: asset_id, persona_id, ownership_percentage, ownership_type
- Business Rules: Ownership percentages cannot exceed 100% per asset
- Features: Direct ownership model (assets owned by personas, not FFCs)

**asset_permissions**
- Purpose: Granular asset-level permissions
- Key Fields: asset_id, persona_id, permission_level (none/read/edit/admin)
- Security: Independent of FFC permissions, asset owner controls access

#### Asset Category Tables (13 Categories)

**1. Personal Directives (personal_directives)**
- Purpose: Power of Attorney, Healthcare Directives, HIPAA authorizations
- Key Fields: directive_type, agent_persona_id, scope_details, execution_terms
- Relationships: Links to personas for agents and principals

**2. Trust Assets (trusts, trust_beneficiaries, trust_trustees)**
- Purpose: Trust arrangements and beneficiary management
- Key Fields: trust_type, settlor_persona_id, tax_id_encrypted
- Complex Relationships: Multiple trustees, beneficiaries with distribution percentages

**3. Estate Planning (wills, will_bequests, will_codicils)**
- Purpose: Will documents, bequests, amendments
- Key Fields: testator_persona_id, execution_date, jurisdiction
- Features: Executor management, witness tracking, bequest distribution

**4. Real Estate (real_estate_properties + 8 supporting tables)**
- Purpose: Comprehensive property management
- Key Fields: property_address_id, property_type_id, current_market_value
- Supporting Tables: property_types, property_features, property_valuations, property_ownership, property_taxes, rental_income_records
- Integration: Real estate data provider APIs for automated valuations

**5. Financial Accounts (financial_accounts + supporting tables)**
- Purpose: Bank accounts, investments, retirement accounts
- Key Fields: institution_id, account_type, account_number_encrypted
- Integration: Quillt API for real-time balance synchronization
- Features: Multi-provider support, webhook processing, balance history

**6. Personal Property (personal_property + category tables)**
- Purpose: Jewelry, art, collectibles, furniture, pets
- Key Fields: property_type, valuation_method, appraisal_value
- Features: Multi-photo support, appraisal tracking, insurance integration

**7. Operational Property (operational_property + type tables)**
- Purpose: Vehicles, boats, equipment, appliances
- Key Fields: property_type, make_model, year, vin_serial
- Features: Maintenance tracking, depreciation calculations

**8. Life Insurance (life_insurance_policies + beneficiaries)**
- Purpose: Insurance policy management
- Key Fields: policy_number, insurance_company_id, death_benefit
- Features: Beneficiary management, premium tracking, policy loans

**9. Recurring Income (recurring_income_sources + payments)**
- Purpose: Royalties, rental income, dividends
- Key Fields: income_type, payment_frequency, tax_treatment
- Features: Payment projection, tax reporting integration

**10. Digital Assets (digital_assets + wallets)**
- Purpose: Cryptocurrency, NFTs, domain names, IP
- Key Fields: asset_type, platform_registry, current_value_usd
- Security: Encrypted wallet credentials, access logging

**11. Ownership Interests (ownership_interests + entities)**
- Purpose: Business interests, partnerships, franchises
- Key Fields: entity_name, ownership_percentage, valuation_method
- Features: Complex ownership structures, valuation tracking

**12. Inventory (inventory_items + categories + locations)**
- Purpose: Business inventory management
- Key Fields: item_name, quantity, unit_value, location_id
- Features: Movement tracking, valuation methods, audit trails

**13. Loans (loans, loan_payments, amortization_schedules)**
- Purpose: HEI loans, interfamily loans
- Key Fields: loan_type, principal_amount, interest_rate, balance_remaining
- Integration: HEI provider APIs for real-time updates
- Features: Payment tracking, loan forgiveness, amortization calculations

---

### CONTACT & COMMUNICATION DOMAIN (8 tables)

#### Normalized Contact Architecture

**address**
- Purpose: Global address storage with geographic data
- Key Fields: address_line1, city, state_or_province, postal_code, coordinates
- Features: International support, geocoding, address validation

**address_usage**
- Purpose: Links addresses to entities with usage context
- Key Fields: address_id, linked_entity_type, linked_entity_id, usage_type
- Usage Types: primary, billing, shipping, property, mailing, legal

**phone_number**
- Purpose: Global phone storage with E.164 format support
- Key Fields: country_code, national_number, phone_type, validation_status
- Features: International formatting, carrier detection, SMS capability

**phone_usage**
- Purpose: Links phone numbers to entities with usage context
- Key Fields: phone_id, linked_entity_type, usage_type, communication_preferences
- Usage Types: primary, mobile, work, emergency, mfa

**email_address**
- Purpose: Global email storage with validation
- Key Fields: email_address, domain, is_verified, email_type
- Features: Domain validation, deliverability tracking, verification status

**email_usage**
- Purpose: Links email addresses to entities with usage context
- Key Fields: email_id, linked_entity_type, usage_type, communication_preferences
- Usage Types: primary, work, login, notification

**contact_info**
- Purpose: Consolidated contact information hub
- Key Fields: address_id, preferred_contact_method, timezone, website
- Relationships: Central hub linking to all contact methods

**social_media_accounts** (+ social_media_usage)
- Purpose: Social media platform management
- Key Fields: platform, handle, url, verification_status
- Platforms: LinkedIn, Twitter, Facebook, Instagram, TikTok

---

### DOCUMENT MANAGEMENT DOMAIN (6 tables)

**asset_documents**
- Purpose: File storage and PII processing tracking
- Key Fields: asset_id, filename, s3_key_original, s3_key_masked, contains_pii
- Features: Encryption required, PII detection pipeline, version control

**document_versions**
- Purpose: Document versioning and change tracking
- Relationships: document_id � asset_documents(id)

**document_shares**
- Purpose: Secure document sharing with expiration
- Key Fields: document_id, shared_with_persona_id, expires_at, access_permissions

**document_categories**
- Purpose: Document classification system
- Categories: deed, statement, photo, appraisal, insurance, legal

**document_templates**
- Purpose: Standardized document templates
- Use Cases: Legal forms, reports, letters

**document_retention_policies**
- Purpose: Compliance-driven document lifecycle
- Key Fields: retention_period, legal_hold_flag, auto_disposal_date

---

### SECURITY & COMPLIANCE DOMAIN (3 tables)

**pii_processing_jobs**
- Purpose: Automated PII detection and masking pipeline
- Key Fields: asset_id, job_type, status, pii_fields_detected
- Integration: AWS Comprehend for entity detection
- Workflow: scan � detect � mask � store (dual storage)

**audit_log**
- Purpose: Comprehensive activity logging
- Key Fields: user_id, action, resource_type, old_values, new_values, risk_score
- Features: IP tracking, session correlation, risk assessment, security alerts

**webhook_logs**
- Purpose: External integration tracking
- Key Fields: endpoint_url, event_type, payload, response_status
- Use Cases: Quillt updates, real estate data, notification delivery

---

### INVITATION & VERIFICATION DOMAIN (3 tables)

**ffc_invitations**
- Purpose: Secure family member invitation workflow
- Key Fields: ffc_id, invitee_email_id, invitee_phone_id, invitation_token
- Security: Dual-channel verification (email + SMS), owner approval required

**verification_attempts**
- Purpose: Phone verification tracking
- Key Fields: invitation_id, phone_id, verification_code, success
- Security: Rate limiting, IP tracking, attempt logging

**login_attempts**
- Purpose: Authentication attempt logging
- Key Fields: user_id, login_type, status, failure_reason, risk_score
- Features: Geographic anomaly detection, device fingerprinting

---

### PROFESSIONAL SERVICES DOMAIN (4 tables)

**advisor_companies**
- Purpose: Professional service company registry
- Key Fields: company_name, company_type, contact_info_id, credentials
- Types: law_firm, accounting_firm, financial_advisory, insurance_agency

**professional_services**
- Purpose: Individual service providers within companies
- Key Fields: first_name, last_name, professional_title, specializations
- Features: Billing rates, availability, performance tracking

**advisor_assignments**
- Purpose: Links families to their professional advisors
- Key Fields: ffc_id, advisor_id, service_type, relationship_status

**service_engagements**
- Purpose: Tracks specific service engagements
- Key Fields: assignment_id, engagement_type, start_date, billing_arrangement

---

### INTEGRATION & EXTERNAL APIS DOMAIN (8 tables)

**third_party_integrations**
- Purpose: External service configuration
- Key Fields: integration_name, config, encrypted_credentials, status

**quillt_integrations**
- Purpose: Financial account synchronization via Quillt API
- Key Fields: persona_id, quillt_profile_id, account_count, last_synced_at
- Features: Real-time balance updates, connection health monitoring

**hei_integrations**
- Purpose: Home Equity Investment loan tracking
- Key Fields: loan_id, hei_provider, api_endpoint, sync_frequency

**real_estate_integrations**
- Purpose: Property data synchronization
- Providers: Zillow, CoreLogic, RentSpree (to be selected)
- Features: Automated valuations, comparable sales, market trends

**webhook_endpoints**
- Purpose: Incoming webhook configuration
- Key Fields: url, event_types, authentication_method, is_active

**external_data_cache**
- Purpose: API response caching for performance
- Key Fields: cache_key, data_source, cached_data, expires_at

**sync_jobs**
- Purpose: Scheduled data synchronization tracking
- Key Fields: job_type, data_source, last_run_at, next_run_at, status

**integration_errors**
- Purpose: API error tracking and retry logic
- Key Fields: integration_id, error_message, retry_count, resolved_at

---

## Key Relationships and Patterns

### Primary Relationship Flows

1. **User Authentication Flow**
   ```
   users � user_sessions (active sessions)
   users � user_mfa_settings (security)
   users � personas (business identity)
   ```

2. **Multi-Tenant Access Flow**
   ```
   users � user_role_assignments � user_roles
   user_role_assignments � ffcs (FFC-scoped permissions)
   ffcs � ffc_personas � personas
   ```

3. **Asset Ownership Flow**
   ```
   personas � asset_persona_ownership � assets
   assets � [category_specific_tables]
   assets � asset_permissions (access control)
   assets � asset_documents (supporting files)
   ```

4. **Contact Normalization Pattern**
   ```
   [entity] � [contact_usage_table] � [contact_data_table]
   Example: users � email_usage � email_address
   ```

5. **Integration Data Flow**
   ```
   external_apis � webhook_endpoints � processing_jobs
   processed_data � asset_updates � audit_log
   ```

### Foreign Key Constraints Summary

- **Users Domain**: 15 foreign key relationships
- **Assets Domain**: 45+ foreign key relationships
- **Contact Domain**: 12 foreign key relationships
- **Integration Domain**: 20+ foreign key relationships

All foreign keys use CASCADE DELETE where appropriate and RESTRICT where data integrity is critical.

---

## Performance & Scalability Features

### Indexing Strategy

**Multi-Tenant Indexes**: Every table has tenant_id indexes with partial indexes for active records
**Composite Indexes**: Strategic combinations for common query patterns
**Covering Indexes**: Include frequently accessed columns to avoid table lookups
**Partial Indexes**: Only index active/relevant records

### Partitioning Strategy

**Time-Series Partitioning**: audit_log, login_attempts, webhook_logs partitioned by month
**Hash Partitioning**: Large tables partitioned by tenant_id for even distribution

### Caching Strategy

**Redis Integration**: Session data, permission checks, frequently accessed reference data
**Materialized Views**: Complex reporting queries, wealth summaries, asset rollups
**Query Result Caching**: API responses cached with appropriate TTL

### Connection Management

**Connection Pooling**: PgBouncer for efficient connection reuse
**Read Replicas**: Query distribution for reporting and analytics
**Connection Limits**: Tenant-based connection limiting for fair resource usage

---

## Security Architecture

### Row-Level Security (RLS)

Every major table implements RLS policies:
```sql
CREATE POLICY [table]_tenant_isolation ON [table]
USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

### Encryption Standards

**At Rest**: pgcrypto for sensitive fields (SSNs, account numbers, tax IDs)
**In Transit**: TLS 1.3 for all connections
**Key Management**: AWS KMS integration for encryption key rotation

### Access Control

**Stored Procedure Only**: All database access through SECURITY DEFINER procedures
**Permission Verification**: Every operation verified through verify_user_permissions()
**Audit Logging**: All operations logged with user context and risk scoring

### PII Protection

**Dual Storage**: Original encrypted + masked versions
**Automated Detection**: AWS Comprehend integration for PII entity recognition
**Access Controls**: Role-based access to original vs masked data
**Retention Policies**: Automated disposal per compliance requirements

---

## Integration Architecture

### Financial Data Integration

**Quillt API**: Real-time bank account synchronization
- Account discovery and balance updates
- Transaction categorization
- Connection health monitoring
- Multi-institution support

**HEI Providers**: Home Equity Investment loan tracking
- Real-time balance updates
- Payment processing
- Document synchronization

### Real Estate Integration

**Provider Selection**: Evaluation of Zillow, CoreLogic, RentSpree
- Automated property valuations
- Comparable sales analysis
- Market trend monitoring
- Property detail enrichment

### Document Management

**S3 Integration**: Encrypted document storage and image management
- Automatic PII processing pipeline
- Version control and access logging
- Secure sharing with expiration
- **Family & Profile Pictures**: Dedicated storage for FFC family pictures and persona profile pictures
- **Image Processing**: Automatic resizing, format optimization, and metadata extraction
- **Secure URLs**: Time-limited signed URLs for secure image access

### Notification Systems

**Multi-Channel**: Email, SMS, push notifications, webhooks
- Delivery tracking and bounce handling
- Template management
- Preference-based routing

---

## Compliance & Regulatory Features

### Data Retention

**Configurable Policies**: Per document type and legal requirements
**Legal Hold**: Override disposal for litigation/audit purposes
**Automated Disposal**: Scheduled cleanup with audit trails

### Privacy Compliance

**GDPR Ready**: Right to be forgotten, data portability, consent management
**CCPA Compliant**: California privacy rights implementation
**PII Minimization**: Automated detection and protection workflows

### Financial Regulations

**TILA Compliance**: Truth in Lending Act for loan disclosures
**Tax Reporting**: Form generation (1098, 1099-INT, 709)
**AML/KYC**: Know Your Customer verification workflows

### Audit Requirements

**SOC 2 Ready**: Control implementation and monitoring
**Comprehensive Logging**: All operations tracked with user context
**Data Lineage**: Complete traceability of data changes and access

---

## Conclusion

The Forward Inheritance Platform database architecture represents a sophisticated, enterprise-grade system designed to handle the complex requirements of family wealth management and estate planning. Key architectural strengths include:

1. **Security First**: Multi-layered security with RLS, encryption, and comprehensive auditing
2. **Scalable Multi-Tenancy**: Clean tenant isolation supporting millions of families
3. **Flexible Asset Framework**: Accommodates all types of wealth with room for expansion
4. **Normalized Contact Management**: Eliminates data duplication while maintaining flexibility
5. **Integration Ready**: Built for real-time data synchronization with external providers
6. **Compliance Focused**: Designed to meet financial and privacy regulatory requirements

The architecture balances complexity with maintainability, providing a robust foundation for sophisticated family wealth management while ensuring data security, compliance, and optimal performance at scale.

---

*This document represents the complete database architecture as of the current design phase. Implementation details may evolve during development based on specific technical requirements and performance testing.*