-- ================================================================
-- Converted from: sp_handle_payment_succeeded() - Part 2
-- Type: UPDATE
-- Description: Update service purchase status to succeeded
-- Parameters:
--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
--   $2: p_tenant_id INTEGER - Tenant ID
-- Returns: Updated service purchase record
-- ================================================================

-- Update service purchase status when payment succeeds

UPDATE service_purchases
SET 
    status = 'succeeded',
    updated_at = NOW()
WHERE stripe_payment_intent_id = $1::TEXT
  AND tenant_id = $2::INTEGER
RETURNING 
    id,
    tenant_id,
    service_id,
    purchaser_user_id,
    status,
    updated_at;