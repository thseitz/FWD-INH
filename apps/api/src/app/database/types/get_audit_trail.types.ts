/** Types generated for queries found in "apps/api/src/app/database/queries/08_audit/events/get_audit_trail.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetAuditTrail' parameters type */
export type IGetAuditTrailParams = void;

/** 'GetAuditTrail' return type */
export interface IGetAuditTrailResult {
  action: string | null;
  audit_id: string;
  changes: Json | null;
  created_at: Date | null;
  entity_name: string | null;
  entity_type: string | null;
  metadata: Json | null;
  user_name: string | null;
}

/** 'GetAuditTrail' query type */
export interface IGetAuditTrailQuery {
  params: IGetAuditTrailParams;
  result: IGetAuditTrailResult;
}

const getAuditTrailIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_audit_trail()\n-- Type: Simple Read-Only Query with Filters\n-- Description: Retrieve audit log entries with optional filters\n-- Parameters:\n--   $1: p_entity_type VARCHAR(50) - Optional filter by entity type\n--   $2: p_entity_id UUID - Optional filter by entity ID\n--   $3: p_user_id UUID - Optional filter by user ID\n--   $4: p_action VARCHAR(50) - Optional filter by action\n--   $5: p_start_date TIMESTAMPTZ - Optional start date filter\n--   $6: p_end_date TIMESTAMPTZ - Optional end date filter\n--   $7: p_limit INTEGER - Maximum records to return (default 100)\n--   $8: p_offset INTEGER - Pagination offset (default 0)\n-- Returns: Audit trail records\n-- ================================================================\n\n-- This query retrieves audit log entries with optional filtering\n-- All parameters are optional for flexible querying\n\nSELECT \n    al.id as audit_id,\n    al.created_at,\n    u.first_name || ' ' || u.last_name as user_name,\n    al.action::VARCHAR,\n    al.entity_type::VARCHAR,\n    al.entity_name,\n    jsonb_build_object(\n        'old_values', al.old_values,\n        'new_values', al.new_values\n    ) as changes,\n    al.metadata\nFROM audit_log al\nLEFT JOIN users u ON al.user_id = u.id\nWHERE \n    ($1::VARCHAR IS NULL OR al.entity_type::TEXT = $1)\n    AND ($2::UUID IS NULL OR al.entity_id = $2)\n    AND ($3::UUID IS NULL OR al.user_id = $3)\n    AND ($4::VARCHAR IS NULL OR al.action::TEXT = $4)\n    AND ($5::TIMESTAMPTZ IS NULL OR al.created_at >= $5)\n    AND ($6::TIMESTAMPTZ IS NULL OR al.created_at <= $6)\nORDER BY al.created_at DESC\nLIMIT COALESCE($7::INTEGER, 100)\nOFFSET COALESCE($8::INTEGER, 0)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_audit_trail()
 * -- Type: Simple Read-Only Query with Filters
 * -- Description: Retrieve audit log entries with optional filters
 * -- Parameters:
 * --   $1: p_entity_type VARCHAR(50) - Optional filter by entity type
 * --   $2: p_entity_id UUID - Optional filter by entity ID
 * --   $3: p_user_id UUID - Optional filter by user ID
 * --   $4: p_action VARCHAR(50) - Optional filter by action
 * --   $5: p_start_date TIMESTAMPTZ - Optional start date filter
 * --   $6: p_end_date TIMESTAMPTZ - Optional end date filter
 * --   $7: p_limit INTEGER - Maximum records to return (default 100)
 * --   $8: p_offset INTEGER - Pagination offset (default 0)
 * -- Returns: Audit trail records
 * -- ================================================================
 * 
 * -- This query retrieves audit log entries with optional filtering
 * -- All parameters are optional for flexible querying
 * 
 * SELECT 
 *     al.id as audit_id,
 *     al.created_at,
 *     u.first_name || ' ' || u.last_name as user_name,
 *     al.action::VARCHAR,
 *     al.entity_type::VARCHAR,
 *     al.entity_name,
 *     jsonb_build_object(
 *         'old_values', al.old_values,
 *         'new_values', al.new_values
 *     ) as changes,
 *     al.metadata
 * FROM audit_log al
 * LEFT JOIN users u ON al.user_id = u.id
 * WHERE 
 *     ($1::VARCHAR IS NULL OR al.entity_type::TEXT = $1)
 *     AND ($2::UUID IS NULL OR al.entity_id = $2)
 *     AND ($3::UUID IS NULL OR al.user_id = $3)
 *     AND ($4::VARCHAR IS NULL OR al.action::TEXT = $4)
 *     AND ($5::TIMESTAMPTZ IS NULL OR al.created_at >= $5)
 *     AND ($6::TIMESTAMPTZ IS NULL OR al.created_at <= $6)
 * ORDER BY al.created_at DESC
 * LIMIT COALESCE($7::INTEGER, 100)
 * OFFSET COALESCE($8::INTEGER, 0)
 * ```
 */
export const getAuditTrail = new PreparedQuery<IGetAuditTrailParams,IGetAuditTrailResult>(getAuditTrailIR);


