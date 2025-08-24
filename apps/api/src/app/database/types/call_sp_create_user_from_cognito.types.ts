/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/users/call_sp_create_user_from_cognito.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpCreateUserFromCognito' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpCreateUserFromCognitoResult = never;

/** Query 'CallSpCreateUserFromCognito' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpCreateUserFromCognitoParams = never;

const callSpCreateUserFromCognitoIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_create_user_from_cognito()\n-- Type: FUNCTION call wrapper\n-- Description: Create user from Cognito authentication\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_cognito_user_id TEXT - Cognito user ID\n--   $3: p_cognito_username TEXT - Cognito username\n--   $4: p_email TEXT - User email\n--   $5: p_phone VARCHAR - Phone number\n--   $6: p_first_name TEXT - First name\n--   $7: p_last_name TEXT - Last name\n--   $8: p_email_verified BOOLEAN - Email verified (optional, default false)\n--   $9: p_phone_verified BOOLEAN - Phone verified (optional, default false)\n--   $10: p_country_code VARCHAR - Country code (optional, default '+1')\n-- Returns: TABLE(user_id UUID, persona_id UUID, email_id UUID, phone_id UUID)\n-- ================================================================\n\n-- Call stored procedure to create user from Cognito\n\nSELECT * FROM sp_create_user_from_cognito(\n    $1::INTEGER,                         -- p_tenant_id\n    $2::TEXT,                            -- p_cognito_user_id\n    $3::TEXT,                            -- p_cognito_username\n    $4::TEXT,                            -- p_email\n    $5::VARCHAR,                         -- p_phone\n    $6::TEXT,                            -- p_first_name\n    $7::TEXT,                            -- p_last_name\n    COALESCE($8::BOOLEAN, FALSE),       -- p_email_verified\n    COALESCE($9::BOOLEAN, FALSE),       -- p_phone_verified\n    COALESCE($10::VARCHAR, '+1')        -- p_country_code\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_create_user_from_cognito()
 * -- Type: FUNCTION call wrapper
 * -- Description: Create user from Cognito authentication
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_cognito_user_id TEXT - Cognito user ID
 * --   $3: p_cognito_username TEXT - Cognito username
 * --   $4: p_email TEXT - User email
 * --   $5: p_phone VARCHAR - Phone number
 * --   $6: p_first_name TEXT - First name
 * --   $7: p_last_name TEXT - Last name
 * --   $8: p_email_verified BOOLEAN - Email verified (optional, default false)
 * --   $9: p_phone_verified BOOLEAN - Phone verified (optional, default false)
 * --   $10: p_country_code VARCHAR - Country code (optional, default '+1')
 * -- Returns: TABLE(user_id UUID, persona_id UUID, email_id UUID, phone_id UUID)
 * -- ================================================================
 * 
 * -- Call stored procedure to create user from Cognito
 * 
 * SELECT * FROM sp_create_user_from_cognito(
 *     $1::INTEGER,                         -- p_tenant_id
 *     $2::TEXT,                            -- p_cognito_user_id
 *     $3::TEXT,                            -- p_cognito_username
 *     $4::TEXT,                            -- p_email
 *     $5::VARCHAR,                         -- p_phone
 *     $6::TEXT,                            -- p_first_name
 *     $7::TEXT,                            -- p_last_name
 *     COALESCE($8::BOOLEAN, FALSE),       -- p_email_verified
 *     COALESCE($9::BOOLEAN, FALSE),       -- p_phone_verified
 *     COALESCE($10::VARCHAR, '+1')        -- p_country_code
 * )
 * ```
 */
export const callSpCreateUserFromCognito = new PreparedQuery<ICallSpCreateUserFromCognitoParams,ICallSpCreateUserFromCognitoResult>(callSpCreateUserFromCognitoIR);


