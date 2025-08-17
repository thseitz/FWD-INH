-- ================================================================
-- Converted from: sp_delete_asset() - Soft Delete
-- Type: Single UPDATE
-- Description: Soft delete an asset by setting status to 'deleted'
-- Parameters:
--   $1: p_asset_id UUID - Asset ID to delete
--   $2: p_deleted_by UUID - User performing deletion (optional)
-- Returns: Updated asset record
-- NOTE: Audit log should be handled separately in service layer
-- ================================================================

-- This query performs a soft delete by updating status
-- Returns the updated record or no rows if asset not found

UPDATE assets SET
    status = 'deleted',
    updated_at = NOW(),
    updated_by = COALESCE(
        $2::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
WHERE id = $1::UUID
  AND status != 'deleted'  -- Prevent double deletion
RETURNING 
    id,
    name,
    status,
    updated_at,
    updated_by;