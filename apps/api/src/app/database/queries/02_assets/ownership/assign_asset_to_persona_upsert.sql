/* @name assignAssetToPersonaUpsert */
-- ================================================================
-- Converted from: sp_assign_asset_to_persona()
-- Type: UPSERT with conditional logic
-- Description: Assign or update asset-persona relationship
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_persona_id UUID - Persona ID  
--   $3: p_ownership_type ownership_type_enum - Ownership type (default 'owner')
--   $4: p_ownership_percentage DECIMAL(5,2) - Ownership percentage (default 100.00)
--   $5: p_is_primary BOOLEAN - Is primary owner (default FALSE)
--   $6: p_assigned_by UUID - User making assignment (optional)
-- Returns: Asset-persona record
-- NOTE: Service layer should:
--   1. Validate total ownership doesn't exceed 100%
--   2. Handle primary owner updates separately if needed
--   3. Create audit log entry
-- ================================================================

-- This query inserts a new asset-persona relationship
-- Service layer should check for existing relationship first and use UPDATE if needed
-- If is_primary is TRUE, a separate query should unset other primary assignments

INSERT INTO asset_persona (
    tenant_id,
    asset_id,
    persona_id,
    ownership_type,
    ownership_percentage,
    is_primary,
    created_at,
    updated_at,
    created_by,
    updated_by
) 
SELECT
    a.tenant_id,
    $1::UUID,
    $2::UUID,
    COALESCE($3::ownership_type_enum, 'owner'::ownership_type_enum),
    COALESCE($4::DECIMAL(5,2), 100.00),
    COALESCE($5::BOOLEAN, FALSE),
    NOW(),
    NOW(),
    COALESCE(
        $6::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    COALESCE(
        $6::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
FROM assets a
WHERE a.id = $1::UUID
  AND NOT EXISTS (
    SELECT 1 FROM asset_persona ap 
    WHERE ap.asset_id = $1::UUID 
      AND ap.persona_id = $2::UUID
  )
RETURNING 
    id,
    asset_id,
    persona_id,
    ownership_type,
    ownership_percentage,
    is_primary,
    updated_at;