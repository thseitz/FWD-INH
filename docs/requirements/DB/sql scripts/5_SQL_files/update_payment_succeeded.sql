-- ================================================================
-- Converted from: sp_handle_payment_succeeded() - Part 1
-- Type: UPDATE
-- Description: Update payment status to succeeded
-- Parameters:
--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
--   $2: p_tenant_id INTEGER - Tenant ID
-- Returns: Updated payment record
-- ================================================================

-- Update payment status when payment succeeds

UPDATE payments
SET 
    status = 'succeeded',
    processed_at = NOW()
WHERE stripe_payment_intent_id = $1::TEXT
  AND tenant_id = $2::INTEGER
RETURNING 
    id,
    tenant_id,
    payer_id,
    amount,
    currency,
    status,
    processed_at;