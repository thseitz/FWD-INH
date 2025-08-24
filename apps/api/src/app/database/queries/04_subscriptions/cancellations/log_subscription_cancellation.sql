/* @name logSubscriptionCancellation */
-- ================================================================
-- Converted from: sp_cancel_subscription() - Part 4
-- Type: INSERT
-- Description: Log subscription cancellation in audit log
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_cancelled_by UUID - User who canceled
--   $3: p_subscription_id UUID - Subscription ID
--   $4: p_reason TEXT - Cancellation reason
-- Returns: Created audit log entry
-- ================================================================

-- Log subscription cancellation to audit

INSERT INTO audit_log (
    tenant_id,
    user_id,
    action,
    entity_type,
    entity_id,
    change_summary
) VALUES (
    $1::INTEGER,
    $2::UUID,
    'update',
    'subscription',
    $3::UUID,
    format('Subscription canceled. Reason: %s', COALESCE($4::TEXT, 'No reason provided'))
)
RETURNING 
    id,
    tenant_id,
    user_id,
    action,
    entity_type,
    entity_id,
    change_summary,
    created_at;