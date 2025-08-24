/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/call_sp_sync_real_estate_data.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpSyncRealEstateData' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpSyncRealEstateDataResult = never;

/** Query 'CallSpSyncRealEstateData' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpSyncRealEstateDataParams = never;

const callSpSyncRealEstateDataIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_sync_real_estate_data()\n-- Type: FUNCTION call wrapper\n-- Description: Sync real estate data from provider\n-- Parameters:\n--   $1: p_provider VARCHAR - Provider name (default 'zillow')\n--   $2: p_property_ids UUID[] - Property IDs (optional)\n--   $3: p_sync_all BOOLEAN - Sync all properties (default false)\n--   $4: p_user_id UUID - User ID (optional)\n-- Returns: Sync results\n-- ================================================================\n\n-- Call stored procedure to sync real estate data\n\nSELECT * FROM sp_sync_real_estate_data(\n    COALESCE($1::VARCHAR, 'zillow'),    -- p_provider\n    $2::UUID[],                          -- p_property_ids (optional)\n    COALESCE($3::BOOLEAN, FALSE),       -- p_sync_all\n    $4::UUID                             -- p_user_id (optional)\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_sync_real_estate_data()
 * -- Type: FUNCTION call wrapper
 * -- Description: Sync real estate data from provider
 * -- Parameters:
 * --   $1: p_provider VARCHAR - Provider name (default 'zillow')
 * --   $2: p_property_ids UUID[] - Property IDs (optional)
 * --   $3: p_sync_all BOOLEAN - Sync all properties (default false)
 * --   $4: p_user_id UUID - User ID (optional)
 * -- Returns: Sync results
 * -- ================================================================
 * 
 * -- Call stored procedure to sync real estate data
 * 
 * SELECT * FROM sp_sync_real_estate_data(
 *     COALESCE($1::VARCHAR, 'zillow'),    -- p_provider
 *     $2::UUID[],                          -- p_property_ids (optional)
 *     COALESCE($3::BOOLEAN, FALSE),       -- p_sync_all
 *     $4::UUID                             -- p_user_id (optional)
 * )
 * ```
 */
export const callSpSyncRealEstateData = new PreparedQuery<ICallSpSyncRealEstateDataParams,ICallSpSyncRealEstateDataResult>(callSpSyncRealEstateDataIR);


