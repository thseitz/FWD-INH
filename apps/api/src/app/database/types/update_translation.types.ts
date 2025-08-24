/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/translations/update_translation.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type language_code_enum = 'ar' | 'de' | 'en' | 'es' | 'fr' | 'hi' | 'ja' | 'ko' | 'pt' | 'ru' | 'zh';

/** 'UpdateTranslation' parameters type */
export type IUpdateTranslationParams = void;

/** 'UpdateTranslation' return type */
export interface IUpdateTranslationResult {
  id: string;
  is_verified: boolean | null;
  language_code: language_code_enum;
  translated_text: string;
  translation_key: string;
  version: number | null;
}

/** 'UpdateTranslation' query type */
export interface IUpdateTranslationQuery {
  params: IUpdateTranslationParams;
  result: IUpdateTranslationResult;
}

const updateTranslationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_manage_translation() - UPDATE action\n-- Type: Single UPDATE\n-- Description: Update an existing translation\n-- Parameters:\n--   $1: p_translation_id UUID - Translation ID to update\n--   $2: p_translated_text TEXT - New translated text (optional)\n--   $3: p_context_notes TEXT - New context notes (optional)\n--   $4: p_is_verified BOOLEAN - Is verified\n--   $5: p_user_id UUID - User ID (optional)\n-- Returns: Updated translation record\n-- ================================================================\n\n-- This query updates an existing translation\n-- Increments version and conditionally sets verification fields\n\nUPDATE translations SET\n    translated_text = COALESCE($2::TEXT, translated_text),\n    context_notes = COALESCE($3::TEXT, context_notes),\n    is_verified = $4::BOOLEAN,\n    verified_by = CASE \n        WHEN $4::BOOLEAN THEN \n            COALESCE(\n                $5::UUID,\n                CASE \n                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n                    THEN NULL\n                    ELSE current_setting('app.current_user_id', true)::UUID\n                END\n            )\n        ELSE verified_by \n    END,\n    verified_at = CASE WHEN $4::BOOLEAN THEN NOW() ELSE verified_at END,\n    updated_at = NOW(),\n    updated_by = COALESCE(\n        $5::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    version = version + 1\nWHERE id = $1::UUID\nRETURNING \n    id,\n    translation_key,\n    language_code,\n    translated_text,\n    is_verified,\n    version"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_manage_translation() - UPDATE action
 * -- Type: Single UPDATE
 * -- Description: Update an existing translation
 * -- Parameters:
 * --   $1: p_translation_id UUID - Translation ID to update
 * --   $2: p_translated_text TEXT - New translated text (optional)
 * --   $3: p_context_notes TEXT - New context notes (optional)
 * --   $4: p_is_verified BOOLEAN - Is verified
 * --   $5: p_user_id UUID - User ID (optional)
 * -- Returns: Updated translation record
 * -- ================================================================
 * 
 * -- This query updates an existing translation
 * -- Increments version and conditionally sets verification fields
 * 
 * UPDATE translations SET
 *     translated_text = COALESCE($2::TEXT, translated_text),
 *     context_notes = COALESCE($3::TEXT, context_notes),
 *     is_verified = $4::BOOLEAN,
 *     verified_by = CASE 
 *         WHEN $4::BOOLEAN THEN 
 *             COALESCE(
 *                 $5::UUID,
 *                 CASE 
 *                     WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *                     THEN NULL
 *                     ELSE current_setting('app.current_user_id', true)::UUID
 *                 END
 *             )
 *         ELSE verified_by 
 *     END,
 *     verified_at = CASE WHEN $4::BOOLEAN THEN NOW() ELSE verified_at END,
 *     updated_at = NOW(),
 *     updated_by = COALESCE(
 *         $5::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     version = version + 1
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     translation_key,
 *     language_code,
 *     translated_text,
 *     is_verified,
 *     version
 * ```
 */
export const updateTranslation = new PreparedQuery<IUpdateTranslationParams,IUpdateTranslationResult>(updateTranslationIR);


