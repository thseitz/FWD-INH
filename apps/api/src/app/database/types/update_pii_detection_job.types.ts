/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/pii_detection/update_pii_detection_job.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'UpdatePiiDetectionJob' parameters type */
export type IUpdatePiiDetectionJobParams = void;

/** 'UpdatePiiDetectionJob' return type */
export interface IUpdatePiiDetectionJobResult {
  completed_at: Date | null;
  id: string;
  pii_found_count: number | null;
  processing_options: Json | null;
  status: string;
}

/** 'UpdatePiiDetectionJob' query type */
export interface IUpdatePiiDetectionJobQuery {
  params: IUpdatePiiDetectionJobParams;
  result: IUpdatePiiDetectionJobResult;
}

const updatePiiDetectionJobIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_detect_pii()\n-- Type: UPDATE\n-- Description: Update PII job with detection results\n-- Parameters:\n--   $1: p_job_id UUID - Job ID to update\n--   $2: p_pii_found BOOLEAN - Whether PII was found\n--   $3: p_pii_types JSONB - Types of PII detected\n--   $4: p_confidence DECIMAL - Confidence score\n--   $5: p_masked_text TEXT - Masked version of text\n-- Returns: Updated job record\n-- ================================================================\n\n-- Update the PII detection job with results\n\nUPDATE pii_processing_jobs\nSET \n    status = 'completed',\n    completed_at = NOW(),\n    records_processed = 1,\n    pii_found_count = CASE \n        WHEN $2::BOOLEAN AND jsonb_typeof($3::JSONB) = 'array' THEN jsonb_array_length($3::JSONB) \n        ELSE 0 \n    END,\n    processing_options = processing_options || jsonb_build_object(\n        'detected_types', $3::JSONB,\n        'confidence', $4::DECIMAL,\n        'masked_text', $5::TEXT,\n        'pii_found', $2::BOOLEAN\n    )\nWHERE id = $1::UUID\nRETURNING \n    id,\n    status,\n    pii_found_count,\n    processing_options,\n    completed_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_detect_pii()
 * -- Type: UPDATE
 * -- Description: Update PII job with detection results
 * -- Parameters:
 * --   $1: p_job_id UUID - Job ID to update
 * --   $2: p_pii_found BOOLEAN - Whether PII was found
 * --   $3: p_pii_types JSONB - Types of PII detected
 * --   $4: p_confidence DECIMAL - Confidence score
 * --   $5: p_masked_text TEXT - Masked version of text
 * -- Returns: Updated job record
 * -- ================================================================
 * 
 * -- Update the PII detection job with results
 * 
 * UPDATE pii_processing_jobs
 * SET 
 *     status = 'completed',
 *     completed_at = NOW(),
 *     records_processed = 1,
 *     pii_found_count = CASE 
 *         WHEN $2::BOOLEAN AND jsonb_typeof($3::JSONB) = 'array' THEN jsonb_array_length($3::JSONB) 
 *         ELSE 0 
 *     END,
 *     processing_options = processing_options || jsonb_build_object(
 *         'detected_types', $3::JSONB,
 *         'confidence', $4::DECIMAL,
 *         'masked_text', $5::TEXT,
 *         'pii_found', $2::BOOLEAN
 *     )
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     status,
 *     pii_found_count,
 *     processing_options,
 *     completed_at
 * ```
 */
export const updatePiiDetectionJob = new PreparedQuery<IUpdatePiiDetectionJobParams,IUpdatePiiDetectionJobResult>(updatePiiDetectionJobIR);


