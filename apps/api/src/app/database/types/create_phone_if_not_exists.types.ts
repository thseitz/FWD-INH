/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/phones/create_phone_if_not_exists.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreatePhoneIfNotExists' parameters type */
export type ICreatePhoneIfNotExistsParams = void;

/** 'CreatePhoneIfNotExists' return type */
export interface ICreatePhoneIfNotExistsResult {
  country_code: string | null;
  id: string | null;
  is_verified: boolean | null;
  phone_number: string | null;
}

/** 'CreatePhoneIfNotExists' query type */
export interface ICreatePhoneIfNotExistsQuery {
  params: ICreatePhoneIfNotExistsParams;
  result: ICreatePhoneIfNotExistsResult;
}

const createPhoneIfNotExistsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_phone_to_persona()\n-- Type: INSERT with ON CONFLICT DO NOTHING\n-- Description: Create phone number if it doesn't exist\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_country_code VARCHAR(5) - Country code (default '+1')\n--   $3: p_phone VARCHAR(20) - Phone number (will be cleaned)\n-- Returns: Phone record (new or existing)\n-- NOTE: Phone number is cleaned using regexp_replace in service layer\n-- ================================================================\n\n-- This query creates a phone number if it doesn't exist\n-- Since there's no unique constraint, we check first\n-- Clean the phone number before passing: regexp_replace(phone, '[^0-9]', '', 'g')\n\nWITH existing AS (\n    SELECT id, country_code, phone_number, is_verified\n    FROM phone_number\n    WHERE tenant_id = $1::INTEGER \n      AND country_code = COALESCE($2::VARCHAR(5), '+1')\n      AND phone_number = $3::VARCHAR(20)\n),\ninserted AS (\n    INSERT INTO phone_number (\n        tenant_id,\n        country_code,\n        phone_number,\n        is_verified,\n        created_at,\n        updated_at\n    )\n    SELECT \n        $1::INTEGER,\n        COALESCE($2::VARCHAR(5), '+1'),\n        $3::VARCHAR(20),\n        FALSE,\n        NOW(),\n        NOW()\n    WHERE NOT EXISTS (SELECT 1 FROM existing)\n    RETURNING id, country_code, phone_number, is_verified\n)\nSELECT * FROM existing\nUNION ALL\nSELECT * FROM inserted"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_phone_to_persona()
 * -- Type: INSERT with ON CONFLICT DO NOTHING
 * -- Description: Create phone number if it doesn't exist
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_country_code VARCHAR(5) - Country code (default '+1')
 * --   $3: p_phone VARCHAR(20) - Phone number (will be cleaned)
 * -- Returns: Phone record (new or existing)
 * -- NOTE: Phone number is cleaned using regexp_replace in service layer
 * -- ================================================================
 * 
 * -- This query creates a phone number if it doesn't exist
 * -- Since there's no unique constraint, we check first
 * -- Clean the phone number before passing: regexp_replace(phone, '[^0-9]', '', 'g')
 * 
 * WITH existing AS (
 *     SELECT id, country_code, phone_number, is_verified
 *     FROM phone_number
 *     WHERE tenant_id = $1::INTEGER 
 *       AND country_code = COALESCE($2::VARCHAR(5), '+1')
 *       AND phone_number = $3::VARCHAR(20)
 * ),
 * inserted AS (
 *     INSERT INTO phone_number (
 *         tenant_id,
 *         country_code,
 *         phone_number,
 *         is_verified,
 *         created_at,
 *         updated_at
 *     )
 *     SELECT 
 *         $1::INTEGER,
 *         COALESCE($2::VARCHAR(5), '+1'),
 *         $3::VARCHAR(20),
 *         FALSE,
 *         NOW(),
 *         NOW()
 *     WHERE NOT EXISTS (SELECT 1 FROM existing)
 *     RETURNING id, country_code, phone_number, is_verified
 * )
 * SELECT * FROM existing
 * UNION ALL
 * SELECT * FROM inserted
 * ```
 */
export const createPhoneIfNotExists = new PreparedQuery<ICreatePhoneIfNotExistsParams,ICreatePhoneIfNotExistsResult>(createPhoneIfNotExistsIR);


