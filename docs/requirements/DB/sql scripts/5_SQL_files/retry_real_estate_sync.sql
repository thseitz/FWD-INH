-- ================================================================
-- Converted from: sp_retry_failed_integration() - Real Estate part
-- Type: UPDATE
-- Description: Retry a failed real estate sync
-- Parameters:
--   $1: p_integration_id UUID - Sync log ID to retry
-- Returns: Updated sync log record
-- ================================================================

-- Mark failed real estate sync for retry

UPDATE real_estate_sync_logs SET
    sync_status = 'in_progress',
    completed_at = NULL,
    error_message = NULL
WHERE id = $1::UUID
  AND sync_status = 'failed'
RETURNING 
    id,
    integration_id,
    sync_status,
    sync_type,
    initiated_at;