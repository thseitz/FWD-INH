  📊 Database Table Count: 150 Total Tables

  Core Infrastructure (15 tables)

  - users, user_sessions, user_mfa_settings, personas, tenants
  - contact_info, phone_numbers, email_addresses, physical_addresses
  - ffcs, ffc_personas, asset_categories, roles, permissions, user_roles

  Asset Category Tables (78 tables)

  1. Financial Accounts (6 tables)
  - financial_accounts, financial_account_balances, financial_account_transactions, financial_account_statements,
  account_types, financial_institutions

  2. Personal Property (6 tables)
  - personal_property, jewelry_items, art_collectibles, pets_animals, furniture_items, precious_metals

  3. Trust (6 tables)
  - trusts, trust_beneficiaries, trust_trustees, trust_distributions, trust_assets, trust_types

  4. Will (6 tables)
  - wills, will_beneficiaries, will_executors, will_assets, will_amendments, will_witnesses

  5. Personal Directives (6 tables)
  - personal_directives, powers_of_attorney, healthcare_directives, hipaa_authorizations, directive_types,
  agent_assignments

  6. Real Estate (9 tables)
  - real_estate_properties, property_types, property_features, property_valuations, property_ownership, property_taxes,     
   property_insurance, rental_income_records, property_expenses

  7. Operational Property (6 tables)
  - operational_property, vehicles, boats_yachts, equipment_machinery, appliances_gear, operational_property_types

  8. Inventory (6 tables)
  - inventory_items, inventory_categories, inventory_locations, inventory_valuations, inventory_movements,
  inventory_audits

  9. Life Insurance (6 tables)
  - life_insurance_policies, policy_beneficiaries, policy_premiums, policy_claims, insurance_companies, policy_types        

  10. Recurring Income (6 tables)
  - recurring_income_sources, royalty_payments, income_categories, income_schedules, income_tax_records,
  income_projections

  11. Digital Assets (6 tables)
  - digital_assets, intellectual_property, domain_names, cryptocurrency_holdings, social_media_accounts,
  digital_wallets

  12. Ownership Interests (6 tables)
  - ownership_interests, business_entities, franchise_agreements, partnership_interests, equity_positions,
  ownership_transfers

  13. Loans (3 tables)
  - loans, loan_payments, loan_amortization_schedules

  Integration & External Systems (15 tables)

  - third_party_integrations, integration_logs, webhook_endpoints, webhook_logs
  - quillt_integrations, quillt_webhook_log, hei_integrations, hei_sync_log
  - real_estate_integrations, bank_connections, api_keys, oauth_tokens
  - sync_jobs, integration_errors, external_data_cache

  Document Management (6 tables)

  - asset_documents, document_versions, document_shares, document_categories, document_templates,
  document_retention_policies

  PII Protection (4 tables)

  - pii_processing_jobs, pii_detection_rules, pii_entities, data_masking_policies

  Security & Audit (10 tables)

  - audit_log, login_attempts, security_events, failed_login_tracking
  - permission_grants, access_requests, security_alerts, compliance_reports
  - data_retention_schedules, legal_holds

  Asset Management Core (8 tables)

  - assets, asset_persona_ownership, asset_permissions, asset_valuations
  - asset_notes, asset_tags, asset_relationships, asset_history

  Invitation & Verification (4 tables)

  - ffc_invitations, invitation_verifications, phone_verifications, email_verifications

  Reference & Lookup (4 tables)

  - countries, states_provinces, currencies, time_zones

  Notification System (3 tables)

  - notifications, notification_preferences, notification_templates

  Bilingual Translation System (3 tables)

  - translations, user_language_preferences, translation_metrics

  ---
  🎯 Key Architecture Highlights

  Multi-Tenant Design: Every major table includes tenant_id for strict data isolation

  Comprehensive Asset Coverage: All 13 asset categories from the PRD requirements are fully implemented with supporting     
   tables

  Enterprise Security: Dedicated tables for audit trails, PII protection, and security monitoring

  Integration Ready: Extensive integration tables supporting Quillt API, HEI providers, and real estate data sources        

  Scalable Architecture: Proper separation of concerns with specialized tables for different functional areas

  Bilingual Support: Streamlined English + Spanish translation system for US market expansion

  This represents a sophisticated, enterprise-grade database architecture designed to handle complex family wealth
  management scenarios with proper security, compliance, and scalability considerations.

