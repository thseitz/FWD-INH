/** Types generated for queries found in "apps/api/src/app/database/queries/08_audit/events/log_audit_event.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type audit_action_enum = 'create' | 'delete' | 'export' | 'login' | 'logout' | 'permission_change' | 'read' | 'share' | 'status_change' | 'update';

export type audit_entity_type_enum = 'asset' | 'document' | 'ffc' | 'payment' | 'payment_method' | 'permission' | 'persona' | 'service_purchase' | 'subscription' | 'system' | 'user';

/** 'LogAuditEvent' parameters type */
export type ILogAuditEventParams = void;

/** 'LogAuditEvent' return type */
export interface ILogAuditEventResult {
  action: audit_action_enum;
  change_summary: string | null;
  created_at: Date | null;
  entity_id: string | null;
  entity_name: string | null;
  entity_type: audit_entity_type_enum;
  id: string;
}

/** 'LogAuditEvent' query type */
export interface ILogAuditEventQuery {
  params: ILogAuditEventParams;
  result: ILogAuditEventResult;
}

const logAuditEventIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_log_audit_event()\n-- Type: INSERT\n-- Description: Create audit log entry\n-- Parameters:\n--   $1: p_action VARCHAR(50) - Action performed\n--   $2: p_entity_type VARCHAR(50) - Entity type\n--   $3: p_entity_id UUID - Entity ID\n--   $4: p_entity_name TEXT - Entity name (optional)\n--   $5: p_old_values JSONB - Old values (optional)\n--   $6: p_new_values JSONB - New values (optional)\n--   $7: p_metadata JSONB - Additional metadata (optional)\n--   $8: p_user_id UUID - User performing action (optional)\n-- Returns: Audit log entry\n-- ================================================================\n\n-- This query creates an audit log entry with automatic change summary generation\n\nINSERT INTO audit_log (\n    tenant_id,\n    user_id,\n    action,\n    entity_type,\n    entity_id,\n    entity_name,\n    old_values,\n    new_values,\n    change_summary,\n    ip_address,\n    user_agent,\n    created_at\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    COALESCE(\n        $8::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    $1::audit_action_enum,\n    $2::audit_entity_type_enum,\n    $3::UUID,\n    $4::TEXT,\n    $5::JSONB,\n    $6::JSONB,\n    COALESCE(\n        CASE \n            WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NOT NULL THEN 'Updated ' || $2\n            WHEN $5::JSONB IS NULL AND $6::JSONB IS NOT NULL THEN 'Created ' || $2\n            WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NULL THEN 'Deleted ' || $2\n            ELSE COALESCE($7::TEXT, 'Action: ' || $1)\n        END,\n        COALESCE($7::TEXT, 'Action: ' || $1)\n    ),\n    inet_client_addr(),\n    current_setting('application_name', true),\n    NOW()\n)\nRETURNING \n    id,\n    action,\n    entity_type,\n    entity_id,\n    entity_name,\n    change_summary,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_log_audit_event()
 * -- Type: INSERT
 * -- Description: Create audit log entry
 * -- Parameters:
 * --   $1: p_action VARCHAR(50) - Action performed
 * --   $2: p_entity_type VARCHAR(50) - Entity type
 * --   $3: p_entity_id UUID - Entity ID
 * --   $4: p_entity_name TEXT - Entity name (optional)
 * --   $5: p_old_values JSONB - Old values (optional)
 * --   $6: p_new_values JSONB - New values (optional)
 * --   $7: p_metadata JSONB - Additional metadata (optional)
 * --   $8: p_user_id UUID - User performing action (optional)
 * -- Returns: Audit log entry
 * -- ================================================================
 * 
 * -- This query creates an audit log entry with automatic change summary generation
 * 
 * INSERT INTO audit_log (
 *     tenant_id,
 *     user_id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     entity_name,
 *     old_values,
 *     new_values,
 *     change_summary,
 *     ip_address,
 *     user_agent,
 *     created_at
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     COALESCE(
 *         $8::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     $1::audit_action_enum,
 *     $2::audit_entity_type_enum,
 *     $3::UUID,
 *     $4::TEXT,
 *     $5::JSONB,
 *     $6::JSONB,
 *     COALESCE(
 *         CASE 
 *             WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NOT NULL THEN 'Updated ' || $2
 *             WHEN $5::JSONB IS NULL AND $6::JSONB IS NOT NULL THEN 'Created ' || $2
 *             WHEN $5::JSONB IS NOT NULL AND $6::JSONB IS NULL THEN 'Deleted ' || $2
 *             ELSE COALESCE($7::TEXT, 'Action: ' || $1)
 *         END,
 *         COALESCE($7::TEXT, 'Action: ' || $1)
 *     ),
 *     inet_client_addr(),
 *     current_setting('application_name', true),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     entity_name,
 *     change_summary,
 *     created_at
 * ```
 */
export const logAuditEvent = new PreparedQuery<ILogAuditEventParams,ILogAuditEventResult>(logAuditEventIR);


