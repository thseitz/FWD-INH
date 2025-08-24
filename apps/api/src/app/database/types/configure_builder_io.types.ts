/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/builder_io/configure_builder_io.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'ConfigureBuilderIo' parameters type */
export type IConfigureBuilderIoParams = void;

/** 'ConfigureBuilderIo' return type */
export interface IConfigureBuilderIoResult {
  environment: string | null;
  id: string;
  is_active: boolean | null;
  space_id: string;
  tenant_id: number;
}

/** 'ConfigureBuilderIo' query type */
export interface IConfigureBuilderIoQuery {
  params: IConfigureBuilderIoParams;
  result: IConfigureBuilderIoResult;
}

const configureBuilderIoIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_configure_builder_io()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Configure or update Builder.io integration\n-- Parameters:\n--   $1: p_api_key TEXT - Builder.io API key\n--   $2: p_space_id TEXT - Builder.io space ID\n--   $3: p_environment VARCHAR(20) - Environment (default 'production')\n--   $4: p_webhook_url TEXT - Webhook URL (optional, not used)\n--   $5: p_user_id UUID - User ID (optional)\n-- Returns: Integration record\n-- ================================================================\n\n-- This query creates or updates a Builder.io integration configuration\n-- Uses ON CONFLICT to handle updates to existing integrations\n\nINSERT INTO builder_io_integrations (\n    tenant_id,\n    api_key,\n    space_id,\n    environment,\n    is_active,\n    created_at,\n    updated_at\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    $1::TEXT,\n    $2::TEXT,\n    COALESCE($3::VARCHAR(20), 'production'),\n    TRUE,\n    NOW(),\n    NOW()\n)\nON CONFLICT (tenant_id, space_id) DO UPDATE SET\n    api_key = EXCLUDED.api_key,\n    space_id = EXCLUDED.space_id,\n    environment = EXCLUDED.environment,\n    is_active = TRUE,\n    updated_at = NOW()\nRETURNING \n    id,\n    tenant_id,\n    space_id,\n    environment,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_configure_builder_io()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Configure or update Builder.io integration
 * -- Parameters:
 * --   $1: p_api_key TEXT - Builder.io API key
 * --   $2: p_space_id TEXT - Builder.io space ID
 * --   $3: p_environment VARCHAR(20) - Environment (default 'production')
 * --   $4: p_webhook_url TEXT - Webhook URL (optional, not used)
 * --   $5: p_user_id UUID - User ID (optional)
 * -- Returns: Integration record
 * -- ================================================================
 * 
 * -- This query creates or updates a Builder.io integration configuration
 * -- Uses ON CONFLICT to handle updates to existing integrations
 * 
 * INSERT INTO builder_io_integrations (
 *     tenant_id,
 *     api_key,
 *     space_id,
 *     environment,
 *     is_active,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     $1::TEXT,
 *     $2::TEXT,
 *     COALESCE($3::VARCHAR(20), 'production'),
 *     TRUE,
 *     NOW(),
 *     NOW()
 * )
 * ON CONFLICT (tenant_id, space_id) DO UPDATE SET
 *     api_key = EXCLUDED.api_key,
 *     space_id = EXCLUDED.space_id,
 *     environment = EXCLUDED.environment,
 *     is_active = TRUE,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     tenant_id,
 *     space_id,
 *     environment,
 *     is_active
 * ```
 */
export const configureBuilderIo = new PreparedQuery<IConfigureBuilderIoParams,IConfigureBuilderIoResult>(configureBuilderIoIR);


