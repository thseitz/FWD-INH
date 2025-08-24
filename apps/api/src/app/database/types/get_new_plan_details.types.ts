/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/plans/get_new_plan_details.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type billing_frequency_enum = 'annual' | 'lifetime' | 'monthly' | 'one_time';

export type plan_type_enum = 'free' | 'paid' | 'sponsored';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetNewPlanDetails' parameters type */
export type IGetNewPlanDetailsParams = void;

/** 'GetNewPlanDetails' return type */
export interface IGetNewPlanDetailsResult {
  base_price: string;
  billing_frequency: billing_frequency_enum;
  features: Json | null;
  id: string;
  max_seats: number | null;
  plan_name: string;
  plan_type: plan_type_enum;
}

/** 'GetNewPlanDetails' query type */
export interface IGetNewPlanDetailsQuery {
  params: IGetNewPlanDetailsParams;
  result: IGetNewPlanDetailsResult;
}

const getNewPlanDetailsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_transition_subscription_plan() - Part 2\n-- Type: SELECT\n-- Description: Get new plan details for transition\n-- Parameters:\n--   $1: p_new_plan_id UUID - New plan ID\n-- Returns: New plan details\n-- ================================================================\n\n-- Get new plan details\n\nSELECT \n    id,\n    plan_name,\n    plan_type,\n    base_price,\n    billing_frequency,\n    COALESCE((features->>'max_seats')::INTEGER, 10) as max_seats,\n    features\nFROM plans\nWHERE id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_transition_subscription_plan() - Part 2
 * -- Type: SELECT
 * -- Description: Get new plan details for transition
 * -- Parameters:
 * --   $1: p_new_plan_id UUID - New plan ID
 * -- Returns: New plan details
 * -- ================================================================
 * 
 * -- Get new plan details
 * 
 * SELECT 
 *     id,
 *     plan_name,
 *     plan_type,
 *     base_price,
 *     billing_frequency,
 *     COALESCE((features->>'max_seats')::INTEGER, 10) as max_seats,
 *     features
 * FROM plans
 * WHERE id = $1::UUID
 * ```
 */
export const getNewPlanDetails = new PreparedQuery<IGetNewPlanDetailsParams,IGetNewPlanDetailsResult>(getNewPlanDetailsIR);


