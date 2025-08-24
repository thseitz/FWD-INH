/* @name createSnapshot */
-- ================================================================
-- Converted from: sp_create_snapshot()
-- Type: INSERT
-- Description: Create snapshot of aggregate state
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_aggregate_id UUID - Aggregate ID
--   $3: p_aggregate_type TEXT - Aggregate type
--   $4: p_snapshot_version INTEGER - Snapshot version (from get_current_event_version.sql)
--   $5: p_snapshot_data JSONB - Snapshot data
-- Returns: Snapshot record
-- NOTE: Service layer should:
--   1. Call get_current_event_version.sql first
--   2. Use the version number in this query
--   3. Call cleanup_old_snapshots.sql after
-- ================================================================

-- This query creates a new snapshot

INSERT INTO event_snapshots (
    tenant_id,
    aggregate_id,
    aggregate_type,
    snapshot_version,
    snapshot_data,
    created_at
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::TEXT,
    $4::INTEGER,  -- Version from get_current_event_version.sql
    $5::JSONB,
    NOW()
)
RETURNING 
    id,
    aggregate_id,
    aggregate_type,
    snapshot_version,
    created_at;