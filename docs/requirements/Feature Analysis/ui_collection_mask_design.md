# UI Collection Mask Design

## Purpose

The `ui_collection_mask` system defines which fields from a database
table should be collected by the UI, whether they are **mandatory** or
**optional**, and what **field type** they represent.

This provides a central, static configuration that front-end code can
query to know how to render forms.

------------------------------------------------------------------------

## Enums

### Requirement

``` sql
CREATE TYPE collection_requirement AS ENUM ('mandatory', 'optional');
```

### Field Type

``` sql
CREATE TYPE ui_field_type AS ENUM ('text','int','real','phone','zip','email','date','year','currency','currency_code','enum');
```

------------------------------------------------------------------------

## Tables

### 1. Entity Table

Maps a logical entity code to a physical table name.

``` sql
CREATE TABLE ui_entity (
  entity_code   text PRIMARY KEY,    -- short identifier, e.g. 'users'
  table_name    text NOT NULL UNIQUE -- actual table name in DB
);
```

-   Each `entity_code` is stable for UI logic.
-   Each `table_name` must be unique across the system.
-   Schema is not stored; all tables are assumed to be in the default
    schema (`public`).

------------------------------------------------------------------------

### 2. Mask Table

Defines the UI mask for columns of a table.

``` sql
CREATE TABLE ui_collection_mask (
  entity_code   text NOT NULL REFERENCES ui_entity(entity_code) ON DELETE CASCADE,
  column_name   text NOT NULL,
  requirement   collection_requirement NOT NULL,
  field_type    ui_field_type NOT NULL,
  display_order int NOT NULL,
  note          text,
  PRIMARY KEY (entity_code, column_name),
  CONSTRAINT ui_collection_mask_order_uniq
    UNIQUE (entity_code, display_order) DEFERRABLE INITIALLY IMMEDIATE
);
```

-   Each row corresponds to one column in one entity.
-   `display_order` controls how fields are ordered in the UI.
-   The unique constraint ensures no duplicate order within an entity.

------------------------------------------------------------------------

## Queries

### Get mask by table name

``` sql
SELECT 
  e.table_name,
  m.column_name,
  m.requirement::text   AS requirement,
  m.field_type::text    AS field_type,
  m.display_order,
  m.note
FROM ui_entity e
JOIN ui_collection_mask m USING (entity_code)
WHERE e.table_name = $1
ORDER BY m.display_order;
```

### Get mask by entity code

``` sql
SELECT 
  e.entity_code,
  e.table_name,
  m.column_name,
  m.requirement::text   AS requirement,
  m.field_type::text    AS field_type,
  m.display_order,
  m.note
FROM ui_entity e
JOIN ui_collection_mask m USING (entity_code)
WHERE e.entity_code = $1
ORDER BY m.display_order;
```

------------------------------------------------------------------------
### Seed mask

