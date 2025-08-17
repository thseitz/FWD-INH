-- ================================================================
-- Converted from: sp_detect_pii() - Pattern Detection
-- Type: SELECT with pattern matching
-- Description: Detect PII patterns in text
-- Parameters:
--   $1: p_text TEXT - Text to analyze
-- Returns: Detection results
-- NOTE: This query performs pattern matching for common PII types
-- ================================================================

-- Detect PII patterns and return results
-- Service layer should use these results to update the job

WITH pii_detection AS (
    SELECT 
        $1::TEXT as original_text,
        -- SSN Detection
        CASE 
            WHEN $1::TEXT ~* '\d{3}-\d{2}-\d{4}' OR $1::TEXT ~* '\d{9}' 
            THEN TRUE 
            ELSE FALSE 
        END as has_ssn,
        -- Email Detection
        CASE 
            WHEN $1::TEXT ~* '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 
            THEN TRUE 
            ELSE FALSE 
        END as has_email,
        -- Phone Detection
        CASE 
            WHEN $1::TEXT ~* '\+?1?\s*\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}' 
            THEN TRUE 
            ELSE FALSE 
        END as has_phone,
        -- Credit Card Detection
        CASE 
            WHEN $1::TEXT ~* '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}' 
            THEN TRUE 
            ELSE FALSE 
        END as has_credit_card
)
SELECT 
    (has_ssn OR has_email OR has_phone OR has_credit_card) as detected,
    jsonb_build_array(
        CASE WHEN has_ssn THEN jsonb_build_object('type', 'SSN', 'confidence', 0.95) END,
        CASE WHEN has_email THEN jsonb_build_object('type', 'Email', 'confidence', 0.98) END,
        CASE WHEN has_phone THEN jsonb_build_object('type', 'Phone', 'confidence', 0.85) END,
        CASE WHEN has_credit_card THEN jsonb_build_object('type', 'Credit Card', 'confidence', 0.90) END
    ) - NULL as pii_types,
    GREATEST(
        CASE WHEN has_ssn THEN 0.95 ELSE 0 END,
        CASE WHEN has_email THEN 0.98 ELSE 0 END,
        CASE WHEN has_phone THEN 0.85 ELSE 0 END,
        CASE WHEN has_credit_card THEN 0.90 ELSE 0 END
    )::DECIMAL as confidence_score,
    -- Mask the text
    regexp_replace(
        regexp_replace(
            regexp_replace(
                regexp_replace(
                    regexp_replace(
                        original_text,
                        '\d{3}-\d{2}-\d{4}', 'XXX-XX-XXXX', 'g'
                    ),
                    '\d{9}', 'XXXXXXXXX', 'g'
                ),
                '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[EMAIL]', 'g'
            ),
            '\+?1?\s*\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', '[PHONE]', 'g'
        ),
        '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}', '[CREDIT_CARD]', 'g'
    ) as masked_text,
    jsonb_build_object(
        'patterns_checked', jsonb_build_array('SSN', 'Email', 'Phone', 'Credit Card'),
        'text_length', length(original_text)
    ) as detection_details
FROM pii_detection;