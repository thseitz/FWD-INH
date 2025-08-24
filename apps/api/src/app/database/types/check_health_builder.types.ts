/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/health_checks/check_health_builder.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'CheckHealthBuilder' parameters type */
export type ICheckHealthBuilderParams = void;

/** 'CheckHealthBuilder' return type */
export interface ICheckHealthBuilderResult {
  error_rate: string | null;
  health_details: Json | null;
  integration_name: string | null;
  integration_type: string | null;
  is_healthy: boolean | null;
  last_activity: Date | null;
}

/** 'CheckHealthBuilder' query type */
export interface ICheckHealthBuilderQuery {
  params: ICheckHealthBuilderParams;
  result: ICheckHealthBuilderResult;
}

const checkHealthBuilderIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_check_integration_health() - Builder.io part\n-- Type: SELECT\n-- Description: Check health of Builder.io integrations\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)\n-- Returns: Health status of Builder.io integrations\n-- ================================================================\n\n-- Check Builder.io integration health\n\nSELECT \n    'builder'::VARCHAR as integration_type,\n    'Builder.io Integration'::VARCHAR as integration_name,\n    bi.is_active as is_healthy,\n    bi.last_sync_at as last_activity,\n    0::DECIMAL as error_rate, -- No error tracking for builder yet\n    jsonb_build_object(\n        'api_key_present', bi.api_key IS NOT NULL,\n        'space_id', bi.space_id,\n        'environment', bi.environment,\n        'last_sync', bi.last_sync_at\n    ) as health_details\nFROM builder_io_integrations bi\nWHERE bi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_check_integration_health() - Builder.io part
 * -- Type: SELECT
 * -- Description: Check health of Builder.io integrations
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
 * -- Returns: Health status of Builder.io integrations
 * -- ================================================================
 * 
 * -- Check Builder.io integration health
 * 
 * SELECT 
 *     'builder'::VARCHAR as integration_type,
 *     'Builder.io Integration'::VARCHAR as integration_name,
 *     bi.is_active as is_healthy,
 *     bi.last_sync_at as last_activity,
 *     0::DECIMAL as error_rate, -- No error tracking for builder yet
 *     jsonb_build_object(
 *         'api_key_present', bi.api_key IS NOT NULL,
 *         'space_id', bi.space_id,
 *         'environment', bi.environment,
 *         'last_sync', bi.last_sync_at
 *     ) as health_details
 * FROM builder_io_integrations bi
 * WHERE bi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
 * ```
 */
export const checkHealthBuilder = new PreparedQuery<ICheckHealthBuilderParams,ICheckHealthBuilderResult>(checkHealthBuilderIR);


