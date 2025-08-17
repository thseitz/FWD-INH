-- ================================================================
-- Supporting query for: sp_add_phone_to_persona()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Link phone to persona with usage details
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_persona_id UUID - Persona ID
--   $3: p_phone_id UUID - Phone ID
--   $4: p_usage_type phone_usage_type_enum - Usage type (default 'primary')
--   $5: p_is_primary BOOLEAN - Is primary phone (default FALSE)
-- Returns: Usage phone record
-- NOTE: If is_primary is TRUE, run unset_other_primary_phones.sql after this
-- ================================================================

-- This query links a phone to a persona or updates the existing link

INSERT INTO usage_phone (
    tenant_id,
    entity_type,
    entity_id,
    phone_id,
    usage_type,
    is_primary,
    created_at,
    updated_at
) VALUES (
    $1::INTEGER,
    'persona',
    $2::UUID,
    $3::UUID,
    COALESCE($4::phone_usage_type_enum, 'primary'::phone_usage_type_enum),
    COALESCE($5::BOOLEAN, FALSE),
    NOW(),
    NOW()
)
ON CONFLICT (entity_type, entity_id, phone_id) DO UPDATE SET
    usage_type = EXCLUDED.usage_type,
    is_primary = EXCLUDED.is_primary,
    updated_at = NOW()
RETURNING 
    id,
    entity_id,
    phone_id,
    usage_type,
    is_primary;