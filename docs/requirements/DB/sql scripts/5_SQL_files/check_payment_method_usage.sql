-- ================================================================
-- Converted from: sp_check_payment_method_usage()
-- Type: Simple SELECT Query
-- Description: Check if payment method is in use
-- Parameters:
--   $1: p_payment_method_id UUID - Payment method ID to check
--   $2: p_tenant_id INTEGER - Tenant ID (optional, not used)
-- Returns: Boolean indicating if payment method is in use
-- ================================================================

-- This query checks if a payment method is in use
-- Uses the payment_methods_with_usage view

SELECT COALESCE(is_in_use, FALSE) as is_in_use
FROM payment_methods_with_usage
WHERE id = $1::UUID;