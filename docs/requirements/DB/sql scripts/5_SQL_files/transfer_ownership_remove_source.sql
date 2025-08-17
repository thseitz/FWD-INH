-- ================================================================
-- Supporting query for: sp_transfer_asset_ownership() - Full Transfer
-- Type: DELETE
-- Description: Remove ownership from source persona (full transfer)
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_from_persona_id UUID - Source persona ID
-- Returns: Deleted ownership record
-- NOTE: Use when transferring 100% ownership
-- ================================================================

-- Remove ownership completely from source persona

DELETE FROM asset_persona 
WHERE asset_id = $1::UUID 
  AND persona_id = $2::UUID
RETURNING 
    asset_id,
    persona_id,
    ownership_percentage;