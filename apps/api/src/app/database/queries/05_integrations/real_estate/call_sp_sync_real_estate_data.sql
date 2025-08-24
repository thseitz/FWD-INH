/* @name callSpSyncRealEstateData */
-- ================================================================
-- Wrapper for: sp_sync_real_estate_data()
-- Type: FUNCTION call wrapper
-- Description: Sync real estate data from provider
-- Parameters:
--   $1: p_provider VARCHAR - Provider name (default 'zillow')
--   $2: p_property_ids UUID[] - Property IDs (optional)
--   $3: p_sync_all BOOLEAN - Sync all properties (default false)
--   $4: p_user_id UUID - User ID (optional)
-- Returns: Sync results
-- ================================================================

-- Call stored procedure to sync real estate data

SELECT * FROM sp_sync_real_estate_data(
    COALESCE($1::VARCHAR, 'zillow'),    -- p_provider
    $2::UUID[],                          -- p_property_ids (optional)
    COALESCE($3::BOOLEAN, FALSE),       -- p_sync_all
    $4::UUID                             -- p_user_id (optional)
);