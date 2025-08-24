/* @name configureBuilderIo */
-- ================================================================
-- Converted from: sp_configure_builder_io()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Configure or update Builder.io integration
-- Parameters:
--   $1: p_api_key TEXT - Builder.io API key
--   $2: p_space_id TEXT - Builder.io space ID
--   $3: p_environment VARCHAR(20) - Environment (default 'production')
--   $4: p_webhook_url TEXT - Webhook URL (optional, not used)
--   $5: p_user_id UUID - User ID (optional)
-- Returns: Integration record
-- ================================================================

-- This query creates or updates a Builder.io integration configuration
-- Uses ON CONFLICT to handle updates to existing integrations

INSERT INTO builder_io_integrations (
    tenant_id,
    api_key,
    space_id,
    environment,
    is_active,
    created_at,
    updated_at
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    $1::TEXT,
    $2::TEXT,
    COALESCE($3::VARCHAR(20), 'production'),
    TRUE,
    NOW(),
    NOW()
)
ON CONFLICT (tenant_id, space_id) DO UPDATE SET
    api_key = EXCLUDED.api_key,
    space_id = EXCLUDED.space_id,
    environment = EXCLUDED.environment,
    is_active = TRUE,
    updated_at = NOW()
RETURNING 
    id,
    tenant_id,
    space_id,
    environment,
    is_active;