/** Types generated for queries found in "apps/api/src/app/database/queries/08_audit/compliance/compliance_report_stats.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'ComplianceReportStats' parameters type */
export type IComplianceReportStatsParams = void;

/** 'ComplianceReportStats' return type */
export interface IComplianceReportStatsResult {
  data_modifications: string | null;
  end_date: Date | null;
  failed_authentications: string | null;
  framework: string | null;
  high_risk_events: string | null;
  pii_access_count: string | null;
  report_date: Date | null;
  risk_summary: Json | null;
  start_date: Date | null;
  total_events: string | null;
}

/** 'ComplianceReportStats' query type */
export interface IComplianceReportStatsQuery {
  params: IComplianceReportStatsParams;
  result: IComplianceReportStatsResult;
}

const complianceReportStatsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_generate_compliance_report() - Main stats\n-- Type: SELECT with subqueries\n-- Description: Generate compliance report with audit statistics\n-- Parameters:\n--   $1: p_start_date DATE - Start date (default last 30 days)\n--   $2: p_end_date DATE - End date (default today)\n--   $3: p_framework VARCHAR - Compliance framework (default 'SOC2')\n--   $4: p_include_pii BOOLEAN - Include PII activity (default true)\n-- Returns: Compliance report statistics\n-- ================================================================\n\n-- Generate compliance report with all statistics\n\nWITH date_range AS (\n    SELECT \n        COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,\n        COALESCE($2::DATE, CURRENT_DATE) as end_date\n),\nevent_counts AS (\n    SELECT \n        COUNT(*) as total_events,\n        COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high') as high_risk_events,\n        COUNT(*) FILTER (WHERE action IN ('create', 'update', 'delete')) as data_modifications\n    FROM audit_log, date_range\n    WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date\n),\npii_counts AS (\n    SELECT COUNT(*) as pii_access_count\n    FROM pii_access_logs, date_range\n    WHERE accessed_at::DATE BETWEEN date_range.start_date AND date_range.end_date\n),\nauth_failures AS (\n    SELECT COUNT(*) as failed_authentications\n    FROM user_login_history, date_range\n    WHERE was_successful = FALSE \n    AND attempt_timestamp::DATE BETWEEN date_range.start_date AND date_range.end_date\n),\nrisk_breakdown AS (\n    SELECT jsonb_build_object(\n        'high', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high'),\n        'medium', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'medium'),\n        'low', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'low')\n    ) as risk_summary\n    FROM audit_log, date_range\n    WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date\n)\nSELECT \n    CURRENT_DATE as report_date,\n    COALESCE($3::VARCHAR, 'SOC2') as framework,\n    dr.start_date,\n    dr.end_date,\n    ec.total_events,\n    ec.high_risk_events,\n    CASE WHEN COALESCE($4::BOOLEAN, TRUE) THEN pc.pii_access_count ELSE 0 END as pii_access_count,\n    af.failed_authentications,\n    ec.data_modifications,\n    rb.risk_summary\nFROM date_range dr\nCROSS JOIN event_counts ec\nCROSS JOIN pii_counts pc\nCROSS JOIN auth_failures af\nCROSS JOIN risk_breakdown rb"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_generate_compliance_report() - Main stats
 * -- Type: SELECT with subqueries
 * -- Description: Generate compliance report with audit statistics
 * -- Parameters:
 * --   $1: p_start_date DATE - Start date (default last 30 days)
 * --   $2: p_end_date DATE - End date (default today)
 * --   $3: p_framework VARCHAR - Compliance framework (default 'SOC2')
 * --   $4: p_include_pii BOOLEAN - Include PII activity (default true)
 * -- Returns: Compliance report statistics
 * -- ================================================================
 * 
 * -- Generate compliance report with all statistics
 * 
 * WITH date_range AS (
 *     SELECT 
 *         COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,
 *         COALESCE($2::DATE, CURRENT_DATE) as end_date
 * ),
 * event_counts AS (
 *     SELECT 
 *         COUNT(*) as total_events,
 *         COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high') as high_risk_events,
 *         COUNT(*) FILTER (WHERE action IN ('create', 'update', 'delete')) as data_modifications
 *     FROM audit_log, date_range
 *     WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date
 * ),
 * pii_counts AS (
 *     SELECT COUNT(*) as pii_access_count
 *     FROM pii_access_logs, date_range
 *     WHERE accessed_at::DATE BETWEEN date_range.start_date AND date_range.end_date
 * ),
 * auth_failures AS (
 *     SELECT COUNT(*) as failed_authentications
 *     FROM user_login_history, date_range
 *     WHERE was_successful = FALSE 
 *     AND attempt_timestamp::DATE BETWEEN date_range.start_date AND date_range.end_date
 * ),
 * risk_breakdown AS (
 *     SELECT jsonb_build_object(
 *         'high', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high'),
 *         'medium', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'medium'),
 *         'low', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'low')
 *     ) as risk_summary
 *     FROM audit_log, date_range
 *     WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date
 * )
 * SELECT 
 *     CURRENT_DATE as report_date,
 *     COALESCE($3::VARCHAR, 'SOC2') as framework,
 *     dr.start_date,
 *     dr.end_date,
 *     ec.total_events,
 *     ec.high_risk_events,
 *     CASE WHEN COALESCE($4::BOOLEAN, TRUE) THEN pc.pii_access_count ELSE 0 END as pii_access_count,
 *     af.failed_authentications,
 *     ec.data_modifications,
 *     rb.risk_summary
 * FROM date_range dr
 * CROSS JOIN event_counts ec
 * CROSS JOIN pii_counts pc
 * CROSS JOIN auth_failures af
 * CROSS JOIN risk_breakdown rb
 * ```
 */
export const complianceReportStats = new PreparedQuery<IComplianceReportStatsParams,IComplianceReportStatsResult>(complianceReportStatsIR);


