-- ================================================================
-- Converted from: sp_cancel_subscription() - Part 1
-- Type: SELECT
-- Description: Get subscription details for cancellation
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID
-- Returns: Subscription details
-- ================================================================

-- Get subscription details and verify it exists

SELECT 
    id,
    status,
    tenant_id,
    ffc_id,
    plan_id,
    stripe_subscription_id
FROM subscriptions
WHERE id = $1::UUID;