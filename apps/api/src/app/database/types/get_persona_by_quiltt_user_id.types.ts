/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/personas/get_persona_by_quiltt_user_id.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

/** 'GetPersonaByQuilttUserId' parameters type */
export type IGetPersonaByQuilttUserIdParams = void;

/** 'GetPersonaByQuilttUserId' return type */
export interface IGetPersonaByQuilttUserIdResult {
  created_at: Date | null;
  display_name: string | null;
  first_name: string;
  id: string;
  last_name: string;
  persona_type: string | null;
  status: status_enum;
  tenant_id: number;
  updated_at: Date | null;
  user_id: string | null;
}

/** 'GetPersonaByQuilttUserId' query type */
export interface IGetPersonaByQuilttUserIdQuery {
  params: IGetPersonaByQuilttUserIdParams;
  result: IGetPersonaByQuilttUserIdResult;
}

const getPersonaByQuilttUserIdIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: get_persona_by_quiltt_user_id\n-- Type: SELECT\n-- Description: Get persona details by Quiltt user ID\n-- Parameters:\n--   $1: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)\n-- Returns: Persona record\n-- Used by: QuilttIntegrationService.handleConnectionWebhook()\n-- ================================================================\n\nSELECT \n    p.id,\n    p.tenant_id,\n    p.user_id,\n    p.first_name,\n    p.last_name,\n    COALESCE(p.nickname, p.first_name || ' ' || p.last_name) as display_name,\n    'living'::TEXT as persona_type,\n    p.status,\n    p.created_at,\n    p.updated_at\nFROM personas p\nWHERE \n    p.id = $1::UUID  -- quiltt_user_id is same as persona_id\n    AND p.status = 'active'"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: get_persona_by_quiltt_user_id
 * -- Type: SELECT
 * -- Description: Get persona details by Quiltt user ID
 * -- Parameters:
 * --   $1: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)
 * -- Returns: Persona record
 * -- Used by: QuilttIntegrationService.handleConnectionWebhook()
 * -- ================================================================
 * 
 * SELECT 
 *     p.id,
 *     p.tenant_id,
 *     p.user_id,
 *     p.first_name,
 *     p.last_name,
 *     COALESCE(p.nickname, p.first_name || ' ' || p.last_name) as display_name,
 *     'living'::TEXT as persona_type,
 *     p.status,
 *     p.created_at,
 *     p.updated_at
 * FROM personas p
 * WHERE 
 *     p.id = $1::UUID  -- quiltt_user_id is same as persona_id
 *     AND p.status = 'active'
 * ```
 */
export const getPersonaByQuilttUserId = new PreparedQuery<IGetPersonaByQuilttUserIdParams,IGetPersonaByQuilttUserIdResult>(getPersonaByQuilttUserIdIR);


