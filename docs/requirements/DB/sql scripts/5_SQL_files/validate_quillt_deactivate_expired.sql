-- ================================================================
-- Converted from: sp_validate_quillt_credentials() - Part 2
-- Type: UPDATE
-- Description: Deactivate expired Quillt integration
-- Parameters:
--   $1: p_integration_id UUID - Integration ID to deactivate
-- Returns: Updated integration record
-- ================================================================

-- Deactivate expired Quillt integration

UPDATE quillt_integrations SET
    is_active = FALSE,
    sync_error = 'Token expired - integration deactivated',
    updated_at = NOW()
WHERE id = $1::UUID
RETURNING 
    id,
    user_id,
    is_active,
    token_expires_at,
    updated_at;