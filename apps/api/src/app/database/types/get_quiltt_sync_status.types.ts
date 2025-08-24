/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/get_quiltt_sync_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetQuilttSyncStatus' parameters type */
export type IGetQuilttSyncStatusParams = void;

/** 'GetQuilttSyncStatus' return type */
export interface IGetQuilttSyncStatusResult {
  integration_active: boolean | null;
  last_sync_at: Date | null;
  recent_syncs: Json | null;
  sync_statistics: Json | null;
  sync_status: string | null;
}

/** 'GetQuilttSyncStatus' query type */
export interface IGetQuilttSyncStatusQuery {
  params: IGetQuilttSyncStatusParams;
  result: IGetQuilttSyncStatusResult;
}

const getQuilttSyncStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_quiltt_sync_status()\n-- Type: Complex Read-Only Query with CTEs\n-- Description: Get Quiltt integration sync status and statistics\n-- Parameters:\n--   $1: p_user_id UUID - User ID to check status for\n--   $2: p_days_back INTEGER - Number of days to look back (default 7)\n-- Returns: Integration status and sync statistics\n-- ================================================================\n\n-- This query retrieves Quiltt integration status with recent sync history\n-- Uses multiple CTEs to aggregate sync statistics\n\nWITH integration_info AS (\n    SELECT \n        qi.*\n    FROM quiltt_integrations qi\n    JOIN personas p ON qi.persona_id = p.id\n    WHERE p.user_id = $1::UUID\n    AND qi.tenant_id = COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    )\n),\nrecent_logs AS (\n    SELECT \n        jsonb_agg(\n            jsonb_build_object(\n                'received_at', qwl.received_at,\n                'event_type', qwl.event_type,\n                'webhook_id', qwl.webhook_id,\n                'status', qwl.processing_status,\n                'records', COALESCE(qwl.payload->'records_synced', '0'::jsonb)\n            ) ORDER BY qwl.received_at DESC\n        ) as logs\n    FROM quiltt_webhook_logs qwl\n    JOIN integration_info ii ON qwl.integration_id = ii.id\n    WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))\n),\nsync_stats AS (\n    SELECT \n        COUNT(*) as total_syncs,\n        COUNT(*) FILTER (WHERE qwl.processing_status = 'delivered') as successful_syncs,\n        COUNT(*) FILTER (WHERE qwl.processing_status = 'failed') as failed_syncs,\n        AVG(COALESCE((qwl.payload->>'records_synced')::INTEGER, 0)) as avg_records_per_sync\n    FROM quiltt_webhook_logs qwl\n    JOIN integration_info ii ON qwl.integration_id = ii.id\n    WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))\n)\nSELECT \n    COALESCE(ii.is_active, false) as integration_active,\n    ii.last_sync_at,\n    COALESCE(ii.sync_status::TEXT, 'pending') as sync_status,\n    COALESCE(rl.logs, '[]'::jsonb) as recent_syncs,\n    jsonb_build_object(\n        'total_syncs', COALESCE(ss.total_syncs, 0),\n        'successful_syncs', COALESCE(ss.successful_syncs, 0),\n        'failed_syncs', COALESCE(ss.failed_syncs, 0),\n        'avg_records_per_sync', COALESCE(ss.avg_records_per_sync, 0)\n    ) as sync_statistics\nFROM integration_info ii\nLEFT JOIN recent_logs rl ON true\nLEFT JOIN sync_stats ss ON true"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_quiltt_sync_status()
 * -- Type: Complex Read-Only Query with CTEs
 * -- Description: Get Quiltt integration sync status and statistics
 * -- Parameters:
 * --   $1: p_user_id UUID - User ID to check status for
 * --   $2: p_days_back INTEGER - Number of days to look back (default 7)
 * -- Returns: Integration status and sync statistics
 * -- ================================================================
 * 
 * -- This query retrieves Quiltt integration status with recent sync history
 * -- Uses multiple CTEs to aggregate sync statistics
 * 
 * WITH integration_info AS (
 *     SELECT 
 *         qi.*
 *     FROM quiltt_integrations qi
 *     JOIN personas p ON qi.persona_id = p.id
 *     WHERE p.user_id = $1::UUID
 *     AND qi.tenant_id = COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     )
 * ),
 * recent_logs AS (
 *     SELECT 
 *         jsonb_agg(
 *             jsonb_build_object(
 *                 'received_at', qwl.received_at,
 *                 'event_type', qwl.event_type,
 *                 'webhook_id', qwl.webhook_id,
 *                 'status', qwl.processing_status,
 *                 'records', COALESCE(qwl.payload->'records_synced', '0'::jsonb)
 *             ) ORDER BY qwl.received_at DESC
 *         ) as logs
 *     FROM quiltt_webhook_logs qwl
 *     JOIN integration_info ii ON qwl.integration_id = ii.id
 *     WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))
 * ),
 * sync_stats AS (
 *     SELECT 
 *         COUNT(*) as total_syncs,
 *         COUNT(*) FILTER (WHERE qwl.processing_status = 'delivered') as successful_syncs,
 *         COUNT(*) FILTER (WHERE qwl.processing_status = 'failed') as failed_syncs,
 *         AVG(COALESCE((qwl.payload->>'records_synced')::INTEGER, 0)) as avg_records_per_sync
 *     FROM quiltt_webhook_logs qwl
 *     JOIN integration_info ii ON qwl.integration_id = ii.id
 *     WHERE qwl.received_at > (NOW() - INTERVAL '1 day' * COALESCE($2::INTEGER, 7))
 * )
 * SELECT 
 *     COALESCE(ii.is_active, false) as integration_active,
 *     ii.last_sync_at,
 *     COALESCE(ii.sync_status::TEXT, 'pending') as sync_status,
 *     COALESCE(rl.logs, '[]'::jsonb) as recent_syncs,
 *     jsonb_build_object(
 *         'total_syncs', COALESCE(ss.total_syncs, 0),
 *         'successful_syncs', COALESCE(ss.successful_syncs, 0),
 *         'failed_syncs', COALESCE(ss.failed_syncs, 0),
 *         'avg_records_per_sync', COALESCE(ss.avg_records_per_sync, 0)
 *     ) as sync_statistics
 * FROM integration_info ii
 * LEFT JOIN recent_logs rl ON true
 * LEFT JOIN sync_stats ss ON true
 * ```
 */
export const getQuilttSyncStatus = new PreparedQuery<IGetQuilttSyncStatusParams,IGetQuilttSyncStatusResult>(getQuilttSyncStatusIR);


