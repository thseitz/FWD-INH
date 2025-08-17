-- ================================================================
-- Converted from: sp_manage_translation() - CREATE action
-- Type: Single INSERT
-- Description: Create a new translation
-- Parameters:
--   $1: p_translation_key TEXT - Translation key
--   $2: p_language_code TEXT - Language code
--   $3: p_translated_text TEXT - Translated text
--   $4: p_context_notes TEXT - Context notes (optional)
--   $5: p_is_verified BOOLEAN - Is verified (default FALSE)
--   $6: p_user_id UUID - User ID (optional)
-- Returns: Created translation record
-- ================================================================

-- This query creates a new translation
-- Sets verified_by and verified_at based on is_verified flag

INSERT INTO translations (
    translation_key,
    language_code,
    translated_text,
    context_notes,
    is_verified,
    verified_by,
    verified_at,
    created_by,
    version
) VALUES (
    $1::TEXT,
    $2::language_code_enum,
    $3::TEXT,
    $4::TEXT,
    COALESCE($5::BOOLEAN, FALSE),
    CASE 
        WHEN COALESCE($5::BOOLEAN, FALSE) THEN 
            COALESCE(
                $6::UUID,
                CASE 
                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
                    THEN NULL
                    ELSE current_setting('app.current_user_id', true)::UUID
                END
            )
        ELSE NULL 
    END,
    CASE WHEN COALESCE($5::BOOLEAN, FALSE) THEN NOW() ELSE NULL END,
    COALESCE(
        $6::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    1
)
RETURNING 
    id,
    translation_key,
    language_code,
    translated_text,
    is_verified,
    version;