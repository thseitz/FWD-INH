/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/seats/suspend_subscription_seats.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'SuspendSubscriptionSeats' parameters type */
export type ISuspendSubscriptionSeatsParams = void;

/** 'SuspendSubscriptionSeats' return type */
export interface ISuspendSubscriptionSeatsResult {
  id: string;
}

/** 'SuspendSubscriptionSeats' query type */
export interface ISuspendSubscriptionSeatsQuery {
  params: ISuspendSubscriptionSeatsParams;
  result: ISuspendSubscriptionSeatsResult;
}

const suspendSubscriptionSeatsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_cancel_subscription() - Part 3\n-- Type: UPDATE\n-- Description: Suspend all active seats for canceled subscription\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID\n-- Returns: Count of suspended seats\n-- ================================================================\n\n-- Suspend all active seat assignments for canceled subscription\n\nUPDATE seat_assignments\nSET \n    status = 'suspended',\n    updated_at = NOW()\nWHERE subscription_id = $1::UUID\n  AND status = 'active'\nRETURNING id"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_cancel_subscription() - Part 3
 * -- Type: UPDATE
 * -- Description: Suspend all active seats for canceled subscription
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID
 * -- Returns: Count of suspended seats
 * -- ================================================================
 * 
 * -- Suspend all active seat assignments for canceled subscription
 * 
 * UPDATE seat_assignments
 * SET 
 *     status = 'suspended',
 *     updated_at = NOW()
 * WHERE subscription_id = $1::UUID
 *   AND status = 'active'
 * RETURNING id
 * ```
 */
export const suspendSubscriptionSeats = new PreparedQuery<ISuspendSubscriptionSeatsParams,ISuspendSubscriptionSeatsResult>(suspendSubscriptionSeatsIR);


