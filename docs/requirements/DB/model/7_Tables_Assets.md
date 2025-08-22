# 05 - Asset Management Tables

## Table of Contents
1. [Overview](#overview)
2. [Asset Architecture](#asset-architecture)
3. [Core Asset Tables](#core-asset-tables)
4. [Financial Asset Tables](#financial-asset-tables)
5. [Physical Property Tables](#physical-property-tables)
6. [Business & Digital Assets](#business--digital-assets)
7. [Legal Document Assets](#legal-document-assets)
8. [Asset Relationships](#asset-relationships)
9. [Data Integrity & Constraints](#data-integrity--constraints)

## Overview

The Forward Inheritance Platform's asset management system is built around **16 specialized tables** that handle the diverse range of assets families need to track for inheritance planning. The system supports everything from real estate and financial accounts to digital assets, legal documents, and HEI investments.

### Asset Management Architecture
- **Base Asset Table**: Common properties for all assets
- **Asset Categories**: 14 predefined categories matching business requirements
- **Specialized Tables**: One table per asset category for specific attributes
- **Ownership Junction**: Flexible persona-asset ownership relationships
- **Inheritance Model**: Clear inheritance chains from base to specialized tables

### Key Statistics
- **Total Tables**: 16 (1 base + 1 junction + 14 category tables)
- **Asset Categories**: 14 predefined categories with extensible metadata
- **Ownership Types**: 4 types (owner, beneficiary, trustee, executor)
- **Supported Currencies**: Multi-currency support with default USD

## Asset Architecture

### Inheritance Model
```
assets (base table)
├── real_estate
├── financial_accounts  
├── operational_property
├── life_insurance
├── personal_property
├── business_interests
├── digital_assets
├── inventory
├── loans
├── trusts
├── wills
├── personal_directives
├── recurring_income
└── hei_assets
```

### Ownership Model
```
personas ←→ asset_persona ←→ assets
         (ownership junction)    (base table)
                ↓
         specialized asset tables
```

## Core Asset Tables

### assets table
The foundation table containing common properties for all asset types.

```sql
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    category_id UUID NOT NULL REFERENCES asset_categories(id),
    
    -- Asset identification
    name TEXT NOT NULL,
    description TEXT,
    
    -- Valuation
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    last_valued_date DATE,
    
    -- Metadata
    tags JSONB DEFAULT '[]',
    
    -- Status
    status status_enum NOT NULL DEFAULT 'active',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

**Key Features:**
- **Universal Properties**: All assets share name, description, value, currency
- **Category Reference**: Links to predefined asset categories
- **Flexible Valuation**: Supports multi-currency with historical valuation dates
- **Tagging System**: JSONB array for flexible categorization and search
- **Extensible Metadata**: Future-proof design for evolving requirements

### asset_categories table
Defines the 14 predefined asset categories that drive the specialized table structure.

```sql
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true
);
```

**Predefined Categories:**
1. **personal_directives** - Power of Attorney, Healthcare Directive, HIPAA Authorization
2. **trust** - Trust documents and agreements
3. **will** - Will documents
4. **personal_property** - Jewelry, Precious Metals, Collectibles, Art, Furniture
5. **operational_property** - Vehicles, Boats, Equipment, Machinery
6. **inventory** - Business inventory and fixtures
7. **real_estate** - Property and Real Estate holdings
8. **life_insurance** - Life Insurance policies
9. **financial_accounts** - Investments, Bank accounts, Retirement Accounts
10. **recurring_income** - Royalties and recurring income streams
11. **digital_assets** - Intellectual Property, Digital Assets
12. **ownership_interests** - Business and Franchise ownership
13. **loans** - HEI and Interfamily Loans

### asset_persona table
Junction table managing ownership relationships between personas and assets.

```sql
CREATE TABLE asset_persona (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    
    -- Relationships
    asset_id UUID NOT NULL,
    persona_id UUID NOT NULL,
    
    -- Ownership details
    ownership_type ownership_type_enum NOT NULL,
    ownership_percentage DECIMAL(5, 2),
    
    -- Legal details
    legal_title TEXT,
    transfer_on_death_to_persona_id UUID,
    
    -- Documentation
    ownership_document_id UUID,
    
    -- Status
    is_primary BOOLEAN DEFAULT FALSE,
    effective_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

**Ownership Types:**
- **owner**: Full legal ownership
- **beneficiary**: Inheritance beneficiary
- **trustee**: Trust management responsibility
- **executor**: Estate execution responsibility

## Financial Asset Tables

### real_estate table
Real property assets including residential, commercial, and land holdings.

```sql
CREATE TABLE real_estate (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property identification
    property_type property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Location (required - property must have address)
    property_address_id UUID NOT NULL,
    parcel_number TEXT, -- Assessor's parcel number
    
    -- Property details
    lot_size_acres DECIMAL(10, 4),
    building_size_sqft INTEGER,
    bedrooms INTEGER,
    bathrooms DECIMAL(3, 1),
    year_built INTEGER,
    
    -- Ownership details
    ownership_type property_ownership_enum NOT NULL,
    deed_type TEXT,
    title_company TEXT,
    title_policy_number TEXT,
    
    -- Usage
    property_use property_use_enum NOT NULL,
    rental_income_monthly DECIMAL(15, 2),
    
    -- Mortgage information
    has_mortgage BOOLEAN DEFAULT FALSE,
    mortgage_balance DECIMAL(15, 2),
    mortgage_payment DECIMAL(15, 2),
    mortgage_institution TEXT,
    mortgage_account_number TEXT,
    
    -- Insurance
    homeowners_insurance_company TEXT,
    homeowners_policy_number TEXT,
    insurance_annual_premium DECIMAL(15, 2),
    insurance_contact_email_id UUID,
    insurance_contact_phone_id UUID,
    
    -- Tax information
    annual_property_tax DECIMAL(15, 2),
    tax_assessment_value DECIMAL(15, 2),
    tax_assessment_year INTEGER,
    
    -- HOA/Condo information
    has_hoa BOOLEAN DEFAULT FALSE,
    hoa_fee_monthly DECIMAL(15, 2),
    hoa_contact_id UUID,
    
    -- Documentation
    deed_document_id UUID,
    survey_document_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### financial_accounts table
Bank accounts, investment accounts, and retirement accounts.

```sql
CREATE TABLE financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Account identification
    institution_name TEXT NOT NULL,
    account_type account_type_enum NOT NULL,
    account_number_last_four VARCHAR(4),
    
    -- Institution details
    routing_number_last_four VARCHAR(4),
    swift_code VARCHAR(11),
    institution_contact_email_id UUID,
    institution_contact_phone_id UUID,
    
    -- Account details
    account_title TEXT, -- How account is titled
    date_opened DATE,
    
    -- Balances
    current_balance DECIMAL(15, 2),
    balance_as_of_date DATE,
    available_balance DECIMAL(15, 2),
    
    -- Investment specific
    total_contributions DECIMAL(15, 2),
    vested_balance DECIMAL(15, 2),
    investment_risk_profile investment_risk_profile_enum,
    
    -- Financial advisor
    has_advisor BOOLEAN DEFAULT FALSE,
    advisor_name TEXT,
    advisor_email_id UUID,
    advisor_phone_id UUID,
    advisor_contact_id UUID,
    
    -- Online access
    online_access_url TEXT,
    online_username TEXT,
    
    -- Features
    has_checks BOOLEAN DEFAULT FALSE,
    has_debit_card BOOLEAN DEFAULT FALSE,
    has_overdraft_protection BOOLEAN DEFAULT FALSE,
    
    -- Documentation
    statement_document_ids UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### life_insurance table
Life insurance policies including term, whole, universal, and variable life.

```sql
CREATE TABLE life_insurance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Policy details
    insurance_company TEXT NOT NULL,
    policy_number TEXT NOT NULL,
    policy_type TEXT NOT NULL, -- Term, Whole, Universal, Variable
    
    -- Coverage
    death_benefit_amount DECIMAL(15, 2) NOT NULL,
    cash_value DECIMAL(15, 2),
    cash_value_as_of_date DATE,
    
    -- Policy dates
    issue_date DATE NOT NULL,
    maturity_date DATE,
    
    -- Insured and owner
    insured_persona_id UUID NOT NULL,
    policy_owner_persona_id UUID NOT NULL,
    
    -- Beneficiaries (stored in asset_persona with ownership_type='beneficiary')
    
    -- Premium information
    annual_premium DECIMAL(15, 2),
    premium_frequency payment_frequency_enum,
    premium_paid_to_date DATE,
    
    -- Riders and options
    has_riders BOOLEAN DEFAULT FALSE,
    rider_details TEXT,
    
    -- Agent/Company contact
    agent_name TEXT,
    agent_contact_id UUID,
    insurer_contact_email_id UUID,
    insurer_contact_phone_id UUID,
    
    -- Documentation
    policy_document_id UUID,
    beneficiary_designation_document_id UUID,
    
    -- Status
    policy_status VARCHAR(50) DEFAULT 'active', -- active, lapsed, paid-up, surrendered
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### loans table
All loan-related assets including mortgages, personal loans, and interfamily loans.

```sql
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Loan identification
    loan_type loan_type_enum NOT NULL,
    loan_number TEXT,
    
    -- Parties
    lender_persona_id UUID NOT NULL,
    lender_name TEXT NOT NULL,
    lender_contact_email_id UUID,
    lender_contact_phone_id UUID,
    
    borrower_name TEXT NOT NULL,
    borrower_tax_id VARCHAR(20),
    borrower_contact_id UUID,
    
    -- Loan terms
    original_amount DECIMAL(15, 2) NOT NULL,
    current_balance DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 3),
    interest_type interest_type_enum,
    
    -- Dates
    origination_date DATE NOT NULL,
    maturity_date DATE,
    last_payment_date DATE,
    next_payment_date DATE,
    
    -- Payment details
    payment_amount DECIMAL(15, 2),
    payment_frequency payment_frequency_enum,
    payments_remaining INTEGER,
    
    -- Collateral
    is_secured BOOLEAN DEFAULT FALSE,
    collateral_description TEXT,
    collateral_value DECIMAL(15, 2),
    
    -- Documentation
    loan_agreement_document_id UUID,
    promissory_note_document_id UUID,
    payment_history_document_id UUID,
    
    -- Status
    loan_status loan_status_enum NOT NULL DEFAULT 'active',
    
    -- Collection information
    is_in_collections BOOLEAN DEFAULT FALSE,
    collection_agency_contact_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### hei_assets table
Home Equity Investment assets - 14th Asset Category with specialized HEI fields and property linking.

```sql
CREATE TABLE hei_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- HEI terms
    amount_funded DECIMAL(15, 2) NOT NULL,
    equity_share_pct DECIMAL(5, 2) NOT NULL CHECK (equity_share_pct >= 0 AND equity_share_pct <= 100),
    effective_date DATE NOT NULL,
    maturity_terms TEXT,
    
    -- Property relationship
    property_asset_id UUID NOT NULL, -- References real estate asset
    
    -- Capital stack information
    first_mortgage_balance DECIMAL(15, 2),
    junior_liens_balance DECIMAL(15, 2),
    cltv_at_close DECIMAL(5, 2) CHECK (cltv_at_close >= 0 AND cltv_at_close <= 100),
    
    -- Valuation
    valuation_amount DECIMAL(15, 2) NOT NULL,
    valuation_method hei_valuation_method_enum NOT NULL,
    valuation_effective_date DATE NOT NULL,
    
    -- Recording information
    jurisdiction TEXT,
    instrument_number TEXT,
    book_page TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE,
    
    -- Funding information
    funding_method hei_funding_method_enum,
    destination_account_last4 VARCHAR(4),
    funded_at TIMESTAMP WITH TIME ZONE,
    
    -- External system tracking
    source_system TEXT NOT NULL,
    external_id TEXT,
    source_application_id TEXT NOT NULL,
    
    -- Servicing
    monitoring_policy TEXT,
    notification_contacts JSONB,
    
    -- Documentation
    hei_agreement_document_id UUID,
    deed_of_trust_document_id UUID,
    closing_disclosure_document_id UUID,
    title_document_id UUID,
    appraisal_document_id UUID,
    
    -- Status
    hei_status hei_status_enum NOT NULL DEFAULT 'active',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID,
    
    -- Constraints
    CONSTRAINT unique_source_application UNIQUE (source_system, source_application_id)
);
```

### recurring_income table
Royalties, patents, licensing, and other recurring income streams.

```sql
CREATE TABLE recurring_income (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Income identification
    income_type recurring_income_type_enum NOT NULL,
    income_source TEXT NOT NULL,
    
    -- Payer information
    payer_name TEXT,
    payer_contact_email_id UUID,
    payer_contact_phone_id UUID,
    payer_tax_id VARCHAR(20),
    
    -- Income details
    payment_amount DECIMAL(15, 2),
    payment_frequency payment_frequency_enum,
    annual_income_estimate DECIMAL(15, 2),
    
    -- Payment history
    last_payment_amount DECIMAL(15, 2),
    last_payment_date DATE,
    ytd_received DECIMAL(15, 2),
    lifetime_received DECIMAL(15, 2),
    
    -- Terms
    start_date DATE,
    end_date DATE,
    has_cola BOOLEAN DEFAULT FALSE, -- Cost of living adjustment
    cola_percentage DECIMAL(5, 2),
    
    -- Tax information
    is_taxable BOOLEAN DEFAULT TRUE,
    tax_rate DECIMAL(5, 2),
    
    -- Documentation
    agreement_document_id UUID,
    payment_statement_document_ids UUID[],
    
    -- Status
    income_status recurring_income_status_enum NOT NULL DEFAULT 'active',
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

## Physical Property Tables

### operational_property table
Vehicles, boats, equipment, machinery, and operational assets.

```sql
CREATE TABLE operational_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property classification
    property_type operational_property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Identification
    make TEXT,
    model TEXT,
    year INTEGER,
    vin_hull_serial TEXT,
    registration_number TEXT,
    registration_state VARCHAR(2),
    
    -- Specifications
    engine_details TEXT,
    mileage_hours INTEGER,
    fuel_type VARCHAR(50),
    transmission_type VARCHAR(50),
    color VARCHAR(50),
    
    -- Location and storage
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Garage", "Marina slip 42", etc.
    
    -- Insurance
    is_insured BOOLEAN DEFAULT FALSE,
    insurance_company TEXT,
    insurance_policy_number TEXT,
    insurance_contact_phone_id UUID,
    insurance_contact_email_id UUID,
    
    -- Operational details
    is_operational BOOLEAN DEFAULT TRUE,
    last_service_date DATE,
    next_service_due DATE,
    service_provider_contact_id UUID,
    
    -- Financial
    loan_balance DECIMAL(15, 2),
    loan_account_number TEXT,
    loan_institution TEXT,
    
    -- Documentation
    title_document_id UUID,
    registration_document_id UUID,
    service_records UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### personal_property table
Jewelry, art, collectibles, furniture, and personal belongings.

```sql
CREATE TABLE personal_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Property classification
    property_type personal_property_type_enum NOT NULL,
    property_subtype TEXT,
    
    -- Item details
    item_name TEXT NOT NULL,
    brand_manufacturer TEXT,
    model_style TEXT,
    serial_number TEXT,
    year_acquired INTEGER,
    
    -- Physical characteristics
    material_composition TEXT,
    dimensions TEXT,
    weight TEXT,
    color TEXT,
    condition_description TEXT,
    
    -- Location
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Master bedroom safe", "Living room", etc.
    
    -- Insurance
    is_insured BOOLEAN DEFAULT FALSE,
    insurance_company TEXT,
    insurance_policy_number TEXT,
    insurance_value DECIMAL(15, 2),
    insurance_contact_phone_id UUID,
    insurance_contact_email_id UUID,
    
    -- Documentation
    receipt_document_id UUID,
    appraisal_document_id UUID,
    photo_ids UUID[],
    certificate_of_authenticity_id UUID,
    
    -- Special handling (for pets)
    pet_name TEXT,
    pet_type pet_type_enum,
    pet_breed TEXT,
    pet_age INTEGER,
    pet_microchip_id VARCHAR(50),
    pet_care_instructions TEXT,
    pet_veterinarian_contact_id UUID,
    pet_care_status pet_care_status_enum,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### inventory table
Business inventory, fixtures, and stock.

```sql
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Inventory identification
    inventory_type TEXT NOT NULL,
    category TEXT,
    
    -- Quantities
    total_units INTEGER,
    unit_of_measure VARCHAR(50),
    units_per_package INTEGER DEFAULT 1,
    
    -- Valuation
    cost_per_unit DECIMAL(15, 2),
    total_cost DECIMAL(15, 2),
    market_value_per_unit DECIMAL(15, 2),
    total_market_value DECIMAL(15, 2),
    
    -- Location
    storage_address_id UUID,
    storage_location_detail TEXT, -- "Warehouse A, Shelf 3", etc.
    
    -- Supplier information
    supplier_name TEXT,
    supplier_contact_id UUID,
    supplier_email_id UUID,
    supplier_phone_id UUID,
    
    -- Documentation
    inventory_list_document_id UUID,
    purchase_orders UUID[],
    
    -- Status
    last_inventory_date DATE,
    next_inventory_date DATE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

## Business & Digital Assets

### ownership_interests table
Business ownership, partnerships, and franchise interests.

```sql
CREATE TABLE ownership_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Business identification
    entity_name TEXT NOT NULL,
    entity_type business_entity_type_enum NOT NULL,
    tax_id VARCHAR(20),
    state_of_formation VARCHAR(2),
    
    -- Ownership details
    ownership_type ownership_interest_type_enum NOT NULL,
    ownership_percentage DECIMAL(5, 2),
    number_of_shares INTEGER,
    share_class VARCHAR(50),
    
    -- Valuation
    initial_investment DECIMAL(15, 2),
    current_valuation DECIMAL(15, 2),
    valuation_date DATE,
    valuation_method TEXT,
    
    -- Business details
    business_description TEXT,
    industry TEXT,
    annual_revenue DECIMAL(15, 2),
    number_of_employees INTEGER,
    
    -- Management
    is_active_participant BOOLEAN DEFAULT FALSE,
    management_role TEXT,
    
    -- Distributions
    receives_distributions BOOLEAN DEFAULT FALSE,
    distribution_frequency payment_frequency_enum,
    last_distribution_amount DECIMAL(15, 2),
    last_distribution_date DATE,
    
    -- Key contacts
    primary_contact_name TEXT,
    primary_contact_title TEXT,
    primary_contact_email_id UUID,
    primary_contact_phone_id UUID,
    primary_contact_address_id UUID,
    
    -- Governance
    has_operating_agreement BOOLEAN DEFAULT FALSE,
    has_buy_sell_agreement BOOLEAN DEFAULT FALSE,
    
    -- Documentation
    formation_document_id UUID,
    operating_agreement_document_id UUID,
    financial_statements_document_ids UUID[],
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### digital_assets table
Intellectual property, digital assets, and intangible property.

```sql
CREATE TABLE digital_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Asset classification
    asset_type digital_asset_type_enum NOT NULL,
    asset_subtype TEXT,
    
    -- Digital asset details
    asset_name TEXT NOT NULL,
    asset_identifier TEXT, -- URL, wallet address, etc.
    platform_name TEXT,
    
    -- Access information
    access_url TEXT,
    username TEXT,
    recovery_email_id UUID,
    recovery_phone_id UUID,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    
    -- Intellectual property specific
    ip_type ip_type_enum,
    registration_number TEXT,
    registration_date DATE,
    expiration_date DATE,
    jurisdiction TEXT,
    
    -- Crypto specific
    wallet_type VARCHAR(50), -- hot, cold, exchange
    blockchain VARCHAR(50),
    wallet_address TEXT,
    approximate_balance DECIMAL(20, 8),
    balance_as_of_date DATE,
    
    -- Documentation
    backup_codes_document_id UUID,
    registration_document_id UUID,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    renewal_required BOOLEAN DEFAULT FALSE,
    auto_renew_enabled BOOLEAN DEFAULT FALSE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

## Legal Document Assets

### trusts table
Trust documents and agreements.

```sql
CREATE TABLE trusts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Trust identification
    trust_name TEXT NOT NULL,
    trust_type trust_type_enum NOT NULL,
    tax_id VARCHAR(20),
    
    -- Parties
    grantor_persona_id UUID NOT NULL,
    grantor_name TEXT NOT NULL,
    
    -- Primary Trustee
    trustee_persona_id UUID,
    trustee_name TEXT NOT NULL,
    trustee_email_id UUID,
    trustee_phone_id UUID,
    
    -- Successor Trustees (up to 2)
    successor_trustee_1_persona_id UUID,
    successor_trustee_1_name TEXT,
    successor_trustee_2_persona_id UUID,
    successor_trustee_2_name TEXT,
    
    -- Trust details
    execution_date DATE NOT NULL,
    effective_date DATE,
    termination_date DATE,
    state_of_formation VARCHAR(2),
    
    -- Trust provisions
    distribution_provisions TEXT,
    special_provisions TEXT,
    amendment_provisions TEXT,
    
    -- Financial details
    initial_funding_amount DECIMAL(15, 2),
    current_value DECIMAL(15, 2),
    value_as_of_date DATE,
    
    -- Document references
    trust_document_id UUID,
    amendments UUID[],
    
    -- Status
    is_funded BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### wills table
Will documents and testament information.

```sql
CREATE TABLE wills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Testator information
    testator_persona_id UUID NOT NULL,
    testator_name TEXT NOT NULL,
    
    -- Executor information
    executor_persona_id UUID,
    executor_name TEXT NOT NULL,
    executor_email_id UUID,
    executor_phone_id UUID,
    
    -- Successor Executors (up to 2)
    successor_executor_1_persona_id UUID,
    successor_executor_1_name TEXT,
    successor_executor_2_persona_id UUID,
    successor_executor_2_name TEXT,
    
    -- Will details
    will_type TEXT DEFAULT 'Last Will and Testament',
    execution_date DATE NOT NULL,
    
    -- Legal details
    state_of_execution VARCHAR(2) NOT NULL,
    county_of_execution TEXT,
    
    -- Witnesses
    witness_1_name TEXT,
    witness_2_name TEXT,
    notarized BOOLEAN DEFAULT FALSE,
    self_proving BOOLEAN DEFAULT FALSE,
    
    -- Will provisions
    guardian_provisions TEXT,
    distribution_provisions TEXT,
    special_bequests TEXT,
    residuary_clause TEXT,
    
    -- Codicils and amendments
    has_codicils BOOLEAN DEFAULT FALSE,
    codicil_dates DATE[],
    codicil_documents UUID[],
    
    -- Document storage
    original_location TEXT,
    copies_location TEXT,
    will_document_id UUID,
    
    -- Status
    is_current BOOLEAN DEFAULT TRUE,
    revoked_date DATE,
    revocation_method TEXT,
    superseded_by_will_id UUID,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

### personal_directives table
Healthcare directives, power of attorney, and personal directives.

```sql
CREATE TABLE personal_directives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL UNIQUE,
    
    -- Directive details
    directive_type directive_type_enum NOT NULL,
    directive_subtype TEXT,
    
    -- Principal information
    principal_persona_id UUID NOT NULL,
    principal_name VARCHAR(255) NOT NULL,
    
    -- Agent information
    agent_persona_id UUID,
    agent_name TEXT NOT NULL,
    agent_email_id UUID,
    agent_phone_id UUID,
    
    -- Successor Agents (up to 2)
    successor_agent_1_persona_id UUID,
    successor_agent_1_name TEXT,
    successor_agent_2_persona_id UUID,
    successor_agent_2_name TEXT,
    
    -- Legal details
    execution_date DATE NOT NULL,
    effective_date DATE,
    state_of_execution VARCHAR(2),
    
    -- Powers and limitations
    powers_granted TEXT,
    powers_excluded TEXT,
    special_instructions TEXT,
    
    -- Healthcare-specific
    life_support_preferences TEXT,
    treatment_preferences TEXT,
    organ_donation_preferences TEXT,
    
    -- HIPAA authorization
    has_hipaa_authorization BOOLEAN DEFAULT FALSE,
    hipaa_authorized_persons TEXT,
    
    -- Document references
    directive_document_id UUID,
    supporting_documents UUID[],
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    revoked_date DATE,
    revocation_method TEXT,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
    created_by UUID,
    updated_by UUID
);
```

## Asset Relationships

### Address Relationships
Real estate assets connect to physical addresses through the `usage_address` junction table:

```sql
-- Real estate properties link to addresses
real_estate → assets → usage_address ← address
```

### Document Relationships
All asset types can have associated documents:

```sql
-- Documents linked to assets through personas
assets → asset_persona → personas → documents
```

### Ownership Chain
The complete ownership relationship:

```sql
-- Full ownership chain
tenants → users → personas → asset_persona → assets → [specialized_asset_table]
```

## Data Integrity & Constraints

### Foreign Key Constraints
```sql
-- Ensure referential integrity
ALTER TABLE assets ADD CONSTRAINT fk_assets_category 
    FOREIGN KEY (category_id) REFERENCES asset_categories(id);

-- Cascade deletes for specialized tables
ALTER TABLE real_estate ADD CONSTRAINT fk_real_estate_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE;
```

### Check Constraints
```sql
-- Ownership percentage validation
ALTER TABLE asset_persona ADD CONSTRAINT chk_ownership_percentage 
    CHECK (ownership_percentage > 0 AND ownership_percentage <= 100);

-- Positive values only
ALTER TABLE assets ADD CONSTRAINT chk_estimated_value 
    CHECK (estimated_value IS NULL OR estimated_value >= 0);
```

### Unique Constraints
```sql
-- Prevent duplicate ownership records
ALTER TABLE asset_persona ADD CONSTRAINT uq_asset_persona_ownership 
    UNIQUE (asset_id, persona_id, ownership_type);
```

### Business Rules
1. **Total Ownership**: Sum of ownership percentages per asset cannot exceed 100%
2. **Active Status**: Only active assets can have new ownership assignments
3. **Category Consistency**: Specialized tables must match their asset's category
4. **Tenant Isolation**: All asset operations scoped to tenant
5. **Audit Trail**: All changes logged with user and timestamp information

---

*This documentation covers the comprehensive asset management system that enables families to track, value, and plan the inheritance of their diverse asset portfolios through the Forward Inheritance Platform.*