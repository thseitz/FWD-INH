/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/check_asset_ownership_total.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CheckAssetOwnershipTotal' parameters type */
export type ICheckAssetOwnershipTotalParams = void;

/** 'CheckAssetOwnershipTotal' return type */
export interface ICheckAssetOwnershipTotalResult {
  total_percentage: string | null;
}

/** 'CheckAssetOwnershipTotal' query type */
export interface ICheckAssetOwnershipTotalQuery {
  params: ICheckAssetOwnershipTotalParams;
  result: ICheckAssetOwnershipTotalResult;
}

const checkAssetOwnershipTotalIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_assign_asset_to_persona()\n-- Type: SELECT for validation\n-- Description: Check total ownership percentage for an asset\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_persona_id UUID - Persona ID to exclude (for updates)\n-- Returns: Current total ownership percentage\n-- NOTE: Use this before inserting/updating to validate total <= 100%\n-- ================================================================\n\n-- This query calculates the current total ownership percentage\n-- Excludes the persona being updated to avoid double-counting\n\nSELECT \n    COALESCE(SUM(ownership_percentage), 0) as total_percentage\nFROM asset_persona \nWHERE asset_id = $1::UUID\n  AND ($2::UUID IS NULL OR persona_id != $2::UUID)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_assign_asset_to_persona()
 * -- Type: SELECT for validation
 * -- Description: Check total ownership percentage for an asset
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_persona_id UUID - Persona ID to exclude (for updates)
 * -- Returns: Current total ownership percentage
 * -- NOTE: Use this before inserting/updating to validate total <= 100%
 * -- ================================================================
 * 
 * -- This query calculates the current total ownership percentage
 * -- Excludes the persona being updated to avoid double-counting
 * 
 * SELECT 
 *     COALESCE(SUM(ownership_percentage), 0) as total_percentage
 * FROM asset_persona 
 * WHERE asset_id = $1::UUID
 *   AND ($2::UUID IS NULL OR persona_id != $2::UUID)
 * ```
 */
export const checkAssetOwnershipTotal = new PreparedQuery<ICheckAssetOwnershipTotalParams,ICheckAssetOwnershipTotalResult>(checkAssetOwnershipTotalIR);


