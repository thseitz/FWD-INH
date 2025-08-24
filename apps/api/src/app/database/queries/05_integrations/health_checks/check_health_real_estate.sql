/* @name checkHealthRealEstate */
-- ================================================================
-- Converted from: sp_check_integration_health() - Real Estate part
-- Type: SELECT with CTE
-- Description: Check health of Real Estate provider integrations
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
-- Returns: Health status of Real Estate integrations
-- ================================================================

-- Check Real Estate integration health with 7-day sync statistics

WITH recent_syncs AS (
    SELECT 
        pi.id,
        pi.provider_name,
        COUNT(*) as total_syncs,
        COUNT(*) FILTER (WHERE sl.sync_status = 'failed') as failed_syncs,
        MAX(sl.completed_at) as last_sync
    FROM real_estate_provider_integrations pi
    LEFT JOIN real_estate_sync_logs sl ON pi.id = sl.integration_id
        AND sl.initiated_at > (NOW() - INTERVAL '7 days')
    WHERE pi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
    GROUP BY pi.id, pi.provider_name
)
SELECT 
    'real_estate'::VARCHAR as integration_type,
    ('Real Estate - ' || rs.provider_name)::VARCHAR as integration_name,
    (rs.failed_syncs = 0 OR rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0) < 0.1) as is_healthy,
    rs.last_sync as last_activity,
    COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0) as error_rate,
    jsonb_build_object(
        'provider', rs.provider_name,
        'total_syncs_7d', rs.total_syncs,
        'failed_syncs_7d', rs.failed_syncs,
        'success_rate', ROUND((1 - COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0)) * 100, 2)
    ) as health_details
FROM recent_syncs rs;