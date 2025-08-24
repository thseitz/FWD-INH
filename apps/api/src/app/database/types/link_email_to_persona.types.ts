/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/emails/link_email_to_persona.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type email_usage_type_enum = 'backup' | 'billing' | 'notifications' | 'personal' | 'primary' | 'work';

/** 'LinkEmailToPersona' parameters type */
export type ILinkEmailToPersonaParams = void;

/** 'LinkEmailToPersona' return type */
export interface ILinkEmailToPersonaResult {
  email_id: string;
  entity_id: string;
  id: string;
  is_primary: boolean | null;
  usage_type: email_usage_type_enum;
}

/** 'LinkEmailToPersona' query type */
export interface ILinkEmailToPersonaQuery {
  params: ILinkEmailToPersonaParams;
  result: ILinkEmailToPersonaResult;
}

const linkEmailToPersonaIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_email_to_persona()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Link email to persona with usage details\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_persona_id UUID - Persona ID\n--   $3: p_email_id UUID - Email ID\n--   $4: p_usage_type email_usage_type_enum - Usage type (default 'personal')\n--   $5: p_is_primary BOOLEAN - Is primary email (default FALSE)\n-- Returns: Usage email record\n-- NOTE: If is_primary is TRUE, run unset_other_primary_emails.sql after this\n-- ================================================================\n\n-- This query links an email to a persona or updates the existing link\n\nINSERT INTO usage_email (\n    tenant_id,\n    entity_type,\n    entity_id,\n    email_id,\n    usage_type,\n    is_primary,\n    created_at,\n    updated_at\n) VALUES (\n    $1::INTEGER,\n    'persona',\n    $2::UUID,\n    $3::UUID,\n    COALESCE($4::email_usage_type_enum, 'personal'::email_usage_type_enum),\n    COALESCE($5::BOOLEAN, FALSE),\n    NOW(),\n    NOW()\n)\nON CONFLICT (entity_type, entity_id, email_id) DO UPDATE SET\n    usage_type = EXCLUDED.usage_type,\n    is_primary = EXCLUDED.is_primary,\n    updated_at = NOW()\nRETURNING \n    id,\n    entity_id,\n    email_id,\n    usage_type,\n    is_primary"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_email_to_persona()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Link email to persona with usage details
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_persona_id UUID - Persona ID
 * --   $3: p_email_id UUID - Email ID
 * --   $4: p_usage_type email_usage_type_enum - Usage type (default 'personal')
 * --   $5: p_is_primary BOOLEAN - Is primary email (default FALSE)
 * -- Returns: Usage email record
 * -- NOTE: If is_primary is TRUE, run unset_other_primary_emails.sql after this
 * -- ================================================================
 * 
 * -- This query links an email to a persona or updates the existing link
 * 
 * INSERT INTO usage_email (
 *     tenant_id,
 *     entity_type,
 *     entity_id,
 *     email_id,
 *     usage_type,
 *     is_primary,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     $1::INTEGER,
 *     'persona',
 *     $2::UUID,
 *     $3::UUID,
 *     COALESCE($4::email_usage_type_enum, 'personal'::email_usage_type_enum),
 *     COALESCE($5::BOOLEAN, FALSE),
 *     NOW(),
 *     NOW()
 * )
 * ON CONFLICT (entity_type, entity_id, email_id) DO UPDATE SET
 *     usage_type = EXCLUDED.usage_type,
 *     is_primary = EXCLUDED.is_primary,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     entity_id,
 *     email_id,
 *     usage_type,
 *     is_primary
 * ```
 */
export const linkEmailToPersona = new PreparedQuery<ILinkEmailToPersonaParams,ILinkEmailToPersonaResult>(linkEmailToPersonaIR);


