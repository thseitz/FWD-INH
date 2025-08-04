# 09 - Security & Compliance Stored Procedures

## Table of Contents
1. [Overview](#overview)
2. [Authentication Procedures](#authentication-procedures)
3. [Session Management Procedures](#session-management-procedures)
4. [Verification Procedures](#verification-procedures)
5. [RBAC Management Procedures](#rbac-management-procedures)
6. [Audit & Compliance Procedures](#audit--compliance-procedures)
7. [PII Processing Procedures](#pii-processing-procedures)
8. [Security Configuration Procedures](#security-configuration-procedures)
9. [Security Validation Functions](#security-validation-functions)
10. [Error Handling & Security](#error-handling--security)

## Overview

The Forward Inheritance Platform implements **18 security and compliance procedures** that handle user authentication, session management, role-based access control, audit logging, and regulatory compliance. These procedures enforce security best practices and maintain comprehensive audit trails.

### Security Procedure Categories
- **Authentication**: 3 procedures for login, logout, and password management
- **Session Management**: 2 procedures for session lifecycle management
- **Verification**: 3 procedures for email/phone verification workflows
- **RBAC Management**: 4 procedures for role and permission management
- **Audit & Compliance**: 4 procedures for logging and compliance reporting
- **PII Processing**: 2 procedures for privacy compliance

### Key Security Features
- **Multi-Factor Authentication**: TOTP and SMS-based 2FA support
- **Session Security**: Secure token generation and rotation
- **Audit Logging**: Complete action tracking for compliance
- **Permission Enforcement**: Database-level permission validation
- **PII Protection**: Automated detection and masking capabilities

## Authentication Procedures

### sp_authenticate_user
Handles user authentication with comprehensive security checks and audit logging.

```sql
CREATE OR REPLACE FUNCTION sp_authenticate_user(
    p_tenant_id INTEGER,
    p_email VARCHAR(255),
    p_password TEXT,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT '{}'
)
RETURNS TABLE (
    success BOOLEAN,
    user_id UUID,
    session_token UUID,
    requires_mfa BOOLEAN,
    error_message TEXT
) AS $$
DECLARE
    v_user_record users%ROWTYPE;
    v_password_valid BOOLEAN := FALSE;
    v_session_id UUID;
    v_session_token UUID;
    v_requires_mfa BOOLEAN := FALSE;
    v_login_attempts INTEGER := 0;
    v_is_locked BOOLEAN := FALSE;
BEGIN
    -- Input validation
    IF p_tenant_id IS NULL OR p_email IS NULL OR p_password IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::UUID, FALSE, 'Invalid input parameters';
        RETURN;
    END IF;

    -- Check for existing user
    SELECT * INTO v_user_record
    FROM users 
    WHERE tenant_id = p_tenant_id 
    AND email = LOWER(p_email);
    
    -- Log failed attempt if user not found
    IF NOT FOUND THEN
        INSERT INTO user_login_history (
            tenant_id, email_attempted, login_successful, 
            failure_reason, ip_address, user_agent, attempted_at
        ) VALUES (
            p_tenant_id, p_email, FALSE, 
            'invalid_email', p_ip_address, p_user_agent, NOW()
        );
        
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::UUID, FALSE, 'Invalid credentials';
        RETURN;
    END IF;

    -- Check account status
    IF v_user_record.status NOT IN ('active', 'pending_verification') THEN
        INSERT INTO user_login_history (
            user_id, tenant_id, email_attempted, login_successful,
            failure_reason, ip_address, user_agent, attempted_at
        ) VALUES (
            v_user_record.id, p_tenant_id, p_email, FALSE,
            'account_' || v_user_record.status, p_ip_address, p_user_agent, NOW()
        );
        
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::UUID, FALSE, 'Account not active';
        RETURN;
    END IF;

    -- Check for account lockout (5 failed attempts in last 15 minutes)
    SELECT COUNT(*) INTO v_login_attempts
    FROM user_login_history
    WHERE user_id = v_user_record.id
    AND login_successful = FALSE
    AND attempted_at > NOW() - INTERVAL '15 minutes';
    
    IF v_login_attempts >= 5 THEN
        INSERT INTO user_login_history (
            user_id, tenant_id, email_attempted, login_successful,
            failure_reason, ip_address, user_agent, attempted_at
        ) VALUES (
            v_user_record.id, p_tenant_id, p_email, FALSE,
            'account_locked', p_ip_address, p_user_agent, NOW()
        );
        
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::UUID, FALSE, 'Account temporarily locked';
        RETURN;
    END IF;

    -- Verify password
    v_password_valid := crypt(p_password, v_user_record.password_hash) = v_user_record.password_hash;
    
    IF NOT v_password_valid THEN
        INSERT INTO user_login_history (
            user_id, tenant_id, email_attempted, login_successful,
            failure_reason, ip_address, user_agent, attempted_at
        ) VALUES (
            v_user_record.id, p_tenant_id, p_email, FALSE,
            'invalid_password', p_ip_address, p_user_agent, NOW()
        );
        
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::UUID, FALSE, 'Invalid credentials';
        RETURN;
    END IF;

    -- Check MFA requirements
    SELECT EXISTS(
        SELECT 1 FROM mfa_settings 
        WHERE user_id = v_user_record.id AND is_enabled = TRUE
    ) INTO v_requires_mfa;

    -- Create session
    v_session_token := gen_random_uuid();
    INSERT INTO user_sessions (
        user_id, session_token, ip_address, user_agent, 
        device_info, login_method, mfa_verified
    ) VALUES (
        v_user_record.id, v_session_token, p_ip_address, p_user_agent,
        p_device_info, 'password', NOT v_requires_mfa
    ) RETURNING id INTO v_session_id;

    -- Log successful login
    INSERT INTO user_login_history (
        user_id, tenant_id, email_attempted, login_successful,
        session_id, ip_address, user_agent, device_info,
        authentication_method, attempted_at
    ) VALUES (
        v_user_record.id, p_tenant_id, p_email, TRUE,
        v_session_id, p_ip_address, p_user_agent, p_device_info,
        'password', NOW()
    );

    -- Update user last login
    UPDATE users 
    SET last_login_at = NOW(), last_login_ip = p_ip_address
    WHERE id = v_user_record.id;

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, session_id, action, entity_type, entity_id,
        ip_address, user_agent, additional_data
    ) VALUES (
        p_tenant_id, v_user_record.id, v_session_id, 'LOGIN', 'user', v_user_record.id,
        p_ip_address, p_user_agent, jsonb_build_object('requires_mfa', v_requires_mfa)
    );

    RETURN QUERY SELECT TRUE, v_user_record.id, v_session_token, v_requires_mfa, NULL::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_logout_user
Securely terminates user sessions with audit logging.

```sql
CREATE OR REPLACE FUNCTION sp_logout_user(
    p_session_token UUID,
    p_logout_reason VARCHAR(100) DEFAULT 'manual'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_session_record user_sessions%ROWTYPE;
BEGIN
    -- Find and validate session
    SELECT * INTO v_session_record
    FROM user_sessions
    WHERE session_token = p_session_token
    AND is_active = TRUE
    AND expires_at > NOW();
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Invalid or expired session';
        RETURN;
    END IF;

    -- Deactivate session
    UPDATE user_sessions
    SET is_active = FALSE,
        logout_reason = p_logout_reason,
        updated_at = NOW()
    WHERE id = v_session_record.id;

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, session_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        fn_get_current_tenant_id(), v_session_record.user_id, v_session_record.id,
        'LOGOUT', 'user', v_session_record.user_id,
        jsonb_build_object('logout_reason', p_logout_reason)
    );

    RETURN QUERY SELECT TRUE, 'Successfully logged out';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_change_password
Handles secure password changes with validation and audit logging.

```sql
CREATE OR REPLACE FUNCTION sp_change_password(
    p_user_id UUID,
    p_current_password TEXT,
    p_new_password TEXT,
    p_session_token UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_user_record users%ROWTYPE;
    v_session_valid BOOLEAN := FALSE;
    v_new_password_hash TEXT;
BEGIN
    -- Validate session
    SELECT EXISTS(
        SELECT 1 FROM user_sessions
        WHERE session_token = p_session_token
        AND user_id = p_user_id
        AND is_active = TRUE
        AND expires_at > NOW()
    ) INTO v_session_valid;
    
    IF NOT v_session_valid THEN
        RETURN QUERY SELECT FALSE, 'Invalid session';
        RETURN;
    END IF;

    -- Get user record
    SELECT * INTO v_user_record
    FROM users WHERE id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'User not found';
        RETURN;
    END IF;

    -- Verify current password
    IF crypt(p_current_password, v_user_record.password_hash) != v_user_record.password_hash THEN
        RETURN QUERY SELECT FALSE, 'Current password is incorrect';
        RETURN;
    END IF;

    -- Validate new password strength
    IF LENGTH(p_new_password) < 8 THEN
        RETURN QUERY SELECT FALSE, 'Password must be at least 8 characters';
        RETURN;
    END IF;

    -- Hash new password
    v_new_password_hash := crypt(p_new_password, gen_salt('bf', 12));

    -- Update password
    UPDATE users
    SET password_hash = v_new_password_hash,
        password_changed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_user_id;

    -- Invalidate all other sessions (except current)
    UPDATE user_sessions
    SET is_active = FALSE,
        logout_reason = 'password_changed'
    WHERE user_id = p_user_id
    AND session_token != p_session_token
    AND is_active = TRUE;

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id
    ) VALUES (
        v_user_record.tenant_id, p_user_id, 'PASSWORD_CHANGE', 'user', p_user_id
    );

    RETURN QUERY SELECT TRUE, 'Password changed successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Session Management Procedures

### sp_validate_session
Validates and refreshes user sessions.

```sql
CREATE OR REPLACE FUNCTION sp_validate_session(
    p_session_token UUID,
    p_extend_session BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    valid BOOLEAN,
    user_id UUID,
    tenant_id INTEGER,
    expires_at TIMESTAMP WITH TIME ZONE,
    mfa_verified BOOLEAN
) AS $$
DECLARE
    v_session_record user_sessions%ROWTYPE;
    v_new_expiry TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Find session
    SELECT * INTO v_session_record
    FROM user_sessions s
    JOIN users u ON s.user_id = u.id
    WHERE s.session_token = p_session_token
    AND s.is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::INTEGER, NULL::TIMESTAMP WITH TIME ZONE, FALSE;
        RETURN;
    END IF;

    -- Check expiration
    IF v_session_record.expires_at <= NOW() THEN
        -- Mark session as expired
        UPDATE user_sessions
        SET is_active = FALSE, logout_reason = 'timeout'
        WHERE id = v_session_record.id;
        
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::INTEGER, NULL::TIMESTAMP WITH TIME ZONE, FALSE;
        RETURN;
    END IF;

    -- Extend session if requested
    IF p_extend_session THEN
        v_new_expiry := NOW() + INTERVAL '7 days';
        UPDATE user_sessions
        SET expires_at = v_new_expiry,
            last_activity_at = NOW()
        WHERE id = v_session_record.id;
    ELSE
        v_new_expiry := v_session_record.expires_at;
    END IF;

    -- Get user tenant_id
    DECLARE
        v_tenant_id INTEGER;
    BEGIN
        SELECT tenant_id INTO v_tenant_id
        FROM users WHERE id = v_session_record.user_id;
        
        RETURN QUERY SELECT TRUE, v_session_record.user_id, v_tenant_id, v_new_expiry, v_session_record.mfa_verified;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_cleanup_expired_sessions
Maintenance procedure to clean up expired sessions.

```sql
CREATE OR REPLACE FUNCTION sp_cleanup_expired_sessions()
RETURNS TABLE (
    sessions_cleaned INTEGER,
    tokens_cleaned INTEGER
) AS $$
DECLARE
    v_sessions_cleaned INTEGER := 0;
    v_tokens_cleaned INTEGER := 0;
BEGIN
    -- Clean up expired sessions
    UPDATE user_sessions
    SET is_active = FALSE,
        logout_reason = 'timeout'
    WHERE is_active = TRUE
    AND expires_at <= NOW();
    
    GET DIAGNOSTICS v_sessions_cleaned = ROW_COUNT;

    -- Clean up expired password reset tokens
    DELETE FROM password_reset_tokens
    WHERE expires_at <= NOW() OR is_used = TRUE;
    
    GET DIAGNOSTICS v_tokens_cleaned = ROW_COUNT;

    -- Clean up expired verification records
    DELETE FROM email_verifications
    WHERE expires_at <= NOW() AND is_verified = FALSE;
    
    DELETE FROM phone_verifications
    WHERE expires_at <= NOW() AND is_verified = FALSE;

    RETURN QUERY SELECT v_sessions_cleaned, v_tokens_cleaned;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Verification Procedures

### sp_send_email_verification
Initiates email verification workflow.

```sql
CREATE OR REPLACE FUNCTION sp_send_email_verification(
    p_user_id UUID,
    p_email_id UUID,
    p_verification_ip INET DEFAULT NULL,
    p_verification_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    verification_token UUID,
    expires_at TIMESTAMP WITH TIME ZONE,
    message TEXT
) AS $$
DECLARE
    v_verification_token UUID;
    v_expires_at TIMESTAMP WITH TIME ZONE;
    v_verification_code VARCHAR(6);
    v_existing_count INTEGER;
BEGIN
    -- Check for recent verification attempts (rate limiting)
    SELECT COUNT(*) INTO v_existing_count
    FROM email_verifications
    WHERE user_id = p_user_id
    AND email_id = p_email_id
    AND sent_at > NOW() - INTERVAL '5 minutes';
    
    IF v_existing_count >= 3 THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TIMESTAMP WITH TIME ZONE, 'Rate limit exceeded';
        RETURN;
    END IF;

    -- Generate verification token and code
    v_verification_token := gen_random_uuid();
    v_verification_code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    v_expires_at := NOW() + INTERVAL '24 hours';

    -- Insert verification record
    INSERT INTO email_verifications (
        user_id, email_id, verification_token, verification_code,
        expires_at, verification_ip, verification_user_agent
    ) VALUES (
        p_user_id, p_email_id, v_verification_token, v_verification_code,
        v_expires_at, p_verification_ip, p_verification_user_agent
    );

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        fn_get_current_tenant_id(), p_user_id, 'EMAIL_VERIFICATION_SENT', 'user', p_user_id,
        jsonb_build_object('email_id', p_email_id)
    );

    RETURN QUERY SELECT TRUE, v_verification_token, v_expires_at, 'Verification email sent';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_verify_email
Completes email verification process.

```sql
CREATE OR REPLACE FUNCTION sp_verify_email(
    p_verification_token UUID,
    p_verification_code VARCHAR(6) DEFAULT NULL,
    p_verification_ip INET DEFAULT NULL,
    p_verification_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_verification_record email_verifications%ROWTYPE;
BEGIN
    -- Find verification record
    SELECT * INTO v_verification_record
    FROM email_verifications
    WHERE verification_token = p_verification_token
    AND is_verified = FALSE
    AND expires_at > NOW();
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Invalid or expired verification token';
        RETURN;
    END IF;

    -- Check verification code if provided
    IF p_verification_code IS NOT NULL THEN
        IF v_verification_record.verification_code != p_verification_code THEN
            -- Increment attempt count
            UPDATE email_verifications
            SET attempt_count = attempt_count + 1
            WHERE id = v_verification_record.id;
            
            RETURN QUERY SELECT FALSE, 'Invalid verification code';
            RETURN;
        END IF;
    END IF;

    -- Mark as verified
    UPDATE email_verifications
    SET is_verified = TRUE,
        verified_at = NOW(),
        verification_ip = COALESCE(p_verification_ip, verification_ip),
        verification_user_agent = COALESCE(p_verification_user_agent, verification_user_agent)
    WHERE id = v_verification_record.id;

    -- Update email address as verified
    UPDATE email_address
    SET is_verified = TRUE,
        verified_at = NOW()
    WHERE id = v_verification_record.email_id;

    -- Check if this completes user verification
    IF EXISTS(
        SELECT 1 FROM users u
        JOIN email_address ea ON u.primary_email_id = ea.id
        WHERE u.id = v_verification_record.user_id
        AND ea.id = v_verification_record.email_id
        AND u.status = 'pending_verification'
    ) THEN
        UPDATE users
        SET email_verified = TRUE,
            status = CASE 
                WHEN phone_verified = TRUE THEN 'active'
                ELSE status
            END
        WHERE id = v_verification_record.user_id;
    END IF;

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        fn_get_current_tenant_id(), v_verification_record.user_id, 
        'EMAIL_VERIFIED', 'user', v_verification_record.user_id,
        jsonb_build_object('email_id', v_verification_record.email_id)
    );

    RETURN QUERY SELECT TRUE, 'Email verified successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_send_phone_verification
Initiates SMS verification workflow.

```sql
CREATE OR REPLACE FUNCTION sp_send_phone_verification(
    p_user_id UUID,
    p_phone_id UUID,
    p_verification_ip INET DEFAULT NULL,
    p_verification_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    expires_at TIMESTAMP WITH TIME ZONE,
    message TEXT
) AS $$
DECLARE
    v_verification_code VARCHAR(6);
    v_code_hash VARCHAR(255);
    v_expires_at TIMESTAMP WITH TIME ZONE;
    v_daily_count INTEGER;
BEGIN
    -- Check daily send limit
    SELECT COUNT(*) INTO v_daily_count
    FROM phone_verifications
    WHERE user_id = p_user_id
    AND phone_id = p_phone_id
    AND sent_at > CURRENT_DATE;
    
    IF v_daily_count >= 5 THEN
        RETURN QUERY SELECT FALSE, NULL::TIMESTAMP WITH TIME ZONE, 'Daily SMS limit exceeded';
        RETURN;
    END IF;

    -- Generate verification code
    v_verification_code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    v_code_hash := crypt(v_verification_code, gen_salt('bf', 8));
    v_expires_at := NOW() + INTERVAL '10 minutes';

    -- Insert verification record
    INSERT INTO phone_verifications (
        user_id, phone_id, verification_code, code_hash,
        expires_at, verification_ip, verification_user_agent,
        daily_send_count
    ) VALUES (
        p_user_id, p_phone_id, v_verification_code, v_code_hash,
        v_expires_at, p_verification_ip, p_verification_user_agent,
        v_daily_count + 1
    );

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        fn_get_current_tenant_id(), p_user_id, 'SMS_VERIFICATION_SENT', 'user', p_user_id,
        jsonb_build_object('phone_id', p_phone_id)
    );

    RETURN QUERY SELECT TRUE, v_expires_at, 'SMS verification sent';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## RBAC Management Procedures

### sp_assign_user_role
Assigns roles to users with audit logging.

```sql
CREATE OR REPLACE FUNCTION sp_assign_user_role(
    p_user_id UUID,
    p_role_id UUID,
    p_tenant_id INTEGER DEFAULT NULL,
    p_ffc_id UUID DEFAULT NULL,
    p_assigned_by UUID DEFAULT NULL,
    p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_existing_assignment UUID;
BEGIN
    -- Check for existing assignment
    SELECT id INTO v_existing_assignment
    FROM user_role_assignments
    WHERE user_id = p_user_id
    AND role_id = p_role_id
    AND COALESCE(tenant_id, 0) = COALESCE(p_tenant_id, 0)
    AND COALESCE(ffc_id::TEXT, '') = COALESCE(p_ffc_id::TEXT, '')
    AND is_active = TRUE;
    
    IF v_existing_assignment IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, 'Role already assigned to user';
        RETURN;
    END IF;

    -- Insert role assignment
    INSERT INTO user_role_assignments (
        user_id, role_id, tenant_id, ffc_id,
        assigned_by, expires_at
    ) VALUES (
        p_user_id, p_role_id, p_tenant_id, p_ffc_id,
        COALESCE(p_assigned_by, fn_get_current_user_id()), p_expires_at
    );

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        COALESCE(p_tenant_id, fn_get_current_tenant_id()), 
        COALESCE(p_assigned_by, fn_get_current_user_id()),
        'ROLE_ASSIGNED', 'user', p_user_id,
        jsonb_build_object(
            'role_id', p_role_id,
            'tenant_id', p_tenant_id,
            'ffc_id', p_ffc_id
        )
    );

    RETURN QUERY SELECT TRUE, 'Role assigned successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_check_user_permission
Validates user permissions for specific actions.

```sql
CREATE OR REPLACE FUNCTION sp_check_user_permission(
    p_user_id UUID,
    p_permission_name VARCHAR(100),
    p_tenant_id INTEGER DEFAULT NULL,
    p_ffc_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN := FALSE;
BEGIN
    -- Check direct permission through role assignments
    SELECT EXISTS(
        SELECT 1
        FROM user_role_assignments ura
        JOIN role_permissions rp ON ura.role_id = rp.role_id
        JOIN user_permissions up ON rp.permission_id = up.id
        WHERE ura.user_id = p_user_id
        AND up.name = p_permission_name
        AND ura.is_active = TRUE
        AND (ura.expires_at IS NULL OR ura.expires_at > NOW())
        AND (p_tenant_id IS NULL OR ura.tenant_id IS NULL OR ura.tenant_id = p_tenant_id)
        AND (p_ffc_id IS NULL OR ura.ffc_id IS NULL OR ura.ffc_id = p_ffc_id)
        AND rp.is_denied = FALSE
        AND up.status = 'active'
    ) INTO v_has_permission;

    RETURN v_has_permission;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_user_permissions
Retrieves all permissions for a user.

```sql
CREATE OR REPLACE FUNCTION sp_get_user_permissions(
    p_user_id UUID,
    p_tenant_id INTEGER DEFAULT NULL,
    p_ffc_id UUID DEFAULT NULL
)
RETURNS TABLE (
    permission_name VARCHAR(100),
    permission_category permission_category_enum,
    role_name VARCHAR(100),
    is_dangerous BOOLEAN,
    requires_2fa BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        up.name,
        up.category,
        ur.name,
        up.is_dangerous,
        up.requires_2fa
    FROM user_role_assignments ura
    JOIN user_roles ur ON ura.role_id = ur.id
    JOIN role_permissions rp ON ur.id = rp.role_id
    JOIN user_permissions up ON rp.permission_id = up.id
    WHERE ura.user_id = p_user_id
    AND ura.is_active = TRUE
    AND (ura.expires_at IS NULL OR ura.expires_at > NOW())
    AND (p_tenant_id IS NULL OR ura.tenant_id IS NULL OR ura.tenant_id = p_tenant_id)
    AND (p_ffc_id IS NULL OR ura.ffc_id IS NULL OR ura.ffc_id = p_ffc_id)
    AND rp.is_denied = FALSE
    AND up.status = 'active'
    ORDER BY up.category, up.name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_revoke_user_role
Revokes role assignments from users.

```sql
CREATE OR REPLACE FUNCTION sp_revoke_user_role(
    p_user_id UUID,
    p_role_id UUID,
    p_tenant_id INTEGER DEFAULT NULL,
    p_ffc_id UUID DEFAULT NULL,
    p_revoked_by UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_assignment_id UUID;
BEGIN
    -- Find assignment to revoke
    SELECT id INTO v_assignment_id
    FROM user_role_assignments
    WHERE user_id = p_user_id
    AND role_id = p_role_id
    AND COALESCE(tenant_id, 0) = COALESCE(p_tenant_id, 0)
    AND COALESCE(ffc_id::TEXT, '') = COALESCE(p_ffc_id::TEXT, '')
    AND is_active = TRUE;
    
    IF v_assignment_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Role assignment not found';
        RETURN;
    END IF;

    -- Deactivate assignment
    UPDATE user_role_assignments
    SET is_active = FALSE,
        updated_at = NOW(),
        updated_by = COALESCE(p_revoked_by, fn_get_current_user_id())
    WHERE id = v_assignment_id;

    -- Audit log
    INSERT INTO audit_log (
        tenant_id, user_id, action, entity_type, entity_id,
        additional_data
    ) VALUES (
        COALESCE(p_tenant_id, fn_get_current_tenant_id()),
        COALESCE(p_revoked_by, fn_get_current_user_id()),
        'ROLE_REVOKED', 'user', p_user_id,
        jsonb_build_object(
            'role_id', p_role_id,
            'assignment_id', v_assignment_id
        )
    );

    RETURN QUERY SELECT TRUE, 'Role revoked successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Audit & Compliance Procedures

### sp_log_audit_event
Central audit logging procedure for all system actions.

```sql
CREATE OR REPLACE FUNCTION sp_log_audit_event(
    p_tenant_id INTEGER,
    p_user_id UUID DEFAULT NULL,
    p_session_id UUID DEFAULT NULL,
    p_action VARCHAR(100),
    p_entity_type VARCHAR(100),
    p_entity_id UUID,
    p_old_values JSONB DEFAULT NULL,
    p_new_values JSONB DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_additional_data JSONB DEFAULT '{}',
    p_compliance_tags VARCHAR(100)[] DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_audit_id UUID;
    v_checksum VARCHAR(64);
BEGIN
    -- Generate audit record ID
    v_audit_id := gen_random_uuid();
    
    -- Calculate checksum for integrity
    v_checksum := encode(
        digest(
            CONCAT(
                v_audit_id::TEXT,
                p_tenant_id::TEXT,
                COALESCE(p_user_id::TEXT, ''),
                p_action,
                p_entity_type,
                COALESCE(p_entity_id::TEXT, ''),
                COALESCE(p_old_values::TEXT, ''),
                COALESCE(p_new_values::TEXT, '')
            ), 'sha256'
        ), 'hex'
    );

    -- Insert audit record
    INSERT INTO audit_log (
        id, tenant_id, user_id, session_id, action, entity_type, entity_id,
        old_values, new_values, ip_address, user_agent, additional_data,
        compliance_tags, checksum, occurred_at
    ) VALUES (
        v_audit_id, p_tenant_id, p_user_id, p_session_id, p_action, p_entity_type, p_entity_id,
        p_old_values, p_new_values, p_ip_address, p_user_agent, p_additional_data,
        p_compliance_tags, v_checksum, NOW()
    );

    RETURN v_audit_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_generate_compliance_report
Generates compliance reports for regulatory requirements.

```sql
CREATE OR REPLACE FUNCTION sp_generate_compliance_report(
    p_tenant_id INTEGER,
    p_report_type VARCHAR(100),
    p_period_start DATE,
    p_period_end DATE,
    p_generated_by UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    report_id UUID,
    report_summary TEXT,
    message TEXT
) AS $$
DECLARE
    v_report_id UUID;
    v_report_data JSONB;
    v_report_summary TEXT;
    v_audit_count INTEGER;
    v_user_count INTEGER;
    v_asset_count INTEGER;
BEGIN
    -- Validate date range
    IF p_period_start >= p_period_end THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Invalid date range';
        RETURN;
    END IF;

    -- Generate report data based on type
    CASE p_report_type
        WHEN 'weekly_activity' THEN
            -- Weekly activity summary
            SELECT COUNT(*) INTO v_audit_count
            FROM audit_log
            WHERE tenant_id = p_tenant_id
            AND occurred_at >= p_period_start
            AND occurred_at <= p_period_end + INTERVAL '1 day';

            SELECT COUNT(*) INTO v_user_count
            FROM users
            WHERE tenant_id = p_tenant_id
            AND last_login_at >= p_period_start
            AND last_login_at <= p_period_end + INTERVAL '1 day';

            v_report_data := jsonb_build_object(
                'audit_events', v_audit_count,
                'active_users', v_user_count,
                'period_start', p_period_start,
                'period_end', p_period_end
            );

            v_report_summary := FORMAT(
                'Weekly Activity Report: %s audit events, %s active users',
                v_audit_count, v_user_count
            );

        WHEN 'soc2_audit' THEN
            -- SOC 2 compliance data
            v_report_data := jsonb_build_object(
                'access_controls', (
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'user_id', user_id,
                            'roles', jsonb_agg(DISTINCT ur.name),
                            'last_login', MAX(attempted_at)
                        )
                    )
                    FROM user_login_history ulh
                    JOIN user_role_assignments ura ON ulh.user_id = ura.user_id
                    JOIN user_roles ur ON ura.role_id = ur.id
                    WHERE ulh.tenant_id = p_tenant_id
                    AND ulh.attempted_at >= p_period_start
                    GROUP BY user_id
                ),
                'failed_logins', (
                    SELECT COUNT(*)
                    FROM user_login_history
                    WHERE tenant_id = p_tenant_id
                    AND login_successful = FALSE
                    AND attempted_at >= p_period_start
                ),
                'data_changes', (
                    SELECT COUNT(*)
                    FROM audit_log
                    WHERE tenant_id = p_tenant_id
                    AND action IN ('CREATE', 'UPDATE', 'DELETE')
                    AND occurred_at >= p_period_start
                )
            );

            v_report_summary := 'SOC 2 Compliance Report Generated';

        ELSE
            RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, 'Unknown report type';
            RETURN;
    END CASE;

    -- Create report record
    v_report_id := gen_random_uuid();
    INSERT INTO compliance_reports (
        id, tenant_id, report_type, report_period_start, report_period_end,
        generated_by, report_summary, report_data, generation_triggered_by
    ) VALUES (
        v_report_id, p_tenant_id, p_report_type, p_period_start, p_period_end,
        COALESCE(p_generated_by, fn_get_current_user_id()), v_report_summary, v_report_data, 'manual'
    );

    -- Audit log
    PERFORM sp_log_audit_event(
        p_tenant_id, COALESCE(p_generated_by, fn_get_current_user_id()), NULL,
        'COMPLIANCE_REPORT_GENERATED', 'compliance_report', v_report_id,
        NULL, jsonb_build_object('report_type', p_report_type)
    );

    RETURN QUERY SELECT TRUE, v_report_id, v_report_summary, 'Report generated successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_create_audit_event
Creates business-level audit events for reporting.

```sql
CREATE OR REPLACE FUNCTION sp_create_audit_event(
    p_tenant_id INTEGER,
    p_ffc_id UUID DEFAULT NULL,
    p_event_type VARCHAR(100),
    p_event_category VARCHAR(50),
    p_event_summary TEXT,
    p_triggered_by_user_id UUID DEFAULT NULL,
    p_affected_persona_ids UUID[] DEFAULT NULL,
    p_event_details JSONB DEFAULT '{}',
    p_severity_level VARCHAR(20) DEFAULT 'info'
)
RETURNS UUID AS $$
DECLARE
    v_event_id UUID;
BEGIN
    v_event_id := gen_random_uuid();

    INSERT INTO audit_events (
        id, tenant_id, ffc_id, event_type, event_category,
        event_summary, triggered_by_user_id, affected_persona_ids,
        event_details, severity_level
    ) VALUES (
        v_event_id, p_tenant_id, p_ffc_id, p_event_type, p_event_category,
        p_event_summary, p_triggered_by_user_id, p_affected_persona_ids,
        p_event_details, p_severity_level
    );

    -- Also log in detailed audit log
    PERFORM sp_log_audit_event(
        p_tenant_id, p_triggered_by_user_id, NULL,
        'AUDIT_EVENT_CREATED', 'audit_event', v_event_id,
        NULL, jsonb_build_object(
            'event_type', p_event_type,
            'event_category', p_event_category,
            'severity_level', p_severity_level
        )
    );

    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_audit_trail
Retrieves audit trail for specific entities or date ranges.

```sql
CREATE OR REPLACE FUNCTION sp_get_audit_trail(
    p_tenant_id INTEGER,
    p_entity_type VARCHAR(100) DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    audit_id UUID,
    occurred_at TIMESTAMP WITH TIME ZONE,
    user_email VARCHAR(255),
    action VARCHAR(100),
    entity_type VARCHAR(100),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    additional_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.id,
        al.occurred_at,
        u.email,
        al.action,
        al.entity_type,
        al.entity_id,
        al.old_values,
        al.new_values,
        al.ip_address,
        al.additional_data
    FROM audit_log al
    LEFT JOIN users u ON al.user_id = u.id
    WHERE al.tenant_id = p_tenant_id
    AND (p_entity_type IS NULL OR al.entity_type = p_entity_type)
    AND (p_entity_id IS NULL OR al.entity_id = p_entity_id)
    AND (p_user_id IS NULL OR al.user_id = p_user_id)
    AND (p_start_date IS NULL OR al.occurred_at >= p_start_date)
    AND (p_end_date IS NULL OR al.occurred_at <= p_end_date)
    ORDER BY al.occurred_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## PII Processing Procedures

### sp_detect_pii
Initiates PII detection jobs for documents and text data.

```sql
CREATE OR REPLACE FUNCTION sp_detect_pii(
    p_tenant_id INTEGER,
    p_target_entity_type VARCHAR(100),
    p_target_entity_id UUID,
    p_initiated_by UUID,
    p_processing_options JSONB DEFAULT '{}'
)
RETURNS TABLE (
    success BOOLEAN,
    job_id UUID,
    message TEXT
) AS $$
DECLARE
    v_job_id UUID;
    v_existing_job_count INTEGER;
BEGIN
    -- Check for existing pending jobs
    SELECT COUNT(*) INTO v_existing_job_count
    FROM pii_processing_jobs
    WHERE tenant_id = p_tenant_id
    AND target_entity_type = p_target_entity_type
    AND target_entity_id = p_target_entity_id
    AND status IN ('pending', 'processing');
    
    IF v_existing_job_count > 0 THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'PII processing already in progress';
        RETURN;
    END IF;

    -- Create PII processing job
    v_job_id := gen_random_uuid();
    INSERT INTO pii_processing_jobs (
        id, tenant_id, job_type, target_entity_type, target_entity_id,
        initiated_by, processing_options, status
    ) VALUES (
        v_job_id, p_tenant_id, 'detection', p_target_entity_type, p_target_entity_id,
        p_initiated_by, p_processing_options, 'pending'
    );

    -- Audit log
    PERFORM sp_log_audit_event(
        p_tenant_id, p_initiated_by, NULL,
        'PII_DETECTION_INITIATED', p_target_entity_type, p_target_entity_id,
        NULL, jsonb_build_object('job_id', v_job_id),
        NULL, NULL, p_processing_options,
        ARRAY['GDPR', 'CCPA']
    );

    RETURN QUERY SELECT TRUE, v_job_id, 'PII detection job created';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_update_pii_job_status
Updates PII processing job status and results.

```sql
CREATE OR REPLACE FUNCTION sp_update_pii_job_status(
    p_job_id UUID,
    p_status pii_status_enum,
    p_pii_types_found VARCHAR(100)[] DEFAULT NULL,
    p_pii_count INTEGER DEFAULT 0,
    p_confidence_score DECIMAL(3,2) DEFAULT NULL,
    p_processing_results JSONB DEFAULT '{}',
    p_error_message TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_job_record pii_processing_jobs%ROWTYPE;
    v_processing_duration INTEGER;
BEGIN
    -- Get existing job record
    SELECT * INTO v_job_record
    FROM pii_processing_jobs
    WHERE id = p_job_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'PII processing job not found';
        RETURN;
    END IF;

    -- Calculate processing duration
    IF p_status = 'completed' OR p_status = 'failed' THEN
        v_processing_duration := EXTRACT(EPOCH FROM (NOW() - v_job_record.started_at)) * 1000;
    END IF;

    -- Update job record
    UPDATE pii_processing_jobs
    SET status = p_status,
        pii_types_found = COALESCE(p_pii_types_found, pii_types_found),
        pii_count = COALESCE(p_pii_count, pii_count),
        confidence_score = COALESCE(p_confidence_score, confidence_score),
        processing_results = COALESCE(p_processing_results, processing_results),
        error_message = p_error_message,
        completed_at = CASE WHEN p_status IN ('completed', 'failed') THEN NOW() ELSE completed_at END,
        processing_duration_ms = COALESCE(v_processing_duration, processing_duration_ms),
        updated_at = NOW()
    WHERE id = p_job_id;

    -- Audit log
    PERFORM sp_log_audit_event(
        v_job_record.tenant_id, fn_get_current_user_id(), NULL,
        'PII_JOB_STATUS_UPDATED', 'pii_processing_job', p_job_id,
        jsonb_build_object('old_status', v_job_record.status),
        jsonb_build_object('new_status', p_status, 'pii_count', p_pii_count),
        NULL, NULL,
        jsonb_build_object('confidence_score', p_confidence_score),
        ARRAY['GDPR', 'CCPA']
    );

    RETURN QUERY SELECT TRUE, 'PII job status updated';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security Configuration Procedures

### sp_update_system_configuration
Manages system-wide security and configuration settings.

```sql
CREATE OR REPLACE FUNCTION sp_update_system_configuration(
    p_tenant_id INTEGER DEFAULT NULL,
    p_config_key VARCHAR(200),
    p_config_value TEXT,
    p_changed_by UUID DEFAULT NULL,
    p_change_reason TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_previous_value TEXT;
    v_config_record system_configurations%ROWTYPE;
BEGIN
    -- Get existing configuration
    SELECT * INTO v_config_record
    FROM system_configurations
    WHERE COALESCE(tenant_id, 0) = COALESCE(p_tenant_id, 0)
    AND config_key = p_config_key;

    IF FOUND THEN
        v_previous_value := v_config_record.config_value;
        
        -- Update existing configuration
        UPDATE system_configurations
        SET config_value = p_config_value,
            previous_value = v_previous_value,
            changed_by = COALESCE(p_changed_by, fn_get_current_user_id()),
            change_reason = p_change_reason,
            updated_at = NOW()
        WHERE id = v_config_record.id;
    ELSE
        -- Insert new configuration
        INSERT INTO system_configurations (
            tenant_id, config_key, config_value, config_type,
            changed_by, change_reason
        ) VALUES (
            p_tenant_id, p_config_key, p_config_value, 'string',
            COALESCE(p_changed_by, fn_get_current_user_id()), p_change_reason
        );
    END IF;

    -- Audit log
    PERFORM sp_log_audit_event(
        COALESCE(p_tenant_id, fn_get_current_tenant_id()),
        COALESCE(p_changed_by, fn_get_current_user_id()), NULL,
        'SYSTEM_CONFIG_UPDATED', 'system_configuration', gen_random_uuid(),
        CASE WHEN v_previous_value IS NOT NULL THEN
            jsonb_build_object('config_key', p_config_key, 'value', v_previous_value)
        ELSE NULL END,
        jsonb_build_object('config_key', p_config_key, 'value', p_config_value),
        NULL, NULL,
        jsonb_build_object('change_reason', p_change_reason)
    );

    RETURN QUERY SELECT TRUE, 'Configuration updated successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security Validation Functions

### fn_validate_password_strength
Validates password complexity requirements.

```sql
CREATE OR REPLACE FUNCTION fn_validate_password_strength(
    p_password TEXT
)
RETURNS TABLE (
    is_valid BOOLEAN,
    score INTEGER,
    feedback TEXT[]
) AS $$
DECLARE
    v_score INTEGER := 0;
    v_feedback TEXT[] := '{}';
    v_length INTEGER;
    v_has_upper BOOLEAN;
    v_has_lower BOOLEAN;
    v_has_digit BOOLEAN;
    v_has_special BOOLEAN;
BEGIN
    v_length := LENGTH(p_password);
    
    -- Check length
    IF v_length >= 8 THEN
        v_score := v_score + 1;
    ELSE
        v_feedback := array_append(v_feedback, 'Password must be at least 8 characters');
    END IF;
    
    IF v_length >= 12 THEN
        v_score := v_score + 1;
    END IF;
    
    -- Check character types
    v_has_upper := p_password ~ '[A-Z]';
    v_has_lower := p_password ~ '[a-z]';
    v_has_digit := p_password ~ '[0-9]';
    v_has_special := p_password ~ '[^A-Za-z0-9]';
    
    IF v_has_upper THEN v_score := v_score + 1;
    ELSE v_feedback := array_append(v_feedback, 'Include uppercase letters'); END IF;
    
    IF v_has_lower THEN v_score := v_score + 1;
    ELSE v_feedback := array_append(v_feedback, 'Include lowercase letters'); END IF;
    
    IF v_has_digit THEN v_score := v_score + 1;
    ELSE v_feedback := array_append(v_feedback, 'Include numbers'); END IF;
    
    IF v_has_special THEN v_score := v_score + 1;
    ELSE v_feedback := array_append(v_feedback, 'Include special characters'); END IF;
    
    -- Check for common patterns
    IF p_password ~* '(password|123456|qwerty)' THEN
        v_score := v_score - 2;
        v_feedback := array_append(v_feedback, 'Avoid common password patterns');
    END IF;
    
    RETURN QUERY SELECT (v_score >= 4), v_score, v_feedback;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### fn_check_rate_limit
Generic rate limiting function for security operations.

```sql
CREATE OR REPLACE FUNCTION fn_check_rate_limit(
    p_identifier TEXT,
    p_action VARCHAR(100),
    p_max_attempts INTEGER,
    p_time_window INTERVAL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_attempt_count INTEGER;
BEGIN
    -- Count attempts in the time window
    SELECT COUNT(*) INTO v_attempt_count
    FROM audit_log
    WHERE additional_data->>'rate_limit_key' = p_identifier
    AND action = p_action
    AND occurred_at > NOW() - p_time_window;
    
    RETURN v_attempt_count < p_max_attempts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Error Handling & Security

### Security Best Practices
All security procedures implement the following practices:

1. **Input Validation**: All parameters are validated before processing
2. **SQL Injection Prevention**: Parameterized queries and proper escaping
3. **Rate Limiting**: Built-in rate limiting for sensitive operations
4. **Audit Logging**: Complete audit trail for all security events
5. **Error Sanitization**: Generic error messages to prevent information disclosure
6. **Session Validation**: Proper session management and expiration
7. **Permission Enforcement**: Database-level permission checking

### Error Handling Pattern
```sql
-- Standard error handling pattern used across all procedures
BEGIN
    -- Validation
    IF condition THEN
        RETURN QUERY SELECT FALSE, 'Generic error message';
        RETURN;
    END IF;
    
    -- Main logic with exception handling
    -- ...
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log detailed error for debugging
        INSERT INTO audit_log (
            tenant_id, action, entity_type, error_message
        ) VALUES (
            fn_get_current_tenant_id(), 'ERROR', 'system', SQLERRM
        );
        
        -- Return generic error to user
        RETURN QUERY SELECT FALSE, 'An error occurred. Please try again.';
END;
```

### Security Configuration Examples
```sql
-- Enable row-level security
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Create policy for tenant isolation
CREATE POLICY tenant_isolation_policy ON user_sessions
    FOR ALL TO application_role
    USING (EXISTS (
        SELECT 1 FROM users u 
        WHERE u.id = user_sessions.user_id 
        AND u.tenant_id = fn_get_current_tenant_id()
    ));

-- Grant minimal required permissions
GRANT EXECUTE ON FUNCTION sp_authenticate_user TO application_role;
REVOKE ALL ON user_sessions FROM application_role;
```

---

*This comprehensive security and compliance procedure documentation provides the Forward Inheritance Platform with enterprise-grade security capabilities, ensuring proper authentication, authorization, audit logging, and regulatory compliance while maintaining high security standards throughout the system.*