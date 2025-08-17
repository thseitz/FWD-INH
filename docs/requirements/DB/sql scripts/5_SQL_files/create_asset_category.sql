-- ================================================================
-- Converted from: sp_create_asset_category()
-- Type: Single INSERT with Generated ID
-- Description: Create new asset category
-- Parameters:
--   $1: p_name VARCHAR(100) - Category name
--   $2: p_description TEXT - Category description (optional)
--   $3: p_icon VARCHAR(50) - Icon identifier (optional)
--   $4: p_sort_order INTEGER - Sort order (default 999)
-- Returns: Created category record
-- ================================================================

-- This query creates a new asset category
-- Generates UUID and derives code from name

INSERT INTO asset_categories (
    id,
    name,
    code,
    description,
    icon,
    sort_order,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    $1::VARCHAR(100),
    UPPER(REPLACE($1::VARCHAR(100), ' ', '_')),
    $2::TEXT,
    $3::VARCHAR(50),
    COALESCE($4::INTEGER, 999),
    TRUE,
    NOW(),
    NOW()
)
RETURNING 
    id,
    name,
    code,
    description,
    icon,
    sort_order,
    is_active;