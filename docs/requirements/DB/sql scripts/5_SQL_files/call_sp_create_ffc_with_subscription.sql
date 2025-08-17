-- ================================================================
-- Wrapper for: sp_create_ffc_with_subscription()
-- Type: PROCEDURE call wrapper
-- Description: Create FFC with subscription
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_name TEXT - FFC name
--   $3: p_description TEXT - FFC description
--   $4: p_owner_user_id UUID - Owner user ID
--   $5: p_owner_persona_id UUID - Owner persona ID
-- Returns: (p_ffc_id UUID, p_subscription_id UUID)
-- ================================================================

-- Call stored procedure to create FFC with subscription

CALL sp_create_ffc_with_subscription(
    $1::INTEGER,      -- p_tenant_id
    $2::TEXT,         -- p_name
    $3::TEXT,         -- p_description
    $4::UUID,         -- p_owner_user_id
    $5::UUID,         -- p_owner_persona_id
    NULL,             -- OUT p_ffc_id
    NULL              -- OUT p_subscription_id
);