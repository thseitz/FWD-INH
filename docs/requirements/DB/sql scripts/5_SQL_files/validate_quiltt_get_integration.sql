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
    id,
    user_id,
    access_token_encrypted,
    token_expires_at,
    sync_accounts,
    sync_transactions,
    last_sync_at,
    is_active
FROM quiltt_integrations
WHERE user_id = $1::UUID 
  AND is_active = TRUE;