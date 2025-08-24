/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/management/update_asset_value.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'UpdateAssetValue' parameters type */
export type IUpdateAssetValueParams = void;

/** 'UpdateAssetValue' return type */
export interface IUpdateAssetValueResult {
  estimated_value: string | null;
  id: string;
  last_valued_date: Date | null;
  name: string;
  updated_at: Date | null;
  valuation_history: Json | null;
}

/** 'UpdateAssetValue' query type */
export interface IUpdateAssetValueQuery {
  params: IUpdateAssetValueParams;
  result: IUpdateAssetValueResult;
}

const updateAssetValueIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_asset_value()\n-- Type: UPDATE with JSONB Append (Dual Operation - needs transaction)\n-- Description: Update asset estimated value and append to valuation history\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID to update\n--   $2: p_new_value DECIMAL(15,2) - New estimated value\n--   $3: p_valuation_date DATE - Valuation date (default CURRENT_DATE)\n--   $4: p_valuation_method VARCHAR(50) - Valuation method (default 'market')\n--   $5: p_updated_by UUID - User performing update (optional)\n-- Returns: Updated asset record\n-- ================================================================\n\n-- This query updates asset value and appends to valuation history in tags\n-- NOTE: The audit log insert needs to be handled separately in the service layer\n-- This is a dual operation that requires transaction handling\n\nWITH current_asset AS (\n    SELECT id, estimated_value, tags, tenant_id, name\n    FROM assets\n    WHERE id = $1::UUID\n)\nUPDATE assets SET\n    estimated_value = $2::DECIMAL(15,2),\n    last_valued_date = COALESCE($3::DATE, CURRENT_DATE),\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $5::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    tags = tags || jsonb_build_object(\n        'valuation_history', \n        COALESCE(tags->'valuation_history', '[]'::jsonb) || \n        jsonb_build_array(jsonb_build_object(\n            'date', COALESCE($3::DATE, CURRENT_DATE),\n            'value', $2::DECIMAL(15,2),\n            'method', COALESCE($4::VARCHAR(50), 'market'),\n            'previous_value', (SELECT estimated_value FROM current_asset),\n            'updated_by', COALESCE(\n                $5::UUID,\n                CASE \n                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n                    THEN NULL\n                    ELSE current_setting('app.current_user_id', true)::UUID\n                END\n            ),\n            'updated_at', NOW()\n        ))\n    )\nWHERE id = $1::UUID\nRETURNING \n    id,\n    name,\n    estimated_value,\n    last_valued_date,\n    updated_at,\n    tags->'valuation_history' as valuation_history"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_asset_value()
 * -- Type: UPDATE with JSONB Append (Dual Operation - needs transaction)
 * -- Description: Update asset estimated value and append to valuation history
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID to update
 * --   $2: p_new_value DECIMAL(15,2) - New estimated value
 * --   $3: p_valuation_date DATE - Valuation date (default CURRENT_DATE)
 * --   $4: p_valuation_method VARCHAR(50) - Valuation method (default 'market')
 * --   $5: p_updated_by UUID - User performing update (optional)
 * -- Returns: Updated asset record
 * -- ================================================================
 * 
 * -- This query updates asset value and appends to valuation history in tags
 * -- NOTE: The audit log insert needs to be handled separately in the service layer
 * -- This is a dual operation that requires transaction handling
 * 
 * WITH current_asset AS (
 *     SELECT id, estimated_value, tags, tenant_id, name
 *     FROM assets
 *     WHERE id = $1::UUID
 * )
 * UPDATE assets SET
 *     estimated_value = $2::DECIMAL(15,2),
 *     last_valued_date = COALESCE($3::DATE, CURRENT_DATE),
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $5::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     tags = tags || jsonb_build_object(
 *         'valuation_history', 
 *         COALESCE(tags->'valuation_history', '[]'::jsonb) || 
 *         jsonb_build_array(jsonb_build_object(
 *             'date', COALESCE($3::DATE, CURRENT_DATE),
 *             'value', $2::DECIMAL(15,2),
 *             'method', COALESCE($4::VARCHAR(50), 'market'),
 *             'previous_value', (SELECT estimated_value FROM current_asset),
 *             'updated_by', COALESCE(
 *                 $5::UUID,
 *                 CASE 
 *                     WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *                     THEN NULL
 *                     ELSE current_setting('app.current_user_id', true)::UUID
 *                 END
 *             ),
 *             'updated_at', NOW()
 *         ))
 *     )
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     name,
 *     estimated_value,
 *     last_valued_date,
 *     updated_at,
 *     tags->'valuation_history' as valuation_history
 * ```
 */
export const updateAssetValue = new PreparedQuery<IUpdateAssetValueParams,IUpdateAssetValueResult>(updateAssetValueIR);


