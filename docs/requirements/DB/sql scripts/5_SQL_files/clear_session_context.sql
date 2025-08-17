-- ================================================================
-- Converted from: sp_clear_session_context()
-- Type: Session Configuration (Side Effect Operation)
-- Description: Clear session context variables
-- Parameters: None
-- Returns: None (void operation)
-- ================================================================

-- This operation clears PostgreSQL session variables
-- These need to be executed as separate statements
-- The service layer should execute both statements

-- Statement 1: Clear user ID
SELECT set_config('app.current_user_id', NULL, true) as user_context;

-- Statement 2: Clear tenant ID
-- This needs to be executed as a separate query:
-- SELECT set_config('app.current_tenant_id', NULL, true) as tenant_context;