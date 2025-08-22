-- ================================================================
-- HEI Idempotency Check SQL
-- Type: SELECT
-- Description: Check if HEI already exists by source system and application ID
-- Parameters:
--   $1: source_system TEXT - External system identifier
--   $2: source_application_id TEXT - External application ID
-- Returns: Existing HEI record if found, null if new
-- ================================================================

SELECT 
    hei.id as hei_id,
    hei.asset_id as hei_asset_id,
    hei.property_asset_id,
    
    -- Persona information
    p.id as persona_id,
    p.first_name || ' ' || p.last_name as persona_name,
    
    -- Ingestion metadata
    hei.source_system,
    hei.source_application_id,
    hei.created_at as originally_ingested_at,
    hei.updated_at as last_updated_at,
    
    -- Status
    'duplicate' as status,
    'HEI already exists with this source system and application ID' as message

FROM hei_assets hei
JOIN asset_persona ap ON hei.asset_id = ap.asset_id
JOIN personas p ON ap.persona_id = p.id

WHERE hei.source_system = $1
AND hei.source_application_id = $2
AND hei.hei_status != 'defaulted'

LIMIT 1;