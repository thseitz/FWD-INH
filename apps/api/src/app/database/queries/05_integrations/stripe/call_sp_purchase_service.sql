/* @name callSpPurchaseService */
-- ================================================================
-- Wrapper for: sp_purchase_service()
-- Type: PROCEDURE call wrapper
-- Description: Process service purchase with payment
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_service_type VARCHAR(50) - Type of service
--   $3: p_amount INTEGER - Amount in cents
--   $4: p_currency VARCHAR(3) - Currency code
--   $5: p_purchased_by UUID - User making the purchase
--   $6: p_payment_method_id UUID - Payment method ID
-- Returns: void (procedure)
-- ================================================================

-- Call stored procedure to purchase service

CALL sp_purchase_service(
    $1::INTEGER,       -- p_tenant_id
    $2::VARCHAR(50),   -- p_service_type
    $3::INTEGER,       -- p_amount
    $4::VARCHAR(3),    -- p_currency
    $5::UUID,          -- p_purchased_by
    $6::UUID           -- p_payment_method_id
);