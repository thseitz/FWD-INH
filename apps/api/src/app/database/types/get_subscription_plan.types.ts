/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/plans/get_subscription_plan.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type plan_type_enum = 'free' | 'paid' | 'sponsored';

/** 'GetSubscriptionPlan' parameters type */
export type IGetSubscriptionPlanParams = void;

/** 'GetSubscriptionPlan' return type */
export interface IGetSubscriptionPlanResult {
  base_price: string;
  ffc_id: string;
  id: string;
  plan_id: string;
  plan_name: string;
  plan_type: plan_type_enum;
  tenant_id: number;
}

/** 'GetSubscriptionPlan' query type */
export interface IGetSubscriptionPlanQuery {
  params: IGetSubscriptionPlanParams;
  result: IGetSubscriptionPlanResult;
}

const getSubscriptionPlanIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_transition_subscription_plan() - Part 1\n-- Type: SELECT\n-- Description: Get current subscription plan\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID\n-- Returns: Current plan details\n-- ================================================================\n\n-- Get current subscription plan details\n\nSELECT \n    s.id,\n    s.plan_id,\n    s.tenant_id,\n    s.ffc_id,\n    p.base_price,\n    p.plan_name,\n    p.plan_type\nFROM subscriptions s\nJOIN plans p ON p.id = s.plan_id\nWHERE s.id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_transition_subscription_plan() - Part 1
 * -- Type: SELECT
 * -- Description: Get current subscription plan
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID
 * -- Returns: Current plan details
 * -- ================================================================
 * 
 * -- Get current subscription plan details
 * 
 * SELECT 
 *     s.id,
 *     s.plan_id,
 *     s.tenant_id,
 *     s.ffc_id,
 *     p.base_price,
 *     p.plan_name,
 *     p.plan_type
 * FROM subscriptions s
 * JOIN plans p ON p.id = s.plan_id
 * WHERE s.id = $1::UUID
 * ```
 */
export const getSubscriptionPlan = new PreparedQuery<IGetSubscriptionPlanParams,IGetSubscriptionPlanResult>(getSubscriptionPlanIR);


