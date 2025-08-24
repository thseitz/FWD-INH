/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/translations/create_translation.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type language_code_enum = 'ar' | 'de' | 'en' | 'es' | 'fr' | 'hi' | 'ja' | 'ko' | 'pt' | 'ru' | 'zh';

/** 'CreateTranslation' parameters type */
export type ICreateTranslationParams = void;

/** 'CreateTranslation' return type */
export interface ICreateTranslationResult {
  id: string;
  is_verified: boolean | null;
  language_code: language_code_enum;
  translated_text: string;
  translation_key: string;
  version: number | null;
}

/** 'CreateTranslation' query type */
export interface ICreateTranslationQuery {
  params: ICreateTranslationParams;
  result: ICreateTranslationResult;
}

const createTranslationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_manage_translation() - CREATE action\n-- Type: Single INSERT\n-- Description: Create a new translation\n-- Parameters:\n--   $1: p_translation_key TEXT - Translation key\n--   $2: p_language_code TEXT - Language code\n--   $3: p_translated_text TEXT - Translated text\n--   $4: p_context_notes TEXT - Context notes (optional)\n--   $5: p_is_verified BOOLEAN - Is verified (default FALSE)\n--   $6: p_user_id UUID - User ID (optional)\n-- Returns: Created translation record\n-- ================================================================\n\n-- This query creates a new translation\n-- Sets verified_by and verified_at based on is_verified flag\n\nINSERT INTO translations (\n    translation_key,\n    language_code,\n    translated_text,\n    context_notes,\n    is_verified,\n    verified_by,\n    verified_at,\n    created_by,\n    version\n) VALUES (\n    $1::TEXT,\n    $2::language_code_enum,\n    $3::TEXT,\n    $4::TEXT,\n    COALESCE($5::BOOLEAN, FALSE),\n    CASE \n        WHEN COALESCE($5::BOOLEAN, FALSE) THEN \n            COALESCE(\n                $6::UUID,\n                CASE \n                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n                    THEN NULL\n                    ELSE current_setting('app.current_user_id', true)::UUID\n                END\n            )\n        ELSE NULL \n    END,\n    CASE WHEN COALESCE($5::BOOLEAN, FALSE) THEN NOW() ELSE NULL END,\n    COALESCE(\n        $6::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    1\n)\nRETURNING \n    id,\n    translation_key,\n    language_code,\n    translated_text,\n    is_verified,\n    version"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_manage_translation() - CREATE action
 * -- Type: Single INSERT
 * -- Description: Create a new translation
 * -- Parameters:
 * --   $1: p_translation_key TEXT - Translation key
 * --   $2: p_language_code TEXT - Language code
 * --   $3: p_translated_text TEXT - Translated text
 * --   $4: p_context_notes TEXT - Context notes (optional)
 * --   $5: p_is_verified BOOLEAN - Is verified (default FALSE)
 * --   $6: p_user_id UUID - User ID (optional)
 * -- Returns: Created translation record
 * -- ================================================================
 * 
 * -- This query creates a new translation
 * -- Sets verified_by and verified_at based on is_verified flag
 * 
 * INSERT INTO translations (
 *     translation_key,
 *     language_code,
 *     translated_text,
 *     context_notes,
 *     is_verified,
 *     verified_by,
 *     verified_at,
 *     created_by,
 *     version
 * ) VALUES (
 *     $1::TEXT,
 *     $2::language_code_enum,
 *     $3::TEXT,
 *     $4::TEXT,
 *     COALESCE($5::BOOLEAN, FALSE),
 *     CASE 
 *         WHEN COALESCE($5::BOOLEAN, FALSE) THEN 
 *             COALESCE(
 *                 $6::UUID,
 *                 CASE 
 *                     WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *                     THEN NULL
 *                     ELSE current_setting('app.current_user_id', true)::UUID
 *                 END
 *             )
 *         ELSE NULL 
 *     END,
 *     CASE WHEN COALESCE($5::BOOLEAN, FALSE) THEN NOW() ELSE NULL END,
 *     COALESCE(
 *         $6::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     1
 * )
 * RETURNING 
 *     id,
 *     translation_key,
 *     language_code,
 *     translated_text,
 *     is_verified,
 *     version
 * ```
 */
export const createTranslation = new PreparedQuery<ICreateTranslationParams,ICreateTranslationResult>(createTranslationIR);


