/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/tenants/get_tenant_payer.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type user_status_enum = 'active' | 'inactive' | 'locked' | 'pending_verification' | 'suspended';

/** 'GetTenantPayer' parameters type */
export type IGetTenantPayerParams = void;

/** 'GetTenantPayer' return type */
export interface IGetTenantPayerResult {
  cognito_user_id: string;
  first_name: string;
  last_name: string;
  payer_id: string;
  status: user_status_enum;
}

/** 'GetTenantPayer' query type */
export interface IGetTenantPayerQuery {
  params: IGetTenantPayerParams;
  result: IGetTenantPayerResult;
}

const getTenantPayerIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_handle_invoice_payment_succeeded()\n-- Type: SELECT\n-- Description: Get primary payer for tenant (usually admin/owner)\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n-- Returns: User who is the payer for this tenant\n-- ================================================================\n\n-- Get the primary user for tenant payments\n\nSELECT \n    u.id as payer_id,\n    u.cognito_user_id,\n    u.first_name,\n    u.last_name,\n    u.status\nFROM users u\nWHERE u.tenant_id = $1::INTEGER\n  AND u.status = 'active'\nORDER BY \n    u.created_at ASC\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_handle_invoice_payment_succeeded()
 * -- Type: SELECT
 * -- Description: Get primary payer for tenant (usually admin/owner)
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * -- Returns: User who is the payer for this tenant
 * -- ================================================================
 * 
 * -- Get the primary user for tenant payments
 * 
 * SELECT 
 *     u.id as payer_id,
 *     u.cognito_user_id,
 *     u.first_name,
 *     u.last_name,
 *     u.status
 * FROM users u
 * WHERE u.tenant_id = $1::INTEGER
 *   AND u.status = 'active'
 * ORDER BY 
 *     u.created_at ASC
 * LIMIT 1
 * ```
 */
export const getTenantPayer = new PreparedQuery<IGetTenantPayerParams,IGetTenantPayerResult>(getTenantPayerIR);


