-- ================================================================
-- Supporting query for: sp_detect_pii()
-- Type: INSERT
-- Description: Create PII processing job
-- Parameters:
--   $1: p_context TEXT - Context for detection (default 'general')
--   $2: p_user_id UUID - User requesting detection (optional)
-- Returns: PII processing job record
-- ================================================================

-- Create a new PII detection job

INSERT INTO pii_processing_jobs (
    tenant_id,
    job_type,
    status,
    records_processed,
    processing_options,
    created_at
) VALUES (
    COALESCE(
        CASE 
            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_tenant_id', true)::INTEGER
        END,
        1
    ),
    'detection',
    'running',
    0,
    jsonb_build_object(
        'context', COALESCE($1::TEXT, 'general'),
        'user_id', COALESCE(
            $2::UUID,
            CASE 
                WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
                THEN NULL
                ELSE current_setting('app.current_user_id', true)::UUID
            END
        )
    ),
    NOW()
)
RETURNING 
    id,
    job_type,
    status,
    processing_options;