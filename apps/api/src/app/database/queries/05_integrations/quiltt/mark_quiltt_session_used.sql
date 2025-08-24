/* @name markQuilttSessionUsed */
-- ================================================================
-- Name: mark_quiltt_session_used
-- Type: UPDATE
-- Description: Mark a Quiltt session as used after successful connection
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
-- Returns: Updated session record
-- Used by: QuilttIntegrationService.handleConnectionWebhook()
-- ================================================================

UPDATE quiltt_sessions 
SET 
    is_used = TRUE,
    used_at = NOW()
WHERE 
    persona_id = $1::UUID 
    AND is_used = FALSE
RETURNING 
    id,
    persona_id,
    session_token,
    is_used,
    used_at;