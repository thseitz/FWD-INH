/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/session/clear_session_context.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ClearSessionContext' parameters type */
export type IClearSessionContextParams = void;

/** 'ClearSessionContext' return type */
export interface IClearSessionContextResult {
  user_context: string | null;
}

/** 'ClearSessionContext' query type */
export interface IClearSessionContextQuery {
  params: IClearSessionContextParams;
  result: IClearSessionContextResult;
}

const clearSessionContextIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_clear_session_context()\n-- Type: Session Configuration (Side Effect Operation)\n-- Description: Clear session context variables\n-- Parameters: None\n-- Returns: None (void operation)\n-- ================================================================\n\n-- This operation clears PostgreSQL session variables\n-- These need to be executed as separate statements\n-- The service layer should execute both statements\n\n-- Statement 1: Clear user ID\nSELECT set_config('app.current_user_id', NULL, true) as user_context"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_clear_session_context()
 * -- Type: Session Configuration (Side Effect Operation)
 * -- Description: Clear session context variables
 * -- Parameters: None
 * -- Returns: None (void operation)
 * -- ================================================================
 * 
 * -- This operation clears PostgreSQL session variables
 * -- These need to be executed as separate statements
 * -- The service layer should execute both statements
 * 
 * -- Statement 1: Clear user ID
 * SELECT set_config('app.current_user_id', NULL, true) as user_context
 * ```
 */
export const clearSessionContext = new PreparedQuery<IClearSessionContextParams,IClearSessionContextResult>(clearSessionContextIR);


