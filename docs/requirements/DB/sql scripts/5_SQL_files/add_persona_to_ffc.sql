-- ================================================================
-- Converted from: sp_add_persona_to_ffc()
-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
-- Description: Add or update persona in FFC
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_ffc_id UUID - FFC ID
--   $3: p_persona_id UUID - Persona ID
--   $4: p_role ffc_role_enum - Role in FFC
--   $5: p_added_by UUID - User adding the persona
-- Returns: FFC persona record
-- ================================================================

-- This query adds a persona to an FFC or updates their role if they already exist
-- Uses ON CONFLICT to handle both insert and update cases

INSERT INTO ffc_personas (
    tenant_id,
    ffc_id,
    persona_id,
    ffc_role,
    joined_at,
    created_at,
    created_by,
    updated_at,
    updated_by
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::UUID,
    $4::ffc_role_enum,
    NOW(),
    NOW(),
    $5::UUID,
    NOW(),
    $5::UUID
)
ON CONFLICT (ffc_id, persona_id) DO UPDATE SET
    ffc_role = EXCLUDED.ffc_role,
    updated_at = NOW(),
    updated_by = EXCLUDED.updated_by
RETURNING 
    ffc_id,
    persona_id,
    ffc_role,
    joined_at,
    updated_at;