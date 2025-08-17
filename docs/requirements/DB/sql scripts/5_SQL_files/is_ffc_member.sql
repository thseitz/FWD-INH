-- ================================================================
-- Converted from: is_ffc_member(p_ffc_id UUID, p_user_id UUID)
-- Type: Simple Read-Only Query
-- Description: Check if user is member of an FFC
-- Parameters: 
--   $1: p_ffc_id UUID - The FFC ID to check
--   $2: p_user_id UUID - The user ID to check (optional, defaults to current user)
-- Returns: BOOLEAN
-- ================================================================

-- This query checks if a user is a member of a Forward Family Circle
-- If p_user_id is not provided, it uses the current user from session context

SELECT EXISTS (
    SELECT 1 
    FROM ffc_personas fp
    JOIN personas p ON fp.persona_id = p.id
    WHERE fp.ffc_id = $1::UUID
    AND p.user_id = COALESCE(
        $2::UUID, 
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
) as is_member;