/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/cancellations/get_subscription_for_cancel.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'GetSubscriptionForCancel' parameters type */
export type IGetSubscriptionForCancelParams = void;

/** 'GetSubscriptionForCancel' return type */
export interface IGetSubscriptionForCancelResult {
  ffc_id: string;
  id: string;
  plan_id: string;
  status: subscription_status_enum;
  stripe_subscription_id: string | null;
  tenant_id: number;
}

/** 'GetSubscriptionForCancel' query type */
export interface IGetSubscriptionForCancelQuery {
  params: IGetSubscriptionForCancelParams;
  result: IGetSubscriptionForCancelResult;
}

const getSubscriptionForCancelIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_cancel_subscription() - Part 1\n-- Type: SELECT\n-- Description: Get subscription details for cancellation\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID\n-- Returns: Subscription details\n-- ================================================================\n\n-- Get subscription details and verify it exists\n\nSELECT \n    id,\n    status,\n    tenant_id,\n    ffc_id,\n    plan_id,\n    stripe_subscription_id\nFROM subscriptions\nWHERE id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_cancel_subscription() - Part 1
 * -- Type: SELECT
 * -- Description: Get subscription details for cancellation
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID
 * -- Returns: Subscription details
 * -- ================================================================
 * 
 * -- Get subscription details and verify it exists
 * 
 * SELECT 
 *     id,
 *     status,
 *     tenant_id,
 *     ffc_id,
 *     plan_id,
 *     stripe_subscription_id
 * FROM subscriptions
 * WHERE id = $1::UUID
 * ```
 */
export const getSubscriptionForCancel = new PreparedQuery<IGetSubscriptionForCancelParams,IGetSubscriptionForCancelResult>(getSubscriptionForCancelIR);


