/* @name updateUserProfile */
-- ================================================================
-- Converted from: sp_update_user_profile()
-- Type: Simple UPDATE Operation
-- Description: Update user profile fields
-- Parameters:
--   $1: p_user_id UUID - User ID to update
--   $2: p_first_name TEXT - New first name (optional)
--   $3: p_last_name TEXT - New last name (optional)
--   $4: p_display_name TEXT - New display name (optional)
--   $5: p_profile_picture_url TEXT - New profile picture URL (optional)
--   $6: p_preferred_language CHAR(2) - New preferred language (optional)
--   $7: p_timezone VARCHAR(50) - New timezone (optional)
-- Returns: Updated user record
-- ================================================================

-- This query updates user profile fields
-- Only non-NULL parameters will update the corresponding fields
-- Returns the updated record for confirmation

UPDATE users SET
    first_name = COALESCE($2::TEXT, first_name),
    last_name = COALESCE($3::TEXT, last_name),
    display_name = COALESCE($4::TEXT, display_name),
    profile_picture_url = COALESCE($5::TEXT, profile_picture_url),
    preferred_language = COALESCE($6::CHAR(2), preferred_language),
    timezone = COALESCE($7::VARCHAR(50), timezone),
    updated_at = NOW(),
    updated_by = $1::UUID
WHERE id = $1::UUID
RETURNING 
    id,
    first_name,
    last_name,
    display_name,
    profile_picture_url,
    preferred_language,
    timezone,
    updated_at;