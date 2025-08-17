-- ================================================================
-- Converted from: current_user_id() 
-- Type: Simple Read-Only Query
-- Description: Get current user's ID from session context
-- Parameters: None
-- Returns: UUID
-- ================================================================

-- This query retrieves the user ID from the PostgreSQL session context
-- The application must set this value using: SET LOCAL app.current_user_id = 'user-uuid'
-- Returns NULL if not set

SELECT 
    CASE 
        WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = '' 
        THEN NULL
        ELSE current_setting('app.current_user_id', true)::UUID
    END as user_id;