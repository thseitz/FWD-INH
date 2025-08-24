/* @name getCurrentTenantId */
-- ================================================================
-- Converted from: current_tenant_id()
-- Type: Simple Read-Only Query
-- Description: Get current tenant ID from session context
-- Parameters: None
-- Returns: INTEGER
-- ================================================================

-- This query retrieves the tenant ID from the PostgreSQL session context
-- The application must set this value using: SET LOCAL app.current_tenant_id = '1'
-- Returns NULL if not set

SELECT 
    CASE 
        WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
        THEN NULL
        ELSE current_setting('app.current_tenant_id', true)::INTEGER
    END as tenant_id;