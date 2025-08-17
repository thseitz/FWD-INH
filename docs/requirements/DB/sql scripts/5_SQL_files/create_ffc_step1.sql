-- ================================================================
-- Converted from: sp_create_ffc() - Step 1
-- Type: Single INSERT
-- Description: Create a new Forward Family Circle
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_owner_user_id UUID - Owner user ID
--   $3: p_name TEXT - FFC name
--   $4: p_description TEXT - FFC description (optional)
-- Returns: Created FFC record
-- ================================================================

-- Step 1 of 2: Create the FFC
-- Step 2 (create_ffc_step2.sql) adds the owner as a member

INSERT INTO fwd_family_circles (
    tenant_id,
    owner_user_id,
    name,
    description,
    is_active,
    status,
    created_at,
    updated_at
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $3::TEXT,
    $4::TEXT,
    TRUE,
    'active',
    NOW(),
    NOW()
)
RETURNING 
    id,
    tenant_id,
    owner_user_id,
    name,
    description,
    is_active;