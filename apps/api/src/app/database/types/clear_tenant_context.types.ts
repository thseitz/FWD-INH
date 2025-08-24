/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/session/clear_tenant_context.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ClearTenantContext' parameters type */
export type IClearTenantContextParams = void;

/** 'ClearTenantContext' return type */
export interface IClearTenantContextResult {
  tenant_context: string | null;
}

/** 'ClearTenantContext' query type */
export interface IClearTenantContextQuery {
  params: IClearTenantContextParams;
  result: IClearTenantContextResult;
}

const clearTenantContextIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_clear_session_context() - Part 2\n-- Type: Session Configuration (Side Effect Operation)\n-- Description: Clear tenant context variable from session\n-- Parameters: None\n-- Returns: Configuration result\n-- ================================================================\n\n-- This operation clears PostgreSQL session variable for tenant\n-- Should be executed after clearSessionContext\nSELECT set_config('app.current_tenant_id', NULL, true) as tenant_context"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_clear_session_context() - Part 2
 * -- Type: Session Configuration (Side Effect Operation)
 * -- Description: Clear tenant context variable from session
 * -- Parameters: None
 * -- Returns: Configuration result
 * -- ================================================================
 * 
 * -- This operation clears PostgreSQL session variable for tenant
 * -- Should be executed after clearSessionContext
 * SELECT set_config('app.current_tenant_id', NULL, true) as tenant_context
 * ```
 */
export const clearTenantContext = new PreparedQuery<IClearTenantContextParams,IClearTenantContextResult>(clearTenantContextIR);


