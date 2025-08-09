-- ================================================================
-- Forward Inheritance Platform - Complete Stored Procedures & Row Level Security
-- UPDATED per Robin's feedback:
-- 1. Removed password-related functions (handled by Cognito)
-- 2. Added Row Level Security policies
-- 3. Updated to work with normalized contact tables
-- 
-- This file contains ALL 46 stored procedures including:
-- CORE PROCEDURES (28):
-- - RLS helper functions (3): current_user_id, current_tenant_id, is_ffc_member
-- - User management (2): sp_create_user_from_cognito, sp_update_user_profile
-- - FFC management (3): sp_create_ffc, sp_add_persona_to_ffc, sp_update_ffc_member_role, sp_remove_ffc_member
-- - Asset management (8): create, update, delete, transfer, update_value, get_details, search, assign_to_persona
-- - Contact management (2): sp_add_email_to_persona, sp_add_phone_to_persona  
-- - Invitation management (1): sp_create_invitation
-- - Audit & compliance (4): sp_log_audit_event, sp_create_audit_event, sp_get_audit_trail, sp_generate_compliance_report
-- - Reporting (1): sp_get_ffc_summary
-- - Session context (2): sp_set_session_context, sp_clear_session_context
-- - Utility functions (1): update_updated_at_column
--
-- INTEGRATION PROCEDURES (18):
-- - PII Management (2): sp_detect_pii, sp_update_pii_job_status
-- - Quillt Integration (4): configure, sync_data, validate_credentials, get_sync_status
-- - Real Estate (2): sp_sync_real_estate_data, sp_get_real_estate_sync_history
-- - Advisor Companies (2): sp_manage_advisor_company, sp_get_advisor_companies
-- - Integration Health (2): sp_check_integration_health, sp_retry_failed_integration
-- - Builder.io (3): configure, refresh_content, get_content_status
-- - Translation (2): sp_manage_translation, sp_get_translations
-- - System Config (1): sp_update_system_configuration
-- ================================================================

-- ================================================================
-- ROW LEVEL SECURITY SETUP
-- ================================================================

-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE fwd_family_circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_storage ENABLE ROW LEVEL SECURITY;
ALTER TABLE ffc_personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_persona ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_address ENABLE ROW LEVEL SECURITY;
ALTER TABLE phone_number ENABLE ROW LEVEL SECURITY;
ALTER TABLE address ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_email ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_phone ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_address ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_social_media ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- HELPER FUNCTIONS FOR RLS
-- ================================================================

-- Get current user's ID from session/context
CREATE OR REPLACE FUNCTION current_user_id() 
RETURNS UUID AS $$
BEGIN
    -- This would typically get the user ID from session context
    -- Set via: SET LOCAL app.current_user_id = 'user-uuid';
    RETURN current_setting('app.current_user_id', true)::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get current tenant ID from session/context
CREATE OR REPLACE FUNCTION current_tenant_id() 
RETURNS INTEGER AS $$
BEGIN
    -- This would typically get the tenant ID from session context
    -- Set via: SET LOCAL app.current_tenant_id = '1';
    RETURN current_setting('app.current_tenant_id', true)::INTEGER;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is member of an FFC
CREATE OR REPLACE FUNCTION is_ffc_member(p_ffc_id UUID, p_user_id UUID DEFAULT current_user_id())
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM ffc_personas fp
        JOIN personas p ON fp.persona_id = p.id
        WHERE fp.ffc_id = p_ffc_id 
        AND p.user_id = p_user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- RLS POLICIES
-- ================================================================

-- Users table policies
CREATE POLICY users_tenant_isolation ON users
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY users_self_read ON users
    FOR SELECT 
    USING (id = current_user_id());

CREATE POLICY users_self_update ON users
    FOR UPDATE 
    USING (id = current_user_id());

-- Personas table policies
CREATE POLICY personas_tenant_isolation ON personas
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY personas_ffc_access ON personas
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM ffc_personas fp
            WHERE fp.persona_id = personas.id
            AND is_ffc_member(fp.ffc_id)
        )
    );

-- FFC table policies
CREATE POLICY ffc_tenant_isolation ON fwd_family_circles
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY ffc_member_access ON fwd_family_circles
    FOR SELECT
    USING (is_ffc_member(id));

CREATE POLICY ffc_owner_full_access ON fwd_family_circles
    FOR ALL
    USING (owner_user_id = current_user_id());

-- Assets table policies
CREATE POLICY assets_tenant_isolation ON assets
    FOR ALL 
    USING (tenant_id = current_tenant_id());

-- Assets are owned by personas through asset_persona junction table
-- Users can manage assets they own through their persona
CREATE POLICY assets_persona_owner_access ON assets
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM asset_persona ap
            JOIN personas p ON ap.persona_id = p.id
            WHERE ap.asset_id = assets.id
            AND p.user_id = current_user_id()
        )
    );

-- Document metadata policies
CREATE POLICY documents_tenant_isolation ON document_metadata
    FOR ALL 
    USING (tenant_id = current_tenant_id());

-- Media storage policies
CREATE POLICY media_tenant_isolation ON media_storage
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY media_uploader_access ON media_storage
    FOR ALL
    USING (uploaded_by = current_user_id());

-- Contact information policies (email, phone, address, social media)
CREATE POLICY email_tenant_isolation ON email_address
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY phone_tenant_isolation ON phone_number
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY address_tenant_isolation ON address
    FOR ALL 
    USING (tenant_id = current_tenant_id());

CREATE POLICY social_media_tenant_isolation ON social_media
    FOR ALL 
    USING (tenant_id = current_tenant_id());

-- Usage policies
CREATE POLICY usage_email_entity_access ON usage_email
    FOR ALL
    USING (
        tenant_id = current_tenant_id() AND
        CASE 
            WHEN entity_type = 'user' THEN entity_id = current_user_id()
            WHEN entity_type = 'persona' THEN EXISTS (
                SELECT 1 FROM personas p 
                WHERE p.id = entity_id AND p.user_id = current_user_id()
            )
            ELSE FALSE
        END
    );

CREATE POLICY usage_phone_entity_access ON usage_phone
    FOR ALL
    USING (
        tenant_id = current_tenant_id() AND
        CASE 
            WHEN entity_type = 'user' THEN entity_id = current_user_id()
            WHEN entity_type = 'persona' THEN EXISTS (
                SELECT 1 FROM personas p 
                WHERE p.id = entity_id AND p.user_id = current_user_id()
            )
            ELSE FALSE
        END
    );

CREATE POLICY usage_address_entity_access ON usage_address
    FOR ALL
    USING (
        tenant_id = current_tenant_id() AND
        CASE 
            WHEN entity_type = 'user' THEN entity_id = current_user_id()
            WHEN entity_type = 'persona' THEN EXISTS (
                SELECT 1 FROM personas p 
                WHERE p.id = entity_id AND p.user_id = current_user_id()
            )
            ELSE FALSE
        END
    );

-- ================================================================
-- USER MANAGEMENT STORED PROCEDURES (Cognito-compatible)
-- ================================================================

-- Drop existing functions first
DROP FUNCTION IF EXISTS sp_register_user CASCADE;
DROP FUNCTION IF EXISTS sp_create_user_from_cognito CASCADE;
DROP FUNCTION IF EXISTS sp_update_user_profile CASCADE;
DROP FUNCTION IF EXISTS sp_verify_email CASCADE;
DROP FUNCTION IF EXISTS sp_verify_phone CASCADE;

