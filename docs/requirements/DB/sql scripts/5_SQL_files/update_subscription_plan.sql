-- ================================================================
-- Converted from: sp_transition_subscription_plan() - Part 4
-- Type: UPDATE
-- Description: Update subscription with new plan
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID
--   $2: p_new_plan_id UUID - New plan ID
-- Returns: Updated subscription record
-- ================================================================

-- Update subscription with new plan

UPDATE subscriptions
SET 
    plan_id = $2::UUID,
    updated_at = NOW()
WHERE id = $1::UUID
RETURNING 
    id,
    tenant_id,
    ffc_id,
    plan_id,
    status,
    updated_at;