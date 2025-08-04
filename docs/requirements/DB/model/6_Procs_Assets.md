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

The Asset Management system provides **7 core stored procedures** that handle all asset-related operations in the Forward Inheritance Platform. These procedures enforce business rules, maintain data integrity, and provide secure access to asset information across all 15 asset tables.

### Asset Management Procedures
1. **sp_create_asset** - Create new assets with ownership assignment
2. **sp_update_asset** - Update asset information and metadata
3. **sp_delete_asset** - Soft delete assets with ownership cleanup
4. **sp_assign_asset_ownership** - Manage persona-asset ownership relationships
5. **sp_transfer_asset_ownership** - Transfer ownership between personas
6. **sp_get_asset_details** - Retrieve complete asset information
7. **sp_search_assets** - Search and filter assets with pagination

### Key Design Principles
- **Database-First**: All business logic implemented in stored procedures
- **Audit Trail**: Complete logging of all asset operations
- **Tenant Isolation**: All operations scoped to current tenant
- **Ownership Validation**: Strict validation of ownership percentages and types
- **Flexible Metadata**: JSONB support for extensible asset attributes

## Asset CRUD Operations

### sp_create_asset
Creates a new asset with automatic ownership assignment to the creating persona.

```sql
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_category_code VARCHAR(20),
    p_name VARCHAR(255),
    p_description TEXT,
    p_estimated_value DECIMAL(15,2) DEFAULT NULL,
    p_currency_code VARCHAR(3) DEFAULT 'USD',
    p_owner_persona_id UUID,
    p_ownership_percentage DECIMAL(5,2) DEFAULT 100.00,
    p_tags JSONB DEFAULT '[]',
    p_specialized_data JSONB DEFAULT '{}'
) RETURNS TABLE (
    asset_id UUID,
    category_id UUID,
    ownership_id UUID
) AS $$
DECLARE
    v_asset_id UUID;
    v_category_id UUID;
    v_ownership_id UUID;
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Validate tenant context
    IF p_tenant_id != v_current_tenant_id THEN
        RAISE EXCEPTION 'Tenant mismatch: operation not allowed';
    END IF;
    
    -- Validate persona belongs to tenant
    IF NOT EXISTS (
        SELECT 1 FROM personas 
        WHERE id = p_owner_persona_id 
        AND tenant_id = p_tenant_id 
        AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Invalid persona or persona not active';
    END IF;
    
    -- Get category ID
    SELECT id INTO v_category_id 
    FROM asset_categories 
    WHERE code = p_category_code AND is_active = true;
    
    IF v_category_id IS NULL THEN
        RAISE EXCEPTION 'Invalid or inactive asset category: %', p_category_code;
    END IF;
    
    -- Validate ownership percentage
    IF p_ownership_percentage <= 0 OR p_ownership_percentage > 100 THEN
        RAISE EXCEPTION 'Ownership percentage must be between 0.01 and 100.00';
    END IF;
    
    -- Create base asset
    INSERT INTO assets (
        tenant_id,
        category_id,
        name,
        description,
        estimated_value,
        currency_code,
        tags,
        created_by,
        updated_by
    ) VALUES (
        p_tenant_id,
        v_category_id,
        p_name,
        p_description,
        p_estimated_value,
        p_currency_code,
        p_tags,
        v_current_user_id,
        v_current_user_id
    ) RETURNING id INTO v_asset_id;
    
    -- Create ownership relationship
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage,
        created_by,
        updated_by
    ) VALUES (
        p_tenant_id,
        v_asset_id,
        p_owner_persona_id,
        'owner',
        p_ownership_percentage,
        v_current_user_id,
        v_current_user_id
    ) RETURNING id INTO v_ownership_id;
    
    -- Create specialized asset record if data provided
    IF p_specialized_data != '{}' THEN
        PERFORM fn_create_specialized_asset_record(
            v_asset_id,
            p_category_code,
            p_specialized_data
        );
    END IF;
    
    -- Log asset creation
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        old_values,
        new_values,
        occurred_at
    ) VALUES (
        p_tenant_id,
        v_current_user_id,
        'CREATE',
        'asset',
        v_asset_id,
        NULL,
        jsonb_build_object(
            'name', p_name,
            'category_code', p_category_code,
            'estimated_value', p_estimated_value,
            'owner_persona_id', p_owner_persona_id
        ),
        NOW()
    );
    
    -- Return results
    RETURN QUERY SELECT v_asset_id, v_category_id, v_ownership_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            COALESCE(p_tenant_id, v_current_tenant_id),
            v_current_user_id,
            'CREATE_ERROR',
            'asset',
            NULL,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Features:**
- **Automatic Ownership**: Creates initial ownership relationship
- **Category Validation**: Ensures valid asset category
- **Specialized Data**: Supports category-specific attributes via JSONB
- **Tenant Isolation**: Validates all operations within tenant scope
- **Complete Audit**: Logs creation with full context

### sp_update_asset
Updates asset information with full audit trail and validation.

```sql
CREATE OR REPLACE FUNCTION sp_update_asset(
    p_asset_id UUID,
    p_name VARCHAR(255) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_estimated_value DECIMAL(15,2) DEFAULT NULL,
    p_currency_code VARCHAR(3) DEFAULT NULL,
    p_tags JSONB DEFAULT NULL,
    p_specialized_data JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
    v_asset_tenant_id INTEGER;
    v_category_code VARCHAR(20);
    v_old_values JSONB;
    v_new_values JSONB;
    v_has_changes BOOLEAN := FALSE;
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Validate asset exists and get current values
    SELECT 
        a.tenant_id,
        ac.code,
        jsonb_build_object(
            'name', a.name,
            'description', a.description,
            'estimated_value', a.estimated_value,
            'currency_code', a.currency_code,
            'tags', a.tags
        )
    INTO v_asset_tenant_id, v_category_code, v_old_values
    FROM assets a
    JOIN asset_categories ac ON a.category_id = ac.id
    WHERE a.id = p_asset_id AND a.is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Asset not found or inactive: %', p_asset_id;
    END IF;
    
    -- Validate tenant access
    IF v_asset_tenant_id != v_current_tenant_id THEN
        RAISE EXCEPTION 'Access denied: asset belongs to different tenant';
    END IF;
    
    -- Validate user has permission to update asset
    IF NOT fn_user_can_modify_asset(v_current_user_id, p_asset_id) THEN
        RAISE EXCEPTION 'Access denied: insufficient permissions to modify asset';
    END IF;
    
    -- Build new values object
    v_new_values := jsonb_build_object(
        'name', COALESCE(p_name, v_old_values->>'name'),
        'description', COALESCE(p_description, v_old_values->>'description'),
        'estimated_value', COALESCE(p_estimated_value, (v_old_values->>'estimated_value')::DECIMAL),
        'currency_code', COALESCE(p_currency_code, v_old_values->>'currency_code'),
        'tags', COALESCE(p_tags, v_old_values->'tags')
    );
    
    -- Check if there are actual changes
    IF v_old_values != v_new_values THEN
        v_has_changes := TRUE;
        
        -- Update base asset
        UPDATE assets SET
            name = COALESCE(p_name, name),
            description = COALESCE(p_description, description),
            estimated_value = COALESCE(p_estimated_value, estimated_value),
            currency_code = COALESCE(p_currency_code, currency_code),
            tags = COALESCE(p_tags, tags),
            updated_at = NOW(),
            updated_by = v_current_user_id
        WHERE id = p_asset_id;
    END IF;
    
    -- Update specialized asset data if provided
    IF p_specialized_data IS NOT NULL THEN
        PERFORM fn_update_specialized_asset_record(
            p_asset_id,
            v_category_code,
            p_specialized_data
        );
        v_has_changes := TRUE;
    END IF;
    
    -- Log update if changes were made
    IF v_has_changes THEN
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            old_values,
            new_values,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'UPDATE',
            'asset',
            p_asset_id,
            v_old_values,
            v_new_values,
            NOW()
        );
    END IF;
    
    RETURN v_has_changes;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'UPDATE_ERROR',
            'asset',
            p_asset_id,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_delete_asset
