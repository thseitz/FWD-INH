/* @name createFinancialAccountFromQuiltt */
-- ================================================================
-- Name: create_financial_account_from_quiltt
-- Type: INSERT
-- Description: Create financial account from Quiltt account data
-- Parameters:
--   $1: p_asset_id UUID - Asset ID
--   $2: p_institution_name TEXT - Institution name
--   $3: p_account_type TEXT - Account type
--   $4: p_account_last_four VARCHAR(4) - Last 4 digits of account
--   $5: p_current_balance DECIMAL - Current balance
--   $6: p_quiltt_integration_id UUID - Quiltt integration ID
--   $7: p_quiltt_account_id TEXT - Quiltt account ID
-- Returns: Created financial account
-- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()
-- ================================================================

INSERT INTO financial_accounts (
    asset_id,
    institution_name,
    account_type,
    account_number_last_four,
    current_balance,
    balance_as_of_date,
    quiltt_integration_id,
    quiltt_account_id,
    quiltt_connection_id,
    is_quiltt_connected,
    last_quiltt_sync_at,
    quiltt_sync_status
) VALUES (
    $1::UUID,
    $2::TEXT,
    $3::account_type_enum,
    $4::VARCHAR(4),
    $5::DECIMAL(15,2),
    NOW()::DATE,
    $6::UUID,
    $7::TEXT,
    (SELECT quiltt_connection_id FROM quiltt_integrations WHERE id = $6::UUID),
    TRUE,
    NOW(),
    'completed'::sync_status_enum
)
RETURNING 
    id,
    asset_id,
    institution_name,
    account_type,
    current_balance,
    is_quiltt_connected,
    quiltt_account_id;