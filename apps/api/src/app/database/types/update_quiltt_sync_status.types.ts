/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/update_quiltt_sync_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type sync_status_enum = 'completed' | 'failed' | 'in_progress' | 'partial' | 'pending';

/** 'UpdateQuilttSyncStatus' parameters type */
export type IUpdateQuilttSyncStatusParams = void;

/** 'UpdateQuilttSyncStatus' return type */
export interface IUpdateQuilttSyncStatusResult {
  id: string;
  last_successful_sync_at: Date | null;
  last_sync_at: Date | null;
  persona_id: string;
  sync_error: string | null;
  sync_status: sync_status_enum | null;
}

/** 'UpdateQuilttSyncStatus' query type */
export interface IUpdateQuilttSyncStatusQuery {
  params: IUpdateQuilttSyncStatusParams;
  result: IUpdateQuilttSyncStatusResult;
}

const updateQuilttSyncStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: update_quiltt_sync_status\n-- Type: UPDATE\n-- Description: Update Quiltt integration sync status\n-- Parameters:\n--   $1: p_integration_id UUID - Integration ID\n--   $2: p_sync_status TEXT - Sync status (pending/completed/failed)\n--   $3: p_sync_error TEXT - Error message if failed (optional)\n-- Returns: Updated integration record\n-- Used by: Sync operations and webhook handlers\n-- ================================================================\n\nUPDATE quiltt_integrations\nSET \n    sync_status = $2::sync_status_enum,\n    sync_error = $3::TEXT,\n    last_sync_at = NOW(),\n    last_successful_sync_at = CASE \n        WHEN $2 = 'completed' THEN NOW()\n        ELSE last_successful_sync_at\n    END,\n    updated_at = NOW()\nWHERE \n    id = $1::UUID\nRETURNING \n    id,\n    persona_id,\n    sync_status,\n    sync_error,\n    last_sync_at,\n    last_successful_sync_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: update_quiltt_sync_status
 * -- Type: UPDATE
 * -- Description: Update Quiltt integration sync status
 * -- Parameters:
 * --   $1: p_integration_id UUID - Integration ID
 * --   $2: p_sync_status TEXT - Sync status (pending/completed/failed)
 * --   $3: p_sync_error TEXT - Error message if failed (optional)
 * -- Returns: Updated integration record
 * -- Used by: Sync operations and webhook handlers
 * -- ================================================================
 * 
 * UPDATE quiltt_integrations
 * SET 
 *     sync_status = $2::sync_status_enum,
 *     sync_error = $3::TEXT,
 *     last_sync_at = NOW(),
 *     last_successful_sync_at = CASE 
 *         WHEN $2 = 'completed' THEN NOW()
 *         ELSE last_successful_sync_at
 *     END,
 *     updated_at = NOW()
 * WHERE 
 *     id = $1::UUID
 * RETURNING 
 *     id,
 *     persona_id,
 *     sync_status,
 *     sync_error,
 *     last_sync_at,
 *     last_successful_sync_at
 * ```
 */
export const updateQuilttSyncStatus = new PreparedQuery<IUpdateQuilttSyncStatusParams,IUpdateQuilttSyncStatusResult>(updateQuilttSyncStatusIR);


