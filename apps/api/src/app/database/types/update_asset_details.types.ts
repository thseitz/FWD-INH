/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/management/update_asset_details.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'UpdateAssetDetails' parameters type */
export type IUpdateAssetDetailsParams = void;

/** 'UpdateAssetDetails' return type */
export interface IUpdateAssetDetailsResult {
  description: string | null;
  estimated_value: string | null;
  id: string;
  name: string;
  status: status_enum;
  tags: Json | null;
  tenant_id: number;
  updated_at: Date | null;
  updated_by: string | null;
}

/** 'UpdateAssetDetails' query type */
export interface IUpdateAssetDetailsQuery {
  params: IUpdateAssetDetailsParams;
  result: IUpdateAssetDetailsResult;
}

const updateAssetDetailsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_asset()\n-- Type: UPDATE with RETURNING\n-- Description: Update asset with optional fields\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID to update\n--   $2: p_name TEXT - New name (optional)\n--   $3: p_description TEXT - New description (optional)\n--   $4: p_estimated_value DECIMAL(15,2) - New value (optional)\n--   $5: p_status status_enum - New status (optional)\n--   $6: p_metadata JSONB - Additional metadata to merge (optional)\n--   $7: p_updated_by UUID - User making update (optional)\n-- Returns: Updated asset record\n-- NOTE: Service layer should create audit log entry after successful update\n-- ================================================================\n\n-- Update asset with COALESCE for optional fields\n\nUPDATE assets SET\n    name = COALESCE($2::TEXT, name),\n    description = COALESCE($3::TEXT, description),\n    estimated_value = COALESCE($4::DECIMAL(15,2), estimated_value),\n    status = COALESCE($5::status_enum, status),\n    tags = CASE \n        WHEN $6::JSONB IS NOT NULL THEN COALESCE(tags, '{}'::JSONB) || $6::JSONB\n        ELSE tags\n    END,\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $7::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nWHERE id = $1::UUID\nRETURNING \n    id,\n    tenant_id,\n    name,\n    description,\n    estimated_value,\n    status,\n    tags,\n    updated_at,\n    updated_by"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_asset()
 * -- Type: UPDATE with RETURNING
 * -- Description: Update asset with optional fields
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID to update
 * --   $2: p_name TEXT - New name (optional)
 * --   $3: p_description TEXT - New description (optional)
 * --   $4: p_estimated_value DECIMAL(15,2) - New value (optional)
 * --   $5: p_status status_enum - New status (optional)
 * --   $6: p_metadata JSONB - Additional metadata to merge (optional)
 * --   $7: p_updated_by UUID - User making update (optional)
 * -- Returns: Updated asset record
 * -- NOTE: Service layer should create audit log entry after successful update
 * -- ================================================================
 * 
 * -- Update asset with COALESCE for optional fields
 * 
 * UPDATE assets SET
 *     name = COALESCE($2::TEXT, name),
 *     description = COALESCE($3::TEXT, description),
 *     estimated_value = COALESCE($4::DECIMAL(15,2), estimated_value),
 *     status = COALESCE($5::status_enum, status),
 *     tags = CASE 
 *         WHEN $6::JSONB IS NOT NULL THEN COALESCE(tags, '{}'::JSONB) || $6::JSONB
 *         ELSE tags
 *     END,
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $7::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     tenant_id,
 *     name,
 *     description,
 *     estimated_value,
 *     status,
 *     tags,
 *     updated_at,
 *     updated_by
 * ```
 */
export const updateAssetDetails = new PreparedQuery<IUpdateAssetDetailsParams,IUpdateAssetDetailsResult>(updateAssetDetailsIR);


