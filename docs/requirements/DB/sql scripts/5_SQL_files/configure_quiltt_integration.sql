-- ================================================================
-- Converted from: sp_configure_quiltt_integration()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Configure or update Quiltt integration for a persona
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
--   $2: p_access_token TEXT - Access token
--   $3: p_quiltt_connection_id TEXT - Quiltt connection ID
--   $4: p_refresh_token TEXT - Refresh token (optional)
--   $5: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)
-- Returns: Integration record
-- NOTE: Audit log insert should be handled separately in service layer
-- ================================================================

-- This query creates or updates a Quiltt integration configuration
-- Uses ON CONFLICT to handle updates to existing integrations

INSERT INTO quiltt_integrations (
    tenant_id,
    persona_id,
    quiltt_user_id,
    quiltt_connection_id,
    quiltt_profile_id,
    access_token_encrypted,
    refresh_token_encrypted,
    token_expires_at,
    is_active
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    $1::UUID,
    $5::TEXT,
    $3::TEXT,
    $5::TEXT,  -- quiltt_profile_id same as quiltt_user_id
    $2::TEXT,
    $4::TEXT,
    (NOW() + INTERVAL '30 days'),
    TRUE
)
ON CONFLICT (tenant_id, persona_id) DO UPDATE SET
    quiltt_connection_id = EXCLUDED.quiltt_connection_id,
    quiltt_user_id = EXCLUDED.quiltt_user_id,
    quiltt_profile_id = EXCLUDED.quiltt_profile_id,
    access_token_encrypted = EXCLUDED.access_token_encrypted,
    refresh_token_encrypted = EXCLUDED.refresh_token_encrypted,
    token_expires_at = EXCLUDED.token_expires_at,
    is_active = TRUE,
    updated_at = NOW()
RETURNING 
    id,
    tenant_id,
    persona_id,
    quiltt_user_id,
    quiltt_connection_id,
    is_active,
    token_expires_at;