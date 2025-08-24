/* @name checkPaymentMethodOwner */
-- ================================================================
-- Converted from: sp_delete_payment_method (Step 1)
-- Type: SELECT for validation
-- Description: Verify payment method ownership
-- Parameters:
--   $1: p_payment_method_id UUID - Payment method ID
--   $2: p_user_id UUID - User attempting deletion
-- Returns: Owner verification result
-- ================================================================

-- Check if user owns the payment method

SELECT 
    id,
    user_id,
    status,
    tenant_id,
    CASE 
        WHEN user_id = $2::UUID THEN TRUE
        ELSE FALSE
    END as is_owner,
    CASE
        WHEN id IS NULL THEN 'Payment method not found'
        WHEN user_id != $2::UUID THEN 'User does not own this payment method'
        WHEN status = 'deleted' THEN 'Payment method already deleted'
        ELSE 'OK'
    END as validation_message
FROM payment_methods
WHERE id = $1::UUID;