-- ================================================================
-- Converted from: sp_cancel_subscription() - Part 3
-- Type: UPDATE
-- Description: Suspend all active seats for canceled subscription
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID
-- Returns: Count of suspended seats
-- ================================================================

-- Suspend all active seat assignments for canceled subscription

UPDATE seat_assignments
SET 
    status = 'suspended',
    updated_at = NOW()
WHERE subscription_id = $1::UUID
  AND status = 'active'
RETURNING id;