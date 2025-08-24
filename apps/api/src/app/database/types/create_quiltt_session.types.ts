/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/create_quiltt_session.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateQuilttSession' parameters type */
export type ICreateQuilttSessionParams = void;

/** 'CreateQuilttSession' return type */
export interface ICreateQuilttSessionResult {
  created_at: Date | null;
  expires_at: Date;
  id: string;
  persona_id: string;
  session_token: string;
}

/** 'CreateQuilttSession' query type */
export interface ICreateQuilttSessionQuery {
  params: ICreateQuilttSessionParams;
  result: ICreateQuilttSessionResult;
}

const createQuilttSessionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: create_quiltt_session\n-- Type: INSERT\n-- Description: Create a temporary Quiltt session token for UI connector\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_persona_id UUID - Persona ID\n--   $3: p_session_token TEXT - Session token from Quiltt API\n--   $4: p_expires_at TIMESTAMPTZ - Token expiration time\n-- Returns: Created session record\n-- Used by: QuilttIntegrationService.createBankingSession()\n-- ================================================================\n\nINSERT INTO quiltt_sessions (\n    tenant_id,\n    persona_id,\n    session_token,\n    expires_at\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::TEXT,\n    $4::TIMESTAMPTZ\n)\nON CONFLICT (persona_id) WHERE NOT is_used\nDO UPDATE SET\n    session_token = EXCLUDED.session_token,\n    expires_at = EXCLUDED.expires_at,\n    is_used = FALSE,\n    used_at = NULL\nRETURNING \n    id,\n    persona_id,\n    session_token,\n    expires_at,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: create_quiltt_session
 * -- Type: INSERT
 * -- Description: Create a temporary Quiltt session token for UI connector
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_persona_id UUID - Persona ID
 * --   $3: p_session_token TEXT - Session token from Quiltt API
 * --   $4: p_expires_at TIMESTAMPTZ - Token expiration time
 * -- Returns: Created session record
 * -- Used by: QuilttIntegrationService.createBankingSession()
 * -- ================================================================
 * 
 * INSERT INTO quiltt_sessions (
 *     tenant_id,
 *     persona_id,
 *     session_token,
 *     expires_at
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::TEXT,
 *     $4::TIMESTAMPTZ
 * )
 * ON CONFLICT (persona_id) WHERE NOT is_used
 * DO UPDATE SET
 *     session_token = EXCLUDED.session_token,
 *     expires_at = EXCLUDED.expires_at,
 *     is_used = FALSE,
 *     used_at = NULL
 * RETURNING 
 *     id,
 *     persona_id,
 *     session_token,
 *     expires_at,
 *     created_at
 * ```
 */
export const createQuilttSession = new PreparedQuery<ICreateQuilttSessionParams,ICreateQuilttSessionResult>(createQuilttSessionIR);


