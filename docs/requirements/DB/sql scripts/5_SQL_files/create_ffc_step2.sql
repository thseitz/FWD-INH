-- ================================================================
-- Converted from: sp_create_ffc() - Step 2
-- Type: Conditional INSERT
-- Description: Add owner to FFC as member
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_ffc_id UUID - FFC ID (from step 1)
--   $3: p_owner_user_id UUID - Owner user ID
-- Returns: Created FFC member record (if persona exists)
-- ================================================================

-- Step 2 of 2: Add owner as FFC member
-- Only executes if owner has a persona
-- Service layer should handle this conditionally based on persona lookup

INSERT INTO ffc_personas (
    tenant_id,
    ffc_id,
    persona_id,
    ffc_role,
    joined_at,
    created_at,
    updated_at
)
SELECT 
    $1::INTEGER,
    $2::UUID,
    p.id,
    'owner'::ffc_role_enum,
    NOW(),
    NOW(),
    NOW()
FROM personas p
WHERE p.user_id = $3::UUID
  AND p.tenant_id = $1::INTEGER
LIMIT 1
ON CONFLICT (ffc_id, persona_id) DO UPDATE SET
    updated_at = NOW()
RETURNING 
    ffc_id,
    persona_id,
    ffc_role,
    joined_at;