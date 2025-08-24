/* @name getFfcSummary */
-- ================================================================
-- Converted from: sp_get_ffc_summary(p_ffc_id UUID, p_user_id UUID)
-- Type: Read-Only Query with Access Check
-- Description: Get summary information for an FFC
-- Parameters:
--   $1: p_ffc_id UUID - The FFC ID to get summary for
--   $2: p_user_id UUID - The user ID requesting the summary
-- Returns: Summary information table
-- ================================================================

-- This query retrieves summary information for an FFC
-- Note: Access check is implemented as a WHERE clause filter
-- If user is not a member, no rows will be returned

SELECT 
    f.name as ffc_name,
    u.first_name || ' ' || u.last_name as owner_name,
    (SELECT COUNT(*) FROM ffc_personas WHERE ffc_id = $1::UUID) as member_count,
    (SELECT COUNT(DISTINCT a.id) 
     FROM assets a 
     JOIN asset_persona ap ON a.id = ap.asset_id
     JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
     WHERE fp.ffc_id = $1::UUID) as asset_count,
    0::BIGINT as document_count, -- Documents not directly linked to FFCs
    f.created_at as created_date
FROM fwd_family_circles f
JOIN users u ON f.owner_user_id = u.id
WHERE f.id = $1::UUID
  -- Access check: Only return data if user is a member
  AND EXISTS (
      SELECT 1 
      FROM ffc_personas fp
      JOIN personas p ON fp.persona_id = p.id
      WHERE fp.ffc_id = $1::UUID 
      AND p.user_id = $2::UUID
  );