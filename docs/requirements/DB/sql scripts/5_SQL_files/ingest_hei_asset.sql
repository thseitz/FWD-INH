-- ================================================================
-- HEI Asset Ingestion SQL
-- Type: Complex INSERT with Multiple Entity Creation
-- Description: Ingest completed HEI snapshot with property, persona, and FFC creation
-- Parameters:
--   $1: tenant_id INTEGER - Tenant ID
--   $2: property_data JSONB - Property information
--   $3: hei_data JSONB - HEI terms and details
--   $4: owner_data JSONB - Owner persona information
--   $5: source_system TEXT - External system identifier
--   $6: source_application_id TEXT - External application ID
-- Returns: JSONB with created entity IDs
-- ================================================================

WITH 
-- Step 1: Create or find real estate asset
property_asset AS (
    INSERT INTO assets (
        tenant_id,
        name, 
        description, 
        category_id, 
        estimated_value,
        created_by,
        updated_by
    ) VALUES (
        $1::INTEGER,
        (($2::JSONB)->>'address_line1') || ', ' || (($2::JSONB)->>'city') || ' ' || (($2::JSONB)->>'state'),
        'Real Estate Property for HEI',
        (SELECT id FROM asset_categories WHERE code = 'real_estate'),
        (($3::JSONB)->>'valuation_amount')::DECIMAL,
        current_user_id(),
        current_user_id()
    )
    RETURNING id as asset_id
),

-- Step 2: Create address for property
property_address AS (
    INSERT INTO address (
        tenant_id,
        address_line_1,
        address_line_2,
        city,
        state_province,
        postal_code,
        country
    ) VALUES (
        $1::INTEGER,
        ($2::JSONB)->>'address_line1',
        ($2::JSONB)->>'address_line2',
        ($2::JSONB)->>'city',
        ($2::JSONB)->>'state',
        ($2::JSONB)->>'postal_code',
        COALESCE(($2::JSONB)->>'country', 'US')
    )
    RETURNING id as address_id
),

-- Step 3: Create real estate details
property_details AS (
    INSERT INTO real_estate (
        asset_id,
        property_type,
        property_address_id,
        parcel_number,
        ownership_type,
        property_use
    ) VALUES (
        (SELECT asset_id FROM property_asset),
        'single_family',
        (SELECT address_id FROM property_address),
        ($2::JSONB)->>'parcel_number',
        'sole_ownership',
        'primary_residence'
    )
    RETURNING asset_id as property_asset_id
),

-- Step 4: Create or find persona
persona AS (
    INSERT INTO personas (
        tenant_id,
        first_name,
        last_name,
        created_by,
        updated_by
    ) VALUES (
        $1::INTEGER,
        split_part(($4::JSONB)->>'legal_name', ' ', 1),
        split_part(($4::JSONB)->>'legal_name', ' ', -1),
        current_user_id(),
        current_user_id()
    )
    RETURNING id as persona_id
),

-- Step 5: Create HEI asset
hei_asset AS (
    INSERT INTO assets (
        tenant_id,
        name,
        description,
        category_id,
        estimated_value,
        created_by,
        updated_by
    ) VALUES (
        $1::INTEGER,
        'HEI Investment - ' || (($2::JSONB)->>'address_line1'),
        'Home Equity Investment',
        (SELECT id FROM asset_categories WHERE code = 'hei'),
        (($3::JSONB)->>'amount_funded')::DECIMAL,
        current_user_id(),
        current_user_id()
    )
    RETURNING id as asset_id
),

-- Step 6: Create HEI details
hei_details AS (
    INSERT INTO hei_assets (
        asset_id,
        amount_funded,
        equity_share_pct,
        effective_date,
        property_asset_id,
        valuation_amount,
        valuation_method,
        valuation_effective_date,
        source_system,
        source_application_id,
        maturity_terms,
        first_mortgage_balance,
        junior_liens_balance,
        cltv_at_close,
        hei_status,
        created_by
    ) VALUES (
        (SELECT asset_id FROM hei_asset),
        (($3::JSONB)->>'amount_funded')::DECIMAL,
        (($3::JSONB)->>'equity_share_pct')::DECIMAL,
        (($3::JSONB)->>'effective_date')::DATE,
        (SELECT property_asset_id FROM property_details),
        (($3::JSONB)->>'valuation_amount')::DECIMAL,
        (($3::JSONB)->>'valuation_method')::hei_valuation_method_enum,
        (($3::JSONB)->>'valuation_effective_date')::DATE,
        $5::TEXT,  -- source_system
        $6::TEXT,  -- source_application_id
        (($3::JSONB)->>'maturity_terms'),
        (($3::JSONB)->>'first_mortgage_balance')::DECIMAL,
        (($3::JSONB)->>'junior_liens_balance')::DECIMAL,
        (($3::JSONB)->>'cltv_at_close')::DECIMAL,
        'active',
        current_user_id()
    )
    RETURNING asset_id as hei_asset_id
),

-- Step 7: Link property ownership
property_ownership AS (
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_percentage,
        ownership_type
    ) VALUES (
        $1::INTEGER,
        (SELECT property_asset_id FROM property_details),
        (SELECT persona_id FROM persona),
        100.00,
        'owner'
    )
    RETURNING asset_id as linked_property_id
),

-- Step 8: Link HEI ownership
hei_ownership AS (
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_percentage,
        ownership_type
    ) VALUES (
        $1::INTEGER,
        (SELECT hei_asset_id FROM hei_details),
        (SELECT persona_id FROM persona),
        100.00,
        'owner'
    )
    RETURNING asset_id as linked_hei_id
)

-- Return all created entity IDs
SELECT jsonb_build_object(
    'property_asset_id', (SELECT property_asset_id FROM property_details),
    'hei_asset_id', (SELECT hei_asset_id FROM hei_details),
    'persona_id', (SELECT persona_id FROM persona),
    'status', 'success'
) as result;