-- ================================================================
-- Converted from: sp_update_system_configuration()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Update system configuration setting
-- Parameters:
--   $1: p_config_key TEXT - Configuration key
--   $2: p_config_value JSONB - Configuration value
--   $3: p_config_category VARCHAR(50) - Category (default 'general')
--   $4: p_description TEXT - Description (optional)
--   $5: p_user_id UUID - User making change (optional)
-- Returns: Configuration record
-- NOTE: Service layer should handle audit logging separately
-- ================================================================

-- This query uses the masking_configurations table for system configs
-- Using 'system' as the table_name for system configuration entries

INSERT INTO masking_configurations (
    tenant_id,
    table_name,
    column_name,
    masking_type,
    masking_pattern,
    preserve_format,
    apply_condition,
    is_active,
    created_at,
    updated_at,
    created_by,
    updated_by
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    'system',
    $1::TEXT,
    COALESCE($3::VARCHAR(50), 'general'),
    $2::TEXT,  -- JSONB converted to TEXT for storage
    TRUE,
    $4::TEXT,  -- description stored in apply_condition
    TRUE,
    NOW(),
    NOW(),
    COALESCE(
        $5::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    COALESCE(
        $5::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
)
ON CONFLICT (tenant_id, table_name, column_name) 
DO UPDATE SET
    masking_pattern = EXCLUDED.masking_pattern,
    masking_type = EXCLUDED.masking_type,
    updated_by = EXCLUDED.updated_by,
    updated_at = NOW()
RETURNING 
    id,
    column_name as config_key,
    masking_pattern as config_value,
    masking_type as config_category,
    updated_at;