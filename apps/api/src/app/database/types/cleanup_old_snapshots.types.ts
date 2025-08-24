/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/snapshots/cleanup_old_snapshots.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CleanupOldSnapshots' parameters type */
export type ICleanupOldSnapshotsParams = void;

/** 'CleanupOldSnapshots' return type */
export interface ICleanupOldSnapshotsResult {
  id: string;
  snapshot_version: number;
}

/** 'CleanupOldSnapshots' query type */
export interface ICleanupOldSnapshotsQuery {
  params: ICleanupOldSnapshotsParams;
  result: ICleanupOldSnapshotsResult;
}

const cleanupOldSnapshotsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_create_snapshot()\n-- Type: DELETE\n-- Description: Clean up old snapshots (keep only last 3)\n-- Parameters:\n--   $1: p_aggregate_id UUID - Aggregate ID\n-- Returns: Deleted snapshot IDs\n-- ================================================================\n\n-- Delete old snapshots, keeping only the 3 most recent\n\nDELETE FROM event_snapshots\nWHERE aggregate_id = $1::UUID\n  AND snapshot_version < (\n      SELECT snapshot_version\n      FROM event_snapshots\n      WHERE aggregate_id = $1::UUID\n      ORDER BY snapshot_version DESC\n      LIMIT 1 OFFSET 2\n  )\nRETURNING id, snapshot_version"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_create_snapshot()
 * -- Type: DELETE
 * -- Description: Clean up old snapshots (keep only last 3)
 * -- Parameters:
 * --   $1: p_aggregate_id UUID - Aggregate ID
 * -- Returns: Deleted snapshot IDs
 * -- ================================================================
 * 
 * -- Delete old snapshots, keeping only the 3 most recent
 * 
 * DELETE FROM event_snapshots
 * WHERE aggregate_id = $1::UUID
 *   AND snapshot_version < (
 *       SELECT snapshot_version
 *       FROM event_snapshots
 *       WHERE aggregate_id = $1::UUID
 *       ORDER BY snapshot_version DESC
 *       LIMIT 1 OFFSET 2
 *   )
 * RETURNING id, snapshot_version
 * ```
 */
export const cleanupOldSnapshots = new PreparedQuery<ICleanupOldSnapshotsParams,ICleanupOldSnapshotsResult>(cleanupOldSnapshotsIR);


