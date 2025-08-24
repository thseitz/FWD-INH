/* @name replayEvents */
-- ================================================================
-- Converted from: sp_replay_events()
-- Type: SELECT returning TABLE
-- Description: Replay events for an aggregate from event store
-- Parameters:
--   $1: p_aggregate_id UUID - Aggregate ID
--   $2: p_from_version INTEGER - Start version (default 1)
--   $3: p_to_version INTEGER - End version (optional)
-- Returns: Event records in order
-- ================================================================

-- Retrieve events for an aggregate within version range

SELECT 
    event_version,
    event_type,
    event_data,
    event_metadata,
    created_at,
    created_by
FROM event_store
WHERE aggregate_id = $1::UUID
  AND event_version >= COALESCE($2::INTEGER, 1)
  AND ($3::INTEGER IS NULL OR event_version <= $3::INTEGER)
ORDER BY event_version;