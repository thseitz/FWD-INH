/* @name getCurrentEventVersion */
-- ================================================================
-- Supporting query for: sp_create_snapshot()
-- Type: SELECT
-- Description: Get current event version for an aggregate
-- Parameters:
--   $1: p_aggregate_id UUID - Aggregate ID
-- Returns: Current version number
-- ================================================================

-- Get the current event version for this aggregate

SELECT COALESCE(MAX(event_version), 0) as current_version
FROM event_store
WHERE aggregate_id = $1::UUID;