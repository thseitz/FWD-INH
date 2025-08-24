/* @name getRealEstateSyncHistory */
-- ================================================================
-- Converted from: sp_get_real_estate_sync_history()
-- Type: Simple Read-Only Query
-- Description: Get real estate provider sync history
-- Parameters:
--   $1: p_provider VARCHAR(50) - Optional filter by provider name
--   $2: p_days_back INTEGER - Number of days to look back (default 30)
--   $3: p_limit INTEGER - Maximum records to return (default 100)
-- Returns: Real estate sync history records
-- ================================================================

-- This query retrieves real estate sync history with optional provider filter
-- Shows sync logs from the specified number of days back

SELECT 
    sl.id as sync_id,
    pi.provider_name,
    sl.sync_type,
    sl.sync_status::TEXT as sync_status,
    sl.initiated_at,
    sl.completed_at,
    sl.integration_id,
    sl.property_id,
    sl.error_message
FROM real_estate_sync_logs sl
JOIN real_estate_provider_integrations pi ON sl.integration_id = pi.id
WHERE 
    ($1::VARCHAR IS NULL OR pi.provider_name = $1)
    AND sl.initiated_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 30))
ORDER BY sl.initiated_at DESC
LIMIT COALESCE($3::INTEGER, 100);