``` sql
-- First, insert entity mappings for all asset tables
INSERT INTO ui_entity (entity_code, table_name) VALUES
  ('ASSETS', 'assets'),
  ('DIRECTIVES', 'personal_directives'),
  ('TRUSTS', 'trusts'),
  ('WILLS', 'wills'),
  ('PERSONAL', 'personal_property'),
  ('OPERATIONAL', 'operational_property'),
  ('INVENTORY', 'inventory'),
  ('REALESTATE', 'real_estate'),
  ('INSURANCE', 'life_insurance'),
  ('ACCOUNTS', 'financial_accounts'),
  ('INCOME', 'recurring_income'),
  ('DIGITAL', 'digital_assets'),
  ('INTERESTS', 'ownership_interests'),
  ('LOANS', 'loans')
ON CONFLICT DO NOTHING;

-- Main Assets Table UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('ASSETS', 'name', 'mandatory', 'text', 1, 'Asset name/title'),
  ('ASSETS', 'description', 'mandatory', 'text', 2, 'Asset description'),
  ('ASSETS', 'estimated_value', 'mandatory', 'currency', 3, 'Current estimated value'),
  ('ASSETS', 'currency_code', 'mandatory', 'currency_code', 4, 'Currency (USD, EUR, etc)'),
  ('ASSETS', 'last_valued_date', 'mandatory', 'date', 5, 'Date of valuation');

-- Personal Directives UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('DIRECTIVES', 'directive_type', 'mandatory', 'enum', 1, 'power_of_attorney|healthcare_directive|living_will|hipaa_authorization|guardianship_designation|family_directive'),
  ('DIRECTIVES', 'directive_subtype', 'mandatory', 'text', 2, 'Specific directive subtype'),
  ('DIRECTIVES', 'agent_name', 'mandatory', 'text', 3, 'Agent/representative name'),
  ('DIRECTIVES', 'agent_email_address', 'mandatory', 'email', 4, 'Agent email contact (normalized)'),
  ('DIRECTIVES', 'agent_phone_number', 'mandatory', 'phone', 5, 'Agent phone contact (normalized)'),
  ('DIRECTIVES', 'successor_agent_1_name', 'mandatory', 'text', 6, 'First successor agent'),
  ('DIRECTIVES', 'healthcare_wishes', 'mandatory', 'text', 7, 'Healthcare preferences'),
  ('DIRECTIVES', 'life_support_preferences', 'mandatory', 'text', 8, 'Life support decisions'),
  ('DIRECTIVES', 'execution_date', 'mandatory', 'date', 9, 'Document execution date'),
  ('DIRECTIVES', 'state_of_execution', 'mandatory', 'text', 10, 'State where executed'),
  ('DIRECTIVES', 'notarized', 'mandatory', 'enum', 11, 'yes|no'),
  ('DIRECTIVES', 'witnesses', 'mandatory', 'int', 12, 'Number of witnesses');

-- Trusts UI Mask  
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('TRUSTS', 'trust_type', 'mandatory', 'enum', 1, 'revocable|irrevocable|living|testamentary|charitable|special_needs|generation_skipping|asset_protection'),
  ('TRUSTS', 'trust_name', 'mandatory', 'text', 2, 'Official trust name'),
  ('TRUSTS', 'grantor_name', 'mandatory', 'text', 3, 'Trust grantor/settlor'),
  ('TRUSTS', 'trustee_name', 'mandatory', 'text', 4, 'Current trustee name'),
  ('TRUSTS', 'trustee_email_address', 'mandatory', 'email', 5, 'Trustee email contact (normalized)'),
  ('TRUSTS', 'trustee_phone_number', 'mandatory', 'phone', 6, 'Trustee phone contact (normalized)'),
  ('TRUSTS', 'successor_trustee_name', 'mandatory', 'text', 7, 'Successor trustee'),
  ('TRUSTS', 'establishment_date', 'mandatory', 'date', 8, 'Trust creation date'),
  ('TRUSTS', 'state_of_establishment', 'mandatory', 'text', 9, 'Governing state law'),
  ('TRUSTS', 'trust_purpose', 'mandatory', 'text', 10, 'Purpose/objectives');

-- Wills UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('WILLS', 'will_type', 'mandatory', 'enum', 1, 'primary|secondary|codicil|holographic|joint'),
  ('WILLS', 'testator_name', 'mandatory', 'text', 2, 'Person making the will'),
  ('WILLS', 'executor_name', 'mandatory', 'text', 3, 'Primary executor name'),
  ('WILLS', 'executor_email_address', 'mandatory', 'email', 4, 'Executor email contact (normalized)'),
  ('WILLS', 'executor_phone_number', 'mandatory', 'phone', 5, 'Executor phone contact (normalized)'),
  ('WILLS', 'successor_executor_name', 'mandatory', 'text', 6, 'Backup executor'),
  ('WILLS', 'execution_date', 'mandatory', 'date', 7, 'Will signing date'),
  ('WILLS', 'state_of_execution', 'mandatory', 'text', 8, 'State where executed'),
  ('WILLS', 'witnesses', 'mandatory', 'int', 9, 'Number of witnesses'),
  ('WILLS', 'notarized', 'mandatory', 'enum', 10, 'yes|no');

-- Personal Property UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('PERSONAL', 'property_type', 'mandatory', 'enum', 1, 'jewelry|precious_metals|collectibles|art|furniture|pets_animals|books|clothing|electronics'),
  ('PERSONAL', 'property_subtype', 'mandatory', 'text', 2, 'Specific item category'),
  ('PERSONAL', 'item_name', 'mandatory', 'text', 3, 'Specific item name'),
  ('PERSONAL', 'brand_manufacturer', 'mandatory', 'text', 4, 'Brand or maker'),
  ('PERSONAL', 'model_style', 'mandatory', 'text', 5, 'Model or style info'),
  ('PERSONAL', 'material_composition', 'mandatory', 'text', 6, 'Materials used'),
  ('PERSONAL', 'dimensions', 'mandatory', 'text', 7, 'Size/dimensions'),
  ('PERSONAL', 'weight', 'mandatory', 'real', 8, 'Weight if applicable'),
  ('PERSONAL', 'purchase_date', 'mandatory', 'date', 9, 'Date acquired'),
  ('PERSONAL', 'purchase_price', 'mandatory', 'currency', 10, 'Original purchase price'),
  ('PERSONAL', 'current_location_address', 'mandatory', 'text', 11, 'Where item is kept (normalized)');

-- Operational Property UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('OPERATIONAL', 'property_type', 'mandatory', 'enum', 1, 'vehicle|boat|aircraft|equipment|machinery|tools'),
  ('OPERATIONAL', 'property_subtype', 'mandatory', 'text', 2, 'Specific type'),
  ('OPERATIONAL', 'make', 'mandatory', 'text', 3, 'Manufacturer/brand'),
  ('OPERATIONAL', 'model', 'mandatory', 'text', 4, 'Model name/number'),
  ('OPERATIONAL', 'year', 'mandatory', 'year', 5, 'Year manufactured'),
  ('OPERATIONAL', 'vin_serial_number', 'mandatory', 'text', 6, 'VIN or serial number'),
  ('OPERATIONAL', 'registration_number', 'mandatory', 'text', 7, 'License/registration'),
  ('OPERATIONAL', 'condition', 'mandatory', 'enum', 8, 'excellent|very_good|good|fair|poor'),
  ('OPERATIONAL', 'mileage_hours', 'mandatory', 'int', 9, 'Usage measurement'),
  ('OPERATIONAL', 'purchase_date', 'mandatory', 'date', 10, 'Date acquired'),
  ('OPERATIONAL', 'purchase_price', 'mandatory', 'currency', 11, 'Original cost');

-- Inventory UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INVENTORY', 'inventory_type', 'mandatory', 'enum', 1, 'business_stock|collections|commodities|raw_materials|finished_goods'),
  ('INVENTORY', 'inventory_subtype', 'mandatory', 'text', 2, 'Specific inventory category'),
  ('INVENTORY', 'item_description', 'mandatory', 'text', 3, 'Detailed description'),
  ('INVENTORY', 'quantity', 'mandatory', 'int', 4, 'Number of items'),
  ('INVENTORY', 'unit_of_measure', 'mandatory', 'enum', 5, 'each|pounds|kilograms|tons|gallons|liters|cubic_feet'),
  ('INVENTORY', 'cost_per_unit', 'mandatory', 'currency', 6, 'Cost per unit'),
  ('INVENTORY', 'market_value_per_unit', 'mandatory', 'currency', 7, 'Current market value per unit'),
  ('INVENTORY', 'storage_location_address', 'mandatory', 'text', 8, 'Where inventory is stored (normalized)'),
  ('INVENTORY', 'condition', 'mandatory', 'enum', 9, 'excellent|good|fair|poor|damaged'),
  ('INVENTORY', 'last_inventory_date', 'mandatory', 'date', 10, 'Last physical count');

-- Real Estate UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('REALESTATE', 'property_type', 'mandatory', 'enum', 1, 'primary_residence|investment_property|commercial|vacant_land|rental_property'),
  ('REALESTATE', 'property_subtype', 'mandatory', 'text', 2, 'Specific property type'),
  ('REALESTATE', 'address_line_1', 'mandatory', 'text', 3, 'Property street address (normalized)'),
  ('REALESTATE', 'address_line_2', 'mandatory', 'text', 4, 'Address line 2 (normalized)'),
  ('REALESTATE', 'city', 'mandatory', 'text', 5, 'City (normalized)'),
  ('REALESTATE', 'state_province', 'mandatory', 'text', 6, 'State/Province (normalized)'),
  ('REALESTATE', 'postal_code', 'mandatory', 'zip', 7, 'ZIP/Postal code (normalized)'),
  ('REALESTATE', 'country', 'mandatory', 'text', 8, 'Country (normalized)'),
  ('REALESTATE', 'parcel_number', 'mandatory', 'text', 9, 'Tax parcel number'),
  ('REALESTATE', 'lot_size_acres', 'mandatory', 'real', 10, 'Lot size in acres'),
  ('REALESTATE', 'building_size_sqft', 'mandatory', 'int', 11, 'Building square footage'),
  ('REALESTATE', 'bedrooms', 'mandatory', 'int', 12, 'Number of bedrooms'),
  ('REALESTATE', 'bathrooms', 'mandatory', 'real', 13, 'Number of bathrooms'),
  ('REALESTATE', 'year_built', 'mandatory', 'year', 14, 'Year constructed'),
  ('REALESTATE', 'ownership_type', 'mandatory', 'enum', 15, 'fee_simple|leasehold|life_estate|joint_tenancy|tenancy_in_common');

-- Life Insurance UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INSURANCE', 'policy_type', 'mandatory', 'enum', 1, 'term|whole_life|universal|variable|variable_universal'),
  ('INSURANCE', 'insurance_company', 'mandatory', 'text', 2, 'Insurance company name'),
  ('INSURANCE', 'policy_number', 'mandatory', 'text', 3, 'Policy number'),
  ('INSURANCE', 'insured_name', 'mandatory', 'text', 4, 'Insured person name'),
  ('INSURANCE', 'beneficiary_primary', 'mandatory', 'text', 5, 'Primary beneficiary'),
  ('INSURANCE', 'beneficiary_contingent', 'mandatory', 'text', 6, 'Contingent beneficiary'),
  ('INSURANCE', 'coverage_amount', 'mandatory', 'currency', 7, 'Death benefit amount'),
  ('INSURANCE', 'annual_premium', 'mandatory', 'currency', 8, 'Annual premium cost'),
  ('INSURANCE', 'policy_start_date', 'mandatory', 'date', 9, 'Policy effective date'),
  ('INSURANCE', 'premium_payment_frequency', 'mandatory', 'enum', 10, 'monthly|quarterly|semi_annually|annually'),
  ('INSURANCE', 'agent_name', 'mandatory', 'text', 11, 'Insurance agent name'),
  ('INSURANCE', 'agent_email_address', 'mandatory', 'email', 12, 'Agent email contact (normalized)'),
  ('INSURANCE', 'agent_phone_number', 'mandatory', 'phone', 13, 'Agent phone contact (normalized)');

-- Financial Accounts UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('ACCOUNTS', 'institution_name', 'mandatory', 'text', 1, 'Bank/Financial institution'),
  ('ACCOUNTS', 'account_type', 'mandatory', 'enum', 2, 'checking|savings|money_market|cd|investment|retirement|college_savings'),
  ('ACCOUNTS', 'account_number_last_four', 'mandatory', 'text', 3, 'Last 4 digits of account'),
  ('ACCOUNTS', 'routing_number_last_four', 'mandatory', 'text', 4, 'Last 4 digits of routing'),
  ('ACCOUNTS', 'account_title', 'mandatory', 'text', 5, 'Account title/name'),
  ('ACCOUNTS', 'date_opened', 'mandatory', 'date', 6, 'Account opening date'),
  ('ACCOUNTS', 'current_balance', 'mandatory', 'currency', 7, 'Current account balance'),
  ('ACCOUNTS', 'balance_as_of_date', 'mandatory', 'date', 8, 'Balance date'),
  ('ACCOUNTS', 'institution_contact_email_address', 'mandatory', 'email', 9, 'Institution email contact (normalized)'),
  ('ACCOUNTS', 'institution_contact_phone_number', 'mandatory', 'phone', 10, 'Institution phone contact (normalized)');

-- Recurring Income UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INCOME', 'income_type', 'mandatory', 'enum', 1, 'royalties|pension|rental_income|social_security|dividends|interest|annuity'),
  ('INCOME', 'income_source', 'mandatory', 'text', 2, 'Source description'),
  ('INCOME', 'payer_name', 'mandatory', 'text', 3, 'Who pays the income'),
  ('INCOME', 'payer_address_line_1', 'mandatory', 'text', 4, 'Payer address (normalized)'),
  ('INCOME', 'payer_email_address', 'mandatory', 'email', 5, 'Payer email contact (normalized)'),
  ('INCOME', 'payer_phone_number', 'mandatory', 'phone', 6, 'Payer phone contact (normalized)'),
  ('INCOME', 'payment_amount', 'mandatory', 'currency', 7, 'Payment amount'),
  ('INCOME', 'payment_frequency', 'mandatory', 'enum', 8, 'weekly|bi_weekly|monthly|quarterly|semi_annually|annually'),
  ('INCOME', 'payment_start_date', 'mandatory', 'date', 9, 'When payments began'),
  ('INCOME', 'payment_end_date', 'mandatory', 'date', 10, 'When payments end');

-- Digital Assets UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('DIGITAL', 'asset_type', 'mandatory', 'enum', 1, 'cryptocurrency|intellectual_property|domain_name|digital_account|nft|software_license'),
  ('DIGITAL', 'asset_subtype', 'mandatory', 'text', 2, 'Specific asset subtype'),
  ('DIGITAL', 'asset_name', 'mandatory', 'text', 3, 'Asset name/identifier'),
  ('DIGITAL', 'platform_service', 'mandatory', 'text', 4, 'Platform or service'),
  ('DIGITAL', 'wallet_address', 'mandatory', 'text', 5, 'Wallet/account identifier'),
  ('DIGITAL', 'access_credentials', 'mandatory', 'text', 6, 'Access method/credentials'),
  ('DIGITAL', 'recovery_information', 'mandatory', 'text', 7, 'Recovery keys/phrases'),
  ('DIGITAL', 'quantity_amount', 'mandatory', 'real', 8, 'Quantity or amount'),
  ('DIGITAL', 'acquisition_date', 'mandatory', 'date', 9, 'Date acquired'),
  ('DIGITAL', 'acquisition_cost', 'mandatory', 'currency', 10, 'Original cost');

-- Ownership Interests UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('INTERESTS', 'interest_type', 'mandatory', 'enum', 1, 'business_equity|partnership|franchise|joint_venture|cooperative'),
  ('INTERESTS', 'entity_name', 'mandatory', 'text', 2, 'Business entity name'),
  ('INTERESTS', 'entity_type', 'mandatory', 'enum', 3, 'corporation|llc|partnership|sole_proprietorship|trust'),
  ('INTERESTS', 'ownership_percentage', 'mandatory', 'real', 4, 'Percentage owned'),
  ('INTERESTS', 'number_of_shares', 'mandatory', 'int', 5, 'Shares/units owned'),
  ('INTERESTS', 'share_class', 'mandatory', 'text', 6, 'Class of shares'),
  ('INTERESTS', 'valuation_method', 'mandatory', 'enum', 7, 'book_value|market_value|appraised_value|revenue_multiple|asset_based'),
  ('INTERESTS', 'acquisition_date', 'mandatory', 'date', 8, 'Date acquired'),
  ('INTERESTS', 'acquisition_cost', 'mandatory', 'currency', 9, 'Original investment'),
  ('INTERESTS', 'voting_rights', 'mandatory', 'enum', 10, 'full_voting|limited_voting|non_voting|super_voting');

-- Loans UI Mask
INSERT INTO ui_collection_mask (entity_code, column_name, requirement, field_type, display_order, note) VALUES
  ('LOANS', 'loan_type', 'mandatory', 'enum', 1, 'hei|interfamily|mortgage|personal|business|student|auto'),
  ('LOANS', 'lender_name', 'mandatory', 'text', 2, 'Lender name'),
  ('LOANS', 'borrower_name', 'mandatory', 'text', 3, 'Borrower name'),
  ('LOANS', 'loan_amount', 'mandatory', 'currency', 4, 'Original loan amount'),
  ('LOANS', 'outstanding_balance', 'mandatory', 'currency', 5, 'Current balance owed'),
  ('LOANS', 'interest_rate', 'mandatory', 'real', 6, 'Interest rate percentage'),
  ('LOANS', 'loan_term_years', 'mandatory', 'int', 7, 'Loan term in years'),
  ('LOANS', 'monthly_payment', 'mandatory', 'currency', 8, 'Monthly payment amount'),
  ('LOANS', 'origination_date', 'mandatory', 'date', 9, 'Loan start date'),
  ('LOANS', 'maturity_date', 'mandatory', 'date', 10, 'Loan end date'),
  ('LOANS', 'lender_contact_email_address', 'mandatory', 'email', 11, 'Lender email contact (normalized)'),
  ('LOANS', 'lender_contact_phone_number', 'mandatory', 'phone', 12, 'Lender phone contact (normalized)');
```

### Query mask

``` sql
SELECT * FROM ui_collection_mask
JOIN ui_entity USING (entity_code)
WHERE table_name = 'users'
ORDER BY display_order;
```

**Result**

  ----------------------------------------------------------------------------------------
  table_name   column_name    requirement   field_type   display_order   note
  ------------ -------------- ------------- ------------ --------------- -----------------
  users        id             mandatory     int          1               Primary key

  users        first_name     mandatory     text         2               Shown on profile

  users        last_name      mandatory     text         3               Shown on profile

  users        email          mandatory     email        4               Login identifier

  users        phone_mobile   optional      phone        5               SMS notifications

  users        zip_code       optional      zip          6               For shipping
                                                                         estimates
  ----------------------------------------------------------------------------------------

------------------------------------------------------------------------

✅ With this design you have: - **Simple static config** you maintain
manually\
- **No schema complexity** (always default)\
- **Order control** with `display_order`\
- **Easy queries** by `table_name` or `entity_code`