> list the stored procedure names and thier purpose

● Task(List all stored procedures)
  ⎿  Done (24 tool uses · 49.2k tokens · 3m 23.4s)

● Based on my comprehensive analysis of the architecture.md file, here are all 22 stored procedures planned for the
  Forward Inheritance platform:

  🔧 Complete List of Stored Procedures (22 Total)

  📈 Marketing & Lead Management (1)

  1. capture_marketing_lead
    - Purpose: Captures marketing leads with spam/rate limiting validation and queues welcome emails
    - Returns: lead_id, status, message

  👥 User Management & FFC Onboarding (2)

  2. register_user
    - Purpose: User registration with email uniqueness validation and verification token generation
    - Returns: user_id, verification_token, status
  3. invite_ffc_member
    - Purpose: Invites new members to Family Financial Circles with permission validation
    - Returns: invitation_id, email_token, sms_code, status

  💼 Asset Management & PII Protection (3)

  4. create_asset_with_ownership
    - Purpose: Creates assets with ownership records and validates ownership percentages
    - Returns: asset_id, ownership_id, status
  5. upload_asset_document
    - Purpose: Handles document uploads with PII detection queue management
    - Returns: document_id, processing_job_id, status
  6. complete_pii_processing
    - Purpose: Completes PII masking process and updates document with masked data
    - Returns: document_id, pii_detected, status

  📊 Reporting, Analytics & Integrations (5)

  7. search_family_assets
    - Purpose: Advanced asset search with full-text search capabilities and filtering
    - Returns: asset_id, asset_name, category_name, owner_name, estimated_value, match_score, snippet
  8. generate_wealth_report
    - Purpose: Generates comprehensive wealth summary reports with growth calculations
    - Returns: category_name, asset_count, total_value, avg_value, top_owner, growth_12m_percent
  9. log_audit_event
    - Purpose: Enhanced audit logging with risk scoring and security alert triggering
    - Returns: audit_id (UUID)
  10. bulk_update_assets
    - Purpose: Bulk asset updates with permission validation and error handling
    - Returns: operation_id, total_assets, successful_updates, failed_updates, error_details
  11. manage_integration
    - Purpose: Manages third-party integrations (create, activate, deactivate)
    - Returns: integration_id, status, message

  📜 Wills & Estate Planning (5)

  12. create_will
    - Purpose: Creates will records with executor and witness management
    - Returns: will_id (UUID)
  13. add_will_bequest
    - Purpose: Adds bequests to wills with beneficiary validation
    - Returns: bequest_id (UUID)
  14. add_will_codicil
    - Purpose: Adds codicils (amendments) to existing wills
    - Returns: codicil_id (UUID)
  15. add_will_guardian_designation
    - Purpose: Adds guardian designations for minors in wills
    - Returns: guardianship_id (UUID)
  16. get_will_details
    - Purpose: Retrieves comprehensive will information with counts of related records
    - Returns: Complete will details including executor, witness, bequest, codicil, and guardianship counts

  💰 Recurring Income Management (4)

  17. record_income_payment
    - Purpose: Records recurring income payments with tax withholding calculations
    - Returns: payment_id (UUID)
  18. calculate_income_projections
    - Purpose: Calculates future income projections based on historical data and trends
    - Returns: month, projected_gross, projected_net, confidence_level
  19. manage_income_beneficiaries
    - Purpose: Manages beneficiary designations for recurring income assets
    - Returns: BOOLEAN (success/failure)
  20. get_income_review_dashboard
    - Purpose: Provides income review dashboard with payment trends and review flags
    - Returns: Comprehensive income dashboard data

  🏦 Loan Management (2)

  21. sync_hei_loan_data
    - Purpose: Synchronizes Home Equity Investment (HEI) loan data from external APIs
    - Returns: VOID (procedure)
  22. forgive_loan
    - Purpose: Processes loan forgiveness with modification tracking
    - Returns: VOID (procedure)

  ---
  🎯 Key Architecture Features

  Security-First Design: All procedures include permission validation, audit logging, and tenant isolation

  Comprehensive Error Handling: Each procedure includes detailed error handling with meaningful return codes

  Multi-Tenant Support: All procedures enforce row-level security with tenant context validation

  Audit Trail: Every procedure logs operations through the log_audit_event function

  Business Logic Enforcement: Complex business rules enforced at the database level for consistency

  This stored procedure only architecture ensures maximum security, performance, and maintainability by centralizing        
  all business logic at the database layer while preventing direct table access from the application layer.

