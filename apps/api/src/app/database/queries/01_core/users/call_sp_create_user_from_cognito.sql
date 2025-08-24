/* @name callSpCreateUserFromCognito */
-- ================================================================
-- Wrapper for: sp_create_user_from_cognito()
-- Type: FUNCTION call wrapper
-- Description: Create user from Cognito authentication
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_cognito_user_id TEXT - Cognito user ID
--   $3: p_cognito_username TEXT - Cognito username
--   $4: p_email TEXT - User email
--   $5: p_phone VARCHAR - Phone number
--   $6: p_first_name TEXT - First name
--   $7: p_last_name TEXT - Last name
--   $8: p_email_verified BOOLEAN - Email verified (optional, default false)
--   $9: p_phone_verified BOOLEAN - Phone verified (optional, default false)
--   $10: p_country_code VARCHAR - Country code (optional, default '+1')
-- Returns: TABLE(user_id UUID, persona_id UUID, email_id UUID, phone_id UUID)
-- ================================================================

-- Call stored procedure to create user from Cognito

SELECT * FROM sp_create_user_from_cognito(
    $1::INTEGER,                         -- p_tenant_id
    $2::TEXT,                            -- p_cognito_user_id
    $3::TEXT,                            -- p_cognito_username
    $4::TEXT,                            -- p_email
    $5::VARCHAR,                         -- p_phone
    $6::TEXT,                            -- p_first_name
    $7::TEXT,                            -- p_last_name
    COALESCE($8::BOOLEAN, FALSE),       -- p_email_verified
    COALESCE($9::BOOLEAN, FALSE),       -- p_phone_verified
    COALESCE($10::VARCHAR, '+1')        -- p_country_code
);