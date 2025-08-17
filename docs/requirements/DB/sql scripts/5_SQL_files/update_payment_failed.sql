-- ================================================================
-- Converted from: sp_handle_payment_failed()
-- Type: UPDATE
-- Description: Update payment status to failed
-- Parameters:
--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
--   $2: p_failure_reason TEXT - Reason for failure
--   $3: p_tenant_id INTEGER - Tenant ID
-- Returns: Updated payment record
-- ================================================================

-- Update payment status when Stripe reports failure

UPDATE payments
SET 
    status = 'failed',
    failure_reason = $2::TEXT,
    processed_at = NOW(),
    updated_at = NOW()
WHERE stripe_payment_intent_id = $1::TEXT
  AND tenant_id = $3::INTEGER
RETURNING 
    id,
    stripe_payment_intent_id,
    status,
    failure_reason,
    processed_at;