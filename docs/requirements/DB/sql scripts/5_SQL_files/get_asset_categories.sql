-- ================================================================
-- Converted from: sp_get_asset_categories(p_include_inactive BOOLEAN)
-- Type: Simple Read-Only Query
-- Description: Get list of asset categories
-- Parameters:
--   $1: p_include_inactive BOOLEAN - Whether to include inactive categories (default FALSE)
-- Returns: Table of category information
-- ================================================================

-- This query retrieves all asset categories from the system
-- By default only returns active categories unless p_include_inactive is TRUE

SELECT 
    ac.id as category_id,
    ac.name::VARCHAR as category_name,
    ac.description as category_description,
    ac.icon::VARCHAR as category_icon,
    ac.sort_order,
    ac.is_active
FROM asset_categories ac
WHERE ac.is_active = TRUE OR COALESCE($1::BOOLEAN, FALSE) = TRUE
ORDER BY ac.sort_order, ac.name;