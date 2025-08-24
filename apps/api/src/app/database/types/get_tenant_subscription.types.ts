/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/tenants/get_tenant_subscription.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'GetTenantSubscription' parameters type */
export type IGetTenantSubscriptionParams = void;

/** 'GetTenantSubscription' return type */
export interface IGetTenantSubscriptionResult {
  current_period_end: Date | null;
  current_period_start: Date | null;
  next_billing_date: Date | null;
  status: subscription_status_enum;
  stripe_subscription_id: string | null;
  subscription_id: string;
}

/** 'GetTenantSubscription' query type */
export interface IGetTenantSubscriptionQuery {
  params: IGetTenantSubscriptionParams;
  result: IGetTenantSubscriptionResult;
}

const getTenantSubscriptionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_handle_invoice_payment_succeeded()\n-- Type: SELECT\n-- Description: Get active subscription for tenant\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n-- Returns: Active subscription for reference\n-- ================================================================\n\n-- Get the active subscription for this tenant\n\nSELECT \n    id as subscription_id,\n    stripe_subscription_id,\n    status,\n    current_period_start,\n    current_period_end,\n    next_billing_date\nFROM subscriptions\nWHERE tenant_id = $1::INTEGER\n  AND status = 'active'\nORDER BY created_at DESC\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_handle_invoice_payment_succeeded()
 * -- Type: SELECT
 * -- Description: Get active subscription for tenant
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * -- Returns: Active subscription for reference
 * -- ================================================================
 * 
 * -- Get the active subscription for this tenant
 * 
 * SELECT 
 *     id as subscription_id,
 *     stripe_subscription_id,
 *     status,
 *     current_period_start,
 *     current_period_end,
 *     next_billing_date
 * FROM subscriptions
 * WHERE tenant_id = $1::INTEGER
 *   AND status = 'active'
 * ORDER BY created_at DESC
 * LIMIT 1
 * ```
 */
export const getTenantSubscription = new PreparedQuery<IGetTenantSubscriptionParams,IGetTenantSubscriptionResult>(getTenantSubscriptionIR);


