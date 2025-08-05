-- ================================================================
-- Forward Inheritance Platform - Stored Procedures (Corrected)
-- Fixed to work with normalized contact tables schema
-- ================================================================

-- ================================================================
-- AUTHENTICATION & USER MANAGEMENT
-- ================================================================

-- Drop existing functions first (to handle signature changes)
DROP FUNCTION IF EXISTS sp_register_user CASCADE;
DROP FUNCTION IF EXISTS sp_login_user CASCADE;
DROP FUNCTION IF EXISTS sp_verify_email CASCADE;
DROP FUNCTION IF EXISTS sp_verify_phone CASCADE;
DROP FUNCTION IF EXISTS sp_request_password_reset CASCADE;
DROP FUNCTION IF EXISTS sp_reset_password CASCADE;
DROP FUNCTION IF EXISTS sp_create_session CASCADE;
DROP FUNCTION IF EXISTS sp_refresh_session CASCADE;
DROP FUNCTION IF EXISTS sp_revoke_session CASCADE;

-- Register a new user with normalized contact information
CREATE OR REPLACE FUNCTION sp_register_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255),
    p_phone VARCHAR(20),
    p_password_hash VARCHAR(255),
    p_password_salt VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
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
    -- Start transaction
    -- Clean phone number (remove formatting)
    v_clean_phone := regexp_replace(p_phone, '[^0-9]', '', 'g');
    
    -- Create email address entry
    INSERT INTO email_address (
        tenant_id, email_address, is_verified, status
    ) VALUES (
        p_tenant_id, lower(p_email), FALSE, 'active'
    ) RETURNING id INTO v_email_id;
    
    -- Create phone number entry
    INSERT INTO phone_number (
        tenant_id, country_code, phone_number, is_verified, status
    ) VALUES (
        p_tenant_id, p_country_code, v_clean_phone, FALSE, 'active'
    ) RETURNING id INTO v_phone_id;
    
    -- Create user with references to contact entries
    INSERT INTO users (
        tenant_id, 
        primary_email_id, 
        primary_phone_id,
        password_hash,
        password_salt,
        first_name, 
        last_name,
        display_name,
        email_verified,
        phone_verified,
        status
    ) VALUES (
        p_tenant_id, 
        v_email_id,
        v_phone_id,
        p_password_hash,
        p_password_salt,
        p_first_name, 
        p_last_name,
        p_first_name || ' ' || p_last_name,
        FALSE,
        FALSE,
        'pending_verification'
    ) RETURNING id INTO v_user_id;
    
    -- Create usage records for email and phone
    INSERT INTO usage_email (
        tenant_id, entity_type, entity_id, email_id, usage_type, is_primary
    ) VALUES (
        p_tenant_id, 'user', v_user_id, v_email_id, 'primary', TRUE
    );
    
    INSERT INTO usage_phone (
        tenant_id, entity_type, entity_id, phone_id, usage_type, is_primary
    ) VALUES (
        p_tenant_id, 'user', v_user_id, v_phone_id, 'primary', TRUE
    );
    
    -- Create persona for the user
    INSERT INTO personas (
        tenant_id, user_id, first_name, last_name, status
    ) VALUES (
        p_tenant_id, v_user_id, p_first_name, p_last_name, 'active'
    ) RETURNING id INTO v_persona_id;
    
    -- Return the created IDs
    RETURN QUERY SELECT v_user_id, v_persona_id, v_email_id, v_phone_id;
END;
$$ LANGUAGE plpgsql;

