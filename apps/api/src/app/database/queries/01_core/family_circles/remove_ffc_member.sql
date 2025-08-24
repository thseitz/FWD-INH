/* @name removeFfcMember */
-- ================================================================
-- Converted from: sp_remove_ffc_member()
-- Type: DELETE with validation
-- Description: Remove persona from FFC (cannot remove owner)
-- Parameters:
--   $1: p_ffc_id UUID - FFC ID
--   $2: p_persona_id UUID - Persona ID to remove
-- Returns: Deleted FFC member record
-- NOTE: Service layer should:
--   1. Check if member exists and is not owner before deletion
--   2. Handle audit logging separately
-- ================================================================

-- This query removes a persona from an FFC
-- Will not delete if role is 'owner' (add WHERE clause)
-- Returns the deleted record or no rows if not found or is owner

DELETE FROM ffc_personas 
WHERE ffc_id = $1::UUID 
  AND persona_id = $2::UUID
  AND ffc_role != 'owner'  -- Prevent owner removal
RETURNING 
    ffc_id,
    persona_id,
    ffc_role,
    joined_at;