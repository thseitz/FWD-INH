/* @name createEmailIfNotExists */
-- ================================================================
-- Supporting query for: sp_add_email_to_persona()
-- Type: INSERT with ON CONFLICT DO NOTHING
-- Description: Create email address if it doesn't exist
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_email TEXT - Email address
-- Returns: Email record (new or existing)
-- ================================================================

-- This query creates an email address if it doesn't exist
-- Since there's no unique constraint, we check first

WITH existing AS (
    SELECT id, email_address, is_verified, status
    FROM email_address
    WHERE tenant_id = $1::INTEGER 
      AND email_address = lower($2::TEXT)
),
inserted AS (
    INSERT INTO email_address (
        tenant_id,
        email_address,
        is_verified,
        status,
        created_at,
        updated_at
    )
    SELECT 
        $1::INTEGER,
        lower($2::TEXT),
        FALSE,
        'active',
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM existing)
    RETURNING id, email_address, is_verified, status
)
SELECT * FROM existing
UNION ALL
SELECT * FROM inserted;