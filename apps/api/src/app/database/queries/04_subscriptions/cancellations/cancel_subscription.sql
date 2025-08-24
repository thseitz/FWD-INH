/* @name cancelSubscription */
-- ================================================================
-- Converted from: sp_cancel_subscription() - Part 2
-- Type: UPDATE
-- Description: Cancel a subscription
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID to cancel
--   $2: p_reason TEXT - Cancellation reason (optional)
-- Returns: Updated subscription record
-- ================================================================

-- Update subscription status to canceled

UPDATE subscriptions
SET 
    status = 'canceled',
    canceled_at = NOW(),
    cancel_reason = $2::TEXT,
    updated_at = NOW()
WHERE id = $1::UUID
  AND status != 'canceled'
RETURNING 
    id,
    tenant_id,
    ffc_id,
    status,
    canceled_at,
    cancel_reason;