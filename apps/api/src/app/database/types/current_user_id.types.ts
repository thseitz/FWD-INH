/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/users/current_user_id.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetCurrentUserId' parameters type */
export type IGetCurrentUserIdParams = void;

/** 'GetCurrentUserId' return type */
export interface IGetCurrentUserIdResult {
  user_id: string | null;
}

/** 'GetCurrentUserId' query type */
export interface IGetCurrentUserIdQuery {
  params: IGetCurrentUserIdParams;
  result: IGetCurrentUserIdResult;
}

const getCurrentUserIdIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: current_user_id() \n-- Type: Simple Read-Only Query\n-- Description: Get current user's ID from session context\n-- Parameters: None\n-- Returns: UUID\n-- ================================================================\n\n-- This query retrieves the user ID from the PostgreSQL session context\n-- The application must set this value using: SET LOCAL app.current_user_id = 'user-uuid'\n-- Returns NULL if not set\nSELECT \n    CASE \n        WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = '' \n        THEN NULL\n        ELSE current_setting('app.current_user_id', true)::UUID\n    END as user_id"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: current_user_id() 
 * -- Type: Simple Read-Only Query
 * -- Description: Get current user's ID from session context
 * -- Parameters: None
 * -- Returns: UUID
 * -- ================================================================
 * 
 * -- This query retrieves the user ID from the PostgreSQL session context
 * -- The application must set this value using: SET LOCAL app.current_user_id = 'user-uuid'
 * -- Returns NULL if not set
 * SELECT 
 *     CASE 
 *         WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = '' 
 *         THEN NULL
 *         ELSE current_setting('app.current_user_id', true)::UUID
 *     END as user_id
 * ```
 */
export const getCurrentUserId = new PreparedQuery<IGetCurrentUserIdParams,IGetCurrentUserIdResult>(getCurrentUserIdIR);


