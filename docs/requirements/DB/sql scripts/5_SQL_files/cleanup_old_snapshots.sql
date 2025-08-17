-- ================================================================
-- Supporting query for: sp_create_snapshot()
-- Type: DELETE
-- Description: Clean up old snapshots (keep only last 3)
-- Parameters:
--   $1: p_aggregate_id UUID - Aggregate ID
-- Returns: Deleted snapshot IDs
-- ================================================================

-- Delete old snapshots, keeping only the 3 most recent

DELETE FROM event_snapshots
WHERE aggregate_id = $1::UUID
  AND snapshot_version < (
      SELECT snapshot_version
      FROM event_snapshots
      WHERE aggregate_id = $1::UUID
      ORDER BY snapshot_version DESC
      LIMIT 1 OFFSET 2
  )
RETURNING id, snapshot_version;