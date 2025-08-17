-- ================================================================
-- Supporting query for: sp_assign_asset_to_persona()
-- Type: SELECT for validation
-- Description: Check total ownership percentage for an asset
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_persona_id UUID - Persona ID to exclude (for updates)
-- Returns: Current total ownership percentage
-- NOTE: Use this before inserting/updating to validate total <= 100%
-- ================================================================

-- This query calculates the current total ownership percentage
-- Excludes the persona being updated to avoid double-counting

SELECT 
    COALESCE(SUM(ownership_percentage), 0) as total_percentage
FROM asset_persona 
WHERE asset_id = $1::UUID
  AND ($2::UUID IS NULL OR persona_id != $2::UUID);