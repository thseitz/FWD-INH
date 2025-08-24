/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/pii_detection/create_pii_detection_job.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'CreatePiiDetectionJob' parameters type */
export type ICreatePiiDetectionJobParams = void;

/** 'CreatePiiDetectionJob' return type */
export interface ICreatePiiDetectionJobResult {
  id: string;
  job_type: string;
  processing_options: Json | null;
  status: string;
}

/** 'CreatePiiDetectionJob' query type */
export interface ICreatePiiDetectionJobQuery {
  params: ICreatePiiDetectionJobParams;
  result: ICreatePiiDetectionJobResult;
}

const createPiiDetectionJobIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_detect_pii()\n-- Type: INSERT\n-- Description: Create PII processing job\n-- Parameters:\n--   $1: p_context TEXT - Context for detection (default 'general')\n--   $2: p_user_id UUID - User requesting detection (optional)\n-- Returns: PII processing job record\n-- ================================================================\n\n-- Create a new PII detection job\n\nINSERT INTO pii_processing_jobs (\n    tenant_id,\n    job_type,\n    status,\n    records_processed,\n    processing_options,\n    created_at\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    'detection',\n    'running',\n    0,\n    jsonb_build_object(\n        'context', COALESCE($1::TEXT, 'general'),\n        'user_id', COALESCE(\n            $2::UUID,\n            CASE \n                WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n                THEN NULL\n                ELSE current_setting('app.current_user_id', true)::UUID\n            END\n        )\n    ),\n    NOW()\n)\nRETURNING \n    id,\n    job_type,\n    status,\n    processing_options"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_detect_pii()
 * -- Type: INSERT
 * -- Description: Create PII processing job
 * -- Parameters:
 * --   $1: p_context TEXT - Context for detection (default 'general')
 * --   $2: p_user_id UUID - User requesting detection (optional)
 * -- Returns: PII processing job record
 * -- ================================================================
 * 
 * -- Create a new PII detection job
 * 
 * INSERT INTO pii_processing_jobs (
 *     tenant_id,
 *     job_type,
 *     status,
 *     records_processed,
 *     processing_options,
 *     created_at
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     'detection',
 *     'running',
 *     0,
 *     jsonb_build_object(
 *         'context', COALESCE($1::TEXT, 'general'),
 *         'user_id', COALESCE(
 *             $2::UUID,
 *             CASE 
 *                 WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *                 THEN NULL
 *                 ELSE current_setting('app.current_user_id', true)::UUID
 *             END
 *         )
 *     ),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     job_type,
 *     status,
 *     processing_options
 * ```
 */
export const createPiiDetectionJob = new PreparedQuery<ICreatePiiDetectionJobParams,ICreatePiiDetectionJobResult>(createPiiDetectionJobIR);


