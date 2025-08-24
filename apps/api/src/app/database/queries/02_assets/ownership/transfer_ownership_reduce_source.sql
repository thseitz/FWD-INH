/* @name transferOwnershipReduceSource */
-- ================================================================
-- Supporting query for: sp_transfer_asset_ownership() - Partial Transfer
-- Type: UPDATE
-- Description: Reduce ownership percentage from source persona
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_from_persona_id UUID - Source persona ID
--   $3: p_new_percentage DECIMAL(5,2) - New reduced percentage
--   $4: p_updated_by UUID - User making the transfer (optional)
-- Returns: Updated ownership record
-- NOTE: Use when transferring partial ownership
-- ================================================================

-- Reduce ownership percentage for source persona

UPDATE asset_persona SET
    ownership_percentage = $3::DECIMAL(5,2),
    updated_at = NOW(),
    updated_by = COALESCE(
        $4::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
WHERE asset_id = $1::UUID 
  AND persona_id = $2::UUID
RETURNING 
    asset_id,
    persona_id,
    ownership_percentage;