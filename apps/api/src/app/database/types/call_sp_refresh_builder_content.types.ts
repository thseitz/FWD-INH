/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/builder_io/call_sp_refresh_builder_content.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpRefreshBuilderContent' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpRefreshBuilderContentResult = never;

/** Query 'CallSpRefreshBuilderContent' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpRefreshBuilderContentParams = never;

const callSpRefreshBuilderContentIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_refresh_builder_content()\n-- Type: FUNCTION call wrapper\n-- Description: Refresh content from Builder.io\n-- Parameters:\n--   $1: p_space_id TEXT - Builder.io space ID\n--   $2: p_model_name VARCHAR - Model name (optional)\n--   $3: p_content_ids TEXT[] - Content IDs (optional)\n-- Returns: Refresh results\n-- ================================================================\n\n-- Call stored procedure to refresh Builder.io content\n\nSELECT * FROM sp_refresh_builder_content(\n    $1::TEXT,                      -- p_space_id\n    $2::VARCHAR,                   -- p_model_name (optional)\n    $3::TEXT[]                     -- p_content_ids (optional)\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_refresh_builder_content()
 * -- Type: FUNCTION call wrapper
 * -- Description: Refresh content from Builder.io
 * -- Parameters:
 * --   $1: p_space_id TEXT - Builder.io space ID
 * --   $2: p_model_name VARCHAR - Model name (optional)
 * --   $3: p_content_ids TEXT[] - Content IDs (optional)
 * -- Returns: Refresh results
 * -- ================================================================
 * 
 * -- Call stored procedure to refresh Builder.io content
 * 
 * SELECT * FROM sp_refresh_builder_content(
 *     $1::TEXT,                      -- p_space_id
 *     $2::VARCHAR,                   -- p_model_name (optional)
 *     $3::TEXT[]                     -- p_content_ids (optional)
 * )
 * ```
 */
export const callSpRefreshBuilderContent = new PreparedQuery<ICallSpRefreshBuilderContentParams,ICallSpRefreshBuilderContentResult>(callSpRefreshBuilderContentIR);


