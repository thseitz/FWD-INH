/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/create_quiltt_integration.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type integration_status_enum = 'connected' | 'disconnected' | 'error' | 'expired' | 'pending';

export type sync_status_enum = 'completed' | 'failed' | 'in_progress' | 'partial' | 'pending';

/** 'CreateQuilttIntegration' parameters type */
export type ICreateQuilttIntegrationParams = void;

/** 'CreateQuilttIntegration' return type */
export interface ICreateQuilttIntegrationResult {
  connection_status: integration_status_enum | null;
  id: string;
  last_sync_at: Date | null;
  persona_id: string;
  quiltt_connection_id: string;
  quiltt_user_id: string;
  sync_status: sync_status_enum | null;
  tenant_id: number;
}

/** 'CreateQuilttIntegration' query type */
export interface ICreateQuilttIntegrationQuery {
  params: ICreateQuilttIntegrationParams;
  result: ICreateQuilttIntegrationResult;
}

const createQuilttIntegrationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: create_quiltt_integration\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Create or update Quiltt integration for a persona\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_persona_id UUID - Persona ID\n--   $3: p_quiltt_user_id TEXT - Quiltt user/profile ID\n--   $4: p_quiltt_connection_id TEXT - Quiltt connection ID\n--   $5: p_connection_status TEXT - Connection status (connected/disconnected)\n--   $6: p_sync_status TEXT - Sync status (pending/completed/failed)\n-- Returns: Integration record\n-- Used by: QuilttIntegrationService.handleConnectionWebhook()\n-- ================================================================\n\nINSERT INTO quiltt_integrations (\n    tenant_id,\n    persona_id,\n    quiltt_user_id,\n    quiltt_connection_id,\n    connection_status,\n    sync_status,\n    last_sync_at,\n    is_active\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::TEXT,\n    $4::TEXT,\n    $5::integration_status_enum,\n    $6::sync_status_enum,\n    NOW(),\n    TRUE\n)\nON CONFLICT (tenant_id, persona_id) \nDO UPDATE SET \n    quiltt_connection_id = EXCLUDED.quiltt_connection_id,\n    connection_status = EXCLUDED.connection_status,\n    sync_status = EXCLUDED.sync_status,\n    last_sync_at = NOW(),\n    is_active = TRUE,\n    updated_at = NOW()\nRETURNING \n    id,\n    tenant_id,\n    persona_id,\n    quiltt_user_id,\n    quiltt_connection_id,\n    connection_status,\n    sync_status,\n    last_sync_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: create_quiltt_integration
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Create or update Quiltt integration for a persona
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_persona_id UUID - Persona ID
 * --   $3: p_quiltt_user_id TEXT - Quiltt user/profile ID
 * --   $4: p_quiltt_connection_id TEXT - Quiltt connection ID
 * --   $5: p_connection_status TEXT - Connection status (connected/disconnected)
 * --   $6: p_sync_status TEXT - Sync status (pending/completed/failed)
 * -- Returns: Integration record
 * -- Used by: QuilttIntegrationService.handleConnectionWebhook()
 * -- ================================================================
 * 
 * INSERT INTO quiltt_integrations (
 *     tenant_id,
 *     persona_id,
 *     quiltt_user_id,
 *     quiltt_connection_id,
 *     connection_status,
 *     sync_status,
 *     last_sync_at,
 *     is_active
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::TEXT,
 *     $4::TEXT,
 *     $5::integration_status_enum,
 *     $6::sync_status_enum,
 *     NOW(),
 *     TRUE
 * )
 * ON CONFLICT (tenant_id, persona_id) 
 * DO UPDATE SET 
 *     quiltt_connection_id = EXCLUDED.quiltt_connection_id,
 *     connection_status = EXCLUDED.connection_status,
 *     sync_status = EXCLUDED.sync_status,
 *     last_sync_at = NOW(),
 *     is_active = TRUE,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     tenant_id,
 *     persona_id,
 *     quiltt_user_id,
 *     quiltt_connection_id,
 *     connection_status,
 *     sync_status,
 *     last_sync_at
 * ```
 */
export const createQuilttIntegration = new PreparedQuery<ICreateQuilttIntegrationParams,ICreateQuilttIntegrationResult>(createQuilttIntegrationIR);


