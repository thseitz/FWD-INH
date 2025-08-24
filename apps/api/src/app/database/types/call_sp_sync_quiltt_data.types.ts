/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/call_sp_sync_quiltt_data.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpSyncQuilttData' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpSyncQuilttDataResult = never;

/** Query 'CallSpSyncQuilttData' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpSyncQuilttDataParams = never;

const callSpSyncQuilttDataIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_sync_quiltt_data()\n-- Type: FUNCTION call wrapper\n-- Description: Sync data from Quiltt financial API\n-- Parameters:\n--   $1: p_user_id UUID - User ID\n--   $2: p_sync_type VARCHAR - Type of sync (default 'full')\n--   $3: p_data_categories JSONB - Data categories (default '[\"accounts\", \"transactions\", \"documents\"]')\n-- Returns: Sync results\n-- ================================================================\n\n-- Call stored procedure to sync Quiltt data\n\nSELECT * FROM sp_sync_quiltt_data(\n    $1::UUID,                                                              -- p_user_id\n    COALESCE($2::VARCHAR, 'full'),                                        -- p_sync_type\n    COALESCE($3::JSONB, '[\"accounts\", \"transactions\", \"documents\"]'::JSONB) -- p_data_categories\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_sync_quiltt_data()
 * -- Type: FUNCTION call wrapper
 * -- Description: Sync data from Quiltt financial API
 * -- Parameters:
 * --   $1: p_user_id UUID - User ID
 * --   $2: p_sync_type VARCHAR - Type of sync (default 'full')
 * --   $3: p_data_categories JSONB - Data categories (default '["accounts", "transactions", "documents"]')
 * -- Returns: Sync results
 * -- ================================================================
 * 
 * -- Call stored procedure to sync Quiltt data
 * 
 * SELECT * FROM sp_sync_quiltt_data(
 *     $1::UUID,                                                              -- p_user_id
 *     COALESCE($2::VARCHAR, 'full'),                                        -- p_sync_type
 *     COALESCE($3::JSONB, '["accounts", "transactions", "documents"]'::JSONB) -- p_data_categories
 * )
 * ```
 */
export const callSpSyncQuilttData = new PreparedQuery<ICallSpSyncQuilttDataParams,ICallSpSyncQuilttDataResult>(callSpSyncQuilttDataIR);


