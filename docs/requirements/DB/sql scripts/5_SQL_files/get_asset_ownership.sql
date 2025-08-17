-- ================================================================
-- Supporting query for: sp_transfer_asset_ownership()
-- Type: SELECT
-- Description: Get current ownership percentage for validation
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_persona_id UUID - Persona ID
-- Returns: Current ownership details
-- ================================================================

-- Get current ownership percentage for a persona

SELECT 
    ownership_percentage,
    ownership_type,
    is_primary
FROM asset_persona 
WHERE asset_id = $1::UUID 
  AND persona_id = $2::UUID;