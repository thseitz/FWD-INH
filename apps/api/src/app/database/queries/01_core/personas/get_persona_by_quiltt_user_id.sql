/* @name getPersonaByQuilttUserId */
-- ================================================================
-- Name: get_persona_by_quiltt_user_id
-- Type: SELECT
-- Description: Get persona details by Quiltt user ID
-- Parameters:
--   $1: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)
-- Returns: Persona record
-- Used by: QuilttIntegrationService.handleConnectionWebhook()
-- ================================================================

SELECT 
    p.id,
    p.tenant_id,
    p.user_id,
    p.first_name,
    p.last_name,
    COALESCE(p.nickname, p.first_name || ' ' || p.last_name) as display_name,
    'living'::TEXT as persona_type,
    p.status,
    p.created_at,
    p.updated_at
FROM personas p
WHERE 
    p.id = $1::UUID  -- quiltt_user_id is same as persona_id
    AND p.status = 'active';