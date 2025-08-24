/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/emails/create_email_if_not_exists.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

/** 'CreateEmailIfNotExists' parameters type */
export type ICreateEmailIfNotExistsParams = void;

/** 'CreateEmailIfNotExists' return type */
export interface ICreateEmailIfNotExistsResult {
  email_address: string | null;
  id: string | null;
  is_verified: boolean | null;
  status: status_enum | null;
}

/** 'CreateEmailIfNotExists' query type */
export interface ICreateEmailIfNotExistsQuery {
  params: ICreateEmailIfNotExistsParams;
  result: ICreateEmailIfNotExistsResult;
}

const createEmailIfNotExistsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_email_to_persona()\n-- Type: INSERT with ON CONFLICT DO NOTHING\n-- Description: Create email address if it doesn't exist\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_email TEXT - Email address\n-- Returns: Email record (new or existing)\n-- ================================================================\n\n-- This query creates an email address if it doesn't exist\n-- Since there's no unique constraint, we check first\n\nWITH existing AS (\n    SELECT id, email_address, is_verified, status\n    FROM email_address\n    WHERE tenant_id = $1::INTEGER \n      AND email_address = lower($2::TEXT)\n),\ninserted AS (\n    INSERT INTO email_address (\n        tenant_id,\n        email_address,\n        is_verified,\n        status,\n        created_at,\n        updated_at\n    )\n    SELECT \n        $1::INTEGER,\n        lower($2::TEXT),\n        FALSE,\n        'active',\n        NOW(),\n        NOW()\n    WHERE NOT EXISTS (SELECT 1 FROM existing)\n    RETURNING id, email_address, is_verified, status\n)\nSELECT * FROM existing\nUNION ALL\nSELECT * FROM inserted"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_email_to_persona()
 * -- Type: INSERT with ON CONFLICT DO NOTHING
 * -- Description: Create email address if it doesn't exist
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_email TEXT - Email address
 * -- Returns: Email record (new or existing)
 * -- ================================================================
 * 
 * -- This query creates an email address if it doesn't exist
 * -- Since there's no unique constraint, we check first
 * 
 * WITH existing AS (
 *     SELECT id, email_address, is_verified, status
 *     FROM email_address
 *     WHERE tenant_id = $1::INTEGER 
 *       AND email_address = lower($2::TEXT)
 * ),
 * inserted AS (
 *     INSERT INTO email_address (
 *         tenant_id,
 *         email_address,
 *         is_verified,
 *         status,
 *         created_at,
 *         updated_at
 *     )
 *     SELECT 
 *         $1::INTEGER,
 *         lower($2::TEXT),
 *         FALSE,
 *         'active',
 *         NOW(),
 *         NOW()
 *     WHERE NOT EXISTS (SELECT 1 FROM existing)
 *     RETURNING id, email_address, is_verified, status
 * )
 * SELECT * FROM existing
 * UNION ALL
 * SELECT * FROM inserted
 * ```
 */
export const createEmailIfNotExists = new PreparedQuery<ICreateEmailIfNotExistsParams,ICreateEmailIfNotExistsResult>(createEmailIfNotExistsIR);


