/* @name checkHealthBuilder */
-- ================================================================
-- Converted from: sp_check_integration_health() - Builder.io part
-- Type: SELECT
-- Description: Check health of Builder.io integrations
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
-- Returns: Health status of Builder.io integrations
-- ================================================================

-- Check Builder.io integration health

SELECT 
    'builder'::VARCHAR as integration_type,
    'Builder.io Integration'::VARCHAR as integration_name,
    bi.is_active as is_healthy,
    bi.last_sync_at as last_activity,
    0::DECIMAL as error_rate, -- No error tracking for builder yet
    jsonb_build_object(
        'api_key_present', bi.api_key IS NOT NULL,
        'space_id', bi.space_id,
        'environment', bi.environment,
        'last_sync', bi.last_sync_at
    ) as health_details
FROM builder_io_integrations bi
WHERE bi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1);