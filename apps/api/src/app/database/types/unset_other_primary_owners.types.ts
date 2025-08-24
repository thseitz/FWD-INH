/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/unset_other_primary_owners.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UnsetOtherPrimaryOwners' parameters type */
export type IUnsetOtherPrimaryOwnersParams = void;

/** 'UnsetOtherPrimaryOwners' return type */
export interface IUnsetOtherPrimaryOwnersResult {
  id: string;
  is_primary: boolean | null;
  persona_id: string;
  updated_at: Date | null;
}

/** 'UnsetOtherPrimaryOwners' query type */
export interface IUnsetOtherPrimaryOwnersQuery {
  params: IUnsetOtherPrimaryOwnersParams;
  result: IUnsetOtherPrimaryOwnersResult;
}

const unsetOtherPrimaryOwnersIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_assign_asset_to_persona()\n-- Type: UPDATE\n-- Description: Unset other primary owners when setting a new primary\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_persona_id UUID - The persona ID that should remain primary\n--   $3: p_updated_by UUID - User making the update (optional)\n-- Returns: Updated records\n-- NOTE: Only run this when setting a persona as primary owner\n-- ================================================================\n\n-- This query unsets the is_primary flag for all other personas on the asset\n-- Should be run after setting a new primary owner\n\nUPDATE asset_persona SET\n    is_primary = FALSE,\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $3::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nWHERE asset_id = $1::UUID \n  AND persona_id != $2::UUID \n  AND is_primary = TRUE\nRETURNING \n    id,\n    persona_id,\n    is_primary,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_assign_asset_to_persona()
 * -- Type: UPDATE
 * -- Description: Unset other primary owners when setting a new primary
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_persona_id UUID - The persona ID that should remain primary
 * --   $3: p_updated_by UUID - User making the update (optional)
 * -- Returns: Updated records
 * -- NOTE: Only run this when setting a persona as primary owner
 * -- ================================================================
 * 
 * -- This query unsets the is_primary flag for all other personas on the asset
 * -- Should be run after setting a new primary owner
 * 
 * UPDATE asset_persona SET
 *     is_primary = FALSE,
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $3::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * WHERE asset_id = $1::UUID 
 *   AND persona_id != $2::UUID 
 *   AND is_primary = TRUE
 * RETURNING 
 *     id,
 *     persona_id,
 *     is_primary,
 *     updated_at
 * ```
 */
export const unsetOtherPrimaryOwners = new PreparedQuery<IUnsetOtherPrimaryOwnersParams,IUnsetOtherPrimaryOwnersResult>(unsetOtherPrimaryOwnersIR);


