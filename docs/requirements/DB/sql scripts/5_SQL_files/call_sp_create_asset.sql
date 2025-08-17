-- ================================================================
-- Wrapper for: sp_create_asset()
-- Type: FUNCTION call wrapper
-- Description: Create a new asset with ownership assignment
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_owner_persona_id UUID - Owner persona ID
--   $3: p_asset_type asset_type_enum - Asset type
--   $4: p_name TEXT - Asset name
--   $5: p_description TEXT - Asset description
--   $6: p_ownership_percentage DECIMAL(5,2) - Ownership % (optional, default 100)
--   $7: p_created_by_user_id UUID - Created by user (optional)
-- Returns: Created asset UUID
-- ================================================================

-- Call stored procedure to create asset

SELECT * FROM sp_create_asset(
    $1::INTEGER,                               -- p_tenant_id
    $2::UUID,                                  -- p_owner_persona_id
    $3::asset_type_enum,                       -- p_asset_type
    $4::TEXT,                                  -- p_name
    $5::TEXT,                                  -- p_description
    COALESCE($6::DECIMAL(5,2), 100.00),       -- p_ownership_percentage
    $7::UUID                                   -- p_created_by_user_id
);