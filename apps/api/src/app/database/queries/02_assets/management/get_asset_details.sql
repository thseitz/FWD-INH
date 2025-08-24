/* @name getAssetDetails */
-- ================================================================
-- Converted from: sp_get_asset_details(p_asset_id UUID, p_requesting_user UUID)
-- Type: Read-Only Query with Access Check
-- Description: Get detailed information about an asset
-- Parameters:
--   $1: p_asset_id UUID - The asset ID to get details for
--   $2: p_requesting_user UUID - Optional user ID for access check
-- Returns: Detailed asset information
-- ================================================================

-- This query retrieves detailed asset information including owners and tags
-- Note: Access check is implemented via WHERE clause when user is provided
-- If user doesn't have access, no rows will be returned

SELECT 
    a.id AS asset_id,
    a.name::TEXT AS asset_name,
    a.description::TEXT AS asset_description,
    ac.name::TEXT AS category_name,
    a.estimated_value::DECIMAL AS estimated_value,
    a.currency_code AS currency_code,
    a.last_valued_date AS last_valued_date,
    a.status AS status,
    f.name::TEXT AS ffc_name,
    (
        SELECT jsonb_agg(jsonb_build_object(
            'persona_id', ap.persona_id,
            'persona_name', p.first_name || ' ' || p.last_name,
            'ownership_type', ap.ownership_type,
            'ownership_percentage', ap.ownership_percentage,
            'is_primary', ap.is_primary
        ))
        FROM asset_persona ap
        JOIN personas p ON ap.persona_id = p.id
        WHERE ap.asset_id = a.id
    ) AS owners,
    a.tags AS tags
FROM assets a
JOIN asset_categories ac ON a.category_id = ac.id
LEFT JOIN LATERAL (
    SELECT DISTINCT f.id, f.name
    FROM asset_persona ap
    JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
    JOIN fwd_family_circles f ON fp.ffc_id = f.id
    WHERE ap.asset_id = a.id
    LIMIT 1
) f ON true
WHERE a.id = $1::UUID
  -- Access check: Only apply if requesting_user is provided
  AND ($2::UUID IS NULL OR EXISTS (
      SELECT 1
      FROM asset_persona ap
      JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
      JOIN personas p ON fp.persona_id = p.id
      WHERE ap.asset_id = a.id
      AND p.user_id = $2::UUID
  ));