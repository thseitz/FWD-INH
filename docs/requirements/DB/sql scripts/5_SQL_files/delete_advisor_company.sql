-- ================================================================
-- Converted from: sp_manage_advisor_company() - DELETE action
-- Type: UPDATE (soft delete)
-- Description: Soft delete advisor company by setting is_active to FALSE
-- Parameters:
--   $1: p_company_id UUID - Company ID to delete
-- Returns: Deleted advisor company record
-- NOTE: Service layer should handle audit logging separately
-- ================================================================

-- This query performs a soft delete by setting is_active to FALSE

UPDATE advisor_companies SET
    is_active = FALSE,
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
    is_active;