-- ================================================================
-- Converted from: sp_manage_translation() - UPDATE action
-- Type: Single UPDATE
-- Description: Update an existing translation
-- Parameters:
--   $1: p_translation_id UUID - Translation ID to update
--   $2: p_translated_text TEXT - New translated text (optional)
--   $3: p_context_notes TEXT - New context notes (optional)
--   $4: p_is_verified BOOLEAN - Is verified
--   $5: p_user_id UUID - User ID (optional)
-- Returns: Updated translation record
-- ================================================================

-- This query updates an existing translation
-- Increments version and conditionally sets verification fields

UPDATE translations SET
    translated_text = COALESCE($2::TEXT, translated_text),
    context_notes = COALESCE($3::TEXT, context_notes),
    is_verified = $4::BOOLEAN,
    verified_by = CASE 
        WHEN $4::BOOLEAN THEN 
            COALESCE(
                $5::UUID,
                CASE 
                    WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
                    THEN NULL
                    ELSE current_setting('app.current_user_id', true)::UUID
                END
            )
        ELSE verified_by 
    END,
    verified_at = CASE WHEN $4::BOOLEAN THEN NOW() ELSE verified_at END,
    updated_at = NOW(),
    updated_by = COALESCE(
        $5::UUID,
        CASE 
            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
            THEN NULL
            ELSE current_setting('app.current_user_id', true)::UUID
        END
    ),
    version = version + 1
WHERE id = $1::UUID
RETURNING 
    id,
    translation_key,
    language_code,
    translated_text,
    is_verified,
    version;