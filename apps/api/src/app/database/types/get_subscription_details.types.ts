/** Types generated for queries found in "apps/api/src/app/database/queries/10_reporting/dashboards/get_subscription_details.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type billing_frequency_enum = 'annual' | 'lifetime' | 'monthly' | 'one_time';

export type plan_type_enum = 'free' | 'paid' | 'sponsored';

export type subscription_status_enum = 'active' | 'canceled' | 'past_due' | 'paused' | 'pending' | 'trialing';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetSubscriptionDetails' parameters type */
export type IGetSubscriptionDetailsParams = void;

/** 'GetSubscriptionDetails' return type */
export interface IGetSubscriptionDetailsResult {
  billing_amount: string;
  billing_frequency: billing_frequency_enum;
  current_period_end: Date | null;
  next_billing_date: Date | null;
  plan_name: string;
  plan_type: plan_type_enum;
  seat_counts: Json | null;
  status: subscription_status_enum;
  subscription_id: string;
}

/** 'GetSubscriptionDetails' query type */
export interface IGetSubscriptionDetailsQuery {
  params: IGetSubscriptionDetailsParams;
  result: IGetSubscriptionDetailsResult;
}

const getSubscriptionDetailsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_subscription_details(p_ffc_id UUID)\n-- Type: Simple Read-Only Query with JSONB Aggregation\n-- Description: Get subscription details with plan info and seat counts\n-- Parameters:\n--   $1: p_ffc_id UUID - The FFC ID to get subscription details for\n-- Returns: Subscription details with seat count aggregation\n-- ================================================================\n\n-- This query retrieves subscription details including seat count aggregation\n-- Returns only active subscriptions for the specified FFC\n\nSELECT \n    s.id as subscription_id,\n    p.plan_name,\n    p.plan_type,\n    p.billing_frequency,\n    s.billing_amount,\n    s.status,\n    s.current_period_end,\n    s.next_billing_date,\n    (\n        SELECT jsonb_object_agg(\n            seat_type_counts.seat_type,\n            seat_type_counts.counts\n        )\n        FROM (\n            SELECT \n                sa.seat_type::text as seat_type,\n                jsonb_build_object(\n                    'active', COUNT(*) FILTER (WHERE sa.status = 'active'),\n                    'total', COUNT(*)\n                ) as counts\n            FROM seat_assignments sa\n            WHERE sa.subscription_id = s.id\n            GROUP BY sa.seat_type\n        ) as seat_type_counts\n    ) as seat_counts\nFROM subscriptions s\nJOIN plans p ON p.id = s.plan_id\nWHERE s.ffc_id = $1::UUID\nAND s.status = 'active'"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_subscription_details(p_ffc_id UUID)
 * -- Type: Simple Read-Only Query with JSONB Aggregation
 * -- Description: Get subscription details with plan info and seat counts
 * -- Parameters:
 * --   $1: p_ffc_id UUID - The FFC ID to get subscription details for
 * -- Returns: Subscription details with seat count aggregation
 * -- ================================================================
 * 
 * -- This query retrieves subscription details including seat count aggregation
 * -- Returns only active subscriptions for the specified FFC
 * 
 * SELECT 
 *     s.id as subscription_id,
 *     p.plan_name,
 *     p.plan_type,
 *     p.billing_frequency,
 *     s.billing_amount,
 *     s.status,
 *     s.current_period_end,
 *     s.next_billing_date,
 *     (
 *         SELECT jsonb_object_agg(
 *             seat_type_counts.seat_type,
 *             seat_type_counts.counts
 *         )
 *         FROM (
 *             SELECT 
 *                 sa.seat_type::text as seat_type,
 *                 jsonb_build_object(
 *                     'active', COUNT(*) FILTER (WHERE sa.status = 'active'),
 *                     'total', COUNT(*)
 *                 ) as counts
 *             FROM seat_assignments sa
 *             WHERE sa.subscription_id = s.id
 *             GROUP BY sa.seat_type
 *         ) as seat_type_counts
 *     ) as seat_counts
 * FROM subscriptions s
 * JOIN plans p ON p.id = s.plan_id
 * WHERE s.ffc_id = $1::UUID
 * AND s.status = 'active'
 * ```
 */
export const getSubscriptionDetails = new PreparedQuery<IGetSubscriptionDetailsParams,IGetSubscriptionDetailsResult>(getSubscriptionDetailsIR);


