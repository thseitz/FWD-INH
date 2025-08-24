/* @name getAuditTrail */
-- ================================================================
-- Converted from: sp_get_audit_trail()
-- Type: Simple Read-Only Query with Filters
-- Description: Retrieve audit log entries with optional filters
-- Parameters:
--   $1: p_entity_type VARCHAR(50) - Optional filter by entity type
--   $2: p_entity_id UUID - Optional filter by entity ID
--   $3: p_user_id UUID - Optional filter by user ID
--   $4: p_action VARCHAR(50) - Optional filter by action
--   $5: p_start_date TIMESTAMPTZ - Optional start date filter
--   $6: p_end_date TIMESTAMPTZ - Optional end date filter
--   $7: p_limit INTEGER - Maximum records to return (default 100)
--   $8: p_offset INTEGER - Pagination offset (default 0)
-- Returns: Audit trail records
-- ================================================================

-- This query retrieves audit log entries with optional filtering
-- All parameters are optional for flexible querying

SELECT 
    al.id as audit_id,
    al.created_at,
    u.first_name || ' ' || u.last_name as user_name,
    al.action::VARCHAR,
    al.entity_type::VARCHAR,
    al.entity_name,
    jsonb_build_object(
        'old_values', al.old_values,
        'new_values', al.new_values
    ) as changes,
    al.metadata
FROM audit_log al
LEFT JOIN users u ON al.user_id = u.id
WHERE 
    ($1::VARCHAR IS NULL OR al.entity_type::TEXT = $1)
    AND ($2::UUID IS NULL OR al.entity_id = $2)
    AND ($3::UUID IS NULL OR al.user_id = $3)
    AND ($4::VARCHAR IS NULL OR al.action::TEXT = $4)
    AND ($5::TIMESTAMPTZ IS NULL OR al.created_at >= $5)
    AND ($6::TIMESTAMPTZ IS NULL OR al.created_at <= $6)
ORDER BY al.created_at DESC
LIMIT COALESCE($7::INTEGER, 100)
OFFSET COALESCE($8::INTEGER, 0);