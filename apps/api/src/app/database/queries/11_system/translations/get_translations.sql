/* @name getTranslations */
-- ================================================================
-- Converted from: sp_get_translations()
-- Type: Simple Read-Only Query with Search
-- Description: Retrieve translations with optional filters
-- Parameters:
--   $1: p_translation_key TEXT - Optional filter/search by translation key
--   $2: p_language_code TEXT - Optional filter by language code
--   $3: p_only_verified BOOLEAN - Only show verified translations (default FALSE)
--   $4: p_limit INTEGER - Maximum records to return (default 100)
--   $5: p_offset INTEGER - Pagination offset (default 0)
-- Returns: Translation records
-- ================================================================

-- This query retrieves translations with filtering and search capabilities
-- Supports partial text search on translation keys

SELECT 
    t.id as translation_id,
    t.translation_key,
    t.language_code::TEXT as language_code,
    t.translated_text,
    t.context_notes,
    t.is_verified,
    t.verified_by,
    t.verified_at,
    t.version,
    t.usage_count,
    t.last_used_at
FROM translations t
WHERE 
    ($1::TEXT IS NULL OR t.translation_key ILIKE '%' || $1 || '%')
    AND ($2::TEXT IS NULL OR t.language_code::TEXT = $2)
    AND (NOT COALESCE($3::BOOLEAN, FALSE) OR t.is_verified = TRUE)
ORDER BY t.translation_key, t.language_code
LIMIT COALESCE($4::INTEGER, 100)
OFFSET COALESCE($5::INTEGER, 0);