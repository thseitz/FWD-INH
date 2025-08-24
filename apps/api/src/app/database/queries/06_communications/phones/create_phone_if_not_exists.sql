/* @name createPhoneIfNotExists */
-- ================================================================
-- Supporting query for: sp_add_phone_to_persona()
-- Type: INSERT with ON CONFLICT DO NOTHING
-- Description: Create phone number if it doesn't exist
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_country_code VARCHAR(5) - Country code (default '+1')
--   $3: p_phone VARCHAR(20) - Phone number (will be cleaned)
-- Returns: Phone record (new or existing)
-- NOTE: Phone number is cleaned using regexp_replace in service layer
-- ================================================================

-- This query creates a phone number if it doesn't exist
-- Since there's no unique constraint, we check first
-- Clean the phone number before passing: regexp_replace(phone, '[^0-9]', '', 'g')

WITH existing AS (
    SELECT id, country_code, phone_number, is_verified
    FROM phone_number
    WHERE tenant_id = $1::INTEGER 
      AND country_code = COALESCE($2::VARCHAR(5), '+1')
      AND phone_number = $3::VARCHAR(20)
),
inserted AS (
    INSERT INTO phone_number (
        tenant_id,
        country_code,
        phone_number,
        is_verified,
        created_at,
        updated_at
    )
    SELECT 
        $1::INTEGER,
        COALESCE($2::VARCHAR(5), '+1'),
        $3::VARCHAR(20),
        FALSE,
        NOW(),
        NOW()
    WHERE NOT EXISTS (SELECT 1 FROM existing)
    RETURNING id, country_code, phone_number, is_verified
)
SELECT * FROM existing
UNION ALL
SELECT * FROM inserted;