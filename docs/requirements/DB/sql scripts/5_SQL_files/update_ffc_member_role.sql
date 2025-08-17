-- ================================================================
-- Converted from: sp_update_ffc_member_role()
-- Type: Simple UPDATE Operation
-- Description: Update FFC member role
-- Parameters:
--   $1: p_ffc_id UUID - FFC ID
--   $2: p_persona_id UUID - Persona ID
--   $3: p_new_role ffc_role_enum - New role to assign
--   $4: p_updated_by UUID - User performing update (optional)
-- Returns: Updated FFC member record
-- ================================================================

-- This query updates an FFC member's role
-- NOTE: The audit log insert needs to be handled separately in the service layer
-- Returns the updated record or no rows if member not found

UPDATE ffc_personas SET
    ffc_role = $3::ffc_role_enum,
    updated_at = NOW(),
    updated_by = COALESCE(
        $4::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
WHERE ffc_id = $1::UUID 
  AND persona_id = $2::UUID
RETURNING 
    ffc_id,
    persona_id,
    ffc_role,
    updated_at,
    updated_by;