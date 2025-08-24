/* @name updateHeiStatus */
-- ================================================================
-- Update HEI Status SQL
-- Type: UPDATE
-- Description: Update HEI status for lifecycle management
-- Parameters:
--   $1: hei_asset_id UUID - HEI asset ID
--   $2: new_status hei_status_enum - New status value
--   $3: notes TEXT - Optional status change notes
-- Returns: Updated HEI record
-- ================================================================

UPDATE hei_assets SET
    hei_status = $2::hei_status_enum,
    updated_at = NOW(),
    updated_by = current_user_id()
WHERE asset_id = $1::UUID

RETURNING 
    id,
    asset_id,
    amount_funded,
    equity_share_pct,
    effective_date,
    property_asset_id,
    hei_status,
    source_system,
    source_application_id,
    updated_at;