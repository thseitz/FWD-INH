/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/get_real_estate_sync_history.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetRealEstateSyncHistory' parameters type */
export type IGetRealEstateSyncHistoryParams = void;

/** 'GetRealEstateSyncHistory' return type */
export interface IGetRealEstateSyncHistoryResult {
  completed_at: Date | null;
  error_message: string | null;
  initiated_at: Date | null;
  integration_id: string;
  property_id: string;
  provider_name: string;
  sync_id: string;
  sync_status: string | null;
  sync_type: string;
}

/** 'GetRealEstateSyncHistory' query type */
export interface IGetRealEstateSyncHistoryQuery {
  params: IGetRealEstateSyncHistoryParams;
  result: IGetRealEstateSyncHistoryResult;
}

const getRealEstateSyncHistoryIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_real_estate_sync_history()\n-- Type: Simple Read-Only Query\n-- Description: Get real estate provider sync history\n-- Parameters:\n--   $1: p_provider VARCHAR(50) - Optional filter by provider name\n--   $2: p_days_back INTEGER - Number of days to look back (default 30)\n--   $3: p_limit INTEGER - Maximum records to return (default 100)\n-- Returns: Real estate sync history records\n-- ================================================================\n\n-- This query retrieves real estate sync history with optional provider filter\n-- Shows sync logs from the specified number of days back\n\nSELECT \n    sl.id as sync_id,\n    pi.provider_name,\n    sl.sync_type,\n    sl.sync_status::TEXT as sync_status,\n    sl.initiated_at,\n    sl.completed_at,\n    sl.integration_id,\n    sl.property_id,\n    sl.error_message\nFROM real_estate_sync_logs sl\nJOIN real_estate_provider_integrations pi ON sl.integration_id = pi.id\nWHERE \n    ($1::VARCHAR IS NULL OR pi.provider_name = $1)\n    AND sl.initiated_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 30))\nORDER BY sl.initiated_at DESC\nLIMIT COALESCE($3::INTEGER, 100)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_real_estate_sync_history()
 * -- Type: Simple Read-Only Query
 * -- Description: Get real estate provider sync history
 * -- Parameters:
 * --   $1: p_provider VARCHAR(50) - Optional filter by provider name
 * --   $2: p_days_back INTEGER - Number of days to look back (default 30)
 * --   $3: p_limit INTEGER - Maximum records to return (default 100)
 * -- Returns: Real estate sync history records
 * -- ================================================================
 * 
 * -- This query retrieves real estate sync history with optional provider filter
 * -- Shows sync logs from the specified number of days back
 * 
 * SELECT 
 *     sl.id as sync_id,
 *     pi.provider_name,
 *     sl.sync_type,
 *     sl.sync_status::TEXT as sync_status,
 *     sl.initiated_at,
 *     sl.completed_at,
 *     sl.integration_id,
 *     sl.property_id,
 *     sl.error_message
 * FROM real_estate_sync_logs sl
 * JOIN real_estate_provider_integrations pi ON sl.integration_id = pi.id
 * WHERE 
 *     ($1::VARCHAR IS NULL OR pi.provider_name = $1)
 *     AND sl.initiated_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 30))
 * ORDER BY sl.initiated_at DESC
 * LIMIT COALESCE($3::INTEGER, 100)
 * ```
 */
export const getRealEstateSyncHistory = new PreparedQuery<IGetRealEstateSyncHistoryParams,IGetRealEstateSyncHistoryResult>(getRealEstateSyncHistoryIR);


