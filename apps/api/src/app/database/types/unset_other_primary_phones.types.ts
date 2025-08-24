/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/phones/unset_other_primary_phones.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UnsetOtherPrimaryPhones' parameters type */
export type IUnsetOtherPrimaryPhonesParams = void;

/** 'UnsetOtherPrimaryPhones' return type */
export interface IUnsetOtherPrimaryPhonesResult {
  id: string;
  is_primary: boolean | null;
  phone_id: string;
}

/** 'UnsetOtherPrimaryPhones' query type */
export interface IUnsetOtherPrimaryPhonesQuery {
  params: IUnsetOtherPrimaryPhonesParams;
  result: IUnsetOtherPrimaryPhonesResult;
}

const unsetOtherPrimaryPhonesIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_phone_to_persona()\n-- Type: UPDATE\n-- Description: Unset other primary phones for a persona\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n--   $2: p_phone_id UUID - The phone ID that should remain primary\n-- Returns: Updated records\n-- NOTE: Only run when setting a phone as primary\n-- ================================================================\n\n-- This query unsets the is_primary flag for all other phones of the persona\n\nUPDATE usage_phone SET\n    is_primary = FALSE,\n    updated_at = NOW()\nWHERE entity_type = 'persona' \n  AND entity_id = $1::UUID \n  AND phone_id != $2::UUID\n  AND is_primary = TRUE\nRETURNING \n    id,\n    phone_id,\n    is_primary"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_phone_to_persona()
 * -- Type: UPDATE
 * -- Description: Unset other primary phones for a persona
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * --   $2: p_phone_id UUID - The phone ID that should remain primary
 * -- Returns: Updated records
 * -- NOTE: Only run when setting a phone as primary
 * -- ================================================================
 * 
 * -- This query unsets the is_primary flag for all other phones of the persona
 * 
 * UPDATE usage_phone SET
 *     is_primary = FALSE,
 *     updated_at = NOW()
 * WHERE entity_type = 'persona' 
 *   AND entity_id = $1::UUID 
 *   AND phone_id != $2::UUID
 *   AND is_primary = TRUE
 * RETURNING 
 *     id,
 *     phone_id,
 *     is_primary
 * ```
 */
export const unsetOtherPrimaryPhones = new PreparedQuery<IUnsetOtherPrimaryPhonesParams,IUnsetOtherPrimaryPhonesResult>(unsetOtherPrimaryPhonesIR);


