/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/emails/unset_other_primary_emails.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UnsetOtherPrimaryEmails' parameters type */
export type IUnsetOtherPrimaryEmailsParams = void;

/** 'UnsetOtherPrimaryEmails' return type */
export interface IUnsetOtherPrimaryEmailsResult {
  email_id: string;
  id: string;
  is_primary: boolean | null;
}

/** 'UnsetOtherPrimaryEmails' query type */
export interface IUnsetOtherPrimaryEmailsQuery {
  params: IUnsetOtherPrimaryEmailsParams;
  result: IUnsetOtherPrimaryEmailsResult;
}

const unsetOtherPrimaryEmailsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_email_to_persona()\n-- Type: UPDATE\n-- Description: Unset other primary emails for a persona\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n--   $2: p_email_id UUID - The email ID that should remain primary\n-- Returns: Updated records\n-- NOTE: Only run when setting an email as primary\n-- ================================================================\n\n-- This query unsets the is_primary flag for all other emails of the persona\n\nUPDATE usage_email SET\n    is_primary = FALSE,\n    updated_at = NOW()\nWHERE entity_type = 'persona' \n  AND entity_id = $1::UUID \n  AND email_id != $2::UUID\n  AND is_primary = TRUE\nRETURNING \n    id,\n    email_id,\n    is_primary"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_email_to_persona()
 * -- Type: UPDATE
 * -- Description: Unset other primary emails for a persona
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * --   $2: p_email_id UUID - The email ID that should remain primary
 * -- Returns: Updated records
 * -- NOTE: Only run when setting an email as primary
 * -- ================================================================
 * 
 * -- This query unsets the is_primary flag for all other emails of the persona
 * 
 * UPDATE usage_email SET
 *     is_primary = FALSE,
 *     updated_at = NOW()
 * WHERE entity_type = 'persona' 
 *   AND entity_id = $1::UUID 
 *   AND email_id != $2::UUID
 *   AND is_primary = TRUE
 * RETURNING 
 *     id,
 *     email_id,
 *     is_primary
 * ```
 */
export const unsetOtherPrimaryEmails = new PreparedQuery<IUnsetOtherPrimaryEmailsParams,IUnsetOtherPrimaryEmailsResult>(unsetOtherPrimaryEmailsIR);


