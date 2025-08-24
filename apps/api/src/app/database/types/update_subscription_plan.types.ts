/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/plans/update_subscription_plan.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'UpdateSubscriptionPlan' parameters type */
export type IUpdateSubscriptionPlanParams = void;

/** 'UpdateSubscriptionPlan' return type */
export interface IUpdateSubscriptionPlanResult {
  ffc_id: string;
  id: string;
  plan_id: string;
  status: subscription_status_enum;
  tenant_id: number;
  updated_at: Date;
}

/** 'UpdateSubscriptionPlan' query type */
export interface IUpdateSubscriptionPlanQuery {
  params: IUpdateSubscriptionPlanParams;
  result: IUpdateSubscriptionPlanResult;
}

const updateSubscriptionPlanIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_transition_subscription_plan() - Part 4\n-- Type: UPDATE\n-- Description: Update subscription with new plan\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID\n--   $2: p_new_plan_id UUID - New plan ID\n-- Returns: Updated subscription record\n-- ================================================================\n\n-- Update subscription with new plan\n\nUPDATE subscriptions\nSET \n    plan_id = $2::UUID,\n    updated_at = NOW()\nWHERE id = $1::UUID\nRETURNING \n    id,\n    tenant_id,\n    ffc_id,\n    plan_id,\n    status,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_transition_subscription_plan() - Part 4
 * -- Type: UPDATE
 * -- Description: Update subscription with new plan
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID
 * --   $2: p_new_plan_id UUID - New plan ID
 * -- Returns: Updated subscription record
 * -- ================================================================
 * 
 * -- Update subscription with new plan
 * 
 * UPDATE subscriptions
 * SET 
 *     plan_id = $2::UUID,
 *     updated_at = NOW()
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     tenant_id,
 *     ffc_id,
 *     plan_id,
 *     status,
 *     updated_at
 * ```
 */
export const updateSubscriptionPlan = new PreparedQuery<IUpdateSubscriptionPlanParams,IUpdateSubscriptionPlanResult>(updateSubscriptionPlanIR);


