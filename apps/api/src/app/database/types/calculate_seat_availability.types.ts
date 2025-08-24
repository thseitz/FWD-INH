/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/seats/calculate_seat_availability.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type seat_type_enum = 'basic' | 'enterprise' | 'pro';

/** 'CalculateSeatAvailability' parameters type */
export type ICalculateSeatAvailabilityParams = void;

/** 'CalculateSeatAvailability' return type */
export interface ICalculateSeatAvailabilityResult {
  available_quantity: number | null;
  can_add_more: boolean | null;
  included_quantity: number | null;
  max_quantity: number | null;
  seat_type: seat_type_enum;
  used_quantity: string | null;
}

/** 'CalculateSeatAvailability' query type */
export interface ICalculateSeatAvailabilityQuery {
  params: ICalculateSeatAvailabilityParams;
  result: ICalculateSeatAvailabilityResult;
}

const calculateSeatAvailabilityIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_calculate_seat_availability(p_subscription_id UUID)\n-- Type: Simple Read-Only Query with CTEs\n-- Description: Calculate available seats for a subscription\n-- Parameters:\n--   $1: p_subscription_id UUID - The subscription ID to calculate seats for\n-- Returns: Seat availability information by type\n-- ================================================================\n\n-- This query calculates seat availability using Common Table Expressions\n-- Returns seat configuration, usage, and availability for each seat type\n\nWITH seat_config AS (\n    SELECT \n        ps.seat_type,\n        ps.included_quantity,\n        ps.max_quantity\n    FROM subscriptions s\n    JOIN plan_seats ps ON ps.plan_id = s.plan_id\n    WHERE s.id = $1::UUID\n),\nseat_usage AS (\n    SELECT \n        sa.seat_type,\n        COUNT(*)::BIGINT as used_count\n    FROM seat_assignments sa\n    WHERE sa.subscription_id = $1::UUID\n    AND sa.status = 'active'\n    GROUP BY sa.seat_type\n)\nSELECT \n    sc.seat_type,\n    sc.included_quantity,\n    sc.max_quantity,\n    COALESCE(su.used_count, 0::BIGINT) as used_quantity,\n    CASE \n        WHEN sc.max_quantity IS NULL THEN 999999  -- Unlimited\n        ELSE GREATEST(0, sc.max_quantity - COALESCE(su.used_count, 0)::INTEGER)\n    END::INTEGER as available_quantity,\n    CASE \n        WHEN sc.max_quantity IS NULL THEN true  -- Unlimited\n        WHEN COALESCE(su.used_count, 0) < sc.max_quantity THEN true\n        ELSE false\n    END as can_add_more\nFROM seat_config sc\nLEFT JOIN seat_usage su ON sc.seat_type = su.seat_type\nORDER BY sc.seat_type"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_calculate_seat_availability(p_subscription_id UUID)
 * -- Type: Simple Read-Only Query with CTEs
 * -- Description: Calculate available seats for a subscription
 * -- Parameters:
 * --   $1: p_subscription_id UUID - The subscription ID to calculate seats for
 * -- Returns: Seat availability information by type
 * -- ================================================================
 * 
 * -- This query calculates seat availability using Common Table Expressions
 * -- Returns seat configuration, usage, and availability for each seat type
 * 
 * WITH seat_config AS (
 *     SELECT 
 *         ps.seat_type,
 *         ps.included_quantity,
 *         ps.max_quantity
 *     FROM subscriptions s
 *     JOIN plan_seats ps ON ps.plan_id = s.plan_id
 *     WHERE s.id = $1::UUID
 * ),
 * seat_usage AS (
 *     SELECT 
 *         sa.seat_type,
 *         COUNT(*)::BIGINT as used_count
 *     FROM seat_assignments sa
 *     WHERE sa.subscription_id = $1::UUID
 *     AND sa.status = 'active'
 *     GROUP BY sa.seat_type
 * )
 * SELECT 
 *     sc.seat_type,
 *     sc.included_quantity,
 *     sc.max_quantity,
 *     COALESCE(su.used_count, 0::BIGINT) as used_quantity,
 *     CASE 
 *         WHEN sc.max_quantity IS NULL THEN 999999  -- Unlimited
 *         ELSE GREATEST(0, sc.max_quantity - COALESCE(su.used_count, 0)::INTEGER)
 *     END::INTEGER as available_quantity,
 *     CASE 
 *         WHEN sc.max_quantity IS NULL THEN true  -- Unlimited
 *         WHEN COALESCE(su.used_count, 0) < sc.max_quantity THEN true
 *         ELSE false
 *     END as can_add_more
 * FROM seat_config sc
 * LEFT JOIN seat_usage su ON sc.seat_type = su.seat_type
 * ORDER BY sc.seat_type
 * ```
 */
export const calculateSeatAvailability = new PreparedQuery<ICalculateSeatAvailabilityParams,ICalculateSeatAvailabilityResult>(calculateSeatAvailabilityIR);


