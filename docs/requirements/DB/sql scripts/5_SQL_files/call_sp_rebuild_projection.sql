-- ================================================================
-- Wrapper for: sp_rebuild_projection()
-- Type: FUNCTION call wrapper
-- Description: Rebuild event projection from event store
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_projection_name TEXT - Projection name
--   $3: p_aggregate_id UUID - Aggregate ID (optional)
-- Returns: VOID
-- ================================================================

-- Call stored procedure to rebuild projection

SELECT sp_rebuild_projection(
    $1::INTEGER,                    -- p_tenant_id
    $2::TEXT,                       -- p_projection_name
    $3::UUID                        -- p_aggregate_id (optional)
);