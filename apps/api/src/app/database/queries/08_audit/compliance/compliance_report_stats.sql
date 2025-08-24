/* @name complianceReportStats */
-- ================================================================
-- Converted from: sp_generate_compliance_report() - Main stats
-- Type: SELECT with subqueries
-- Description: Generate compliance report with audit statistics
-- Parameters:
--   $1: p_start_date DATE - Start date (default last 30 days)
--   $2: p_end_date DATE - End date (default today)
--   $3: p_framework VARCHAR - Compliance framework (default 'SOC2')
--   $4: p_include_pii BOOLEAN - Include PII activity (default true)
-- Returns: Compliance report statistics
-- ================================================================

-- Generate compliance report with all statistics

WITH date_range AS (
    SELECT 
        COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,
        COALESCE($2::DATE, CURRENT_DATE) as end_date
),
event_counts AS (
    SELECT 
        COUNT(*) as total_events,
        COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high') as high_risk_events,
        COUNT(*) FILTER (WHERE action IN ('create', 'update', 'delete')) as data_modifications
    FROM audit_log, date_range
    WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date
),
pii_counts AS (
    SELECT COUNT(*) as pii_access_count
    FROM pii_access_logs, date_range
    WHERE accessed_at::DATE BETWEEN date_range.start_date AND date_range.end_date
),
auth_failures AS (
    SELECT COUNT(*) as failed_authentications
    FROM user_login_history, date_range
    WHERE was_successful = FALSE 
    AND attempt_timestamp::DATE BETWEEN date_range.start_date AND date_range.end_date
),
risk_breakdown AS (
    SELECT jsonb_build_object(
        'high', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'high'),
        'medium', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'medium'),
        'low', COUNT(*) FILTER (WHERE metadata->>'risk_level' = 'low')
    ) as risk_summary
    FROM audit_log, date_range
    WHERE created_at::DATE BETWEEN date_range.start_date AND date_range.end_date
)
SELECT 
    CURRENT_DATE as report_date,
    COALESCE($3::VARCHAR, 'SOC2') as framework,
    dr.start_date,
    dr.end_date,
    ec.total_events,
    ec.high_risk_events,
    CASE WHEN COALESCE($4::BOOLEAN, TRUE) THEN pc.pii_access_count ELSE 0 END as pii_access_count,
    af.failed_authentications,
    ec.data_modifications,
    rb.risk_summary
FROM date_range dr
CROSS JOIN event_counts ec
CROSS JOIN pii_counts pc
CROSS JOIN auth_failures af
CROSS JOIN risk_breakdown rb;