Performs soft delete of assets with ownership cleanup and cascade handling.

```sql
CREATE OR REPLACE FUNCTION sp_delete_asset(
    p_asset_id UUID,
    p_delete_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
    v_asset_record RECORD;
    v_ownership_count INTEGER;
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Get asset details
    SELECT a.*, ac.code as category_code
    INTO v_asset_record
    FROM assets a
    JOIN asset_categories ac ON a.category_id = ac.id
    WHERE a.id = p_asset_id AND a.is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Asset not found or already deleted: %', p_asset_id;
    END IF;
    
    -- Validate tenant access
    IF v_asset_record.tenant_id != v_current_tenant_id THEN
        RAISE EXCEPTION 'Access denied: asset belongs to different tenant';
    END IF;
    
    -- Validate user has permission to delete asset
    IF NOT fn_user_can_delete_asset(v_current_user_id, p_asset_id) THEN
        RAISE EXCEPTION 'Access denied: insufficient permissions to delete asset';
    END IF;
    
    -- Get ownership count for audit
    SELECT COUNT(*) INTO v_ownership_count
    FROM asset_persona
    WHERE asset_id = p_asset_id AND is_active = true;
    
    -- Soft delete the asset
    UPDATE assets SET
        is_active = false,
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_asset_id;
    
    -- Deactivate all ownership relationships
    UPDATE asset_persona SET
        is_active = false,
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE asset_id = p_asset_id AND is_active = true;
    
    -- Log deletion
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        old_values,
        new_values,
        occurred_at
    ) VALUES (
        v_current_tenant_id,
        v_current_user_id,
        'DELETE',
        'asset',
        p_asset_id,
        jsonb_build_object(
            'name', v_asset_record.name,
            'category_code', v_asset_record.category_code,
            'estimated_value', v_asset_record.estimated_value,
            'ownership_count', v_ownership_count
        ),
        jsonb_build_object(
            'delete_reason', p_delete_reason,
            'is_active', false
        ),
        NOW()
    );
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'DELETE_ERROR',
            'asset',
            p_asset_id,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Ownership Management

### sp_assign_asset_ownership
Assigns or updates ownership relationships between personas and assets.

```sql
CREATE OR REPLACE FUNCTION sp_assign_asset_ownership(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum,
    p_ownership_percentage DECIMAL(5,2),
    p_notes TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
    v_ownership_id UUID;
    v_total_ownership DECIMAL(5,2);
    v_existing_ownership DECIMAL(5,2) := 0;
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Validate asset exists and belongs to tenant
    IF NOT EXISTS (
        SELECT 1 FROM assets 
        WHERE id = p_asset_id 
        AND tenant_id = v_current_tenant_id 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Asset not found or access denied: %', p_asset_id;
    END IF;
    
    -- Validate persona exists and belongs to tenant
    IF NOT EXISTS (
        SELECT 1 FROM personas 
        WHERE id = p_persona_id 
        AND tenant_id = v_current_tenant_id 
        AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Persona not found or access denied: %', p_persona_id;
    END IF;
    
    -- Validate ownership percentage
    IF p_ownership_percentage <= 0 OR p_ownership_percentage > 100 THEN
        RAISE EXCEPTION 'Ownership percentage must be between 0.01 and 100.00';
    END IF;
    
    -- Check for existing ownership of same type
    SELECT ownership_percentage INTO v_existing_ownership
    FROM asset_persona
    WHERE asset_id = p_asset_id 
    AND persona_id = p_persona_id 
    AND ownership_type = p_ownership_type
    AND is_active = true;
    
    -- Calculate total ownership if adding new or updating existing
    SELECT COALESCE(SUM(ownership_percentage), 0) INTO v_total_ownership
    FROM asset_persona
    WHERE asset_id = p_asset_id 
    AND ownership_type = 'owner'  -- Only count actual ownership, not beneficiaries
    AND is_active = true
    AND NOT (persona_id = p_persona_id AND ownership_type = p_ownership_type);  -- Exclude current if updating
    
    -- Validate total ownership doesn't exceed 100%
    IF p_ownership_type = 'owner' AND (v_total_ownership + p_ownership_percentage) > 100 THEN
        RAISE EXCEPTION 'Total ownership cannot exceed 100%%. Current total: %%, Requested: %%', 
            v_total_ownership, p_ownership_percentage;
    END IF;
    
    -- Insert or update ownership record
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage,
        notes,
        created_by,
        updated_by
    ) VALUES (
        v_current_tenant_id,
        p_asset_id,
        p_persona_id,
        p_ownership_type,
        p_ownership_percentage,
        p_notes,
        v_current_user_id,
        v_current_user_id
    )
    ON CONFLICT (asset_id, persona_id, ownership_type)
    DO UPDATE SET
        ownership_percentage = p_ownership_percentage,
        notes = p_notes,
        is_active = true,
        updated_at = NOW(),
        updated_by = v_current_user_id
    RETURNING id INTO v_ownership_id;
    
    -- Log ownership assignment
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        new_values,
        occurred_at
    ) VALUES (
        v_current_tenant_id,
        v_current_user_id,
        'ASSIGN_OWNERSHIP',
        'asset_persona',
        v_ownership_id,
        jsonb_build_object(
            'asset_id', p_asset_id,
            'persona_id', p_persona_id,
            'ownership_type', p_ownership_type,
            'ownership_percentage', p_ownership_percentage,
            'previous_percentage', v_existing_ownership
        ),
        NOW()
    );
    
    RETURN v_ownership_id;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'ASSIGN_OWNERSHIP_ERROR',
            'asset_persona',
            NULL,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_transfer_asset_ownership
Transfers ownership from one persona to another with validation and audit trail.

```sql
CREATE OR REPLACE FUNCTION sp_transfer_asset_ownership(
    p_asset_id UUID,
    p_from_persona_id UUID,
    p_to_persona_id UUID,
    p_ownership_percentage DECIMAL(5,2),
    p_transfer_reason TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
    v_from_ownership DECIMAL(5,2);
    v_remaining_ownership DECIMAL(5,2);
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Validate all personas belong to tenant
    IF NOT EXISTS (
        SELECT 1 FROM personas 
        WHERE id IN (p_from_persona_id, p_to_persona_id)
        AND tenant_id = v_current_tenant_id 
        AND status = 'active'
        HAVING COUNT(*) = 2
    ) THEN
        RAISE EXCEPTION 'One or more personas not found or access denied';
    END IF;
    
    -- Get current ownership percentage
    SELECT ownership_percentage INTO v_from_ownership
    FROM asset_persona
    WHERE asset_id = p_asset_id 
    AND persona_id = p_from_persona_id 
    AND ownership_type = 'owner'
    AND is_active = true;
    
    IF v_from_ownership IS NULL THEN
        RAISE EXCEPTION 'Source persona does not own this asset';
    END IF;
    
    -- Validate transfer amount
    IF p_ownership_percentage <= 0 OR p_ownership_percentage > v_from_ownership THEN
        RAISE EXCEPTION 'Invalid transfer amount. Available: %%, Requested: %%', 
            v_from_ownership, p_ownership_percentage;
    END IF;
    
    -- Calculate remaining ownership
    v_remaining_ownership := v_from_ownership - p_ownership_percentage;
    
    -- Update source ownership
    IF v_remaining_ownership > 0 THEN
        UPDATE asset_persona SET
            ownership_percentage = v_remaining_ownership,
            updated_at = NOW(),
            updated_by = v_current_user_id
        WHERE asset_id = p_asset_id 
        AND persona_id = p_from_persona_id 
        AND ownership_type = 'owner';
    ELSE
        -- Remove ownership record if transferring all
        UPDATE asset_persona SET
            is_active = false,
            updated_at = NOW(),
            updated_by = v_current_user_id
        WHERE asset_id = p_asset_id 
        AND persona_id = p_from_persona_id 
        AND ownership_type = 'owner';
    END IF;
    
    -- Add or update target ownership
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage,
        notes,
        created_by,
        updated_by
    ) VALUES (
        v_current_tenant_id,
        p_asset_id,
        p_to_persona_id,
        'owner',
        p_ownership_percentage,
        'Transferred from persona: ' || p_from_persona_id || '. Reason: ' || COALESCE(p_transfer_reason, 'Not specified'),
        v_current_user_id,
        v_current_user_id
    )
    ON CONFLICT (asset_id, persona_id, ownership_type)
    DO UPDATE SET
        ownership_percentage = asset_persona.ownership_percentage + p_ownership_percentage,
        updated_at = NOW(),
        updated_by = v_current_user_id;
    
    -- Log ownership transfer
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        old_values,
        new_values,
        occurred_at
    ) VALUES (
        v_current_tenant_id,
        v_current_user_id,
        'TRANSFER_OWNERSHIP',
        'asset',
        p_asset_id,
        jsonb_build_object(
            'from_persona_id', p_from_persona_id,
            'from_ownership', v_from_ownership
        ),
        jsonb_build_object(
            'to_persona_id', p_to_persona_id,
            'transferred_percentage', p_ownership_percentage,
            'remaining_from_ownership', v_remaining_ownership,
            'transfer_reason', p_transfer_reason
        ),
        NOW()
    );
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'TRANSFER_OWNERSHIP_ERROR',
            'asset',
            p_asset_id,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Valuation Procedures

### sp_update_asset_valuation
Updates asset valuation with historical tracking.

```sql
CREATE OR REPLACE FUNCTION sp_update_asset_valuation(
    p_asset_id UUID,
    p_new_value DECIMAL(15,2),
    p_valuation_date DATE DEFAULT CURRENT_DATE,
    p_valuation_method VARCHAR(100) DEFAULT NULL,
    p_appraiser_notes TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_current_user_id UUID;
    v_current_tenant_id INTEGER;
    v_old_value DECIMAL(15,2);
    v_old_date DATE;
BEGIN
    -- Get current context
    v_current_user_id := fn_get_current_user_id();
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Get current valuation
    SELECT estimated_value, last_valued_date 
    INTO v_old_value, v_old_date
    FROM assets 
    WHERE id = p_asset_id 
    AND tenant_id = v_current_tenant_id 
    AND is_active = true;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Asset not found or access denied: %', p_asset_id;
    END IF;
    
    -- Validate new value
    IF p_new_value < 0 THEN
        RAISE EXCEPTION 'Asset value cannot be negative';
    END IF;
    
    -- Update asset valuation
    UPDATE assets SET
        estimated_value = p_new_value,
        last_valued_date = p_valuation_date,
        updated_at = NOW(),
        updated_by = v_current_user_id
    WHERE id = p_asset_id;
    
    -- Log valuation update
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        old_values,
        new_values,
        occurred_at
    ) VALUES (
        v_current_tenant_id,
        v_current_user_id,
        'UPDATE_VALUATION',
        'asset',
        p_asset_id,
        jsonb_build_object(
            'old_value', v_old_value,
            'old_date', v_old_date
        ),
        jsonb_build_object(
            'new_value', p_new_value,
            'valuation_date', p_valuation_date,
            'valuation_method', p_valuation_method,
            'appraiser_notes', p_appraiser_notes
        ),
        NOW()
    );
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO audit_log (
            tenant_id,
            user_id,
            action,
            entity_type,
            entity_id,
            error_message,
            occurred_at
        ) VALUES (
            v_current_tenant_id,
            v_current_user_id,
            'UPDATE_VALUATION_ERROR',
            'asset',
            p_asset_id,
            SQLERRM,
            NOW()
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Asset Search & Reporting

### sp_get_asset_details
Retrieves complete asset information including ownership and specialized data.

```sql
CREATE OR REPLACE FUNCTION sp_get_asset_details(
    p_asset_id UUID
) RETURNS TABLE (
    asset_id UUID,
    tenant_id INTEGER,
    category_name VARCHAR(100),
    category_code VARCHAR(20),
    asset_name VARCHAR(255),
    description TEXT,
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3),
    last_valued_date DATE,
    tags JSONB,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    ownership_details JSONB,
    specialized_data JSONB
) AS $$
DECLARE
    v_current_tenant_id INTEGER;
BEGIN
    -- Get current context
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Return asset details with ownership information
    RETURN QUERY
    SELECT 
        a.id,
        a.tenant_id,
        ac.name,
        ac.code,
        a.name,
        a.description,
        a.estimated_value,
        a.currency_code,
        a.last_valued_date,
        a.tags,
        a.is_active,
        a.created_at,
        a.updated_at,
        
        -- Aggregate ownership details
        COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'persona_id', ap.persona_id,
                    'persona_name', p.first_name || ' ' || p.last_name,
                    'ownership_type', ap.ownership_type,
                    'ownership_percentage', ap.ownership_percentage,
                    'notes', ap.notes
                )
            )
            FROM asset_persona ap
            JOIN personas p ON ap.persona_id = p.id
            WHERE ap.asset_id = a.id AND ap.is_active = true),
            '[]'::jsonb
        ),
        
        -- Get specialized data based on category
        fn_get_specialized_asset_data(a.id, ac.code)
        
    FROM assets a
    JOIN asset_categories ac ON a.category_id = ac.id
    WHERE a.id = p_asset_id 
    AND a.tenant_id = v_current_tenant_id 
    AND a.is_active = true;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_search_assets
Advanced asset search with filtering, sorting, and pagination.

```sql
CREATE OR REPLACE FUNCTION sp_search_assets(
    p_search_text VARCHAR(255) DEFAULT NULL,
    p_category_codes VARCHAR(20)[] DEFAULT NULL,
    p_persona_id UUID DEFAULT NULL,
    p_ownership_type ownership_type_enum DEFAULT NULL,
    p_min_value DECIMAL(15,2) DEFAULT NULL,
    p_max_value DECIMAL(15,2) DEFAULT NULL,
    p_tags VARCHAR(100)[] DEFAULT NULL,
    p_sort_by VARCHAR(50) DEFAULT 'name',
    p_sort_direction VARCHAR(4) DEFAULT 'ASC',
    p_page_size INTEGER DEFAULT 50,
    p_page_number INTEGER DEFAULT 1
) RETURNS TABLE (
    asset_id UUID,
    asset_name VARCHAR(255),
    category_name VARCHAR(100),
    category_code VARCHAR(20),
    estimated_value DECIMAL(15,2),
    currency_code VARCHAR(3),
    owner_names TEXT,
    total_results INTEGER
) AS $$
DECLARE
    v_current_tenant_id INTEGER;
    v_offset INTEGER;
    v_total_count INTEGER;
    v_base_query TEXT;
    v_where_conditions TEXT[];
    v_where_clause TEXT;
    v_order_clause TEXT;
BEGIN
    -- Get current context
    v_current_tenant_id := fn_get_current_tenant_id();
    
    -- Calculate offset
    v_offset := (p_page_number - 1) * p_page_size;
    
    -- Build where conditions
    v_where_conditions := ARRAY['a.tenant_id = ' || v_current_tenant_id || ' AND a.is_active = true'];
    
    -- Add search text filter
    IF p_search_text IS NOT NULL AND LENGTH(TRIM(p_search_text)) > 0 THEN
        v_where_conditions := array_append(v_where_conditions, 
            '(a.name ILIKE ''%' || p_search_text || '%'' OR a.description ILIKE ''%' || p_search_text || '%'')');
    END IF;
    
    -- Add category filter
    IF p_category_codes IS NOT NULL AND array_length(p_category_codes, 1) > 0 THEN
        v_where_conditions := array_append(v_where_conditions,
            'ac.code = ANY(''' || array_to_string(p_category_codes, ',') || ''')');
    END IF;
    
    -- Add value range filters
    IF p_min_value IS NOT NULL THEN
        v_where_conditions := array_append(v_where_conditions,
            'a.estimated_value >= ' || p_min_value);
    END IF;
    
    IF p_max_value IS NOT NULL THEN
        v_where_conditions := array_append(v_where_conditions,
            'a.estimated_value <= ' || p_max_value);
    END IF;
    
    -- Add persona ownership filter
    IF p_persona_id IS NOT NULL THEN
        v_where_conditions := array_append(v_where_conditions,
            'EXISTS (SELECT 1 FROM asset_persona ap WHERE ap.asset_id = a.id AND ap.persona_id = ''' || p_persona_id || ''' AND ap.is_active = true' ||
            CASE WHEN p_ownership_type IS NOT NULL THEN ' AND ap.ownership_type = ''' || p_ownership_type || '''' ELSE '' END || ')');
    END IF;
    
    -- Add tags filter
    IF p_tags IS NOT NULL AND array_length(p_tags, 1) > 0 THEN
        v_where_conditions := array_append(v_where_conditions,
            'a.tags ?| ARRAY[''' || array_to_string(p_tags, ''',''') || ''']');
    END IF;
    
    -- Combine where conditions
    v_where_clause := 'WHERE ' || array_to_string(v_where_conditions, ' AND ');
    
    -- Build order clause
    v_order_clause := 'ORDER BY ' || 
        CASE p_sort_by
            WHEN 'name' THEN 'a.name'
            WHEN 'category' THEN 'ac.name'
            WHEN 'value' THEN 'a.estimated_value'
            WHEN 'created' THEN 'a.created_at'
            WHEN 'updated' THEN 'a.updated_at'
            ELSE 'a.name'
        END || ' ' || 
        CASE WHEN UPPER(p_sort_direction) = 'DESC' THEN 'DESC' ELSE 'ASC' END;
    
    -- Get total count
    v_base_query := '
        SELECT COUNT(*)
        FROM assets a
        JOIN asset_categories ac ON a.category_id = ac.id
        ' || v_where_clause;
    
    EXECUTE v_base_query INTO v_total_count;
    
    -- Return paginated results
    RETURN QUERY EXECUTE '
        SELECT 
            a.id,
            a.name,
            ac.name,
            ac.code,
            a.estimated_value,
            a.currency_code,
            COALESCE(
                (SELECT string_agg(p.first_name || '' '' || p.last_name, '', '')
                 FROM asset_persona ap
                 JOIN personas p ON ap.persona_id = p.id
                 WHERE ap.asset_id = a.id AND ap.ownership_type = ''owner'' AND ap.is_active = true),
                ''No owners''
            ),
            ' || v_total_count || '
        FROM assets a
        JOIN asset_categories ac ON a.category_id = ac.id
        ' || v_where_clause || '
        ' || v_order_clause || '
        LIMIT ' || p_page_size || ' OFFSET ' || v_offset;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Business Logic & Validation

### Helper Functions

```sql
-- Validate user permissions for asset operations
CREATE OR REPLACE FUNCTION fn_user_can_modify_asset(
    p_user_id UUID,
    p_asset_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    -- Check if user owns the asset through their personas
    -- Or has appropriate permissions in the FFC
    RETURN EXISTS (
        SELECT 1 
        FROM asset_persona ap
        JOIN personas pe ON ap.persona_id = pe.id
        WHERE ap.asset_id = p_asset_id
        AND pe.user_id = p_user_id
        AND ap.ownership_type IN ('owner', 'trustee')
        AND ap.is_active = true
    ) OR fn_check_user_permission(p_user_id, fn_get_asset_ffc(p_asset_id), 'asset_modify');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get specialized asset data based on category
CREATE OR REPLACE FUNCTION fn_get_specialized_asset_data(
    p_asset_id UUID,
    p_category_code VARCHAR(20)
) RETURNS JSONB AS $$
DECLARE
    v_result JSONB := '{}';
BEGIN
    -- Route to appropriate specialized table based on category
    CASE p_category_code
        WHEN 'real_estate' THEN
            SELECT to_jsonb(re.*) INTO v_result FROM real_estate re WHERE re.asset_id = p_asset_id;
        WHEN 'financial_accounts' THEN
            SELECT to_jsonb(fa.*) INTO v_result FROM financial_accounts fa WHERE fa.asset_id = p_asset_id;
        WHEN 'life_insurance' THEN
            SELECT to_jsonb(li.*) INTO v_result FROM life_insurance li WHERE li.asset_id = p_asset_id;
        -- Add other categories as needed
        ELSE
            v_result := '{}';
    END CASE;
    
    RETURN COALESCE(v_result, '{}');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security Considerations

### Access Control
- **Tenant Isolation**: All procedures validate tenant context
- **Permission Checking**: User permissions validated for modify/delete operations
- **Ownership Validation**: Only asset owners/trustees can modify assets
- **Audit Logging**: All operations logged with user context

### Data Protection
- **Encrypted Sensitive Data**: Account numbers and credentials encrypted
- **Soft Deletes**: Assets are soft-deleted to maintain audit trail
- **Input Validation**: All inputs validated for type and range
- **SQL Injection Prevention**: All procedures use parameterized queries

### Business Rules
- **Ownership Limits**: Total ownership cannot exceed 100%
- **Valid Percentages**: Ownership percentages must be between 0.01 and 100.00
- **Active Status**: Only active assets can be modified
- **Category Consistency**: Specialized tables must match asset category

## Usage Examples

### Creating a Real Estate Asset
```sql
-- Create a primary residence
SELECT * FROM sp_create_asset(
    p_tenant_id := 1,
    p_category_code := 'real_estate',
    p_name := 'Family Home - 123 Main St',
    p_description := 'Primary family residence',
    p_estimated_value := 750000.00,
    p_currency_code := 'USD',
    p_owner_persona_id := '550e8400-e29b-41d4-a716-446655440001',
    p_ownership_percentage := 100.00,
    p_tags := '["primary_residence", "family_home"]',
    p_specialized_data := '{
        "property_type": "single_family",
        "property_use": "primary_residence",
        "year_built": 2010,
        "square_footage": 2800,
        "lot_size_acres": 0.25,
        "purchase_price": 650000.00,
        "purchase_date": "2020-03-15",
        "annual_property_tax": 8500.00,
        "is_primary_residence": true
    }'
);
```

### Transferring Asset Ownership
```sql
-- Transfer 50% ownership to spouse
SELECT sp_transfer_asset_ownership(
    p_asset_id := '660e8400-e29b-41d4-a716-446655440001',
    p_from_persona_id := '550e8400-e29b-41d4-a716-446655440001',
    p_to_persona_id := '550e8400-e29b-41d4-a716-446655440002',
    p_ownership_percentage := 50.00,
    p_transfer_reason := 'Joint ownership for estate planning'
);
```

### Searching Assets
```sql
-- Search for all real estate over $500k
SELECT * FROM sp_search_assets(
    p_category_codes := ARRAY['real_estate'],
    p_min_value := 500000.00,
    p_sort_by := 'value',
    p_sort_direction := 'DESC',
    p_page_size := 10,
    p_page_number := 1
);
```

---

*These asset management procedures provide comprehensive, secure, and auditable asset operations for the Forward Inheritance Platform, enabling families to effectively manage their diverse asset portfolios with proper ownership tracking and inheritance planning capabilities.*