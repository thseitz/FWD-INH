-- ================================================================
-- Converted from: sp_manage_advisor_company() - CREATE action
-- Type: INSERT
-- Description: Create new advisor company
-- Parameters:
--   $1: p_company_name TEXT - Company name
--   $2: p_company_type VARCHAR(50) - Company type (default 'General')
--   $3: p_contact_phone VARCHAR(20) - Primary contact phone
--   $4: p_website TEXT - Website URL
-- Returns: New advisor company record
-- NOTE: Service layer should handle audit logging separately
-- ================================================================

-- This query creates a new advisor company

INSERT INTO advisor_companies (
    tenant_id,
    company_name,
    company_type,
    primary_contact_name,  -- Note: storing phone in contact name field
    website_url,
    is_active,
    created_at,
    updated_at
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    $1::TEXT,
    COALESCE($2::VARCHAR(50), 'General'),
    $3::VARCHAR(20),  -- Primary contact phone
    $4::TEXT,
    TRUE,
    NOW(),
    NOW()
)
RETURNING 
    id,
    company_name,
    company_type,
    primary_contact_name,
    website_url,
    is_active;