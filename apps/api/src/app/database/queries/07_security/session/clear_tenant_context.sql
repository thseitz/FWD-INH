/* @name clearTenantContext */
-- ================================================================
-- Converted from: sp_clear_session_context() - Part 2
-- Type: Session Configuration (Side Effect Operation)
-- Description: Clear tenant context variable from session
-- Parameters: None
-- Returns: Configuration result
-- ================================================================

-- This operation clears PostgreSQL session variable for tenant
-- Should be executed after clearSessionContext
SELECT set_config('app.current_tenant_id', NULL, true) as tenant_context;