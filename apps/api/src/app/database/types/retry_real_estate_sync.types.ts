/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/retry_real_estate_sync.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type sync_status_enum = 'completed' | 'failed' | 'in_progress' | 'partial' | 'pending';

/** 'RetryRealEstateSync' parameters type */
export type IRetryRealEstateSyncParams = void;

/** 'RetryRealEstateSync' return type */
export interface IRetryRealEstateSyncResult {
  id: string;
  initiated_at: Date | null;
  integration_id: string;
  sync_status: sync_status_enum;
  sync_type: string;
}

/** 'RetryRealEstateSync' query type */
export interface IRetryRealEstateSyncQuery {
  params: IRetryRealEstateSyncParams;
  result: IRetryRealEstateSyncResult;
}

const retryRealEstateSyncIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_retry_failed_integration() - Real Estate part\n-- Type: UPDATE\n-- Description: Retry a failed real estate sync\n-- Parameters:\n--   $1: p_integration_id UUID - Sync log ID to retry\n-- Returns: Updated sync log record\n-- ================================================================\n\n-- Mark failed real estate sync for retry\n\nUPDATE real_estate_sync_logs SET\n    sync_status = 'in_progress',\n    completed_at = NULL,\n    error_message = NULL\nWHERE id = $1::UUID\n  AND sync_status = 'failed'\nRETURNING \n    id,\n    integration_id,\n    sync_status,\n    sync_type,\n    initiated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_retry_failed_integration() - Real Estate part
 * -- Type: UPDATE
 * -- Description: Retry a failed real estate sync
 * -- Parameters:
 * --   $1: p_integration_id UUID - Sync log ID to retry
 * -- Returns: Updated sync log record
 * -- ================================================================
 * 
 * -- Mark failed real estate sync for retry
 * 
 * UPDATE real_estate_sync_logs SET
 *     sync_status = 'in_progress',
 *     completed_at = NULL,
 *     error_message = NULL
 * WHERE id = $1::UUID
 *   AND sync_status = 'failed'
 * RETURNING 
 *     id,
 *     integration_id,
 *     sync_status,
 *     sync_type,
 *     initiated_at
 * ```
 */
export const retryRealEstateSync = new PreparedQuery<IRetryRealEstateSyncParams,IRetryRealEstateSyncResult>(retryRealEstateSyncIR);


