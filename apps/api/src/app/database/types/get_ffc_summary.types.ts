/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/get_ffc_summary.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetFfcSummary' parameters type */
export type IGetFfcSummaryParams = void;

/** 'GetFfcSummary' return type */
export interface IGetFfcSummaryResult {
  asset_count: string | null;
  created_date: Date | null;
  document_count: string | null;
  ffc_name: string;
  member_count: string | null;
  owner_name: string | null;
}

/** 'GetFfcSummary' query type */
export interface IGetFfcSummaryQuery {
  params: IGetFfcSummaryParams;
  result: IGetFfcSummaryResult;
}

const getFfcSummaryIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_ffc_summary(p_ffc_id UUID, p_user_id UUID)\n-- Type: Read-Only Query with Access Check\n-- Description: Get summary information for an FFC\n-- Parameters:\n--   $1: p_ffc_id UUID - The FFC ID to get summary for\n--   $2: p_user_id UUID - The user ID requesting the summary\n-- Returns: Summary information table\n-- ================================================================\n\n-- This query retrieves summary information for an FFC\n-- Note: Access check is implemented as a WHERE clause filter\n-- If user is not a member, no rows will be returned\n\nSELECT \n    f.name as ffc_name,\n    u.first_name || ' ' || u.last_name as owner_name,\n    (SELECT COUNT(*) FROM ffc_personas WHERE ffc_id = $1::UUID) as member_count,\n    (SELECT COUNT(DISTINCT a.id) \n     FROM assets a \n     JOIN asset_persona ap ON a.id = ap.asset_id\n     JOIN ffc_personas fp ON ap.persona_id = fp.persona_id\n     WHERE fp.ffc_id = $1::UUID) as asset_count,\n    0::BIGINT as document_count, -- Documents not directly linked to FFCs\n    f.created_at as created_date\nFROM fwd_family_circles f\nJOIN users u ON f.owner_user_id = u.id\nWHERE f.id = $1::UUID\n  -- Access check: Only return data if user is a member\n  AND EXISTS (\n      SELECT 1 \n      FROM ffc_personas fp\n      JOIN personas p ON fp.persona_id = p.id\n      WHERE fp.ffc_id = $1::UUID \n      AND p.user_id = $2::UUID\n  )"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_ffc_summary(p_ffc_id UUID, p_user_id UUID)
 * -- Type: Read-Only Query with Access Check
 * -- Description: Get summary information for an FFC
 * -- Parameters:
 * --   $1: p_ffc_id UUID - The FFC ID to get summary for
 * --   $2: p_user_id UUID - The user ID requesting the summary
 * -- Returns: Summary information table
 * -- ================================================================
 * 
 * -- This query retrieves summary information for an FFC
 * -- Note: Access check is implemented as a WHERE clause filter
 * -- If user is not a member, no rows will be returned
 * 
 * SELECT 
 *     f.name as ffc_name,
 *     u.first_name || ' ' || u.last_name as owner_name,
 *     (SELECT COUNT(*) FROM ffc_personas WHERE ffc_id = $1::UUID) as member_count,
 *     (SELECT COUNT(DISTINCT a.id) 
 *      FROM assets a 
 *      JOIN asset_persona ap ON a.id = ap.asset_id
 *      JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
 *      WHERE fp.ffc_id = $1::UUID) as asset_count,
 *     0::BIGINT as document_count, -- Documents not directly linked to FFCs
 *     f.created_at as created_date
 * FROM fwd_family_circles f
 * JOIN users u ON f.owner_user_id = u.id
 * WHERE f.id = $1::UUID
 *   -- Access check: Only return data if user is a member
 *   AND EXISTS (
 *       SELECT 1 
 *       FROM ffc_personas fp
 *       JOIN personas p ON fp.persona_id = p.id
 *       WHERE fp.ffc_id = $1::UUID 
 *       AND p.user_id = $2::UUID
 *   )
 * ```
 */
export const getFfcSummary = new PreparedQuery<IGetFfcSummaryParams,IGetFfcSummaryResult>(getFfcSummaryIR);


