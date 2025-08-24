/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/management/soft_delete_asset.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

/** 'SoftDeleteAsset' parameters type */
export type ISoftDeleteAssetParams = void;

/** 'SoftDeleteAsset' return type */
export interface ISoftDeleteAssetResult {
  id: string;
  name: string;
  status: status_enum;
  updated_at: Date | null;
  updated_by: string | null;
}

/** 'SoftDeleteAsset' query type */
export interface ISoftDeleteAssetQuery {
  params: ISoftDeleteAssetParams;
  result: ISoftDeleteAssetResult;
}

const softDeleteAssetIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_delete_asset() - Soft Delete\n-- Type: Single UPDATE\n-- Description: Soft delete an asset by setting status to 'deleted'\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID to delete\n--   $2: p_deleted_by UUID - User performing deletion (optional)\n-- Returns: Updated asset record\n-- NOTE: Audit log should be handled separately in service layer\n-- ================================================================\n\n-- This query performs a soft delete by updating status\n-- Returns the updated record or no rows if asset not found\n\nUPDATE assets SET\n    status = 'deleted',\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $2::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nWHERE id = $1::UUID\n  AND status != 'deleted'  -- Prevent double deletion\nRETURNING \n    id,\n    name,\n    status,\n    updated_at,\n    updated_by"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_delete_asset() - Soft Delete
 * -- Type: Single UPDATE
 * -- Description: Soft delete an asset by setting status to 'deleted'
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID to delete
 * --   $2: p_deleted_by UUID - User performing deletion (optional)
 * -- Returns: Updated asset record
 * -- NOTE: Audit log should be handled separately in service layer
 * -- ================================================================
 * 
 * -- This query performs a soft delete by updating status
 * -- Returns the updated record or no rows if asset not found
 * 
 * UPDATE assets SET
 *     status = 'deleted',
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $2::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * WHERE id = $1::UUID
 *   AND status != 'deleted'  -- Prevent double deletion
 * RETURNING 
 *     id,
 *     name,
 *     status,
 *     updated_at,
 *     updated_by
 * ```
 */
export const softDeleteAsset = new PreparedQuery<ISoftDeleteAssetParams,ISoftDeleteAssetResult>(softDeleteAssetIR);


