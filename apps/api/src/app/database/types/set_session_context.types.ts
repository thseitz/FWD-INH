/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/session/set_session_context.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'SetSessionContext' parameters type */
export type ISetSessionContextParams = void;

/** 'SetSessionContext' return type */
export interface ISetSessionContextResult {
  user_context: string | null;
}

/** 'SetSessionContext' query type */
export interface ISetSessionContextQuery {
  params: ISetSessionContextParams;
  result: ISetSessionContextResult;
}

const setSessionContextIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_set_session_context()\n-- Type: Session Configuration (Side Effect Operation)\n-- Description: Set session context variables for user and tenant\n-- Parameters:\n--   $1: p_user_id UUID - User ID to set in session\n-- Returns: None (void operation)\n-- ================================================================\n\n-- This operation sets PostgreSQL session variables\n-- These need to be executed as separate statements in a transaction\n-- The service layer should execute both statements\n\n-- Statement 1: Set user ID\nSELECT set_config('app.current_user_id', $1::TEXT, true) as user_context"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_set_session_context()
 * -- Type: Session Configuration (Side Effect Operation)
 * -- Description: Set session context variables for user and tenant
 * -- Parameters:
 * --   $1: p_user_id UUID - User ID to set in session
 * -- Returns: None (void operation)
 * -- ================================================================
 * 
 * -- This operation sets PostgreSQL session variables
 * -- These need to be executed as separate statements in a transaction
 * -- The service layer should execute both statements
 * 
 * -- Statement 1: Set user ID
 * SELECT set_config('app.current_user_id', $1::TEXT, true) as user_context
 * ```
 */
export const setSessionContext = new PreparedQuery<ISetSessionContextParams,ISetSessionContextResult>(setSessionContextIR);


