/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/users/update_user_profile.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UpdateUserProfile' parameters type */
export type IUpdateUserProfileParams = void;

/** 'UpdateUserProfile' return type */
export interface IUpdateUserProfileResult {
  display_name: string | null;
  first_name: string;
  id: string;
  last_name: string;
  preferred_language: string | null;
  profile_picture_url: string | null;
  timezone: string | null;
  updated_at: Date | null;
}

/** 'UpdateUserProfile' query type */
export interface IUpdateUserProfileQuery {
  params: IUpdateUserProfileParams;
  result: IUpdateUserProfileResult;
}

const updateUserProfileIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_user_profile()\n-- Type: Simple UPDATE Operation\n-- Description: Update user profile fields\n-- Parameters:\n--   $1: p_user_id UUID - User ID to update\n--   $2: p_first_name TEXT - New first name (optional)\n--   $3: p_last_name TEXT - New last name (optional)\n--   $4: p_display_name TEXT - New display name (optional)\n--   $5: p_profile_picture_url TEXT - New profile picture URL (optional)\n--   $6: p_preferred_language CHAR(2) - New preferred language (optional)\n--   $7: p_timezone VARCHAR(50) - New timezone (optional)\n-- Returns: Updated user record\n-- ================================================================\n\n-- This query updates user profile fields\n-- Only non-NULL parameters will update the corresponding fields\n-- Returns the updated record for confirmation\n\nUPDATE users SET\n    first_name = COALESCE($2::TEXT, first_name),\n    last_name = COALESCE($3::TEXT, last_name),\n    display_name = COALESCE($4::TEXT, display_name),\n    profile_picture_url = COALESCE($5::TEXT, profile_picture_url),\n    preferred_language = COALESCE($6::CHAR(2), preferred_language),\n    timezone = COALESCE($7::VARCHAR(50), timezone),\n    updated_at = NOW(),\n    updated_by = $1::UUID\nWHERE id = $1::UUID\nRETURNING \n    id,\n    first_name,\n    last_name,\n    display_name,\n    profile_picture_url,\n    preferred_language,\n    timezone,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_user_profile()
 * -- Type: Simple UPDATE Operation
 * -- Description: Update user profile fields
 * -- Parameters:
 * --   $1: p_user_id UUID - User ID to update
 * --   $2: p_first_name TEXT - New first name (optional)
 * --   $3: p_last_name TEXT - New last name (optional)
 * --   $4: p_display_name TEXT - New display name (optional)
 * --   $5: p_profile_picture_url TEXT - New profile picture URL (optional)
 * --   $6: p_preferred_language CHAR(2) - New preferred language (optional)
 * --   $7: p_timezone VARCHAR(50) - New timezone (optional)
 * -- Returns: Updated user record
 * -- ================================================================
 * 
 * -- This query updates user profile fields
 * -- Only non-NULL parameters will update the corresponding fields
 * -- Returns the updated record for confirmation
 * 
 * UPDATE users SET
 *     first_name = COALESCE($2::TEXT, first_name),
 *     last_name = COALESCE($3::TEXT, last_name),
 *     display_name = COALESCE($4::TEXT, display_name),
 *     profile_picture_url = COALESCE($5::TEXT, profile_picture_url),
 *     preferred_language = COALESCE($6::CHAR(2), preferred_language),
 *     timezone = COALESCE($7::VARCHAR(50), timezone),
 *     updated_at = NOW(),
 *     updated_by = $1::UUID
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     first_name,
 *     last_name,
 *     display_name,
 *     profile_picture_url,
 *     preferred_language,
 *     timezone,
 *     updated_at
 * ```
 */
export const updateUserProfile = new PreparedQuery<IUpdateUserProfileParams,IUpdateUserProfileResult>(updateUserProfileIR);


