/* @name updateAssetDetails */
-- ================================================================
-- Converted from: sp_update_asset()
-- Type: UPDATE with RETURNING
-- Description: Update asset with optional fields
-- Parameters:
--   $1: p_asset_id UUID - Asset ID to update
--   $2: p_name TEXT - New name (optional)
--   $3: p_description TEXT - New description (optional)
--   $4: p_estimated_value DECIMAL(15,2) - New value (optional)
--   $5: p_status status_enum - New status (optional)
--   $6: p_metadata JSONB - Additional metadata to merge (optional)
--   $7: p_updated_by UUID - User making update (optional)
-- Returns: Updated asset record
-- NOTE: Service layer should create audit log entry after successful update
-- ================================================================

-- Update asset with COALESCE for optional fields

UPDATE assets SET
    name = COALESCE($2::TEXT, name),
    description = COALESCE($3::TEXT, description),
    estimated_value = COALESCE($4::DECIMAL(15,2), estimated_value),
    status = COALESCE($5::status_enum, status),
    tags = CASE 
        WHEN $6::JSONB IS NOT NULL THEN COALESCE(tags, '{}'::JSONB) || $6::JSONB
        ELSE tags
    END,
    updated_at = NOW(),
    updated_by = COALESCE(
        $7::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
WHERE id = $1::UUID
RETURNING 
    id,
    tenant_id,
    name,
    description,
    estimated_value,
    status,
    tags,
    updated_at,
    updated_by;