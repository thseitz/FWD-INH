/* @name updateAssetValue */
-- ================================================================
-- Converted from: sp_update_asset_value()
-- Type: UPDATE with JSONB Append (Dual Operation - needs transaction)
-- Description: Update asset estimated value and append to valuation history
-- Parameters:
--   $1: p_asset_id UUID - Asset ID to update
--   $2: p_new_value DECIMAL(15,2) - New estimated value
--   $3: p_valuation_date DATE - Valuation date (default CURRENT_DATE)
--   $4: p_valuation_method VARCHAR(50) - Valuation method (default 'market')
--   $5: p_updated_by UUID - User performing update (optional)
-- Returns: Updated asset record
-- ================================================================

-- This query updates asset value and appends to valuation history in tags
-- NOTE: The audit log insert needs to be handled separately in the service layer
-- This is a dual operation that requires transaction handling

WITH current_asset AS (
    SELECT id, estimated_value, tags, tenant_id, name
    FROM assets
    WHERE id = $1::UUID
)
UPDATE assets SET
    estimated_value = $2::DECIMAL(15,2),
    last_valued_date = COALESCE($3::DATE, CURRENT_DATE),
    updated_at = NOW(),
    updated_by = COALESCE(
        $5::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    tags = tags || jsonb_build_object(
        'valuation_history', 
        COALESCE(tags->'valuation_history', '[]'::jsonb) || 
        jsonb_build_array(jsonb_build_object(
            'date', COALESCE($3::DATE, CURRENT_DATE),
            'value', $2::DECIMAL(15,2),
            'method', COALESCE($4::VARCHAR(50), 'market'),
            'previous_value', (SELECT estimated_value FROM current_asset),
            'updated_by', COALESCE(
                $5::UUID,
                CASE 
                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
                    THEN NULL
                    ELSE current_setting('app.current_user_id', true)::UUID
                END
            ),
            'updated_at', NOW()
        ))
    )
WHERE id = $1::UUID
RETURNING 
    id,
    name,
    estimated_value,
    last_valued_date,
    updated_at,
    tags->'valuation_history' as valuation_history;