-- Create user from Cognito registration
CREATE OR REPLACE FUNCTION sp_create_user_from_cognito(
    p_tenant_id INTEGER,
    p_cognito_user_id TEXT,
    p_cognito_username TEXT,
    p_email TEXT,
    p_phone VARCHAR(20),
    p_first_name TEXT,
    p_last_name TEXT,
    p_email_verified BOOLEAN DEFAULT FALSE,
    p_phone_verified BOOLEAN DEFAULT FALSE,
    p_country_code VARCHAR(5) DEFAULT '+1'
) RETURNS TABLE (
    user_id UUID,
    persona_id UUID,
    email_id UUID,
    phone_id UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_persona_id UUID;
    v_email_id UUID;
    v_phone_id UUID;
    v_clean_phone VARCHAR(20);
BEGIN
    -- Clean phone number (remove formatting)
    v_clean_phone := regexp_replace(p_phone, '[^0-9]', '', 'g');
    
    -- Create email address entry if provided
    IF p_email IS NOT NULL THEN
        INSERT INTO email_address (
            tenant_id, email_address, is_verified, status
        ) VALUES (
            p_tenant_id, lower(p_email), p_email_verified, 'active'
        ) RETURNING id INTO v_email_id;
    END IF;
    
    -- Create phone number entry if provided
    IF p_phone IS NOT NULL THEN
        INSERT INTO phone_number (
            tenant_id, country_code, phone_number, is_verified, status
        ) VALUES (
            p_tenant_id, p_country_code, v_clean_phone, p_phone_verified, 'active'
        ) RETURNING id INTO v_phone_id;
    END IF;
    
    -- Create user linked to Cognito
    INSERT INTO users (
        tenant_id,
        cognito_user_id,
        cognito_username,
        primary_email_id, 
        primary_phone_id,
        first_name, 
        last_name,
        display_name,
        email_verified,
        phone_verified,
        status
    ) VALUES (
        p_tenant_id,
        p_cognito_user_id,
        p_cognito_username,
        v_email_id,
        v_phone_id,
        p_first_name, 
        p_last_name,
        p_first_name || ' ' || p_last_name,
        p_email_verified,
        p_phone_verified,
        CASE 
            WHEN p_email_verified OR p_phone_verified THEN 'active'::user_status_enum
            ELSE 'pending_verification'::user_status_enum
        END
    ) RETURNING id INTO v_user_id;
    
    -- Create usage records for email if exists
    IF v_email_id IS NOT NULL THEN
        INSERT INTO usage_email (
            tenant_id, entity_type, entity_id, email_id, usage_type, is_primary
        ) VALUES (
            p_tenant_id, 'user', v_user_id, v_email_id, 'primary', TRUE
        );
    END IF;
    
    -- Create usage records for phone if exists
    IF v_phone_id IS NOT NULL THEN
        INSERT INTO usage_phone (
            tenant_id, entity_type, entity_id, phone_id, usage_type, is_primary
        ) VALUES (
            p_tenant_id, 'user', v_user_id, v_phone_id, 'primary', TRUE
        );
    END IF;
    
    -- Create a persona for the user
    INSERT INTO personas (
        tenant_id,
        user_id,
        first_name,
        last_name,
        is_living,
        status
    ) VALUES (
        p_tenant_id,
        v_user_id,
        p_first_name,
        p_last_name,
        TRUE,
        'active'
    ) RETURNING id INTO v_persona_id;
    
    RETURN QUERY SELECT v_user_id, v_persona_id, v_email_id, v_phone_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update user profile
CREATE OR REPLACE FUNCTION sp_update_user_profile(
    p_user_id UUID,
    p_first_name TEXT,
    p_last_name TEXT,
    p_display_name TEXT,
    p_profile_picture_url TEXT,
    p_preferred_language CHAR(2),
    p_timezone VARCHAR(50)
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE users SET
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        display_name = COALESCE(p_display_name, display_name),
        profile_picture_url = COALESCE(p_profile_picture_url, profile_picture_url),
        preferred_language = COALESCE(p_preferred_language, preferred_language),
        timezone = COALESCE(p_timezone, timezone),
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = p_user_id
    WHERE id = p_user_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- FFC MANAGEMENT
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_ffc CASCADE;
DROP FUNCTION IF EXISTS sp_add_persona_to_ffc CASCADE;
DROP FUNCTION IF EXISTS sp_remove_persona_from_ffc CASCADE;

-- Create a new FFC
CREATE OR REPLACE FUNCTION sp_create_ffc(
    p_tenant_id INTEGER,
    p_owner_user_id UUID,
    p_name TEXT,
    p_description TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_ffc_id UUID;
    v_owner_persona_id UUID;
BEGIN
    -- Create the FFC
    INSERT INTO fwd_family_circles (
        tenant_id,
        owner_user_id,
        name,
        description,
        is_active
    ) VALUES (
        p_tenant_id,
        p_owner_user_id,
        p_name,
        p_description,
        TRUE
    ) RETURNING id INTO v_ffc_id;
    
    -- Get owner's persona
    SELECT id INTO v_owner_persona_id
    FROM personas
    WHERE user_id = p_owner_user_id
    LIMIT 1;
    
    -- Add owner to FFC as owner
    IF v_owner_persona_id IS NOT NULL THEN
        INSERT INTO ffc_personas (
            tenant_id,
            ffc_id,
            persona_id,
            ffc_role,
            joined_at
        ) VALUES (
            p_tenant_id,
            v_ffc_id,
            v_owner_persona_id,
            'owner',
            (NOW() AT TIME ZONE 'UTC')
        );
    END IF;
    
    RETURN v_ffc_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add persona to FFC
CREATE OR REPLACE FUNCTION sp_add_persona_to_ffc(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_persona_id UUID,
    p_role ffc_role_enum,
    p_added_by UUID
) RETURNS BOOLEAN AS $$
BEGIN
    -- Check if already exists
    IF EXISTS (
        SELECT 1 FROM ffc_personas 
        WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id
    ) THEN
        -- Update role if different
        UPDATE ffc_personas 
        SET ffc_role = p_role,
            updated_at = (NOW() AT TIME ZONE 'UTC'),
            updated_by = p_added_by
        WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id;
    ELSE
        -- Insert new
        INSERT INTO ffc_personas (
            tenant_id,
            ffc_id,
            persona_id,
            ffc_role,
            joined_at,
            created_by
        ) VALUES (
            p_tenant_id,
            p_ffc_id,
            p_persona_id,
            p_role,
            (NOW() AT TIME ZONE 'UTC'),
            p_added_by
        );
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- ASSET MANAGEMENT
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_asset CASCADE;
DROP FUNCTION IF EXISTS sp_update_asset CASCADE;
DROP FUNCTION IF EXISTS sp_transfer_asset CASCADE;

-- Create a new asset and assign ownership to a persona
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_owner_persona_id UUID,
    p_asset_type asset_type_enum,
    p_name TEXT,
    p_description TEXT,
    p_ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    p_created_by_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_category_id UUID;
    v_user_id UUID;
BEGIN
    -- Get the user_id from the persona if not provided
    IF p_created_by_user_id IS NULL THEN
        SELECT user_id INTO v_user_id
        FROM personas
        WHERE id = p_owner_persona_id;
    ELSE
        v_user_id := p_created_by_user_id;
    END IF;
    
    -- Get category_id from asset_type
    SELECT id INTO v_category_id
    FROM asset_categories
    WHERE code = p_asset_type::TEXT;
    
    -- Create the asset
    INSERT INTO assets (
        tenant_id,
        category_id,
        name,
        description,
        status,
        created_by,
        updated_by
    ) VALUES (
        p_tenant_id,
        v_category_id,
        p_name,
        p_description,
        'active',
        v_user_id,
        v_user_id
    ) RETURNING id INTO v_asset_id;
    
    -- Create ownership relationship in asset_persona
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage,
        is_primary,
        created_by,
        updated_by
    ) VALUES (
        p_tenant_id,
        v_asset_id,
        p_owner_persona_id,
        'owner',
        p_ownership_percentage,
        TRUE,
        v_user_id,
        v_user_id
    );
    
    -- Log the creation
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        p_tenant_id,
        v_user_id,
        'create',
        'asset',
        v_asset_id,
        p_name,
        jsonb_build_object(
            'asset_type', p_asset_type, 
            'owner_persona_id', p_owner_persona_id,
            'ownership_percentage', p_ownership_percentage
        )
    );
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- INVITATION MANAGEMENT
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_invitation CASCADE;
DROP FUNCTION IF EXISTS sp_verify_invitation CASCADE;
DROP FUNCTION IF EXISTS sp_accept_invitation CASCADE;

-- Create FFC invitation
CREATE OR REPLACE FUNCTION sp_create_invitation(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_phone_number VARCHAR(20),
    p_role ffc_role_enum,
    p_invited_by UUID,
    p_persona_first_name TEXT,
    p_persona_last_name TEXT
) RETURNS UUID AS $$
DECLARE
    v_invitation_id UUID;
    v_verification_code VARCHAR(6);
BEGIN
    -- Generate 6-digit verification code
    v_verification_code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    
    -- Create invitation
    INSERT INTO ffc_invitations (
        tenant_id,
        ffc_id,
        phone_number,
        verification_code,
        ffc_role,
        persona_first_name,
        persona_last_name,
        invited_by,
        status,
        sent_at,
        expires_at
    ) VALUES (
        p_tenant_id,
        p_ffc_id,
        p_phone_number,
        v_verification_code,
        p_role,
        p_persona_first_name,
        p_persona_last_name,
        p_invited_by,
        'sent',
        (NOW() AT TIME ZONE 'UTC'),
        ((NOW() AT TIME ZONE 'UTC') + INTERVAL '30 days')
    ) RETURNING id INTO v_invitation_id;
    
    RETURN v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- REPORTING FUNCTIONS
-- ================================================================

-- Get FFC summary
CREATE OR REPLACE FUNCTION sp_get_ffc_summary(
    p_ffc_id UUID,
    p_user_id UUID
) RETURNS TABLE (
    ffc_name VARCHAR,
    owner_name TEXT,
    member_count BIGINT,
    asset_count BIGINT,
    document_count BIGINT,
    created_date TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check access
    IF NOT is_ffc_member(p_ffc_id, p_user_id) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;
    
    RETURN QUERY
    SELECT 
        f.name,
        u.first_name || ' ' || u.last_name as owner_name,
        (SELECT COUNT(*) FROM ffc_personas WHERE ffc_id = p_ffc_id),
        (SELECT COUNT(*) FROM assets WHERE ffc_id = p_ffc_id),
        (SELECT COUNT(*) FROM document_metadata d 
         JOIN assets a ON a.id = d.id 
         WHERE a.ffc_id = p_ffc_id),
        f.created_at
    FROM fwd_family_circles f
    JOIN users u ON f.owner_user_id = u.id
    WHERE f.id = p_ffc_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- UTILITY FUNCTIONS
-- ================================================================

-- Set session context (called at beginning of each request)
CREATE OR REPLACE FUNCTION sp_set_session_context(
    p_user_id UUID,
    p_tenant_id INTEGER
) RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, true);
    PERFORM set_config('app.current_tenant_id', p_tenant_id::TEXT, true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Clear session context (called at end of request)
CREATE OR REPLACE FUNCTION sp_clear_session_context() 
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', NULL, true);
    PERFORM set_config('app.current_tenant_id', NULL, true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- AUDIT TRIGGERS
-- ================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = (NOW() AT TIME ZONE 'UTC');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables with updated_at (if they don't already exist)
-- Note: These triggers are already created in script 2, so this block will skip them
DO $$
DECLARE
    t text;
    trigger_name text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        trigger_name := 'update_' || t || '_updated_at';
        -- Only create trigger if it doesn't exist
        IF NOT EXISTS (
            SELECT 1 FROM pg_trigger 
            WHERE tgname = trigger_name
        ) THEN
            EXECUTE format('
                CREATE TRIGGER %I 
                BEFORE UPDATE ON %I 
                FOR EACH ROW 
                EXECUTE FUNCTION update_updated_at_column()',
                trigger_name, t);
        END IF;
    END LOOP;
END;
$$;

-- ================================================================
-- GRANT PERMISSIONS
-- ================================================================

-- Grant execute permissions on functions to application role
-- This assumes you have an 'app_user' role for your application
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_user;
    END IF;
END;
$$;

-- ================================================================
-- ADDITIONAL CRITICAL STORED PROCEDURES
-- ================================================================

-- ================================================================
-- ASSET MANAGEMENT PROCEDURES
-- ================================================================

-- Update existing asset
CREATE OR REPLACE FUNCTION sp_update_asset(
    p_asset_id UUID,
    p_name TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_acquisition_value DECIMAL(15,2) DEFAULT NULL,
    p_acquisition_date DATE DEFAULT NULL,
    p_status status_enum DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL,
    p_updated_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_updated_by, current_user_id());
    
    -- Update the asset
    UPDATE assets SET
        name = COALESCE(p_name, name),
        description = COALESCE(p_description, description),
        acquisition_value = COALESCE(p_acquisition_value, acquisition_value),
        acquisition_date = COALESCE(p_acquisition_date, acquisition_date),
        status = COALESCE(p_status, status),
        tags = CASE 
            WHEN p_metadata IS NOT NULL THEN tags || p_metadata
            ELSE tags
        END,
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = v_user_id
    WHERE id = p_asset_id;
    
    -- Log the update
    IF FOUND THEN
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            entity_name,
            metadata
        ) VALUES (
            (SELECT tenant_id FROM assets WHERE id = p_asset_id),
            v_user_id,
            'update',
            'asset',
            p_asset_id,
            (SELECT name FROM assets WHERE id = p_asset_id),
            jsonb_build_object('changes', jsonb_build_object(
                'name', p_name,
                'description', p_description,
                'value', p_acquisition_value,
                'status', p_status
            ))
        );
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Delete asset (soft delete)
CREATE OR REPLACE FUNCTION sp_delete_asset(
    p_asset_id UUID,
    p_deleted_by UUID DEFAULT NULL,
    p_hard_delete BOOLEAN DEFAULT FALSE
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_asset_name TEXT;
    v_tenant_id INTEGER;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_deleted_by, current_user_id());
    
    -- Get asset info for audit
    SELECT name, tenant_id INTO v_asset_name, v_tenant_id
    FROM assets WHERE id = p_asset_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    IF p_hard_delete THEN
        -- Remove ownership relationships first
        DELETE FROM asset_persona WHERE asset_id = p_asset_id;
        DELETE FROM asset_permissions WHERE asset_id = p_asset_id;
        
        -- Delete the asset
        DELETE FROM assets WHERE id = p_asset_id;
    ELSE
        -- Soft delete
        UPDATE assets SET
            status = 'deleted',
            updated_at = (NOW() AT TIME ZONE 'UTC'),
            updated_by = v_user_id
        WHERE id = p_asset_id;
    END IF;
    
    -- Log the deletion
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        v_tenant_id,
        v_user_id,
        CASE WHEN p_hard_delete THEN 'hard_delete' ELSE 'soft_delete' END,
        'asset',
        p_asset_id,
        v_asset_name,
        jsonb_build_object('hard_delete', p_hard_delete)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Transfer asset ownership between personas
CREATE OR REPLACE FUNCTION sp_transfer_asset_ownership(
    p_asset_id UUID,
    p_from_persona_id UUID,
    p_to_persona_id UUID,
    p_ownership_percentage DECIMAL(5,2) DEFAULT NULL,
    p_transfer_type VARCHAR(50) DEFAULT 'full',
    p_transferred_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_current_percentage DECIMAL(5,2);
    v_transfer_percentage DECIMAL(5,2);
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_transferred_by, current_user_id());
    
    -- Get tenant_id
    SELECT tenant_id INTO v_tenant_id FROM assets WHERE id = p_asset_id;
    
    -- Get current ownership percentage
    SELECT ownership_percentage INTO v_current_percentage
    FROM asset_persona 
    WHERE asset_id = p_asset_id AND persona_id = p_from_persona_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source persona does not own this asset';
    END IF;
    
    -- Determine transfer percentage
    IF p_transfer_type = 'full' THEN
        v_transfer_percentage := v_current_percentage;
    ELSE
        v_transfer_percentage := COALESCE(p_ownership_percentage, v_current_percentage);
    END IF;
    
    -- Validate transfer
    IF v_transfer_percentage > v_current_percentage THEN
        RAISE EXCEPTION 'Cannot transfer more than current ownership %', v_current_percentage;
    END IF;
    
    BEGIN
        -- Start transaction
        -- Update or remove from persona's ownership
        IF v_transfer_percentage = v_current_percentage THEN
            -- Full transfer - remove from source
            DELETE FROM asset_persona 
            WHERE asset_id = p_asset_id AND persona_id = p_from_persona_id;
        ELSE
            -- Partial transfer - reduce percentage
            UPDATE asset_persona SET
                ownership_percentage = v_current_percentage - v_transfer_percentage,
                updated_at = (NOW() AT TIME ZONE 'UTC'),
                updated_by = v_user_id
            WHERE asset_id = p_asset_id AND persona_id = p_from_persona_id;
        END IF;
        
        -- Add or update to persona's ownership
        INSERT INTO asset_persona (
            tenant_id,
            asset_id,
            persona_id,
            ownership_type,
            ownership_percentage,
            is_primary,
            created_by,
            updated_by
        ) VALUES (
            v_tenant_id,
            p_asset_id,
            p_to_persona_id,
            'owner',
            v_transfer_percentage,
            FALSE,
            v_user_id,
            v_user_id
        )
        ON CONFLICT (asset_id, persona_id) DO UPDATE SET
            ownership_percentage = asset_persona.ownership_percentage + v_transfer_percentage,
            updated_at = (NOW() AT TIME ZONE 'UTC'),
            updated_by = v_user_id;
        
        -- Log the transfer
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            entity_name,
            metadata
        ) VALUES (
            v_tenant_id,
            v_user_id,
            'transfer_ownership',
            'asset',
            p_asset_id,
            (SELECT name FROM assets WHERE id = p_asset_id),
            jsonb_build_object(
                'from_persona_id', p_from_persona_id,
                'to_persona_id', p_to_persona_id,
                'percentage', v_transfer_percentage,
                'transfer_type', p_transfer_type
            )
        );
        
        RETURN TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update asset value/valuation
CREATE OR REPLACE FUNCTION sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_valuation_date DATE DEFAULT CURRENT_DATE,
    p_valuation_method VARCHAR(50) DEFAULT 'market',
    p_updated_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_old_value DECIMAL(15,2);
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_updated_by, current_user_id());
    
    -- Get current value
    SELECT estimated_value INTO v_old_value FROM assets WHERE id = p_asset_id;
    
    -- Update asset value
    UPDATE assets SET
        estimated_value = p_new_value,
        last_valued_date = p_valuation_date,
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = v_user_id,
        tags = tags || jsonb_build_object(
            'valuation_history', 
            COALESCE(tags->'valuation_history', '[]'::jsonb) || 
            jsonb_build_array(jsonb_build_object(
                'date', p_valuation_date,
                'value', p_new_value,
                'method', p_valuation_method,
                'previous_value', v_old_value,
                'updated_by', v_user_id,
                'updated_at', (NOW() AT TIME ZONE 'UTC')
            ))
        )
    WHERE id = p_asset_id;
    
    IF FOUND THEN
        -- Log the valuation update
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            entity_name,
            metadata
        ) VALUES (
            (SELECT tenant_id FROM assets WHERE id = p_asset_id),
            v_user_id,
            'update',
            'asset',
            p_asset_id,
            (SELECT name FROM assets WHERE id = p_asset_id),
            jsonb_build_object(
                'old_value', v_old_value,
                'new_value', p_new_value,
                'valuation_date', p_valuation_date,
                'valuation_method', p_valuation_method
            )
        );
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get asset details
CREATE OR REPLACE FUNCTION sp_get_asset_details(
    p_asset_id UUID,
    p_requesting_user UUID DEFAULT NULL
) RETURNS TABLE (
    asset_id UUID,
    asset_name VARCHAR,
    asset_description TEXT,
    category_name VARCHAR,
    acquisition_value DECIMAL,
    estimated_value DECIMAL,
    acquisition_date DATE,
    last_valued_date DATE,
    status status_enum,
    ffc_name VARCHAR,
    owners JSONB,
    tags JSONB
) AS $$
BEGIN
    -- Check access if user provided
    IF p_requesting_user IS NOT NULL AND NOT is_ffc_member(
        (SELECT ffc_id FROM assets WHERE id = p_asset_id),
        p_requesting_user
    ) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;
    
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.description,
        ac.name,
        a.acquisition_value,
        a.current_value,
        a.acquisition_date,
        a.last_valuation_date,
        a.status,
        f.name,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'persona_id', ap.persona_id,
                'persona_name', p.first_name || ' ' || p.last_name,
                'ownership_type', ap.ownership_type,
                'ownership_percentage', ap.ownership_percentage,
                'is_primary', ap.is_primary
            ))
            FROM asset_persona ap
            JOIN personas p ON ap.persona_id = p.id
            WHERE ap.asset_id = a.id
        ),
        a.tags
    FROM assets a
    JOIN asset_categories ac ON a.category_id = ac.id
    JOIN fwd_family_circles f ON a.ffc_id = f.id
    WHERE a.id = p_asset_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Search assets
