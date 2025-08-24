/* @name getQuilttConnectedAccounts */
-- ================================================================
-- Name: get_quiltt_connected_accounts
-- Type: SELECT
-- Description: Get all Quiltt-connected financial accounts for a persona
-- Parameters:
--   $1: p_persona_id UUID - Persona ID
-- Returns: List of connected financial accounts
-- Used by: Account management and display
-- ================================================================

SELECT 
    fa.id,
    fa.asset_id,
    a.name as asset_name,
    fa.institution_name,
    fa.account_type,
    fa.account_number_last_four,
    fa.current_balance,
    fa.balance_as_of_date,
    fa.quiltt_account_id,
    fa.is_quiltt_connected,
    fa.last_quiltt_sync_at,
    fa.quiltt_sync_status,
    qi.connection_status,
    qi.last_sync_at as integration_last_sync
FROM financial_accounts fa
JOIN assets a ON fa.asset_id = a.id
JOIN asset_persona ap ON a.id = ap.asset_id
JOIN quiltt_integrations qi ON fa.quiltt_integration_id = qi.id
WHERE 
    ap.persona_id = $1::UUID
    AND fa.is_quiltt_connected = TRUE
    AND qi.is_active = TRUE
ORDER BY 
    fa.institution_name,
    fa.account_type;