-- Login user with email
CREATE OR REPLACE FUNCTION sp_login_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255)
) RETURNS TABLE (
    user_id UUID,
    password_hash VARCHAR(255),
    password_salt VARCHAR(255),
    status user_status_enum,
    account_locked BOOLEAN,
    failed_login_attempts INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.password_hash,
        u.password_salt,
        u.status,
        u.account_locked,
        u.failed_login_attempts
    FROM users u
    INNER JOIN email_address ea ON ea.id = u.primary_email_id
    WHERE ea.tenant_id = p_tenant_id 
      AND lower(ea.email_address) = lower(p_email)
      AND ea.status = 'active';
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FORWARD FAMILY CIRCLES (FFCs)
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_ffc CASCADE;
DROP FUNCTION IF EXISTS sp_add_ffc_member CASCADE;
DROP FUNCTION IF EXISTS sp_update_ffc_member_role CASCADE;
DROP FUNCTION IF EXISTS sp_remove_ffc_member CASCADE;

-- Create a new Forward Family Circle
CREATE OR REPLACE FUNCTION sp_create_ffc(
    p_tenant_id INTEGER,
    p_owner_user_id UUID,
    p_name VARCHAR(255),
    p_description TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_ffc_id UUID;
    v_owner_persona_id UUID;
BEGIN
    -- Get the owner's persona ID
    SELECT id INTO v_owner_persona_id
    FROM personas
    WHERE tenant_id = p_tenant_id AND user_id = p_owner_user_id
    LIMIT 1;
    
    IF v_owner_persona_id IS NULL THEN
        RAISE EXCEPTION 'Owner persona not found for user %', p_owner_user_id;
    END IF;
    
    -- Create the FFC
    INSERT INTO fwd_family_circles (
        tenant_id, owner_user_id, name, description, status
    ) VALUES (
        p_tenant_id, p_owner_user_id, p_name, p_description, 'active'
    ) RETURNING id INTO v_ffc_id;
    
    -- Add the owner as a member with 'owner' role
    INSERT INTO ffc_personas (
        tenant_id, ffc_id, persona_id, ffc_role, 
        can_view_all_assets, can_manage_assets, is_active
    ) VALUES (
        p_tenant_id, v_ffc_id, v_owner_persona_id, 'owner',
        TRUE, TRUE, TRUE
    );
    
    RETURN v_ffc_id;
END;
$$ LANGUAGE plpgsql;

-- Add a member to an FFC
CREATE OR REPLACE FUNCTION sp_add_ffc_member(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_persona_id UUID,
    p_role ffc_role_enum DEFAULT 'beneficiary',
    p_relationship family_relationship_enum DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Check if already a member
    IF EXISTS (
        SELECT 1 FROM ffc_personas 
        WHERE ffc_id = p_ffc_id AND persona_id = p_persona_id
    ) THEN
        RETURN FALSE;
    END IF;
    
    -- Add the member
    INSERT INTO ffc_personas (
        tenant_id, ffc_id, persona_id, ffc_role, 
        family_relationship, is_active
    ) VALUES (
        p_tenant_id, p_ffc_id, p_persona_id, p_role,
        p_relationship, TRUE
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- PERSONAS
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_persona CASCADE;

-- Create a new persona (for non-user family members)
CREATE OR REPLACE FUNCTION sp_create_persona(
    p_tenant_id INTEGER,
    p_first_name VARCHAR(255),
    p_last_name VARCHAR(255),
    p_date_of_birth DATE DEFAULT NULL,
    p_is_living BOOLEAN DEFAULT TRUE,
    p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_persona_id UUID;
BEGIN
    INSERT INTO personas (
        tenant_id, first_name, last_name, date_of_birth,
        is_living, status, created_by
    ) VALUES (
        p_tenant_id, p_first_name, p_last_name, p_date_of_birth,
        p_is_living, 'active', p_created_by
    ) RETURNING id INTO v_persona_id;
    
    RETURN v_persona_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ASSETS
-- ================================================================

DROP FUNCTION IF EXISTS sp_create_asset CASCADE;
DROP FUNCTION IF EXISTS sp_update_asset_value CASCADE;
DROP FUNCTION IF EXISTS sp_assign_asset_to_persona CASCADE;

-- Create a new asset
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_category_code VARCHAR(50),
    p_name VARCHAR(255),
    p_description TEXT DEFAULT NULL,
    p_acquisition_value DECIMAL(15,2) DEFAULT NULL,
    p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_category_id UUID;
    v_user_id UUID;
BEGIN
    -- Get category ID from code
    SELECT id INTO v_category_id
    FROM asset_categories
    WHERE code = p_category_code;
    
    IF v_category_id IS NULL THEN
        RAISE EXCEPTION 'Asset category % not found', p_category_code;
    END IF;
    
    -- Convert persona ID to user ID if p_created_by is provided
    IF p_created_by IS NOT NULL THEN
        SELECT user_id INTO v_user_id
        FROM personas
        WHERE id = p_created_by AND tenant_id = p_tenant_id;
        
        -- If no user found for the persona, set to NULL
        IF v_user_id IS NULL THEN
            v_user_id := NULL;
        END IF;
    ELSE
        v_user_id := NULL;
    END IF;
    
    -- Create the asset
    INSERT INTO assets (
        tenant_id, ffc_id, category_id, name, description,
        acquisition_value, current_value, status, created_by
    ) VALUES (
        p_tenant_id, p_ffc_id, v_category_id, p_name, p_description,
        p_acquisition_value, p_acquisition_value, 'active', v_user_id
    ) RETURNING id INTO v_asset_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Update asset value
CREATE OR REPLACE FUNCTION sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_value_date DATE DEFAULT CURRENT_DATE,
    p_updated_by UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant_id from asset for persona lookup
    SELECT tenant_id INTO v_tenant_id
    FROM assets
    WHERE id = p_asset_id;
    
    -- Convert persona ID to user ID if p_updated_by is provided
    IF p_updated_by IS NOT NULL AND v_tenant_id IS NOT NULL THEN
        SELECT user_id INTO v_user_id
        FROM personas
        WHERE id = p_updated_by AND tenant_id = v_tenant_id;
        
        -- If no user found for the persona, set to NULL
        IF v_user_id IS NULL THEN
            v_user_id := NULL;
        END IF;
    ELSE
        v_user_id := NULL;
    END IF;
    
    UPDATE assets
    SET current_value = p_new_value,
        value_as_of_date = p_value_date,
        updated_at = NOW(),
        updated_by = v_user_id
    WHERE id = p_asset_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Assign asset to persona with ownership details
CREATE OR REPLACE FUNCTION sp_assign_asset_to_persona(
    p_tenant_id INTEGER,
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum DEFAULT 'owner',
    p_ownership_percentage DECIMAL(5,2) DEFAULT 100.0,
    p_is_primary BOOLEAN DEFAULT TRUE,
    p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_assignment_id UUID;
    v_user_id UUID;
BEGIN
    -- Convert persona ID to user ID if p_created_by is provided
    IF p_created_by IS NOT NULL THEN
        SELECT user_id INTO v_user_id
        FROM personas
        WHERE id = p_created_by AND tenant_id = p_tenant_id;
        
        -- If no user found for the persona, set to NULL
        IF v_user_id IS NULL THEN
            v_user_id := NULL;
        END IF;
    ELSE
        v_user_id := NULL;
    END IF;
    
    -- Check if assignment already exists
    SELECT id INTO v_assignment_id
    FROM asset_persona
    WHERE asset_id = p_asset_id AND persona_id = p_persona_id;
    
    IF v_assignment_id IS NOT NULL THEN
        -- Update existing assignment
        UPDATE asset_persona
        SET ownership_type = p_ownership_type,
            ownership_percentage = p_ownership_percentage,
            is_primary = p_is_primary,
            updated_at = NOW(),
            updated_by = v_user_id
        WHERE id = v_assignment_id;
    ELSE
        -- Create new assignment
        INSERT INTO asset_persona (
            tenant_id, asset_id, persona_id, ownership_type,
            ownership_percentage, is_primary, created_by
        ) VALUES (
            p_tenant_id, p_asset_id, p_persona_id, p_ownership_type,
            p_ownership_percentage, p_is_primary, v_user_id
        ) RETURNING id INTO v_assignment_id;
    END IF;
    
    RETURN v_assignment_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- HELPER FUNCTIONS
-- ================================================================

-- Add email to persona
CREATE OR REPLACE FUNCTION sp_add_email_to_persona(
    p_tenant_id INTEGER,
    p_persona_id UUID,
    p_email VARCHAR(255),
    p_usage_type email_usage_type_enum DEFAULT 'personal',
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_email_id UUID;
    v_usage_id UUID;
BEGIN
    -- Check if email already exists
    SELECT id INTO v_email_id
    FROM email_address
    WHERE tenant_id = p_tenant_id AND lower(email_address) = lower(p_email);
    
    -- Create if doesn't exist
    IF v_email_id IS NULL THEN
        INSERT INTO email_address (tenant_id, email_address, status)
        VALUES (p_tenant_id, lower(p_email), 'active')
        RETURNING id INTO v_email_id;
    END IF;
    
    -- Create usage record
    INSERT INTO usage_email (
        tenant_id, entity_type, entity_id, email_id, usage_type, is_primary
    ) VALUES (
        p_tenant_id, 'persona', p_persona_id, v_email_id, p_usage_type, p_is_primary
    ) RETURNING id INTO v_usage_id;
    
    RETURN v_usage_id;
END;
$$ LANGUAGE plpgsql;

-- Add phone to persona
CREATE OR REPLACE FUNCTION sp_add_phone_to_persona(
    p_tenant_id INTEGER,
    p_persona_id UUID,
    p_phone VARCHAR(20),
    p_country_code VARCHAR(5) DEFAULT '+1',
    p_usage_type phone_usage_type_enum DEFAULT 'primary',
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_phone_id UUID;
    v_usage_id UUID;
    v_clean_phone VARCHAR(20);
BEGIN
    -- Clean phone number
    v_clean_phone := regexp_replace(p_phone, '[^0-9]', '', 'g');
    
    -- Check if phone already exists
    SELECT id INTO v_phone_id
    FROM phone_number
    WHERE tenant_id = p_tenant_id 
      AND country_code = p_country_code 
      AND phone_number = v_clean_phone;
    
    -- Create if doesn't exist
    IF v_phone_id IS NULL THEN
        INSERT INTO phone_number (tenant_id, country_code, phone_number, status)
        VALUES (p_tenant_id, p_country_code, v_clean_phone, 'active')
        RETURNING id INTO v_phone_id;
    END IF;
    
    -- Create usage record
    INSERT INTO usage_phone (
        tenant_id, entity_type, entity_id, phone_id, usage_type, is_primary
    ) VALUES (
        p_tenant_id, 'persona', p_persona_id, v_phone_id, p_usage_type, p_is_primary
    ) RETURNING id INTO v_usage_id;
    
    RETURN v_usage_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- AUDIT LOGGING
-- ================================================================

-- Log audit event
CREATE OR REPLACE FUNCTION sp_log_audit_event(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_action audit_action_enum,
    p_entity_type audit_entity_type_enum,
    p_entity_id UUID,
    p_entity_name VARCHAR(255) DEFAULT NULL,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_audit_id UUID;
BEGIN
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        entity_name, old_values, new_values, metadata
    ) VALUES (
        p_tenant_id, p_user_id, p_action, p_entity_type, p_entity_id,
        p_entity_name, p_old_values, p_new_values, p_metadata
    ) RETURNING id INTO v_audit_id;
    
    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ADDITIONAL STORED PROCEDURES (From architecture.md)
-- ================================================================

-- Verify email with normalized schema
CREATE OR REPLACE FUNCTION sp_verify_email(
    p_token UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_email_id UUID;
BEGIN
    -- Find valid token
    SELECT user_id INTO v_user_id
    FROM email_verifications
    WHERE token = p_token
    AND expires_at > CURRENT_TIMESTAMP
    AND used_at IS NULL;
    
    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update user
    UPDATE users
    SET email_verified = TRUE,
        status = CASE 
            WHEN phone_verified THEN 'active'
            ELSE status
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_user_id;
    
    -- Also mark the primary email as verified
    UPDATE email_address ea
    SET is_verified = TRUE
    FROM users u
    WHERE u.id = v_user_id
    AND ea.id = u.primary_email_id;
    
    -- Mark token as used
    UPDATE email_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE token = p_token;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Verify phone with normalized schema
CREATE OR REPLACE FUNCTION sp_verify_phone(
    p_user_id UUID,
    p_code VARCHAR(6)
) RETURNS BOOLEAN AS $$
DECLARE
    v_valid BOOLEAN;
BEGIN
    -- Check if code is valid
    SELECT EXISTS (
        SELECT 1 FROM phone_verifications
        WHERE user_id = p_user_id
        AND code = p_code
        AND expires_at > CURRENT_TIMESTAMP
        AND used_at IS NULL
    ) INTO v_valid;
    
    IF NOT v_valid THEN
        RETURN FALSE;
    END IF;
    
    -- Update user
    UPDATE users
    SET phone_verified = TRUE,
        status = CASE 
            WHEN email_verified THEN 'active'
            ELSE status
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_user_id;
    
    -- Also mark the primary phone as verified
    UPDATE phone_number pn
    SET is_verified = TRUE
    FROM users u
    WHERE u.id = p_user_id
    AND pn.id = u.primary_phone_id;
    
    -- Mark code as used
    UPDATE phone_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id
    AND code = p_code;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Request password reset with normalized schema
CREATE OR REPLACE FUNCTION sp_request_password_reset(
    p_email VARCHAR(255)
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_token UUID;
BEGIN
    -- Get user from email address table
    SELECT u.id INTO v_user_id
    FROM users u
    INNER JOIN email_address ea ON ea.id = u.primary_email_id
    WHERE lower(ea.email_address) = lower(p_email)
    AND u.status != 'deleted';
    
    IF v_user_id IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Create reset token
    v_token := gen_random_uuid();
    INSERT INTO password_reset_tokens (
        user_id, token, expires_at
    ) VALUES (
        v_user_id, v_token, 
        CURRENT_TIMESTAMP + INTERVAL '1 hour'
    );
    
    RETURN v_token;
END;
$$ LANGUAGE plpgsql;

-- Reset password
CREATE OR REPLACE FUNCTION sp_reset_password(
    p_token UUID,
    p_new_password_hash VARCHAR(255),
    p_new_password_salt VARCHAR(255)
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Find valid token
    SELECT user_id INTO v_user_id
    FROM password_reset_tokens
    WHERE token = p_token
    AND expires_at > CURRENT_TIMESTAMP
    AND used_at IS NULL;
    
    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update password
    UPDATE users
    SET password_hash = p_new_password_hash,
        password_salt = p_new_password_salt,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_user_id;
    
    -- Mark token as used
    UPDATE password_reset_tokens
    SET used_at = CURRENT_TIMESTAMP
    WHERE token = p_token;
    
    -- Invalidate all sessions
    UPDATE user_sessions
    SET is_active = FALSE
    WHERE user_id = v_user_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Create session
CREATE OR REPLACE FUNCTION sp_create_session(
    p_user_id UUID,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_session_token UUID;
BEGIN
    v_session_token := gen_random_uuid();
    
    INSERT INTO user_sessions (
        user_id, session_token, ip_address, user_agent,
        device_info, expires_at
    ) VALUES (
        p_user_id, v_session_token, p_ip_address, p_user_agent,
        p_device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
    );
    
    RETURN v_session_token;
END;
$$ LANGUAGE plpgsql;

-- Refresh session
CREATE OR REPLACE FUNCTION sp_refresh_session(
    p_session_token UUID
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_new_token UUID;
    v_ip_address INET;
    v_user_agent TEXT;
    v_device_info JSONB;
BEGIN
    -- Get user from valid session
    SELECT user_id, ip_address, user_agent, device_info 
    INTO v_user_id, v_ip_address, v_user_agent, v_device_info
    FROM user_sessions
    WHERE session_token = p_session_token
    AND is_active = TRUE
    AND expires_at > CURRENT_TIMESTAMP;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Invalid or expired session';
    END IF;
    
    -- Invalidate old session
    UPDATE user_sessions
    SET is_active = FALSE
    WHERE session_token = p_session_token;
    
    -- Create new session
    v_new_token := gen_random_uuid();
    INSERT INTO user_sessions (
        user_id, session_token, ip_address, user_agent,
        device_info, expires_at
    ) VALUES (
        v_user_id, v_new_token, v_ip_address, v_user_agent,
        v_device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
    );
    
    RETURN v_new_token;
END;
$$ LANGUAGE plpgsql;

-- Revoke session
CREATE OR REPLACE FUNCTION sp_revoke_session(
    p_session_token UUID
) RETURNS VOID AS $$
BEGIN
    UPDATE user_sessions
    SET is_active = FALSE,
        revoked_at = CURRENT_TIMESTAMP
    WHERE session_token = p_session_token;
END;
$$ LANGUAGE plpgsql;

-- Update FFC member role
CREATE OR REPLACE FUNCTION sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_new_role ffc_role_enum,
    p_updated_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_old_role ffc_role_enum;
    v_tenant_id INTEGER;
BEGIN
    -- Get current role and tenant
    SELECT fm.ffc_role, f.tenant_id
    INTO v_old_role, v_tenant_id
    FROM ffc_personas fm
    JOIN fwd_family_circles f ON f.id = fm.ffc_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.persona_id = p_persona_id;
    
    IF v_old_role IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update role
    UPDATE ffc_personas
    SET ffc_role = p_new_role,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND persona_id = p_persona_id;
    
    -- Log change
    PERFORM sp_log_audit_event(
        v_tenant_id, p_updated_by, 'update'::audit_action_enum, 
        'ffc'::audit_entity_type_enum, p_ffc_id,
        'FFC member role updated',
        jsonb_build_object('role', v_old_role::text),
        jsonb_build_object('role', p_new_role::text),
        jsonb_build_object(
            'persona_id', p_persona_id,
            'old_role', v_old_role::text,
            'new_role', p_new_role::text
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Remove FFC member
CREATE OR REPLACE FUNCTION sp_remove_ffc_member(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_removed_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM fwd_family_circles
    WHERE id = p_ffc_id;
    
    -- Soft delete member (set is_active to false)
    UPDATE ffc_personas
    SET is_active = FALSE,
        left_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND persona_id = p_persona_id;
    
    -- Log removal
    PERFORM sp_log_audit_event(
        v_tenant_id, p_removed_by, 'delete'::audit_action_enum,
        'ffc'::audit_entity_type_enum, p_ffc_id,
        'FFC member removed',
        NULL, NULL,
        jsonb_build_object('removed_persona_id', p_persona_id)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Link personas (create relationship)
CREATE OR REPLACE FUNCTION sp_link_personas(
    p_persona1_id UUID,
    p_persona2_id UUID,
    p_relationship family_relationship_enum,
    p_created_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM personas
    WHERE id = p_persona1_id;
    
    -- Create bidirectional relationship
    INSERT INTO persona_relationships (
        tenant_id, persona_id, related_persona_id, relationship_type
    ) VALUES
        (v_tenant_id, p_persona1_id, p_persona2_id, p_relationship),
        (v_tenant_id, p_persona2_id, p_persona1_id, p_relationship)
    ON CONFLICT (persona_id, related_persona_id) DO UPDATE
    SET relationship_type = EXCLUDED.relationship_type;
    
    -- Log relationship
    PERFORM sp_log_audit_event(
        v_tenant_id, p_created_by, 'create'::audit_action_enum,
        'persona'::audit_entity_type_enum, p_persona1_id,
        'Personas linked',
        NULL, NULL,
        jsonb_build_object(
            'persona2_id', p_persona2_id,
            'relationship', p_relationship::text
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Create real estate asset
CREATE OR REPLACE FUNCTION sp_create_real_estate(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_property_type property_type_enum,
    p_property_use property_use_enum,
    p_description TEXT,
    p_purchase_date DATE,
    p_purchase_price DECIMAL(15,2),
    p_current_value DECIMAL(15,2),
    p_address_id UUID,
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_real_estate_id UUID;
BEGIN
    -- Create base asset
    v_asset_id := sp_create_asset(
        p_tenant_id, p_ffc_id, 'real_estate',
        p_property_type::TEXT || ' - ' || COALESCE(p_description, 'Property'),
        p_description, p_purchase_price, p_created_by
    );
    
    -- Create real estate specific record
    INSERT INTO real_estate (
        id, asset_id, property_type, property_use,
        description, purchase_date, purchase_price, current_value,
        address_id
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_property_type, p_property_use,
        p_description, p_purchase_date, p_purchase_price, p_current_value,
        p_address_id
    ) RETURNING id INTO v_real_estate_id;
    
    -- Update asset value if different from purchase price
    IF p_current_value != p_purchase_price THEN
        PERFORM sp_update_asset_value(v_asset_id, p_current_value, CURRENT_DATE, p_created_by);
    END IF;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Create financial account asset
CREATE OR REPLACE FUNCTION sp_create_financial_account(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_account_type account_type_enum,
    p_institution_name VARCHAR(255),
    p_account_number VARCHAR(50),
    p_current_balance DECIMAL(15,2),
    p_currency VARCHAR(3),
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
    v_account_id UUID;
BEGIN
    -- Create base asset
    v_asset_id := sp_create_asset(
        p_tenant_id, p_ffc_id, 'financial_accounts',
        p_account_type::TEXT || ' - ' || p_institution_name,
        'Financial account at ' || p_institution_name,
        p_current_balance,
        p_created_by
    );
    
    -- Create financial account specific record
    INSERT INTO financial_accounts (
        id, asset_id, account_type,
        institution_name, account_number, current_balance,
        currency
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_account_type,
        p_institution_name, p_account_number, p_current_balance,
        p_currency
    ) RETURNING id INTO v_account_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Delete asset (soft delete)
CREATE OR REPLACE FUNCTION sp_delete_asset(
    p_asset_id UUID,
    p_deleted_by UUID,
    p_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_asset_name VARCHAR(255);
BEGIN
    -- Get tenant ID and asset name
    SELECT tenant_id, name INTO v_tenant_id, v_asset_name
    FROM assets
    WHERE id = p_asset_id;
    
    IF v_tenant_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Soft delete asset
    UPDATE assets
    SET status = 'deleted',
        updated_at = CURRENT_TIMESTAMP,
        updated_by = p_deleted_by
    WHERE id = p_asset_id;
    
    -- Log deletion
    PERFORM sp_log_audit_event(
        v_tenant_id, p_deleted_by, 'delete'::audit_action_enum,
        'asset'::audit_entity_type_enum, p_asset_id,
        v_asset_name,
        NULL, NULL,
        jsonb_build_object('reason', p_reason)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Mark audit events as sent in weekly report
CREATE OR REPLACE FUNCTION sp_mark_audit_events_sent(
    p_ffc_id UUID,
    p_report_date DATE
) RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Update audit log entries
    UPDATE audit_log
    SET metadata = metadata || jsonb_build_object('report_sent_date', p_report_date)
    WHERE entity_type = 'ffc'
    AND entity_id = p_ffc_id
    AND created_at < p_report_date
    AND (metadata->>'report_sent_date') IS NULL;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Sync Quillt financial data
CREATE OR REPLACE FUNCTION sp_sync_quillt_data(
    p_user_id UUID,
    p_quillt_data JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
    v_sync_log_id UUID;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM users
    WHERE id = p_user_id;
    
    -- Get or create integration record
    SELECT id INTO v_integration_id
    FROM quillt_integrations
    WHERE user_id = p_user_id;
    
    IF v_integration_id IS NULL THEN
        INSERT INTO quillt_integrations (
            user_id, quillt_user_id, connection_status
        ) VALUES (
            p_user_id, 
            p_quillt_data->>'quillt_user_id',
            'active'
        ) RETURNING id INTO v_integration_id;
    END IF;
    
    -- Update last sync
    UPDATE quillt_integrations
    SET last_sync_at = CURRENT_TIMESTAMP,
        sync_data = p_quillt_data
    WHERE id = v_integration_id;
    
    -- Log sync
    INSERT INTO quillt_sync_logs (
        integration_id, sync_type, sync_status, 
        records_synced, sync_metadata
    ) VALUES (
        v_integration_id, 'financial_accounts', 'completed',
        (p_quillt_data->>'account_count')::INTEGER,
        p_quillt_data
    ) RETURNING id INTO v_sync_log_id;
    
    -- Create audit log
    PERFORM sp_log_audit_event(
        v_tenant_id, p_user_id, 'sync'::audit_action_enum,
        'user'::audit_entity_type_enum, p_user_id,
        'Quillt data synced',
        NULL, NULL,
        jsonb_build_object(
            'sync_log_id', v_sync_log_id,
            'accounts_synced', p_quillt_data->>'account_count'
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Sync real estate valuation data
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_real_estate_id UUID,
    p_provider_name VARCHAR(100),
    p_property_data JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    v_sync_log_id UUID;
    v_old_value DECIMAL(15,2);
    v_new_value DECIMAL(15,2);
    v_asset_id UUID;
    v_tenant_id INTEGER;
BEGIN
    -- Get asset ID, current value, and tenant
    SELECT re.asset_id, re.current_value, a.tenant_id
    INTO v_asset_id, v_old_value, v_tenant_id
    FROM real_estate re
    JOIN assets a ON a.id = re.asset_id
    WHERE re.id = p_real_estate_id;
    
    IF v_asset_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update real estate data
    v_new_value := (p_property_data->>'estimated_value')::DECIMAL(15,2);
    
    UPDATE real_estate
    SET current_value = v_new_value,
        last_valuation_date = CURRENT_DATE,
        metadata = COALESCE(metadata, '{}'::jsonb) || p_property_data
    WHERE id = p_real_estate_id;
    
    -- Log sync
    INSERT INTO real_estate_sync_logs (
        real_estate_id, provider_name, sync_type,
        sync_status, property_data
    ) VALUES (
        p_real_estate_id, p_provider_name, 'valuation',
        'completed', p_property_data
    ) RETURNING id INTO v_sync_log_id;
    
    -- Create audit event if value changed
    IF v_old_value != v_new_value THEN
        PERFORM sp_log_audit_event(
            v_tenant_id, NULL, 'update'::audit_action_enum,
            'asset'::audit_entity_type_enum, v_asset_id,
            'Real estate value synced',
            jsonb_build_object('value', v_old_value),
            jsonb_build_object('value', v_new_value),
            jsonb_build_object(
                'provider', p_provider_name,
                'sync_log_id', v_sync_log_id
            )
        );
        
        -- Also update the asset value
        PERFORM sp_update_asset_value(v_asset_id, v_new_value, CURRENT_DATE, NULL);
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Process PII masking job
CREATE OR REPLACE FUNCTION sp_process_pii_masking(
    p_job_id UUID,
    p_detected_pii JSONB,
    p_masked_file_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_media_id UUID;
    v_status processing_status_enum;
BEGIN
    -- Get media ID
    SELECT media_storage_id INTO v_media_id
    FROM pii_processing_jobs
    WHERE id = p_job_id;
    
    IF v_media_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update job status
    UPDATE pii_processing_jobs
    SET status = CASE 
            WHEN p_masked_file_id IS NOT NULL THEN 'completed'::processing_status_enum
            ELSE 'failed'::processing_status_enum
        END,
        detected_pii = p_detected_pii,
        masked_file_id = p_masked_file_id,
        completed_at = CURRENT_TIMESTAMP
    WHERE id = p_job_id;
    
    -- Update media storage PII flags
    UPDATE media_storage
    SET contains_pii = (p_detected_pii IS NOT NULL AND jsonb_array_length(p_detected_pii) > 0),
        pii_masked_version_id = p_masked_file_id
    WHERE id = v_media_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Update Builder.io content
CREATE OR REPLACE FUNCTION sp_update_builder_content(
    p_page_name VARCHAR(255),
    p_builder_content_id VARCHAR(255),
    p_content_data JSONB,
    p_updated_by UUID
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant from user
    SELECT tenant_id INTO v_tenant_id
    FROM users
    WHERE id = p_updated_by;
    
    -- Upsert Builder.io integration record
    INSERT INTO builder_io_integrations (
        tenant_id, page_name, builder_content_id, content_data, 
        last_updated_by
    ) VALUES (
        v_tenant_id, p_page_name, p_builder_content_id, p_content_data,
        p_updated_by
    )
    ON CONFLICT (tenant_id, page_name) DO UPDATE
    SET builder_content_id = EXCLUDED.builder_content_id,
        content_data = EXCLUDED.content_data,
        last_sync_at = CURRENT_TIMESTAMP,
        last_updated_by = EXCLUDED.last_updated_by
    RETURNING id INTO v_integration_id;
    
    -- Log update
    PERFORM sp_log_audit_event(
        v_tenant_id, p_updated_by, 'update'::audit_action_enum,
        'asset'::audit_entity_type_enum, v_integration_id,
        'Builder.io content updated',
        NULL, NULL,
        jsonb_build_object(
            'page_name', p_page_name,
            'content_id', p_builder_content_id
        )
    );
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql;

-- Bulk update asset ownership percentages
CREATE OR REPLACE FUNCTION sp_bulk_update_asset_ownership(
    p_updates JSONB,
    p_updated_by UUID
) RETURNS INTEGER AS $$
DECLARE
    v_update JSONB;
    v_count INTEGER := 0;
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant from user
    SELECT tenant_id INTO v_tenant_id
    FROM users
    WHERE id = p_updated_by;
    
    -- Process each update
    FOR v_update IN SELECT * FROM jsonb_array_elements(p_updates)
    LOOP
        UPDATE asset_persona
        SET ownership_percentage = (v_update->>'ownership_percentage')::DECIMAL(5,2),
            ownership_type = (v_update->>'ownership_type')::ownership_type_enum,
            updated_at = CURRENT_TIMESTAMP,
            updated_by = p_updated_by
        WHERE asset_id = (v_update->>'asset_id')::UUID
        AND persona_id = (v_update->>'persona_id')::UUID;
        
        v_count := v_count + 1;
    END LOOP;
    
    -- Log bulk update
    PERFORM sp_log_audit_event(
        v_tenant_id, p_updated_by, 'update'::audit_action_enum,
        'asset'::audit_entity_type_enum, NULL,
        'Bulk ownership update',
        NULL, NULL,
        jsonb_build_object('updates_count', v_count)
    );
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Process FFC invitation
CREATE OR REPLACE FUNCTION sp_process_invitation(
    p_invitation_id UUID,
    p_action VARCHAR(20), -- 'accept', 'decline', 'cancel'
    p_user_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_invitation RECORD;
    v_new_status invitation_status_enum;
    v_persona_id UUID;
BEGIN
    -- Get invitation details
    SELECT * INTO v_invitation
    FROM invitations
    WHERE id = p_invitation_id;
    
    IF v_invitation.id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Determine new status
    v_new_status := CASE p_action
        WHEN 'accept' THEN 'accepted'::invitation_status_enum
        WHEN 'decline' THEN 'declined'::invitation_status_enum
        WHEN 'cancel' THEN 'cancelled'::invitation_status_enum
        ELSE v_invitation.status
    END;
    
    -- Update invitation
    UPDATE invitations
    SET status = v_new_status,
        responded_at = CASE 
            WHEN p_action IN ('accept', 'decline') THEN CURRENT_TIMESTAMP
            ELSE responded_at
        END
    WHERE id = p_invitation_id;
    
    -- If accepted, add to FFC
    IF p_action = 'accept' AND p_user_id IS NOT NULL THEN
        -- Get persona for user
        SELECT id INTO v_persona_id
        FROM personas
        WHERE user_id = p_user_id
        AND tenant_id = v_invitation.tenant_id
        LIMIT 1;
        
        IF v_persona_id IS NOT NULL THEN
            PERFORM sp_add_ffc_member(
                v_invitation.tenant_id,
                v_invitation.ffc_id,
                v_persona_id,
                v_invitation.role
            );
        END IF;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- End of corrected stored procedures
-- ================================================================