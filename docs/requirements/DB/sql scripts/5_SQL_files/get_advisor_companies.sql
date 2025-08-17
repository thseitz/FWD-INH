-- ================================================================
-- Converted from: sp_get_advisor_companies()
-- Type: Simple Read-Only Query with Search
-- Description: List advisor companies with optional filters and search
-- Parameters:
--   $1: p_company_type VARCHAR(50) - Optional filter by company type
--   $2: p_is_active BOOLEAN - Filter by active status (default TRUE)
--   $3: p_search_term TEXT - Optional search term
--   $4: p_limit INTEGER - Maximum records to return (default 100)
--   $5: p_offset INTEGER - Pagination offset (default 0)
-- Returns: List of advisor companies
-- ================================================================

-- This query retrieves advisor companies with filtering and search capabilities
-- Supports partial text search across multiple fields

SELECT 
    ac.id as company_id,
    ac.company_name,
    ac.company_type,
    ac.primary_contact_name,
    ac.website_url,
    ac.is_active,
    ac.created_at,
    jsonb_build_object(
        'license_number', ac.license_number,
        'license_state', ac.license_state,
        'license_expiration', ac.license_expiration
    ) as metadata
FROM advisor_companies ac
WHERE 
    ac.tenant_id = COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END, 
        1
    )
    AND (COALESCE($2::BOOLEAN, TRUE) IS NULL OR ac.is_active = COALESCE($2::BOOLEAN, TRUE))
    AND ($1::VARCHAR IS NULL OR ac.company_type = $1)
    AND ($3::TEXT IS NULL OR 
         ac.company_name ILIKE '%' || $3 || '%' OR
         ac.primary_contact_name ILIKE '%' || $3 || '%' OR
         ac.website_url ILIKE '%' || $3 || '%')
ORDER BY ac.company_name
LIMIT COALESCE($4::INTEGER, 100)
OFFSET COALESCE($5::INTEGER, 0);