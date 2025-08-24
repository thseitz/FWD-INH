/* @name getBuilderContentStatus */
-- ================================================================
-- Converted from: sp_get_builder_content_status()
-- Type: Simple Read-Only Query
-- Description: Get Builder.io content integration status
-- Parameters:
--   $1: p_space_id TEXT - Optional filter by space ID
-- Returns: Builder.io integration status information
-- ================================================================

-- This query retrieves Builder.io integration status and configuration
-- Shows sync status, cache age, and configuration details

SELECT 
    bi.space_id,
    bi.environment,
    bi.is_active,
    bi.last_sync_at,
    0 as cached_content_count,
    bi.content_model_mappings,
    jsonb_build_object(
        'webhook_configured', false,
        'cache_age_hours', 
        CASE 
            WHEN bi.last_sync_at IS NOT NULL THEN
                EXTRACT(EPOCH FROM (NOW() - bi.last_sync_at)) / 3600
            ELSE NULL
        END,
        'integration_id', bi.id
    ) as status_details
FROM builder_io_integrations bi
WHERE 
    bi.tenant_id = CASE 
        WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
        THEN NULL
        ELSE current_setting('app.current_tenant_id', true)::INTEGER
    END
    AND ($1::TEXT IS NULL OR bi.space_id = $1);