CREATE OR REPLACE FUNCTION sp_search_assets(
    p_ffc_id UUID DEFAULT NULL,
    p_category_code VARCHAR(50) DEFAULT NULL,
    p_owner_persona_id UUID DEFAULT NULL,
    p_status status_enum DEFAULT NULL,
    p_min_value DECIMAL(15,2) DEFAULT NULL,
    p_max_value DECIMAL(15,2) DEFAULT NULL,
    p_search_term TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    asset_id UUID,
    asset_name VARCHAR,
    category_name VARCHAR,
    current_value DECIMAL,
    status status_enum,
    ffc_name VARCHAR,
    primary_owner VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        ac.name,
        a.current_value,
        a.status,
        f.name,
        (
            SELECT p.first_name || ' ' || p.last_name
            FROM asset_persona ap
            JOIN personas p ON ap.persona_id = p.id
            WHERE ap.asset_id = a.id AND ap.is_primary = TRUE
            LIMIT 1
        )
    FROM assets a
    JOIN asset_categories ac ON a.category_id = ac.id
    JOIN fwd_family_circles f ON a.ffc_id = f.id
    WHERE 
        (p_ffc_id IS NULL OR a.ffc_id = p_ffc_id)
        AND (p_category_code IS NULL OR ac.code = p_category_code)
        AND (p_status IS NULL OR a.status = p_status)
        AND (p_min_value IS NULL OR a.current_value >= p_min_value)
        AND (p_max_value IS NULL OR a.current_value <= p_max_value)
        AND (p_search_term IS NULL OR 
             a.name ILIKE '%' || p_search_term || '%' OR
             a.description ILIKE '%' || p_search_term || '%')
        AND (p_owner_persona_id IS NULL OR EXISTS (
            SELECT 1 FROM asset_persona ap 
            WHERE ap.asset_id = a.id AND ap.persona_id = p_owner_persona_id
        ))
    ORDER BY a.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Assign asset to persona (link assets to personas)
CREATE OR REPLACE FUNCTION sp_assign_asset_to_persona(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum DEFAULT 'owner',
    p_ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    p_is_primary BOOLEAN DEFAULT FALSE,
    p_assigned_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_total_percentage DECIMAL(5,2);
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_assigned_by, current_user_id());
    
    -- Get tenant_id from asset
    SELECT tenant_id INTO v_tenant_id FROM assets WHERE id = p_asset_id;
    
    -- Check total ownership doesn't exceed 100%
    SELECT COALESCE(SUM(ownership_percentage), 0) INTO v_total_percentage
    FROM asset_persona WHERE asset_id = p_asset_id;
    
    IF v_total_percentage + p_ownership_percentage > 100 THEN
        RAISE EXCEPTION 'Total ownership would exceed 100%%';
    END IF;
    
    -- Insert or update assignment
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage,
        is_primary,
        created_by,
        updated_by
    ) VALUES (
        v_tenant_id,
        p_asset_id,
        p_persona_id,
        p_ownership_type,
        p_ownership_percentage,
        p_is_primary,
        v_user_id,
        v_user_id
    )
    ON CONFLICT (asset_id, persona_id) DO UPDATE SET
        ownership_type = p_ownership_type,
        ownership_percentage = p_ownership_percentage,
        is_primary = p_is_primary,
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = v_user_id;
    
    -- If setting as primary, unset other primaries
    IF p_is_primary THEN
        UPDATE asset_persona SET
            is_primary = FALSE,
            updated_at = (NOW() AT TIME ZONE 'UTC'),
            updated_by = v_user_id
        WHERE asset_id = p_asset_id 
        AND persona_id != p_persona_id 
        AND is_primary = TRUE;
    END IF;
    
    -- Log the assignment
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        v_tenant_id,
        v_user_id,
        'assign_asset',
        'asset',
        p_asset_id,
        (SELECT name FROM assets WHERE id = p_asset_id),
        jsonb_build_object(
            'persona_id', p_persona_id,
            'ownership_type', p_ownership_type,
            'ownership_percentage', p_ownership_percentage,
            'is_primary', p_is_primary
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- FFC MEMBER MANAGEMENT PROCEDURES
-- ================================================================

-- Update FFC member role
CREATE OR REPLACE FUNCTION sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_new_role ffc_role_enum,
    p_updated_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_old_role ffc_role_enum;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_updated_by, current_user_id());
    
    -- Get current role
    SELECT ffc_role INTO v_old_role
    FROM ffc_personas
    WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Update the role
    UPDATE ffc_personas SET
        ffc_role = p_new_role,
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = v_user_id
    WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id;
    
    -- Log the change
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        (SELECT tenant_id FROM fwd_family_circles WHERE id = p_ffc_id),
        v_user_id,
        'update_member_role',
        'ffc',
        p_ffc_id,
        (SELECT name FROM fwd_family_circles WHERE id = p_ffc_id),
        jsonb_build_object(
            'persona_id', p_persona_id,
            'old_role', v_old_role,
            'new_role', p_new_role
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remove FFC member
CREATE OR REPLACE FUNCTION sp_remove_ffc_member(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_removed_by UUID DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_member_role ffc_role_enum;
    v_persona_name TEXT;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_removed_by, current_user_id());
    
    -- Get member info
    SELECT fp.ffc_role, p.first_name || ' ' || p.last_name
    INTO v_member_role, v_persona_name
    FROM ffc_personas fp
    JOIN personas p ON fp.persona_id = p.id
    WHERE fp.ffc_id = p_ffc_id AND fp.persona_id = p_persona_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Prevent removing the owner
    IF v_member_role = 'owner' THEN
        RAISE EXCEPTION 'Cannot remove FFC owner';
    END IF;
    
    -- Remove the member
    DELETE FROM ffc_personas 
    WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id;
    
    -- Log the removal
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        (SELECT tenant_id FROM fwd_family_circles WHERE id = p_ffc_id),
        v_user_id,
        'remove_member',
        'ffc',
        p_ffc_id,
        (SELECT name FROM fwd_family_circles WHERE id = p_ffc_id),
        jsonb_build_object(
            'persona_id', p_persona_id,
            'persona_name', v_persona_name,
            'role', v_member_role,
            'reason', p_reason
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- CONTACT MANAGEMENT PROCEDURES
-- ================================================================

-- Add email to persona
CREATE OR REPLACE FUNCTION sp_add_email_to_persona(
    p_persona_id UUID,
    p_email TEXT,
    p_usage_type email_usage_type_enum DEFAULT 'personal',
    p_is_primary BOOLEAN DEFAULT FALSE,
    p_added_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_email_id UUID;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_added_by, current_user_id());
    
    -- Get tenant_id from persona
    SELECT tenant_id INTO v_tenant_id FROM personas WHERE id = p_persona_id;
    
    -- Check if email already exists
    SELECT id INTO v_email_id 
    FROM email_address 
    WHERE email_address = lower(p_email) AND tenant_id = v_tenant_id;
    
    -- Create email if doesn't exist
    IF v_email_id IS NULL THEN
        INSERT INTO email_address (
            tenant_id,
            email_address,
            is_verified,
            status
        ) VALUES (
            v_tenant_id,
            lower(p_email),
            FALSE,
            'active'
        ) RETURNING id INTO v_email_id;
    END IF;
    
    -- Create usage record
    INSERT INTO usage_email (
        tenant_id,
        entity_type,
        entity_id,
        email_id,
        usage_type,
        is_primary
    ) VALUES (
        v_tenant_id,
        'persona',
        p_persona_id,
        v_email_id,
        p_usage_type,
        p_is_primary
    )
    ON CONFLICT (entity_type, entity_id, email_id) DO UPDATE SET
        usage_type = p_usage_type,
        is_primary = p_is_primary,
        updated_at = (NOW() AT TIME ZONE 'UTC');
    
    -- If setting as primary, unset other primaries
    IF p_is_primary THEN
        UPDATE usage_email SET
            is_primary = FALSE,
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE entity_type = 'persona' 
        AND entity_id = p_persona_id 
        AND email_id != v_email_id
        AND is_primary = TRUE;
    END IF;
    
    RETURN v_email_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add phone to persona
CREATE OR REPLACE FUNCTION sp_add_phone_to_persona(
    p_persona_id UUID,
    p_phone VARCHAR(20),
    p_country_code VARCHAR(5) DEFAULT '+1',
    p_usage_type phone_usage_type_enum DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE,
    p_added_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_phone_id UUID;
    v_clean_phone VARCHAR(20);
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_added_by, current_user_id());
    
    -- Get tenant_id from persona
    SELECT tenant_id INTO v_tenant_id FROM personas WHERE id = p_persona_id;
    
    -- Clean phone number
    v_clean_phone := regexp_replace(p_phone, '[^0-9]', '', 'g');
    
    -- Check if phone already exists
    SELECT id INTO v_phone_id 
    FROM phone_number 
    WHERE phone_number = v_clean_phone 
    AND country_code = p_country_code 
    AND tenant_id = v_tenant_id;
    
    -- Create phone if doesn't exist
    IF v_phone_id IS NULL THEN
        INSERT INTO phone_number (
            tenant_id,
            country_code,
            phone_number,
            is_verified,
            status
        ) VALUES (
            v_tenant_id,
            p_country_code,
            v_clean_phone,
            FALSE,
            'active'
        ) RETURNING id INTO v_phone_id;
    END IF;
    
    -- Create usage record
    INSERT INTO usage_phone (
        tenant_id,
        entity_type,
        entity_id,
        phone_id,
        usage_type,
        is_primary
    ) VALUES (
        v_tenant_id,
        'persona',
        p_persona_id,
        v_phone_id,
        p_usage_type,
        p_is_primary
    )
    ON CONFLICT (entity_type, entity_id, phone_id) DO UPDATE SET
        usage_type = p_usage_type,
        is_primary = p_is_primary,
        updated_at = (NOW() AT TIME ZONE 'UTC');
    
    -- If setting as primary, unset other primaries
    IF p_is_primary THEN
        UPDATE usage_phone SET
            is_primary = FALSE,
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE entity_type = 'persona' 
        AND entity_id = p_persona_id 
        AND phone_id != v_phone_id
        AND is_primary = TRUE;
    END IF;
    
    RETURN v_phone_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- AUDIT & COMPLIANCE PROCEDURES
-- ================================================================

-- Log audit event
CREATE OR REPLACE FUNCTION sp_log_audit_event(
    p_action VARCHAR(50),
    p_entity_type VARCHAR(50),
    p_entity_id UUID,
    p_entity_name TEXT DEFAULT NULL,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}',
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_audit_id UUID;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Get tenant_id
    v_tenant_id := current_tenant_id();
    
    -- Insert audit log
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        old_values,
        new_values,
        metadata,
        ip_address,
        user_agent
    ) VALUES (
        v_tenant_id,
        v_user_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_entity_name,
        p_old_values,
        p_new_values,
        p_metadata,
        inet_client_addr(),
        current_setting('application_name', true)
    ) RETURNING id INTO v_audit_id;
    
    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create audit event (for compliance)
CREATE OR REPLACE FUNCTION sp_create_audit_event(
    p_event_type TEXT,
    p_event_category VARCHAR(50),
    p_description TEXT,
    p_risk_level VARCHAR(20) DEFAULT 'low',
    p_compliance_framework VARCHAR(50) DEFAULT 'SOC2',
    p_metadata JSONB DEFAULT '{}',
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_event_id UUID;
BEGIN
    -- Get user_id if not provided
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Get tenant_id
    v_tenant_id := current_tenant_id();
    
    -- Insert audit event
    INSERT INTO audit_events (
        tenant_id,
        event_type,
        event_category,
        event_timestamp,
        user_id,
        session_id,
        resource_type,
        resource_id,
        action_performed,
        action_result,
        risk_level,
        compliance_framework,
        event_data,
        ip_address,
        user_agent,
        description
    ) VALUES (
        v_tenant_id,
        p_event_type,
        p_event_category,
        (NOW() AT TIME ZONE 'UTC'),
        v_user_id,
        current_setting('app.session_id', true)::UUID,
        p_metadata->>'resource_type',
        (p_metadata->>'resource_id')::UUID,
        p_metadata->>'action',
        COALESCE(p_metadata->>'result', 'success'),
        p_risk_level,
        p_compliance_framework,
        p_metadata,
        inet_client_addr(),
        current_setting('application_name', true),
        p_description
    ) RETURNING id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get audit trail
CREATE OR REPLACE FUNCTION sp_get_audit_trail(
    p_entity_type VARCHAR(50) DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_action VARCHAR(50) DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    audit_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    user_name TEXT,
    action VARCHAR,
    entity_type VARCHAR,
    entity_name VARCHAR,
    changes JSONB,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id,
        al.created_at,
        u.first_name || ' ' || u.last_name,
        al.action,
        al.entity_type,
        al.entity_name,
        jsonb_build_object(
            'old_values', al.old_values,
            'new_values', al.new_values
        ),
        al.metadata
    FROM audit_log al
    LEFT JOIN users u ON al.user_id = u.id
    WHERE 
        (p_entity_type IS NULL OR al.entity_type = p_entity_type)
        AND (p_entity_id IS NULL OR al.entity_id = p_entity_id)
        AND (p_user_id IS NULL OR al.user_id = p_user_id)
        AND (p_action IS NULL OR al.action = p_action)
        AND (p_start_date IS NULL OR al.created_at >= p_start_date)
        AND (p_end_date IS NULL OR al.created_at <= p_end_date)
    ORDER BY al.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Generate compliance report (SOC 2)
CREATE OR REPLACE FUNCTION sp_generate_compliance_report(
    p_framework VARCHAR(50) DEFAULT 'SOC2',
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_include_pii_activity BOOLEAN DEFAULT TRUE
) RETURNS TABLE (
    report_date DATE,
    framework VARCHAR,
    total_events BIGINT,
    high_risk_events BIGINT,
    pii_access_count BIGINT,
    failed_authentications BIGINT,
    data_modifications BIGINT,
    user_activity JSONB,
    risk_summary JSONB
) AS $$
DECLARE
    v_start DATE;
    v_end DATE;
BEGIN
    -- Default to last 30 days if not specified
    v_start := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '30 days');
    v_end := COALESCE(p_end_date, CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        CURRENT_DATE,
        p_framework,
        (SELECT COUNT(*) FROM audit_events 
         WHERE compliance_framework = p_framework 
         AND event_timestamp::DATE BETWEEN v_start AND v_end),
        (SELECT COUNT(*) FROM audit_events 
         WHERE compliance_framework = p_framework 
         AND risk_level = 'high'
         AND event_timestamp::DATE BETWEEN v_start AND v_end),
        CASE WHEN p_include_pii_activity THEN
            (SELECT COUNT(*) FROM pii_access_logs 
             WHERE access_timestamp::DATE BETWEEN v_start AND v_end)
        ELSE 0 END,
        (SELECT COUNT(*) FROM user_login_history 
         WHERE login_success = FALSE 
         AND login_timestamp::DATE BETWEEN v_start AND v_end),
        (SELECT COUNT(*) FROM audit_log 
         WHERE action IN ('create', 'update', 'delete') 
         AND created_at::DATE BETWEEN v_start AND v_end),
        (SELECT jsonb_object_agg(
            u.id::TEXT,
            jsonb_build_object(
                'name', u.first_name || ' ' || u.last_name,
                'events', event_count
            )
         ) FROM (
            SELECT user_id, COUNT(*) as event_count
            FROM audit_events
            WHERE event_timestamp::DATE BETWEEN v_start AND v_end
            GROUP BY user_id
         ) ae
         JOIN users u ON ae.user_id = u.id),
        (SELECT jsonb_build_object(
            'high', COUNT(*) FILTER (WHERE risk_level = 'high'),
            'medium', COUNT(*) FILTER (WHERE risk_level = 'medium'),
            'low', COUNT(*) FILTER (WHERE risk_level = 'low')
         ) FROM audit_events
         WHERE event_timestamp::DATE BETWEEN v_start AND v_end);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- INTEGRATION & FUTURE PHASE PROCEDURES
-- ================================================================

-- ================================================================
-- PII DETECTION & MANAGEMENT PROCEDURES (SOC 2 Compliance)
-- ================================================================

-- Detect PII in text/data
CREATE OR REPLACE FUNCTION sp_detect_pii(
    p_text TEXT,
    p_context TEXT DEFAULT 'general',
    p_user_id UUID DEFAULT NULL
) RETURNS TABLE (
    detected BOOLEAN,
    pii_types JSONB,
    confidence_score DECIMAL,
    masked_text TEXT,
    detection_details JSONB
) AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_job_id UUID;
    v_detected_pii JSONB;
    v_masked TEXT;
    v_confidence DECIMAL;
BEGIN
    -- Get user_id and tenant
    v_user_id := COALESCE(p_user_id, current_user_id());
    v_tenant_id := current_tenant_id();
    
    -- Create PII processing job
    INSERT INTO pii_processing_jobs (
        tenant_id,
        job_type,
        status,
        total_records,
        metadata
    ) VALUES (
        v_tenant_id,
        'detection',
        'processing',
        1,
        jsonb_build_object('context', p_context, 'user_id', v_user_id)
    ) RETURNING id INTO v_job_id;
    
    -- Initialize detection results
    v_detected_pii := '[]'::jsonb;
    v_masked := p_text;
    v_confidence := 0;
    
    -- Check against PII detection rules
    WITH rule_checks AS (
        SELECT 
            pdr.rule_name,
            pdr.rule_type,
            pdr.pattern,
            pdr.confidence_score,
            CASE 
                WHEN pdr.rule_type = 'regex' THEN 
                    p_text ~ pdr.pattern
                WHEN pdr.rule_type = 'keyword' THEN 
                    p_text ILIKE '%' || pdr.pattern || '%'
                ELSE FALSE
            END as matched
        FROM pii_detection_rules pdr
        WHERE pdr.is_active = TRUE
        AND pdr.tenant_id = v_tenant_id
    ),
    detections AS (
        SELECT 
            jsonb_agg(
                jsonb_build_object(
                    'type', rule_name,
                    'confidence', confidence_score
                )
            ) as pii_found,
            MAX(confidence_score) as max_confidence
        FROM rule_checks
        WHERE matched = TRUE
    )
    SELECT 
        COALESCE(pii_found, '[]'::jsonb),
        COALESCE(max_confidence, 0)
    INTO v_detected_pii, v_confidence
    FROM detections;
    
    -- Apply masking if PII detected
    IF jsonb_array_length(v_detected_pii) > 0 THEN
        -- Simple masking - replace common patterns
        v_masked := regexp_replace(p_text, '\d{3}-\d{2}-\d{4}', 'XXX-XX-XXXX', 'g'); -- SSN
        v_masked := regexp_replace(v_masked, '\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}', 'XXXX-XXXX-XXXX-XXXX', 'g'); -- Credit card
        v_masked := regexp_replace(v_masked, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}', 'XXXXX@XXXXX.XXX', 'g'); -- Email
        v_masked := regexp_replace(v_masked, '\+?1?[\s.-]?\(?[0-9]{3}\)?[\s.-]?[0-9]{3}[\s.-]?[0-9]{4}', 'XXX-XXX-XXXX', 'g'); -- Phone
        
        -- Log PII access
        INSERT INTO pii_access_logs (
            tenant_id,
            user_id,
            resource_type,
            resource_id,
            access_type,
            purpose,
            data_categories,
            access_timestamp
        ) VALUES (
            v_tenant_id,
            v_user_id,
            'text_scan',
            v_job_id,
            'detection',
            'pii_scan',
            v_detected_pii,
            (NOW() AT TIME ZONE 'UTC')
        );
    END IF;
    
    -- Update job status
    UPDATE pii_processing_jobs SET
        status = 'completed',
        processed_records = 1,
        pii_found_count = jsonb_array_length(v_detected_pii),
        completed_at = (NOW() AT TIME ZONE 'UTC'),
        results = jsonb_build_object(
            'detected_types', v_detected_pii,
            'confidence', v_confidence,
            'masked_text', v_masked
        )
    WHERE id = v_job_id;
    
    RETURN QUERY
    SELECT 
        jsonb_array_length(v_detected_pii) > 0,
        v_detected_pii,
        v_confidence,
        v_masked,
        jsonb_build_object(
            'job_id', v_job_id,
            'timestamp', (NOW() AT TIME ZONE 'UTC'),
            'rules_checked', (SELECT COUNT(*) FROM pii_detection_rules WHERE is_active = TRUE)
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update PII processing job status
CREATE OR REPLACE FUNCTION sp_update_pii_job_status(
    p_job_id UUID,
    p_status VARCHAR(20),
    p_processed_records INTEGER DEFAULT NULL,
    p_pii_found_count INTEGER DEFAULT NULL,
    p_error_message TEXT DEFAULT NULL,
    p_results JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE pii_processing_jobs SET
        status = p_status,
        processed_records = COALESCE(p_processed_records, processed_records),
        pii_found_count = COALESCE(p_pii_found_count, pii_found_count),
        error_message = p_error_message,
        results = COALESCE(p_results, results),
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        completed_at = CASE 
            WHEN p_status IN ('completed', 'failed') THEN (NOW() AT TIME ZONE 'UTC')
            ELSE completed_at
        END
    WHERE id = p_job_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- QUILLT INTEGRATION PROCEDURES
-- ================================================================

-- Configure Quillt integration
CREATE OR REPLACE FUNCTION sp_configure_quillt_integration(
    p_user_id UUID,
    p_access_token TEXT,
    p_refresh_token TEXT DEFAULT NULL,
    p_environment VARCHAR(20) DEFAULT 'production',
    p_auto_sync BOOLEAN DEFAULT TRUE,
    p_sync_frequency INTEGER DEFAULT 24, -- hours
    p_metadata JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
    v_encrypted_token TEXT;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Simple encryption placeholder (in production, use proper encryption)
    v_encrypted_token := encode(pgp_sym_encrypt(p_access_token, 'encryption_key'), 'base64');
    
    -- Insert or update Quillt integration
    INSERT INTO quillt_integrations (
        tenant_id,
        user_id,
        quillt_user_id,
        access_token,
        refresh_token,
        token_expiry,
        is_active,
        sync_enabled,
        last_sync_at,
        sync_frequency_hours,
        metadata
    ) VALUES (
        v_tenant_id,
        p_user_id,
        p_metadata->>'quillt_user_id',
        v_encrypted_token,
        CASE WHEN p_refresh_token IS NOT NULL 
            THEN encode(pgp_sym_encrypt(p_refresh_token, 'encryption_key'), 'base64')
            ELSE NULL 
        END,
        ((NOW() AT TIME ZONE 'UTC') + INTERVAL '30 days'),
        TRUE,
        p_auto_sync,
        NULL,
        p_sync_frequency,
        p_metadata || jsonb_build_object('environment', p_environment)
    )
    ON CONFLICT (user_id) DO UPDATE SET
        access_token = EXCLUDED.access_token,
        refresh_token = EXCLUDED.refresh_token,
        token_expiry = EXCLUDED.token_expiry,
        is_active = TRUE,
        sync_enabled = p_auto_sync,
        sync_frequency_hours = p_sync_frequency,
        metadata = EXCLUDED.metadata,
        updated_at = (NOW() AT TIME ZONE 'UTC')
    RETURNING id INTO v_integration_id;
    
    -- Log configuration
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        metadata
    ) VALUES (
        v_tenant_id,
        p_user_id,
        'configure_integration',
        'quillt',
        v_integration_id,
        jsonb_build_object('environment', p_environment, 'auto_sync', p_auto_sync)
    );
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Sync Quillt data
CREATE OR REPLACE FUNCTION sp_sync_quillt_data(
    p_user_id UUID,
    p_sync_type VARCHAR(50) DEFAULT 'full',
    p_data_categories JSONB DEFAULT '["accounts", "transactions", "documents"]'
) RETURNS TABLE (
    sync_id UUID,
    status VARCHAR,
    records_synced INTEGER,
    sync_details JSONB
) AS $$
DECLARE
    v_integration_id UUID;
    v_webhook_id UUID;
    v_tenant_id INTEGER;
    v_records_count INTEGER := 0;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Get active integration
    SELECT id INTO v_integration_id
    FROM quillt_integrations
    WHERE user_id = p_user_id AND is_active = TRUE;
    
    IF v_integration_id IS NULL THEN
        RAISE EXCEPTION 'No active Quillt integration found';
    END IF;
    
    -- Create webhook log entry
    INSERT INTO quillt_webhook_logs (
        tenant_id,
        integration_id,
        webhook_type,
        event_id,
        event_timestamp,
        payload,
        processing_status,
        processed_at
    ) VALUES (
        v_tenant_id,
        v_integration_id,
        'sync_' || p_sync_type,
        gen_random_uuid()::TEXT,
        (NOW() AT TIME ZONE 'UTC'),
        jsonb_build_object(
            'sync_type', p_sync_type,
            'categories', p_data_categories,
            'initiated_by', p_user_id
        ),
        'processing',
        (NOW() AT TIME ZONE 'UTC')
    ) RETURNING id INTO v_webhook_id;
    
    -- Simulate sync process (in production, this would call Quillt API)
    -- For now, just update timestamps and counts
    v_records_count := floor(random() * 100 + 1)::INTEGER;
    
    -- Update last sync time
    UPDATE quillt_integrations SET
        last_sync_at = (NOW() AT TIME ZONE 'UTC'),
        metadata = metadata || jsonb_build_object(
            'last_sync_type', p_sync_type,
            'last_sync_records', v_records_count
        ),
        updated_at = (NOW() AT TIME ZONE 'UTC')
    WHERE id = v_integration_id;
    
    -- Update webhook log
    UPDATE quillt_webhook_logs SET
        processing_status = 'completed',
        processed_at = (NOW() AT TIME ZONE 'UTC'),
        response_data = jsonb_build_object(
            'records_synced', v_records_count,
            'categories_synced', p_data_categories
        )
    WHERE id = v_webhook_id;
    
    RETURN QUERY
    SELECT 
        v_webhook_id,
        'completed'::VARCHAR,
        v_records_count,
        jsonb_build_object(
            'integration_id', v_integration_id,
            'sync_type', p_sync_type,
            'categories', p_data_categories,
            'timestamp', (NOW() AT TIME ZONE 'UTC')
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Validate Quillt credentials
CREATE OR REPLACE FUNCTION sp_validate_quillt_credentials(
    p_user_id UUID,
    p_access_token TEXT DEFAULT NULL
) RETURNS TABLE (
    is_valid BOOLEAN,
    expires_at TIMESTAMP,
    validation_details JSONB
) AS $$
DECLARE
    v_integration RECORD;
    v_token_to_check TEXT;
BEGIN
    -- Get integration
    SELECT * INTO v_integration
    FROM quillt_integrations
    WHERE user_id = p_user_id AND is_active = TRUE;
    
    IF v_integration IS NULL THEN
        RETURN QUERY
        SELECT 
            FALSE,
            NULL::TIMESTAMP,
            jsonb_build_object('error', 'No active integration found');
        RETURN;
    END IF;
    
    -- Use provided token or stored token
    v_token_to_check := COALESCE(p_access_token, v_integration.access_token);
    
    -- Check token expiry
    IF v_integration.token_expiry < (NOW() AT TIME ZONE 'UTC') THEN
        -- Token expired
        UPDATE quillt_integrations SET
            is_active = FALSE,
            metadata = metadata || jsonb_build_object('deactivation_reason', 'token_expired'),
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration.id;
        
        RETURN QUERY
        SELECT 
            FALSE,
            v_integration.token_expiry,
            jsonb_build_object(
                'error', 'Token expired',
                'expired_at', v_integration.token_expiry
            );
    ELSE
        -- Token valid
        RETURN QUERY
        SELECT 
            TRUE,
            v_integration.token_expiry,
            jsonb_build_object(
                'integration_id', v_integration.id,
                'sync_enabled', v_integration.sync_enabled,
                'last_sync', v_integration.last_sync_at
            );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get Quillt sync status
CREATE OR REPLACE FUNCTION sp_get_quillt_sync_status(
    p_user_id UUID,
    p_days_back INTEGER DEFAULT 7
) RETURNS TABLE (
    integration_active BOOLEAN,
    last_sync_at TIMESTAMP,
    sync_frequency_hours INTEGER,
    recent_syncs JSONB,
    sync_statistics JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH integration_info AS (
        SELECT 
            qi.*
        FROM quillt_integrations qi
        WHERE qi.user_id = p_user_id
    ),
    recent_logs AS (
        SELECT 
            jsonb_agg(
                jsonb_build_object(
                    'timestamp', qwl.event_timestamp,
                    'type', qwl.webhook_type,
                    'status', qwl.processing_status,
                    'records', qwl.response_data->'records_synced'
                ) ORDER BY qwl.event_timestamp DESC
            ) as logs
        FROM quillt_webhook_logs qwl
        JOIN integration_info ii ON qwl.integration_id = ii.id
        WHERE qwl.event_timestamp > ((NOW() AT TIME ZONE 'UTC') - INTERVAL '1 day' * p_days_back)
    ),
    sync_stats AS (
        SELECT 
            COUNT(*) as total_syncs,
            COUNT(*) FILTER (WHERE qwl.processing_status = 'completed') as successful_syncs,
            COUNT(*) FILTER (WHERE qwl.processing_status = 'failed') as failed_syncs,
            AVG((qwl.response_data->>'records_synced')::INTEGER) as avg_records_per_sync
        FROM quillt_webhook_logs qwl
        JOIN integration_info ii ON qwl.integration_id = ii.id
        WHERE qwl.event_timestamp > ((NOW() AT TIME ZONE 'UTC') - INTERVAL '1 day' * p_days_back)
    )
    SELECT 
        ii.is_active,
        ii.last_sync_at,
        ii.sync_frequency_hours,
        rl.logs,
        jsonb_build_object(
            'total_syncs', ss.total_syncs,
            'successful_syncs', ss.successful_syncs,
            'failed_syncs', ss.failed_syncs,
            'avg_records_per_sync', ss.avg_records_per_sync,
            'period_days', p_days_back
        )
    FROM integration_info ii
    CROSS JOIN recent_logs rl
    CROSS JOIN sync_stats ss;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- REAL ESTATE INTEGRATION PROCEDURES
-- ================================================================

-- Sync real estate data
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_provider VARCHAR(50) DEFAULT 'zillow',
    p_property_ids UUID[] DEFAULT NULL,
    p_sync_all BOOLEAN DEFAULT FALSE,
    p_user_id UUID DEFAULT NULL
) RETURNS TABLE (
    sync_id UUID,
    properties_synced INTEGER,
    properties_updated INTEGER,
    sync_status VARCHAR,
    sync_details JSONB
) AS $$
DECLARE
    v_sync_id UUID;
    v_tenant_id INTEGER;
    v_user_id UUID;
    v_provider_id UUID;
    v_properties_synced INTEGER := 0;
    v_properties_updated INTEGER := 0;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Get provider integration
    SELECT id INTO v_provider_id
    FROM real_estate_provider_integrations
    WHERE provider_name = p_provider 
    AND tenant_id = v_tenant_id
    AND is_active = TRUE;
    
    IF v_provider_id IS NULL THEN
        -- Create provider integration if doesn't exist
        INSERT INTO real_estate_provider_integrations (
            tenant_id,
            provider_name,
            api_endpoint,
            api_key,
            is_active,
            rate_limit_per_hour,
            metadata
        ) VALUES (
            v_tenant_id,
            p_provider,
            'https://api.' || p_provider || '.com/v1',
            'placeholder_key',
            TRUE,
            1000,
            jsonb_build_object('auto_created', true)
        ) RETURNING id INTO v_provider_id;
    END IF;
    
    -- Create sync log
    INSERT INTO real_estate_sync_logs (
        tenant_id,
        provider_id,
        sync_type,
        sync_status,
        started_at,
        properties_synced,
        properties_updated,
        metadata
    ) VALUES (
        v_tenant_id,
        v_provider_id,
        CASE WHEN p_sync_all THEN 'full' ELSE 'partial' END,
        'in_progress',
        (NOW() AT TIME ZONE 'UTC'),
        0,
        0,
        jsonb_build_object(
            'initiated_by', v_user_id,
            'property_ids', p_property_ids
        )
    ) RETURNING id INTO v_sync_id;
    
    -- Simulate sync process
    IF p_sync_all THEN
        -- Sync all real estate properties
        UPDATE real_estate SET
            last_valuation_date = CURRENT_DATE,
            metadata = metadata || jsonb_build_object(
                'last_sync', (NOW() AT TIME ZONE 'UTC'),
                'sync_provider', p_provider
            ),
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE tenant_id = v_tenant_id;
        
        GET DIAGNOSTICS v_properties_updated = ROW_COUNT;
        v_properties_synced := v_properties_updated;
    ELSIF p_property_ids IS NOT NULL THEN
        -- Sync specific properties
        UPDATE real_estate SET
            last_valuation_date = CURRENT_DATE,
            metadata = metadata || jsonb_build_object(
                'last_sync', (NOW() AT TIME ZONE 'UTC'),
                'sync_provider', p_provider
            ),
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = ANY(p_property_ids)
        AND tenant_id = v_tenant_id;
        
        GET DIAGNOSTICS v_properties_updated = ROW_COUNT;
        v_properties_synced := array_length(p_property_ids, 1);
    END IF;
    
    -- Update sync log
    UPDATE real_estate_sync_logs SET
        sync_status = 'completed',
        completed_at = (NOW() AT TIME ZONE 'UTC'),
        properties_synced = v_properties_synced,
        properties_updated = v_properties_updated,
        metadata = metadata || jsonb_build_object(
            'duration_seconds', 
            EXTRACT(EPOCH FROM ((NOW() AT TIME ZONE 'UTC') - started_at))
        )
    WHERE id = v_sync_id;
    
    RETURN QUERY
    SELECT 
        v_sync_id,
        v_properties_synced,
        v_properties_updated,
        'completed'::VARCHAR,
        jsonb_build_object(
            'provider', p_provider,
            'sync_type', CASE WHEN p_sync_all THEN 'full' ELSE 'partial' END,
            'timestamp', (NOW() AT TIME ZONE 'UTC')
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get real estate sync history
CREATE OR REPLACE FUNCTION sp_get_real_estate_sync_history(
    p_provider VARCHAR(50) DEFAULT NULL,
    p_days_back INTEGER DEFAULT 30,
    p_limit INTEGER DEFAULT 100
) RETURNS TABLE (
    sync_id UUID,
    provider_name VARCHAR,
    sync_type VARCHAR,
    sync_status VARCHAR,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    properties_synced INTEGER,
    properties_updated INTEGER,
    error_count INTEGER,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sl.id,
        pi.provider_name,
        sl.sync_type,
        sl.sync_status,
        sl.started_at,
        sl.completed_at,
        sl.properties_synced,
        sl.properties_updated,
        sl.error_count,
        sl.metadata
    FROM real_estate_sync_logs sl
    JOIN real_estate_provider_integrations pi ON sl.provider_id = pi.id
    WHERE 
        (p_provider IS NULL OR pi.provider_name = p_provider)
        AND sl.started_at > ((NOW() AT TIME ZONE 'UTC') - INTERVAL '1 day' * p_days_back)
    ORDER BY sl.started_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- ADVISOR COMPANY MANAGEMENT PROCEDURES
-- ================================================================

-- Manage advisor company
CREATE OR REPLACE FUNCTION sp_manage_advisor_company(
    p_action VARCHAR(20), -- 'create', 'update', 'delete'
    p_company_id UUID DEFAULT NULL,
    p_company_name TEXT DEFAULT NULL,
    p_company_type VARCHAR(50) DEFAULT NULL,
    p_contact_email TEXT DEFAULT NULL,
    p_contact_phone VARCHAR(20) DEFAULT NULL,
    p_website TEXT DEFAULT NULL,
    p_address TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}',
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_company_id UUID;
    v_tenant_id INTEGER;
    v_user_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    CASE p_action
        WHEN 'create' THEN
            INSERT INTO advisor_companies (
                tenant_id,
                company_name,
                company_type,
                contact_email,
                contact_phone,
                website,
                address,
                is_active,
                metadata,
                created_by,
                updated_by
            ) VALUES (
                v_tenant_id,
                p_company_name,
                p_company_type,
                lower(p_contact_email),
                p_contact_phone,
                p_website,
                p_address,
                TRUE,
                p_metadata,
                v_user_id,
                v_user_id
            ) RETURNING id INTO v_company_id;
            
        WHEN 'update' THEN
            UPDATE advisor_companies SET
                company_name = COALESCE(p_company_name, company_name),
                company_type = COALESCE(p_company_type, company_type),
                contact_email = COALESCE(lower(p_contact_email), contact_email),
                contact_phone = COALESCE(p_contact_phone, contact_phone),
                website = COALESCE(p_website, website),
                address = COALESCE(p_address, address),
                metadata = metadata || p_metadata,
                updated_at = (NOW() AT TIME ZONE 'UTC'),
                updated_by = v_user_id
            WHERE id = p_company_id
            RETURNING id INTO v_company_id;
            
        WHEN 'delete' THEN
            UPDATE advisor_companies SET
                is_active = FALSE,
                metadata = metadata || jsonb_build_object(
                    'deactivated_at', (NOW() AT TIME ZONE 'UTC'),
                    'deactivated_by', v_user_id
                ),
                updated_at = (NOW() AT TIME ZONE 'UTC'),
                updated_by = v_user_id
            WHERE id = p_company_id
            RETURNING id INTO v_company_id;
            
        ELSE
            RAISE EXCEPTION 'Invalid action: %', p_action;
    END CASE;
    
    -- Log the action
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        metadata
    ) VALUES (
        v_tenant_id,
        v_user_id,
        p_action,
        'advisor_company',
        v_company_id,
        p_company_name,
        jsonb_build_object('action', p_action, 'changes', p_metadata)
    );
    
    RETURN v_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get advisor companies
CREATE OR REPLACE FUNCTION sp_get_advisor_companies(
    p_company_type VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE,
    p_search_term TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    company_id UUID,
    company_name VARCHAR,
    company_type VARCHAR,
    contact_email VARCHAR,
    contact_phone VARCHAR,
    website VARCHAR,
    address TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ac.id,
        ac.company_name,
        ac.company_type,
        ac.contact_email,
        ac.contact_phone,
        ac.website,
        ac.address,
        ac.is_active,
        ac.created_at,
        ac.metadata
    FROM advisor_companies ac
    WHERE 
        ac.tenant_id = current_tenant_id()
        AND (p_is_active IS NULL OR ac.is_active = p_is_active)
        AND (p_company_type IS NULL OR ac.company_type = p_company_type)
        AND (p_search_term IS NULL OR 
             ac.company_name ILIKE '%' || p_search_term || '%' OR
             ac.contact_email ILIKE '%' || p_search_term || '%' OR
             ac.address ILIKE '%' || p_search_term || '%')
    ORDER BY ac.company_name
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- INTEGRATION HEALTH MONITORING PROCEDURES
-- ================================================================

-- Check integration health
CREATE OR REPLACE FUNCTION sp_check_integration_health(
    p_integration_type VARCHAR(50) DEFAULT NULL -- 'quillt', 'builder', 'real_estate', or NULL for all
) RETURNS TABLE (
    integration_type VARCHAR,
    integration_name VARCHAR,
    is_healthy BOOLEAN,
    last_activity TIMESTAMP,
    error_rate DECIMAL,
    health_details JSONB
) AS $$
BEGIN
    -- Check Quillt integrations
    IF p_integration_type IS NULL OR p_integration_type = 'quillt' THEN
        RETURN QUERY
        SELECT 
            'quillt'::VARCHAR,
            'Quillt Integration'::VARCHAR,
            qi.is_active AND qi.token_expiry > (NOW() AT TIME ZONE 'UTC'),
            qi.last_sync_at,
            COALESCE(
                (SELECT COUNT(*) FILTER (WHERE processing_status = 'failed')::DECIMAL / NULLIF(COUNT(*), 0)
                 FROM quillt_webhook_logs 
                 WHERE integration_id = qi.id 
                 AND event_timestamp > ((NOW() AT TIME ZONE 'UTC') - INTERVAL '24 hours')),
                0
            ),
            jsonb_build_object(
                'active_integrations', COUNT(*),
                'expired_tokens', COUNT(*) FILTER (WHERE qi.token_expiry < (NOW() AT TIME ZONE 'UTC')),
                'sync_enabled', COUNT(*) FILTER (WHERE qi.sync_enabled = TRUE)
            )
        FROM quillt_integrations qi
        WHERE qi.tenant_id = current_tenant_id()
        GROUP BY qi.is_active, qi.token_expiry, qi.last_sync_at, qi.id;
    END IF;
    
    -- Check Builder.io integrations
    IF p_integration_type IS NULL OR p_integration_type = 'builder' THEN
        RETURN QUERY
        SELECT 
            'builder'::VARCHAR,
            'Builder.io Integration'::VARCHAR,
            bi.is_active,
            bi.last_sync_at,
            0::DECIMAL, -- No error tracking for builder yet
            jsonb_build_object(
                'api_key_present', bi.api_key IS NOT NULL,
                'space_id', bi.space_id,
                'environment', bi.environment
            )
        FROM builder_io_integrations bi
        WHERE bi.tenant_id = current_tenant_id();
    END IF;
    
    -- Check Real Estate integrations
    IF p_integration_type IS NULL OR p_integration_type = 'real_estate' THEN
        RETURN QUERY
        WITH recent_syncs AS (
            SELECT 
                pi.id,
                pi.provider_name,
                COUNT(*) as total_syncs,
                COUNT(*) FILTER (WHERE sl.sync_status = 'failed') as failed_syncs,
                MAX(sl.completed_at) as last_sync
            FROM real_estate_provider_integrations pi
            LEFT JOIN real_estate_sync_logs sl ON pi.id = sl.provider_id
                AND sl.started_at > ((NOW() AT TIME ZONE 'UTC') - INTERVAL '7 days')
            WHERE pi.tenant_id = current_tenant_id()
            GROUP BY pi.id, pi.provider_name
        )
        SELECT 
            'real_estate'::VARCHAR,
            'Real Estate - ' || rs.provider_name::VARCHAR,
            rs.failed_syncs = 0 OR rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0) < 0.1,
            rs.last_sync,
            COALESCE(rs.failed_syncs::DECIMAL / NULLIF(rs.total_syncs, 0), 0),
            jsonb_build_object(
                'provider', rs.provider_name,
                'total_syncs_7d', rs.total_syncs,
                'failed_syncs_7d', rs.failed_syncs
            )
        FROM recent_syncs rs;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Retry failed integration
CREATE OR REPLACE FUNCTION sp_retry_failed_integration(
    p_integration_type VARCHAR(50),
    p_integration_id UUID,
    p_retry_count INTEGER DEFAULT 1,
    p_user_id UUID DEFAULT NULL
) RETURNS TABLE (
    retry_successful BOOLEAN,
    retry_details JSONB
) AS $$
DECLARE
    v_user_id UUID;
    v_success BOOLEAN := FALSE;
    v_details JSONB;
BEGIN
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    CASE p_integration_type
        WHEN 'quillt' THEN
            -- Update webhook log to retry
            UPDATE quillt_webhook_logs SET
                processing_status = 'retrying',
                retry_count = COALESCE(retry_count, 0) + p_retry_count,
                metadata = metadata || jsonb_build_object(
                    'retry_initiated_by', v_user_id,
                    'retry_timestamp', (NOW() AT TIME ZONE 'UTC')
                )
            WHERE id = p_integration_id
            AND processing_status = 'failed';
            
            v_success := FOUND;
            v_details := jsonb_build_object(
                'integration_type', 'quillt',
                'webhook_id', p_integration_id,
                'retried', v_success
            );
            
        WHEN 'real_estate' THEN
            -- Retry real estate sync
            UPDATE real_estate_sync_logs SET
                sync_status = 'retrying',
                metadata = metadata || jsonb_build_object(
                    'retry_count', COALESCE((metadata->>'retry_count')::INTEGER, 0) + p_retry_count,
                    'retry_initiated_by', v_user_id,
                    'retry_timestamp', (NOW() AT TIME ZONE 'UTC')
                )
            WHERE id = p_integration_id
            AND sync_status = 'failed';
            
            v_success := FOUND;
            v_details := jsonb_build_object(
                'integration_type', 'real_estate',
                'sync_log_id', p_integration_id,
                'retried', v_success
            );
            
        ELSE
            v_details := jsonb_build_object(
                'error', 'Unknown integration type',
                'integration_type', p_integration_type
            );
    END CASE;
    
    -- Log retry attempt
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        metadata
    ) VALUES (
        current_tenant_id(),
        v_user_id,
        'retry_integration',
        p_integration_type,
        p_integration_id,
        v_details
    );
    
    RETURN QUERY SELECT v_success, v_details;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- BUILDER.IO INTEGRATION PROCEDURES
-- ================================================================

-- Configure Builder integration
CREATE OR REPLACE FUNCTION sp_configure_builder_integration(
    p_api_key TEXT,
    p_space_id TEXT,
    p_environment VARCHAR(20) DEFAULT 'production',
    p_model_names JSONB DEFAULT '["page", "section", "component"]',
    p_webhook_url TEXT DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
    v_user_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Insert or update Builder integration
    INSERT INTO builder_io_integrations (
        tenant_id,
        api_key,
        space_id,
        environment,
        model_names,
        webhook_url,
        is_active,
        created_by,
        updated_by
    ) VALUES (
        v_tenant_id,
        encode(pgp_sym_encrypt(p_api_key, 'encryption_key'), 'base64'),
        p_space_id,
        p_environment,
        p_model_names,
        p_webhook_url,
        TRUE,
        v_user_id,
        v_user_id
    )
    ON CONFLICT (tenant_id, space_id) DO UPDATE SET
        api_key = EXCLUDED.api_key,
        environment = p_environment,
        model_names = p_model_names,
        webhook_url = COALESCE(p_webhook_url, builder_io_integrations.webhook_url),
        is_active = TRUE,
        updated_at = (NOW() AT TIME ZONE 'UTC'),
        updated_by = v_user_id
    RETURNING id INTO v_integration_id;
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Refresh Builder content
CREATE OR REPLACE FUNCTION sp_refresh_builder_content(
    p_space_id TEXT,
    p_model_name VARCHAR(50) DEFAULT NULL,
    p_content_ids TEXT[] DEFAULT NULL
) RETURNS TABLE (
    refresh_id UUID,
    content_refreshed INTEGER,
    refresh_status VARCHAR,
    refresh_details JSONB
) AS $$
DECLARE
    v_integration_id UUID;
    v_refresh_id UUID;
    v_content_count INTEGER := 0;
BEGIN
    -- Get integration
    SELECT id INTO v_integration_id
    FROM builder_io_integrations
    WHERE space_id = p_space_id 
    AND tenant_id = current_tenant_id()
    AND is_active = TRUE;
    
    IF v_integration_id IS NULL THEN
        RAISE EXCEPTION 'No active Builder integration found for space %', p_space_id;
    END IF;
    
    v_refresh_id := gen_random_uuid();
    
    -- Simulate content refresh
    IF p_content_ids IS NOT NULL THEN
        v_content_count := array_length(p_content_ids, 1);
    ELSE
        v_content_count := floor(random() * 50 + 1)::INTEGER;
    END IF;
    
    -- Update last sync
    UPDATE builder_io_integrations SET
        last_sync_at = (NOW() AT TIME ZONE 'UTC'),
        content_cache = content_cache || jsonb_build_object(
            'last_refresh', (NOW() AT TIME ZONE 'UTC'),
            'last_refresh_count', v_content_count,
            'last_model', p_model_name
        ),
        updated_at = (NOW() AT TIME ZONE 'UTC')
    WHERE id = v_integration_id;
    
    RETURN QUERY
    SELECT 
        v_refresh_id,
        v_content_count,
        'completed'::VARCHAR,
        jsonb_build_object(
            'integration_id', v_integration_id,
            'space_id', p_space_id,
            'model_name', p_model_name,
            'content_ids', p_content_ids,
            'timestamp', (NOW() AT TIME ZONE 'UTC')
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get Builder content status
CREATE OR REPLACE FUNCTION sp_get_builder_content_status(
    p_space_id TEXT DEFAULT NULL
) RETURNS TABLE (
    space_id VARCHAR,
    environment VARCHAR,
    is_active BOOLEAN,
    last_sync_at TIMESTAMP,
    cached_content_count INTEGER,
    model_names JSONB,
    status_details JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bi.space_id,
        bi.environment,
        bi.is_active,
        bi.last_sync_at,
        COALESCE((bi.content_cache->>'last_refresh_count')::INTEGER, 0),
        bi.model_names,
        jsonb_build_object(
            'webhook_configured', bi.webhook_url IS NOT NULL,
            'cache_age_hours', 
            CASE 
                WHEN bi.last_sync_at IS NOT NULL THEN
                    EXTRACT(EPOCH FROM ((NOW() AT TIME ZONE 'UTC') - bi.last_sync_at)) / 3600
                ELSE NULL
            END,
            'integration_id', bi.id
        )
    FROM builder_io_integrations bi
    WHERE 
        bi.tenant_id = current_tenant_id()
        AND (p_space_id IS NULL OR bi.space_id = p_space_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- TRANSLATION MANAGEMENT PROCEDURES
-- ================================================================

-- Manage translation
CREATE OR REPLACE FUNCTION sp_manage_translation(
    p_action VARCHAR(20), -- 'create', 'update', 'delete'
    p_translation_id UUID DEFAULT NULL,
    p_entity_type VARCHAR(50) DEFAULT NULL,
    p_entity_id TEXT DEFAULT NULL,
    p_field_name TEXT DEFAULT NULL,
    p_language_code CHAR(2) DEFAULT NULL,
    p_translated_value TEXT DEFAULT NULL,
    p_is_verified BOOLEAN DEFAULT FALSE,
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_translation_id UUID;
    v_tenant_id INTEGER;
    v_user_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    CASE p_action
        WHEN 'create' THEN
            INSERT INTO translations (
                tenant_id,
                entity_type,
                entity_id,
                field_name,
                language_code,
                original_value,
                translated_value,
                is_machine_translated,
                is_verified,
                verified_by,
                verified_at
            ) VALUES (
                v_tenant_id,
                p_entity_type,
                p_entity_id,
                p_field_name,
                p_language_code,
                '', -- Original value would be fetched from source
                p_translated_value,
                FALSE,
                p_is_verified,
                CASE WHEN p_is_verified THEN v_user_id ELSE NULL END,
                CASE WHEN p_is_verified THEN (NOW() AT TIME ZONE 'UTC') ELSE NULL END
            ) RETURNING id INTO v_translation_id;
            
        WHEN 'update' THEN
            UPDATE translations SET
                translated_value = COALESCE(p_translated_value, translated_value),
                is_verified = p_is_verified,
                verified_by = CASE WHEN p_is_verified THEN v_user_id ELSE verified_by END,
                verified_at = CASE WHEN p_is_verified THEN (NOW() AT TIME ZONE 'UTC') ELSE verified_at END,
                updated_at = (NOW() AT TIME ZONE 'UTC')
            WHERE id = p_translation_id
            RETURNING id INTO v_translation_id;
            
        WHEN 'delete' THEN
            DELETE FROM translations 
            WHERE id = p_translation_id
            RETURNING id INTO v_translation_id;
            
        ELSE
            RAISE EXCEPTION 'Invalid action: %', p_action;
    END CASE;
    
    RETURN v_translation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get translations
CREATE OR REPLACE FUNCTION sp_get_translations(
    p_entity_type VARCHAR(50) DEFAULT NULL,
    p_entity_id TEXT DEFAULT NULL,
    p_language_code CHAR(2) DEFAULT NULL,
    p_only_verified BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    translation_id UUID,
    entity_type VARCHAR,
    entity_id VARCHAR,
    field_name VARCHAR,
    language_code CHAR,
    original_value TEXT,
    translated_value TEXT,
    is_verified BOOLEAN,
    verified_by UUID,
    verified_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.entity_type,
        t.entity_id,
        t.field_name,
        t.language_code,
        t.original_value,
        t.translated_value,
        t.is_verified,
        t.verified_by,
        t.verified_at
    FROM translations t
    WHERE 
        t.tenant_id = current_tenant_id()
        AND (p_entity_type IS NULL OR t.entity_type = p_entity_type)
        AND (p_entity_id IS NULL OR t.entity_id = p_entity_id)
        AND (p_language_code IS NULL OR t.language_code = p_language_code)
        AND (NOT p_only_verified OR t.is_verified = TRUE)
    ORDER BY t.entity_type, t.entity_id, t.field_name, t.language_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- SYSTEM CONFIGURATION PROCEDURE
-- ================================================================

-- Update system configuration
CREATE OR REPLACE FUNCTION sp_update_system_configuration(
    p_config_key TEXT,
    p_config_value JSONB,
    p_config_category VARCHAR(50) DEFAULT 'general',
    p_description TEXT DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_user_id UUID;
    v_old_value JSONB;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Get old value for audit
    SELECT metadata->p_config_key INTO v_old_value
    FROM tenants
    WHERE id = v_tenant_id;
    
    -- Update configuration in tenant metadata
    UPDATE tenants SET
        metadata = 
            CASE 
                WHEN metadata ? 'system_config' THEN
                    jsonb_set(
                        metadata,
                        ARRAY['system_config', p_config_category, p_config_key],
                        p_config_value,
                        true
                    )
                ELSE
                    metadata || jsonb_build_object(
                        'system_config', jsonb_build_object(
                            p_config_category, jsonb_build_object(
                                p_config_key, p_config_value
                            )
                        )
                    )
            END,
        updated_at = (NOW() AT TIME ZONE 'UTC')
    WHERE id = v_tenant_id;
    
    -- Log configuration change
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        old_values,
        new_values,
        metadata
    ) VALUES (
        v_tenant_id,
        v_user_id,
        'update_config',
        'system_configuration',
        gen_random_uuid(),
        p_config_key,
        jsonb_build_object(p_config_key, v_old_value),
        jsonb_build_object(p_config_key, p_config_value),
        jsonb_build_object(
            'category', p_config_category,
            'description', p_description
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- END OF COMPLETE STORED PROCEDURES AND RLS FILE
-- ================================================================