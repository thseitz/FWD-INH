/** Types generated for queries found in "apps/api/src/app/database/queries/03_financial/accounts/create_financial_account_from_quiltt.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type account_type_enum = 'business_account' | 'checking' | 'college_529' | 'college_coverdell' | 'cryptocurrency' | 'hsa' | 'investment' | 'retirement_401k' | 'retirement_ira' | 'retirement_pension' | 'retirement_roth' | 'savings' | 'trust_account';

/** 'CreateFinancialAccountFromQuiltt' parameters type */
export type ICreateFinancialAccountFromQuilttParams = void;

/** 'CreateFinancialAccountFromQuiltt' return type */
export interface ICreateFinancialAccountFromQuilttResult {
  account_type: account_type_enum;
  asset_id: string;
  current_balance: string | null;
  id: string;
  institution_name: string;
  is_quiltt_connected: boolean | null;
  quiltt_account_id: string | null;
}

/** 'CreateFinancialAccountFromQuiltt' query type */
export interface ICreateFinancialAccountFromQuilttQuery {
  params: ICreateFinancialAccountFromQuilttParams;
  result: ICreateFinancialAccountFromQuilttResult;
}

const createFinancialAccountFromQuilttIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: create_financial_account_from_quiltt\n-- Type: INSERT\n-- Description: Create financial account from Quiltt account data\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_institution_name TEXT - Institution name\n--   $3: p_account_type TEXT - Account type\n--   $4: p_account_last_four VARCHAR(4) - Last 4 digits of account\n--   $5: p_current_balance DECIMAL - Current balance\n--   $6: p_quiltt_integration_id UUID - Quiltt integration ID\n--   $7: p_quiltt_account_id TEXT - Quiltt account ID\n-- Returns: Created financial account\n-- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()\n-- ================================================================\n\nINSERT INTO financial_accounts (\n    asset_id,\n    institution_name,\n    account_type,\n    account_number_last_four,\n    current_balance,\n    balance_as_of_date,\n    quiltt_integration_id,\n    quiltt_account_id,\n    quiltt_connection_id,\n    is_quiltt_connected,\n    last_quiltt_sync_at,\n    quiltt_sync_status\n) VALUES (\n    $1::UUID,\n    $2::TEXT,\n    $3::account_type_enum,\n    $4::VARCHAR(4),\n    $5::DECIMAL(15,2),\n    NOW()::DATE,\n    $6::UUID,\n    $7::TEXT,\n    (SELECT quiltt_connection_id FROM quiltt_integrations WHERE id = $6::UUID),\n    TRUE,\n    NOW(),\n    'completed'::sync_status_enum\n)\nRETURNING \n    id,\n    asset_id,\n    institution_name,\n    account_type,\n    current_balance,\n    is_quiltt_connected,\n    quiltt_account_id"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: create_financial_account_from_quiltt
 * -- Type: INSERT
 * -- Description: Create financial account from Quiltt account data
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_institution_name TEXT - Institution name
 * --   $3: p_account_type TEXT - Account type
 * --   $4: p_account_last_four VARCHAR(4) - Last 4 digits of account
 * --   $5: p_current_balance DECIMAL - Current balance
 * --   $6: p_quiltt_integration_id UUID - Quiltt integration ID
 * --   $7: p_quiltt_account_id TEXT - Quiltt account ID
 * -- Returns: Created financial account
 * -- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()
 * -- ================================================================
 * 
 * INSERT INTO financial_accounts (
 *     asset_id,
 *     institution_name,
 *     account_type,
 *     account_number_last_four,
 *     current_balance,
 *     balance_as_of_date,
 *     quiltt_integration_id,
 *     quiltt_account_id,
 *     quiltt_connection_id,
 *     is_quiltt_connected,
 *     last_quiltt_sync_at,
 *     quiltt_sync_status
 * ) VALUES (
 *     $1::UUID,
 *     $2::TEXT,
 *     $3::account_type_enum,
 *     $4::VARCHAR(4),
 *     $5::DECIMAL(15,2),
 *     NOW()::DATE,
 *     $6::UUID,
 *     $7::TEXT,
 *     (SELECT quiltt_connection_id FROM quiltt_integrations WHERE id = $6::UUID),
 *     TRUE,
 *     NOW(),
 *     'completed'::sync_status_enum
 * )
 * RETURNING 
 *     id,
 *     asset_id,
 *     institution_name,
 *     account_type,
 *     current_balance,
 *     is_quiltt_connected,
 *     quiltt_account_id
 * ```
 */
export const createFinancialAccountFromQuiltt = new PreparedQuery<ICreateFinancialAccountFromQuilttParams,ICreateFinancialAccountFromQuilttResult>(createFinancialAccountFromQuilttIR);


