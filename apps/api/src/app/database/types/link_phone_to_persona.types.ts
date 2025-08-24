/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/phones/link_phone_to_persona.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type phone_usage_type_enum = 'emergency' | 'fax' | 'home' | 'mobile' | 'primary' | 'work';

/** 'LinkPhoneToPersona' parameters type */
export type ILinkPhoneToPersonaParams = void;

/** 'LinkPhoneToPersona' return type */
export interface ILinkPhoneToPersonaResult {
  entity_id: string;
  id: string;
  is_primary: boolean | null;
  phone_id: string;
  usage_type: phone_usage_type_enum;
}

/** 'LinkPhoneToPersona' query type */
export interface ILinkPhoneToPersonaQuery {
  params: ILinkPhoneToPersonaParams;
  result: ILinkPhoneToPersonaResult;
}

const linkPhoneToPersonaIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_add_phone_to_persona()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Link phone to persona with usage details\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_persona_id UUID - Persona ID\n--   $3: p_phone_id UUID - Phone ID\n--   $4: p_usage_type phone_usage_type_enum - Usage type (default 'primary')\n--   $5: p_is_primary BOOLEAN - Is primary phone (default FALSE)\n-- Returns: Usage phone record\n-- NOTE: If is_primary is TRUE, run unset_other_primary_phones.sql after this\n-- ================================================================\n\n-- This query links a phone to a persona or updates the existing link\n\nINSERT INTO usage_phone (\n    tenant_id,\n    entity_type,\n    entity_id,\n    phone_id,\n    usage_type,\n    is_primary,\n    created_at,\n    updated_at\n) VALUES (\n    $1::INTEGER,\n    'persona',\n    $2::UUID,\n    $3::UUID,\n    COALESCE($4::phone_usage_type_enum, 'primary'::phone_usage_type_enum),\n    COALESCE($5::BOOLEAN, FALSE),\n    NOW(),\n    NOW()\n)\nON CONFLICT (entity_type, entity_id, phone_id) DO UPDATE SET\n    usage_type = EXCLUDED.usage_type,\n    is_primary = EXCLUDED.is_primary,\n    updated_at = NOW()\nRETURNING \n    id,\n    entity_id,\n    phone_id,\n    usage_type,\n    is_primary"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_add_phone_to_persona()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Link phone to persona with usage details
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_persona_id UUID - Persona ID
 * --   $3: p_phone_id UUID - Phone ID
 * --   $4: p_usage_type phone_usage_type_enum - Usage type (default 'primary')
 * --   $5: p_is_primary BOOLEAN - Is primary phone (default FALSE)
 * -- Returns: Usage phone record
 * -- NOTE: If is_primary is TRUE, run unset_other_primary_phones.sql after this
 * -- ================================================================
 * 
 * -- This query links a phone to a persona or updates the existing link
 * 
 * INSERT INTO usage_phone (
 *     tenant_id,
 *     entity_type,
 *     entity_id,
 *     phone_id,
 *     usage_type,
 *     is_primary,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     $1::INTEGER,
 *     'persona',
 *     $2::UUID,
 *     $3::UUID,
 *     COALESCE($4::phone_usage_type_enum, 'primary'::phone_usage_type_enum),
 *     COALESCE($5::BOOLEAN, FALSE),
 *     NOW(),
 *     NOW()
 * )
 * ON CONFLICT (entity_type, entity_id, phone_id) DO UPDATE SET
 *     usage_type = EXCLUDED.usage_type,
 *     is_primary = EXCLUDED.is_primary,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     entity_id,
 *     phone_id,
 *     usage_type,
 *     is_primary
 * ```
 */
export const linkPhoneToPersona = new PreparedQuery<ILinkPhoneToPersonaParams,ILinkPhoneToPersonaResult>(linkPhoneToPersonaIR);


