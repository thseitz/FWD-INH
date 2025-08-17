-- ================================================================
-- Converted from: sp_get_quillt_sync_status()
-- Type: Complex Read-Only Query with CTEs
-- Description: Get Quillt integration sync status and statistics
-- Parameters:
--   $1: p_user_id UUID - User ID to check status for
--   $2: p_days_back INTEGER - Number of days to look back (default 7)
-- Returns: Integration status and sync statistics
-- ================================================================

-- This query retrieves Quillt integration status with recent sync history
-- Uses multiple CTEs to aggregate sync statistics

WITH integration_info AS (
    SELECT 
        qi.*
    FROM quillt_integrations qi
    WHERE qi.user_id = $1::UUID
    AND qi.tenant_id = COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    )
),
recent_logs AS (
    SELECT 
        jsonb_agg(
            jsonb_build_object(
                'received_at', qwl.received_at,
                'event_type', qwl.event_type,
                'webhook_id', qwl.webhook_id,
                'status', qwl.processing_status,
                'records', COALESCE(qwl.payload->'records_synced', '0'::jsonb)
            ) ORDER BY qwl.received_at DESC
        ) as logs
    FROM quillt_webhook_logs qwl
    JOIN integration_info ii ON qwl.integration_id = ii.id
    WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))
),
sync_stats AS (
    SELECT 
        COUNT(*) as total_syncs,
        COUNT(*) FILTER (WHERE qwl.processing_status = 'delivered') as successful_syncs,
        COUNT(*) FILTER (WHERE qwl.processing_status = 'failed') as failed_syncs,
        AVG(COALESCE((qwl.payload->>'records_synced')::INTEGER, 0)) as avg_records_per_sync
    FROM quillt_webhook_logs qwl
    JOIN integration_info ii ON qwl.integration_id = ii.id
    WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))
)
SELECT 
    COALESCE(ii.is_active, false) as integration_active,
    ii.last_sync_at,
    COALESCE(ii.sync_status::TEXT, 'pending') as sync_status,
    COALESCE(rl.logs, '[]'::jsonb) as recent_syncs,
    jsonb_build_object(
        'total_syncs', COALESCE(ss.total_syncs, 0),
        'successful_syncs', COALESCE(ss.successful_syncs, 0),
        'failed_syncs', COALESCE(ss.failed_syncs, 0),
        'avg_records_per_sync', COALESCE(ss.avg_records_per_sync, 0)
    ) as sync_statistics
FROM integration_info ii
LEFT JOIN recent_logs rl ON true
LEFT JOIN sync_stats ss ON true;