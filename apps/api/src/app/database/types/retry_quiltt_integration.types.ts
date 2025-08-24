/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/retry_quiltt_integration.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type webhook_status_enum = 'delivered' | 'failed' | 'pending' | 'retrying';

/** 'RetryQuilttIntegration' parameters type */
export type IRetryQuilttIntegrationParams = void;

/** 'RetryQuilttIntegration' return type */
export interface IRetryQuilttIntegrationResult {
  event_type: string;
  id: string;
  integration_id: string | null;
  processing_error: string | null;
  processing_status: webhook_status_enum | null;
  retry_count: number | null;
}

/** 'RetryQuilttIntegration' query type */
export interface IRetryQuilttIntegrationQuery {
  params: IRetryQuilttIntegrationParams;
  result: IRetryQuilttIntegrationResult;
}

const retryQuilttIntegrationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_retry_failed_integration() - Quiltt part\n-- Type: UPDATE\n-- Description: Retry a failed Quiltt webhook\n-- Parameters:\n--   $1: p_integration_id UUID - Webhook log ID to retry\n--   $2: p_retry_count INTEGER - Number of retry attempts (default 1)\n-- Returns: Updated webhook log record\n-- ================================================================\n\n-- Mark failed Quiltt webhook for retry\n\nUPDATE quiltt_webhook_logs SET\n    processing_status = 'retrying',\n    retry_count = COALESCE(retry_count, 0) + COALESCE($2::INTEGER, 1),\n    processed_at = NULL\nWHERE id = $1::UUID\n  AND processing_status = 'failed'\nRETURNING \n    id,\n    integration_id,\n    processing_status,\n    retry_count,\n    event_type,\n    processing_error"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_retry_failed_integration() - Quiltt part
 * -- Type: UPDATE
 * -- Description: Retry a failed Quiltt webhook
 * -- Parameters:
 * --   $1: p_integration_id UUID - Webhook log ID to retry
 * --   $2: p_retry_count INTEGER - Number of retry attempts (default 1)
 * -- Returns: Updated webhook log record
 * -- ================================================================
 * 
 * -- Mark failed Quiltt webhook for retry
 * 
 * UPDATE quiltt_webhook_logs SET
 *     processing_status = 'retrying',
 *     retry_count = COALESCE(retry_count, 0) + COALESCE($2::INTEGER, 1),
 *     processed_at = NULL
 * WHERE id = $1::UUID
 *   AND processing_status = 'failed'
 * RETURNING 
 *     id,
 *     integration_id,
 *     processing_status,
 *     retry_count,
 *     event_type,
 *     processing_error
 * ```
 */
export const retryQuilttIntegration = new PreparedQuery<IRetryQuilttIntegrationParams,IRetryQuilttIntegrationResult>(retryQuilttIntegrationIR);


