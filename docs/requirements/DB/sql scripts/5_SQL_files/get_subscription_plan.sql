-- ================================================================
-- Converted from: sp_transition_subscription_plan() - Part 1
-- Type: SELECT
-- Description: Get current subscription plan
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID
-- Returns: Current plan details
-- ================================================================

-- Get current subscription plan details

SELECT 
    s.id,
    s.plan_id,
    s.tenant_id,
    s.ffc_id,
    p.base_price,
    p.plan_name,
    p.plan_type
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
WHERE s.id = $1::UUID;