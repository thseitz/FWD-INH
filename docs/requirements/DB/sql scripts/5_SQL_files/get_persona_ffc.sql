-- ================================================================
-- Name: get_persona_ffc
-- Type: SELECT
-- Description: Get FFC ID for a persona
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
-- Returns: FFC record
-- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()
-- ================================================================

SELECT 
    fp.ffc_id,
    fp.persona_id,
    fp.ffc_role,
    fp.is_active,
    f.name as ffc_name,
    f.created_at as ffc_created_at
FROM ffc_personas fp
JOIN fwd_family_circles f ON fp.ffc_id = f.id
WHERE 
    fp.persona_id = $1::UUID
    AND fp.is_active = TRUE
LIMIT 1;