/* @name validateQuilttGetIntegration */
-- ================================================================
-- Converted from: sp_validate_quiltt_credentials() - Part 1
-- Type: SELECT 
-- Description: Get active Quiltt integration for validation
-- Parameters:
--   $1: p_user_id UUID - User ID
-- Returns: Integration record with token details
-- ================================================================

-- Get active Quiltt integration for user

SELECT 
    qi.id,
    qi.persona_id,
    qi.access_token_encrypted,
    qi.token_expires_at,
    qi.sync_accounts,
    qi.sync_transactions,
    qi.last_sync_at,
    qi.is_active
FROM quiltt_integrations qi
JOIN personas p ON qi.persona_id = p.id
WHERE p.user_id = $1::UUID 
  AND qi.is_active = TRUE;