/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/is_ffc_member.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'IsFfcMember' parameters type */
export type IIsFfcMemberParams = void;

/** 'IsFfcMember' return type */
export interface IIsFfcMemberResult {
  is_member: boolean | null;
}

/** 'IsFfcMember' query type */
export interface IIsFfcMemberQuery {
  params: IIsFfcMemberParams;
  result: IIsFfcMemberResult;
}

const isFfcMemberIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: is_ffc_member(p_ffc_id UUID, p_user_id UUID)\n-- Type: Simple Read-Only Query\n-- Description: Check if user is member of an FFC\n-- Parameters: \n--   $1: p_ffc_id UUID - The FFC ID to check\n--   $2: p_user_id UUID - The user ID to check (optional, defaults to current user)\n-- Returns: BOOLEAN\n-- ================================================================\n\n-- This query checks if a user is a member of a Forward Family Circle\n-- If p_user_id is not provided, it uses the current user from session context\n\nSELECT EXISTS (\n    SELECT 1 \n    FROM ffc_personas fp\n    JOIN personas p ON fp.persona_id = p.id\n    WHERE fp.ffc_id = $1::UUID\n    AND p.user_id = COALESCE(\n        $2::UUID, \n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\n) as is_member"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: is_ffc_member(p_ffc_id UUID, p_user_id UUID)
 * -- Type: Simple Read-Only Query
 * -- Description: Check if user is member of an FFC
 * -- Parameters: 
 * --   $1: p_ffc_id UUID - The FFC ID to check
 * --   $2: p_user_id UUID - The user ID to check (optional, defaults to current user)
 * -- Returns: BOOLEAN
 * -- ================================================================
 * 
 * -- This query checks if a user is a member of a Forward Family Circle
 * -- If p_user_id is not provided, it uses the current user from session context
 * 
 * SELECT EXISTS (
 *     SELECT 1 
 *     FROM ffc_personas fp
 *     JOIN personas p ON fp.persona_id = p.id
 *     WHERE fp.ffc_id = $1::UUID
 *     AND p.user_id = COALESCE(
 *         $2::UUID, 
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * ) as is_member
 * ```
 */
export const isFfcMember = new PreparedQuery<IIsFfcMemberParams,IIsFfcMemberResult>(isFfcMemberIR);


