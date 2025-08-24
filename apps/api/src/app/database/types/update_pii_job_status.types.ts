/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/pii_detection/update_pii_job_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UpdatePiiJobStatus' parameters type */
export type IUpdatePiiJobStatusParams = void;

/** 'UpdatePiiJobStatus' return type */
export interface IUpdatePiiJobStatusResult {
  completed_at: Date | null;
  id: string;
  pii_found_count: number | null;
  records_processed: number | null;
  status: string;
}

/** 'UpdatePiiJobStatus' query type */
export interface IUpdatePiiJobStatusQuery {
  params: IUpdatePiiJobStatusParams;
  result: IUpdatePiiJobStatusResult;
}

const updatePiiJobStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_pii_job_status()\n-- Type: Complex UPDATE with Conditional Logic\n-- Description: Update PII processing job status\n-- Parameters:\n--   $1: p_job_id UUID - Job ID to update\n--   $2: p_status VARCHAR(20) - New status\n--   $3: p_processed_records INTEGER - Number of records processed (optional)\n--   $4: p_pii_found_count INTEGER - Number of PII items found (optional)\n--   $5: p_error_message TEXT - Error message to append (optional)\n--   $6: p_results JSONB - Results to merge (optional)\n-- Returns: Updated job record\n-- ================================================================\n\n-- This query updates PII job status with conditional field updates\n-- Appends errors to array and merges results into options\n\nUPDATE pii_processing_jobs SET\n    status = $2::VARCHAR(20),\n    records_processed = COALESCE($3::INTEGER, records_processed),\n    pii_found_count = COALESCE($4::INTEGER, pii_found_count),\n    error_details = CASE \n        WHEN $5::TEXT IS NOT NULL \n        THEN COALESCE(error_details, '[]'::jsonb) || jsonb_build_array(\n            jsonb_build_object('error', $5::TEXT, 'timestamp', NOW())\n        )\n        ELSE error_details\n    END,\n    processing_options = CASE\n        WHEN $6::JSONB IS NOT NULL\n        THEN COALESCE(processing_options, '{}'::jsonb) || jsonb_build_object('results', $6::JSONB)\n        ELSE processing_options\n    END,\n    completed_at = CASE \n        WHEN $2::VARCHAR(20) IN ('completed', 'failed') THEN NOW()\n        ELSE completed_at\n    END\nWHERE id = $1::UUID\nRETURNING \n    id,\n    status,\n    records_processed,\n    pii_found_count,\n    completed_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_pii_job_status()
 * -- Type: Complex UPDATE with Conditional Logic
 * -- Description: Update PII processing job status
 * -- Parameters:
 * --   $1: p_job_id UUID - Job ID to update
 * --   $2: p_status VARCHAR(20) - New status
 * --   $3: p_processed_records INTEGER - Number of records processed (optional)
 * --   $4: p_pii_found_count INTEGER - Number of PII items found (optional)
 * --   $5: p_error_message TEXT - Error message to append (optional)
 * --   $6: p_results JSONB - Results to merge (optional)
 * -- Returns: Updated job record
 * -- ================================================================
 * 
 * -- This query updates PII job status with conditional field updates
 * -- Appends errors to array and merges results into options
 * 
 * UPDATE pii_processing_jobs SET
 *     status = $2::VARCHAR(20),
 *     records_processed = COALESCE($3::INTEGER, records_processed),
 *     pii_found_count = COALESCE($4::INTEGER, pii_found_count),
 *     error_details = CASE 
 *         WHEN $5::TEXT IS NOT NULL 
 *         THEN COALESCE(error_details, '[]'::jsonb) || jsonb_build_array(
 *             jsonb_build_object('error', $5::TEXT, 'timestamp', NOW())
 *         )
 *         ELSE error_details
 *     END,
 *     processing_options = CASE
 *         WHEN $6::JSONB IS NOT NULL
 *         THEN COALESCE(processing_options, '{}'::jsonb) || jsonb_build_object('results', $6::JSONB)
 *         ELSE processing_options
 *     END,
 *     completed_at = CASE 
 *         WHEN $2::VARCHAR(20) IN ('completed', 'failed') THEN NOW()
 *         ELSE completed_at
 *     END
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     status,
 *     records_processed,
 *     pii_found_count,
 *     completed_at
 * ```
 */
export const updatePiiJobStatus = new PreparedQuery<IUpdatePiiJobStatusParams,IUpdatePiiJobStatusResult>(updatePiiJobStatusIR);


