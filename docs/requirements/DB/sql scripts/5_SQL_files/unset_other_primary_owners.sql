-- ================================================================
-- Supporting query for: sp_assign_asset_to_persona()
-- Type: UPDATE
-- Description: Unset other primary owners when setting a new primary
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_persona_id UUID - The persona ID that should remain primary
--   $3: p_updated_by UUID - User making the update (optional)
-- Returns: Updated records
-- NOTE: Only run this when setting a persona as primary owner
-- ================================================================

-- This query unsets the is_primary flag for all other personas on the asset
-- Should be run after setting a new primary owner

UPDATE asset_persona SET
    is_primary = FALSE,
    updated_at = NOW(),
    updated_by = COALESCE(
        $3::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
WHERE asset_id = $1::UUID 
  AND persona_id != $2::UUID 
  AND is_primary = TRUE
RETURNING 
    id,
    persona_id,
    is_primary,
    updated_at;