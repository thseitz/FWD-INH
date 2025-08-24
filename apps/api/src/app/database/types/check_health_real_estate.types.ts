/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/health_checks/check_health_real_estate.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'CheckHealthRealEstate' parameters type */
export type ICheckHealthRealEstateParams = void;

/** 'CheckHealthRealEstate' return type */
export interface ICheckHealthRealEstateResult {
  error_rate: string | null;
  health_details: Json | null;
  integration_name: string | null;
  integration_type: string | null;
  is_healthy: boolean | null;
  last_activity: Date | null;
}

/** 'CheckHealthRealEstate' query type */
export interface ICheckHealthRealEstateQuery {
  params: ICheckHealthRealEstateParams;
  result: ICheckHealthRealEstateResult;
}

const checkHealthRealEstateIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_check_integration_health() - Real Estate part\n-- Type: SELECT with CTE\n-- Description: Check health of Real Estate provider integrations\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)\n-- Returns: Health status of Real Estate integrations\n-- ================================================================\n\n-- Check Real Estate integration health with 7-day sync statistics\n\nWITH recent_syncs AS (\n    SELECT \n        pi.id,\n        pi.provider_name,\n        COUNT(*) as total_syncs,\n        COUNT(*) FILTER (WHERE sl.sync_status = 'failed') as failed_syncs,\n        MAX(sl.completed_at) as last_sync\n    FROM real_estate_provider_integrations pi\n    LEFT JOIN real_estate_sync_logs sl ON pi.id = sl.integration_id\n        AND sl.initiated_at > (NOW() - INTERVAL '7 days')\n    WHERE pi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)\n    GROUP BY pi.id, pi.provider_name\n)\nSELECT \n    'real_estate'::VARCHAR as integration_type,\n    ('Real Estate - ' || rs.provider_name)::VARCHAR as integration_name,\n    (rs.failed_syncs = 0 OR rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0) < 0.1) as is_healthy,\n    rs.last_sync as last_activity,\n    COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0) as error_rate,\n    jsonb_build_object(\n        'provider', rs.provider_name,\n        'total_syncs_7d', rs.total_syncs,\n        'failed_syncs_7d', rs.failed_syncs,\n        'success_rate', ROUND((1 - COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0)) * 100, 2)\n    ) as health_details\nFROM recent_syncs rs"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_check_integration_health() - Real Estate part
 * -- Type: SELECT with CTE
 * -- Description: Check health of Real Estate provider integrations
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID (optional, uses session if null)
 * -- Returns: Health status of Real Estate integrations
 * -- ================================================================
 * 
 * -- Check Real Estate integration health with 7-day sync statistics
 * 
 * WITH recent_syncs AS (
 *     SELECT 
 *         pi.id,
 *         pi.provider_name,
 *         COUNT(*) as total_syncs,
 *         COUNT(*) FILTER (WHERE sl.sync_status = 'failed') as failed_syncs,
 *         MAX(sl.completed_at) as last_sync
 *     FROM real_estate_provider_integrations pi
 *     LEFT JOIN real_estate_sync_logs sl ON pi.id = sl.integration_id
 *         AND sl.initiated_at > (NOW() - INTERVAL '7 days')
 *     WHERE pi.tenant_id = COALESCE($1::INTEGER, current_setting('app.current_tenant_id', true)::INTEGER, 1)
 *     GROUP BY pi.id, pi.provider_name
 * )
 * SELECT 
 *     'real_estate'::VARCHAR as integration_type,
 *     ('Real Estate - ' || rs.provider_name)::VARCHAR as integration_name,
 *     (rs.failed_syncs = 0 OR rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0) < 0.1) as is_healthy,
 *     rs.last_sync as last_activity,
 *     COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0) as error_rate,
 *     jsonb_build_object(
 *         'provider', rs.provider_name,
 *         'total_syncs_7d', rs.total_syncs,
 *         'failed_syncs_7d', rs.failed_syncs,
 *         'success_rate', ROUND((1 - COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0)) * 100, 2)
 *     ) as health_details
 * FROM recent_syncs rs
 * ```
 */
export const checkHealthRealEstate = new PreparedQuery<ICheckHealthRealEstateParams,ICheckHealthRealEstateResult>(checkHealthRealEstateIR);


