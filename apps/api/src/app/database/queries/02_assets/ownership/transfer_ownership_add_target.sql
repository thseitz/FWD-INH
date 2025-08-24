/* @name transferOwnershipAddTarget */
-- ================================================================
-- Supporting query for: sp_transfer_asset_ownership() - Add to Target
-- Type: INSERT with ON CONFLICT UPDATE
-- Description: Add or increase ownership for target persona
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_to_persona_id UUID - Target persona ID
--   $3: p_transfer_percentage DECIMAL(5,2) - Percentage to add
--   $4: p_updated_by UUID - User making the transfer (optional)
-- Returns: Target ownership record
-- NOTE: Service layer should get tenant_id from asset first
-- ================================================================

-- Add or increase ownership for target persona
-- If target already has ownership, increase it; otherwise create new

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
    'owner'::ownership_type_enum,
    $3::DECIMAL(5,2),
    FALSE,
    NOW(),
    NOW(),
    COALESCE(
        $4::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    COALESCE(
        $4::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    )
FROM assets a
WHERE a.id = $1::UUID
ON CONFLICT (asset_id, persona_id) DO UPDATE SET
    ownership_percentage = asset_persona.ownership_percentage + EXCLUDED.ownership_percentage,
    updated_at = NOW(),
    updated_by = EXCLUDED.updated_by
RETURNING 
    asset_id,
    persona_id,
    ownership_percentage,
    updated_at;