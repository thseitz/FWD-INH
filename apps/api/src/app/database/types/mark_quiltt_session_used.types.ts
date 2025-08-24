/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/mark_quiltt_session_used.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'MarkQuilttSessionUsed' parameters type */
export type IMarkQuilttSessionUsedParams = void;

/** 'MarkQuilttSessionUsed' return type */
export interface IMarkQuilttSessionUsedResult {
  id: string;
  is_used: boolean | null;
  persona_id: string;
  session_token: string;
  used_at: Date | null;
}

/** 'MarkQuilttSessionUsed' query type */
export interface IMarkQuilttSessionUsedQuery {
  params: IMarkQuilttSessionUsedParams;
  result: IMarkQuilttSessionUsedResult;
}

const markQuilttSessionUsedIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: mark_quiltt_session_used\n-- Type: UPDATE\n-- Description: Mark a Quiltt session as used after successful connection\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n-- Returns: Updated session record\n-- Used by: QuilttIntegrationService.handleConnectionWebhook()\n-- ================================================================\n\nUPDATE quiltt_sessions \nSET \n    is_used = TRUE,\n    used_at = NOW()\nWHERE \n    persona_id = $1::UUID \n    AND is_used = FALSE\nRETURNING \n    id,\n    persona_id,\n    session_token,\n    is_used,\n    used_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: mark_quiltt_session_used
 * -- Type: UPDATE
 * -- Description: Mark a Quiltt session as used after successful connection
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * -- Returns: Updated session record
 * -- Used by: QuilttIntegrationService.handleConnectionWebhook()
 * -- ================================================================
 * 
 * UPDATE quiltt_sessions 
 * SET 
 *     is_used = TRUE,
 *     used_at = NOW()
 * WHERE 
 *     persona_id = $1::UUID 
 *     AND is_used = FALSE
 * RETURNING 
 *     id,
 *     persona_id,
 *     session_token,
 *     is_used,
 *     used_at
 * ```
 */
export const markQuilttSessionUsed = new PreparedQuery<IMarkQuilttSessionUsedParams,IMarkQuilttSessionUsedResult>(markQuilttSessionUsedIR);


