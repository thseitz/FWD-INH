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

The Forward Inheritance Platform's asset management system is built around **15 specialized tables** that handle the diverse range of assets families need to track for inheritance planning. The system supports everything from real estate and financial accounts to digital assets and legal documents.

### Asset Management Architecture
- **Base Asset Table**: Common properties for all assets
- **Asset Categories**: 13 predefined categories matching business requirements
- **Specialized Tables**: One table per asset category for specific attributes
- **Ownership Junction**: Flexible persona-asset ownership relationships
- **Inheritance Model**: Clear inheritance chains from base to specialized tables

### Key Statistics
- **Total Tables**: 15 (1 base + 1 junction + 13 category tables)
- **Asset Categories**: 13 predefined categories with extensible metadata
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
└── recurring_income
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
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Valuation
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    last_valued_date DATE,
    
    -- Metadata
    tags JSONB DEFAULT '[]',
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

**Key Features:**
- **Universal Properties**: All assets share name, description, value, currency
- **Category Reference**: Links to predefined asset categories
- **Flexible Valuation**: Supports multi-currency with historical valuation dates
- **Tagging System**: JSONB array for flexible categorization and search
- **Extensible Metadata**: Future-proof design for evolving requirements

### asset_categories table
Defines the 13 predefined asset categories that drive the specialized table structure.

```sql
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
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
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    persona_id UUID NOT NULL REFERENCES personas(id) ON DELETE CASCADE,
    
    -- Ownership details
    ownership_type ownership_type_enum NOT NULL DEFAULT 'owner',
    ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    
    -- Additional info
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
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
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Property details
    property_type property_type_enum NOT NULL,
    property_use property_use_enum NOT NULL,
    year_built INTEGER,
    square_footage INTEGER,
    lot_size_acres DECIMAL(10,4),
    
    -- Valuation
    purchase_price DECIMAL(15,2),
    purchase_date DATE,
    current_market_value DECIMAL(15,2),
    last_appraisal_date DATE,
    
    -- Financial details
    annual_property_tax DECIMAL(12,2),
    annual_insurance DECIMAL(12,2),
    monthly_hoa_fee DECIMAL(8,2),
    
    -- Legal
    deed_type VARCHAR(100),
    parcel_number VARCHAR(100),
    
    -- Rental information
    is_rental_property BOOLEAN DEFAULT false,
    monthly_rental_income DECIMAL(10,2),
    
    -- Status
    is_primary_residence BOOLEAN DEFAULT false,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### financial_accounts table
Bank accounts, investment accounts, and retirement accounts.

```sql
CREATE TABLE financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Account details
    account_type account_type_enum NOT NULL,
    institution_name VARCHAR(200) NOT NULL,
    account_number_encrypted TEXT, -- Encrypted account number
    routing_number_encrypted TEXT, -- Encrypted routing number
    
    -- Balances
    current_balance DECIMAL(15,2),
    available_balance DECIMAL(15,2),
    last_updated_balance DATE,
    
    -- Investment details (for investment accounts)
    investment_type VARCHAR(100),
    risk_level VARCHAR(50),
    
    -- Retirement details (for retirement accounts)
    contribution_limit DECIMAL(12,2),
    employer_match_percentage DECIMAL(5,2),
    vesting_schedule TEXT,
    
    -- Interest/Returns
    interest_rate DECIMAL(7,4),
    annual_fee DECIMAL(8,2),
    
    -- Status
    is_joint_account BOOLEAN DEFAULT false,
    account_status VARCHAR(50) DEFAULT 'active',
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### life_insurance table
Life insurance policies including term, whole, universal, and variable life.

```sql
CREATE TABLE life_insurance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Policy details
    insurance_type insurance_type_enum NOT NULL,
    policy_number VARCHAR(100) NOT NULL,
    insurance_company VARCHAR(200) NOT NULL,
    
    -- Coverage
    death_benefit DECIMAL(15,2) NOT NULL,
    cash_value DECIMAL(15,2),
    
    -- Premiums
    annual_premium DECIMAL(12,2),
    premium_frequency VARCHAR(20), -- monthly, quarterly, annually
    
    -- Dates
    policy_start_date DATE NOT NULL,
    policy_end_date DATE,
    
    -- Beneficiaries (stored as JSONB for flexibility)
    primary_beneficiaries JSONB DEFAULT '[]',
    contingent_beneficiaries JSONB DEFAULT '[]',
    
    -- Policy details
    is_term_policy BOOLEAN NOT NULL,
    term_length_years INTEGER,
    
    -- Status
    policy_status VARCHAR(50) DEFAULT 'active',
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### loans table
All loan-related assets including mortgages, personal loans, and interfamily loans.

```sql
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Loan details
    loan_type loan_type_enum NOT NULL,
    lender_name VARCHAR(200),
    loan_number VARCHAR(100),
    
    -- Financial details
    original_loan_amount DECIMAL(15,2) NOT NULL,
    current_balance DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(7,4) NOT NULL,
    
    -- Terms
    loan_term_months INTEGER NOT NULL,
    monthly_payment DECIMAL(10,2),
    
    -- Dates
    origination_date DATE NOT NULL,
    maturity_date DATE NOT NULL,
    first_payment_date DATE,
    
    -- Status
    loan_status VARCHAR(50) DEFAULT 'active',
    is_secured BOOLEAN DEFAULT false,
    collateral_description TEXT,
    
    -- For interfamily loans
    is_interfamily_loan BOOLEAN DEFAULT false,
    family_member_persona_id UUID REFERENCES personas(id),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### recurring_income table
