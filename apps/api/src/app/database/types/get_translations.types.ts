/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/translations/get_translations.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetTranslations' parameters type */
export type IGetTranslationsParams = void;

/** 'GetTranslations' return type */
export interface IGetTranslationsResult {
  context_notes: string | null;
  is_verified: boolean | null;
  language_code: string | null;
  last_used_at: Date | null;
  translated_text: string;
  translation_id: string;
  translation_key: string;
  usage_count: number | null;
  verified_at: Date | null;
  verified_by: string | null;
  version: number | null;
}

/** 'GetTranslations' query type */
export interface IGetTranslationsQuery {
  params: IGetTranslationsParams;
  result: IGetTranslationsResult;
}

const getTranslationsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_translations()\n-- Type: Simple Read-Only Query with Search\n-- Description: Retrieve translations with optional filters\n-- Parameters:\n--   $1: p_translation_key TEXT - Optional filter/search by translation key\n--   $2: p_language_code TEXT - Optional filter by language code\n--   $3: p_only_verified BOOLEAN - Only show verified translations (default FALSE)\n--   $4: p_limit INTEGER - Maximum records to return (default 100)\n--   $5: p_offset INTEGER - Pagination offset (default 0)\n-- Returns: Translation records\n-- ================================================================\n\n-- This query retrieves translations with filtering and search capabilities\n-- Supports partial text search on translation keys\n\nSELECT \n    t.id as translation_id,\n    t.translation_key,\n    t.language_code::TEXT as language_code,\n    t.translated_text,\n    t.context_notes,\n    t.is_verified,\n    t.verified_by,\n    t.verified_at,\n    t.version,\n    t.usage_count,\n    t.last_used_at\nFROM translations t\nWHERE \n    ($1::TEXT IS NULL OR t.translation_key ILIKE '%' || $1 || '%')\n    AND ($2::TEXT IS NULL OR t.language_code::TEXT = $2)\n    AND (NOT COALESCE($3::BOOLEAN, FALSE) OR t.is_verified = TRUE)\nORDER BY t.translation_key, t.language_code\nLIMIT COALESCE($4::INTEGER, 100)\nOFFSET COALESCE($5::INTEGER, 0)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_translations()
 * -- Type: Simple Read-Only Query with Search
 * -- Description: Retrieve translations with optional filters
 * -- Parameters:
 * --   $1: p_translation_key TEXT - Optional filter/search by translation key
 * --   $2: p_language_code TEXT - Optional filter by language code
 * --   $3: p_only_verified BOOLEAN - Only show verified translations (default FALSE)
 * --   $4: p_limit INTEGER - Maximum records to return (default 100)
 * --   $5: p_offset INTEGER - Pagination offset (default 0)
 * -- Returns: Translation records
 * -- ================================================================
 * 
 * -- This query retrieves translations with filtering and search capabilities
 * -- Supports partial text search on translation keys
 * 
 * SELECT 
 *     t.id as translation_id,
 *     t.translation_key,
 *     t.language_code::TEXT as language_code,
 *     t.translated_text,
 *     t.context_notes,
 *     t.is_verified,
 *     t.verified_by,
 *     t.verified_at,
 *     t.version,
 *     t.usage_count,
 *     t.last_used_at
 * FROM translations t
 * WHERE 
 *     ($1::TEXT IS NULL OR t.translation_key ILIKE '%' || $1 || '%')
 *     AND ($2::TEXT IS NULL OR t.language_code::TEXT = $2)
 *     AND (NOT COALESCE($3::BOOLEAN, FALSE) OR t.is_verified = TRUE)
 * ORDER BY t.translation_key, t.language_code
 * LIMIT COALESCE($4::INTEGER, 100)
 * OFFSET COALESCE($5::INTEGER, 0)
 * ```
 */
export const getTranslations = new PreparedQuery<IGetTranslationsParams,IGetTranslationsResult>(getTranslationsIR);


