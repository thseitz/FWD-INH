/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/tenants/current_tenant_id.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetCurrentTenantId' parameters type */
export type IGetCurrentTenantIdParams = void;

/** 'GetCurrentTenantId' return type */
export interface IGetCurrentTenantIdResult {
  tenant_id: number | null;
}

/** 'GetCurrentTenantId' query type */
export interface IGetCurrentTenantIdQuery {
  params: IGetCurrentTenantIdParams;
  result: IGetCurrentTenantIdResult;
}

const getCurrentTenantIdIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: current_tenant_id()\n-- Type: Simple Read-Only Query\n-- Description: Get current tenant ID from session context\n-- Parameters: None\n-- Returns: INTEGER\n-- ================================================================\n\n-- This query retrieves the tenant ID from the PostgreSQL session context\n-- The application must set this value using: SET LOCAL app.current_tenant_id = '1'\n-- Returns NULL if not set\n\nSELECT \n    CASE \n        WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n        THEN NULL\n        ELSE current_setting('app.current_tenant_id', true)::INTEGER\n    END as tenant_id"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: current_tenant_id()
 * -- Type: Simple Read-Only Query
 * -- Description: Get current tenant ID from session context
 * -- Parameters: None
 * -- Returns: INTEGER
 * -- ================================================================
 * 
 * -- This query retrieves the tenant ID from the PostgreSQL session context
 * -- The application must set this value using: SET LOCAL app.current_tenant_id = '1'
 * -- Returns NULL if not set
 * 
 * SELECT 
 *     CASE 
 *         WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *         THEN NULL
 *         ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *     END as tenant_id
 * ```
 */
export const getCurrentTenantId = new PreparedQuery<IGetCurrentTenantIdParams,IGetCurrentTenantIdResult>(getCurrentTenantIdIR);


