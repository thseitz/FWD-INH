/* @name searchAssets */
-- ================================================================
-- Converted from: sp_search_assets()
-- Type: Complex SELECT with optional filters
-- Description: Search assets with multiple optional filters
-- Parameters:
--   $1: p_ffc_id UUID - Filter by FFC (optional)
--   $2: p_category_code VARCHAR(50) - Filter by category (optional)
--   $3: p_owner_persona_id UUID - Filter by owner (optional)
--   $4: p_status status_enum - Filter by status (optional)
--   $5: p_min_value DECIMAL(15,2) - Minimum value (optional)
--   $6: p_max_value DECIMAL(15,2) - Maximum value (optional)
--   $7: p_search_term TEXT - Search in name/description (optional)
--   $8: p_limit INTEGER - Result limit (default 100)
--   $9: p_offset INTEGER - Result offset (default 0)
-- Returns: Filtered asset records with related data
-- ================================================================

-- Complex search with multiple JOINs and optional WHERE clauses

SELECT 
    a.id as asset_id,
    a.name as asset_name,
    ac.name as category_name,
    a.estimated_value,
    a.status,
    f.name as ffc_name,
    (
        SELECT p.first_name || ' ' || p.last_name
        FROM asset_persona ap
        JOIN personas p ON ap.persona_id = p.id
        WHERE ap.asset_id = a.id AND ap.is_primary = TRUE
        LIMIT 1
    ) as primary_owner
FROM assets a
JOIN asset_categories ac ON a.category_id = ac.id
LEFT JOIN LATERAL (
    SELECT DISTINCT fc.id, fc.name
    FROM asset_persona ap
    JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
    JOIN fwd_family_circles fc ON fp.ffc_id = fc.id
    WHERE ap.asset_id = a.id
    LIMIT 1
) f ON true
WHERE 
    ($1::UUID IS NULL OR EXISTS (
        SELECT 1 
        FROM asset_persona ap2
        JOIN ffc_personas fp2 ON ap2.persona_id = fp2.persona_id
        WHERE ap2.asset_id = a.id AND fp2.ffc_id = $1::UUID
    ))
    AND ($2::VARCHAR(50) IS NULL OR ac.code = $2::VARCHAR(50))
    AND ($4::status_enum IS NULL OR a.status = $4::status_enum)
    AND ($5::DECIMAL(15,2) IS NULL OR a.estimated_value >= $5::DECIMAL(15,2))
    AND ($6::DECIMAL(15,2) IS NULL OR a.estimated_value <= $6::DECIMAL(15,2))
    AND ($7::TEXT IS NULL OR 
         a.name ILIKE '%' || $7::TEXT || '%' OR
         a.description ILIKE '%' || $7::TEXT || '%')
    AND ($3::UUID IS NULL OR EXISTS (
        SELECT 1 FROM asset_persona ap 
        WHERE ap.asset_id = a.id AND ap.persona_id = $3::UUID
    ))
ORDER BY a.created_at DESC
LIMIT COALESCE($8::INTEGER, 100)
OFFSET COALESCE($9::INTEGER, 0);