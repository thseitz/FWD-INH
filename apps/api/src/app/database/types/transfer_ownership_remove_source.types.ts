/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/transfer_ownership_remove_source.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'TransferOwnershipRemoveSource' parameters type */
export type ITransferOwnershipRemoveSourceParams = void;

/** 'TransferOwnershipRemoveSource' return type */
export interface ITransferOwnershipRemoveSourceResult {
  asset_id: string;
  ownership_percentage: string | null;
  persona_id: string;
}

/** 'TransferOwnershipRemoveSource' query type */
export interface ITransferOwnershipRemoveSourceQuery {
  params: ITransferOwnershipRemoveSourceParams;
  result: ITransferOwnershipRemoveSourceResult;
}

const transferOwnershipRemoveSourceIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_transfer_asset_ownership() - Full Transfer\n-- Type: DELETE\n-- Description: Remove ownership from source persona (full transfer)\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_from_persona_id UUID - Source persona ID\n-- Returns: Deleted ownership record\n-- NOTE: Use when transferring 100% ownership\n-- ================================================================\n\n-- Remove ownership completely from source persona\n\nDELETE FROM asset_persona \nWHERE asset_id = $1::UUID \n  AND persona_id = $2::UUID\nRETURNING \n    asset_id,\n    persona_id,\n    ownership_percentage"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_transfer_asset_ownership() - Full Transfer
 * -- Type: DELETE
 * -- Description: Remove ownership from source persona (full transfer)
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_from_persona_id UUID - Source persona ID
 * -- Returns: Deleted ownership record
 * -- NOTE: Use when transferring 100% ownership
 * -- ================================================================
 * 
 * -- Remove ownership completely from source persona
 * 
 * DELETE FROM asset_persona 
 * WHERE asset_id = $1::UUID 
 *   AND persona_id = $2::UUID
 * RETURNING 
 *     asset_id,
 *     persona_id,
 *     ownership_percentage
 * ```
 */
export const transferOwnershipRemoveSource = new PreparedQuery<ITransferOwnershipRemoveSourceParams,ITransferOwnershipRemoveSourceResult>(transferOwnershipRemoveSourceIR);


