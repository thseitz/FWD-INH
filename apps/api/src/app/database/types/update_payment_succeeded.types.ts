/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/update_payment_succeeded.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type payment_status_enum = 'failed' | 'partially_refunded' | 'pending' | 'refunded' | 'succeeded';

/** 'UpdatePaymentSucceeded' parameters type */
export type IUpdatePaymentSucceededParams = void;

/** 'UpdatePaymentSucceeded' return type */
export interface IUpdatePaymentSucceededResult {
  amount: string;
  currency: string;
  id: string;
  payer_id: string;
  processed_at: Date | null;
  status: payment_status_enum;
  tenant_id: number;
}

/** 'UpdatePaymentSucceeded' query type */
export interface IUpdatePaymentSucceededQuery {
  params: IUpdatePaymentSucceededParams;
  result: IUpdatePaymentSucceededResult;
}

const updatePaymentSucceededIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_payment_succeeded() - Part 1\n-- Type: UPDATE\n-- Description: Update payment status to succeeded\n-- Parameters:\n--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID\n--   $2: p_tenant_id INTEGER - Tenant ID\n-- Returns: Updated payment record\n-- ================================================================\n\n-- Update payment status when payment succeeds\n\nUPDATE payments\nSET \n    status = 'succeeded',\n    processed_at = NOW()\nWHERE stripe_payment_intent_id = $1::TEXT\n  AND tenant_id = $2::INTEGER\nRETURNING \n    id,\n    tenant_id,\n    payer_id,\n    amount,\n    currency,\n    status,\n    processed_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_payment_succeeded() - Part 1
 * -- Type: UPDATE
 * -- Description: Update payment status to succeeded
 * -- Parameters:
 * --   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
 * --   $2: p_tenant_id INTEGER - Tenant ID
 * -- Returns: Updated payment record
 * -- ================================================================
 * 
 * -- Update payment status when payment succeeds
 * 
 * UPDATE payments
 * SET 
 *     status = 'succeeded',
 *     processed_at = NOW()
 * WHERE stripe_payment_intent_id = $1::TEXT
 *   AND tenant_id = $2::INTEGER
 * RETURNING 
 *     id,
 *     tenant_id,
 *     payer_id,
 *     amount,
 *     currency,
 *     status,
 *     processed_at
 * ```
 */
export const updatePaymentSucceeded = new PreparedQuery<IUpdatePaymentSucceededParams,IUpdatePaymentSucceededResult>(updatePaymentSucceededIR);


