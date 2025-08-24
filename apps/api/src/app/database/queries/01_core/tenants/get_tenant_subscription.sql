/* @name getTenantSubscription */
-- ================================================================
-- Supporting query for: sp_handle_invoice_payment_succeeded()
-- Type: SELECT
-- Description: Get active subscription for tenant
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
-- Returns: Active subscription for reference
-- ================================================================

-- Get the active subscription for this tenant

SELECT 
    id as subscription_id,
    stripe_subscription_id,
    status,
    current_period_start,
    current_period_end,
    next_billing_date
FROM subscriptions
WHERE tenant_id = $1::INTEGER
  AND status = 'active'
ORDER BY created_at DESC
LIMIT 1;