Royalties, patents, licensing, and other recurring income streams.

```sql
CREATE TABLE recurring_income (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Income source details
    income_type VARCHAR(100) NOT NULL, -- royalty, patent, licensing, rental, etc.
    source_name VARCHAR(200) NOT NULL,
    
    -- Financial details
    monthly_income DECIMAL(10,2),
    annual_income DECIMAL(12,2),
    last_payment_amount DECIMAL(10,2),
    last_payment_date DATE,
    
    -- Terms
    income_start_date DATE,
    income_end_date DATE, -- NULL for indefinite
    payment_frequency VARCHAR(20), -- monthly, quarterly, annually
    
    -- Legal details
    contract_number VARCHAR(100),
    contract_expiry_date DATE,
    
    -- Status
    is_guaranteed BOOLEAN DEFAULT false,
    income_status VARCHAR(50) DEFAULT 'active',
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

## Physical Property Tables

### operational_property table
Vehicles, boats, equipment, machinery, and operational assets.

```sql
CREATE TABLE operational_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Property details
    property_subtype VARCHAR(100) NOT NULL, -- vehicle, boat, equipment, machinery
    make VARCHAR(100),
    model VARCHAR(100),
    year INTEGER,
    
    -- Identification
    serial_number VARCHAR(200),
    vin_number VARCHAR(100), -- For vehicles
    registration_number VARCHAR(100),
    
    -- Valuation
    purchase_price DECIMAL(15,2),
    purchase_date DATE,
    current_market_value DECIMAL(15,2),
    
    -- Condition
    condition_rating VARCHAR(50), -- excellent, good, fair, poor
    mileage INTEGER, -- For vehicles
    last_service_date DATE,
    
    -- Insurance
    insurance_company VARCHAR(200),
    policy_number VARCHAR(100),
    annual_insurance_cost DECIMAL(8,2),
    
    -- Status
    is_operational BOOLEAN DEFAULT true,
    location_description VARCHAR(500),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### personal_property table
Jewelry, art, collectibles, furniture, and personal belongings.

```sql
CREATE TABLE personal_property (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Property details
    property_subtype VARCHAR(100) NOT NULL, -- jewelry, art, collectible, furniture, etc.
    brand VARCHAR(100),
    model VARCHAR(100),
    
    -- Identification
    serial_number VARCHAR(200),
    certificate_number VARCHAR(100),
    
    -- Valuation
    purchase_price DECIMAL(15,2),
    purchase_date DATE,
    appraised_value DECIMAL(15,2),
    last_appraisal_date DATE,
    
    -- Physical details
    condition_rating VARCHAR(50), -- mint, excellent, good, fair, poor
    weight DECIMAL(10,4),
    dimensions VARCHAR(200),
    material VARCHAR(200),
    
    -- Provenance
    acquisition_method VARCHAR(100), -- purchased, inherited, gift
    provenance_notes TEXT,
    
    -- Storage
    storage_location VARCHAR(500),
    is_insured BOOLEAN DEFAULT false,
    insurance_value DECIMAL(15,2),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### inventory table
Business inventory, fixtures, and stock.

```sql
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Inventory details
    inventory_type VARCHAR(100) NOT NULL, -- raw_materials, finished_goods, fixtures
    category VARCHAR(100),
    sku VARCHAR(100),
    
    -- Quantities
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    unit_of_measure VARCHAR(50),
    
    -- Valuation
    unit_cost DECIMAL(10,4),
    total_value DECIMAL(15,2),
    last_inventory_date DATE,
    
    -- Location
    warehouse_location VARCHAR(200),
    bin_location VARCHAR(100),
    
    -- Status
    inventory_status VARCHAR(50) DEFAULT 'active',
    minimum_stock_level INTEGER,
    reorder_point INTEGER,
    
    -- Supplier
    primary_supplier VARCHAR(200),
    supplier_part_number VARCHAR(100),
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

## Business & Digital Assets

### business_interests table
Business ownership, partnerships, and franchise interests.

