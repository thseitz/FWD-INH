/* @name retryQuilttIntegration */
-- ================================================================
-- Converted from: sp_retry_failed_integration() - Quiltt part
-- Type: UPDATE
-- Description: Retry a failed Quiltt webhook
-- Parameters:
--   $1: p_integration_id UUID - Webhook log ID to retry
--   $2: p_retry_count INTEGER - Number of retry attempts (default 1)
-- Returns: Updated webhook log record
-- ================================================================

-- Mark failed Quiltt webhook for retry

UPDATE quiltt_webhook_logs SET
    processing_status = 'retrying',
    retry_count = COALESCE(retry_count, 0) + COALESCE($2::INTEGER, 1),
    processed_at = NULL
WHERE id = $1::UUID
  AND processing_status = 'failed'
RETURNING 
    id,
    integration_id,
    processing_status,
    retry_count,
    event_type,
    processing_error;