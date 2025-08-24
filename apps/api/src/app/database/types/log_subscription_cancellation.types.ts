/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/cancellations/log_subscription_cancellation.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type audit_action_enum = 'create' | 'delete' | 'export' | 'login' | 'logout' | 'permission_change' | 'read' | 'share' | 'status_change' | 'update';

export type audit_entity_type_enum = 'asset' | 'document' | 'ffc' | 'payment' | 'payment_method' | 'permission' | 'persona' | 'service_purchase' | 'subscription' | 'system' | 'user';

/** 'LogSubscriptionCancellation' parameters type */
export type ILogSubscriptionCancellationParams = void;

/** 'LogSubscriptionCancellation' return type */
export interface ILogSubscriptionCancellationResult {
  action: audit_action_enum;
  change_summary: string | null;
  created_at: Date | null;
  entity_id: string | null;
  entity_type: audit_entity_type_enum;
  id: string;
  tenant_id: number;
  user_id: string | null;
}

/** 'LogSubscriptionCancellation' query type */
export interface ILogSubscriptionCancellationQuery {
  params: ILogSubscriptionCancellationParams;
  result: ILogSubscriptionCancellationResult;
}

const logSubscriptionCancellationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_cancel_subscription() - Part 4\n-- Type: INSERT\n-- Description: Log subscription cancellation in audit log\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_cancelled_by UUID - User who canceled\n--   $3: p_subscription_id UUID - Subscription ID\n--   $4: p_reason TEXT - Cancellation reason\n-- Returns: Created audit log entry\n-- ================================================================\n\n-- Log subscription cancellation to audit\n\nINSERT INTO audit_log (\n    tenant_id,\n    user_id,\n    action,\n    entity_type,\n    entity_id,\n    change_summary\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    'update',\n    'subscription',\n    $3::UUID,\n    format('Subscription canceled. Reason: %s', COALESCE($4::TEXT, 'No reason provided'))\n)\nRETURNING \n    id,\n    tenant_id,\n    user_id,\n    action,\n    entity_type,\n    entity_id,\n    change_summary,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_cancel_subscription() - Part 4
 * -- Type: INSERT
 * -- Description: Log subscription cancellation in audit log
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_cancelled_by UUID - User who canceled
 * --   $3: p_subscription_id UUID - Subscription ID
 * --   $4: p_reason TEXT - Cancellation reason
 * -- Returns: Created audit log entry
 * -- ================================================================
 * 
 * -- Log subscription cancellation to audit
 * 
 * INSERT INTO audit_log (
 *     tenant_id,
 *     user_id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     change_summary
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     'update',
 *     'subscription',
 *     $3::UUID,
 *     format('Subscription canceled. Reason: %s', COALESCE($4::TEXT, 'No reason provided'))
 * )
 * RETURNING 
 *     id,
 *     tenant_id,
 *     user_id,
 *     action,
 *     entity_type,
 *     entity_id,
 *     change_summary,
 *     created_at
 * ```
 */
export const logSubscriptionCancellation = new PreparedQuery<ILogSubscriptionCancellationParams,ILogSubscriptionCancellationResult>(logSubscriptionCancellationIR);


