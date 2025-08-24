/* @name unsetOtherPrimaryPhones */
-- ================================================================
-- Supporting query for: sp_add_phone_to_persona()
-- Type: UPDATE
-- Description: Unset other primary phones for a persona
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
--   $2: p_phone_id UUID - The phone ID that should remain primary
-- Returns: Updated records
-- NOTE: Only run when setting a phone as primary
-- ================================================================

-- This query unsets the is_primary flag for all other phones of the persona

UPDATE usage_phone SET
    is_primary = FALSE,
    updated_at = NOW()
WHERE entity_type = 'persona' 
  AND entity_id = $1::UUID 
  AND phone_id != $2::UUID
  AND is_primary = TRUE
RETURNING 
    id,
    phone_id,
    is_primary;