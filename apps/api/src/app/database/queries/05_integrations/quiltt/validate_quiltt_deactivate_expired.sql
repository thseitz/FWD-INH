/* @name validateQuilttDeactivateExpired */
-- ================================================================
-- Converted from: sp_validate_quiltt_credentials() - Part 2
-- Type: UPDATE
-- Description: Deactivate expired Quiltt integration
-- Parameters:
--   $1: p_integration_id UUID - Integration ID to deactivate
-- Returns: Updated integration record
-- ================================================================

-- Deactivate expired Quiltt integration

UPDATE quiltt_integrations SET
    is_active = FALSE,
    sync_error = 'Token expired - integration deactivated',
    updated_at = NOW()
WHERE id = $1::UUID
RETURNING 
    id,
    persona_id,
    is_active,
    token_expires_at,
    updated_at;