/* @name updateQuilttSyncStatus */
-- ================================================================
-- Name: update_quiltt_sync_status
-- Type: UPDATE
-- Description: Update Quiltt integration sync status
-- Parameters:
--   $1: p_integration_id UUID - Integration ID
--   $2: p_sync_status TEXT - Sync status (pending/completed/failed)
--   $3: p_sync_error TEXT - Error message if failed (optional)
-- Returns: Updated integration record
-- Used by: Sync operations and webhook handlers
-- ================================================================

UPDATE quiltt_integrations
SET 
    sync_status = $2::sync_status_enum,
    sync_error = $3::TEXT,
    last_sync_at = NOW(),
    last_successful_sync_at = CASE 
        WHEN $2 = 'completed' THEN NOW()
        ELSE last_successful_sync_at
    END,
    updated_at = NOW()
WHERE 
    id = $1::UUID
RETURNING 
    id,
    persona_id,
    sync_status,
    sync_error,
    last_sync_at,
    last_successful_sync_at;