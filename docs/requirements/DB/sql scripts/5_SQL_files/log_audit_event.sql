-- ================================================================
-- Converted from: sp_log_audit_event()
-- Type: INSERT
-- Description: Create audit log entry
-- Parameters:
--   $1: p_action VARCHAR(50) - Action performed
--   $2: p_entity_type VARCHAR(50) - Entity type
--   $3: p_entity_id UUID - Entity ID
--   $4: p_entity_name TEXT - Entity name (optional)
--   $5: p_old_values JSONB - Old values (optional)
--   $6: p_new_values JSONB - New values (optional)
--   $7: p_metadata JSONB - Additional metadata (optional)
--   $8: p_user_id UUID - User performing action (optional)
-- Returns: Audit log entry
-- ================================================================

-- This query creates an audit log entry with automatic change summary generation

INSERT INTO audit_log (
    tenant_id,
    user_id,
    action,
    entity_type,
    entity_id,
    entity_name,
    old_values,
    new_values,
    change_summary,
    ip_address,
    user_agent,
    created_at
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    COALESCE(
        $8::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    $1::audit_action_enum,
    $2::audit_entity_type_enum,
    $3::UUID,
    $4::TEXT,
    $5::JSONB,
    $6::JSONB,
    COALESCE(
        CASE 
            WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NOT NULL THEN 'Updated ' || $2
            WHEN $5::JSONB IS NULL AND $6::JSONB IS NOT NULL THEN 'Created ' || $2
            WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NULL THEN 'Deleted ' || $2
            ELSE COALESCE($7::TEXT, 'Action: ' || $1)
        END,
        COALESCE($7::TEXT, 'Action: ' || $1)
    ),
    inet_client_addr(),
    current_setting('application_name', true),
    NOW()
)
RETURNING 
    id,
    action,
    entity_type,
    entity_id,
    entity_name,
    change_summary,
    created_at;