# Forward Inheritance Platform - Database Architecture

## Table of Contents

1. [Database Overview](#database-overview)
2. [Database Extensions](#database-extensions)
3. [Enums](#enums)
   - [Status and State Enums](#status-and-state-enums)
   - [Document and Media Enums](#document-and-media-enums)
   - [Personal Demographics Enums](#personal-demographics-enums)
   - [Contact Information Enums](#contact-information-enums)
   - [Usage/Relationship Enums](#usagerelationship-enums)
   - [Family and Relationship Enums](#family-and-relationship-enums)
   - [Legal Document Enums](#legal-document-enums)
   - [Asset Category Enums](#asset-category-enums)
   - [Personal Property Enums](#personal-property-enums)
   - [Operational Property Enums](#operational-property-enums)
   - [Real Estate Enums](#real-estate-enums)
   - [Financial Enums](#financial-enums)
   - [Digital Assets Enums](#digital-assets-enums)
   - [Business Enums](#business-enums)
   - [Loan Enums](#loan-enums)
   - [HEI Enums](#hei-enums)
   - [Subscription and Payment Enums](#subscription-and-payment-enums)
   - [Security and Audit Enums](#security-and-audit-enums)
   - [Language and Localization Enums](#language-and-localization-enums)
   - [Integration Enums](#integration-enums)
4. [Tables](#tables)
   - [Core System Tables](#core-system-tables)
   - [User and Identity Management](#user-and-identity-management)
   - [Contact Information Tables](#contact-information-tables)
   - [Asset Management Tables](#asset-management-tables)
   - [Asset Type-Specific Tables](#asset-type-specific-tables)
   - [Subscription and Payment Management Tables](#subscription-and-payment-management-tables)
   - [Security and Session Management](#security-and-session-management)
   - [Audit and Compliance](#audit-and-compliance)
   - [Event Sourcing Tables](#event-sourcing-tables)
   - [Integration Tables](#integration-tables)
5. [Relationships (Foreign Keys)](#relationships-foreign-keys)
   - [Core Relationships](#core-relationships)
   - [Contact Relationships](#contact-relationships)
   - [Asset Relationships](#asset-relationships)
   - [Security Relationships](#security-relationships)
   - [Audit Relationships](#audit-relationships)
   - [Integration Relationships](#integration-relationships)
6. [Indexes](#indexes)
   - [Performance Indexes](#performance-indexes)
   - [Search Indexes](#search-indexes)
   - [Subscription and Payment Indexes](#subscription-and-payment-indexes)
   - [Unique Constraint Indexes](#unique-constraint-indexes)
7. [Views](#views)
   - [Payment Management Views](#payment-management-views)
8. [Database Operations Architecture](#database-operations-architecture)
   - [pgTyped Integration](#pgtyped-integration)
   - [Slonik Runtime Client](#slonik-runtime-client)
   - [SQL Query Organization](#sql-query-organization)
   - [Remaining Stored Procedures](#remaining-stored-procedures)
9. [Helper Functions](#helper-functions)
10. [Row-Level Security (RLS) Policies](#row-level-security-rls-policies)
11. [Data Population and Test Data](#data-population-and-test-data)

---

## Database Overview

The Forward Inheritance Platform uses a PostgreSQL database with a sophisticated multi-tenant architecture designed for secure estate planning, asset management, and subscription billing. The database now includes 70+ tables (up from 56) with the addition of comprehensive subscription and payment management capabilities. It implements Row-Level Security (RLS) policies for data isolation, comprehensive audit trails for compliance with SOC 2 requirements, and event sourcing for complete system state reconstruction.

**Key Features:**
- Multi-tenant isolation with tenant-scoped data access
- Row-Level Security (RLS) policies for fine-grained access control
- AWS Cognito integration for authentication
- Event sourcing architecture for complete audit trails and state reconstruction
- Comprehensive audit logging and compliance tracking
- PII detection and data masking capabilities
- Integration support for third-party services (Quiltt, Builder.io, Real Estate APIs)
- **Subscription and payment management with Stripe integration**
- **Single-entry general ledger for financial tracking**
- **Flexible seat-based subscription plans with dynamic UI configuration**
- **Asynchronous webhook processing for payment events**

## Database Extensions

The database uses the following PostgreSQL extensions:
- `uuid-ossp` - UUID generation functions
- `pgcrypto` - Cryptographic functions
- `pg_trgm` - Trigram matching for full-text search
- `btree_gist` - Additional indexing capabilities

## Enums

### Status and State Enums
- `status_enum`: 'active', 'inactive', 'pending', 'suspended', 'deleted'
- `user_status_enum`: 'pending_verification', 'active', 'inactive', 'suspended', 'locked'
- `processing_status_enum`: 'uploaded', 'processing', 'ready', 'failed'
- `retention_policy_enum`: 'permanent', '7_years', '5_years', '3_years', '1_year', '6_months'

### Document and Media Enums
- `document_type_enum`: 'will', 'trust', 'insurance_policy', 'deed', 'contract', 'statement', 'certificate', 'directive', 'other'
- `document_category_enum`: 'legal', 'financial', 'personal', 'medical', 'business', 'tax', 'insurance'

### Personal Demographics Enums
- `gender_enum`: 'male', 'female', 'non_binary', 'prefer_not_to_say', 'other'
- `marital_status_enum`: 'single', 'married', 'divorced', 'widowed', 'separated', 'domestic_partnership'

### Contact Information Enums
- `phone_type_enum`: 'mobile', 'landline', 'voip', 'toll_free', 'fax'
- `email_type_enum`: 'personal', 'business', 'temporary', 'alias', 'shared'
- `address_type_enum`: 'residential', 'business', 'mailing', 'billing', 'property', 'temporary'
- `social_media_platform_enum`: 'facebook', 'twitter', 'linkedin', 'instagram', 'youtube', 'tiktok', 'snapchat', 'other'

### Usage/Relationship Enums
- `entity_type_enum`: 'user', 'persona', 'asset'
- `email_usage_type_enum`: 'primary', 'work', 'personal', 'backup', 'billing', 'notifications'
- `phone_usage_type_enum`: 'primary', 'work', 'home', 'mobile', 'emergency', 'fax'
- `address_usage_type_enum`: 'primary', 'mailing', 'billing', 'property', 'work', 'emergency'
- `contact_time_enum`: 'morning', 'afternoon', 'evening', 'anytime', 'business_hours'

### Family and Relationship Enums
- `family_relationship_enum`: 'spouse', 'child', 'parent', 'sibling', 'grandparent', 'grandchild', 'aunt_uncle', 'cousin', 'in_law', 'step_family', 'other'
- `ffc_role_enum`: 'owner', 'beneficiary', 'non_beneficiary', 'advisor'
- `ownership_type_enum`: 'owner', 'beneficiary', 'trustee', 'executor'

### Legal Document Enums
- `directive_type_enum`: 'power_of_attorney', 'healthcare_directive', 'living_will', 'hipaa_authorization', 'guardianship_designation', 'family_directive'
- `directive_status_enum`: 'draft', 'executed', 'active', 'suspended', 'revoked', 'expired', 'superseded'
- `trust_type_enum`: 'revocable', 'irrevocable', 'living', 'testamentary', 'charitable', 'special_needs', 'generation_skipping', 'asset_protection'
- `trust_role_enum`: 'grantor', 'trustee', 'successor_trustee', 'beneficiary', 'trust_protector', 'trust_advisor'

### Asset Category Enums
- `asset_type_enum`: 'personal_directives', 'trust', 'will', 'personal_property', 'operational_property', 'inventory', 'real_estate', 'life_insurance', 'financial_accounts', 'recurring_income', 'digital_assets', 'ownership_interests', 'loans', 'hei'

### Personal Property Enums
- `personal_property_type_enum`: 'jewelry', 'precious_metals', 'collectibles', 'art', 'furniture', 'pets_animals', 'memorabilia', 'other'
- `pet_type_enum`: 'dog', 'cat', 'bird', 'reptile', 'fish', 'horse', 'livestock', 'exotic', 'other'
- `pet_care_status_enum`: 'self_care', 'needs_basic_care', 'needs_special_care', 'needs_medical_care'

### Operational Property Enums
- `operational_property_type_enum`: 'vehicle', 'boat_yacht', 'aircraft', 'equipment_machinery', 'appliances_gear', 'recreational_vehicle', 'other'
- `vehicle_type_enum`: 'car', 'truck', 'suv', 'motorcycle', 'rv', 'trailer', 'other'
- `vehicle_condition_enum`: 'excellent', 'good', 'fair', 'poor', 'non_operational'

### Real Estate Enums
- `property_type_enum`: 'single_family', 'multi_family', 'condo', 'townhouse', 'commercial', 'land', 'farm_ranch', 'vacation_property', 'other'
- `property_ownership_enum`: 'sole_ownership', 'joint_tenancy', 'tenancy_in_common', 'community_property', 'trust_owned', 'llc_owned'
- `property_use_enum`: 'primary_residence', 'rental', 'vacation', 'commercial', 'investment', 'vacant'

### Financial Enums
- `account_type_enum`: 'checking', 'savings', 'investment', 'retirement_401k', 'retirement_ira', 'retirement_roth', 'retirement_pension', 'college_529', 'college_coverdell', 'hsa', 'trust_account', 'business_account', 'cryptocurrency'
- `investment_risk_profile_enum`: 'conservative', 'moderate', 'aggressive', 'speculative'
- `income_type_enum`: 'royalty', 'pension', 'social_security', 'annuity', 'rental_income', 'dividend', 'trust_distribution', 'business_income', 'other'
- `payment_frequency_enum`: 'weekly', 'bi_weekly', 'monthly', 'quarterly', 'semi_annual', 'annual', 'irregular'

### Digital Assets Enums
- `digital_asset_type_enum`: 'domain_name', 'website', 'social_media_account', 'digital_content', 'cryptocurrency', 'nft', 'online_business', 'intellectual_property', 'software_license', 'cloud_storage', 'email_account', 'other'
- `ip_type_enum`: 'patent', 'trademark', 'copyright', 'trade_secret'

### Business Enums
- `business_entity_type_enum`: 'sole_proprietorship', 'partnership', 'llc', 'corporation', 's_corp', 'c_corp', 'non_profit', 'trust', 'other'
- `ownership_interest_type_enum`: 'stock', 'membership_interest', 'partnership_interest', 'beneficial_interest', 'option', 'warrant', 'convertible_note'

### Loan Enums
- `loan_type_enum`: 'mortgage', 'heloc', 'personal', 'business', 'auto', 'student', 'family_loan', 'hard_money', 'other'
- `loan_status_enum`: 'active', 'paid_off', 'defaulted', 'in_forbearance', 'refinanced'
- `interest_type_enum`: 'fixed', 'variable', 'hybrid'

### HEI Enums
- `hei_valuation_method_enum`: 'avm', 'bpo', 'appraisal', 'broker_opinion', 'market_analysis'
- `hei_funding_method_enum`: 'ach', 'wire', 'check'
- `hei_status_enum`: 'active', 'matured', 'sold', 'bought_out', 'defaulted'

### Subscription and Payment Enums
- `plan_type_enum`: 'free', 'paid', 'sponsored'
- `billing_frequency_enum`: 'monthly', 'annual', 'one_time', 'lifetime'
- `subscription_status_enum`: 'active', 'trialing', 'past_due', 'canceled', 'pending', 'paused'
- `payment_status_enum`: 'pending', 'succeeded', 'failed', 'refunded', 'partially_refunded'
- `payment_type_enum`: 'subscription', 'service', 'seat_upgrade', 'add_on'
- `transaction_type_enum`: 'charge', 'refund', 'credit', 'adjustment'
- `ledger_account_type_enum`: 'revenue', 'refund', 'credit', 'accounts_receivable'
- `seat_type_enum`: 'basic', 'pro', 'enterprise'
- `payer_type_enum`: 'owner', 'advisor', 'third_party', 'individual', 'none'
- `refund_reason_enum`: 'duplicate', 'fraudulent', 'requested_by_customer', 'other'
- `service_type_enum`: 'one_time', 'recurring'
- `card_brand_enum`: 'visa', 'mastercard', 'amex', 'discover', 'diners', 'jcb', 'unionpay', 'other'

### Security and Audit Enums
- `permission_category_enum`: 'asset', 'user', 'admin', 'report', 'document', 'ffc', 'system'
- `invitation_status_enum`: 'sent', 'phone_verified', 'accepted', 'approved', 'expired', 'cancelled', 'declined'
- `audit_action_enum`: 'create', 'read', 'update', 'delete', 'login', 'logout', 'export', 'share', 'permission_change', 'status_change'
- `audit_entity_type_enum`: 'user', 'persona', 'asset', 'document', 'ffc', 'permission', 'system'

### PII and Compliance Enums
- `pii_type_enum`: 'ssn', 'credit_card', 'bank_account', 'drivers_license', 'passport', 'medical_record', 'tax_id', 'other'
- `pii_risk_level_enum`: 'low', 'medium', 'high', 'critical'

### Integration Enums
- `language_code_enum`: 'en', 'es', 'fr', 'de', 'pt', 'zh', 'ja', 'ko', 'ar', 'hi', 'ru'
- `translation_status_enum`: 'pending', 'in_progress', 'completed', 'approved', 'rejected'
- `integration_status_enum`: 'connected', 'disconnected', 'error', 'pending', 'expired'
- `sync_status_enum`: 'pending', 'in_progress', 'completed', 'failed', 'partial'
- `webhook_status_enum`: 'pending', 'delivered', 'failed', 'retrying'

### UI Collection Mask Enums
- `collection_requirement`: 'mandatory', 'optional' - Specifies whether a field is required or optional for collection
- `ui_field_type`: 'text', 'int', 'real', 'phone', 'zip', 'email', 'date', 'year', 'currency', 'currency_code', 'enum' - Defines how fields should be rendered in the UI

## Tables (Organized by Category)

### Core System Tables

#### tenants
Multi-tenancy foundation table that isolates data between different organizations.

**Columns:**
- `id` (INTEGER, PRIMARY KEY)
- `name` (TEXT, NOT NULL, UNIQUE) - Unique tenant identifier
- `display_name` (TEXT, NOT NULL) - User-friendly tenant name
- `domain` (TEXT) - Tenant domain
- `logo_url` (TEXT) - Tenant branding logo URL
- `primary_color` (VARCHAR(7)) - Primary brand color (hex)
- `secondary_color` (VARCHAR(7)) - Secondary brand color (hex)
- `settings` (JSONB, DEFAULT '{}') - Tenant configuration settings
- `feature_flags` (JSONB, DEFAULT '{}') - Feature toggles
- `is_active` (BOOLEAN, NOT NULL, DEFAULT true)
- Standard audit fields (created_at, updated_at, created_by, updated_by)

#### media_storage
Centralized storage for all uploaded files and documents.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL) - Foreign key to tenants
- File identification (file_name, original_file_name, mime_type, file_size_bytes)
- Storage details (storage_provider, storage_bucket, storage_key, storage_region, cdn_url)
- File metadata (checksum, encryption_key_id, is_encrypted)
- Processing status and error handling
- Content analysis (has_pii, pii_types, content_classification)
- Lifecycle management (retention_policy, retention_until, is_archived, archived_at)
- Standard audit fields

#### document_metadata
Additional metadata for documents stored in media_storage.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- `media_storage_id` (UUID, NOT NULL) - Foreign key to media_storage
- Document classification (document_type, document_category)
- Document details (title, description, document_date, expiration_date)
- Document attributes (is_original, is_certified_copy, certification_details)
- Legal metadata (notarized, notary_details, witnessed, witness_details)
- Searchable content (extracted_text, ocr_processed, searchable_content as TSVECTOR)
- Tags and categorization (tags as TEXT[], custom_metadata as JSONB)
- Standard audit fields

### User and Identity Management

#### users
Core user authentication and profile information with AWS Cognito integration.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Cognito integration (cognito_user_id, cognito_username)
- Contact references (primary_email_id, primary_phone_id)
- Verification status (email_verified, email_verified_at, phone_verified, phone_verified_at)
- Account metadata (last_login_at, last_login_ip)
- Profile information (first_name, last_name, display_name, profile_picture_url)
- Preferences (preferred_language, timezone)
- System fields (status, created_at, updated_at, created_by, updated_by)

#### personas
Business identity layer representing family members (living or deceased).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- `user_id` (UUID) - NULL for deceased or non-user personas
- Personal identification (first_name, middle_name, last_name, suffix, nickname)
- Demographics (date_of_birth, date_of_death, place_of_birth, gender, marital_status)
- Documentation (ssn_last_four, has_full_ssn_on_file, drivers_license info)
- Professional information (occupation, employer)
- Profile (profile_photo_url, bio)
- System fields (is_living, status, created_at, updated_at, created_by, updated_by)

#### fwd_family_circles
Family groups that organize personas and assets.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- FFC identification (name, description)
- `owner_user_id` (UUID, NOT NULL) - Must be a user with login credentials
- FFC metadata (family_photo_url, established_date)
- Settings (settings, privacy_settings as JSONB)
- System fields (is_active, status, created_at, updated_at, created_by, updated_by)

### Contact Information Tables

#### phone_number
Centralized phone number storage with validation.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Phone components (country_code, phone_number, extension)
- Phone metadata (phone_type, is_primary, can_receive_sms, is_verified, verified_at)
- Carrier information (carrier_name, is_mobile)
- System fields (status, created_at, updated_at)

#### email_address
Centralized email address storage with validation.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Email details (email_address, domain)
- Email metadata (is_verified, verified_at, email_type)
- System fields (status, created_at, updated_at, created_by, updated_by)

#### address
Normalized physical address storage.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Address components (address_line_1, address_line_2, city, state_province, postal_code, country)
- Address metadata (address_type, is_primary)
- Geocoding (latitude, longitude, geocoding_accuracy)
- Validation (is_validated, validation_source, validated_at)
- System fields (status, created_at, updated_at)

#### social_media
Social media account information.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Platform details (platform, platform_user_id, username, profile_url)
- Account metadata (display_name, is_verified, is_business_account, follower_count)
- Privacy settings (is_public, is_active)
- System fields (status, created_at, updated_at)

### Usage/Relationship Tables

#### usage_email
Links email addresses to entities (users, personas, assets) with usage context.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Entity reference (entity_type, entity_id)
- `email_id` (UUID, NOT NULL) - Foreign key to email_address
- Usage details (usage_type, is_primary)
- Preferences (preferred_contact_time, notes)
- System fields (created_at, updated_at)

#### usage_phone
Links phone numbers to entities with usage context.

**Columns:**
- Similar structure to usage_email but for phone numbers
- `phone_id` (UUID, NOT NULL) - Foreign key to phone_number

#### usage_address
Links addresses to entities with usage context.

**Columns:**
- Similar structure to usage_email but for addresses
- `address_id` (UUID, NOT NULL) - Foreign key to address
- Validity period (effective_date, end_date)

#### usage_social_media
Links social media accounts to entities with usage context.

**Columns:**
- Similar structure to usage_email but for social media
- `social_media_id` (UUID, NOT NULL) - Foreign key to social_media
- Access details (has_login_credentials, recovery_email_id, recovery_phone_id)

### Asset Management Tables

#### asset_categories
Define the types of assets that can be tracked.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Category definition (name, code, description, icon)
- Hierarchy (parent_category_id, sort_order)
- Metadata (is_active, requires_valuation, requires_documentation)
- Standard audit fields

#### assets
Core asset tracking table.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Asset identification (category_id, name, description)
- Valuation (estimated_value, currency_code, last_valued_date)
- Metadata (tags as JSONB)
- System fields (status, created_at, updated_at, created_by, updated_by)

#### asset_persona
Links assets to personas with ownership details.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Relationships (asset_id, persona_id)
- Ownership details (ownership_type, ownership_percentage)
- Legal details (legal_title, transfer_on_death_to_persona_id)
- Documentation (ownership_document_id)
- Status (is_primary, effective_date, end_date)
- Standard audit fields

#### asset_permissions
Simple asset-level permissions for personas.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- `asset_id` (UUID, NOT NULL)
- `persona_id` (UUID, NOT NULL)
- `permission_level` (VARCHAR(20)) - 'read', 'edit', 'admin'
- Grant details (granted_by_persona_id, granted_at)
- Standard audit fields

### Asset Type-Specific Tables

#### personal_directives
Healthcare directives, POAs, and other personal directives.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Directive details (directive_type, directive_subtype)
- Principal/Grantor (principal_persona_id)
- Agents (agent_persona_id, agent_name, agent_email_id, agent_phone_id)
- Successor agents (successor_agent_1_persona_id, successor_agent_1_name, etc.)
- Healthcare specific fields (healthcare_wishes, life_support_preferences, organ_donation_preferences)
- POA specific fields (powers_granted, powers_excluded, special_instructions)
- Execution details (execution_date, effective_date, expiration_date)
- Legal details (state_of_execution, county_of_execution, notarized, witnesses)
- Document references (primary_document_id, supporting_documents)
- Status (status, revoked_date, revocation_document_id)
- Standard audit fields

#### trusts
Trust information storage.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Trust identification (trust_name, trust_type, tax_id)
- Parties (grantor_persona_id, grantor_name)
- Trustee information (trustee_persona_id, trustee_name, trustee_email_id, trustee_phone_id)
- Successor trustees (successor_trustee_1_persona_id, successor_trustee_1_name, etc.)
- Trust details (execution_date, effective_date, termination_date, state_of_formation)
- Trust provisions (distribution_provisions, special_provisions, amendment_provisions)
- Financial details (initial_funding_amount, current_value, value_as_of_date)
- Document references (trust_document_id, amendments)
- Status (is_funded, is_active)
- Standard audit fields

#### wills
Will information storage.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Testator information (testator_persona_id, testator_name)
- Executor information (executor_persona_id, executor_name, executor_email_id, executor_phone_id)
- Successor executors (successor_executor_1_persona_id, successor_executor_1_name, etc.)
- Will details (will_type, execution_date)
- Legal details (state_of_execution, county_of_execution)
- Witnesses (witness_1_name, witness_2_name, notarized, self_proving)
- Will provisions (guardian_provisions, distribution_provisions, special_bequests, residuary_clause)
- Codicils and amendments (has_codicils, codicil_dates, codicil_documents)
- Document storage (original_location, copies_location, will_document_id)
- Status (is_current, revoked_date, revocation_method, superseded_by_will_id)
- Standard audit fields

#### personal_property
Jewelry, collectibles, pets, art, furniture, etc.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Property classification (property_type, property_subtype)
- Item details (item_name, brand_manufacturer, model_style, serial_number, year_acquired)
- Physical characteristics (material_composition, dimensions, weight, color, condition_description)
- Location (storage_address_id, storage_location_detail)
- Insurance (is_insured, insurance_company, insurance_policy_number, insurance_value, insurance contacts)
- Documentation (receipt_document_id, appraisal_document_id, photo_ids, certificate_of_authenticity_id)
- Pet-specific fields (pet_name, pet_type, pet_breed, pet_age, pet_microchip_id, pet_care_instructions, veterinarian contact, pet_care_status)
- Standard audit fields

#### operational_property
Vehicles, boats, equipment, machinery, appliances.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Property classification (property_type, property_subtype)
- Identification (make, model, year, vin_hull_serial, registration_number, registration_state)
- Specifications (engine_details, mileage_hours, fuel_type, transmission_type, color)
- Location and storage (storage_address_id, storage_location_detail)
- Insurance (is_insured, insurance_company, insurance_policy_number, insurance contacts)
- Operational details (is_operational, last_service_date, next_service_due, service_provider_contact_id)
- Financial (loan_balance, loan_account_number, loan_institution)
- Documentation (title_document_id, registration_document_id, service_records)
- Standard audit fields

#### inventory
Business inventory, supplies, fixtures.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Inventory identification (inventory_type, category)
- Quantities (total_units, unit_of_measure, units_per_package)
- Valuation (cost_per_unit, total_cost, market_value_per_unit, total_market_value)
- Location (storage_address_id, storage_location_detail)
- Supplier information (supplier_name, supplier_contact_id, supplier contacts)
- Documentation (inventory_list_document_id, purchase_orders)
- Status (last_inventory_date, next_inventory_date)
- Standard audit fields

#### real_estate
Real property - homes, land, commercial property.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Property identification (property_type, property_subtype)
- Location (property_address_id NOT NULL, parcel_number)
- Property details (lot_size_acres, building_size_sqft, bedrooms, bathrooms, year_built)
- Ownership details (ownership_type, deed_type, title_company, title_policy_number)
- Usage (property_use, rental_income_monthly)
- Mortgage information (has_mortgage, mortgage_balance, mortgage_payment, mortgage_institution, mortgage_account_number)
- Insurance (homeowners_insurance_company, homeowners_policy_number, insurance_annual_premium, insurance contacts)
- Tax information (annual_property_tax, tax_assessment_value, tax_assessment_year)
- HOA/Condo information (has_hoa, hoa_fee_monthly, hoa_contact_id)
- Documentation (deed_document_id, survey_document_id)
- Standard audit fields

#### life_insurance
Life insurance policies.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Policy details (insurance_company, policy_number, policy_type)
- Coverage (death_benefit_amount, cash_value, cash_value_as_of_date)
- Policy dates (issue_date, maturity_date)
- Insured and owner (insured_persona_id, policy_owner_persona_id)
- Premium information (annual_premium, premium_frequency, premium_paid_to_date)
- Riders and options (has_riders, rider_details)
- Agent/Company contact (agent_name, agent_contact_id, insurer contacts)
- Documentation (policy_document_id, beneficiary_designation_document_id)
- Status (policy_status)
- Standard audit fields

#### financial_accounts
Bank accounts, investment accounts, retirement accounts.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Account identification (institution_name, account_type, account_number_last_four)
- Institution details (routing_number_last_four, swift_code, institution contacts)
- Account details (account_title, date_opened)
- Balances (current_balance, balance_as_of_date, available_balance)
- Investment specific (total_contributions, vested_balance, investment_risk_profile)
- Financial advisor (has_advisor, advisor_name, advisor contacts)
- Online access (online_access_url, online_username)
- Features (has_checks, has_debit_card, has_overdraft_protection)
- Documentation (statement_document_ids)
- Standard audit fields

#### recurring_income
Royalties, pensions, annuities, rental income.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Income identification (income_type, income_source, description)
- Payment details (payment_amount, payment_frequency)
- Payment dates (start_date, end_date, next_payment_date, last_payment_date)
- Payer information (payer_name, payer_tax_id, contact information)
- Documentation (contract_document_id, payment_history_document_id)
- Tax information (is_taxable, tax_form_type)
- Direct deposit (deposit_account_id)
- Status (is_active)
- Standard audit fields

#### digital_assets
Domains, IP, online accounts, cryptocurrency.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Asset classification (asset_type, asset_subtype)
- Digital asset details (asset_name, asset_identifier, platform_name)
- Access information (access_url, username, recovery contacts, two_factor_enabled)
- Intellectual property specific (ip_type, registration_number, registration_date, expiration_date, jurisdiction)
- Crypto specific (wallet_type, blockchain, wallet_address, approximate_balance, balance_as_of_date)
- Documentation (backup_codes_document_id, registration_document_id)
- Status (is_active, renewal_required, auto_renew_enabled)
- Standard audit fields

#### ownership_interests
Business ownership, partnerships, franchises.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Business identification (entity_name, entity_type, tax_id, state_of_formation)
- Ownership details (ownership_type, ownership_percentage, number_of_shares, share_class)
- Valuation (initial_investment, current_valuation, valuation_date, valuation_method)
- Business details (business_description, industry, annual_revenue, number_of_employees)
- Management (is_active_participant, management_role)
- Distributions (receives_distributions, distribution_frequency, last_distribution_amount, last_distribution_date)
- Key contacts (primary_contact_name, primary_contact_title, primary contact information)
- Governance (has_operating_agreement, has_buy_sell_agreement)
- Documentation (formation_document_id, operating_agreement_document_id, financial_statements_document_ids)
- Standard audit fields

#### loans
Loans receivable, family loans, business loans owed to the persona.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- Loan identification (loan_type, loan_number)
- Parties (lender_persona_id, lender_name, lender contacts, borrower_name, borrower_tax_id, borrower_contact_id)
- Loan terms (original_amount, current_balance, interest_rate, interest_type)
- Dates (origination_date, maturity_date, last_payment_date, next_payment_date)
- Payment details (payment_amount, payment_frequency, payments_remaining)
- Collateral (is_secured, collateral_description, collateral_value)
- Documentation (loan_agreement_document_id, promissory_note_document_id, payment_history_document_id)
- Status (loan_status)
- Collection information (is_in_collections, collection_agency_contact_id)
- Standard audit fields

#### hei_assets
Home Equity Investment assets - 14th Asset Category with specialized HEI fields.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `asset_id` (UUID, NOT NULL, UNIQUE)
- HEI terms (amount_funded, equity_share_pct, effective_date, maturity_terms)
- Property relationship (property_asset_id - references real estate asset)
- Capital stack (first_mortgage_balance, junior_liens_balance, cltv_at_close)
- Valuation (valuation_amount, valuation_method, valuation_effective_date)
- Recording (jurisdiction, instrument_number, book_page, recorded_at)
- Funding (funding_method, destination_account_last4, funded_at)
- External tracking (source_system, external_id, source_application_id)
- Servicing (monitoring_policy, notification_contacts)
- Documentation (hei_agreement_document_id, deed_of_trust_document_id, closing_disclosure_document_id)
- Status (hei_status)
- Standard audit fields

### Contact and External Entity Tables

#### contact_info
External contacts (advisors, companies, institutions).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Contact identification (entity_type, company_name, contact_name, title)
- Contact references (primary_email_id, primary_phone_id, primary_address_id)
- Additional info (website, notes)
- Professional details (license_number, license_state, specialties)
- System fields (is_preferred, status, created_at, updated_at)

#### ffc_personas
Links personas to FFCs with their role.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Relationships (ffc_id, persona_id)
- Role and relationship (ffc_role, family_relationship, relationship_details)
- Permissions and access (can_view_all_assets, can_manage_assets, custom_permissions)
- Status (joined_at, invited_at, invitation_accepted_at, is_active)
- Standard audit fields

### RBAC (Role-Based Access Control) Tables

#### user_roles
Define roles for RBAC system.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Role definition (name, description)
- Role metadata (is_system_role, is_assignable, priority)
- System fields (created_at, updated_at)

#### user_permissions
Define granular permissions.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Permission definition (name, category, description)
- Permission metadata (resource, action, conditions)
- System fields (is_system_permission, created_at, updated_at)

#### role_permissions
Link roles to permissions.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `role_id` (UUID, NOT NULL)
- `permission_id` (UUID, NOT NULL)
- Grant details (granted_at, granted_by)

#### user_role_assignments
Assign roles to users with optional FFC scope.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID, NOT NULL)
- `role_id` (UUID, NOT NULL)
- `ffc_id` (UUID) - NULL for platform_admin
- Assignment details (assigned_by, assigned_at, expires_at)
- Assignment metadata (assignment_reason, conditions)
- Status (is_active, revoked_at, revoked_by, revocation_reason)
- Standard audit fields

### Invitation System Tables

#### ffc_invitations
Manage invitations to join FFCs (extended for subscription seat management).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Invitation details (ffc_id, inviter_user_id, invitee_email_id, invitee_phone_id, invitee_name, proposed_role)
- Invitation message (personal_message)
- Verification (email_verification_code, email_verification_attempts, email_verified_at, phone_verification_code, phone_verification_attempts, phone_verified_at)
- Status tracking (status, sent_at, accepted_at, approved_at, approved_by_user_id, declined_at, declined_reason)
- Expiration (expires_at)
- **Subscription fields** (seat_type, subscription_id) - Added for seat assignment tracking
- Standard audit fields

#### invitation_verification_attempts
Track verification attempts for security.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `invitation_id` (UUID, NOT NULL)
- Attempt details (verification_type, attempted_code, ip_address, user_agent)
- Result (was_successful, failure_reason)
- Tracking (attempted_at)
- Phone specific (phone_id)
- Multi-tenancy (tenant_id)

### Subscription and Payment Management Tables

#### plans
Plan templates and catalog for subscription offerings.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Plan identification (plan_code UNIQUE, plan_name, plan_description)
- Plan configuration (plan_type, base_price, billing_frequency, trial_days)
- Feature configuration (features JSONB, ui_config JSONB)
- Stripe integration (stripe_product_id, stripe_price_id)
- Status and visibility (status, is_public, sort_order)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at, created_by, updated_by)

#### plan_seats
Seat configuration per plan defining included and additional seats.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `plan_id` (UUID, NOT NULL) - Foreign key to plans
- Seat configuration (seat_type, included_quantity, max_quantity, additional_seat_price)
- Features per seat type (features JSONB)
- Standard audit fields (created_at, updated_at)

#### subscriptions
Active subscriptions for each Forward Family Circle (one active subscription per FFC).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Subscription ownership (ffc_id UNIQUE WHERE status='active', plan_id)
- Payment responsibility (owner_user_id, payer_id, payer_type)
- Advisor tracking (advisor_id UUID) - References users table for advisor-sponsored plans
- Stripe integration (stripe_subscription_id, stripe_customer_id)
- Subscription status (status, trial_end_date, current_period_start, current_period_end)
- Cancellation tracking (canceled_at, cancel_reason)
- Billing details (next_billing_date, billing_amount)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at)

#### seat_assignments
Individual seat assignments within a subscription (one active assignment per persona per subscription).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `subscription_id` (UUID, NOT NULL) - Foreign key to subscriptions
- Assignment details (persona_id, seat_type) - UNIQUE(subscription_id, persona_id) WHERE status='active'
- Individual payer for self-upgrades (payer_id, is_self_paid)
- Status tracking (status, invited_at, activated_at, suspended_at)
- Invitation link (invitation_id references ffc_invitations)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at)

#### payment_methods
Stored payment methods for users (protected from deletion when in use via view).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- `user_id` (UUID, NOT NULL) - Foreign key to users
- Stripe details (stripe_payment_method_id, stripe_customer_id)
- Card details for display (payment_type, last_four, brand, exp_month, exp_year, card_holder_name)
- Status (is_default, status)
- Standard audit fields (created_at, updated_at)

**Note:** Usage tracking is provided via the `payment_methods_with_usage` view

#### services
One-time service catalog (e.g., Estate Capture Service).

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Service identification (service_code UNIQUE, service_name, service_description)
- Pricing (price, service_type)
- Stripe integration (stripe_product_id, stripe_price_id)
- Configuration (features JSONB, delivery_timeline)
- Status and visibility (status, is_public, sort_order)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at)

#### service_purchases
Records of one-time service purchases.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Purchase details (service_id, ffc_id, purchaser_user_id)
- Payment details (amount, stripe_payment_intent_id, payment_method_id)
- Status tracking (status, purchased_at, delivered_at)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at)

#### payments
Unified payment tracking for all payment types.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Payment details (payer_id, amount, currency)
- Payment type and reference (payment_type, reference_id)
- Payment method (payment_method_id)
- Stripe details (stripe_charge_id, stripe_payment_intent_id, stripe_invoice_id)
- Status tracking (status, failure_reason, processed_at)
- Metadata (metadata JSONB)
- Standard audit fields (created_at, updated_at)

#### general_ledger
Single-entry bookkeeping for financial tracking.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Transaction details (transaction_type, transaction_date, account_type)
- Financial details (amount, currency)
- Reference tracking (reference_type, reference_id)
- Stripe reference (stripe_reference)
- Transaction categorization (category CHECK IN ('recurring_monthly', 'recurring_annual', 'one_time', 'refund'))
- Description and notes (description, internal_notes)
- Reconciliation (reconciled, reconciled_at, reconciled_by)
- Metadata (metadata JSONB)
- Standard audit fields (created_at)

#### refunds
Refund tracking and processing.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Refund details (payment_id, amount, reason, reason_details)
- Stripe details (stripe_refund_id)
- Status tracking (status, initiated_by, processed_at)
- Metadata (metadata JSONB)
- Standard audit fields (created_at)

#### stripe_events
Webhook event processing for asynchronous Stripe integration.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Event identification (stripe_event_id UNIQUE, event_type)
- Processing status (status CHECK IN ('pending', 'processing', 'processed', 'failed', 'ignored'))
- Processing tracking (attempts, last_attempt_at, processed_at)
- Event data (payload JSONB, error_message)
- Standard audit fields (created_at)

#### subscription_transitions
History of subscription plan changes.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `subscription_id` (UUID, NOT NULL) - Foreign key to subscriptions
- Transition details (from_plan_id, to_plan_id, transition_type)
- Financial impact (prorated_amount, effective_date)
- User tracking (initiated_by, reason)
- Standard audit fields (created_at)

### Security and Session Management Tables

#### user_sessions
Track active user sessions.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID, NOT NULL)
- `tenant_id` (INTEGER, NOT NULL)
- Session details (session_token, refresh_token)
- Device/Browser info (ip_address, user_agent, device_id, device_type, browser, os)
- Session lifecycle (created_at, expires_at, last_activity_at)
- Session metadata (is_active, login_method)
- Revocation (revoked_at, revoked_by, revocation_reason)

#### user_mfa_settings
Multi-factor authentication settings.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID, NOT NULL)
- MFA configuration (mfa_enabled, mfa_method)
- TOTP settings (totp_secret, totp_verified, totp_verified_at)
- SMS/Phone settings (mfa_phone_id)
- Email settings (mfa_email_id)
- Target contact points (target_phone_id, target_email_id)
- Backup codes (backup_codes, backup_codes_generated_at, backup_codes_used)
- Recovery (recovery_codes)
- Standard audit fields

#### password_reset_tokens
Secure password reset tokens.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID, NOT NULL)
- Token details (token_hash)
- Token lifecycle (created_at, expires_at, used_at)
- Request metadata (requested_ip, requested_user_agent)
- Usage metadata (used_ip, used_user_agent)
- Status (is_valid, invalidated_reason)

#### user_login_history
Track login attempts and history.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID) - Can be NULL for failed attempts
- `email` (TEXT, NOT NULL) - Track even failed attempts
- Attempt details (attempt_timestamp, was_successful, failure_reason)
- Device/Location (ip_address, user_agent, device_id, location_country, location_city)
- Security (required_mfa, mfa_completed, risk_score, risk_factors)
- Session created (session_id)

### Audit and Compliance Tables

#### audit_log
Comprehensive audit trail.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Actor (user_id, persona_id, session_id)
- Action (action, entity_type, entity_id, entity_name)
- Change details (old_values, new_values, change_summary)
- Context (ip_address, user_agent, request_id)
- Timestamp (created_at)
- Additional metadata (metadata)

#### audit_events
System-wide audit events.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Event identification (event_type, event_category, severity)
- Event details (description, details)
- Source (source_system, source_ip)
- User context (user_id, session_id)
- Timing (occurred_at, detected_at)
- Response (response_action, resolved_at, resolved_by)

### PII and Data Protection Tables

#### pii_detection_rules
Rules for detecting and handling PII.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Rule definition (rule_name, pii_type)
- Pattern matching (detection_pattern, pattern_type)
- Rule configuration (confidence_threshold, is_active)
- Actions (action_on_detection, masking_pattern)
- Risk assessment (risk_level)
- Metadata (description, examples)
- Standard audit fields

#### pii_processing_jobs
Track PII scanning and processing jobs.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Job details (job_type, target_table, target_columns)
- Execution (status, started_at, completed_at)
- Results (records_processed, pii_found_count, pii_masked_count, errors_count)
- Error handling (error_details)
- Configuration (rules_applied, processing_options)
- System fields (created_at, scheduled_by)

#### masking_configurations
Configure data masking rules.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Target (table_name, column_name)
- Masking configuration (masking_type, masking_pattern, preserve_format)
- Conditions (apply_condition, user_roles)
- Options (show_last_n_chars, show_first_n_chars, replacement_char)
- Status (is_active)
- Standard audit fields

#### pii_access_logs
Track access to PII data.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Access details (user_id, accessed_at)
- What was accessed (table_name, column_names, record_identifiers)
- PII details (pii_types, data_classification)
- Access context (access_reason, access_method)
- Document reference (document_id)
- Session info (session_id, ip_address)
- Compliance (consent_verified, legal_basis)
- Alert status (requires_review, reviewed_by, reviewed_at)

### Translation and Localization Tables

#### translations
Multi-language support for UI and content.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Translation key (translation_key, language_code)
- Content (translated_text, context_notes)
- Metadata (is_verified, verified_by, verified_at)
- Version control (version, previous_text)
- Usage (usage_count, last_used_at)
- Standard audit fields

#### user_language_preferences
Track user language preferences.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `user_id` (UUID, NOT NULL)
- Language settings (preferred_language, fallback_language)
- Regional settings (date_format, time_format, currency_code, timezone)
- Accessibility (high_contrast_mode, large_text_mode)
- System fields (created_at, updated_at)

### Event Sourcing Tables

#### event_store
Immutable event log for complete audit trail and system state reconstruction.

**Columns:**
- `id` (UUID, PRIMARY KEY, DEFAULT gen_random_uuid())
- `tenant_id` (INTEGER, NOT NULL) - Foreign key to tenants
- `aggregate_id` (UUID, NOT NULL) - ID of the entity (asset, FFC, user, etc.)
- `aggregate_type` (TEXT, NOT NULL) - Type of entity (e.g., 'asset', 'ffc', 'user')
- `event_type` (TEXT, NOT NULL) - Type of event (e.g., 'AssetCreated', 'OwnershipTransferred')
- `event_data` (JSONB, NOT NULL) - Event payload with all relevant data
- `event_metadata` (JSONB) - Context information (user, IP, reason, etc.)
- `event_version` (INTEGER, NOT NULL) - Order of events for an aggregate
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT NOW())
- `created_by` (UUID, NOT NULL) - User who triggered the event

**Indexes:**
- `idx_event_store_aggregate_lookup` ON (aggregate_id, event_version)
- `idx_event_store_type` ON (event_type, created_at)
- `idx_event_store_tenant` ON (tenant_id, created_at)
- `idx_event_store_created_by` ON (created_by, created_at)

**Constraints:**
- CHECK (event_version > 0)
- UNIQUE (aggregate_id, event_version)

#### event_snapshots
Periodic snapshots of aggregate state for performance optimization.

**Columns:**
- `id` (UUID, PRIMARY KEY, DEFAULT gen_random_uuid())
- `tenant_id` (INTEGER, NOT NULL) - Foreign key to tenants
- `aggregate_id` (UUID, NOT NULL) - ID of the entity
- `aggregate_type` (TEXT, NOT NULL) - Type of entity
- `snapshot_version` (INTEGER, NOT NULL) - Event version this snapshot represents
- `snapshot_data` (JSONB, NOT NULL) - Complete state at this version
- `created_at` (TIMESTAMP, NOT NULL, DEFAULT NOW())

**Indexes:**
- `idx_event_snapshots_aggregate` ON (aggregate_id, snapshot_version DESC)
- `idx_event_snapshots_tenant` ON (tenant_id)

**Constraints:**
- UNIQUE (aggregate_id, snapshot_version)

#### event_projections
Materialized views for query optimization.

**Columns:**
- `id` (UUID, PRIMARY KEY, DEFAULT gen_random_uuid())
- `tenant_id` (INTEGER, NOT NULL) - Foreign key to tenants
- `projection_name` (TEXT, NOT NULL) - Name of the projection
- `aggregate_id` (UUID) - Optional aggregate this projection relates to
- `projection_data` (JSONB, NOT NULL) - Denormalized query-optimized data
- `last_event_version` (INTEGER, NOT NULL) - Last processed event version
- `updated_at` (TIMESTAMP, NOT NULL, DEFAULT NOW())

**Indexes:**
- `idx_event_projections_name` ON (projection_name, tenant_id)
- `idx_event_projections_aggregate` ON (aggregate_id) WHERE aggregate_id IS NOT NULL

**Constraints:**
- UNIQUE (tenant_id, projection_name, aggregate_id)

### Integration Tables

#### advisor_companies
Professional service providers.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Company details (company_name, company_type, tax_id)
- Contact information (primary_contact_name, primary contact references, website_url)
- Licensing (license_number, license_state, license_expiration)
- Service details (services_provided, specialties)
- Relationship (client_since, last_review_date, next_review_date)
- Ratings (service_rating, would_recommend, notes)
- Status (is_active)
- Standard audit fields

#### builder_io_integrations
Builder.io CMS integration.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Builder.io configuration (api_key, space_id, environment)
- Content mapping (content_model_mappings)
- Sync settings (auto_sync_enabled, sync_frequency_hours, last_sync_at, next_sync_at)
- Status (is_active, connection_status, last_error)
- System fields (created_at, updated_at)

#### quiltt_integrations
Quiltt financial data integration.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- `user_id` (UUID, NOT NULL)
- Quiltt connection (quiltt_connection_id, quiltt_profile_id)
- OAuth tokens (access_token_encrypted, refresh_token_encrypted, token_expires_at)
- Sync configuration (sync_accounts, sync_transactions, sync_investments)
- Sync status (last_sync_at, last_successful_sync_at, sync_status, sync_error)
- Connected accounts (connected_account_ids)
- Status (is_active, connection_status)
- System fields (created_at, updated_at)

#### quiltt_webhook_logs
Track Quiltt webhook events.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Webhook details (webhook_id, event_type)
- Payload (payload, headers)
- Processing (received_at, processed_at, processing_status, processing_error, retry_count)
- Related entities (user_id, integration_id)

#### real_estate_provider_integrations
Real estate data provider integration.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- `tenant_id` (INTEGER, NOT NULL)
- Provider details (provider_name, api_key_encrypted, api_endpoint)
- Configuration (update_frequency_days, property_data_fields)
- Status (is_active, last_sync_at)
- System fields (created_at, updated_at)

#### real_estate_sync_logs
Track real estate data synchronization.

**Columns:**
- `id` (UUID, PRIMARY KEY)
- Sync details (integration_id, property_id)
- Sync data (sync_type)
- Results (old_value, new_value, data_source)
- Status (sync_status, error_message)
- Timing (initiated_at, completed_at)

### UI Collection Mask Tables

#### ui_entity
Maps logical entity codes to physical table names for the UI collection mask system.

**Columns:**
- `entity_code` (TEXT, PRIMARY KEY) - UPPERCASE logical entity identifier (e.g., 'ASSETS', 'DIRECTIVES')
- `table_name` (TEXT, NOT NULL, UNIQUE) - Physical database table name

**Purpose:**
Provides an abstraction layer between logical entity names used in the UI and actual database table names, enabling flexible form generation and data collection workflows.

#### ui_collection_mask
Defines the UI mask configuration for database columns, enabling dynamic form generation in the frontend.

**Columns:**
- `entity_code` (TEXT, NOT NULL) - Foreign key to ui_entity(entity_code)
- `column_name` (TEXT, NOT NULL) - Database column name
- `requirement` (collection_requirement, NOT NULL) - Whether field is 'mandatory' or 'optional'
- `field_type` (ui_field_type, NOT NULL) - UI field type for rendering
- `display_order` (INTEGER, NOT NULL) - Order for field display
- `note` (TEXT) - Additional metadata (e.g., enum choices in pipe-separated format)

**Primary Key:** (entity_code, column_name)

**Constraints:**
- `ui_collection_mask_order_uniq`: UNIQUE (entity_code, display_order) DEFERRABLE INITIALLY IMMEDIATE
- `entity_code` → `ui_entity(entity_code)` ON DELETE CASCADE

**Purpose:**
Enables metadata-driven form generation by defining how database columns should be presented and collected in the UI. Supports 11 field types including text, numeric, date, currency, and enum fields with progressive disclosure (mandatory vs optional).

## Relationships (Foreign Keys - Deduplicated)

### Tenant Relationships
All major tables have foreign key constraints to `tenants(id)` for multi-tenant isolation:
- `media_storage.tenant_id` → `tenants(id)`
- `document_metadata.tenant_id` → `tenants(id)`
- `users.tenant_id` → `tenants(id)`
- `personas.tenant_id` → `tenants(id)`
- `fwd_family_circles.tenant_id` → `tenants(id)`
- All contact and usage tables have tenant_id foreign keys
- All asset-related tables have tenant_id foreign keys
- All RBAC tables have tenant_id foreign keys
- All audit and compliance tables have tenant_id foreign keys

### Core Entity Relationships
- `users.primary_email_id` → `email_address(id)`
- `users.primary_phone_id` → `phone_number(id)`
- `personas.user_id` → `users(id)` (NULL allowed for deceased personas)
- `fwd_family_circles.owner_user_id` → `users(id)`
- `ffc_personas.ffc_id` → `fwd_family_circles(id)`
- `ffc_personas.persona_id` → `personas(id)`

### Asset Relationships
- `assets.category_id` → `asset_categories(id)`
- `asset_persona.asset_id` → `assets(id)`
- `asset_persona.persona_id` → `personas(id)`
- `asset_persona.transfer_on_death_to_persona_id` → `personas(id)`
- `asset_permissions.asset_id` → `assets(id)`
- `asset_permissions.persona_id` → `personas(id)`

### Asset Type-Specific Relationships
Each asset type table has:
- `[asset_type].asset_id` → `assets(id)` (UNIQUE constraint)
- Various persona references for roles (owner, trustee, executor, etc.)
- Document references to `media_storage(id)`
- Contact information references

### Contact Information Relationships
- `usage_email.email_id` → `email_address(id)`
- `usage_phone.phone_id` → `phone_number(id)`
- `usage_address.address_id` → `address(id)`
- `usage_social_media.social_media_id` → `social_media(id)`

### Document and Media Relationships
- `document_metadata.media_storage_id` → `media_storage(id)`
- `media_storage.uploaded_by` → `users(id)`

### RBAC Relationships
- `role_permissions.role_id` → `user_roles(id)`
- `role_permissions.permission_id` → `user_permissions(id)`
- `user_role_assignments.user_id` → `users(id)`
- `user_role_assignments.role_id` → `user_roles(id)`
- `user_role_assignments.ffc_id` → `fwd_family_circles(id)`

### Invitation System Relationships
- `ffc_invitations.ffc_id` → `fwd_family_circles(id)`
- `ffc_invitations.inviter_user_id` → `users(id)`
- `ffc_invitations.invitee_email_id` → `email_address(id)`
- `ffc_invitations.invitee_phone_id` → `phone_number(id)`
- `invitation_verification_attempts.invitation_id` → `ffc_invitations(id)`

### Security and Session Relationships
- `user_sessions.user_id` → `users(id)` (ON DELETE CASCADE)
- `user_mfa_settings.user_id` → `users(id)` (ON DELETE CASCADE)
- `password_reset_tokens.user_id` → `users(id)` (ON DELETE CASCADE)
- `user_login_history.user_id` → `users(id)` (ON DELETE CASCADE)

### Audit Relationships
- `audit_log.user_id` → `users(id)`
- `audit_log.persona_id` → `personas(id)`
- `audit_log.session_id` → `user_sessions(id)`

### Event Sourcing Relationships
- `event_store.tenant_id` → `tenants(id)`
- `event_store.created_by` → `users(id)`
- `event_snapshots.tenant_id` → `tenants(id)`
- `event_projections.tenant_id` → `tenants(id)`

### Integration Relationships
- `quiltt_integrations.user_id` → `users(id)`
- `quiltt_webhook_logs.user_id` → `users(id)`
- `quiltt_webhook_logs.integration_id` → `quiltt_integrations(id)`
- `real_estate_sync_logs.integration_id` → `real_estate_provider_integrations(id)`
- `real_estate_sync_logs.property_id` → `real_estate(id)`

### UI Collection Mask Relationships
- `ui_collection_mask.entity_code` → `ui_entity(entity_code)` ON DELETE CASCADE

### Self-Referential Relationships
- `asset_categories.parent_category_id` → `asset_categories(id)`
- `wills.superseded_by_will_id` → `wills(id)`
- Various audit fields referencing `users(id)` for created_by/updated_by

## Indexes (Deduplicated)

### Unique Partial Indexes (PostgreSQL 17 compatible)
These replace invalid UNIQUE constraints with WHERE clauses:
- `unique_primary_email_per_entity` ON `usage_email(entity_type, entity_id, is_primary)` WHERE `is_primary = TRUE`
- `unique_primary_phone_per_entity` ON `usage_phone(entity_type, entity_id, is_primary)` WHERE `is_primary = TRUE`
- `unique_primary_address_per_entity` ON `usage_address(entity_type, entity_id, is_primary)` WHERE `is_primary = TRUE`
- `unique_primary_social_per_entity` ON `usage_social_media(entity_type, entity_id, is_primary)` WHERE `is_primary = TRUE`
- `unique_active_role_assignment` ON `user_role_assignments(user_id, role_id, ffc_id, is_active)` WHERE `is_active = TRUE`
- `unique_primary_owner_per_asset` ON `asset_persona(asset_id, is_primary)` WHERE `is_primary = TRUE`
- `unique_active_subscription_per_ffc` ON `subscriptions(ffc_id)` WHERE `status = 'active'`
- `unique_active_seat_per_persona` ON `seat_assignments(subscription_id, persona_id)` WHERE `status = 'active'`

### Tenant Isolation Indexes (Critical for Multi-tenancy)
- `idx_media_storage_tenant` ON `media_storage(tenant_id)`
- `idx_document_metadata_tenant` ON `document_metadata(tenant_id)`
- `idx_users_tenant` ON `users(tenant_id)`
- `idx_personas_tenant` ON `personas(tenant_id)`
- `idx_fwd_family_circles_tenant` ON `fwd_family_circles(tenant_id)`
- `idx_assets_tenant` ON `assets(tenant_id)`
- All major tables with tenant_id have corresponding tenant isolation indexes

### Authentication and Session Indexes
- `idx_users_cognito_user_id` ON `users(cognito_user_id)`
- `idx_users_email_verified` ON `users(email_verified)` WHERE `email_verified = FALSE`
- `idx_users_status` ON `users(status)`
- `idx_user_sessions_token` ON `user_sessions(session_token)` WHERE `is_active = TRUE`
- `idx_user_sessions_user` ON `user_sessions(user_id, is_active)`
- `idx_password_reset_tokens_hash` ON `password_reset_tokens(token_hash)` WHERE `is_valid = TRUE`

### Contact Information Lookup Indexes
- `idx_email_address_email` ON `email_address(email_address)`
- `idx_phone_number_phone` ON `phone_number(country_code, phone_number)`
- `idx_address_postal` ON `address(postal_code, country)`

### Entity Relationship Indexes (Polymorphic)
- `idx_usage_email_entity` ON `usage_email(entity_type, entity_id)`
- `idx_usage_phone_entity` ON `usage_phone(entity_type, entity_id)`
- `idx_usage_address_entity` ON `usage_address(entity_type, entity_id)`
- `idx_usage_social_media_entity` ON `usage_social_media(entity_type, entity_id)`

### FFC and Persona Relationship Indexes
- `idx_ffc_personas_ffc` ON `ffc_personas(ffc_id)`
- `idx_ffc_personas_persona` ON `ffc_personas(persona_id)`
- `idx_personas_user` ON `personas(user_id)` WHERE `user_id IS NOT NULL`
- `idx_ffc_personas_role` ON `ffc_personas(ffc_role)`

### Asset Relationship Indexes
- `idx_assets_category` ON `assets(category_id)`
- `idx_asset_persona_asset` ON `asset_persona(asset_id)`
- `idx_asset_persona_persona` ON `asset_persona(persona_id)`

### Document and Media Indexes
- `idx_media_storage_processing` ON `media_storage(processing_status)` WHERE `processing_status != 'ready'`
- `idx_document_metadata_media` ON `document_metadata(media_storage_id)`
- `idx_document_metadata_type` ON `document_metadata(document_type, document_category)`
- `idx_document_metadata_search` ON `document_metadata` USING GIN(`searchable_content`)

### Subscription and Payment Indexes
- `idx_plans_tenant_status` ON `plans(tenant_id, status)`
- `idx_plans_code` ON `plans(plan_code)`
- `idx_plans_public` ON `plans(is_public, status)` WHERE `is_public = TRUE`
- `unique_active_subscription_per_ffc` ON `subscriptions(ffc_id)` WHERE `status = 'active'` UNIQUE
- `idx_subscriptions_ffc` ON `subscriptions(ffc_id)`
- `idx_subscriptions_status` ON `subscriptions(status, tenant_id)`
- `idx_subscriptions_payer` ON `subscriptions(payer_id)` WHERE `payer_id IS NOT NULL`
- `idx_subscriptions_advisor` ON `subscriptions(advisor_id)` WHERE `advisor_id IS NOT NULL`
- `idx_subscriptions_stripe` ON `subscriptions(stripe_subscription_id)` WHERE `stripe_subscription_id IS NOT NULL`
- `unique_active_seat_per_persona` ON `seat_assignments(subscription_id, persona_id)` WHERE `status = 'active'` UNIQUE
- `idx_seat_assignments_subscription` ON `seat_assignments(subscription_id, status)`
- `idx_seat_assignments_persona` ON `seat_assignments(persona_id)`
- `idx_seat_assignments_invitation` ON `seat_assignments(invitation_id)` WHERE `invitation_id IS NOT NULL`
- `idx_payments_payer` ON `payments(payer_id, status)`
- `idx_payments_reference` ON `payments(reference_id, payment_type)`
- `idx_payments_stripe` ON `payments(stripe_payment_intent_id)` WHERE `stripe_payment_intent_id IS NOT NULL`
- `idx_payments_date` ON `payments(created_at DESC)`
- `idx_ledger_date` ON `general_ledger(transaction_date DESC)`
- `idx_ledger_reconciliation` ON `general_ledger(reconciled, transaction_date)`
- `idx_ledger_category` ON `general_ledger(category, transaction_date)`
- `idx_ledger_reference` ON `general_ledger(reference_id)` WHERE `reference_id IS NOT NULL`
- `unique_stripe_event_id` ON `stripe_events(stripe_event_id)` UNIQUE
- `idx_stripe_events_status` ON `stripe_events(status, created_at)` WHERE `status IN ('pending', 'failed')`

### Audit and Compliance Indexes
- `idx_audit_log_user` ON `audit_log(user_id)`
- `idx_audit_log_entity` ON `audit_log(entity_type, entity_id)`
- `idx_audit_log_created` ON `audit_log(created_at DESC)`
- `idx_pii_access_logs_user` ON `pii_access_logs(user_id)`
- `idx_pii_access_logs_document` ON `pii_access_logs(document_id)`

### RBAC Indexes
- `idx_user_role_assignments_user` ON `user_role_assignments(user_id)` WHERE `is_active = TRUE`
- `idx_user_role_assignments_role` ON `user_role_assignments(role_id)` WHERE `is_active = TRUE`
- `idx_role_permissions_role` ON `role_permissions(role_id)`

### Invitation Indexes
- `idx_ffc_invitations_ffc` ON `ffc_invitations(ffc_id)`
- `idx_ffc_invitations_status` ON `ffc_invitations(status)`
- `idx_ffc_invitations_email` ON `ffc_invitations(invitee_email_id)`

### Financial and Asset-Specific Indexes
- `idx_financial_accounts_asset` ON `financial_accounts(asset_id)`
- `idx_real_estate_asset` ON `real_estate(asset_id)`
- `idx_life_insurance_asset` ON `life_insurance(asset_id)`
- `idx_personal_property_asset` ON `personal_property(asset_id)`

### Event Sourcing Indexes
- `idx_event_store_aggregate_lookup` ON `event_store(aggregate_id, event_version)`
- `idx_event_store_type` ON `event_store(event_type, created_at)`
- `idx_event_store_tenant` ON `event_store(tenant_id, created_at)`
- `idx_event_store_created_by` ON `event_store(created_by, created_at)`
- `idx_event_snapshots_aggregate` ON `event_snapshots(aggregate_id, snapshot_version DESC)`
- `idx_event_snapshots_tenant` ON `event_snapshots(tenant_id)`
- `idx_event_projections_name` ON `event_projections(projection_name, tenant_id)`
- `idx_event_projections_aggregate` ON `event_projections(aggregate_id)` WHERE `aggregate_id IS NOT NULL`

### Integration Indexes
- `idx_quiltt_integrations_user` ON `quiltt_integrations(user_id)`
- `idx_quiltt_webhook_logs_status` ON `quiltt_webhook_logs(processing_status)` WHERE `processing_status = 'pending'`

## Views

### Payment Management Views

#### payment_methods_with_usage
Provides payment methods with computed usage status to prevent deletion of in-use payment methods.

**Columns:**
- All columns from `payment_methods` table
- `is_in_use` (BOOLEAN) - Computed field indicating if the payment method is currently in use

**Usage Logic:**
The `is_in_use` field is `TRUE` when:
1. The payment method is associated with an active, trialing, or past_due subscription
2. The payment method has been used for a successful payment in the last 30 days

**Query Definition:**
```sql
CREATE OR REPLACE VIEW payment_methods_with_usage AS
SELECT 
    pm.*,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM subscriptions 
            WHERE payer_id = pm.user_id 
            AND status IN ('active', 'trialing', 'past_due')
        ) THEN true
        WHEN EXISTS (
            SELECT 1 FROM payments 
            WHERE payment_method_id = pm.id 
            AND status = 'succeeded' 
            AND created_at > NOW() - INTERVAL '30 days'
        ) THEN true
        ELSE false
    END AS is_in_use
FROM payment_methods pm;
```

**Used By:**
- `sp_check_payment_method_usage()` - Function to verify if payment method can be deleted
- `sp_delete_payment_method()` - Procedure that safely deletes unused payment methods

## Database Operations Architecture

### Overview

The database operations have been modernized from a stored procedure-centric approach to a hybrid architecture leveraging:
- **pgTyped** for compile-time SQL type safety
- **Slonik** for runtime PostgreSQL client operations
- **Single source of truth** - Each query lives in one `.sql` file

This migration converted 59 of 70 stored procedures (84%) to individual SQL queries, improving maintainability, type safety, and enabling better version control.

### pgTyped Integration

pgTyped provides compile-time type safety by:
- Introspecting the live PostgreSQL schema
- Generating TypeScript types from `.sql` files
- Ensuring query parameters and return types match the database schema
- Preventing runtime SQL errors through build-time validation

### Slonik Runtime Client

Slonik serves as the production-grade runtime client providing:
- Connection pooling with configurable limits
- Strict SQL parameterization preventing injection attacks
- Query logging and performance monitoring
- Automatic retry logic for transient failures
- Statement timeout enforcement

### SQL Query Organization

#### Converted Operations (99 SQL files)

The following categories of operations have been converted from stored procedures to individual SQL queries:

**Authentication & Session (5 files)**
- `current_user_id.sql` - Get current user's ID from session context
- `current_tenant_id.sql` - Get current tenant ID from session context
- `is_ffc_member.sql` - Check if user is member of an FFC
- `set_session_context.sql` - Set user and tenant context
- `clear_session_context.sql` - Clear session context

**User Management (1 file)**
- `update_user_profile.sql` - Update user profile information

**FFC Management (5 files)**
- `create_ffc_step1.sql` - Create new FFC
- `create_ffc_step2.sql` - Add owner as member
- `add_persona_to_ffc.sql` - Add persona to FFC
- `update_ffc_member_role.sql` - Update member role
- `remove_ffc_member.sql` - Remove member from FFC

**Asset Management (15 files)**
- `get_asset_details.sql` - Retrieve asset information
- `search_assets.sql` - Search with filters
- `update_asset_details.sql` - Update asset properties
- `soft_delete_asset.sql` - Soft delete asset
- `update_asset_value.sql` - Update valuation
- `get_asset_ownership.sql` - Get ownership details
- `transfer_ownership_*.sql` (3 files) - Transfer operations
- `assign_asset_to_persona_upsert.sql` - Link assets
- `check_asset_ownership_total.sql` - Validate percentages
- `unset_other_primary_owners.sql` - Manage primary ownership
- `get_asset_categories.sql` - List categories
- `create_asset_category.sql` - Create new category

**Contact Management (6 files)**
- `create_email_if_not_exists.sql` - Create email record
- `link_email_to_persona.sql` - Link email to persona
- `unset_other_primary_emails.sql` - Manage primary emails
- `create_phone_if_not_exists.sql` - Create phone record
- `link_phone_to_persona.sql` - Link phone to persona
- `unset_other_primary_phones.sql` - Manage primary phones

**Subscription & Payment (20 files)**
- `calculate_seat_availability.sql` - Check available seats
- `get_subscription_*.sql` (5 files) - Subscription queries
- `cancel_subscription.sql` - Cancel subscription
- `suspend_subscription_seats.sql` - Suspend seats
- `update_subscription_*.sql` (2 files) - Update subscription
- `record_subscription_transition.sql` - Log plan changes
- `create_invoice_payment.sql` - Record payments
- `update_payment_*.sql` (2 files) - Payment status
- `check_payment_method_*.sql` (2 files) - Payment validation
- `delete_payment_method.sql` - Remove payment method
- `create_ledger_entry.sql` - Bookkeeping entries

**Audit & Compliance (5 files)**
- `log_audit_event.sql` - Log audit events
- `create_audit_event.sql` - Create audit records
- `get_audit_trail.sql` - Retrieve audit history
- `compliance_report_stats.sql` - Generate statistics
- `compliance_report_user_activity.sql` - User activity reports

**Event Sourcing (6 files)**
- `append_event.sql` - Add events to store
- `get_next_event_version.sql` - Version management
- `replay_events.sql` - Event replay
- `create_snapshot.sql` - Create snapshots
- `get_current_event_version.sql` - Current version
- `cleanup_old_snapshots.sql` - Maintenance

**Integration Operations (30+ files)**
- PII Management (3 files)
- Quiltt Integration (4 files)
- Real Estate Integration (3 files)
- Builder.io Integration (3 files)
- Advisor Companies (3 files)
- Translation Management (3 files)
- System Configuration (1 file)
- Health Checks (3 files)
- Retry Logic (3 files)

### Remaining Stored Procedures

The following 10 complex procedures remain as stored procedures with pgTyped-compatible wrapper files:

#### Complex Business Logic Procedures (10)

These procedures contain complex business logic, multi-step transactions, or dynamic SQL that are best kept as stored procedures:

1. **sp_create_user_from_cognito** - Complex user creation with multi-table inserts
   - Wrapper: `call_sp_create_user_from_cognito.sql`
   
2. **sp_create_asset** - Asset creation with category validation and ownership setup
   - Wrapper: `call_sp_create_asset.sql`

3. **sp_create_ffc_with_subscription** - FFC creation with automatic subscription setup
   - Wrapper: `call_sp_create_ffc_with_subscription.sql`
   
4. **sp_process_seat_invitation** - Complex invitation processing with validation
   - Wrapper: `call_sp_process_seat_invitation.sql`

5. **sp_purchase_service** - Service purchase with payment processing
   - Wrapper: `call_sp_purchase_service.sql`
   
6. **sp_process_stripe_webhook** - Webhook processing with dynamic event routing
   - Wrapper: `call_sp_process_stripe_webhook.sql`
- `sp_create_asset(p_tenant_id INTEGER, p_owner_persona_id UUID, p_asset_type asset_type_enum, p_name TEXT, p_description TEXT, p_ownership_percentage DECIMAL(5,2) DEFAULT 100.00, p_created_by_user_id UUID DEFAULT NULL)` RETURNS UUID - Create new asset
- `sp_update_asset(p_asset_id UUID, p_name TEXT DEFAULT NULL, p_description TEXT DEFAULT NULL, p_estimated_value DECIMAL(15,2) DEFAULT NULL, p_status status_enum DEFAULT NULL, p_metadata JSONB DEFAULT NULL, p_updated_by UUID DEFAULT NULL)` RETURNS BOOLEAN - Update existing asset properties
- `sp_delete_asset(p_asset_id UUID, p_deleted_by UUID DEFAULT NULL, p_hard_delete BOOLEAN DEFAULT FALSE)` RETURNS BOOLEAN - Delete asset (soft or hard delete)
- `sp_transfer_asset_ownership(p_asset_id UUID, p_from_persona_id UUID, p_to_persona_id UUID, p_ownership_percentage DECIMAL(5,2) DEFAULT NULL, p_transfer_type VARCHAR(50) DEFAULT 'full', p_transferred_by UUID DEFAULT NULL)` RETURNS BOOLEAN - Transfer ownership between personas
- `sp_update_asset_value(p_asset_id UUID, p_new_value DECIMAL(15,2), p_valuation_date DATE DEFAULT CURRENT_DATE, p_valuation_method VARCHAR(50) DEFAULT 'market', p_updated_by UUID DEFAULT NULL)` RETURNS BOOLEAN - Update asset valuation
- `sp_get_asset_details(p_asset_id UUID, p_requesting_user UUID DEFAULT NULL)` RETURNS TABLE - Retrieve comprehensive asset information
- `sp_search_assets(p_ffc_id UUID DEFAULT NULL, p_category_code VARCHAR(50) DEFAULT NULL, p_owner_persona_id UUID DEFAULT NULL, p_status status_enum DEFAULT NULL, p_min_value DECIMAL(15,2) DEFAULT NULL, p_max_value DECIMAL(15,2) DEFAULT NULL, p_search_term TEXT DEFAULT NULL, p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)` RETURNS TABLE - Search assets with filters
- `sp_assign_asset_to_persona(p_asset_id UUID, p_persona_id UUID, p_ownership_type ownership_type_enum DEFAULT 'owner', p_ownership_percentage DECIMAL(5,2) DEFAULT 100.00, p_is_primary BOOLEAN DEFAULT FALSE, p_assigned_by UUID DEFAULT NULL)` RETURNS BOOLEAN - Link assets to personas

7. **sp_rebuild_projection** - Event sourcing projection rebuilding
   - Wrapper: `call_sp_rebuild_projection.sql`
- `sp_add_email_to_persona(p_persona_id UUID, p_email TEXT, p_usage_type email_usage_type_enum DEFAULT 'personal', p_is_primary BOOLEAN DEFAULT FALSE, p_added_by UUID DEFAULT NULL)` RETURNS UUID - Add email to persona
- `sp_add_phone_to_persona(p_persona_id UUID, p_phone VARCHAR(20), p_country_code VARCHAR(5) DEFAULT '+1', p_usage_type phone_usage_type_enum DEFAULT 'primary', p_is_primary BOOLEAN DEFAULT FALSE, p_added_by UUID DEFAULT NULL)` RETURNS UUID - Add phone to persona

8. **sp_sync_quiltt_data** - Complex financial data synchronization
   - Wrapper: `call_sp_sync_quiltt_data.sql`
- `sp_create_invitation(p_tenant_id INTEGER, p_ffc_id UUID, p_phone_number VARCHAR(20), p_role ffc_role_enum, p_invited_by UUID, p_persona_first_name TEXT, p_persona_last_name TEXT)` RETURNS UUID - Create FFC invitation

9. **sp_sync_real_estate_data** - Property data synchronization with multiple providers
   - Wrapper: `call_sp_sync_real_estate_data.sql`
   
10. **sp_refresh_builder_content** - CMS content synchronization
    - Wrapper: `call_sp_refresh_builder_content.sql`
- `sp_create_ffc_with_subscription(p_tenant_id INTEGER, p_name TEXT, p_description TEXT, p_owner_user_id UUID, p_owner_persona_id UUID, OUT p_ffc_id UUID, OUT p_subscription_id UUID)` - Create FFC with automatic free plan assignment (prevents duplicate active subscriptions)
- `sp_process_seat_invitation(p_invitation_id UUID, p_subscription_id UUID, p_persona_id UUID, p_seat_type seat_type_enum DEFAULT 'pro')` - Process seat invitation after approval (checks for existing assignments)
- `sp_purchase_service(p_tenant_id INTEGER, p_service_id UUID, p_ffc_id UUID, p_purchaser_user_id UUID, p_payment_method_id UUID, p_stripe_payment_intent_id TEXT, OUT p_purchase_id UUID, OUT p_payment_id UUID)` - Purchase one-time service by service ID
- `sp_purchase_service(p_tenant_id INTEGER, p_service_code VARCHAR(50), p_ffc_id UUID, p_purchaser_user_id UUID, p_payment_method_id UUID, p_stripe_payment_intent_id TEXT, OUT p_purchase_id UUID, OUT p_payment_id UUID)` - Purchase one-time service by service code (overloaded)
- `sp_process_stripe_webhook(p_stripe_event_id TEXT, p_event_type TEXT, p_payload JSONB)` - Process Stripe webhook events asynchronously
- `sp_handle_payment_succeeded(p_event_id UUID, p_payload JSONB)` - Handle successful payment from Stripe
- `sp_handle_payment_failed(p_event_id UUID, p_payload JSONB)` - Handle failed payment from Stripe
- `sp_handle_invoice_payment_succeeded(p_event_id UUID, p_payload JSONB)` - Handle successful invoice payment from Stripe
- `sp_handle_subscription_created(p_event_id UUID, p_payload JSONB)` - Handle subscription created webhook
- `sp_handle_subscription_updated(p_event_id UUID, p_payload JSONB)` - Handle subscription updated webhook
- `sp_handle_subscription_deleted(p_event_id UUID, p_payload JSONB)` - Handle subscription deleted webhook
- `sp_check_payment_method_usage(p_payment_method_id UUID)` RETURNS BOOLEAN - Check if payment method is in use before deletion
- `sp_delete_payment_method(p_payment_method_id UUID, p_user_id UUID)` - Safely delete payment method (fails if in use)
- `sp_transition_subscription_plan(p_subscription_id UUID, p_new_plan_id UUID, p_initiated_by UUID, p_reason TEXT DEFAULT NULL)` - Change subscription plan
- `sp_cancel_subscription(p_subscription_id UUID, p_user_id UUID, p_reason TEXT DEFAULT NULL)` - Cancel subscription
- `sp_get_subscription_status(p_ffc_id UUID)` RETURNS TABLE - Get current subscription status and details
- `sp_calculate_seat_availability(p_subscription_id UUID)` RETURNS TABLE - Calculate available seats for subscription plans
- `sp_get_subscription_details(p_ffc_id UUID)` RETURNS TABLE - Get detailed subscription information with seat counts
- `sp_create_ledger_entry(p_tenant_id INTEGER, p_transaction_type transaction_type_enum, p_account_type ledger_account_type_enum, p_amount DECIMAL(10,2), p_reference_type VARCHAR(50), p_reference_id UUID, p_description TEXT, p_stripe_reference VARCHAR(255) DEFAULT NULL)` - Create general ledger entry

### Query File Naming Conventions

SQL files follow a consistent naming pattern for maintainability:
- **Actions**: `create_`, `update_`, `delete_`, `get_`, `check_`, `validate_`
- **Entities**: Singular form (e.g., `asset`, `subscription`, `payment`)
- **Modifiers**: Descriptive suffixes (e.g., `_if_not_exists`, `_with_usage`)

### Transaction Management

Complex operations that previously relied on stored procedure transactions are now handled through:
- Slonik's transaction management
- Explicit BEGIN/COMMIT in SQL files where needed
- Application-level transaction coordination in NestJS services
- `sp_log_audit_event(p_action VARCHAR(50), p_entity_type VARCHAR(50), p_entity_id UUID, p_entity_name TEXT DEFAULT NULL, p_old_values JSONB DEFAULT NULL, p_new_values JSONB DEFAULT NULL, p_metadata JSONB DEFAULT '{}', p_user_id UUID DEFAULT NULL)` RETURNS UUID - Log audit events
- `sp_create_audit_event(p_event_type TEXT, p_event_category VARCHAR(50), p_description TEXT, p_risk_level VARCHAR(20) DEFAULT 'low', p_compliance_framework VARCHAR(50) DEFAULT 'SOC2', p_metadata JSONB DEFAULT '{}', p_user_id UUID DEFAULT NULL)` RETURNS UUID - Create audit events
- `sp_get_audit_trail(p_entity_type VARCHAR(50) DEFAULT NULL, p_entity_id UUID DEFAULT NULL, p_user_id UUID DEFAULT NULL, p_action VARCHAR(50) DEFAULT NULL, p_start_date timestamptz DEFAULT NULL, p_end_date timestamptz DEFAULT NULL, p_limit INTEGER DEFAULT 100, p_offset INTEGER DEFAULT 0)` RETURNS TABLE - Retrieve audit history
- `sp_generate_compliance_report(p_framework VARCHAR(50) DEFAULT 'SOC2', p_start_date DATE DEFAULT NULL, p_end_date DATE DEFAULT NULL, p_include_pii_activity BOOLEAN DEFAULT TRUE)` RETURNS TABLE - Generate compliance reports

#### Reporting (1)
- `sp_get_ffc_summary(p_ffc_id UUID, p_user_id UUID)` RETURNS TABLE - Get comprehensive FFC summary with statistics

#### Session Context (2)
- `sp_set_session_context(p_user_id UUID, p_tenant_id INTEGER)` RETURNS VOID - Set user and tenant context for session
- `sp_clear_session_context()` RETURNS VOID - Clear session context

#### Utility Functions (1)
- `update_updated_at_column()` RETURNS TRIGGER - Trigger function to update timestamps

### Migration Statistics

- **Total Procedures**: 70
- **Converted to SQL**: 59 (84%)
- **Kept as Procedures**: 10 (14%)
- **Trigger Functions**: 1 (2%)
- **Total SQL Files**: 109 (99 conversions + 10 wrappers)

### Benefits of the New Architecture

1. **Type Safety**: Compile-time validation prevents runtime SQL errors
2. **Version Control**: Individual SQL files enable better change tracking
3. **Testing**: Easier to test individual queries in isolation
4. **Performance**: Query optimization is more transparent
5. **Maintenance**: Simpler to update and debug individual operations
6. **Documentation**: SQL files can include inline documentation

#### Event Store Management
- `sp_append_event(p_tenant_id INTEGER, p_aggregate_id UUID, p_aggregate_type TEXT, p_event_type TEXT, p_event_data JSONB, p_event_metadata JSONB DEFAULT NULL, p_user_id UUID DEFAULT NULL)` RETURNS UUID - Append event to store
- `sp_replay_events(p_aggregate_id UUID, p_from_version INTEGER DEFAULT 1, p_to_version INTEGER DEFAULT NULL)` RETURNS TABLE - Replay events for an aggregate
- `sp_create_snapshot(p_tenant_id INTEGER, p_aggregate_id UUID, p_aggregate_type TEXT, p_snapshot_data JSONB)` RETURNS UUID - Create snapshot of aggregate state
- `sp_rebuild_projection(p_tenant_id INTEGER, p_projection_name TEXT, p_aggregate_id UUID DEFAULT NULL)` RETURNS VOID - Rebuild projection from event stream

### Trigger Functions

The following trigger function remains unchanged as it must be a database function:

- `update_updated_at_column()` - Automatically updates `updated_at` timestamp on row modifications
- `sp_detect_pii(p_text TEXT, p_context TEXT DEFAULT 'general', p_user_id UUID DEFAULT NULL)` RETURNS TABLE (detected BOOLEAN, pii_types JSONB, confidence_score DECIMAL, masked_text TEXT, detection_details JSONB) - Detect PII in text with masking
- `sp_update_pii_job_status(p_job_id UUID, p_status VARCHAR(20), p_processed_records INTEGER DEFAULT NULL, p_pii_found_count INTEGER DEFAULT NULL, p_error_message TEXT DEFAULT NULL, p_results JSONB DEFAULT NULL)` RETURNS BOOLEAN - Update PII processing job status

### SQL File Location

All converted SQL files are located in:
```
/docs/requirements/DB/sql scripts/5_SQL_files/
```

This directory contains:
- 99 converted query files
- 10 procedure wrapper files
- `COMPLETE_70_PROCEDURE_MAPPING.md` - Complete mapping documentation

## Helper Functions

### Trigger Functions
- `update_updated_at_column()` - Automatically updates `updated_at` timestamp on row modifications

### RLS Policy Functions
- `current_user_id()` - Returns current session user ID for RLS policies
- `current_tenant_id()` - Returns current session tenant ID for RLS policies
- `is_ffc_member()` - Determines FFC membership for access control

## RLS Policies

The database implements comprehensive Row-Level Security (RLS) policies for data isolation and access control:

### Tenant Isolation Policies
All major tables have tenant isolation policies using `current_tenant_id()`:
- `users_tenant_isolation` - Users can only see data from their tenant
- `personas_tenant_isolation` - Personas scoped to tenant
- `assets_tenant_isolation` - Assets scoped to tenant
- `ffc_tenant_isolation` - FFCs scoped to tenant

### User Access Policies
- `users_self_read` - Users can read their own profile
- `users_self_update` - Users can update their own profile

### FFC Access Policies
- `ffc_member_access` - Users can access FFCs they're members of
- `ffc_owner_full_access` - FFC owners have full access to their FFCs

### Asset Access Policies
- `assets_persona_owner_access` - Users can access assets owned by their personas

### Persona Access Policies
- `personas_ffc_access` - Users can access personas in FFCs they're members of

### Contact Information Policies
- `email_tenant_isolation`, `phone_tenant_isolation`, `address_tenant_isolation` - Contact info scoped to tenant
- `usage_email_entity_access`, `usage_phone_entity_access`, `usage_address_entity_access` - Usage records accessible based on entity ownership

### Media and Document Policies
- `media_tenant_isolation` - Media files scoped to tenant
- `media_uploader_access` - Users can access files they uploaded
- `documents_tenant_isolation` - Document metadata scoped to tenant

This comprehensive RLS implementation ensures data security, privacy, and proper multi-tenant isolation while maintaining performance through strategic indexing.

## Testing Framework

### Automated Stored Procedure Testing

The database includes a comprehensive Node.js/TypeScript testing framework for all 50 stored procedures:

#### Test Implementation
- **Location**: `/docs/requirements/DB/Node JS scripts/test-data-generator/`
- **Main Test Classes**:
  - `StoredProcedureTester.ts` - Core test implementation with all test cases
  - `test-stored-procedures-with-output.ts` - Enhanced runner with file output capabilities

#### Test Coverage
All 50 procedures are tested across three categories:
1. **Core Procedures (28)** - User management, FFC operations, assets, audit, etc.
2. **Event Sourcing Procedures (4)** - Event store management and projections
3. **Integration Procedures (18)** - External system integrations (Quiltt, Builder.io, etc.)

#### Test Features
- **Automatic Test Data Generation** - Creates required test data (tenants, users, personas, FFCs)
- **Comprehensive Coverage** - Tests all procedures with valid parameters
- **Multiple Output Formats**:
  - JSON for programmatic analysis
  - Markdown for human-readable reports
  - CSV for spreadsheet analysis
- **Performance Tracking** - Measures execution time for each procedure
- **Error Handling** - Captures and reports failures with detailed error messages

#### Running Tests
```bash
# Setup and run tests
cd docs/requirements/DB/Node JS scripts/test-data-generator
npm install
npm run build
npm run test:procedures  # Run with console output
npm run test:procedures:output  # Run with file output to test-results/
```

#### Test Results
Test results are saved to `test-results/` directory with timestamps:
- `test-results-YYYY-MM-DDTHH-MM-SS.json` - Complete test data
- `test-results-YYYY-MM-DDTHH-MM-SS.md` - Formatted markdown report
- `test-results-YYYY-MM-DDTHH-MM-SS.csv` - CSV summary

The testing framework ensures all procedures work correctly with the actual database schema and helps identify issues during development.