/** Types generated for queries found in "apps/api/src/app/database/queries/08_audit/compliance/compliance_report_user_activity.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ComplianceReportUserActivity' parameters type */
export type IComplianceReportUserActivityParams = void;

/** 'ComplianceReportUserActivity' return type */
export interface IComplianceReportUserActivityResult {
  email: string;
  event_count: string | null;
  first_activity: Date | null;
  high_risk_events: string | null;
  last_activity: Date | null;
  modifications: string | null;
  user_id: string;
  user_name: string | null;
}

/** 'ComplianceReportUserActivity' query type */
export interface IComplianceReportUserActivityQuery {
  params: IComplianceReportUserActivityParams;
  result: IComplianceReportUserActivityResult;
}

const complianceReportUserActivityIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_generate_compliance_report() - User activity\n-- Type: SELECT with aggregation\n-- Description: Get user activity for compliance report\n-- Parameters:\n--   $1: p_start_date DATE - Start date (default last 30 days)\n--   $2: p_end_date DATE - End date (default today)\n-- Returns: User activity summary\n-- ================================================================\n\n-- Get user activity summary for compliance report\n\nWITH date_range AS (\n    SELECT \n        COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,\n        COALESCE($2::DATE, CURRENT_DATE) as end_date\n)\nSELECT \n    u.id as user_id,\n    u.first_name || ' ' || u.last_name as user_name,\n    e.email_address as email,\n    COUNT(al.id) as event_count,\n    COUNT(*) FILTER (WHERE al.metadata->>'risk_level' = 'high') as high_risk_events,\n    COUNT(*) FILTER (WHERE al.action IN ('create', 'update', 'delete')) as modifications,\n    MIN(al.created_at) as first_activity,\n    MAX(al.created_at) as last_activity\nFROM users u\nLEFT JOIN email_address e ON e.id = u.primary_email_id\nJOIN audit_log al ON al.user_id = u.id\nCROSS JOIN date_range dr\nWHERE al.created_at::DATE BETWEEN dr.start_date AND dr.end_date\nGROUP BY u.id, u.first_name, u.last_name, e.email_address\nORDER BY event_count DESC"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_generate_compliance_report() - User activity
 * -- Type: SELECT with aggregation
 * -- Description: Get user activity for compliance report
 * -- Parameters:
 * --   $1: p_start_date DATE - Start date (default last 30 days)
 * --   $2: p_end_date DATE - End date (default today)
 * -- Returns: User activity summary
 * -- ================================================================
 * 
 * -- Get user activity summary for compliance report
 * 
 * WITH date_range AS (
 *     SELECT 
 *         COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,
 *         COALESCE($2::DATE, CURRENT_DATE) as end_date
 * )
 * SELECT 
 *     u.id as user_id,
 *     u.first_name || ' ' || u.last_name as user_name,
 *     e.email_address as email,
 *     COUNT(al.id) as event_count,
 *     COUNT(*) FILTER (WHERE al.metadata->>'risk_level' = 'high') as high_risk_events,
 *     COUNT(*) FILTER (WHERE al.action IN ('create', 'update', 'delete')) as modifications,
 *     MIN(al.created_at) as first_activity,
 *     MAX(al.created_at) as last_activity
 * FROM users u
 * LEFT JOIN email_address e ON e.id = u.primary_email_id
 * JOIN audit_log al ON al.user_id = u.id
 * CROSS JOIN date_range dr
 * WHERE al.created_at::DATE BETWEEN dr.start_date AND dr.end_date
 * GROUP BY u.id, u.first_name, u.last_name, e.email_address
 * ORDER BY event_count DESC
 * ```
 */
export const complianceReportUserActivity = new PreparedQuery<IComplianceReportUserActivityParams,IComplianceReportUserActivityResult>(complianceReportUserActivityIR);


