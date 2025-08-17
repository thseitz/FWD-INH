-- ================================================================
-- Converted from: sp_manage_advisor_company() - UPDATE action
-- Type: UPDATE
-- Description: Update existing advisor company
-- Parameters:
--   $1: p_company_id UUID - Company ID to update
--   $2: p_company_name TEXT - Company name (optional)
--   $3: p_company_type VARCHAR(50) - Company type (optional)
--   $4: p_contact_phone VARCHAR(20) - Primary contact phone (optional)
--   $5: p_website TEXT - Website URL (optional)
-- Returns: Updated advisor company record
-- NOTE: Service layer should handle audit logging separately
-- ================================================================

-- This query updates an existing advisor company
-- Only provided fields will be updated

UPDATE advisor_companies SET
    company_name = COALESCE($2::TEXT, company_name),
    company_type = COALESCE($3::VARCHAR(50), company_type),
    primary_contact_name = COALESCE($4::VARCHAR(20), primary_contact_name),
    website_url = COALESCE($5::TEXT, website_url),
    updated_at = NOW()
WHERE id = $1::UUID
  AND tenant_id = COALESCE(
      CASE 
          WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
          THEN NULL
          ELSE current_setting('app.current_tenant_id', true)::INTEGER
      END,
      1
  )
RETURNING 
    id,
    company_name,
    company_type,
    primary_contact_name,
    website_url,
    is_active;