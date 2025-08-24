/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/management/call_sp_create_asset.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpCreateAsset' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpCreateAssetResult = never;

/** Query 'CallSpCreateAsset' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpCreateAssetParams = never;

const callSpCreateAssetIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_create_asset()\n-- Type: FUNCTION call wrapper\n-- Description: Create a new asset with ownership assignment\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_owner_persona_id UUID - Owner persona ID\n--   $3: p_asset_type asset_type_enum - Asset type\n--   $4: p_name TEXT - Asset name\n--   $5: p_description TEXT - Asset description\n--   $6: p_ownership_percentage DECIMAL(5,2) - Ownership % (optional, default 100)\n--   $7: p_created_by_user_id UUID - Created by user (optional)\n-- Returns: Created asset UUID\n-- ================================================================\n\n-- Call stored procedure to create asset\n\nSELECT * FROM sp_create_asset(\n    $1::INTEGER,                               -- p_tenant_id\n    $2::UUID,                                  -- p_owner_persona_id\n    $3::asset_type_enum,                       -- p_asset_type\n    $4::TEXT,                                  -- p_name\n    $5::TEXT,                                  -- p_description\n    COALESCE($6::DECIMAL(5,2), 100.00),       -- p_ownership_percentage\n    $7::UUID                                   -- p_created_by_user_id\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_create_asset()
 * -- Type: FUNCTION call wrapper
 * -- Description: Create a new asset with ownership assignment
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_owner_persona_id UUID - Owner persona ID
 * --   $3: p_asset_type asset_type_enum - Asset type
 * --   $4: p_name TEXT - Asset name
 * --   $5: p_description TEXT - Asset description
 * --   $6: p_ownership_percentage DECIMAL(5,2) - Ownership % (optional, default 100)
 * --   $7: p_created_by_user_id UUID - Created by user (optional)
 * -- Returns: Created asset UUID
 * -- ================================================================
 * 
 * -- Call stored procedure to create asset
 * 
 * SELECT * FROM sp_create_asset(
 *     $1::INTEGER,                               -- p_tenant_id
 *     $2::UUID,                                  -- p_owner_persona_id
 *     $3::asset_type_enum,                       -- p_asset_type
 *     $4::TEXT,                                  -- p_name
 *     $5::TEXT,                                  -- p_description
 *     COALESCE($6::DECIMAL(5,2), 100.00),       -- p_ownership_percentage
 *     $7::UUID                                   -- p_created_by_user_id
 * )
 * ```
 */
export const callSpCreateAsset = new PreparedQuery<ICallSpCreateAssetParams,ICallSpCreateAssetResult>(callSpCreateAssetIR);


