/* @name getNewPlanDetails */
-- ================================================================
-- Converted from: sp_transition_subscription_plan() - Part 2
-- Type: SELECT
-- Description: Get new plan details for transition
-- Parameters:
--   $1: p_new_plan_id UUID - New plan ID
-- Returns: New plan details
-- ================================================================

-- Get new plan details

SELECT 
    id,
    plan_name,
    plan_type,
    base_price,
    billing_frequency,
    COALESCE((features->>'max_seats')::INTEGER, 10) as max_seats,
    features
FROM plans
WHERE id = $1::UUID;