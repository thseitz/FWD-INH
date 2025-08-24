/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/validate_quiltt_get_integration.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ValidateQuilttGetIntegration' parameters type */
export type IValidateQuilttGetIntegrationParams = void;

/** 'ValidateQuilttGetIntegration' return type */
export interface IValidateQuilttGetIntegrationResult {
  access_token_encrypted: string | null;
  id: string;
  is_active: boolean | null;
  last_sync_at: Date | null;
  persona_id: string;
  sync_accounts: boolean | null;
  sync_transactions: boolean | null;
  token_expires_at: Date | null;
}

/** 'ValidateQuilttGetIntegration' query type */
export interface IValidateQuilttGetIntegrationQuery {
  params: IValidateQuilttGetIntegrationParams;
  result: IValidateQuilttGetIntegrationResult;
}

const validateQuilttGetIntegrationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_validate_quiltt_credentials() - Part 1\n-- Type: SELECT \n-- Description: Get active Quiltt integration for validation\n-- Parameters:\n--   $1: p_user_id UUID - User ID\n-- Returns: Integration record with token details\n-- ================================================================\n\n-- Get active Quiltt integration for user\n\nSELECT \n    qi.id,\n    qi.persona_id,\n    qi.access_token_encrypted,\n    qi.token_expires_at,\n    qi.sync_accounts,\n    qi.sync_transactions,\n    qi.last_sync_at,\n    qi.is_active\nFROM quiltt_integrations qi\nJOIN personas p ON qi.persona_id = p.id\nWHERE p.user_id = $1::UUID \n  AND qi.is_active = TRUE"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_validate_quiltt_credentials() - Part 1
 * -- Type: SELECT 
 * -- Description: Get active Quiltt integration for validation
 * -- Parameters:
 * --   $1: p_user_id UUID - User ID
 * -- Returns: Integration record with token details
 * -- ================================================================
 * 
 * -- Get active Quiltt integration for user
 * 
 * SELECT 
 *     qi.id,
 *     qi.persona_id,
 *     qi.access_token_encrypted,
 *     qi.token_expires_at,
 *     qi.sync_accounts,
 *     qi.sync_transactions,
 *     qi.last_sync_at,
 *     qi.is_active
 * FROM quiltt_integrations qi
 * JOIN personas p ON qi.persona_id = p.id
 * WHERE p.user_id = $1::UUID 
 *   AND qi.is_active = TRUE
 * ```
 */
export const validateQuilttGetIntegration = new PreparedQuery<IValidateQuilttGetIntegrationParams,IValidateQuilttGetIntegrationResult>(validateQuilttGetIntegrationIR);


