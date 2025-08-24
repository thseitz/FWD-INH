/** Types generated for queries found in "apps/api/src/app/database/queries/10_reporting/dashboards/get_subscription_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type billing_frequency_enum = 'annual' | 'lifetime' | 'monthly' | 'one_time';

export type plan_type_enum = 'free' | 'paid' | 'sponsored';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

/** 'GetSubscriptionStatus' parameters type */
export type IGetSubscriptionStatusParams = void;

/** 'GetSubscriptionStatus' return type */
export interface IGetSubscriptionStatusResult {
  billing_amount: string;
  billing_frequency: billing_frequency_enum;
  cancel_reason: string | null;
  canceled_at: Date | null;
  current_period_end: Date | null;
  next_billing_date: Date | null;
  plan_name: string;
  plan_type: plan_type_enum;
  status: subscription_status_enum;
  subscription_id: string;
  total_active_seats: string | null;
  total_seats: string | null;
}

/** 'GetSubscriptionStatus' query type */
export interface IGetSubscriptionStatusQuery {
  params: IGetSubscriptionStatusParams;
  result: IGetSubscriptionStatusResult;
}

const getSubscriptionStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_subscription_status(p_ffc_id UUID)\n-- Type: Simple Read-Only Query\n-- Description: Get subscription status and details for an FFC\n-- Parameters:\n--   $1: p_ffc_id UUID - The FFC ID to get subscription status for\n-- Returns: Subscription status information\n-- ================================================================\n\n-- This query retrieves the active subscription status for an FFC\n-- Returns at most one row for the active/trialing/past_due subscription\n\nSELECT \n    s.id as subscription_id,\n    s.status,\n    p.plan_name,\n    p.plan_type,\n    p.billing_frequency,\n    s.billing_amount,\n    s.current_period_end,\n    s.next_billing_date,\n    s.canceled_at,\n    s.cancel_reason,\n    COUNT(*) FILTER (WHERE sa.status = 'active') as total_active_seats,\n    COUNT(*) as total_seats\nFROM subscriptions s\nJOIN plans p ON p.id = s.plan_id\nLEFT JOIN seat_assignments sa ON sa.subscription_id = s.id\nWHERE s.ffc_id = $1::UUID\nAND s.status IN ('active', 'trialing', 'past_due')\nGROUP BY s.id, s.status, p.plan_name, p.plan_type, p.billing_frequency, \n         s.billing_amount, s.current_period_end, s.next_billing_date,\n         s.canceled_at, s.cancel_reason\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_subscription_status(p_ffc_id UUID)
 * -- Type: Simple Read-Only Query
 * -- Description: Get subscription status and details for an FFC
 * -- Parameters:
 * --   $1: p_ffc_id UUID - The FFC ID to get subscription status for
 * -- Returns: Subscription status information
 * -- ================================================================
 * 
 * -- This query retrieves the active subscription status for an FFC
 * -- Returns at most one row for the active/trialing/past_due subscription
 * 
 * SELECT 
 *     s.id as subscription_id,
 *     s.status,
 *     p.plan_name,
 *     p.plan_type,
 *     p.billing_frequency,
 *     s.billing_amount,
 *     s.current_period_end,
 *     s.next_billing_date,
 *     s.canceled_at,
 *     s.cancel_reason,
 *     COUNT(*) FILTER (WHERE sa.status = 'active') as total_active_seats,
 *     COUNT(*) as total_seats
 * FROM subscriptions s
 * JOIN plans p ON p.id = s.plan_id
 * LEFT JOIN seat_assignments sa ON sa.subscription_id = s.id
 * WHERE s.ffc_id = $1::UUID
 * AND s.status IN ('active', 'trialing', 'past_due')
 * GROUP BY s.id, s.status, p.plan_name, p.plan_type, p.billing_frequency, 
 *          s.billing_amount, s.current_period_end, s.next_billing_date,
 *          s.canceled_at, s.cancel_reason
 * LIMIT 1
 * ```
 */
export const getSubscriptionStatus = new PreparedQuery<IGetSubscriptionStatusParams,IGetSubscriptionStatusResult>(getSubscriptionStatusIR);


