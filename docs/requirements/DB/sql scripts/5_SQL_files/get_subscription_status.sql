-- ================================================================
-- Converted from: sp_get_subscription_status(p_ffc_id UUID)
-- Type: Simple Read-Only Query
-- Description: Get subscription status and details for an FFC
-- Parameters:
--   $1: p_ffc_id UUID - The FFC ID to get subscription status for
-- Returns: Subscription status information
-- ================================================================

-- This query retrieves the active subscription status for an FFC
-- Returns at most one row for the active/trialing/past_due subscription

SELECT 
    s.id as subscription_id,
    s.status,
    p.plan_name,
    p.plan_type,
    p.billing_frequency,
    s.billing_amount,
    s.current_period_end,
    s.next_billing_date,
    s.canceled_at,
    s.cancel_reason,
    COUNT(*) FILTER (WHERE sa.status = 'active') as total_active_seats,
    COUNT(*) as total_seats
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
LEFT JOIN seat_assignments sa ON sa.subscription_id = s.id
WHERE s.ffc_id = $1::UUID
AND s.status IN ('active', 'trialing', 'past_due')
GROUP BY s.id, s.status, p.plan_name, p.plan_type, p.billing_frequency, 
         s.billing_amount, s.current_period_end, s.next_billing_date,
         s.canceled_at, s.cancel_reason
LIMIT 1;