-- ================================================================
-- Converted from: sp_check_integration_health() - Quiltt part
-- Type: SELECT
-- Description: Check health of Quiltt integrations
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
-- Returns: Health status of Quiltt integrations
-- ================================================================

-- Check Quiltt integration health with error rates

WITH integration_errors AS (
    SELECT 
        qi.id,
        COUNT(*) FILTER (WHERE wl.processing_status = 'failed')::DECIMAL / NULLIF(COUNT(*), 0) as error_rate
    FROM quiltt_integrations qi
    LEFT JOIN quiltt_webhook_logs wl ON wl.integration_id = qi.id 
        AND wl.received_at > (NOW() - INTERVAL '24 hours')
    WHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
    GROUP BY qi.id
)
SELECT 
    'quiltt'::VARCHAR as integration_type,
    'Quiltt Integration'::VARCHAR as integration_name,
    (qi.is_active AND qi.token_expires_at > NOW()) as is_healthy,
    qi.last_sync_at as last_activity,
    COALESCE(ie.error_rate, 0) as error_rate,
    jsonb_build_object(
        'integration_id', qi.id,
        'expired', qi.token_expires_at < NOW(),
        'sync_accounts', qi.sync_accounts,
        'sync_transactions', qi.sync_transactions,
        'last_sync', qi.last_sync_at
    ) as health_details
FROM quiltt_integrations qi
LEFT JOIN integration_errors ie ON ie.id = qi.id
WHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1);