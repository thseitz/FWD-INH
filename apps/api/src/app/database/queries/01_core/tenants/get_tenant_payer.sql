/* @name getTenantPayer */
-- ================================================================
-- Supporting query for: sp_handle_invoice_payment_succeeded()
-- Type: SELECT
-- Description: Get primary payer for tenant (usually admin/owner)
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
-- Returns: User who is the payer for this tenant
-- ================================================================

-- Get the primary user for tenant payments

SELECT 
    u.id as payer_id,
    u.cognito_user_id,
    u.first_name,
    u.last_name,
    u.status
FROM users u
WHERE u.tenant_id = $1::INTEGER
  AND u.status = 'active'
ORDER BY 
    u.created_at ASC
LIMIT 1;