/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/validate_quiltt_deactivate_expired.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ValidateQuilttDeactivateExpired' parameters type */
export type IValidateQuilttDeactivateExpiredParams = void;

/** 'ValidateQuilttDeactivateExpired' return type */
export interface IValidateQuilttDeactivateExpiredResult {
  id: string;
  is_active: boolean | null;
  persona_id: string;
  token_expires_at: Date | null;
  updated_at: Date | null;
}

/** 'ValidateQuilttDeactivateExpired' query type */
export interface IValidateQuilttDeactivateExpiredQuery {
  params: IValidateQuilttDeactivateExpiredParams;
  result: IValidateQuilttDeactivateExpiredResult;
}

const validateQuilttDeactivateExpiredIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_validate_quiltt_credentials() - Part 2\n-- Type: UPDATE\n-- Description: Deactivate expired Quiltt integration\n-- Parameters:\n--   $1: p_integration_id UUID - Integration ID to deactivate\n-- Returns: Updated integration record\n-- ================================================================\n\n-- Deactivate expired Quiltt integration\n\nUPDATE quiltt_integrations SET\n    is_active = FALSE,\n    sync_error = 'Token expired - integration deactivated',\n    updated_at = NOW()\nWHERE id = $1::UUID\nRETURNING \n    id,\n    persona_id,\n    is_active,\n    token_expires_at,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_validate_quiltt_credentials() - Part 2
 * -- Type: UPDATE
 * -- Description: Deactivate expired Quiltt integration
 * -- Parameters:
 * --   $1: p_integration_id UUID - Integration ID to deactivate
 * -- Returns: Updated integration record
 * -- ================================================================
 * 
 * -- Deactivate expired Quiltt integration
 * 
 * UPDATE quiltt_integrations SET
 *     is_active = FALSE,
 *     sync_error = 'Token expired - integration deactivated',
 *     updated_at = NOW()
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     persona_id,
 *     is_active,
 *     token_expires_at,
 *     updated_at
 * ```
 */
export const validateQuilttDeactivateExpired = new PreparedQuery<IValidateQuilttDeactivateExpiredParams,IValidateQuilttDeactivateExpiredResult>(validateQuilttDeactivateExpiredIR);


