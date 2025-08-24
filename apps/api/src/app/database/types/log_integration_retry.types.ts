/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/health_checks/log_integration_retry.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type audit_action_enum = 'create' | 'delete' | 'export' | 'login' | 'logout' | 'permission_change' | 'read' | 'share' | 'status_change' | 'update';

export type audit_entity_type_enum = 'asset' | 'document' | 'ffc' | 'payment' | 'payment_method' | 'permission' | 'persona' | 'service_purchase' | 'subscription' | 'system' | 'user';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'LogIntegrationRetry' parameters type */
export type ILogIntegrationRetryParams = void;

/** 'LogIntegrationRetry' return type */
export interface ILogIntegrationRetryResult {
  action: audit_action_enum;
  created_at: Date | null;
  entity_id: string | null;
  entity_type: audit_entity_type_enum;
  id: string;
  new_values: Json | null;
  tenant_id: number;
  user_id: string | null;
}

/** 'LogIntegrationRetry' query type */
export interface ILogIntegrationRetryQuery {
  params: ILogIntegrationRetryParams;
  result: ILogIntegrationRetryResult;
}

const logIntegrationRetryIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_retry_failed_integration() - Audit log part\n-- Type: INSERT\n-- Description: Log integration retry attempt in audit log\n-- Parameters:\n--   $1: p_integration_id UUID - Integration ID being retried\n--   $2: p_integration_type VARCHAR(50) - Type of integration\n--   $3: p_user_id UUID - User initiating retry (optional)\n--   $4: p_success BOOLEAN - Whether retry was initiated successfully\n-- Returns: Created audit log entry\n-- ================================================================\n\n-- Log integration retry attempt\n\nINSERT INTO audit_log (\n    tenant_id,\n    user_id,\n    action,\n    entity_type,\n    entity_id,\n    new_values\n) VALUES (\n    COALESCE(current_setting('app.current_tenant_id', true)::INTEGER, 1),\n    COALESCE($3::UUID, \n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    'update'::audit_action_enum,\n    'system'::audit_entity_type_enum,\n    $1::UUID,\n    jsonb_build_object(\n        'integration_type', $2::VARCHAR(50),\n        'action', 'retry_integration',\n        'retried', $4::BOOLEAN\n    )\n)\nRETURNING \n    id,\n    tenant_id,\n    user_id,\n    action,\n    entity_type,\n    entity_id,\n    new_values,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_retry_failed_integration() - Audit log part
 * -- Type: INSERT
 * -- Description: Log integration retry attempt in audit log
 * -- Parameters:
 * --   $1: p_integration_id UUID - Integration ID being retried
 * --   $2: p_integration_type VARCHAR(50) - Type of integration
 * --   $3: p_user_id UUID - User initiating retry (optional)
 * --   $4: p_success BOOLEAN - Whether retry was initiated successfully
 * -- Returns: Created audit log entry
 * -- ================================================================
 * 
 * -- Log integration retry attempt
 * 
 * INSERT INTO audit_log (
 *     tenant_id,
 *     user_id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     new_values
 * ) VALUES (
 *     COALESCE(current_setting('app.current_tenant_id', true)::INTEGER, 1),
 *     COALESCE($3::UUID, 
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     'update'::audit_action_enum,
 *     'system'::audit_entity_type_enum,
 *     $1::UUID,
 *     jsonb_build_object(
 *         'integration_type', $2::VARCHAR(50),
 *         'action', 'retry_integration',
 *         'retried', $4::BOOLEAN
 *     )
 * )
 * RETURNING 
 *     id,
 *     tenant_id,
 *     user_id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     new_values,
 *     created_at
 * ```
 */
export const logIntegrationRetry = new PreparedQuery<ILogIntegrationRetryParams,ILogIntegrationRetryResult>(logIntegrationRetryIR);


