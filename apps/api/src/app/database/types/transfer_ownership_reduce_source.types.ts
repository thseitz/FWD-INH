/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/transfer_ownership_reduce_source.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'TransferOwnershipReduceSource' parameters type */
export type ITransferOwnershipReduceSourceParams = void;

/** 'TransferOwnershipReduceSource' return type */
export interface ITransferOwnershipReduceSourceResult {
  asset_id: string;
  ownership_percentage: string | null;
  persona_id: string;
}

/** 'TransferOwnershipReduceSource' query type */
export interface ITransferOwnershipReduceSourceQuery {
  params: ITransferOwnershipReduceSourceParams;
  result: ITransferOwnershipReduceSourceResult;
}

const transferOwnershipReduceSourceIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_transfer_asset_ownership() - Partial Transfer\n-- Type: UPDATE\n-- Description: Reduce ownership percentage from source persona\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_from_persona_id UUID - Source persona ID\n--   $3: p_new_percentage DECIMAL(5,2) - New reduced percentage\n--   $4: p_updated_by UUID - User making the transfer (optional)\n-- Returns: Updated ownership record\n-- NOTE: Use when transferring partial ownership\n-- ================================================================\n\n-- Reduce ownership percentage for source persona\n\nUPDATE asset_persona SET\n    ownership_percentage = $3::DECIMAL(5,2),\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $4::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nWHERE asset_id = $1::UUID \n  AND persona_id = $2::UUID\nRETURNING \n    asset_id,\n    persona_id,\n    ownership_percentage"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_transfer_asset_ownership() - Partial Transfer
 * -- Type: UPDATE
 * -- Description: Reduce ownership percentage from source persona
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_from_persona_id UUID - Source persona ID
 * --   $3: p_new_percentage DECIMAL(5,2) - New reduced percentage
 * --   $4: p_updated_by UUID - User making the transfer (optional)
 * -- Returns: Updated ownership record
 * -- NOTE: Use when transferring partial ownership
 * -- ================================================================
 * 
 * -- Reduce ownership percentage for source persona
 * 
 * UPDATE asset_persona SET
 *     ownership_percentage = $3::DECIMAL(5,2),
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $4::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * WHERE asset_id = $1::UUID 
 *   AND persona_id = $2::UUID
 * RETURNING 
 *     asset_id,
 *     persona_id,
 *     ownership_percentage
 * ```
 */
export const transferOwnershipReduceSource = new PreparedQuery<ITransferOwnershipReduceSourceParams,ITransferOwnershipReduceSourceResult>(transferOwnershipReduceSourceIR);


