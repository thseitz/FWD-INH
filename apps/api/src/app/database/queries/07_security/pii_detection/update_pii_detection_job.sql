/* @name updatePiiDetectionJob */
-- ================================================================
-- Supporting query for: sp_detect_pii()
-- Type: UPDATE
-- Description: Update PII job with detection results
-- Parameters:
--   $1: p_job_id UUID - Job ID to update
--   $2: p_pii_found BOOLEAN - Whether PII was found
--   $3: p_pii_types JSONB - Types of PII detected
--   $4: p_confidence DECIMAL - Confidence score
--   $5: p_masked_text TEXT - Masked version of text
-- Returns: Updated job record
-- ================================================================

-- Update the PII detection job with results

UPDATE pii_processing_jobs
SET 
    status = 'completed',
    completed_at = NOW(),
    records_processed = 1,
    pii_found_count = CASE 
        WHEN $2::BOOLEAN AND jsonb_typeof($3::JSONB) = 'array' THEN jsonb_array_length($3::JSONB) 
        ELSE 0 
    END,
    processing_options = processing_options || jsonb_build_object(
        'detected_types', $3::JSONB,
        'confidence', $4::DECIMAL,
        'masked_text', $5::TEXT,
        'pii_found', $2::BOOLEAN
    )
WHERE id = $1::UUID
RETURNING 
    id,
    status,
    pii_found_count,
    processing_options,
    completed_at;