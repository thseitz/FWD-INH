/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/remove_ffc_member.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

/** 'RemoveFfcMember' parameters type */
export type IRemoveFfcMemberParams = void;

/** 'RemoveFfcMember' return type */
export interface IRemoveFfcMemberResult {
  ffc_id: string;
  ffc_role: ffc_role_enum;
  joined_at: Date | null;
  persona_id: string;
}

/** 'RemoveFfcMember' query type */
export interface IRemoveFfcMemberQuery {
  params: IRemoveFfcMemberParams;
  result: IRemoveFfcMemberResult;
}

const removeFfcMemberIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_remove_ffc_member()\n-- Type: DELETE with validation\n-- Description: Remove persona from FFC (cannot remove owner)\n-- Parameters:\n--   $1: p_ffc_id UUID - FFC ID\n--   $2: p_persona_id UUID - Persona ID to remove\n-- Returns: Deleted FFC member record\n-- NOTE: Service layer should:\n--   1. Check if member exists and is not owner before deletion\n--   2. Handle audit logging separately\n-- ================================================================\n\n-- This query removes a persona from an FFC\n-- Will not delete if role is 'owner' (add WHERE clause)\n-- Returns the deleted record or no rows if not found or is owner\n\nDELETE FROM ffc_personas \nWHERE ffc_id = $1::UUID \n  AND persona_id = $2::UUID\n  AND ffc_role != 'owner'  -- Prevent owner removal\nRETURNING \n    ffc_id,\n    persona_id,\n    ffc_role,\n    joined_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_remove_ffc_member()
 * -- Type: DELETE with validation
 * -- Description: Remove persona from FFC (cannot remove owner)
 * -- Parameters:
 * --   $1: p_ffc_id UUID - FFC ID
 * --   $2: p_persona_id UUID - Persona ID to remove
 * -- Returns: Deleted FFC member record
 * -- NOTE: Service layer should:
 * --   1. Check if member exists and is not owner before deletion
 * --   2. Handle audit logging separately
 * -- ================================================================
 * 
 * -- This query removes a persona from an FFC
 * -- Will not delete if role is 'owner' (add WHERE clause)
 * -- Returns the deleted record or no rows if not found or is owner
 * 
 * DELETE FROM ffc_personas 
 * WHERE ffc_id = $1::UUID 
 *   AND persona_id = $2::UUID
 *   AND ffc_role != 'owner'  -- Prevent owner removal
 * RETURNING 
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     joined_at
 * ```
 */
export const removeFfcMember = new PreparedQuery<IRemoveFfcMemberParams,IRemoveFfcMemberResult>(removeFfcMemberIR);


