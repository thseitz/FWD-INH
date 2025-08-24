/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/update_ffc_member_role.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

/** 'UpdateFfcMemberRole' parameters type */
export type IUpdateFfcMemberRoleParams = void;

/** 'UpdateFfcMemberRole' return type */
export interface IUpdateFfcMemberRoleResult {
  ffc_id: string;
  ffc_role: ffc_role_enum;
  persona_id: string;
  updated_at: Date | null;
  updated_by: string | null;
}

/** 'UpdateFfcMemberRole' query type */
export interface IUpdateFfcMemberRoleQuery {
  params: IUpdateFfcMemberRoleParams;
  result: IUpdateFfcMemberRoleResult;
}

const updateFfcMemberRoleIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_ffc_member_role()\n-- Type: Simple UPDATE Operation\n-- Description: Update FFC member role\n-- Parameters:\n--   $1: p_ffc_id UUID - FFC ID\n--   $2: p_persona_id UUID - Persona ID\n--   $3: p_new_role ffc_role_enum - New role to assign\n--   $4: p_updated_by UUID - User performing update (optional)\n-- Returns: Updated FFC member record\n-- ================================================================\n\n-- This query updates an FFC member's role\n-- NOTE: The audit log insert needs to be handled separately in the service layer\n-- Returns the updated record or no rows if member not found\n\nUPDATE ffc_personas SET\n    ffc_role = $3::ffc_role_enum,\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $4::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nWHERE ffc_id = $1::UUID \n  AND persona_id = $2::UUID\nRETURNING \n    ffc_id,\n    persona_id,\n    ffc_role,\n    updated_at,\n    updated_by"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_ffc_member_role()
 * -- Type: Simple UPDATE Operation
 * -- Description: Update FFC member role
 * -- Parameters:
 * --   $1: p_ffc_id UUID - FFC ID
 * --   $2: p_persona_id UUID - Persona ID
 * --   $3: p_new_role ffc_role_enum - New role to assign
 * --   $4: p_updated_by UUID - User performing update (optional)
 * -- Returns: Updated FFC member record
 * -- ================================================================
 * 
 * -- This query updates an FFC member's role
 * -- NOTE: The audit log insert needs to be handled separately in the service layer
 * -- Returns the updated record or no rows if member not found
 * 
 * UPDATE ffc_personas SET
 *     ffc_role = $3::ffc_role_enum,
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $4::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * WHERE ffc_id = $1::UUID 
 *   AND persona_id = $2::UUID
 * RETURNING 
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     updated_at,
 *     updated_by
 * ```
 */
export const updateFfcMemberRole = new PreparedQuery<IUpdateFfcMemberRoleParams,IUpdateFfcMemberRoleResult>(updateFfcMemberRoleIR);


