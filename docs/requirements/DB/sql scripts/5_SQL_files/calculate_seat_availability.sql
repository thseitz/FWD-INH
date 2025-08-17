-- ================================================================
-- Converted from: sp_calculate_seat_availability(p_subscription_id UUID)
-- Type: Simple Read-Only Query with CTEs
-- Description: Calculate available seats for a subscription
-- Parameters:
--   $1: p_subscription_id UUID - The subscription ID to calculate seats for
-- Returns: Seat availability information by type
-- ================================================================

-- This query calculates seat availability using Common Table Expressions
-- Returns seat configuration, usage, and availability for each seat type

WITH seat_config AS (
    SELECT 
        ps.seat_type,
        ps.included_quantity,
        ps.max_quantity
    FROM subscriptions s
    JOIN plan_seats ps ON ps.plan_id = s.plan_id
    WHERE s.id = $1::UUID
),
seat_usage AS (
    SELECT 
        sa.seat_type,
        COUNT(*)::BIGINT as used_count
    FROM seat_assignments sa
    WHERE sa.subscription_id = $1::UUID
    AND sa.status = 'active'
    GROUP BY sa.seat_type
)
SELECT 
    sc.seat_type,
    sc.included_quantity,
    sc.max_quantity,
    COALESCE(su.used_count, 0::BIGINT) as used_quantity,
    CASE 
        WHEN sc.max_quantity IS NULL THEN 999999  -- Unlimited
        ELSE GREATEST(0, sc.max_quantity - COALESCE(su.used_count, 0)::INTEGER)
    END::INTEGER as available_quantity,
    CASE 
        WHEN sc.max_quantity IS NULL THEN true  -- Unlimited
        WHEN COALESCE(su.used_count, 0) < sc.max_quantity THEN true
        ELSE false
    END as can_add_more
FROM seat_config sc
LEFT JOIN seat_usage su ON sc.seat_type = su.seat_type
ORDER BY sc.seat_type;