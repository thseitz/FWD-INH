/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/snapshots/create_snapshot.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateSnapshot' parameters type */
export type ICreateSnapshotParams = void;

/** 'CreateSnapshot' return type */
export interface ICreateSnapshotResult {
  aggregate_id: string;
  aggregate_type: string;
  created_at: Date;
  id: string;
  snapshot_version: number;
}

/** 'CreateSnapshot' query type */
export interface ICreateSnapshotQuery {
  params: ICreateSnapshotParams;
  result: ICreateSnapshotResult;
}

const createSnapshotIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_snapshot()\n-- Type: INSERT\n-- Description: Create snapshot of aggregate state\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_aggregate_id UUID - Aggregate ID\n--   $3: p_aggregate_type TEXT - Aggregate type\n--   $4: p_snapshot_version INTEGER - Snapshot version (from get_current_event_version.sql)\n--   $5: p_snapshot_data JSONB - Snapshot data\n-- Returns: Snapshot record\n-- NOTE: Service layer should:\n--   1. Call get_current_event_version.sql first\n--   2. Use the version number in this query\n--   3. Call cleanup_old_snapshots.sql after\n-- ================================================================\n\n-- This query creates a new snapshot\n\nINSERT INTO event_snapshots (\n    tenant_id,\n    aggregate_id,\n    aggregate_type,\n    snapshot_version,\n    snapshot_data,\n    created_at\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::TEXT,\n    $4::INTEGER,  -- Version from get_current_event_version.sql\n    $5::JSONB,\n    NOW()\n)\nRETURNING \n    id,\n    aggregate_id,\n    aggregate_type,\n    snapshot_version,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_snapshot()
 * -- Type: INSERT
 * -- Description: Create snapshot of aggregate state
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_aggregate_id UUID - Aggregate ID
 * --   $3: p_aggregate_type TEXT - Aggregate type
 * --   $4: p_snapshot_version INTEGER - Snapshot version (from get_current_event_version.sql)
 * --   $5: p_snapshot_data JSONB - Snapshot data
 * -- Returns: Snapshot record
 * -- NOTE: Service layer should:
 * --   1. Call get_current_event_version.sql first
 * --   2. Use the version number in this query
 * --   3. Call cleanup_old_snapshots.sql after
 * -- ================================================================
 * 
 * -- This query creates a new snapshot
 * 
 * INSERT INTO event_snapshots (
 *     tenant_id,
 *     aggregate_id,
 *     aggregate_type,
 *     snapshot_version,
 *     snapshot_data,
 *     created_at
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::TEXT,
 *     $4::INTEGER,  -- Version from get_current_event_version.sql
 *     $5::JSONB,
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     aggregate_id,
 *     aggregate_type,
 *     snapshot_version,
 *     created_at
 * ```
 */
export const createSnapshot = new PreparedQuery<ICreateSnapshotParams,ICreateSnapshotResult>(createSnapshotIR);


