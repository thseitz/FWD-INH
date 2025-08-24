/* @name getHeiDashboardData */
-- ================================================================
-- HEI Dashboard Data SQL
-- Type: SELECT
-- Description: Get comprehensive HEI data for user dashboard
-- Parameters:
--   $1: persona_id UUID - Persona ID to filter HEIs for
-- Returns: Complete HEI information with property and document details
-- ================================================================

SELECT 
    -- HEI Investment Details
    hei.id as hei_id,
    hei.asset_id as hei_asset_id,
    hei.amount_funded,
    hei.equity_share_pct,
    hei.effective_date,
    hei.maturity_terms,
    hei.valuation_amount,
    hei.valuation_method,
    hei.valuation_effective_date,
    hei.hei_status,
    hei.first_mortgage_balance,
    hei.junior_liens_balance,
    hei.cltv_at_close,
    hei.source_system,
    hei.funded_at,
    
    -- HEI Asset Information
    a_hei.name as hei_asset_name,
    a_hei.description as hei_description,
    a_hei.estimated_value as hei_estimated_value,
    a_hei.created_at as hei_created_at,
    
    -- Property Details from address
    hei.property_asset_id,
    addr.address_line_1,
    addr.address_line_2,
    addr.city,
    addr.state_province,
    addr.postal_code,
    addr.country,
    re.parcel_number,
    re.property_type,
    re.building_size_sqft,
    re.lot_size_acres,
    re.year_built,
    
    -- Property Asset Information
    a_prop.name as property_name,
    a_prop.estimated_value as property_estimated_value,
    
    -- Ownership Information
    ap_hei.ownership_percentage as hei_ownership_pct,
    
    -- Persona Information
    p.first_name || ' ' || p.last_name as owner_name

FROM hei_assets hei
JOIN assets a_hei ON hei.asset_id = a_hei.id
JOIN real_estate re ON hei.property_asset_id = re.asset_id
JOIN assets a_prop ON re.asset_id = a_prop.id
JOIN address addr ON re.property_address_id = addr.id

-- HEI ownership
JOIN asset_persona ap_hei ON hei.asset_id = ap_hei.asset_id
JOIN personas p ON ap_hei.persona_id = p.id

-- HEI document count (removing for now - would need document linking table)
-- LEFT JOIN (
--     SELECT 
--         asset_id,
--         COUNT(*) as total
--     FROM asset_documents 
--     WHERE asset_id = hei.asset_id
--     GROUP BY asset_id
-- ) hei_doc_count ON hei.asset_id = hei_doc_count.asset_id

-- Property document count (removing for now - would need document linking table)
-- LEFT JOIN (
--     SELECT 
--         asset_id,
--         COUNT(*) as total
--     FROM asset_documents
--     WHERE asset_id = re.asset_id
--     GROUP BY asset_id  
-- ) prop_doc_count ON re.asset_id = prop_doc_count.asset_id

WHERE p.id = $1::UUID  -- Filter by persona_id instead
AND hei.hei_status = 'active'
AND a_hei.status = 'active'
AND a_prop.status = 'active'

ORDER BY hei.effective_date DESC;