/* @name createQuilttIntegration */
-- ================================================================
-- Name: create_quiltt_integration
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Create or update Quiltt integration for a persona
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_persona_id UUID - Persona ID
--   $3: p_quiltt_user_id TEXT - Quiltt user/profile ID
--   $4: p_quiltt_connection_id TEXT - Quiltt connection ID
--   $5: p_connection_status TEXT - Connection status (connected/disconnected)
--   $6: p_sync_status TEXT - Sync status (pending/completed/failed)
-- Returns: Integration record
-- Used by: QuilttIntegrationService.handleConnectionWebhook()
-- ================================================================

INSERT INTO quiltt_integrations (
    tenant_id,
    persona_id,
    quiltt_user_id,
    quiltt_connection_id,
    connection_status,
    sync_status,
    last_sync_at,
    is_active
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::TEXT,
    $4::TEXT,
    $5::integration_status_enum,
    $6::sync_status_enum,
    NOW(),
    TRUE
)
ON CONFLICT (tenant_id, persona_id) 
DO UPDATE SET 
    quiltt_connection_id = EXCLUDED.quiltt_connection_id,
    connection_status = EXCLUDED.connection_status,
    sync_status = EXCLUDED.sync_status,
    last_sync_at = NOW(),
    is_active = TRUE,
    updated_at = NOW()
RETURNING 
    id,
    tenant_id,
    persona_id,
    quiltt_user_id,
    quiltt_connection_id,
    connection_status,
    sync_status,
    last_sync_at;