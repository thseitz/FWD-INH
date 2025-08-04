-- ================================================================
-- SQL Test Script 6 - Stored Procedures and Functions
-- ================================================================
-- This script contains all stored procedures and functions
-- from architecture.md to complete the Forward DB
-- Execute this after SQL_Test_5.sql
-- ================================================================

-- ================================================================
-- AUTHENTICATION AND USER MANAGEMENT PROCEDURES
-- ================================================================

-- Register new user
CREATE OR REPLACE FUNCTION sp_register_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255),
    p_phone VARCHAR(20),
    p_password_hash TEXT,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_referral_code VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    user_id UUID,
    persona_id UUID,
    verification_token UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_persona_id UUID;
    v_verification_token UUID;
BEGIN
    -- Create user
    INSERT INTO users (
        tenant_id, email, phone, password_hash, 
        email_verified, phone_verified, status
    ) VALUES (
        p_tenant_id, p_email, p_phone, p_password_hash,
        FALSE, FALSE, 'pending_verification'
    ) RETURNING users.user_id INTO v_user_id;
    
    -- Create default persona
    INSERT INTO personas (
        tenant_id, user_id, first_name, last_name,
        is_primary, status
    ) VALUES (
        p_tenant_id, v_user_id, p_first_name, p_last_name,
        TRUE, 'active'
    ) RETURNING personas.persona_id INTO v_persona_id;
    
    -- Create verification token
    v_verification_token := gen_random_uuid();
    INSERT INTO email_verifications (
        user_id, token, expires_at
    ) VALUES (
        v_user_id, v_verification_token, 
        CURRENT_TIMESTAMP + INTERVAL '24 hours'
    );
    
    -- Log registration event
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        p_tenant_id, v_user_id, 'user_registered', 'user', v_user_id,
        jsonb_build_object('referral_code', p_referral_code)
    );
    
    RETURN QUERY SELECT v_user_id, v_persona_id, v_verification_token;
END;
$$ LANGUAGE plpgsql;

-- User login
CREATE OR REPLACE FUNCTION sp_login_user(
    p_email VARCHAR(255),
    p_password_hash TEXT,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT NULL
) RETURNS TABLE (
    user_id UUID,
    tenant_id INTEGER,
    mfa_required BOOLEAN,
    session_token UUID
) AS $$
DECLARE
    v_user_id UUID;
    v_tenant_id INTEGER;
    v_mfa_required BOOLEAN;
    v_session_token UUID;
    v_password_valid BOOLEAN;
BEGIN
    -- Get user info
    SELECT u.user_id, u.tenant_id, u.mfa_enabled, 
           u.password_hash = p_password_hash
    INTO v_user_id, v_tenant_id, v_mfa_required, v_password_valid
    FROM users u
    WHERE u.email = p_email
    AND u.status = 'active';
    
    -- Log login attempt
    INSERT INTO user_login_history (
        user_id, ip_address, user_agent, device_info,
        attempt_time, success
    ) VALUES (
        v_user_id, p_ip_address, p_user_agent, p_device_info,
        CURRENT_TIMESTAMP, v_password_valid
    );
    
    IF NOT v_password_valid THEN
        RAISE EXCEPTION 'Invalid credentials';
    END IF;
    
    -- Create session if no MFA required
    IF NOT v_mfa_required THEN
        v_session_token := gen_random_uuid();
        INSERT INTO user_sessions (
            user_id, session_token, ip_address, user_agent,
            device_info, expires_at
        ) VALUES (
            v_user_id, v_session_token, p_ip_address, p_user_agent,
            p_device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
        );
    END IF;
    
    RETURN QUERY SELECT v_user_id, v_tenant_id, v_mfa_required, v_session_token;
END;
$$ LANGUAGE plpgsql;

-- Verify email
CREATE OR REPLACE FUNCTION sp_verify_email(
    p_token UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
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
    WHERE user_id = v_user_id;
    
    -- Mark token as used
    UPDATE email_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE token = p_token;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Verify phone
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
    WHERE user_id = p_user_id;
    
    -- Mark code as used
    UPDATE phone_verifications
    SET used_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id
    AND code = p_code;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Request password reset
CREATE OR REPLACE FUNCTION sp_request_password_reset(
    p_email VARCHAR(255)
) RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
    v_token UUID;
BEGIN
    -- Get user
    SELECT user_id INTO v_user_id
    FROM users
    WHERE email = p_email
    AND status != 'deleted';
    
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
    p_new_password_hash TEXT
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
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = v_user_id;
    
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

-- Check user permission
CREATE OR REPLACE FUNCTION fn_check_user_permission(
    p_user_id UUID,
    p_ffc_id UUID,
    p_permission_name VARCHAR(100)
) RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM ffc_members fm
        JOIN role_permissions rp ON rp.role_id = fm.role_id
        JOIN permissions p ON p.permission_id = rp.permission_id
        WHERE fm.user_id = p_user_id
        AND fm.ffc_id = p_ffc_id
        AND p.permission_name = p_permission_name
        AND fm.status = 'active'
    );
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
BEGIN
    -- Get user from valid session
    SELECT user_id INTO v_user_id
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
    )
    SELECT user_id, v_new_token, ip_address, user_agent,
           device_info, CURRENT_TIMESTAMP + INTERVAL '7 days'
    FROM user_sessions
    WHERE session_token = p_session_token;
    
    RETURN v_new_token;
