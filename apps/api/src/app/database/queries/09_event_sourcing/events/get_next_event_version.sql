/* @name getNextEventVersion */
-- ================================================================
-- Supporting query for: sp_append_event()
-- Type: SELECT
-- Description: Get next event version for an aggregate
-- Parameters:
--   $1: p_aggregate_id UUID - Aggregate ID
-- Returns: Next version number
-- ================================================================

-- Get the next event version for this aggregate

SELECT COALESCE(MAX(event_version), 0) + 1 as next_version
FROM event_store
WHERE aggregate_id = $1::UUID;