```sql
CREATE TABLE business_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Business details
    business_name VARCHAR(200) NOT NULL,
    business_type VARCHAR(100), -- corporation, LLC, partnership, sole_proprietorship
    industry VARCHAR(100),
    
    -- Ownership
    ownership_percentage DECIMAL(5,2) NOT NULL,
    number_of_shares INTEGER,
    share_class VARCHAR(50),
    
    -- Identification
    ein VARCHAR(20), -- Employer Identification Number
    business_registration_number VARCHAR(100),
    
    -- Valuation
    book_value DECIMAL(15,2),
    market_value DECIMAL(15,2),
    last_valuation_date DATE,
    
    -- Financial performance
    annual_revenue DECIMAL(15,2),
    annual_profit DECIMAL(15,2),
    last_financial_year INTEGER,
    
    -- Management
    is_active_management BOOLEAN DEFAULT false,
    management_role VARCHAR(100),
    
    -- Legal
    voting_rights BOOLEAN DEFAULT true,
    transfer_restrictions TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### digital_assets table
Intellectual property, digital assets, and intangible property.

```sql
CREATE TABLE digital_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Asset details
    digital_asset_type VARCHAR(100) NOT NULL, -- patent, trademark, copyright, domain, software
    asset_name VARCHAR(200) NOT NULL,
    
    -- Legal protection
    registration_number VARCHAR(100),
    registration_date DATE,
    expiry_date DATE,
    
    -- Valuation
    development_cost DECIMAL(15,2),
    licensing_value DECIMAL(15,2),
    annual_licensing_income DECIMAL(12,2),
    
    -- Technical details
    technology_description TEXT,
    current_version VARCHAR(50),
    
    -- Legal status
    protection_status VARCHAR(100), -- registered, pending, expired
    protection_jurisdiction VARCHAR(100),
    
    -- Commercial details
    is_licensed BOOLEAN DEFAULT false,
    licensing_terms TEXT,
    
    -- Access details
    access_credentials_encrypted TEXT, -- For digital accounts, domains, etc.
    recovery_information_encrypted TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

## Legal Document Assets

### trusts table
Trust documents and agreements.

```sql
CREATE TABLE trusts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Trust details
    trust_type trust_type_enum NOT NULL,
    trust_name VARCHAR(200) NOT NULL,
    
    -- Parties
    grantor_persona_id UUID REFERENCES personas(id),
    trustee_persona_ids JSONB DEFAULT '[]', -- Array of persona IDs
    beneficiary_persona_ids JSONB DEFAULT '[]', -- Array of persona IDs
    
    -- Legal details
    trust_agreement_date DATE NOT NULL,
    governing_law_state VARCHAR(50),
    
    -- Financial
    initial_funding_amount DECIMAL(15,2),
    current_value DECIMAL(15,2),
    last_valuation_date DATE,
    
    -- Status
    trust_status VARCHAR(50) DEFAULT 'active', -- active, terminated, pending
    
    -- Document storage
    trust_document_id UUID REFERENCES media_storage(id),
    
    -- Terms
    distribution_terms TEXT,
    termination_conditions TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### wills table
Will documents and testament information.

```sql
CREATE TABLE wills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Will details
    will_type VARCHAR(100) NOT NULL, -- simple, pour_over, living, etc.
    testator_persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Legal details
    execution_date DATE NOT NULL,
    governing_law_state VARCHAR(50),
    
    -- Witnesses and notarization
    witness_count INTEGER DEFAULT 0,
    is_notarized BOOLEAN DEFAULT false,
    notary_details JSONB,
    
    -- Status
    will_status VARCHAR(50) DEFAULT 'active', -- active, revoked, superseded
    supersedes_will_id UUID REFERENCES wills(id),
    
    -- Document storage
    will_document_id UUID REFERENCES media_storage(id),
    
    -- Executor information
    primary_executor_persona_id UUID REFERENCES personas(id),
    alternate_executor_persona_ids JSONB DEFAULT '[]',
    
    -- Key provisions
    has_specific_bequests BOOLEAN DEFAULT false,
    has_residuary_clause BOOLEAN DEFAULT true,
    guardian_provisions TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
);
```

### personal_directives table
Healthcare directives, power of attorney, and personal directives.

```sql
CREATE TABLE personal_directives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    
    -- Directive details
    directive_type directive_type_enum NOT NULL,
    principal_persona_id UUID NOT NULL REFERENCES personas(id),
    
    -- Legal details
    execution_date DATE NOT NULL,
    effective_date DATE,
    expiry_date DATE,
    governing_law_state VARCHAR(50),
    
    -- Agent/Representative information
    primary_agent_persona_id UUID REFERENCES personas(id),
    alternate_agent_persona_ids JSONB DEFAULT '[]',
    
    -- Powers and limitations
    powers_granted TEXT,
    limitations TEXT,
    special_instructions TEXT,
    
    -- Medical directives specific
    life_support_wishes TEXT,
    organ_donation_wishes TEXT,
    funeral_arrangements TEXT,
    
    -- Status
    directive_status directive_status_enum DEFAULT 'active',
    
    -- Document storage
    directive_document_id UUID REFERENCES media_storage(id),
    
    -- HIPAA authorization
    hipaa_authorization BOOLEAN DEFAULT false,
    authorized_persons JSONB DEFAULT '[]',
    
    -- Metadata
    metadata JSONB DEFAULT '{}'
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