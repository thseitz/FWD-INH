/* @name createLedgerEntry */
-- ================================================================
-- Converted from: sp_create_ledger_entry()
-- Type: INSERT
-- Description: Create a new general ledger entry
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_transaction_type transaction_type_enum - Type of transaction
--   $3: p_account_type ledger_account_type_enum - Account type
--   $4: p_amount DECIMAL(10,2) - Transaction amount
--   $5: p_reference_type VARCHAR(50) - Reference type
--   $6: p_reference_id UUID - Reference ID
--   $7: p_description TEXT - Transaction description
--   $8: p_stripe_reference VARCHAR(255) - Stripe reference (optional)
-- Returns: Created ledger entry
-- ================================================================

-- Create a new general ledger entry with automatic category assignment

INSERT INTO general_ledger (
    tenant_id,
    transaction_type,
    transaction_date,
    account_type,
    amount,
    currency,
    reference_type,
    reference_id,
    stripe_reference,
    category,
    description
) VALUES (
    $1::INTEGER,
    $2::transaction_type_enum,
    CURRENT_DATE,
    $3::ledger_account_type_enum,
    $4::DECIMAL(10,2),
    'USD',
    $5::VARCHAR(50),
    $6::UUID,
    $8::VARCHAR(255),
    CASE 
        WHEN $5 = 'subscription' AND $2::TEXT = 'charge' THEN 'recurring_monthly'
        WHEN $5 = 'service' THEN 'one_time'
        WHEN $2::TEXT = 'refund' THEN 'refund'
        ELSE NULL
    END,
    $7::TEXT
)
RETURNING 
    id,
    tenant_id,
    transaction_type,
    transaction_date,
    account_type,
    amount,
    currency,
    reference_type,
    reference_id,
    stripe_reference,
    category,
    description,
    created_at;