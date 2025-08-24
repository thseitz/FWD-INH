/* @name linkEmailToPersona */
-- ================================================================
-- Supporting query for: sp_add_email_to_persona()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Link email to persona with usage details
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_persona_id UUID - Persona ID
--   $3: p_email_id UUID - Email ID
--   $4: p_usage_type email_usage_type_enum - Usage type (default 'personal')
--   $5: p_is_primary BOOLEAN - Is primary email (default FALSE)
-- Returns: Usage email record
-- NOTE: If is_primary is TRUE, run unset_other_primary_emails.sql after this
-- ================================================================

-- This query links an email to a persona or updates the existing link

INSERT INTO usage_email (
    tenant_id,
    entity_type,
    entity_id,
    email_id,
    usage_type,
    is_primary,
    created_at,
    updated_at
) VALUES (
    $1::INTEGER,
    'persona',
    $2::UUID,
    $3::UUID,
    COALESCE($4::email_usage_type_enum, 'personal'::email_usage_type_enum),
    COALESCE($5::BOOLEAN, FALSE),
    NOW(),
    NOW()
)
ON CONFLICT (entity_type, entity_id, email_id) DO UPDATE SET
    usage_type = EXCLUDED.usage_type,
    is_primary = EXCLUDED.is_primary,
    updated_at = NOW()
RETURNING 
    id,
    entity_id,
    email_id,
    usage_type,
    is_primary;