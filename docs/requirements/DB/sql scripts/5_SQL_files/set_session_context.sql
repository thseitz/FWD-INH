-- ================================================================
-- Converted from: sp_set_session_context()
-- Type: Session Configuration (Side Effect Operation)
-- Description: Set session context variables for user and tenant
-- Parameters:
--   $1: p_user_id UUID - User ID to set in session
--   $2: p_tenant_id INTEGER - Tenant ID to set in session
-- Returns: None (void operation)
-- ================================================================

-- This operation sets PostgreSQL session variables
-- These need to be executed as separate statements in a transaction
-- The service layer should execute both statements

-- Statement 1: Set user ID
SELECT set_config('app.current_user_id', $1::TEXT, true) as user_context;

-- Statement 2: Set tenant ID  
-- This needs to be executed as a separate query:
-- SELECT set_config('app.current_tenant_id', $2::TEXT, true) as tenant_context;