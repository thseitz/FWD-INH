-- ================================================================
-- Converted from: sp_create_audit_event()
-- Type: Single INSERT with CASE logic
-- Description: Create an audit event record
-- Parameters:
--   $1: p_event_type TEXT - Type of event
--   $2: p_event_category VARCHAR(50) - Event category
--   $3: p_description TEXT - Event description
--   $4: p_risk_level VARCHAR(20) - Risk level (default 'low')
--   $5: p_compliance_framework VARCHAR(50) - Compliance framework (default 'SOC2')
--   $6: p_metadata JSONB - Additional metadata (default '{}')
--   $7: p_user_id UUID - User ID (optional)
-- Returns: Created audit event record
-- ================================================================

-- This query creates an audit event with risk level mapping
-- Includes CASE logic for severity mapping

INSERT INTO audit_events (
    tenant_id,
    event_type,
    event_category,
    severity,
    description,
    details,
    source_system,
    source_ip,
    user_id,
    session_id,
    occurred_at,
    detected_at
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    $1::TEXT,
    $2::VARCHAR(50),
    CASE COALESCE($4::VARCHAR(20), 'low')
        WHEN 'critical' THEN 'critical'
        WHEN 'high' THEN 'error'
        WHEN 'medium' THEN 'warning'
        WHEN 'low' THEN 'info'
        ELSE 'info'
    END,
    $3::TEXT,
    COALESCE($6::JSONB, '{}'::JSONB) || jsonb_build_object(
        'risk_level', COALESCE($4::VARCHAR(20), 'low'),
        'compliance_framework', COALESCE($5::VARCHAR(50), 'SOC2')
    ),
    COALESCE(($6::JSONB)->>'source_system', 'application'),
    COALESCE((($6::JSONB)->>'source_ip')::inet, inet_client_addr()),
    COALESCE(
        $7::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    CASE 
        WHEN current_setting('app.session_id', true) IS NOT NULL 
        THEN current_setting('app.session_id', true)::UUID 
        ELSE NULL 
    END,
    NOW(),
    NOW()
)
RETURNING 
    id,
    event_type,
    event_category,
    severity,
    description,
    occurred_at;