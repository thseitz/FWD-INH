/* @name setTenantContext */
-- ================================================================
-- Converted from: sp_set_session_context() - Part 2
-- Type: Session Configuration (Side Effect Operation)
-- Description: Set tenant context variable for session
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID to set in session
-- Returns: Configuration result
-- ================================================================

-- This operation sets PostgreSQL session variable for tenant
-- Should be executed after setSessionContext
SELECT set_config('app.current_tenant_id', $1::TEXT, true) as tenant_context;