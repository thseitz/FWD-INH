/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/session/set_tenant_context.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'SetTenantContext' parameters type */
export type ISetTenantContextParams = void;

/** 'SetTenantContext' return type */
export interface ISetTenantContextResult {
  tenant_context: string | null;
}

/** 'SetTenantContext' query type */
export interface ISetTenantContextQuery {
  params: ISetTenantContextParams;
  result: ISetTenantContextResult;
}

const setTenantContextIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_set_session_context() - Part 2\n-- Type: Session Configuration (Side Effect Operation)\n-- Description: Set tenant context variable for session\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID to set in session\n-- Returns: Configuration result\n-- ================================================================\n\n-- This operation sets PostgreSQL session variable for tenant\n-- Should be executed after setSessionContext\nSELECT set_config('app.current_tenant_id', $1::TEXT, true) as tenant_context"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_set_session_context() - Part 2
 * -- Type: Session Configuration (Side Effect Operation)
 * -- Description: Set tenant context variable for session
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID to set in session
 * -- Returns: Configuration result
 * -- ================================================================
 * 
 * -- This operation sets PostgreSQL session variable for tenant
 * -- Should be executed after setSessionContext
 * SELECT set_config('app.current_tenant_id', $1::TEXT, true) as tenant_context
 * ```
 */
export const setTenantContext = new PreparedQuery<ISetTenantContextParams,ISetTenantContextResult>(setTenantContextIR);


