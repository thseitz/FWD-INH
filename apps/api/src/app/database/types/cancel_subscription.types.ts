/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/cancellations/cancel_subscription.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'CancelSubscription' parameters type */
export type ICancelSubscriptionParams = void;

/** 'CancelSubscription' return type */
export interface ICancelSubscriptionResult {
  cancel_reason: string | null;
  canceled_at: Date | null;
  ffc_id: string;
  id: string;
  status: subscription_status_enum;
  tenant_id: number;
}

/** 'CancelSubscription' query type */
export interface ICancelSubscriptionQuery {
  params: ICancelSubscriptionParams;
  result: ICancelSubscriptionResult;
}

const cancelSubscriptionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_cancel_subscription() - Part 2\n-- Type: UPDATE\n-- Description: Cancel a subscription\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID to cancel\n--   $2: p_reason TEXT - Cancellation reason (optional)\n-- Returns: Updated subscription record\n-- ================================================================\n\n-- Update subscription status to canceled\n\nUPDATE subscriptions\nSET \n    status = 'canceled',\n    canceled_at = NOW(),\n    cancel_reason = $2::TEXT,\n    updated_at = NOW()\nWHERE id = $1::UUID\n  AND status != 'canceled'\nRETURNING \n    id,\n    tenant_id,\n    ffc_id,\n    status,\n    canceled_at,\n    cancel_reason"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_cancel_subscription() - Part 2
 * -- Type: UPDATE
 * -- Description: Cancel a subscription
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID to cancel
 * --   $2: p_reason TEXT - Cancellation reason (optional)
 * -- Returns: Updated subscription record
 * -- ================================================================
 * 
 * -- Update subscription status to canceled
 * 
 * UPDATE subscriptions
 * SET 
 *     status = 'canceled',
 *     canceled_at = NOW(),
 *     cancel_reason = $2::TEXT,
 *     updated_at = NOW()
 * WHERE id = $1::UUID
 *   AND status != 'canceled'
 * RETURNING 
 *     id,
 *     tenant_id,
 *     ffc_id,
 *     status,
 *     canceled_at,
 *     cancel_reason
 * ```
 */
export const cancelSubscription = new PreparedQuery<ICancelSubscriptionParams,ICancelSubscriptionResult>(cancelSubscriptionIR);


