# 04 - Authentication & User Management Procedures

## Table of Contents
1. [Overview](#overview)
2. [User Registration Flow](#user-registration-flow)
3. [Authentication Procedures](#authentication-procedures)
4. [Verification Workflows](#verification-workflows)
5. [Password Management](#password-management)
6. [Session Management](#session-management)
7. [Permission Checking](#permission-checking)
8. [Utility Functions](#utility-functions)
9. [Security Considerations](#security-considerations)

## Overview

The authentication and user management procedures implement the platform's dual-channel verification system, secure session management, and role-based access control. These 13 procedures handle everything from user registration through session validation.

### Procedure Categories
- **User Registration**: `sp_register_user`
- **Authentication**: `sp_login_user` 
- **Verification**: `sp_verify_email`, `sp_verify_phone`
- **Password Management**: `sp_request_password_reset`, `sp_reset_password`
- **Session Management**: `sp_create_session`, `sp_refresh_session`, `fn_validate_session`, `sp_revoke_session`
- **Authorization**: `fn_check_user_permission`
- **Utilities**: `fn_get_current_tenant_id`, `fn_get_current_user_id`

## User Registration Flow

### sp_register_user
Creates a new user account with dual-channel verification requirements and automatic primary persona creation.

```sql
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
)
```

**Process Flow:**
1. **User Creation**: Creates user record with `pending_verification` status
2. **Primary Persona**: Automatically creates primary persona for business identity
3. **Email Verification**: Generates 24-hour verification token
4. **Audit Logging**: Records registration event with referral tracking
5. **Return Values**: Provides IDs for immediate use by calling application

**Key Features:**
- **Atomic Operation**: All steps succeed or fail together
- **Dual Identity**: Creates both user (auth) and persona (business) records
- **Verification Required**: Users cannot be active until both email and phone verified
- **Referral Tracking**: Optional referral code for analytics
- **Audit Trail**: Complete registration activity logging

**Usage Example:**
```sql
-- Register new user
SELECT * FROM sp_register_user(
    1,                                       -- tenant_id (1=Forward)
    'john@example.com',                       -- email
    '+1-555-0123',                           -- phone
    '$2b$12$hashed_password_here',           -- password_hash
    'John',                                  -- first_name
    'Smith',                                 -- last_name
    'REF123'                                 -- referral_code
);
```

**Error Conditions:**
- Email already exists for tenant
- Invalid tenant_id
- Missing required fields
- Database constraint violations

**Security Notes:**
- Password must be hashed by application before calling
- Verification token is cryptographically secure UUID
- All sensitive operations are logged for audit

## Authentication Procedures

### sp_login_user
Authenticates user credentials and manages session creation with security logging.

```sql
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
)
```

**Process Flow:**
1. **Credential Validation**: Verifies email and password hash match
2. **Login Logging**: Records both successful and failed attempts
3. **MFA Check**: Determines if multi-factor authentication required
4. **Session Creation**: Creates session token if no MFA needed
5. **Security Tracking**: Logs IP address, user agent, device info

**Key Features:**
- **Security Logging**: All login attempts recorded
- **MFA Integration**: Supports multi-factor authentication flow
- **Device Tracking**: Records device information for security analysis
- **Conditional Sessions**: Only creates session if MFA not required
- **Tenant Context**: Returns tenant information for application context

**Return Values:**
- **user_id**: Authenticated user identifier
- **tenant_id**: User's tenant for multi-tenant context
- **mfa_required**: Whether additional authentication needed
- **session_token**: Session identifier (NULL if MFA required)

**Usage Example:**
```sql
-- Authenticate user
SELECT * FROM sp_login_user(
    'john@example.com',                      -- email
    '$2b$12$hashed_password_here',          -- password_hash
    '192.168.1.100'::inet,                  -- ip_address
    'Mozilla/5.0 (Chrome/91.0)',           -- user_agent
    '{"device_type": "desktop"}'::jsonb     -- device_info
);
```

**Security Features:**
- Password comparison at database level
- Comprehensive audit logging
- Failed attempt tracking
- Device fingerprinting support

## Verification Workflows

### sp_verify_email
Validates email verification tokens and updates user status accordingly.

```sql
CREATE OR REPLACE FUNCTION sp_verify_email(
    p_token UUID
) RETURNS BOOLEAN
```

**Process Flow:**
1. **Token Validation**: Checks token exists, not expired, not already used
2. **User Update**: Sets `email_verified = true`
3. **Status Update**: Activates user if phone also verified
4. **Token Marking**: Marks verification token as used
5. **Success Return**: Returns true/false for verification result

**Key Features:**
- **Token Security**: Single-use tokens with expiration
- **Atomic Status Update**: User activation when both verifications complete
- **Audit Trail**: Verification events logged automatically
- **Graceful Failure**: Returns false for invalid/expired tokens

### sp_verify_phone
Validates SMS verification codes for phone number confirmation.

```sql
CREATE OR REPLACE FUNCTION sp_verify_phone(
    p_user_id UUID,
    p_code VARCHAR(6)
) RETURNS BOOLEAN
```

**Process Flow:**
1. **Code Validation**: Verifies code exists, not expired, not used
2. **User Update**: Sets `phone_verified = true`
3. **Status Update**: Activates user if email also verified
4. **Code Marking**: Marks verification code as used
5. **Success Return**: Returns verification result

**Key Features:**
- **Time-Limited Codes**: SMS codes expire quickly for security
- **Single Use**: Codes can only be used once
- **Dual Verification**: User activated only when both email and phone verified
- **Security Logging**: All verification attempts logged

**Usage Example:**
```sql
-- Verify phone with SMS code
SELECT sp_verify_phone(
    '550e8400-e29b-41d4-a716-446655440000',  -- user_id
    '123456'                                  -- verification_code
);
```

## Password Management

### sp_request_password_reset
Initiates password reset workflow with secure token generation.

```sql
CREATE OR REPLACE FUNCTION sp_request_password_reset(
    p_email VARCHAR(255)
) RETURNS UUID
```

**Process Flow:**
1. **User Lookup**: Finds user by email (excludes deleted users)
2. **Token Generation**: Creates secure reset token
3. **Token Storage**: Stores token with 1-hour expiration
4. **Return Token**: Provides token for email/SMS delivery

**Key Features:**
- **Short Expiration**: Reset tokens expire in 1 hour
- **Secure Generation**: Cryptographically secure random tokens
- **User Validation**: Only active users can request resets
- **Audit Logging**: Reset requests logged for security monitoring

### sp_reset_password
Completes password reset process with comprehensive security measures.

```sql
CREATE OR REPLACE FUNCTION sp_reset_password(
    p_token UUID,
    p_new_password_hash TEXT
) RETURNS BOOLEAN
```

**Process Flow:**
1. **Token Validation**: Verifies token exists, not expired, not used
2. **Password Update**: Sets new password hash
3. **Token Invalidation**: Marks reset token as used
4. **Session Cleanup**: Invalidates all existing user sessions
5. **Success Return**: Returns operation result

**Key Features:**
- **Session Invalidation**: Forces re-authentication on all devices
- **Token Single-Use**: Reset tokens can only be used once
- **Immediate Effect**: Password change takes effect immediately
- **Security Logging**: Password changes logged for audit

**Security Considerations:**
- All existing sessions invalidated to prevent unauthorized access
- New password must be hashed by application
- Reset tokens have short lifespan to minimize attack window

## Session Management

### sp_create_session
Creates new user session with security tracking.

```sql
CREATE OR REPLACE FUNCTION sp_create_session(
    p_user_id UUID,
    p_ip_address INET,
    p_user_agent TEXT,
    p_device_info JSONB DEFAULT NULL
) RETURNS UUID
```

**Key Features:**
- **7-Day Expiration**: Sessions automatically expire after 7 days
- **Device Tracking**: Records IP, user agent, device information
- **Secure Tokens**: Cryptographically secure session identifiers
- **Audit Ready**: All session creation logged

### sp_refresh_session
Extends session lifetime with new token generation.

```sql
CREATE OR REPLACE FUNCTION sp_refresh_session(
    p_session_token UUID
) RETURNS UUID
```

**Process Flow:**
1. **Session Validation**: Verifies current session is valid and active
2. **Old Session Invalidation**: Marks current session as inactive
3. **New Session Creation**: Creates new session with fresh token
4. **Context Preservation**: Maintains IP, user agent, device info
5. **New Token Return**: Provides fresh session token

**Key Features:**
- **Token Rotation**: Each refresh generates new token
- **Seamless Transition**: Preserves user context during refresh
- **Security Enhancement**: Reduces token reuse risks
- **Extended Lifetime**: Resets 7-day expiration timer

### fn_validate_session
Validates session tokens for authentication middleware.

```sql
CREATE OR REPLACE FUNCTION fn_validate_session(
    p_session_token UUID
) RETURNS TABLE (
    user_id UUID,
    tenant_id INTEGER,
    is_valid BOOLEAN
)
```

**Validation Criteria:**
- Session token exists in database
- Session is marked as active
- Session has not expired
- Associated user account is active

**Usage in Middleware:**
```sql
-- Validate session for API request
SELECT * FROM fn_validate_session('session-token-here');
```

### sp_revoke_session
Immediately invalidates user session for logout or security purposes.

```sql
CREATE OR REPLACE FUNCTION sp_revoke_session(
    p_session_token UUID
) RETURNS VOID
```

**Process:**
- Marks session as inactive
- Records revocation timestamp
- Effective immediately

## Permission Checking

### fn_check_user_permission
Validates user permissions within Forward Family Circle context.

```sql
CREATE OR REPLACE FUNCTION fn_check_user_permission(
    p_user_id UUID,
    p_ffc_id UUID,
    p_permission_name VARCHAR(100)
) RETURNS BOOLEAN
```

**Permission Resolution Flow:**
1. **Membership Check**: Verifies user is active member of FFC
2. **Role Lookup**: Gets user's role within the FFC
3. **Permission Query**: Checks if role has requested permission
4. **Boolean Return**: True if permission granted, false otherwise

**Key Features:**
- **Context-Aware**: Permissions scoped to specific FFC
- **Role-Based**: Uses role-permission matrix for authorization
- **Active Only**: Only considers active FFC memberships
- **Performance Optimized**: Single query for permission check

**Usage Example:**
```sql
-- Check if user can create assets in FFC
SELECT fn_check_user_permission(
    '550e8400-e29b-41d4-a716-446655440000',  -- user_id
    '660e8400-e29b-41d4-a716-446655440000',  -- ffc_id
    'asset_create'                            -- permission_name
);
```

## Utility Functions

### fn_get_current_tenant_id
Retrieves current tenant context from session variables.

```sql
CREATE OR REPLACE FUNCTION fn_get_current_tenant_id() 
RETURNS INTEGER
```

**Implementation:**
- Reads from `app.current_tenant_id` session variable
- Set by application layer during authentication
- Used by audit logging and multi-tenant queries
- Raises exception if no tenant context set

### fn_get_current_user_id
Retrieves current user context from session variables.

```sql
CREATE OR REPLACE FUNCTION fn_get_current_user_id() 
RETURNS UUID
```

**Implementation:**
- Reads from `app.current_user_id` session variable
- Set by application layer during authentication
- Used by audit logging and user-specific operations
- Raises exception if no user context set

**Usage in Application:**
```sql
-- Set context at start of request
SET LOCAL app.current_tenant_id = 1;  -- 1=Forward
SET LOCAL app.current_user_id = '660e8400-e29b-41d4-a716-446655440000';

-- Context automatically used by procedures
SELECT sp_create_asset(...);  -- Uses current tenant/user context
```

## Security Considerations

### Password Security
- **Never Store Plain Text**: All procedures expect pre-hashed passwords
- **Secure Hashing**: Use bcrypt or similar with appropriate cost factor
- **Hash Comparison**: Database-level password verification
- **Immediate Invalidation**: Password changes invalidate all sessions

### Session Security
- **Secure Tokens**: Cryptographically secure random UUIDs
- **Token Rotation**: Refresh generates new tokens
- **Automatic Expiration**: 7-day default lifetime
- **Device Tracking**: IP and user agent logging for analysis

### Verification Security
- **Time-Limited Tokens**: Email tokens expire in 24 hours
- **Short SMS Codes**: Phone codes expire quickly
- **Single Use**: All verification tokens/codes are one-time use
- **Audit Logging**: All verification attempts logged

### Multi-Tenant Security
- **Complete Isolation**: All operations scoped to tenant
- **Context Validation**: Tenant context required for operations
- **Cross-Tenant Prevention**: Schema enforces tenant boundaries
- **Audit Segregation**: Audit logs partitioned by tenant

### Error Handling
- **Information Leakage**: Errors don't reveal user existence
- **Consistent Timing**: Operations take similar time regardless of success
- **Graceful Failures**: Invalid operations return false, not exceptions
- **Audit Trail**: All failures logged for security analysis

---

*These authentication procedures provide the secure foundation for the Forward Inheritance Platform's user management system, implementing industry best practices for security, audit, and multi-tenant isolation.*