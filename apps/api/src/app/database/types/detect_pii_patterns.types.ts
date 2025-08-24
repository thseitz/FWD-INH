/** Types generated for queries found in "apps/api/src/app/database/queries/07_security/pii_detection/detect_pii_patterns.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'DetectPiiPatterns' parameters type */
export type IDetectPiiPatternsParams = void;

/** 'DetectPiiPatterns' return type */
export interface IDetectPiiPatternsResult {
  confidence_score: string | null;
  detected: boolean | null;
  detection_details: Json | null;
  masked_text: string | null;
  pii_types: Json | null;
}

/** 'DetectPiiPatterns' query type */
export interface IDetectPiiPatternsQuery {
  params: IDetectPiiPatternsParams;
  result: IDetectPiiPatternsResult;
}

const detectPiiPatternsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_detect_pii() - Pattern Detection\n-- Type: SELECT with pattern matching\n-- Description: Detect PII patterns in text\n-- Parameters:\n--   $1: p_text TEXT - Text to analyze\n-- Returns: Detection results\n-- NOTE: This query performs pattern matching for common PII types\n-- ================================================================\n\n-- Detect PII patterns and return results\n-- Service layer should use these results to update the job\n\nWITH pii_detection AS (\n    SELECT \n        $1::TEXT as original_text,\n        -- SSN Detection\n        CASE \n            WHEN $1::TEXT ~* '\\d{3}-\\d{2}-\\d{4}' OR $1::TEXT ~* '\\d{9}' \n            THEN TRUE \n            ELSE FALSE \n        END as has_ssn,\n        -- Email Detection\n        CASE \n            WHEN $1::TEXT ~* '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}' \n            THEN TRUE \n            ELSE FALSE \n        END as has_email,\n        -- Phone Detection\n        CASE \n            WHEN $1::TEXT ~* '\\+?1?\\s*\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}' \n            THEN TRUE \n            ELSE FALSE \n        END as has_phone,\n        -- Credit Card Detection\n        CASE \n            WHEN $1::TEXT ~* '\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}' \n            THEN TRUE \n            ELSE FALSE \n        END as has_credit_card\n)\nSELECT \n    (has_ssn OR has_email OR has_phone OR has_credit_card) as detected,\n    jsonb_build_array(\n        CASE WHEN has_ssn THEN jsonb_build_object('type', 'SSN', 'confidence', 0.95) END,\n        CASE WHEN has_email THEN jsonb_build_object('type', 'Email', 'confidence', 0.98) END,\n        CASE WHEN has_phone THEN jsonb_build_object('type', 'Phone', 'confidence', 0.85) END,\n        CASE WHEN has_credit_card THEN jsonb_build_object('type', 'Credit Card', 'confidence', 0.90) END\n    ) - NULL as pii_types,\n    GREATEST(\n        CASE WHEN has_ssn THEN 0.95 ELSE 0 END,\n        CASE WHEN has_email THEN 0.98 ELSE 0 END,\n        CASE WHEN has_phone THEN 0.85 ELSE 0 END,\n        CASE WHEN has_credit_card THEN 0.90 ELSE 0 END\n    )::DECIMAL as confidence_score,\n    -- Mask the text\n    regexp_replace(\n        regexp_replace(\n            regexp_replace(\n                regexp_replace(\n                    regexp_replace(\n                        original_text,\n                        '\\d{3}-\\d{2}-\\d{4}', 'XXX-XX-XXXX', 'g'\n                    ),\n                    '\\d{9}', 'XXXXXXXXX', 'g'\n                ),\n                '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}', '[EMAIL]', 'g'\n            ),\n            '\\+?1?\\s*\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}', '[PHONE]', 'g'\n        ),\n        '\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}', '[CREDIT_CARD]', 'g'\n    ) as masked_text,\n    jsonb_build_object(\n        'patterns_checked', jsonb_build_array('SSN', 'Email', 'Phone', 'Credit Card'),\n        'text_length', length(original_text)\n    ) as detection_details\nFROM pii_detection"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_detect_pii() - Pattern Detection
 * -- Type: SELECT with pattern matching
 * -- Description: Detect PII patterns in text
 * -- Parameters:
 * --   $1: p_text TEXT - Text to analyze
 * -- Returns: Detection results
 * -- NOTE: This query performs pattern matching for common PII types
 * -- ================================================================
 * 
 * -- Detect PII patterns and return results
 * -- Service layer should use these results to update the job
 * 
 * WITH pii_detection AS (
 *     SELECT 
 *         $1::TEXT as original_text,
 *         -- SSN Detection
 *         CASE 
 *             WHEN $1::TEXT ~* '\d{3}-\d{2}-\d{4}' OR $1::TEXT ~* '\d{9}' 
 *             THEN TRUE 
 *             ELSE FALSE 
 *         END as has_ssn,
 *         -- Email Detection
 *         CASE 
 *             WHEN $1::TEXT ~* '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 
 *             THEN TRUE 
 *             ELSE FALSE 
 *         END as has_email,
 *         -- Phone Detection
 *         CASE 
 *             WHEN $1::TEXT ~* '\+?1?\s*\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}' 
 *             THEN TRUE 
 *             ELSE FALSE 
 *         END as has_phone,
 *         -- Credit Card Detection
 *         CASE 
 *             WHEN $1::TEXT ~* '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}' 
 *             THEN TRUE 
 *             ELSE FALSE 
 *         END as has_credit_card
 * )
 * SELECT 
 *     (has_ssn OR has_email OR has_phone OR has_credit_card) as detected,
 *     jsonb_build_array(
 *         CASE WHEN has_ssn THEN jsonb_build_object('type', 'SSN', 'confidence', 0.95) END,
 *         CASE WHEN has_email THEN jsonb_build_object('type', 'Email', 'confidence', 0.98) END,
 *         CASE WHEN has_phone THEN jsonb_build_object('type', 'Phone', 'confidence', 0.85) END,
 *         CASE WHEN has_credit_card THEN jsonb_build_object('type', 'Credit Card', 'confidence', 0.90) END
 *     ) - NULL as pii_types,
 *     GREATEST(
 *         CASE WHEN has_ssn THEN 0.95 ELSE 0 END,
 *         CASE WHEN has_email THEN 0.98 ELSE 0 END,
 *         CASE WHEN has_phone THEN 0.85 ELSE 0 END,
 *         CASE WHEN has_credit_card THEN 0.90 ELSE 0 END
 *     )::DECIMAL as confidence_score,
 *     -- Mask the text
 *     regexp_replace(
 *         regexp_replace(
 *             regexp_replace(
 *                 regexp_replace(
 *                     regexp_replace(
 *                         original_text,
 *                         '\d{3}-\d{2}-\d{4}', 'XXX-XX-XXXX', 'g'
 *                     ),
 *                     '\d{9}', 'XXXXXXXXX', 'g'
 *                 ),
 *                 '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '[EMAIL]', 'g'
 *             ),
 *             '\+?1?\s*\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}', '[PHONE]', 'g'
 *         ),
 *         '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}', '[CREDIT_CARD]', 'g'
 *     ) as masked_text,
 *     jsonb_build_object(
 *         'patterns_checked', jsonb_build_array('SSN', 'Email', 'Phone', 'Credit Card'),
 *         'text_length', length(original_text)
 *     ) as detection_details
 * FROM pii_detection
 * ```
 */
export const detectPiiPatterns = new PreparedQuery<IDetectPiiPatternsParams,IDetectPiiPatternsResult>(detectPiiPatternsIR);


