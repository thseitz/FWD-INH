/* @name appendEvent */
-- ================================================================
-- Converted from: sp_append_event()
-- Type: INSERT
-- Description: Append event to event store
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_aggregate_id UUID - Aggregate ID
--   $3: p_aggregate_type TEXT - Aggregate type
--   $4: p_event_type TEXT - Event type
--   $5: p_event_data JSONB - Event data
--   $6: p_event_metadata JSONB - Event metadata (optional)
--   $7: p_event_version INTEGER - Event version (from get_next_event_version.sql)
--   $8: p_user_id UUID - User creating event (optional)
-- Returns: Event store entry
-- NOTE: Service layer should:
--   1. Call get_next_event_version.sql first
--   2. Use the version number in this query
-- ================================================================

-- This query appends an event to the event store

INSERT INTO event_store (
    tenant_id,
    aggregate_id,
    aggregate_type,
    event_type,
    event_data,
    event_metadata,
    event_version,
    created_at,
    created_by
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::TEXT,
    $4::TEXT,
    $5::JSONB,
    $6::JSONB,
    $7::INTEGER,  -- Version from get_next_event_version.sql
    NOW(),
    COALESCE(
        $8::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
)
RETURNING 
    id,
    aggregate_id,
    aggregate_type,
    event_type,
    event_version,
    created_at;