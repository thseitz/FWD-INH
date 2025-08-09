# 09 - Security & Compliance Stored Procedures

## Table of Contents
1. [Overview](#overview)
2. [Session Management Procedures](#session-management-procedures)
3. [Audit & Compliance Procedures](#audit--compliance-procedures)
4. [PII Processing Procedures](#pii-processing-procedures)
5. [System Configuration Procedures](#system-configuration-procedures)
6. [Row-Level Security Setup](#row-level-security-setup)
7. [Helper Functions](#helper-functions)

## Overview

The Forward Inheritance Platform implements **8 security and compliance procedures** that handle audit logging, PII detection, compliance reporting, and session management. Authentication is handled by AWS Cognito, with the database maintaining session context and audit trails.

### Security Procedure Categories
- **Session Management**: 2 procedures for RLS session context
- **Audit & Compliance**: 3 procedures for logging and compliance reporting
- **PII Processing**: 2 procedures for privacy compliance
- **System Configuration**: 1 procedure for system settings management

### Key Security Features
- **AWS Cognito Integration**: Authentication handled externally by AWS Cognito
- **Row-Level Security**: Database-level tenant and user isolation
- **Audit Logging**: Complete action tracking for compliance
- **PII Detection**: Automated PII detection and masking capabilities
- **Compliance Reporting**: SOC 2 and regulatory compliance support

## Session Management Procedures

### sp_set_session_context
Sets the current session context for Row-Level Security enforcement.

```sql
CREATE OR REPLACE FUNCTION sp_set_session_context(
    p_user_id UUID,
    p_tenant_id INTEGER
) RETURNS VOID AS $$
BEGIN
    -- Set session variables for RLS
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, false);
    PERFORM set_config('app.current_tenant_id', p_tenant_id::TEXT, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Usage:**
- Called after AWS Cognito authentication succeeds
- Sets database session context for the authenticated user
- Enables Row-Level Security policies to filter data

### sp_clear_session_context
Clears the session context when user logs out or session expires.

```sql
CREATE OR REPLACE FUNCTION sp_clear_session_context() 
RETURNS VOID AS $$
BEGIN
    -- Clear session variables
    PERFORM set_config('app.current_user_id', NULL, false);
    PERFORM set_config('app.current_tenant_id', NULL, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Audit & Compliance Procedures

### sp_log_audit_event
Central audit logging procedure for all system actions.

```sql
CREATE OR REPLACE FUNCTION sp_log_audit_event(
    p_action audit_action_enum,
    p_entity_type audit_entity_type_enum,
    p_entity_id UUID DEFAULT NULL,
    p_entity_name TEXT DEFAULT NULL,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_audit_id UUID;
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_persona_id UUID;
BEGIN
    -- Get current session context
    v_user_id := current_user_id();
    v_tenant_id := current_tenant_id();
    v_persona_id := current_persona_id();
    
    -- Insert audit record
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        persona_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        old_values,
        new_values,
        metadata,
        ip_address,
        user_agent,
        created_at
    ) VALUES (
        v_tenant_id,
        v_user_id,
        v_persona_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_entity_name,
        p_old_values,
        p_new_values,
        p_metadata,
        inet_client_addr(),
        current_setting('application_name', true),
        (NOW() AT TIME ZONE 'UTC')
    ) RETURNING id INTO v_audit_id;
    
    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Features:**
- Automatic capture of session context
- Support for before/after values
- Flexible metadata storage
- IP address and user agent tracking

### sp_create_audit_event
Creates business-level audit events for weekly reporting.

```sql
CREATE OR REPLACE FUNCTION sp_create_audit_event(
    p_event_type TEXT,
    p_event_category VARCHAR(50),
    p_severity VARCHAR(20),
    p_description TEXT,
    p_details JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_event_id UUID;
    v_user_id UUID;
    v_tenant_id INTEGER;
BEGIN
    v_user_id := current_user_id();
    v_tenant_id := current_tenant_id();
    
    INSERT INTO audit_events (
        tenant_id,
        event_type,
        event_category,
        severity,
        description,
        details,
        user_id,
        occurred_at
    ) VALUES (
        v_tenant_id,
        p_event_type,
        p_event_category,
        p_severity,
        p_description,
        p_details,
        v_user_id,
        (NOW() AT TIME ZONE 'UTC')
    ) RETURNING id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_generate_compliance_report
Generates compliance reports for regulatory requirements.

```sql
CREATE OR REPLACE FUNCTION sp_generate_compliance_report(
    p_report_type VARCHAR(100),
    p_start_date DATE,
    p_end_date DATE,
    p_include_pii BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    report_id UUID,
    report_data JSONB,
    generated_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    v_tenant_id INTEGER;
    v_report_data JSONB;
    v_report_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_report_id := gen_random_uuid();
    
    -- Generate report based on type
    CASE p_report_type
        WHEN 'weekly_activity' THEN
            -- Weekly activity summary
            SELECT jsonb_build_object(
                'period', jsonb_build_object(
                    'start', p_start_date,
                    'end', p_end_date
                ),
                'summary', jsonb_build_object(
                    'total_logins', (
                        SELECT COUNT(*) FROM user_login_history
                        WHERE tenant_id = v_tenant_id
                        AND attempt_timestamp BETWEEN p_start_date AND p_end_date
                        AND was_successful = TRUE
                    ),
                    'unique_users', (
                        SELECT COUNT(DISTINCT user_id) FROM audit_log
                        WHERE tenant_id = v_tenant_id
                        AND created_at BETWEEN p_start_date AND p_end_date
                    ),
                    'asset_changes', (
                        SELECT COUNT(*) FROM audit_log
                        WHERE tenant_id = v_tenant_id
                        AND entity_type = 'asset'
                        AND created_at BETWEEN p_start_date AND p_end_date
                    ),
                    'new_personas', (
                        SELECT COUNT(*) FROM personas
                        WHERE tenant_id = v_tenant_id
                        AND created_at BETWEEN p_start_date AND p_end_date
                    )
                ),
                'events', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'event_type', event_type,
                            'count', event_count
                        )
                    )
                    FROM (
                        SELECT event_type, COUNT(*) as event_count
                        FROM audit_events
                        WHERE tenant_id = v_tenant_id
                        AND occurred_at BETWEEN p_start_date AND p_end_date
                        GROUP BY event_type
                    ) events
                )
            ) INTO v_report_data;
            
        WHEN 'soc2_compliance' THEN
            -- SOC 2 compliance report
            SELECT jsonb_build_object(
                'period', jsonb_build_object(
                    'start', p_start_date,
                    'end', p_end_date
                ),
                'access_controls', jsonb_build_object(
                    'failed_login_attempts', (
                        SELECT COUNT(*) FROM user_login_history
                        WHERE tenant_id = v_tenant_id
                        AND attempt_timestamp BETWEEN p_start_date AND p_end_date
                        AND was_successful = FALSE
                    ),
                    'permission_changes', (
                        SELECT COUNT(*) FROM audit_log
                        WHERE tenant_id = v_tenant_id
                        AND entity_type = 'role'
                        AND created_at BETWEEN p_start_date AND p_end_date
                    )
                ),
                'data_protection', jsonb_build_object(
                    'pii_scans', (
                        SELECT COUNT(*) FROM pii_processing_jobs
                        WHERE tenant_id = v_tenant_id
                        AND created_at BETWEEN p_start_date AND p_end_date
                    ),
                    'pii_detected', (
                        SELECT SUM(pii_found_count) FROM pii_processing_jobs
                        WHERE tenant_id = v_tenant_id
                        AND created_at BETWEEN p_start_date AND p_end_date
                    )
                ),
                'audit_trail', jsonb_build_object(
                    'total_events', (
                        SELECT COUNT(*) FROM audit_log
                        WHERE tenant_id = v_tenant_id
                        AND created_at BETWEEN p_start_date AND p_end_date
                    )
                )
            ) INTO v_report_data;
            
        ELSE
            RAISE EXCEPTION 'Unknown report type: %', p_report_type;
    END CASE;
    
    -- Store report
    INSERT INTO audit_events (
        tenant_id,
        event_type,
        event_category,
        severity,
        description,
        details,
        occurred_at
    ) VALUES (
        v_tenant_id,
        'compliance_report_generated',
        'compliance',
        'info',
        format('Generated %s report for %s to %s', p_report_type, p_start_date, p_end_date),
        jsonb_build_object(
            'report_id', v_report_id,
            'report_type', p_report_type,
            'report_data', v_report_data
        ),
        (NOW() AT TIME ZONE 'UTC')
    );
    
    RETURN QUERY
    SELECT v_report_id, v_report_data, (NOW() AT TIME ZONE 'UTC');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_audit_trail
Retrieves audit trail for specific entities or date ranges.

```sql
CREATE OR REPLACE FUNCTION sp_get_audit_trail(
    p_entity_type audit_entity_type_enum DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    audit_id UUID,
    action audit_action_enum,
    entity_type audit_entity_type_enum,
    entity_name TEXT,
    user_email VARCHAR(255),
    occurred_at TIMESTAMP WITH TIME ZONE,
    change_summary TEXT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id,
        al.action,
        al.entity_type,
        al.entity_name,
        u.email,
        al.created_at,
        al.change_summary,
        al.metadata
    FROM audit_log al
    LEFT JOIN users u ON al.user_id = u.id
    WHERE al.tenant_id = current_tenant_id()
    AND (p_entity_type IS NULL OR al.entity_type = p_entity_type)
    AND (p_entity_id IS NULL OR al.entity_id = p_entity_id)
    AND (p_start_date IS NULL OR al.created_at >= p_start_date)
    AND (p_end_date IS NULL OR al.created_at <= p_end_date)
    ORDER BY al.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## PII Processing Procedures

### sp_detect_pii
Detects and masks PII in text data.

```sql
CREATE OR REPLACE FUNCTION sp_detect_pii(
    p_text TEXT,
    p_context VARCHAR(100) DEFAULT 'general',
    p_user_id UUID DEFAULT NULL
) RETURNS TABLE (
    detected BOOLEAN,
    pii_types JSONB,
    confidence_score DECIMAL,
    masked_text TEXT,
    detection_details JSONB
) AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_job_id UUID;
    v_detected_pii JSONB;
    v_masked TEXT;
    v_confidence DECIMAL;
BEGIN
    -- Get user_id and tenant
    v_user_id := COALESCE(p_user_id, current_user_id());
    v_tenant_id := current_tenant_id();
    
    -- Create PII processing job
    INSERT INTO pii_processing_jobs (
        tenant_id,
        job_type,
        status,
        target_table,
        created_at,
        scheduled_by
    ) VALUES (
        v_tenant_id,
        'scan',
        'running',
        'text_input',
        (NOW() AT TIME ZONE 'UTC'),
        v_user_id
    ) RETURNING id INTO v_job_id;
    
    -- Initialize detection results
    v_detected_pii := '[]'::jsonb;
    v_masked := p_text;
    v_confidence := 0;
    
    -- Check against PII detection rules
    WITH rule_checks AS (
        SELECT 
            pdr.rule_name,
            pdr.pii_type,
            pdr.detection_pattern,
            pdr.confidence_threshold,
            CASE 
                WHEN pdr.pattern_type = 'regex' THEN 
                    p_text ~ pdr.detection_pattern
                WHEN pdr.pattern_type = 'keyword' THEN 
                    p_text ILIKE '%' || pdr.detection_pattern || '%'
                ELSE FALSE
            END as matched
        FROM pii_detection_rules pdr
        WHERE pdr.is_active = TRUE
    ),
    detections AS (
        SELECT 
            jsonb_agg(
                jsonb_build_object(
                    'type', pii_type,
                    'rule', rule_name,
                    'confidence', confidence_threshold
                )
            ) as pii_found,
            MAX(confidence_threshold) as max_confidence
        FROM rule_checks
        WHERE matched = TRUE
    )
    SELECT 
        COALESCE(pii_found, '[]'::jsonb),
        COALESCE(max_confidence, 0)
    INTO v_detected_pii, v_confidence
    FROM detections;
    
    -- Apply masking if PII detected
    IF jsonb_array_length(v_detected_pii) > 0 THEN
        -- Simple masking patterns
        v_masked := regexp_replace(p_text, '\d{3}-\d{2}-\d{4}', 'XXX-XX-XXXX', 'g'); -- SSN
        v_masked := regexp_replace(v_masked, '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}', 'XXXX-XXXX-XXXX-XXXX', 'g'); -- Credit card
        v_masked := regexp_replace(v_masked, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}', 'XXXXX@XXXXX.XXX', 'g'); -- Email
        v_masked := regexp_replace(v_masked, '\+?1?[\s.-]?\(?[0-9]{3}\)?[\s.-]?[0-9]{3}[\s.-]?[0-9]{4}', 'XXX-XXX-XXXX', 'g'); -- Phone
        
        -- Log PII access
        INSERT INTO pii_access_logs (
            tenant_id,
            user_id,
            accessed_at,
            table_name,
            column_names,
            pii_types,
            access_method,
            document_id,
            session_id
        ) VALUES (
            v_tenant_id,
            v_user_id,
            (NOW() AT TIME ZONE 'UTC'),
            'text_scan',
            ARRAY['input_text'],
            ARRAY(SELECT jsonb_array_elements_text(v_detected_pii -> 'type')),
            'detection',
            v_job_id,
            NULL
        );
    END IF;
    
    -- Update job status
    UPDATE pii_processing_jobs SET
        status = 'completed',
        completed_at = (NOW() AT TIME ZONE 'UTC'),
        records_processed = 1,
        pii_found_count = jsonb_array_length(v_detected_pii),
        processing_options = jsonb_build_object(
            'detected_types', v_detected_pii,
            'confidence', v_confidence,
            'context', p_context
        )
    WHERE id = v_job_id;
    
    RETURN QUERY
    SELECT 
        jsonb_array_length(v_detected_pii) > 0,
        v_detected_pii,
        v_confidence,
        v_masked,
        jsonb_build_object(
            'job_id', v_job_id,
            'timestamp', (NOW() AT TIME ZONE 'UTC'),
            'rules_checked', (SELECT COUNT(*) FROM pii_detection_rules WHERE is_active = TRUE)
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Features:**
- Pattern-based PII detection (SSN, credit cards, emails, phones)
- Automatic masking of detected PII
- Confidence scoring based on detection rules
- Complete audit trail of PII access

### sp_update_pii_job_status
Updates the status of PII processing jobs.

```sql
CREATE OR REPLACE FUNCTION sp_update_pii_job_status(
    p_job_id UUID,
    p_status VARCHAR(20),
    p_processed_records INTEGER DEFAULT NULL,
    p_pii_found_count INTEGER DEFAULT NULL,
    p_error_message TEXT DEFAULT NULL,
    p_results JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE pii_processing_jobs SET
        status = p_status,
        records_processed = COALESCE(p_processed_records, records_processed),
        pii_found_count = COALESCE(p_pii_found_count, pii_found_count),
        errors_count = CASE WHEN p_error_message IS NOT NULL THEN errors_count + 1 ELSE errors_count END,
        error_details = CASE 
            WHEN p_error_message IS NOT NULL 
            THEN error_details || jsonb_build_array(jsonb_build_object(
                'timestamp', (NOW() AT TIME ZONE 'UTC'),
                'message', p_error_message
            ))
            ELSE error_details
        END,
        processing_options = COALESCE(p_results, processing_options),
        completed_at = CASE 
            WHEN p_status IN ('completed', 'failed') THEN (NOW() AT TIME ZONE 'UTC')
            ELSE completed_at
        END
    WHERE id = p_job_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## System Configuration Procedures

### sp_update_system_configuration
Updates system-wide configuration settings.

```sql
CREATE OR REPLACE FUNCTION sp_update_system_configuration(
    p_key VARCHAR(255),
    p_value TEXT,
    p_description TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_old_value TEXT;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Get old value for audit
    SELECT value INTO v_old_value
    FROM system_configurations
    WHERE tenant_id = v_tenant_id
    AND key = p_key;
    
    -- Upsert configuration
    INSERT INTO system_configurations (
        tenant_id,
        key,
        value,
        description,
        updated_at,
        updated_by
    ) VALUES (
        v_tenant_id,
        p_key,
        p_value,
        p_description,
        (NOW() AT TIME ZONE 'UTC'),
        current_user_id()
    )
    ON CONFLICT (tenant_id, key) DO UPDATE SET
        value = EXCLUDED.value,
        description = COALESCE(EXCLUDED.description, system_configurations.description),
        updated_at = EXCLUDED.updated_at,
        updated_by = EXCLUDED.updated_by;
    
    -- Audit log
    PERFORM sp_log_audit_event(
        'update'::audit_action_enum,
        'configuration'::audit_entity_type_enum,
        NULL,
        p_key,
        jsonb_build_object('value', v_old_value),
        jsonb_build_object('value', p_value),
        jsonb_build_object('description', p_description)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Row-Level Security Setup

### RLS Policies
The platform implements comprehensive Row-Level Security policies:

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Tenant isolation policy
CREATE POLICY tenant_isolation ON users
    FOR ALL
    USING (tenant_id = current_tenant_id());

-- User data access policy
CREATE POLICY user_data_access ON personas
    FOR SELECT
    USING (
        user_id = current_user_id() 
        OR EXISTS (
            SELECT 1 FROM ffc_members fm
            WHERE fm.persona_id = personas.id
            AND fm.ffc_id IN (
                SELECT ffc_id FROM ffc_members
                WHERE persona_id IN (
                    SELECT id FROM personas WHERE user_id = current_user_id()
                )
            )
        )
    );

-- Asset visibility policy
CREATE POLICY asset_visibility ON assets
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM asset_persona ap
            JOIN personas p ON ap.persona_id = p.id
            WHERE ap.asset_id = assets.id
            AND p.user_id = current_user_id()
        )
        OR EXISTS (
            SELECT 1 FROM asset_permissions ap
            WHERE ap.asset_id = assets.id
            AND ap.persona_id IN (
                SELECT id FROM personas WHERE user_id = current_user_id()
            )
        )
    );
```

## Helper Functions

### current_user_id
Returns the current user ID from session context.

```sql
CREATE OR REPLACE FUNCTION current_user_id() 
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_user_id', true), '')::UUID;
END;
$$ LANGUAGE plpgsql STABLE;
```

### current_tenant_id
Returns the current tenant ID from session context.

```sql
CREATE OR REPLACE FUNCTION current_tenant_id() 
RETURNS INTEGER AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant_id', true), '')::INTEGER;
END;
$$ LANGUAGE plpgsql STABLE;
```

### current_persona_id
Returns the current persona ID from session context.

```sql
CREATE OR REPLACE FUNCTION current_persona_id() 
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_persona_id', true), '')::UUID;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

*This security and compliance procedure documentation reflects the Forward Inheritance Platform's integration with AWS Cognito for authentication while maintaining comprehensive audit logging, PII protection, and regulatory compliance capabilities within the database layer.*