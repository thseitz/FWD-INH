/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/health_checks/check_health_quiltt.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'CheckHealthQuiltt' parameters type */
export type ICheckHealthQuilttParams = void;

/** 'CheckHealthQuiltt' return type */
export interface ICheckHealthQuilttResult {
  error_rate: string | null;
  health_details: Json | null;
  integration_name: string | null;
  integration_type: string | null;
  is_healthy: boolean | null;
  last_activity: Date | null;
}

/** 'CheckHealthQuiltt' query type */
export interface ICheckHealthQuilttQuery {
  params: ICheckHealthQuilttParams;
  result: ICheckHealthQuilttResult;
}

const checkHealthQuilttIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_check_integration_health() - Quiltt part\n-- Type: SELECT\n-- Description: Check health of Quiltt integrations\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)\n-- Returns: Health status of Quiltt integrations\n-- ================================================================\n\n-- Check Quiltt integration health with error rates\n\nWITH integration_errors AS (\n    SELECT \n        qi.id,\n        COUNT(*) FILTER (WHERE wl.processing_status = 'failed')::DECIMAL / NULLIF(COUNT(*), 0) as error_rate\n    FROM quiltt_integrations qi\n    LEFT JOIN quiltt_webhook_logs wl ON wl.integration_id = qi.id \n        AND wl.received_at > (NOW() - INTERVAL '24 hours')\n    WHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)\n    GROUP BY qi.id\n)\nSELECT \n    'quiltt'::VARCHAR as integration_type,\n    'Quiltt Integration'::VARCHAR as integration_name,\n    (qi.is_active AND qi.token_expires_at > NOW()) as is_healthy,\n    qi.last_sync_at as last_activity,\n    COALESCE(ie.error_rate, 0) as error_rate,\n    jsonb_build_object(\n        'integration_id', qi.id,\n        'expired', qi.token_expires_at < NOW(),\n        'sync_accounts', qi.sync_accounts,\n        'sync_transactions', qi.sync_transactions,\n        'last_sync', qi.last_sync_at\n    ) as health_details\nFROM quiltt_integrations qi\nLEFT JOIN integration_errors ie ON ie.id = qi.id\nWHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_check_integration_health() - Quiltt part
 * -- Type: SELECT
 * -- Description: Check health of Quiltt integrations
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
 * -- Returns: Health status of Quiltt integrations
 * -- ================================================================
 * 
 * -- Check Quiltt integration health with error rates
 * 
 * WITH integration_errors AS (
 *     SELECT 
 *         qi.id,
 *         COUNT(*) FILTER (WHERE wl.processing_status = 'failed')::DECIMAL / NULLIF(COUNT(*), 0) as error_rate
 *     FROM quiltt_integrations qi
 *     LEFT JOIN quiltt_webhook_logs wl ON wl.integration_id = qi.id 
 *         AND wl.received_at > (NOW() - INTERVAL '24 hours')
 *     WHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
 *     GROUP BY qi.id
 * )
 * SELECT 
 *     'quiltt'::VARCHAR as integration_type,
 *     'Quiltt Integration'::VARCHAR as integration_name,
 *     (qi.is_active AND qi.token_expires_at > NOW()) as is_healthy,
 *     qi.last_sync_at as last_activity,
 *     COALESCE(ie.error_rate, 0) as error_rate,
 *     jsonb_build_object(
 *         'integration_id', qi.id,
 *         'expired', qi.token_expires_at < NOW(),
 *         'sync_accounts', qi.sync_accounts,
 *         'sync_transactions', qi.sync_transactions,
 *         'last_sync', qi.last_sync_at
 *     ) as health_details
 * FROM quiltt_integrations qi
 * LEFT JOIN integration_errors ie ON ie.id = qi.id
 * WHERE qi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
 * ```
 */
export const checkHealthQuiltt = new PreparedQuery<ICheckHealthQuilttParams,ICheckHealthQuilttResult>(checkHealthQuilttIR);


