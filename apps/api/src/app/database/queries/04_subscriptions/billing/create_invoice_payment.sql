/* @name createInvoicePayment */
-- ================================================================
-- Converted from: sp_handle_invoice_payment_succeeded() - Step 1
-- Type: INSERT
-- Description: Create payment record for successful invoice payment
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_payer_id UUID - Payer user ID (from service layer)
--   $3: p_amount INTEGER - Amount in cents
--   $4: p_currency VARCHAR(3) - Currency code
--   $5: p_stripe_invoice_id TEXT - Stripe invoice ID
--   $6: p_reference_id UUID - Reference subscription ID (optional)
-- Returns: Created payment record
-- NOTE: Service layer should get payer_id and reference_id before calling
-- ================================================================

-- Create payment record for invoice

INSERT INTO payments (
    tenant_id,
    payer_id,
    amount,
    currency,
    payment_type,
    reference_id,
    stripe_invoice_id,
    status,
    processed_at,
    created_at,
    updated_at
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::DECIMAL / 100,  -- Convert cents to dollars
    $4::VARCHAR(3),
    'subscription',
    $6::UUID,
    $5::TEXT,
    'succeeded',
    NOW(),
    NOW(),
    NOW()
)
RETURNING 
    id,
    payer_id,
    amount,
    currency,
    stripe_invoice_id,
    status;