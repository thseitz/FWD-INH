-- ================================================================
-- Converted from: sp_retry_failed_integration() - Audit log part
-- Type: INSERT
-- Description: Log integration retry attempt in audit log
-- Parameters:
--   $1: p_integration_id UUID - Integration ID being retried
--   $2: p_integration_type VARCHAR(50) - Type of integration
--   $3: p_user_id UUID - User initiating retry (optional)
--   $4: p_success BOOLEAN - Whether retry was initiated successfully
-- Returns: Created audit log entry
-- ================================================================

-- Log integration retry attempt

INSERT INTO audit_log (
    tenant_id,
    user_id,
    action,
    entity_type,
    entity_id,
    new_values
) VALUES (
    COALESCE(current_setting('app.current_tenant_id', true)::INTEGER, 1),
    COALESCE($3::UUID, 
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    'update'::audit_action_enum,
    'system'::audit_entity_type_enum,
    $1::UUID,
    jsonb_build_object(
        'integration_type', $2::VARCHAR(50),
        'action', 'retry_integration',
        'retried', $4::BOOLEAN
    )
)
RETURNING 
    id,
    tenant_id,
    user_id,
    action,
    entity_type,
    entity_id,
    new_values,
    created_at;