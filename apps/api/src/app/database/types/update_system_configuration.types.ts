/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/configuration/update_system_configuration.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UpdateSystemConfiguration' parameters type */
export type IUpdateSystemConfigurationParams = void;

/** 'UpdateSystemConfiguration' return type */
export interface IUpdateSystemConfigurationResult {
  config_category: string;
  config_key: string;
  config_value: string | null;
  id: string;
  updated_at: Date | null;
}

/** 'UpdateSystemConfiguration' query type */
export interface IUpdateSystemConfigurationQuery {
  params: IUpdateSystemConfigurationParams;
  result: IUpdateSystemConfigurationResult;
}

const updateSystemConfigurationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_update_system_configuration()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Update system configuration setting\n-- Parameters:\n--   $1: p_config_key TEXT - Configuration key\n--   $2: p_config_value JSONB - Configuration value\n--   $3: p_config_category VARCHAR(50) - Category (default 'general')\n--   $4: p_description TEXT - Description (optional)\n--   $5: p_user_id UUID - User making change (optional)\n-- Returns: Configuration record\n-- NOTE: Service layer should handle audit logging separately\n-- ================================================================\n\n-- This query uses the masking_configurations table for system configs\n-- Using 'system' as the table_name for system configuration entries\n\nINSERT INTO masking_configurations (\n    tenant_id,\n    table_name,\n    column_name,\n    masking_type,\n    masking_pattern,\n    preserve_format,\n    apply_condition,\n    is_active,\n    created_at,\n    updated_at,\n    created_by,\n    updated_by\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    'system',\n    $1::TEXT,\n    COALESCE($3::VARCHAR(50), 'general'),\n    $2::TEXT,  -- JSONB converted to TEXT for storage\n    TRUE,\n    $4::TEXT,  -- description stored in apply_condition\n    TRUE,\n    NOW(),\n    NOW(),\n    COALESCE(\n        $5::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    COALESCE(\n        $5::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\n)\nON CONFLICT (tenant_id, table_name, column_name) \nDO UPDATE SET\n    masking_pattern = EXCLUDED.masking_pattern,\n    masking_type = EXCLUDED.masking_type,\n    updated_by = EXCLUDED.updated_by,\n    updated_at = NOW()\nRETURNING \n    id,\n    column_name as config_key,\n    masking_pattern as config_value,\n    masking_type as config_category,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_update_system_configuration()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Update system configuration setting
 * -- Parameters:
 * --   $1: p_config_key TEXT - Configuration key
 * --   $2: p_config_value JSONB - Configuration value
 * --   $3: p_config_category VARCHAR(50) - Category (default 'general')
 * --   $4: p_description TEXT - Description (optional)
 * --   $5: p_user_id UUID - User making change (optional)
 * -- Returns: Configuration record
 * -- NOTE: Service layer should handle audit logging separately
 * -- ================================================================
 * 
 * -- This query uses the masking_configurations table for system configs
 * -- Using 'system' as the table_name for system configuration entries
 * 
 * INSERT INTO masking_configurations (
 *     tenant_id,
 *     table_name,
 *     column_name,
 *     masking_type,
 *     masking_pattern,
 *     preserve_format,
 *     apply_condition,
 *     is_active,
 *     created_at,
 *     updated_at,
 *     created_by,
 *     updated_by
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     'system',
 *     $1::TEXT,
 *     COALESCE($3::VARCHAR(50), 'general'),
 *     $2::TEXT,  -- JSONB converted to TEXT for storage
 *     TRUE,
 *     $4::TEXT,  -- description stored in apply_condition
 *     TRUE,
 *     NOW(),
 *     NOW(),
 *     COALESCE(
 *         $5::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     COALESCE(
 *         $5::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * )
 * ON CONFLICT (tenant_id, table_name, column_name) 
 * DO UPDATE SET
 *     masking_pattern = EXCLUDED.masking_pattern,
 *     masking_type = EXCLUDED.masking_type,
 *     updated_by = EXCLUDED.updated_by,
 *     updated_at = NOW()
 * RETURNING 
 *     id,
 *     column_name as config_key,
 *     masking_pattern as config_value,
 *     masking_type as config_category,
 *     updated_at
 * ```
 */
export const updateSystemConfiguration = new PreparedQuery<IUpdateSystemConfigurationParams,IUpdateSystemConfigurationResult>(updateSystemConfigurationIR);


