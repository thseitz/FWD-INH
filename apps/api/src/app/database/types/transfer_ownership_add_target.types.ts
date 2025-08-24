/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/transfer_ownership_add_target.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'TransferOwnershipAddTarget' parameters type */
export type ITransferOwnershipAddTargetParams = void;

/** 'TransferOwnershipAddTarget' return type */
export interface ITransferOwnershipAddTargetResult {
  asset_id: string;
  ownership_percentage: string | null;
  persona_id: string;
  updated_at: Date | null;
}

/** 'TransferOwnershipAddTarget' query type */
export interface ITransferOwnershipAddTargetQuery {
  params: ITransferOwnershipAddTargetParams;
  result: ITransferOwnershipAddTargetResult;
}

const transferOwnershipAddTargetIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_transfer_asset_ownership() - Add to Target\n-- Type: INSERT with ON CONFLICT UPDATE\n-- Description: Add or increase ownership for target persona\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_to_persona_id UUID - Target persona ID\n--   $3: p_transfer_percentage DECIMAL(5,2) - Percentage to add\n--   $4: p_updated_by UUID - User making the transfer (optional)\n-- Returns: Target ownership record\n-- NOTE: Service layer should get tenant_id from asset first\n-- ================================================================\n\n-- Add or increase ownership for target persona\n-- If target already has ownership, increase it; otherwise create new\n\nINSERT INTO asset_persona (\n    tenant_id,\n    asset_id,\n    persona_id,\n    ownership_type,\n    ownership_percentage,\n    is_primary,\n    created_at,\n    updated_at,\n    created_by,\n    updated_by\n)\nSELECT\n    a.tenant_id,\n    $1::UUID,\n    $2::UUID,\n    'owner'::ownership_type_enum,\n    $3::DECIMAL(5,2),\n    FALSE,\n    NOW(),\n    NOW(),\n    COALESCE(\n        $4::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    COALESCE(\n        $4::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nFROM assets a\nWHERE a.id = $1::UUID\nON CONFLICT (asset_id, persona_id) DO UPDATE SET\n    ownership_percentage = asset_persona.ownership_percentage + EXCLUDED.ownership_percentage,\n    updated_at = NOW(),\n    updated_by = EXCLUDED.updated_by\nRETURNING \n    asset_id,\n    persona_id,\n    ownership_percentage,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_transfer_asset_ownership() - Add to Target
 * -- Type: INSERT with ON CONFLICT UPDATE
 * -- Description: Add or increase ownership for target persona
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_to_persona_id UUID - Target persona ID
 * --   $3: p_transfer_percentage DECIMAL(5,2) - Percentage to add
 * --   $4: p_updated_by UUID - User making the transfer (optional)
 * -- Returns: Target ownership record
 * -- NOTE: Service layer should get tenant_id from asset first
 * -- ================================================================
 * 
 * -- Add or increase ownership for target persona
 * -- If target already has ownership, increase it; otherwise create new
 * 
 * INSERT INTO asset_persona (
 *     tenant_id,
 *     asset_id,
 *     persona_id,
 *     ownership_type,
 *     ownership_percentage,
 *     is_primary,
 *     created_at,
 *     updated_at,
 *     created_by,
 *     updated_by
 * )
 * SELECT
 *     a.tenant_id,
 *     $1::UUID,
 *     $2::UUID,
 *     'owner'::ownership_type_enum,
 *     $3::DECIMAL(5,2),
 *     FALSE,
 *     NOW(),
 *     NOW(),
 *     COALESCE(
 *         $4::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     COALESCE(
 *         $4::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * FROM assets a
 * WHERE a.id = $1::UUID
 * ON CONFLICT (asset_id, persona_id) DO UPDATE SET
 *     ownership_percentage = asset_persona.ownership_percentage + EXCLUDED.ownership_percentage,
 *     updated_at = NOW(),
 *     updated_by = EXCLUDED.updated_by
 * RETURNING 
 *     asset_id,
 *     persona_id,
 *     ownership_percentage,
 *     updated_at
 * ```
 */
export const transferOwnershipAddTarget = new PreparedQuery<ITransferOwnershipAddTargetParams,ITransferOwnershipAddTargetResult>(transferOwnershipAddTargetIR);


