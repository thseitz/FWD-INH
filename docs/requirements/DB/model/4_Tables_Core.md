# 03 - Core Infrastructure Tables

## Table of Contents
1. [Overview](#overview)
2. [Multi-Tenant Architecture](#multi-tenant-architecture)
3. [Dual-Identity System](#dual-identity-system)
4. [Family Organization](#family-organization)
5. [Role-Based Access Control](#role-based-access-control)
6. [Usage Tracking](#usage-tracking)
7. [Invitation System](#invitation-system)
8. [Table Relationships](#table-relationships)

## Overview

The core infrastructure tables form the foundation of the Forward Inheritance Platform, implementing multi-tenant architecture, dual-identity user management, and family-based access control. These 11 tables handle everything from basic authentication to complex family relationship management.

### Core Tables List
1. **tenants** - Multi-tenant organization management
2. **users** - Authentication and system access (AWS Cognito integrated)
3. **personas** - Business identity layer
4. **fwd_family_circles** - Family financial organizations
5. **ffc_personas** - Family circle membership with role-based access
6. **ffc_invitations** - Invitation workflow tracking
7. **email_address** - Normalized email storage
8. **phone_number** - Normalized phone storage
9. **address** - Physical address storage

## Multi-Tenant Architecture

### tenants table
The `tenants` table serves as the root of the multi-tenant hierarchy, providing complete data isolation for white lableing B2B partners and their data ownership and security. 

```sql
CREATE TABLE tenants (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    domain TEXT,
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    settings JSONB DEFAULT '{}',
    feature_flags JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- **Simple Integer IDs**: Tenants use simple INTEGER primary keys (1=Forward, 2-50 for customers)
- **Complete Isolation**: Every other table references `tenant_id` for data separation
- **White-Label Support**: Domain and branding configuration for white-label deployments
- **Flexible Settings**: JSONB fields for tenant-specific configurations and feature flags

**Business Rules:**
- Tenant names must be unique within the system
- Only active tenants (is_active = true) can create new users or access the platform
- Platform anticipates max 50 tenants total (1=Forward, 2-50 for customers)

**Common Queries:**
```sql
-- Get tenant information
SELECT * FROM tenants WHERE id = 1;  -- Forward tenant

-- Check tenant status
SELECT name, display_name, is_active 
FROM tenants 
WHERE id = ?;

-- Get tenant branding
SELECT display_name, logo_url, primary_color, secondary_color
FROM tenants 
WHERE id = ?;
```

## Dual-Identity System

The platform separates authentication concerns (`users`) from business identity (`personas`), enabling flexible family representation and improved security.

### users table
Handles authentication integration with AWS Cognito and system access.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    
    -- AWS Cognito integration
    cognito_user_id TEXT UNIQUE NOT NULL,
    cognito_username TEXT UNIQUE,
    
    -- Normalized contact references
    primary_email_id UUID REFERENCES email_address(id),
    primary_phone_id UUID REFERENCES phone_number(id),
    
    -- Profile information
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    display_name TEXT,
    
    -- Status and tracking
    status user_status_enum NOT NULL DEFAULT 'pending_verification',
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- **AWS Cognito Integration**: Authentication handled by Cognito, no passwords stored
- **Normalized Contact Info**: References to email_address and phone_number tables
- **Security Tracking**: Last login monitoring, verification handled by Cognito
- **Tenant Isolation**: All users belong to specific tenant (INTEGER FK)

**Status Flow:**
1. `pending_verification` → User registered but not verified
2. `active` → Both email and phone verified, full access
3. `suspended` → Temporarily disabled by admin
4. `locked` → Locked due to security concerns

### personas table
Represents family members in business contexts, enabling complex family modeling.

```sql
CREATE TABLE personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    user_id UUID REFERENCES users(id),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    middle_name TEXT,
    date_of_birth DATE,
    date_of_death DATE,
    is_living BOOLEAN NOT NULL DEFAULT true,
    gender gender_enum,
    marital_status marital_status_enum,
    profile_picture_id UUID REFERENCES media_storage(id),
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Key Features:**
- **Living and Deceased**: Can represent both living family members (with user_id) and deceased (user_id NULL)
- **Family Member Representation**: One user can manage multiple personas for family members
- **Demographic Information**: Birth/death dates, gender, marital status for legal and inheritance purposes
- **Asset Ownership**: Personas own assets through asset_persona junction table

**Business Rules:**
- Living personas must have a user_id, deceased personas have user_id NULL
- Personas can represent deceased family members for estate management
- Only active personas can be assigned new assets
- Date constraints: date_of_death must be after date_of_birth if both present

**Usage Examples:**
```sql
-- Get all personas managed by a user
SELECT * FROM personas 
WHERE user_id = ? AND status = 'active'
ORDER BY is_living DESC, last_name, first_name;

-- Get deceased family members
SELECT * FROM personas 
WHERE tenant_id = ? AND is_living = false
ORDER BY date_of_death DESC;
```

## Family Organization

### fwd_family_circles table
Forward Family Circles (FFCs) are the organizational units that group family members and define access boundaries.

```sql
CREATE TABLE fwd_family_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL REFERENCES tenants(id),
    owner_user_id UUID NOT NULL REFERENCES users(id),
    name TEXT NOT NULL,
    description TEXT,
    family_picture_id UUID REFERENCES media_storage(id),
    established_date DATE DEFAULT CURRENT_DATE,
    settings JSONB DEFAULT '{}',
    preferences JSONB DEFAULT '{}',
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

**Key Features:**
- **Family Organization**: Groups related family members and their assets
- **Access Boundary**: Defines what users can see and modify
- **Creator Tracking**: Records who established the family circle
- **Flexible Naming**: Descriptive names for different family branches

**Common Use Cases:**
- Nuclear family: "John & Jane Smith Family"
- Extended family: "Smith Family Trust"
- Business interests: "Smith Family Business Holdings"

### ffc_personas table
Manages membership in Forward Family Circles with role-based access control.

```sql
CREATE TABLE ffc_personas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id INTEGER NOT NULL,
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(id),
    persona_id UUID NOT NULL REFERENCES personas(id),
    ffc_role ffc_role_enum NOT NULL DEFAULT 'beneficiary',
    added_by UUID REFERENCES users(id),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    status status_enum NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    UNIQUE(ffc_id, persona_id)
);
```

**Key Features:**
- **Unique Membership**: Each user can have only one role per FFC
- **Role-Based Access**: Links to roles table for permission management
- **Invitation Tracking**: Records who invited each member
- **Membership History**: Tracks join/leave dates for audit purposes

**Membership Lifecycle:**
1. User invited to FFC → `invited_by` recorded
2. User accepts invitation → `joined_at` set, status = 'active'
3. User leaves or is removed → `left_at` set, status = 'inactive'

## Role-Based Access Control

The platform uses a simplified enum-based role system for FFC membership rather than separate tables.

### FFC Role System

Roles are defined using the `ffc_role_enum` type:

```sql
CREATE TYPE ffc_role_enum AS ENUM (
    'owner',
    'beneficiary', 
    'non_beneficiary',
    'advisor'
);
```

**Standard FFC Roles:**
- **owner**: Full control over FFC and all assets
- **beneficiary**: Can view assets they have inheritance rights to
- **non_beneficiary**: Limited view of family financial information  
- **advisor**: Professional advisor with read-only access

**Role Assignment:**
- Roles are assigned directly in the `ffc_personas` table
- Each persona has exactly one role per FFC
- The FFC creator automatically gets the 'owner' role
- Additional owners can be designated as needed

### Permission Model

Permissions are enforced at the application level based on the FFC role:
- **Owners**: Full CRUD on all FFC resources
- **Beneficiaries**: Read access to assets, limited write access
- **Non-Beneficiaries**: Read-only access to general information
- **Advisors**: Read-only access for professional consultation

## Usage Tracking

### usage_tracking table
Monitors system usage for analytics and billing purposes.

```sql
CREATE TABLE usage_tracking (
    usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    action_type VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100),
    resource_id UUID,
    session_id UUID,
    ip_address INET,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}',
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Tracked Actions:**
- Login/logout events
- Asset creation/modification
- Document uploads
- Report generation
- Search queries
- API calls

## Invitation System

### invitation_codes table
Manages reusable invitation codes for family circle access.

```sql
CREATE TABLE invitation_codes (
    code_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(ffc_id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    expires_at TIMESTAMP,
    created_by UUID NOT NULL REFERENCES users(user_id),
    status status_enum DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### invitations table
Tracks individual invitation workflow from creation to acceptance.

```sql
CREATE TABLE invitations (
    invitation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    ffc_id UUID NOT NULL REFERENCES fwd_family_circles(ffc_id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL,
    invited_by UUID NOT NULL REFERENCES users(user_id),
    invitation_code VARCHAR(50),
    message TEXT,
    status invitation_status_enum DEFAULT 'sent',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '7 days'),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Invitation Workflow:**
1. `sent` → Invitation email/SMS sent to recipient
2. `phone_verified` → Recipient verified phone number
3. `accepted` → Recipient accepted invitation
4. `approved` → FFC owner approved the new member
5. `expired` → Invitation expired without acceptance
6. `cancelled` → Invitation cancelled by sender
7. `declined` → Recipient declined invitation

## Table Relationships

### Relationship Hierarchy
```
tenants (root)
├── users (Cognito integrated)
│   ├── personas (1:many)
│   └── primary contacts → email_address, phone_number
├── fwd_family_circles
│   ├── ffc_personas → personas (many:many)
│   └── ffc_invitations
├── personas
│   ├── ffc_personas (membership)
│   └── asset_persona (ownership)
└── normalized contacts
    ├── email_address
    ├── phone_number
    └── address
```

### Key Foreign Key Relationships
- All tables reference `tenants.id` (INTEGER) for multi-tenant isolation
- `personas.user_id` → `users.id` (multiple personas per user)
- `ffc_personas.ffc_id` → `fwd_family_circles.id` (FFC membership)
- `ffc_personas.persona_id` → `personas.id` (persona membership)
- `fwd_family_circles.owner_user_id` → `users.id` (FFC ownership)

### Business Rules Enforced by Schema
1. **Tenant Isolation**: Every entity belongs to exactly one tenant
2. **Primary Persona**: Each user has exactly one primary persona
3. **Unique Membership**: Users can only be members of an FFC once
4. **Role Consistency**: Roles and permissions must belong to the same tenant
5. **Invitation Expiry**: Invitations automatically expire after 7 days

---

*This documentation covers the core infrastructure that enables the Forward Inheritance Platform's multi-tenant, family-oriented architecture. These tables work together to provide secure, scalable family financial management capabilities.*