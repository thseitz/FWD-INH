/* @name complianceReportUserActivity */
-- ================================================================
-- Converted from: sp_generate_compliance_report() - User activity
-- Type: SELECT with aggregation
-- Description: Get user activity for compliance report
-- Parameters:
--   $1: p_start_date DATE - Start date (default last 30 days)
--   $2: p_end_date DATE - End date (default today)
-- Returns: User activity summary
-- ================================================================

-- Get user activity summary for compliance report

WITH date_range AS (
    SELECT 
        COALESCE($1::DATE, CURRENT_DATE - INTERVAL '30 days')::DATE as start_date,
        COALESCE($2::DATE, CURRENT_DATE) as end_date
)
SELECT 
    u.id as user_id,
    u.first_name || ' ' || u.last_name as user_name,
    e.email_address as email,
    COUNT(al.id) as event_count,
    COUNT(*) FILTER (WHERE al.metadata->>'risk_level' = 'high') as high_risk_events,
    COUNT(*) FILTER (WHERE al.action IN ('create', 'update', 'delete')) as modifications,
    MIN(al.created_at) as first_activity,
    MAX(al.created_at) as last_activity
FROM users u
LEFT JOIN email_address e ON e.id = u.primary_email_id
JOIN audit_log al ON al.user_id = u.id
CROSS JOIN date_range dr
WHERE al.created_at::DATE BETWEEN dr.start_date AND dr.end_date
GROUP BY u.id, u.first_name, u.last_name, e.email_address
ORDER BY event_count DESC;