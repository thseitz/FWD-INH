/* @name createQuilttSession */
-- ================================================================
-- Name: create_quiltt_session
-- Type: INSERT
-- Description: Create a temporary Quiltt session token for UI connector
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_persona_id UUID - Persona ID
--   $3: p_session_token TEXT - Session token from Quiltt API
--   $4: p_expires_at TIMESTAMPTZ - Token expiration time
-- Returns: Created session record
-- Used by: QuilttIntegrationService.createBankingSession()
-- ================================================================

INSERT INTO quiltt_sessions (
    tenant_id,
    persona_id,
    session_token,
    expires_at
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::TEXT,
    $4::TIMESTAMPTZ
)
ON CONFLICT (persona_id) WHERE NOT is_used
DO UPDATE SET
    session_token = EXCLUDED.session_token,
    expires_at = EXCLUDED.expires_at,
    is_used = FALSE,
    used_at = NULL
RETURNING 
    id,
    persona_id,
    session_token,
    expires_at,
    created_at;