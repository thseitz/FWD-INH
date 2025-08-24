/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/update_subscription_billing.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'UpdateSubscriptionBilling' parameters type */
export type IUpdateSubscriptionBillingParams = void;

/** 'UpdateSubscriptionBilling' return type */
export interface IUpdateSubscriptionBillingResult {
  current_period_end: Date | null;
  id: string;
  next_billing_date: Date | null;
  status: subscription_status_enum;
}

/** 'UpdateSubscriptionBilling' query type */
export interface IUpdateSubscriptionBillingQuery {
  params: IUpdateSubscriptionBillingParams;
  result: IUpdateSubscriptionBillingResult;
}

const updateSubscriptionBillingIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_invoice_payment_succeeded() - Step 2\n-- Type: UPDATE\n-- Description: Update subscription billing dates after invoice payment\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n-- Returns: Updated subscription records\n-- ================================================================\n\n-- Update subscription billing dates for active subscriptions\n\nUPDATE subscriptions\nSET \n    next_billing_date = (current_period_end + INTERVAL '1 month')::date,\n    updated_at = NOW()\nWHERE tenant_id = $1::INTEGER\n  AND status = 'active'\nRETURNING \n    id,\n    next_billing_date,\n    current_period_end,\n    status"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_invoice_payment_succeeded() - Step 2
 * -- Type: UPDATE
 * -- Description: Update subscription billing dates after invoice payment
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * -- Returns: Updated subscription records
 * -- ================================================================
 * 
 * -- Update subscription billing dates for active subscriptions
 * 
 * UPDATE subscriptions
 * SET 
 *     next_billing_date = (current_period_end + INTERVAL '1 month')::date,
 *     updated_at = NOW()
 * WHERE tenant_id = $1::INTEGER
 *   AND status = 'active'
 * RETURNING 
 *     id,
 *     next_billing_date,
 *     current_period_end,
 *     status
 * ```
 */
export const updateSubscriptionBilling = new PreparedQuery<IUpdateSubscriptionBillingParams,IUpdateSubscriptionBillingResult>(updateSubscriptionBillingIR);


