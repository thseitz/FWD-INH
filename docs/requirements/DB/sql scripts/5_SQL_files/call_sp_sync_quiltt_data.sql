-- ================================================================
-- Wrapper for: sp_sync_quiltt_data()
-- Type: FUNCTION call wrapper
-- Description: Sync data from Quiltt financial API
-- Parameters:
--   $1: p_user_id UUID - User ID
--   $2: p_sync_type VARCHAR - Type of sync (default 'full')
--   $3: p_data_categories JSONB - Data categories (default '["accounts", "transactions", "documents"]')
-- Returns: Sync results
-- ================================================================

-- Call stored procedure to sync Quiltt data

SELECT * FROM sp_sync_quiltt_data(
    $1::UUID,                                                              -- p_user_id
    COALESCE($2::VARCHAR, 'full'),                                        -- p_sync_type
    COALESCE($3::JSONB, '["accounts", "transactions", "documents"]'::JSONB) -- p_data_categories
);