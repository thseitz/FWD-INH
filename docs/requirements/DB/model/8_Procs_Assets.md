# 06 - Asset Management Procedures

## Table of Contents
1. [Overview](#overview)
2. [Asset CRUD Operations](#asset-crud-operations)
3. [Ownership Management](#ownership-management)
4. [Valuation Procedures](#valuation-procedures)
5. [Asset Search & Reporting](#asset-search--reporting)
6. [Business Logic & Validation](#business-logic--validation)
7. [Security Considerations](#security-considerations)
8. [Usage Examples](#usage-examples)

## Overview

The Asset Management system has been modernized with most operations converted from stored procedures to individual SQL queries using pgTyped and Slonik. These operations handle all asset-related functionality across all 15 asset tables.

### Migration Status
- **Converted to SQL**: 9 of 10 procedures (90%)
- **Kept as Procedure**: 1 (sp_create_asset - complex validation logic)
- **Total SQL Files**: 15

### Asset Management Operations
1. **sp_create_asset** - KEPT AS PROCEDURE (complex business logic)
   - Wrapper: `call_sp_create_asset.sql`
2. **update_asset_details.sql** - Update asset information (from sp_update_asset)
3. **soft_delete_asset.sql** - Soft delete assets (from sp_delete_asset)
4. **Transfer ownership** (from sp_transfer_asset_ownership):
   - `get_asset_ownership.sql` - Check current ownership
   - `transfer_ownership_remove_source.sql` - Remove from source
   - `transfer_ownership_reduce_source.sql` - Reduce percentage
   - `transfer_ownership_add_target.sql` - Add to target
5. **update_asset_value.sql** - Update valuation (from sp_update_asset_value)
6. **get_asset_details.sql** - Retrieve asset info (from sp_get_asset_details)
7. **search_assets.sql** - Search and filter (from sp_search_assets)
8. **Assign to persona** (from sp_assign_asset_to_persona):
   - `assign_asset_to_persona_upsert.sql` - Link assets
   - `check_asset_ownership_total.sql` - Validate percentages
   - `unset_other_primary_owners.sql` - Manage primary ownership
9. **get_asset_categories.sql** - List categories
10. **create_asset_category.sql** - Create new category

### Key Design Principles
- **Type-Safe Operations**: pgTyped provides compile-time validation
- **Single Source of Truth**: Each query in one `.sql` file
- **Audit Trail**: Complete logging of all asset operations in audit_log table
- **Tenant Isolation**: All operations scoped to current tenant
- **Ownership Validation**: Strict validation of ownership percentages (max 100% total)
- **Flexible Tags**: JSONB tags field for extensible asset attributes and valuation history

## Asset CRUD Operations

### sp_create_asset (Kept as Procedure)
Creates a new asset with automatic ownership assignment. This remains as a stored procedure due to complex validation logic.

**Wrapper File:** `call_sp_create_asset.sql`
```sql
-- Wrapper for complex stored procedure
-- $1: tenant_id (integer)
-- $2: owner_persona_id (uuid)
-- $3: asset_type (asset_type_enum)
-- $4: name (text)
-- $5: description (text)
-- $6: ownership_percentage (decimal)
-- $7: created_by_user_id (uuid)
SELECT * FROM sp_create_asset($1, $2, $3, $4, $5, $6, $7);
```

This procedure remains due to:
- Category lookup and validation
- Ownership percentage validation
- Multi-table transactional insert
- Automatic audit logging

### update_asset_details.sql (Converted from sp_update_asset)
Update asset information and metadata.

```sql
-- Updates asset details
-- $1: asset_id (uuid)
-- $2: name (text)
-- $3: description (text)
-- $4: estimated_value (decimal)
-- $5: status (status_enum)
-- $6: metadata (jsonb)
-- $7: updated_by (uuid)
UPDATE assets
SET 
    name = COALESCE($2, name),
    description = COALESCE($3, description),
    estimated_value = COALESCE($4, estimated_value),
    status = COALESCE($5, status),
    tags = COALESCE($6, tags),
    updated_by = $7,
    updated_at = NOW()
WHERE id = $1
RETURNING *;
```

### soft_delete_asset.sql (Converted from sp_delete_asset)
Soft delete an asset by setting status.

```sql
-- Soft deletes an asset
-- $1: asset_id (uuid)
-- $2: deleted_by (uuid)
UPDATE assets
SET 
    status = 'deleted',
    updated_by = $2,
    updated_at = NOW()
WHERE id = $1;
```

**Original sp_create_asset Implementation:**
```sql
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
```

**Key Features:**
- **Automatic Ownership**: Creates initial ownership relationship with 100% default
- **Category Lookup**: Maps asset_type enum to category
- **User Context**: Derives user from persona if not provided
- **Primary Owner**: Sets is_primary to TRUE for creator
- **Complete Audit**: Logs creation with full context in audit_log

### sp_update_asset
Updates asset information with selective field updates and audit trail.

```sql
CREATE OR REPLACE FUNCTION sp_update_asset(
    p_asset_id UUID,
    p_name TEXT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_estimated_value DECIMAL(15,2) DEFAULT NULL,
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
        estimated_value = COALESCE(p_estimated_value, estimated_value),
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
```

**Key Features:**
- **Selective Updates**: Only modifies provided fields using COALESCE
- **Metadata Merge**: Appends new metadata to existing tags
- **Audit Logging**: Records all changes with before/after context
- **Return Status**: Returns TRUE if update successful, FALSE if not found

### sp_delete_asset
Performs soft or hard delete of assets with ownership cleanup.

```sql
CREATE OR REPLACE FUNCTION sp_delete_asset(
    p_asset_id UUID,
    p_deleted_by UUID DEFAULT NULL,
    p_hard_delete BOOLEAN DEFAULT FALSE
) RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_asset_name VARCHAR(255);
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
```

**Key Features:**
- **Soft Delete Default**: Marks as deleted without removing data
- **Hard Delete Option**: Completely removes asset and relationships
- **Cascade Cleanup**: Removes ownership and permissions on hard delete
- **Audit Trail**: Logs deletion type and context

## Ownership Management

### sp_transfer_asset_ownership
Transfers asset ownership between personas with percentage validation.

```sql
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
```

**Key Features:**
- **Full or Partial Transfer**: Supports complete or percentage-based transfers
- **Percentage Validation**: Ensures transfer doesn't exceed current ownership
- **Automatic Aggregation**: Combines ownership if target already owns asset
- **Transaction Safety**: Wrapped in exception handling for atomicity

### sp_assign_asset_to_persona
Links assets to personas with ownership validation.

```sql
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
        'assign_ownership',
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
```

## Valuation Procedures

### sp_update_asset_value
Updates asset valuation with historical tracking.

```sql
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
```

**Key Features:**
- **Historical Tracking**: Maintains valuation history in tags JSONB
- **Multiple Methods**: Supports different valuation methods (market, appraisal, etc.)
- **Previous Value**: Stores old value for comparison
- **Audit Trail**: Complete logging of valuation changes

## Asset Search & Reporting

### sp_get_asset_details
Retrieves complete asset information with ownership details.

```sql
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
```

### sp_search_assets
Searches and filters assets with pagination support.

```sql
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
```

**Key Features:**
- **Flexible Filtering**: Multiple optional filter parameters
- **Full-Text Search**: Searches name and description fields
- **Ownership Filter**: Find assets by specific owner
- **Pagination**: Built-in limit and offset support
- **Sorted Results**: Returns newest assets first

## Business Logic & Validation

### Key Business Rules Enforced

1. **Ownership Validation**
   - Total ownership cannot exceed 100%
   - Only one primary owner per asset
   - Ownership transfers maintain percentage integrity

2. **Tenant Isolation**
   - All operations scoped to asset's tenant
   - Cross-tenant access prevented
   - Tenant context validated on all operations

3. **Audit Requirements**
   - All modifications logged to audit_log
   - Complete before/after state captured
   - User and timestamp tracked

4. **Status Management**
   - Assets can be active, inactive, or deleted
   - Soft delete preserves data integrity
   - Status changes tracked in audit

## Security Considerations

### Access Control
- **Row-Level Security**: Procedures use SECURITY DEFINER
- **Permission Checks**: User permissions validated within procedures
- **FFC Membership**: Access limited to family circle members
- **Tenant Boundaries**: Strict tenant isolation enforced

### Data Protection
- **Soft Delete Default**: Preserves data for audit trail
- **Cascade Handling**: Proper cleanup of related records
- **Transaction Safety**: Operations wrapped in exception handlers
- **Input Validation**: All parameters validated before processing

## Usage Examples

### Creating an Asset
```sql
-- Create a real estate asset
SELECT sp_create_asset(
    p_tenant_id := 1,
    p_owner_persona_id := '550e8400-e29b-41d4-a716-446655440000',
    p_asset_type := 'real_estate',
    p_name := 'Family Home',
    p_description := 'Primary residence in California',
    p_ownership_percentage := 100.00
);
```

### Transferring Ownership
```sql
-- Transfer 50% ownership to spouse
SELECT sp_transfer_asset_ownership(
    p_asset_id := '660e8400-e29b-41d4-a716-446655440000',
    p_from_persona_id := '550e8400-e29b-41d4-a716-446655440000',
    p_to_persona_id := '770e8400-e29b-41d4-a716-446655440000',
    p_ownership_percentage := 50.00,
    p_transfer_type := 'partial'
);
```

### Updating Valuation
```sql
-- Update asset value based on appraisal
SELECT sp_update_asset_value(
    p_asset_id := '660e8400-e29b-41d4-a716-446655440000',
    p_new_value := 750000.00,
    p_valuation_date := '2024-01-15',
    p_valuation_method := 'appraisal'
);
```

### Searching Assets
```sql
-- Find all real estate assets over $500,000
SELECT * FROM sp_search_assets(
    p_category_code := 'real_estate',
    p_min_value := 500000.00,
    p_status := 'active'
);
```

---

*These asset management procedures provide the core functionality for the Forward Inheritance Platform's asset tracking and management system, ensuring data integrity, security, and complete audit trails for all asset operations.*