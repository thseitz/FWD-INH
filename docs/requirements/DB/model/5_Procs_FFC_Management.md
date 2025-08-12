# 04 - FFC (Forward Family Circle) Management Procedures

## Table of Contents
1. [Overview](#overview)
2. [FFC Creation and Management](#ffc-creation-and-management)
3. [Member Management](#member-management)
4. [FFC Information and Reporting](#ffc-information-and-reporting)
5. [Helper Functions](#helper-functions)
6. [Usage Examples](#usage-examples)
7. [Security Considerations](#security-considerations)

## Overview

The FFC (Forward Family Circle) management procedures handle the creation, modification, and management of family circles within the Forward Inheritance Platform. These procedures work with the multi-tenant architecture to ensure proper data isolation while enabling family collaboration.

### Core Components
- **FFC Creation**: `sp_create_ffc` - Creates new family circles
- **Member Management**: `sp_add_persona_to_ffc`, `sp_update_ffc_member_role`, `sp_remove_ffc_member`
- **Reporting**: `sp_get_ffc_summary` - Provides comprehensive FFC statistics
- **Access Control**: `is_ffc_member` - Validates membership for security

## FFC Creation and Management

### sp_create_ffc
Creates a new Forward Family Circle with an owner.

```sql
CREATE OR REPLACE PROCEDURE sp_create_ffc(
    p_tenant_id INTEGER,
    p_owner_user_id UUID,
    p_name TEXT,
    p_description TEXT,
    OUT p_ffc_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO fwd_family_circles (
        tenant_id,
        owner_user_id,
        name,
        description
    ) VALUES (
        p_tenant_id,
        p_owner_user_id,
        p_name,
        p_description
    ) RETURNING id INTO p_ffc_id;
END;
$$;
```

**Parameters:**
- `p_tenant_id`: Tenant identifier for multi-tenant isolation
- `p_owner_user_id`: UUID of the user who will own the FFC
- `p_name`: Name of the family circle
- `p_description`: Description of the family circle
- `p_ffc_id`: (OUT) Generated UUID for the new FFC

**Usage Example:**
```sql
CALL sp_create_ffc(
    1,                                          -- Tenant ID
    '123e4567-e89b-12d3-a456-426614174000',   -- Owner User ID
    'Smith Family Circle',                     -- Name
    'Extended Smith family financial planning', -- Description
    NULL                                        -- OUT parameter
);
```

## Member Management

### sp_add_persona_to_ffc
Adds a persona to an FFC with a specified role.

```sql
CREATE OR REPLACE PROCEDURE sp_add_persona_to_ffc(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_role ffc_role_enum
)
LANGUAGE plpgsql AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    SELECT tenant_id INTO v_tenant_id
    FROM fwd_family_circles WHERE id = p_ffc_id;
    
    INSERT INTO ffc_personas (
        tenant_id,
        ffc_id,
        persona_id,
        ffc_role
    ) VALUES (
        v_tenant_id,
        p_ffc_id,
        p_persona_id,
        p_role
    )
    ON CONFLICT (ffc_id, persona_id) 
    DO UPDATE SET 
        ffc_role = EXCLUDED.ffc_role,
        updated_at = NOW();
END;
$$;
```

**Parameters:**
- `p_ffc_id`: UUID of the FFC
- `p_persona_id`: UUID of the persona to add
- `p_role`: Role within the FFC (owner, admin, member, viewer)

**Features:**
- Handles conflicts gracefully with UPSERT logic
- Automatically maintains tenant isolation
- Updates timestamp on role changes

### sp_update_ffc_member_role
Updates the role of an existing FFC member.

```sql
CREATE OR REPLACE PROCEDURE sp_update_ffc_member_role(
    p_ffc_id UUID,
    p_persona_id UUID,
    p_new_role ffc_role_enum
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE ffc_personas
    SET ffc_role = p_new_role,
        updated_at = NOW()
    WHERE ffc_id = p_ffc_id
    AND persona_id = p_persona_id;
END;
$$;
```

**Parameters:**
- `p_ffc_id`: UUID of the FFC
- `p_persona_id`: UUID of the persona whose role to update
- `p_new_role`: New role to assign (owner, admin, member, viewer)

### sp_remove_ffc_member
Removes a member from an FFC.

```sql
CREATE OR REPLACE PROCEDURE sp_remove_ffc_member(
    p_ffc_id UUID,
    p_persona_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM ffc_personas
    WHERE ffc_id = p_ffc_id
    AND persona_id = p_persona_id;
END;
$$;
```

**Parameters:**
- `p_ffc_id`: UUID of the FFC
- `p_persona_id`: UUID of the persona to remove

**Note:** The owner cannot be removed without transferring ownership first.

## FFC Information and Reporting

### sp_get_ffc_summary
Retrieves comprehensive summary statistics for an FFC.

```sql
CREATE OR REPLACE FUNCTION sp_get_ffc_summary(p_ffc_id UUID)
RETURNS TABLE(
    ffc_id UUID,
    name TEXT,
    member_count BIGINT,
    asset_count BIGINT,
    total_value DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.name,
        COUNT(DISTINCT fp.persona_id)::BIGINT,
        COUNT(DISTINCT ap.asset_id)::BIGINT,
        COALESCE(SUM(a.estimated_value), 0)
    FROM fwd_family_circles f
    LEFT JOIN ffc_personas fp ON f.id = fp.ffc_id
    LEFT JOIN asset_persona ap ON fp.persona_id = ap.persona_id
    LEFT JOIN assets a ON ap.asset_id = a.id
    WHERE f.id = p_ffc_id
    GROUP BY f.id, f.name;
END;
$$ LANGUAGE plpgsql;
```

**Returns:**
- `ffc_id`: UUID of the FFC
- `name`: Name of the FFC
- `member_count`: Total number of members
- `asset_count`: Total number of assets owned by members
- `total_value`: Combined value of all assets

**Usage Example:**
```sql
SELECT * FROM sp_get_ffc_summary('123e4567-e89b-12d3-a456-426614174000');
```

## Helper Functions

### is_ffc_member
Checks if a user is a member of an FFC through any of their personas.

```sql
CREATE OR REPLACE FUNCTION is_ffc_member(
    p_ffc_id UUID, 
    p_user_id UUID DEFAULT current_user_id()
)
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
```

**Parameters:**
- `p_ffc_id`: UUID of the FFC to check
- `p_user_id`: UUID of the user (defaults to current user)

**Returns:** 
- `TRUE` if the user is a member
- `FALSE` if the user is not a member

**Usage:**
- Used in Row-Level Security policies
- Access control for FFC-specific operations
- Validation in other procedures

## Usage Examples

### Complete FFC Setup Workflow
```sql
-- 1. Create a new FFC
CALL sp_create_ffc(
    1,
    '123e4567-e89b-12d3-a456-426614174000',
    'Johnson Family Trust',
    'Multi-generational wealth planning',
    @ffc_id
);

-- 2. Add family members with different roles
CALL sp_add_persona_to_ffc(
    @ffc_id,
    'persona-uuid-spouse',
    'admin'
);

CALL sp_add_persona_to_ffc(
    @ffc_id,
    'persona-uuid-child1',
    'member'
);

CALL sp_add_persona_to_ffc(
    @ffc_id,
    'persona-uuid-advisor',
    'viewer'
);

-- 3. Update a member's role
CALL sp_update_ffc_member_role(
    @ffc_id,
    'persona-uuid-child1',
    'admin'
);

-- 4. Get summary statistics
SELECT * FROM sp_get_ffc_summary(@ffc_id);

-- 5. Check membership
SELECT is_ffc_member(@ffc_id, 'user-uuid');
```

## Security Considerations

### Multi-Tenant Isolation
- All procedures enforce tenant isolation
- Tenant ID is automatically propagated to junction tables
- Cross-tenant access is prevented at the database level

### Role-Based Access Control
**FFC Roles:**
- **owner**: Full control, cannot be removed
- **admin**: Can manage members and assets
- **member**: Can view and contribute
- **viewer**: Read-only access

### Row-Level Security Integration
The `is_ffc_member` function integrates with RLS policies:
```sql
-- Example RLS policy using the helper function
CREATE POLICY ffc_member_access ON assets
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM asset_persona ap
            JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
            WHERE ap.asset_id = assets.id
            AND is_ffc_member(fp.ffc_id)
        )
    );
```

### Audit Trail
All FFC operations should be logged using the audit procedures:
```sql
-- Log FFC creation
CALL sp_log_audit_event(
    p_tenant_id,
    p_user_id,
    'create',
    'ffc',
    p_ffc_id,
    jsonb_build_object('name', p_name),
    p_ip_address
);
```

### Best Practices
1. **Ownership Transfer**: Implement separate procedure for ownership transfer with validation
2. **Cascade Deletes**: Configure appropriate cascade rules for FFC deletion
3. **Member Limits**: Consider implementing member count limits per FFC
4. **Invitation System**: Use `sp_create_invitation` for adding new members
5. **Permission Checks**: Always validate user permissions before FFC operations

## Error Handling

Common error scenarios and handling:

1. **Duplicate Member**: Handled with ON CONFLICT clause
2. **Invalid FFC ID**: Returns empty result or no rows affected
3. **Invalid Role**: Constraint violation on ffc_role_enum
4. **Orphaned Records**: Prevented by foreign key constraints
5. **Concurrent Updates**: Handled by transaction isolation

## Performance Optimization

### Indexes
Ensure these indexes exist for optimal performance:
```sql
-- FFC lookup
CREATE INDEX idx_ffc_tenant_owner ON fwd_family_circles(tenant_id, owner_user_id);

-- Member queries
CREATE INDEX idx_ffc_personas_ffc ON ffc_personas(ffc_id);
CREATE INDEX idx_ffc_personas_persona ON ffc_personas(persona_id);

-- Summary calculations
CREATE INDEX idx_asset_persona_persona ON asset_persona(persona_id);
```

### Query Optimization
- Use `EXISTS` instead of `COUNT` for membership checks
- Leverage prepared statements for repeated operations
- Consider materialized views for complex summaries

## Migration and Upgrade Considerations

When upgrading FFC procedures:
1. Maintain backward compatibility
2. Version procedure names if breaking changes needed
3. Migrate data in transactions
4. Update RLS policies if security model changes
5. Test with production-like data volumes

---

*This documentation covers the complete FFC management system within the Forward Inheritance Platform, providing secure, scalable family circle management with comprehensive member and role management capabilities.*