/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/get_asset_ownership.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ownership_type_enum = 'beneficiary' | 'executor' | 'owner' | 'trustee';

/** 'GetAssetOwnership' parameters type */
export type IGetAssetOwnershipParams = void;

/** 'GetAssetOwnership' return type */
export interface IGetAssetOwnershipResult {
  is_primary: boolean | null;
  ownership_percentage: string | null;
  ownership_type: ownership_type_enum;
}

/** 'GetAssetOwnership' query type */
export interface IGetAssetOwnershipQuery {
  params: IGetAssetOwnershipParams;
  result: IGetAssetOwnershipResult;
}

const getAssetOwnershipIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_transfer_asset_ownership()\n-- Type: SELECT\n-- Description: Get current ownership percentage for validation\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_persona_id UUID - Persona ID\n-- Returns: Current ownership details\n-- ================================================================\n\n-- Get current ownership percentage for a persona\n\nSELECT \n    ownership_percentage,\n    ownership_type,\n    is_primary\nFROM asset_persona \nWHERE asset_id = $1::UUID \n  AND persona_id = $2::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_transfer_asset_ownership()
 * -- Type: SELECT
 * -- Description: Get current ownership percentage for validation
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_persona_id UUID - Persona ID
 * -- Returns: Current ownership details
 * -- ================================================================
 * 
 * -- Get current ownership percentage for a persona
 * 
 * SELECT 
 *     ownership_percentage,
 *     ownership_type,
 *     is_primary
 * FROM asset_persona 
 * WHERE asset_id = $1::UUID 
 *   AND persona_id = $2::UUID
 * ```
 */
export const getAssetOwnership = new PreparedQuery<IGetAssetOwnershipParams,IGetAssetOwnershipResult>(getAssetOwnershipIR);


