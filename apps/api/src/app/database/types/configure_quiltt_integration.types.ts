/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/quiltt/configure_quiltt_integration.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ConfigureQuilttIntegration' parameters type */
export type IConfigureQuilttIntegrationParams = void;

/** 'ConfigureQuilttIntegration' return type */
export interface IConfigureQuilttIntegrationResult {
  id: string;
  is_active: boolean | null;
  persona_id: string;
  quiltt_connection_id: string;
  quiltt_user_id: string;
  tenant_id: number;
  token_expires_at: Date | null;
}

/** 'ConfigureQuilttIntegration' query type */
export interface IConfigureQuilttIntegrationQuery {
  params: IConfigureQuilttIntegrationParams;
  result: IConfigureQuilttIntegrationResult;
}

const configureQuilttIntegrationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_configure_quiltt_integration()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Configure or update Quiltt integration for a persona\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n--   $2: p_access_token TEXT - Access token\n--   $3: p_quiltt_connection_id TEXT - Quiltt connection ID\n--   $4: p_refresh_token TEXT - Refresh token (optional)\n--   $5: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)\n-- Returns: Integration record\n-- NOTE: Audit log insert should be handled separately in service layer\n-- ================================================================\n\n-- This query creates or updates a Quiltt integration configuration\n-- Uses ON CONFLICT to handle updates to existing integrations\n\nINSERT INTO quiltt_integrations (\n    tenant_id,\n    persona_id,\n    quiltt_user_id,\n    quiltt_connection_id,\n    quiltt_profile_id,\n    access_token_encrypted,\n    refresh_token_encrypted,\n    token_expires_at,\n    is_active\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    $1::UUID,\n    $5::TEXT,\n    $3::TEXT,\n    $5::TEXT,  -- quiltt_profile_id same as quiltt_user_id\n    $2::TEXT,\n    $4::TEXT,\n    (NOW() + INTERVAL '30 days'),\n    TRUE\n)\nON CONFLICT (tenant_id, persona_id) DO UPDATE SET\n    quiltt_connection_id = EXCLUDED.quiltt_connection_id,\n    quiltt_user_id = EXCLUDED.quiltt_user_id,\n    quiltt_profile_id = EXCLUDED.quiltt_profile_id,\n    access_token_encrypted = EXCLUDED.access_token_encrypted,\n    refresh_token_encrypted = EXCLUDED.refresh_token_encrypted,\n    token_expires_at = EXCLUDED.token_expires_at,\n    is_active = TRUE,\n    updated_at = NOW()\nRETURNING \n    id,\n    tenant_id,\n    persona_id,\n    quiltt_user_id,\n    quiltt_connection_id,\n    is_active,\n    token_expires_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_configure_quiltt_integration()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Configure or update Quiltt integration for a persona
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * --   $2: p_access_token TEXT - Access token
 * --   $3: p_quiltt_connection_id TEXT - Quiltt connection ID
 * --   $4: p_refresh_token TEXT - Refresh token (optional)
 * --   $5: p_quiltt_user_id TEXT - Quiltt user ID (same as persona_id)
 * -- Returns: Integration record
 * -- NOTE: Audit log insert should be handled separately in service layer
 * -- ================================================================
 * 
 * -- This query creates or updates a Quiltt integration configuration
 * -- Uses ON CONFLICT to handle updates to existing integrations
 * 
 * INSERT INTO quiltt_integrations (
 *     tenant_id,
 *     persona_id,
 *     quiltt_user_id,
 *     quiltt_connection_id,
 *     quiltt_profile_id,
 *     access_token_encrypted,
 *     refresh_token_encrypted,
 *     token_expires_at,
 *     is_active
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     $1::UUID,
 *     $5::TEXT,
 *     $3::TEXT,
 *     $5::TEXT,  -- quiltt_profile_id same as quiltt_user_id
 *     $2::TEXT,
 *     $4::TEXT,
 *     (NOW() + INTERVAL '30 days'),
 *     TRUE
 * )
 * ON CONFLICT (tenant_id, persona_id) DO UPDATE SET
 *     quiltt_connection_id = EXCLUDED.quiltt_connection_id,
 *     quiltt_user_id = EXCLUDED.quiltt_user_id,
 *     quiltt_profile_id = EXCLUDED.quiltt_profile_id,
 *     access_token_encrypted = EXCLUDED.access_token_encrypted,
 *     refresh_token_encrypted = EXCLUDED.refresh_token_encrypted,
 *     token_expires_at = EXCLUDED.token_expires_at,
 *     is_active = TRUE,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     tenant_id,
 *     persona_id,
 *     quiltt_user_id,
 *     quiltt_connection_id,
 *     is_active,
 *     token_expires_at
 * ```
 */
export const configureQuilttIntegration = new PreparedQuery<IConfigureQuilttIntegrationParams,IConfigureQuilttIntegrationResult>(configureQuilttIntegrationIR);


