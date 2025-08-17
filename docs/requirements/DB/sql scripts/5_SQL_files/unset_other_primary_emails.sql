-- ================================================================
-- Supporting query for: sp_add_email_to_persona()
-- Type: UPDATE
-- Description: Unset other primary emails for a persona
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
--   $2: p_email_id UUID - The email ID that should remain primary
-- Returns: Updated records
-- NOTE: Only run when setting an email as primary
-- ================================================================

-- This query unsets the is_primary flag for all other emails of the persona

UPDATE usage_email SET
    is_primary = FALSE,
    updated_at = NOW()
WHERE entity_type = 'persona' 
  AND entity_id = $1::UUID 
  AND email_id != $2::UUID
  AND is_primary = TRUE
RETURNING 
    id,
    email_id,
    is_primary;