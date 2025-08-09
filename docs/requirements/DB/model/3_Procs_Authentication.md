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

The authentication and user management procedures work in conjunction with AWS Cognito, which handles password management, verification, and JWT-based authentication. The database procedures focus on user creation from Cognito data, profile management, and authorization checks.

### AWS Cognito Integration
- **Authentication**: Handled entirely by AWS Cognito
- **Password Management**: Managed by AWS Cognito
- **Email/Phone Verification**: Managed by AWS Cognito
- **Session Management**: JWT tokens issued by AWS Cognito
- **MFA**: Configured in AWS Cognito

### Database Procedure Categories
- **User Creation**: `sp_create_user_from_cognito` - Creates database user after Cognito registration
- **Profile Management**: `sp_update_user_profile` - Updates user profile information
- **Authorization**: Permission checking within the application context
- **Utilities**: `fn_get_current_tenant_id`, `fn_get_current_user_id` - Context helpers

## User Registration Flow

### sp_create_user_from_cognito
Creates a database user record after successful AWS Cognito registration, with automatic primary persona creation.

```sql
CREATE OR REPLACE FUNCTION sp_create_user_from_cognito(
    p_tenant_id INTEGER,
    p_cognito_user_id TEXT,
    p_cognito_username TEXT,
    p_email TEXT,
    p_phone VARCHAR(20),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_email_verified BOOLEAN DEFAULT FALSE,
    p_phone_verified BOOLEAN DEFAULT FALSE,
    p_country_code VARCHAR(10) DEFAULT '+1'
) RETURNS TABLE (
    user_id UUID,
    persona_id UUID
)
```

**Process Flow:**
1. **Cognito Registration**: User registers through AWS Cognito (handled externally)
2. **User Creation**: Creates database user record linked to Cognito ID
3. **Status Setting**: Sets status based on verification status from Cognito
4. **Primary Persona**: Automatically creates primary persona for business identity
5. **Contact Records**: Creates normalized email and phone records
6. **Audit Logging**: Records user creation event

**Key Features:**
- **Cognito Integration**: Links database user to Cognito identity
- **Dual Identity**: Creates both user (auth) and persona (business) records
- **Normalized Contacts**: Email and phone stored in separate tables
- **Verification Status**: Reflects Cognito verification state
- **Audit Trail**: Complete user creation logging

**Usage Example:**
```sql
-- Create user after Cognito registration
SELECT * FROM sp_create_user_from_cognito(
    1,                                       -- tenant_id (1=Forward)
    'cognito-sub-123456',                   -- cognito_user_id (from Cognito)
    'john.smith',                           -- cognito_username
    'john@example.com',                     -- email
    '+15550123',                           -- phone
    'John',                                 -- first_name
    'Smith',                                -- last_name
    true,                                   -- email_verified (from Cognito)
    true,                                   -- phone_verified (from Cognito)
    '+1'                                    -- country_code
);
```

**Integration Notes:**
- Called after successful Cognito registration
- Cognito handles all password management
- Verification status comes from Cognito
- No password stored in database

## Authentication Procedures

### AWS Cognito Authentication Flow

Authentication is handled entirely by AWS Cognito, which provides:

**Cognito Features:**
1. **User Authentication**: Username/password validation
2. **MFA Support**: SMS and TOTP multi-factor authentication
3. **Token Management**: JWT access and refresh tokens
4. **Session Security**: Configurable token expiration
5. **Security Features**: Account lockout, password policies, device tracking

**Authentication Flow:**
1. **Client Login**: Application sends credentials to AWS Cognito
2. **Cognito Validation**: AWS Cognito validates credentials
3. **MFA Challenge**: If enabled, Cognito handles MFA flow
4. **Token Issuance**: Cognito returns JWT tokens (access, ID, refresh)
5. **Database Lookup**: Application uses Cognito ID to fetch user data from database

**JWT Token Usage:**
```javascript
// Example: Validating Cognito JWT in application
const cognitoUserId = decodedToken.sub;  // Cognito user ID
const email = decodedToken.email;
const emailVerified = decodedToken.email_verified;

// Fetch user data from database using Cognito ID
const userData = await db.query(
    'SELECT * FROM users WHERE cognito_user_id = $1',
    [cognitoUserId]
);
```

**Security Benefits:**
- No password storage in database
- AWS manages security patches and compliance
- Built-in account recovery flows
- Automatic token rotation
- Device fingerprinting and tracking

## Verification Workflows

### AWS Cognito Verification

Email and phone verification are handled entirely by AWS Cognito:

**Cognito Verification Process:**
1. **Registration**: User signs up through Cognito
2. **Verification Email/SMS**: Cognito automatically sends verification codes
3. **Code Validation**: User submits code to Cognito
4. **Status Update**: Cognito marks email/phone as verified
5. **Database Sync**: Verification status passed to `sp_create_user_from_cognito`

