-- ================================================================
-- Converted from: sp_delete_payment_method (Step 2)
-- Type: UPDATE (soft delete)
-- Description: Soft delete payment method
-- Parameters:
--   $1: p_payment_method_id UUID - Payment method to delete
-- Returns: Deleted payment method record
-- NOTE: Service layer should:
--   1. Check ownership first (check_payment_method_owner.sql)
--   2. Check usage (check_payment_method_usage.sql - already exists)
--   3. Execute this delete
--   4. Log audit event
-- ================================================================

-- Soft delete the payment method

UPDATE payment_methods
SET 
    status = 'deleted',
    updated_at = NOW()
WHERE id = $1::UUID
  AND status != 'deleted'  -- Prevent double deletion
RETURNING 
    id,
    user_id,
    tenant_id,
    status,
    updated_at;