> how does data get added manually enter through the front end web UI utilizing which stored procedures based on assets

● Based on the Forward Inheritance platform architecture, here's how data gets added manually through the front-end web
   UI for each asset category:

  🖥️ Manual Data Entry Flow Through Web UI

  📋 General Asset Creation Pattern

  Step 1: Asset Category Selection
  - User selects from 13 asset categories via dropdown/tiles
  - Frontend validates user permissions for asset creation

  Step 2: Asset Data Entry Form
  - Dynamic form generation based on selected category
  - Category-specific fields populated from database schemas
  - Real-time validation on frontend with backend confirmation

  Step 3: Ownership Assignment
  - User assigns ownership percentage and type
  - Multiple personas can own single asset with percentage breakdown

  Step 4: Document Upload (Optional)
  - File upload with drag-and-drop interface
  - Triggers PII detection pipeline automatically

  ---
  🏦 Asset Category-Specific Data Entry

  1. Financial Accounts

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Account type → Institution → Account details → Balances
  - Backend Process: Creates financial_accounts record with encrypted account numbers
  - Additional: Balance history tracked in financial_account_balances

  2. Personal Property (Jewelry, Art, Collectibles, etc.)

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Property type → Description → Valuation → Photos
  - Backend Process: Creates personal_property record with subcategory-specific data
  - Additional: Photo uploads trigger upload_asset_document for image management

  3. Trust

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Trust type → Trustees → Beneficiaries → Asset allocation
  - Backend Process: Creates trusts record with linked trust_beneficiaries and trust_trustees
  - Complex Logic: Handles trust distribution rules and beneficiary percentages

  4. Will

  Primary Stored Procedure: create_will
  - UI Flow: Will type → Executors → Witnesses → Bequests
  - Backend Process: Multi-step creation using several procedures:
    - create_will for basic will record
    - add_will_bequest for each bequest added
    - add_will_guardian_designation for guardian appointments
    - add_will_codicil for amendments

  5. Personal Directives (POA, Healthcare, etc.)

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Directive type → Agent assignment → Scope definition → Execution terms
  - Backend Process: Creates personal_directives record with agent_assignments
  - Validation: Ensures proper legal agent designation

  6. Real Estate

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Property address → Property details → Valuation → Ownership structure
  - Backend Process: Creates real_estate_properties with multiple supporting records:
    - property_features for property characteristics
    - property_valuations for current and historical values
    - property_ownership for complex ownership structures
  - Integration: May trigger real estate data provider lookup for property enrichment

  7. Operational Property (Vehicles, Boats, Equipment)

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Property type → Specifications → Valuation → Maintenance records
  - Backend Process: Creates operational_property with type-specific subtables
  - Additional: Maintenance tracking and depreciation calculations

  8. Inventory

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Inventory category → Location → Quantity → Valuation method
  - Backend Process: Creates inventory_items with location and movement tracking
  - Features: Supports bulk inventory entry and barcode scanning

  9. Life Insurance

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Policy type → Beneficiaries → Premium details → Coverage amounts
  - Backend Process: Creates life_insurance_policies with policy_beneficiaries
  - Calculations: Premium tracking and benefit calculations

  10. Recurring Income (Royalties)

  Primary Stored Procedures:
  - create_asset_with_ownership (initial creation)
  - record_income_payment (payment tracking)
  - manage_income_beneficiaries (beneficiary management)
  - UI Flow: Income source → Payment schedule → Tax withholding → Beneficiaries
  - Backend Process: Creates recurring_income_sources with automated payment tracking
  - Features: Income projection calculations and tax reporting

  11. Digital Assets (IP, Crypto, Domains)

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Asset type → Platform/Registry → Access credentials → Valuation
  - Backend Process: Creates digital_assets with secure credential storage
  - Security: Credentials encrypted and access logged

  12. Ownership Interests (Business, Franchise)

  Primary Stored Procedure: create_asset_with_ownership
  - UI Flow: Entity type → Ownership percentage → Valuation method → Related assets
  - Backend Process: Creates ownership_interests with business_entities
  - Complexity: Handles complex ownership structures and related asset linking

  13. Loans (HEI, Interfamily)

  Primary Stored Procedures:
  - create_asset_with_ownership (initial creation)
  - sync_hei_loan_data (HEI integration)
  - forgive_loan (loan modifications)
  - UI Flow: Loan type → Terms → Payment schedule → Collateral
  - Backend Process: Creates loans with loan_amortization_schedules
  - Integration: HEI loans sync automatically from external APIs

  ---
  🔄 Common UI Components Across All Assets

  Document Upload Flow

  // Frontend triggers:
  uploadDocument() → API call → upload_asset_document()
  → PII Detection Queue → complete_pii_processing()

  Permission Management

  - Asset-level permission assignment during creation
  - Granular access control (read/edit/admin) per persona
  - Inheritance from FFC-level permissions with override capability

  Audit Trail

  - Every asset creation/modification logged via log_audit_event
  - User action tracking with IP address and session data
  - Change history maintained automatically

  Validation Pipeline

  1. Frontend Validation: Real-time field validation and form completion checks
  2. API Validation: Permission checks and data format validation
  3. Database Validation: Stored procedure validation with business rule enforcement
  4. Post-Creation: Document processing and PII detection if applicable

  ---
  🎯 Key Benefits of This Architecture

  Consistency: All asset types follow the same creation pattern with category-specific customization

  Security: Every operation goes through stored procedures with built-in permission validation

  Audit Trail: Complete tracking of who created what, when, and from where

  Flexibility: Dynamic form generation allows for easy addition of new asset types

  Data Integrity: Database-level validation ensures data consistency across all asset categories

  This architecture ensures that manual data entry through the web UI is secure, consistent, and fully audited while        
  providing a smooth user experience tailored to each asset category's specific requirements.


Complete Coverage:

  10 Functional Categories:

  1. Authentication & User Management (5 functions)
  2. FFC & Persona Management (5 functions)
  3. Asset Management (5 functions)
  4. Financial Calculations (5 functions)
  5. Integration & Synchronization (5 functions)
  6. Security & Permissions (4 functions)
  7. Audit & Logging (3 functions)
  8. PII Processing (4 functions)
  9. Utility Functions (9 functions)
  10. Performance & Maintenance (3 functions)

  Each Function Includes:

  - Complete SQL signature with parameter types
  - Input parameters with descriptions
  - Return types and output structure
  - Purpose and business logic description
  - Security level (all use SECURITY DEFINER)

  Key Features:

  - Multi-tenant architecture with tenant isolation
  - Comprehensive audit logging for all operations
  - PII protection and data masking capabilities
  - Financial calculations for loans, valuations, taxes
  - External API integration for Quillt, HEI providers
  - Security-first design with permission verification
  - Performance optimization with caching and cleanup

  The specification follows the platform's "Stored Procedure Only" architecture ensuring complete database security and
  controlled access patterns.

