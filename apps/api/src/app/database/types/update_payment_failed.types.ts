/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/update_payment_failed.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type payment_status_enum = 'failed' | 'partially_refunded' | 'pending' | 'refunded' | 'succeeded';

/** 'UpdatePaymentFailed' parameters type */
export type IUpdatePaymentFailedParams = void;

/** 'UpdatePaymentFailed' return type */
export interface IUpdatePaymentFailedResult {
  failure_reason: string | null;
  id: string;
  processed_at: Date | null;
  status: payment_status_enum;
  stripe_payment_intent_id: string | null;
}

/** 'UpdatePaymentFailed' query type */
export interface IUpdatePaymentFailedQuery {
  params: IUpdatePaymentFailedParams;
  result: IUpdatePaymentFailedResult;
}

const updatePaymentFailedIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_payment_failed()\n-- Type: UPDATE\n-- Description: Update payment status to failed\n-- Parameters:\n--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID\n--   $2: p_failure_reason TEXT - Reason for failure\n--   $3: p_tenant_id INTEGER - Tenant ID\n-- Returns: Updated payment record\n-- ================================================================\n\n-- Update payment status when Stripe reports failure\n\nUPDATE payments\nSET \n    status = 'failed',\n    failure_reason = $2::TEXT,\n    processed_at = NOW(),\n    updated_at = NOW()\nWHERE stripe_payment_intent_id = $1::TEXT\n  AND tenant_id = $3::INTEGER\nRETURNING \n    id,\n    stripe_payment_intent_id,\n    status,\n    failure_reason,\n    processed_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_payment_failed()
 * -- Type: UPDATE
 * -- Description: Update payment status to failed
 * -- Parameters:
 * --   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
 * --   $2: p_failure_reason TEXT - Reason for failure
 * --   $3: p_tenant_id INTEGER - Tenant ID
 * -- Returns: Updated payment record
 * -- ================================================================
 * 
 * -- Update payment status when Stripe reports failure
 * 
 * UPDATE payments
 * SET 
 *     status = 'failed',
 *     failure_reason = $2::TEXT,
 *     processed_at = NOW(),
 *     updated_at = NOW()
 * WHERE stripe_payment_intent_id = $1::TEXT
 *   AND tenant_id = $3::INTEGER
 * RETURNING 
 *     id,
 *     stripe_payment_intent_id,
 *     status,
 *     failure_reason,
 *     processed_at
 * ```
 */
export const updatePaymentFailed = new PreparedQuery<IUpdatePaymentFailedParams,IUpdatePaymentFailedResult>(updatePaymentFailedIR);


