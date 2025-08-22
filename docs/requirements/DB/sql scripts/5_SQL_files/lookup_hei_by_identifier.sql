-- ================================================================
-- HEI Lookup by Identifier SQL
-- Type: SELECT
-- Description: Find existing HEI by loan number or external ID for self-registration
-- Parameters:
--   $1: identifier TEXT - Loan number, external ID, or property address
-- Returns: HEI record with linked persona and FFC information
-- ================================================================

SELECT 
    hei.id as hei_id,
    hei.asset_id as hei_asset_id,
    hei.property_asset_id,
    hei.amount_funded,
    hei.equity_share_pct,
    hei.effective_date,
    hei.source_system,
    hei.source_application_id,
    
    -- Persona information  
    p.id as persona_id,
    p.first_name || ' ' || p.last_name as persona_name,
    
    -- Property information from address
    addr.address_line_1,
    addr.city,
    addr.state_province,
    addr.postal_code,
    
    -- Asset information
    a_hei.name as hei_asset_name,
    a_prop.name as property_asset_name

FROM hei_assets hei
JOIN assets a_hei ON hei.asset_id = a_hei.id
JOIN real_estate re ON hei.property_asset_id = re.asset_id  
JOIN assets a_prop ON re.asset_id = a_prop.id
JOIN address addr ON re.property_address_id = addr.id
JOIN asset_persona ap ON hei.asset_id = ap.asset_id
JOIN personas p ON ap.persona_id = p.id

WHERE hei.hei_status = 'active'
AND (
    hei.source_application_id = $1
    OR LOWER(addr.address_line_1) LIKE LOWER('%' || $1 || '%')
    OR LOWER(a_prop.name) LIKE LOWER('%' || $1 || '%')
)

ORDER BY hei.created_at DESC
LIMIT 5;