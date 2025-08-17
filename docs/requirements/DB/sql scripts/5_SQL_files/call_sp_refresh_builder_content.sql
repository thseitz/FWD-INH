-- ================================================================
-- Wrapper for: sp_refresh_builder_content()
-- Type: FUNCTION call wrapper
-- Description: Refresh content from Builder.io
-- Parameters:
--   $1: p_space_id TEXT - Builder.io space ID
--   $2: p_model_name VARCHAR - Model name (optional)
--   $3: p_content_ids TEXT[] - Content IDs (optional)
-- Returns: Refresh results
-- ================================================================

-- Call stored procedure to refresh Builder.io content

SELECT * FROM sp_refresh_builder_content(
    $1::TEXT,                      -- p_space_id
    $2::VARCHAR,                   -- p_model_name (optional)
    $3::TEXT[]                     -- p_content_ids (optional)
);