END;
$$ LANGUAGE plpgsql;

-- Validate session
CREATE OR REPLACE FUNCTION fn_validate_session(
    p_session_token UUID
) RETURNS TABLE (
    user_id UUID,
    tenant_id INTEGER,
    is_valid BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.user_id, u.tenant_id, TRUE AS is_valid
    FROM user_sessions s
    JOIN users u ON u.user_id = s.user_id
    WHERE s.session_token = p_session_token
    AND s.is_active = TRUE
    AND s.expires_at > CURRENT_TIMESTAMP
    AND u.status = 'active';
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

-- ================================================================
-- UTILITY FUNCTIONS
-- ================================================================

-- Get current tenant ID from session
CREATE OR REPLACE FUNCTION fn_get_current_tenant_id() 
RETURNS INTEGER AS $$
BEGIN
    -- This would typically be set by the application layer
    -- using SET LOCAL or similar mechanism
    RETURN current_setting('app.current_tenant_id')::INTEGER;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No tenant context set';
END;
$$ LANGUAGE plpgsql;

-- Get current user ID from session
CREATE OR REPLACE FUNCTION fn_get_current_user_id() 
RETURNS UUID AS $$
BEGIN
    -- This would typically be set by the application layer
    -- using SET LOCAL or similar mechanism
    RETURN current_setting('app.current_user_id')::UUID;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'No user context set';
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FFC MANAGEMENT PROCEDURES
-- ================================================================

-- Create FFC
CREATE OR REPLACE FUNCTION sp_create_ffc(
    p_tenant_id INTEGER,
    p_name VARCHAR(100),
    p_description TEXT,
    p_created_by UUID
) RETURNS UUID AS $$
DECLARE
    v_ffc_id UUID;
BEGIN
    -- Create FFC
    INSERT INTO fwd_family_circles (
        tenant_id, name, description, created_by
    ) VALUES (
        p_tenant_id, p_name, p_description, p_created_by
    ) RETURNING ffc_id INTO v_ffc_id;
    
    -- Add creator as owner
    INSERT INTO ffc_members (
        ffc_id, user_id, role_id, invited_by, joined_at, status
    ) 
    SELECT v_ffc_id, p_created_by, role_id, p_created_by, CURRENT_TIMESTAMP, 'active'
    FROM roles 
    WHERE role_name = 'owner' AND tenant_id = p_tenant_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id
    ) VALUES (
        p_tenant_id, p_created_by, 'ffc_created', 'ffc', v_ffc_id
    );
    
    RETURN v_ffc_id;
END;
$$ LANGUAGE plpgsql;

