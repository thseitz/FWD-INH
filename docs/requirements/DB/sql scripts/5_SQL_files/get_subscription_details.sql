-- ================================================================
-- Converted from: sp_get_subscription_details(p_ffc_id UUID)
-- Type: Simple Read-Only Query with JSONB Aggregation
-- Description: Get subscription details with plan info and seat counts
-- Parameters:
--   $1: p_ffc_id UUID - The FFC ID to get subscription details for
-- Returns: Subscription details with seat count aggregation
-- ================================================================

-- This query retrieves subscription details including seat count aggregation
-- Returns only active subscriptions for the specified FFC

SELECT 
    s.id as subscription_id,
    p.plan_name,
    p.plan_type,
    p.billing_frequency,
    s.billing_amount,
    s.status,
    s.current_period_end,
    s.next_billing_date,
    (
        SELECT jsonb_object_agg(
            seat_type_counts.seat_type,
            seat_type_counts.counts
        )
        FROM (
            SELECT 
                sa.seat_type::text as seat_type,
                jsonb_build_object(
                    'active', COUNT(*) FILTER (WHERE sa.status = 'active'),
                    'total', COUNT(*)
                ) as counts
            FROM seat_assignments sa
            WHERE sa.subscription_id = s.id
            GROUP BY sa.seat_type
        ) as seat_type_counts
    ) as seat_counts
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
WHERE s.ffc_id = $1::UUID
AND s.status = 'active';