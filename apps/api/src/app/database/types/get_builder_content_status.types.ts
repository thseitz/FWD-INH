/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/builder_io/get_builder_content_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetBuilderContentStatus' parameters type */
export type IGetBuilderContentStatusParams = void;

/** 'GetBuilderContentStatus' return type */
export interface IGetBuilderContentStatusResult {
  cached_content_count: number | null;
  content_model_mappings: Json | null;
  environment: string | null;
  is_active: boolean | null;
  last_sync_at: Date | null;
  space_id: string;
  status_details: Json | null;
}

/** 'GetBuilderContentStatus' query type */
export interface IGetBuilderContentStatusQuery {
  params: IGetBuilderContentStatusParams;
  result: IGetBuilderContentStatusResult;
}

const getBuilderContentStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_builder_content_status()\n-- Type: Simple Read-Only Query\n-- Description: Get Builder.io content integration status\n-- Parameters:\n--   $1: p_space_id TEXT - Optional filter by space ID\n-- Returns: Builder.io integration status information\n-- ================================================================\n\n-- This query retrieves Builder.io integration status and configuration\n-- Shows sync status, cache age, and configuration details\n\nSELECT \n    bi.space_id,\n    bi.environment,\n    bi.is_active,\n    bi.last_sync_at,\n    0 as cached_content_count,\n    bi.content_model_mappings,\n    jsonb_build_object(\n        'webhook_configured', false,\n        'cache_age_hours', \n        CASE \n            WHEN bi.last_sync_at IS NOT NULL THEN\n                EXTRACT(EPOCH FROM (NOW() - bi.last_sync_at)) / 3600\n            ELSE NULL\n        END,\n        'integration_id', bi.id\n    ) as status_details\nFROM builder_io_integrations bi\nWHERE \n    bi.tenant_id = CASE \n        WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n        THEN NULL\n        ELSE current_setting('app.current_tenant_id', true)::INTEGER\n    END\n    AND ($1::TEXT IS NULL OR bi.space_id = $1)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_builder_content_status()
 * -- Type: Simple Read-Only Query
 * -- Description: Get Builder.io content integration status
 * -- Parameters:
 * --   $1: p_space_id TEXT - Optional filter by space ID
 * -- Returns: Builder.io integration status information
 * -- ================================================================
 * 
 * -- This query retrieves Builder.io integration status and configuration
 * -- Shows sync status, cache age, and configuration details
 * 
 * SELECT 
 *     bi.space_id,
 *     bi.environment,
 *     bi.is_active,
 *     bi.last_sync_at,
 *     0 as cached_content_count,
 *     bi.content_model_mappings,
 *     jsonb_build_object(
 *         'webhook_configured', false,
 *         'cache_age_hours', 
 *         CASE 
 *             WHEN bi.last_sync_at IS NOT NULL THEN
 *                 EXTRACT(EPOCH FROM (NOW() - bi.last_sync_at)) / 3600
 *             ELSE NULL
 *         END,
 *         'integration_id', bi.id
 *     ) as status_details
 * FROM builder_io_integrations bi
 * WHERE 
 *     bi.tenant_id = CASE 
 *         WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *         THEN NULL
 *         ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *     END
 *     AND ($1::TEXT IS NULL OR bi.space_id = $1)
 * ```
 */
export const getBuilderContentStatus = new PreparedQuery<IGetBuilderContentStatusParams,IGetBuilderContentStatusResult>(getBuilderContentStatusIR);