**Cognito Configuration:**
```javascript
// Example: Cognito User Pool configuration
{
  "AutoVerifiedAttributes": ["email", "phone_number"],
  "VerificationMessageTemplate": {
    "EmailMessage": "Your verification code is {####}",
    "EmailSubject": "Verify your Forward Inheritance account",
    "SmsMessage": "Your Forward verification code is {####}"
  },
  "MfaConfiguration": "OPTIONAL",
  "EnabledMfas": ["SMS_MFA", "SOFTWARE_TOKEN_MFA"]
}
```

**Verification Status in Database:**
- Verification status is stored when user is created via `sp_create_user_from_cognito`
- The database reflects Cognito's verification state
- No separate verification procedures needed in database

**Benefits:**
- Automatic retry logic for failed deliveries
- Built-in rate limiting
- Configurable code expiration
- Support for custom verification templates
- No verification tokens stored in database

## Password Management

### AWS Cognito Password Management

Password management is handled entirely by AWS Cognito:

**Cognito Password Features:**
1. **Password Policies**: Configurable complexity requirements
2. **Forgot Password Flow**: Built-in password reset via email/SMS
3. **Password History**: Prevents reuse of recent passwords
4. **Temporary Passwords**: Admin-initiated password resets
5. **Change Password**: Authenticated users can change passwords

**Password Reset Flow:**
```javascript
// Example: Initiating password reset with Cognito
await cognito.forgotPassword({
    ClientId: 'your-client-id',
    Username: 'john@example.com'
});

// Cognito sends verification code to user's email/phone

// User submits new password with verification code
await cognito.confirmForgotPassword({
    ClientId: 'your-client-id',
    Username: 'john@example.com',
    ConfirmationCode: '123456',
    Password: 'NewSecurePassword123!'
});
```

**Password Policy Configuration:**
```javascript
{
  "PasswordPolicy": {
    "MinimumLength": 12,
    "RequireUppercase": true,
    "RequireLowercase": true,
    "RequireNumbers": true,
    "RequireSymbols": true,
    "TemporaryPasswordValidityDays": 7
  }
}
```

**Security Benefits:**
- No password hashes in database
- AWS manages encryption and storage
- Automatic session invalidation on password change
- Built-in rate limiting for password attempts
- Compliance with security standards (SOC 2, ISO 27001)

## Session Management

### AWS Cognito Session Management

Session management is handled through AWS Cognito JWT tokens:

**Cognito Token Types:**
1. **ID Token**: Contains user identity claims (email, name, etc.)
2. **Access Token**: Used for API authorization
3. **Refresh Token**: Used to obtain new ID/Access tokens

**Token Configuration:**
```javascript
{
  "AccessTokenValidity": 1,        // 1 hour
  "IdTokenValidity": 1,            // 1 hour
  "RefreshTokenValidity": 30,      // 30 days
  "TokenValidityUnits": {
    "AccessToken": "hours",
    "IdToken": "hours",
    "RefreshToken": "days"
  }
}
```

**Session Validation in Application:**
```javascript
// Example: Validating Cognito JWT token
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

// Verify JWT signature using Cognito's public keys
const client = jwksClient({
    jwksUri: `https://cognito-idp.${region}.amazonaws.com/${userPoolId}/.well-known/jwks.json`
});

function verifyToken(token) {
    return new Promise((resolve, reject) => {
        jwt.verify(token, getKey, {
            audience: clientId,
            issuer: `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`,
            algorithms: ['RS256']
        }, (err, decoded) => {
            if (err) reject(err);
            else resolve(decoded);
        });
    });
}
```

**Token Refresh Flow:**
```javascript
// Refresh expired tokens using refresh token
await cognito.initiateAuth({
    AuthFlow: 'REFRESH_TOKEN_AUTH',
    ClientId: 'your-client-id',
    AuthParameters: {
        REFRESH_TOKEN: refreshToken
    }
});
```

**Security Benefits:**
- Stateless authentication (no server-side session storage)
- Automatic token expiration
- Secure token rotation
- Device tracking through Cognito
- Built-in revocation support

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

### AWS Cognito Security
- **Password Management**: AWS Cognito handles all password storage and validation
- **Encryption**: Passwords encrypted at rest and in transit by AWS
- **Compliance**: SOC 2, ISO 27001, HIPAA eligible service
- **DDoS Protection**: Built-in AWS Shield protection

### JWT Token Security
- **Signature Verification**: Tokens signed with RS256 algorithm
- **Public Key Validation**: Keys fetched from Cognito JWKS endpoint
- **Token Expiration**: Automatic expiration with configurable lifetimes
- **Refresh Token Rotation**: Optional refresh token rotation for enhanced security

### Verification Security
- **Managed by Cognito**: Email and SMS verification handled by AWS
- **Rate Limiting**: Built-in protection against verification abuse
- **Code Expiration**: Configurable verification code lifetimes
- **Delivery Tracking**: AWS tracks delivery success/failure

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