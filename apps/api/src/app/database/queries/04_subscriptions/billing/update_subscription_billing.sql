/* @name updateSubscriptionBilling */
-- ================================================================
-- Converted from: sp_handle_invoice_payment_succeeded() - Step 2
-- Type: UPDATE
-- Description: Update subscription billing dates after invoice payment
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
-- Returns: Updated subscription records
-- ================================================================

-- Update subscription billing dates for active subscriptions

UPDATE subscriptions
SET 
    next_billing_date = (current_period_end + INTERVAL '1 month')::date,
    updated_at = NOW()
WHERE tenant_id = $1::INTEGER
  AND status = 'active'
RETURNING 
    id,
    next_billing_date,
    current_period_end,
    status;