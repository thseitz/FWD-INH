/** Types generated for queries found in "apps/api/src/app/database/queries/03_financial/accounts/get_quiltt_connected_accounts.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type account_type_enum = 'business_account' | 'checking' | 'college_529' | 'college_coverdell' | 'cryptocurrency' | 'hsa' | 'investment' | 'retirement_401k' | 'retirement_ira' | 'retirement_pension' | 'retirement_roth' | 'savings' | 'trust_account';

export type integration_status_enum = 'connected' | 'disconnected' | 'error' | 'expired' | 'pending';

export type sync_status_enum = 'completed' | 'failed' | 'in_progress' | 'partial' | 'pending';

/** 'GetQuilttConnectedAccounts' parameters type */
export type IGetQuilttConnectedAccountsParams = void;

/** 'GetQuilttConnectedAccounts' return type */
export interface IGetQuilttConnectedAccountsResult {
  account_number_last_four: string | null;
  account_type: account_type_enum;
  asset_id: string;
  asset_name: string;
  balance_as_of_date: Date | null;
  connection_status: integration_status_enum | null;
  current_balance: string | null;
  id: string;
  institution_name: string;
  integration_last_sync: Date | null;
  is_quiltt_connected: boolean | null;
  last_quiltt_sync_at: Date | null;
  quiltt_account_id: string | null;
  quiltt_sync_status: sync_status_enum | null;
}

/** 'GetQuilttConnectedAccounts' query type */
export interface IGetQuilttConnectedAccountsQuery {
  params: IGetQuilttConnectedAccountsParams;
  result: IGetQuilttConnectedAccountsResult;
}

const getQuilttConnectedAccountsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: get_quiltt_connected_accounts\n-- Type: SELECT\n-- Description: Get all Quiltt-connected financial accounts for a persona\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n-- Returns: List of connected financial accounts\n-- Used by: Account management and display\n-- ================================================================\n\nSELECT \n    fa.id,\n    fa.asset_id,\n    a.name as asset_name,\n    fa.institution_name,\n    fa.account_type,\n    fa.account_number_last_four,\n    fa.current_balance,\n    fa.balance_as_of_date,\n    fa.quiltt_account_id,\n    fa.is_quiltt_connected,\n    fa.last_quiltt_sync_at,\n    fa.quiltt_sync_status,\n    qi.connection_status,\n    qi.last_sync_at as integration_last_sync\nFROM financial_accounts fa\nJOIN assets a ON fa.asset_id = a.id\nJOIN asset_persona ap ON a.id = ap.asset_id\nJOIN quiltt_integrations qi ON fa.quiltt_integration_id = qi.id\nWHERE \n    ap.persona_id = $1::UUID\n    AND fa.is_quiltt_connected = TRUE\n    AND qi.is_active = TRUE\nORDER BY \n    fa.institution_name,\n    fa.account_type"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: get_quiltt_connected_accounts
 * -- Type: SELECT
 * -- Description: Get all Quiltt-connected financial accounts for a persona
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * -- Returns: List of connected financial accounts
 * -- Used by: Account management and display
 * -- ================================================================
 * 
 * SELECT 
 *     fa.id,
 *     fa.asset_id,
 *     a.name as asset_name,
 *     fa.institution_name,
 *     fa.account_type,
 *     fa.account_number_last_four,
 *     fa.current_balance,
 *     fa.balance_as_of_date,
 *     fa.quiltt_account_id,
 *     fa.is_quiltt_connected,
 *     fa.last_quiltt_sync_at,
 *     fa.quiltt_sync_status,
 *     qi.connection_status,
 *     qi.last_sync_at as integration_last_sync
 * FROM financial_accounts fa
 * JOIN assets a ON fa.asset_id = a.id
 * JOIN asset_persona ap ON a.id = ap.asset_id
 * JOIN quiltt_integrations qi ON fa.quiltt_integration_id = qi.id
 * WHERE 
 *     ap.persona_id = $1::UUID
 *     AND fa.is_quiltt_connected = TRUE
 *     AND qi.is_active = TRUE
 * ORDER BY 
 *     fa.institution_name,
 *     fa.account_type
 * ```
 */
export const getQuilttConnectedAccounts = new PreparedQuery<IGetQuilttConnectedAccountsParams,IGetQuilttConnectedAccountsResult>(getQuilttConnectedAccountsIR);