-- Add FFC member
CREATE OR REPLACE FUNCTION sp_add_ffc_member(
    p_ffc_id UUID,
    p_user_id UUID,
    p_role_name VARCHAR(50),
    p_invited_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_role_id UUID;
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant ID and role
    SELECT f.tenant_id, r.role_id 
    INTO v_tenant_id, v_role_id
    FROM fwd_family_circles f
    JOIN roles r ON r.tenant_id = f.tenant_id
    WHERE f.ffc_id = p_ffc_id
    AND r.role_name = p_role_name;
    
    -- Add member
    INSERT INTO ffc_members (
        ffc_id, user_id, role_id, invited_by, status
    ) VALUES (
        p_ffc_id, p_user_id, v_role_id, p_invited_by, 'active'
    );
    
    -- Log addition
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_invited_by, 'member_added', 'ffc', p_ffc_id,
        jsonb_build_object('new_member_id', p_user_id, 'role', p_role_name)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Update FFC member role
CREATE OR REPLACE FUNCTION sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_user_id UUID,
    p_new_role_name VARCHAR(50),
    p_updated_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_new_role_id UUID;
    v_old_role_name VARCHAR(50);
    v_tenant_id INTEGER;
BEGIN
    -- Get current role
    SELECT r.role_name, f.tenant_id
    INTO v_old_role_name, v_tenant_id
    FROM ffc_members fm
    JOIN roles r ON r.role_id = fm.role_id
    JOIN fwd_family_circles f ON f.ffc_id = fm.ffc_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.user_id = p_user_id;
    
    -- Get new role ID
    SELECT role_id INTO v_new_role_id
    FROM roles
    WHERE role_name = p_new_role_name
    AND tenant_id = v_tenant_id;
    
    -- Update role
    UPDATE ffc_members
    SET role_id = v_new_role_id,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND user_id = p_user_id;
    
    -- Log change
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_updated_by, 'member_role_changed', 'ffc', p_ffc_id,
        jsonb_build_object(
            'member_id', p_user_id, 
            'old_role', v_old_role_name,
            'new_role', p_new_role_name
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Remove FFC member
CREATE OR REPLACE FUNCTION sp_remove_ffc_member(
    p_ffc_id UUID,
    p_user_id UUID,
    p_removed_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM fwd_family_circles
    WHERE ffc_id = p_ffc_id;
    
    -- Soft delete member
    UPDATE ffc_members
    SET status = 'inactive',
        left_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE ffc_id = p_ffc_id
    AND user_id = p_user_id;
    
    -- Log removal
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_removed_by, 'member_removed', 'ffc', p_ffc_id,
        jsonb_build_object('removed_member_id', p_user_id)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Get FFC members with roles
CREATE OR REPLACE FUNCTION fn_get_ffc_members(
    p_ffc_id UUID
) RETURNS TABLE (
    user_id UUID,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_name VARCHAR(50),
    joined_at TIMESTAMP,
    status status_enum
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.user_id,
        u.email,
        p.first_name,
        p.last_name,
        r.role_name,
        fm.joined_at,
        fm.status
    FROM ffc_members fm
    JOIN users u ON u.user_id = fm.user_id
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    JOIN roles r ON r.role_id = fm.role_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.status = 'active';
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- PERSONA MANAGEMENT PROCEDURES
-- ================================================================

-- Create persona
CREATE OR REPLACE FUNCTION sp_create_persona(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_date_of_birth DATE DEFAULT NULL,
    p_gender gender_enum DEFAULT NULL,
    p_marital_status marital_status_enum DEFAULT NULL,
    p_is_primary BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_persona_id UUID;
BEGIN
    -- Create persona
    INSERT INTO personas (
        tenant_id, user_id, first_name, last_name,
        date_of_birth, gender, marital_status, is_primary
    ) VALUES (
        p_tenant_id, p_user_id, p_first_name, p_last_name,
        p_date_of_birth, p_gender, p_marital_status, p_is_primary
    ) RETURNING persona_id INTO v_persona_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id
    ) VALUES (
        p_tenant_id, p_user_id, 'persona_created', 'persona', v_persona_id
    );
    
    RETURN v_persona_id;
END;
$$ LANGUAGE plpgsql;

-- Link personas (family relationships)
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
    WHERE persona_id = p_persona1_id;
    
    -- Create bidirectional relationship
    INSERT INTO persona_relationships (
        persona_id, related_persona_id, relationship_type
    ) VALUES
        (p_persona1_id, p_persona2_id, p_relationship),
        (p_persona2_id, p_persona1_id, p_relationship);
    
    -- Log relationship
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_created_by, 'personas_linked', 'persona', p_persona1_id,
        jsonb_build_object(
            'persona2_id', p_persona2_id,
            'relationship', p_relationship
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- ASSET CRUD PROCEDURES
-- ================================================================

-- Create generic asset
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_asset_category VARCHAR(50),
    p_name VARCHAR(255),
    p_description TEXT,
    p_created_by UUID,
    p_metadata JSONB DEFAULT '{}'::JSONB
) RETURNS UUID AS $$
DECLARE
    v_asset_id UUID;
BEGIN
    -- Create asset
    INSERT INTO assets (
        tenant_id, asset_category, name, description, 
        created_by, metadata
    ) VALUES (
        p_tenant_id, p_asset_category, p_name, p_description,
        p_created_by, p_metadata
    ) RETURNING asset_id INTO v_asset_id;
    
    -- Log creation
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        p_tenant_id, p_created_by, 'asset_created', 'asset', v_asset_id,
        jsonb_build_object('category', p_asset_category)
    );
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Assign asset to persona
CREATE OR REPLACE FUNCTION sp_assign_asset_to_persona(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum,
    p_ownership_percentage DECIMAL(5,2),
    p_assigned_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_asset_category VARCHAR(50);
BEGIN
    -- Get asset info
    SELECT tenant_id, asset_category 
    INTO v_tenant_id, v_asset_category
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Create ownership record
    INSERT INTO asset_persona (
        asset_id, persona_id, ownership_type, ownership_percentage,
        assigned_date, assigned_by
    ) VALUES (
        p_asset_id, p_persona_id, p_ownership_type, p_ownership_percentage,
        CURRENT_TIMESTAMP, p_assigned_by
    );
    
    -- Log assignment
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_assigned_by, 'asset_assigned', 'asset', p_asset_id,
        jsonb_build_object(
            'persona_id', p_persona_id,
            'ownership_type', p_ownership_type,
            'ownership_percentage', p_ownership_percentage
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Create real estate asset
CREATE OR REPLACE FUNCTION sp_create_real_estate(
    p_tenant_id INTEGER,
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
        p_tenant_id, 'real_estate', 
        p_property_type::TEXT || ' - ' || p_description,
        p_description, p_created_by
    );
    
    -- Create real estate record
    INSERT INTO real_estate (
        real_estate_id, asset_id, property_type, property_use,
        description, purchase_date, purchase_price, current_value,
        address_id
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_property_type, p_property_use,
        p_description, p_purchase_date, p_purchase_price, p_current_value,
        p_address_id
    ) RETURNING real_estate_id INTO v_real_estate_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Create financial account
CREATE OR REPLACE FUNCTION sp_create_financial_account(
    p_tenant_id INTEGER,
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
        p_tenant_id, 'financial_account',
        p_account_type::TEXT || ' - ' || p_institution_name,
        'Financial account at ' || p_institution_name,
        p_created_by
    );
    
    -- Create financial account record
    INSERT INTO financial_accounts (
        financial_account_id, asset_id, account_type,
        institution_name, account_number, current_balance,
        currency
    ) VALUES (
        gen_random_uuid(), v_asset_id, p_account_type,
        p_institution_name, p_account_number, p_current_balance,
        p_currency
    ) RETURNING financial_account_id INTO v_account_id;
    
    RETURN v_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Update asset value
CREATE OR REPLACE FUNCTION sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_valuation_date DATE,
    p_updated_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_asset_category VARCHAR(50);
    v_old_value DECIMAL(15,2);
BEGIN
    -- Get asset info
    SELECT tenant_id, asset_category
    INTO v_tenant_id, v_asset_category
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Update based on category
    CASE v_asset_category
        WHEN 'real_estate' THEN
            UPDATE real_estate
            SET current_value = p_new_value,
                last_valuation_date = p_valuation_date
            WHERE asset_id = p_asset_id
            RETURNING current_value INTO v_old_value;
            
        WHEN 'financial_account' THEN
            UPDATE financial_accounts
            SET current_balance = p_new_value
            WHERE asset_id = p_asset_id
            RETURNING current_balance INTO v_old_value;
            
        WHEN 'vehicle' THEN
            UPDATE vehicles
            SET current_value = p_new_value
            WHERE asset_id = p_asset_id
            RETURNING current_value INTO v_old_value;
            
        ELSE
            -- Update metadata for other categories
            UPDATE assets
            SET metadata = metadata || 
                jsonb_build_object('current_value', p_new_value)
            WHERE asset_id = p_asset_id;
    END CASE;
    
    -- Log value update
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_updated_by, 'asset_value_updated', 'asset', p_asset_id,
        jsonb_build_object(
            'old_value', v_old_value,
            'new_value', p_new_value,
            'valuation_date', p_valuation_date
        )
    );
    
    RETURN TRUE;
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
BEGIN
    -- Get tenant ID
    SELECT tenant_id INTO v_tenant_id
    FROM assets
    WHERE asset_id = p_asset_id;
    
    -- Soft delete asset
    UPDATE assets
    SET is_deleted = TRUE,
        deleted_at = CURRENT_TIMESTAMP,
        deleted_by = p_deleted_by,
        updated_at = CURRENT_TIMESTAMP
    WHERE asset_id = p_asset_id;
    
    -- Log deletion
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        metadata
    ) VALUES (
        v_tenant_id, p_deleted_by, 'asset_deleted', 'asset', p_asset_id,
        jsonb_build_object('reason', p_reason)
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Get assets by persona
CREATE OR REPLACE FUNCTION fn_get_persona_assets(
    p_persona_id UUID
) RETURNS TABLE (
    asset_id UUID,
    asset_category VARCHAR(50),
    name VARCHAR(255),
    description TEXT,
    ownership_type ownership_type_enum,
    ownership_percentage DECIMAL(5,2),
    estimated_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.asset_id,
        a.asset_category,
        a.name,
        a.description,
        ap.ownership_type,
        ap.ownership_percentage,
        CASE 
            WHEN a.asset_category = 'real_estate' THEN 
                (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'financial_account' THEN
                (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'vehicle' THEN
                (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
            ELSE
                (a.metadata->>'current_value')::DECIMAL(15,2)
        END AS estimated_value
    FROM assets a
    JOIN asset_persona ap ON ap.asset_id = a.asset_id
    WHERE ap.persona_id = p_persona_id
    AND a.is_deleted = FALSE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- AUDIT LOGGING FUNCTIONS
-- ================================================================

-- Generic audit log function
CREATE OR REPLACE FUNCTION fn_audit_log(
    p_action VARCHAR(100),
    p_entity_type entity_type_enum,
    p_entity_id UUID,
    p_metadata JSONB DEFAULT NULL,
    p_tenant_id INTEGER DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        metadata,
        ip_address,
        user_agent
    ) VALUES (
        COALESCE(p_tenant_id, fn_get_current_tenant_id()),
        COALESCE(p_user_id, fn_get_current_user_id()),
        p_action,
        p_entity_type,
        p_entity_id,
        p_metadata,
        inet_client_addr(),
        current_setting('app.user_agent', TRUE)
    );
END;
$$ LANGUAGE plpgsql;

-- Log audit event for weekly reports
CREATE OR REPLACE FUNCTION fn_log_audit_event(
    p_ffc_id UUID,
    p_event_category VARCHAR(50),
    p_event_type VARCHAR(100),
    p_event_description TEXT,
    p_affected_entity_type entity_type_enum,
    p_affected_entity_id UUID,
    p_performed_by UUID,
    p_metadata JSONB DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_event_id UUID;
BEGIN
    INSERT INTO audit_events (
        ffc_id,
        event_category,
        event_type,
        event_description,
        affected_entity_type,
        affected_entity_id,
        performed_by,
        metadata
    ) VALUES (
        p_ffc_id,
        p_event_category,
        p_event_type,
        p_event_description,
        p_affected_entity_type,
        p_affected_entity_id,
        p_performed_by,
        p_metadata
    ) RETURNING event_id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;

-- Generate weekly audit report
CREATE OR REPLACE FUNCTION fn_generate_weekly_audit_report(
    p_ffc_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
) RETURNS TABLE (
    event_id UUID,
    event_date DATE,
    event_time TIME,
    event_category VARCHAR(50),
    event_type VARCHAR(100),
    event_description TEXT,
    performed_by_name TEXT,
    affected_entity TEXT
) AS $$
BEGIN
    -- Default to last 7 days if dates not provided
    p_start_date := COALESCE(p_start_date, CURRENT_DATE - INTERVAL '7 days');
    p_end_date := COALESCE(p_end_date, CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        ae.event_id,
        ae.event_timestamp::DATE AS event_date,
        ae.event_timestamp::TIME AS event_time,
        ae.event_category,
        ae.event_type,
        ae.event_description,
        CONCAT(p.first_name, ' ', p.last_name) AS performed_by_name,
        CASE 
            WHEN ae.affected_entity_type = 'asset' THEN
                (SELECT name FROM assets WHERE asset_id = ae.affected_entity_id)
            WHEN ae.affected_entity_type = 'persona' THEN
                (SELECT CONCAT(first_name, ' ', last_name) 
                 FROM personas WHERE persona_id = ae.affected_entity_id)
            ELSE ae.affected_entity_id::TEXT
        END AS affected_entity
    FROM audit_events ae
    JOIN users u ON u.user_id = ae.performed_by
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    WHERE ae.ffc_id = p_ffc_id
    AND ae.event_timestamp::DATE BETWEEN p_start_date AND p_end_date
    AND ae.included_in_weekly_report = TRUE
    ORDER BY ae.event_timestamp DESC;
END;
$$ LANGUAGE plpgsql;

-- Mark audit events as sent
CREATE OR REPLACE FUNCTION sp_mark_audit_events_sent(
    p_ffc_id UUID,
    p_report_date DATE
) RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE audit_events
    SET report_sent_date = p_report_date
    WHERE ffc_id = p_ffc_id
    AND included_in_weekly_report = TRUE
    AND report_sent_date IS NULL
    AND event_timestamp < p_report_date;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for automatic audit logging
CREATE OR REPLACE FUNCTION fn_trigger_audit_log() 
RETURNS TRIGGER AS $$
DECLARE
    v_action VARCHAR(100);
    v_entity_type entity_type_enum;
    v_entity_id UUID;
    v_metadata JSONB;
BEGIN
    -- Determine action
    IF TG_OP = 'INSERT' THEN
        v_action := TG_TABLE_NAME || '_created';
        v_entity_id := NEW.asset_id; -- Adjust based on table
        v_metadata := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := TG_TABLE_NAME || '_updated';
        v_entity_id := NEW.asset_id; -- Adjust based on table
        v_metadata := jsonb_build_object(
            'old', to_jsonb(OLD),
            'new', to_jsonb(NEW)
        );
    ELSIF TG_OP = 'DELETE' THEN
        v_action := TG_TABLE_NAME || '_deleted';
        v_entity_id := OLD.asset_id; -- Adjust based on table
        v_metadata := to_jsonb(OLD);
    END IF;
    
    -- Determine entity type based on table
    v_entity_type := CASE 
        WHEN TG_TABLE_NAME LIKE '%asset%' THEN 'asset'
        WHEN TG_TABLE_NAME LIKE '%persona%' THEN 'persona'
        WHEN TG_TABLE_NAME LIKE '%user%' THEN 'user'
        ELSE 'asset'
    END;
    
    -- Log the action
    PERFORM fn_audit_log(
        v_action,
        v_entity_type,
        v_entity_id,
        v_metadata
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Get audit history for an entity
CREATE OR REPLACE FUNCTION fn_get_entity_audit_history(
    p_entity_type entity_type_enum,
    p_entity_id UUID,
    p_limit INTEGER DEFAULT 100
) RETURNS TABLE (
    log_id UUID,
    action VARCHAR(100),
    user_email VARCHAR(255),
    occurred_at TIMESTAMP,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.log_id,
        al.action,
        u.email AS user_email,
        al.occurred_at,
        al.metadata
    FROM audit_log al
    LEFT JOIN users u ON u.user_id = al.user_id
    WHERE al.entity_type = p_entity_type
    AND al.entity_id = p_entity_id
    ORDER BY al.occurred_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- SEARCH AND REPORTING FUNCTIONS
-- ================================================================

-- Search assets by name or description
CREATE OR REPLACE FUNCTION fn_search_assets(
    p_tenant_id INTEGER,
    p_search_term TEXT,
    p_category VARCHAR(50) DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
) RETURNS TABLE (
    asset_id UUID,
    asset_category VARCHAR(50),
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP,
    total_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.asset_id,
        a.asset_category,
        a.name,
        a.description,
        a.created_at,
        CASE 
            WHEN a.asset_category = 'real_estate' THEN 
                (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'financial_account' THEN
                (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
            WHEN a.asset_category = 'vehicle' THEN
                (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
            ELSE
                (a.metadata->>'current_value')::DECIMAL(15,2)
        END AS total_value
    FROM assets a
    WHERE a.tenant_id = p_tenant_id
    AND a.is_deleted = FALSE
    AND (p_category IS NULL OR a.asset_category = p_category)
    AND (
        a.name ILIKE '%' || p_search_term || '%' OR
        a.description ILIKE '%' || p_search_term || '%'
    )
    ORDER BY a.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Get FFC net worth summary
CREATE OR REPLACE FUNCTION fn_get_ffc_net_worth(
    p_ffc_id UUID
) RETURNS TABLE (
    asset_category VARCHAR(50),
    total_count INTEGER,
    total_value DECIMAL(15,2),
    liability_value DECIMAL(15,2),
    net_value DECIMAL(15,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH ffc_personas AS (
        SELECT DISTINCT p.persona_id
        FROM ffc_members fm
        JOIN personas p ON p.user_id = fm.user_id
        WHERE fm.ffc_id = p_ffc_id
        AND fm.status = 'active'
    ),
    asset_values AS (
        SELECT 
            a.asset_category,
            COUNT(DISTINCT a.asset_id) AS asset_count,
            SUM(
                CASE 
                    WHEN a.asset_category = 'real_estate' THEN 
                        (SELECT current_value FROM real_estate WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'financial_account' THEN
                        (SELECT current_balance FROM financial_accounts WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'vehicle' THEN
                        (SELECT current_value FROM vehicles WHERE asset_id = a.asset_id)
                    WHEN a.asset_category = 'loan' THEN
                        -(SELECT balance_remaining_usd FROM loans WHERE asset_id = a.asset_id)
                    ELSE
                        COALESCE((a.metadata->>'current_value')::DECIMAL(15,2), 0)
                END * (ap.ownership_percentage / 100)
            ) AS total_value
        FROM assets a
        JOIN asset_persona ap ON ap.asset_id = a.asset_id
        JOIN ffc_personas fp ON fp.persona_id = ap.persona_id
        WHERE a.is_deleted = FALSE
        GROUP BY a.asset_category
    )
    SELECT 
        av.asset_category,
        av.asset_count::INTEGER AS total_count,
        CASE 
            WHEN av.asset_category = 'loan' THEN 0
            ELSE COALESCE(av.total_value, 0)
        END AS total_value,
        CASE 
            WHEN av.asset_category = 'loan' THEN ABS(COALESCE(av.total_value, 0))
            ELSE 0
        END AS liability_value,
        COALESCE(av.total_value, 0) AS net_value
    FROM asset_values av
    ORDER BY av.asset_category;
END;
$$ LANGUAGE plpgsql;

-- Get persona document summary
CREATE OR REPLACE FUNCTION fn_get_persona_documents(
    p_persona_id UUID,
    p_category document_category_enum DEFAULT NULL
) RETURNS TABLE (
    document_id UUID,
    document_type document_type_enum,
    document_category document_category_enum,
    title VARCHAR(255),
    upload_date TIMESTAMP,
    file_size BIGINT,
    is_pii_processed BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.document_id,
        d.document_type,
        d.document_category,
        d.title,
        d.created_at AS upload_date,
        ms.file_size,
        EXISTS(
            SELECT 1 FROM pii_processing_jobs ppj
            WHERE ppj.media_storage_id = d.media_storage_id
            AND ppj.status = 'completed'
        ) AS is_pii_processed
    FROM documents d
    JOIN media_storage ms ON ms.media_id = d.media_storage_id
    WHERE d.persona_id = p_persona_id
    AND (p_category IS NULL OR d.document_category = p_category)
    AND d.is_deleted = FALSE
    ORDER BY d.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Generate FFC activity report
CREATE OR REPLACE FUNCTION fn_generate_ffc_activity_report(
    p_ffc_id UUID,
    p_start_date DATE,
    p_end_date DATE
) RETURNS TABLE (
    activity_date DATE,
    activity_type VARCHAR(100),
    user_name TEXT,
    description TEXT,
    affected_assets INTEGER,
    affected_personas INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.occurred_at::DATE AS activity_date,
        al.action AS activity_type,
        CONCAT(p.first_name, ' ', p.last_name) AS user_name,
        CASE 
            WHEN al.action LIKE '%asset%' THEN 
                'Asset operation: ' || COALESCE((al.metadata->>'name')::TEXT, al.entity_id::TEXT)
            WHEN al.action LIKE '%persona%' THEN 
                'Persona operation: ' || al.entity_id::TEXT
            ELSE al.action
        END AS description,
        CASE WHEN al.entity_type = 'asset' THEN 1 ELSE 0 END AS affected_assets,
        CASE WHEN al.entity_type = 'persona' THEN 1 ELSE 0 END AS affected_personas
    FROM audit_log al
    JOIN users u ON u.user_id = al.user_id
    JOIN personas p ON p.user_id = u.user_id AND p.is_primary = TRUE
    JOIN ffc_members fm ON fm.user_id = u.user_id
    WHERE fm.ffc_id = p_ffc_id
    AND fm.status = 'active'
    AND al.occurred_at::DATE BETWEEN p_start_date AND p_end_date
    ORDER BY al.occurred_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Search personas by name
CREATE OR REPLACE FUNCTION fn_search_personas(
    p_tenant_id INTEGER,
    p_search_term TEXT,
    p_limit INTEGER DEFAULT 50
) RETURNS TABLE (
    persona_id UUID,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    is_primary BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.persona_id,
        p.first_name,
        p.last_name,
        u.email,
        u.phone,
        p.date_of_birth,
        p.is_primary
    FROM personas p
    JOIN users u ON u.user_id = p.user_id
    WHERE p.tenant_id = p_tenant_id
    AND p.status = 'active'
    AND (
        p.first_name ILIKE '%' || p_search_term || '%' OR
        p.last_name ILIKE '%' || p_search_term || '%' OR
        u.email ILIKE '%' || p_search_term || '%'
    )
    ORDER BY p.last_name, p.first_name
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- INTEGRATION SYNC PROCEDURES
-- ================================================================

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
    WHERE user_id = p_user_id;
    
    -- Get or create integration record
    SELECT integration_id INTO v_integration_id
    FROM quillt_integrations
    WHERE user_id = p_user_id;
    
    IF v_integration_id IS NULL THEN
        INSERT INTO quillt_integrations (
            user_id, quillt_user_id, connection_status
        ) VALUES (
            p_user_id, 
            p_quillt_data->>'quillt_user_id',
            'active'
        ) RETURNING integration_id INTO v_integration_id;
    END IF;
    
    -- Update last sync
    UPDATE quillt_integrations
    SET last_sync_at = CURRENT_TIMESTAMP,
        sync_data = p_quillt_data
    WHERE integration_id = v_integration_id;
    
    -- Log sync
    INSERT INTO quillt_sync_logs (
        integration_id, sync_type, sync_status, 
        records_synced, sync_metadata
    ) VALUES (
        v_integration_id, 'financial_accounts', 'completed',
        (p_quillt_data->>'account_count')::INTEGER,
        p_quillt_data
    ) RETURNING sync_log_id INTO v_sync_log_id;
    
    -- Create audit log
    PERFORM fn_audit_log(
        'quillt_data_synced',
        'user',
        p_user_id,
        jsonb_build_object(
            'sync_log_id', v_sync_log_id,
            'accounts_synced', p_quillt_data->>'account_count'
        ),
        v_tenant_id,
        p_user_id
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Sync real estate data from provider
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
BEGIN
    -- Get asset ID and current value
    SELECT asset_id, current_value 
    INTO v_asset_id, v_old_value
    FROM real_estate
    WHERE real_estate_id = p_real_estate_id;
    
    -- Update real estate data
    v_new_value := (p_property_data->>'estimated_value')::DECIMAL(15,2);
    
    UPDATE real_estate
    SET current_value = v_new_value,
        last_valuation_date = CURRENT_DATE,
        metadata = metadata || p_property_data
    WHERE real_estate_id = p_real_estate_id;
    
    -- Log sync
    INSERT INTO real_estate_sync_logs (
        real_estate_id, provider_name, sync_type,
        sync_status, property_data
    ) VALUES (
        p_real_estate_id, p_provider_name, 'valuation',
        'completed', p_property_data
    ) RETURNING sync_log_id INTO v_sync_log_id;
    
    -- Create audit event if value changed
    IF v_old_value != v_new_value THEN
        PERFORM fn_audit_log(
            'real_estate_value_synced',
            'asset',
            v_asset_id,
            jsonb_build_object(
                'provider', p_provider_name,
                'old_value', v_old_value,
                'new_value', v_new_value,
                'sync_log_id', v_sync_log_id
            )
        );
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
    v_status pii_status_enum;
BEGIN
    -- Get media ID
    SELECT media_storage_id INTO v_media_id
    FROM pii_processing_jobs
    WHERE job_id = p_job_id;
    
    -- Update job status
    UPDATE pii_processing_jobs
    SET status = CASE 
            WHEN p_masked_file_id IS NOT NULL THEN 'completed'
            ELSE 'failed'
        END,
        detected_pii = p_detected_pii,
        masked_file_id = p_masked_file_id,
        completed_at = CURRENT_TIMESTAMP
    WHERE job_id = p_job_id;
    
    -- Update media storage PII flags
    UPDATE media_storage
    SET contains_pii = (p_detected_pii IS NOT NULL AND jsonb_array_length(p_detected_pii) > 0),
        pii_masked_version_id = p_masked_file_id
    WHERE media_id = v_media_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Update Builder.io content reference
CREATE OR REPLACE FUNCTION sp_update_builder_content(
    p_page_name VARCHAR(255),
    p_builder_content_id VARCHAR(255),
    p_content_data JSONB,
    p_updated_by UUID
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
BEGIN
    -- Upsert Builder.io integration record
    INSERT INTO builder_io_integrations (
        page_name, builder_content_id, content_data, 
        last_updated_by
    ) VALUES (
        p_page_name, p_builder_content_id, p_content_data,
        p_updated_by
    )
    ON CONFLICT (page_name) DO UPDATE
    SET builder_content_id = EXCLUDED.builder_content_id,
        content_data = EXCLUDED.content_data,
        last_sync_at = CURRENT_TIMESTAMP,
        last_updated_by = EXCLUDED.last_updated_by
    RETURNING integration_id INTO v_integration_id;
    
    -- Log update
    PERFORM fn_audit_log(
        'builder_content_updated',
        'asset',
        v_integration_id,
        jsonb_build_object(
            'page_name', p_page_name,
            'content_id', p_builder_content_id
        )
    );
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql;

-- Bulk update asset ownership
CREATE OR REPLACE FUNCTION sp_bulk_update_asset_ownership(
    p_updates JSONB
) RETURNS INTEGER AS $$
DECLARE
    v_update JSONB;
    v_count INTEGER := 0;
BEGIN
    -- Process each update
    FOR v_update IN SELECT * FROM jsonb_array_elements(p_updates)
    LOOP
        UPDATE asset_persona
        SET ownership_percentage = (v_update->>'ownership_percentage')::DECIMAL(5,2),
            ownership_type = (v_update->>'ownership_type')::ownership_type_enum,
            updated_at = CURRENT_TIMESTAMP
        WHERE asset_id = (v_update->>'asset_id')::UUID
        AND persona_id = (v_update->>'persona_id')::UUID;
        
        v_count := v_count + 1;
    END LOOP;
    
    -- Log bulk update
    PERFORM fn_audit_log(
        'bulk_ownership_update',
        'asset',
        NULL,
        jsonb_build_object('updates_count', v_count)
    );
    
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Process invitation
CREATE OR REPLACE FUNCTION sp_process_invitation(
    p_invitation_id UUID,
    p_action VARCHAR(20), -- 'accept', 'decline', 'cancel'
    p_user_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_invitation RECORD;
    v_new_status invitation_status_enum;
BEGIN
    -- Get invitation details
    SELECT * INTO v_invitation
    FROM invitations
    WHERE invitation_id = p_invitation_id;
    
    -- Determine new status
    v_new_status := CASE p_action
        WHEN 'accept' THEN 'accepted'
        WHEN 'decline' THEN 'declined'
        WHEN 'cancel' THEN 'cancelled'
        ELSE v_invitation.status
    END;
    
    -- Update invitation
    UPDATE invitations
    SET status = v_new_status,
        responded_at = CASE 
            WHEN p_action IN ('accept', 'decline') THEN CURRENT_TIMESTAMP
            ELSE responded_at
        END
    WHERE invitation_id = p_invitation_id;
    
    -- If accepted, add to FFC
    IF p_action = 'accept' AND p_user_id IS NOT NULL THEN
        PERFORM sp_add_ffc_member(
            v_invitation.ffc_id,
            p_user_id,
            v_invitation.role,
            v_invitation.invited_by
        );
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- END OF STORED PROCEDURES AND FUNCTIONS
-- ================================================================