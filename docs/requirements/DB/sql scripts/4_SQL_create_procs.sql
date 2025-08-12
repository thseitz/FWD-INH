-- Test Functions for Stored Procedure Testing
-- This creates simplified versions of the procedures for testing

-- ================================================================
-- HELPER FUNCTIONS FOR RLS
-- ================================================================

-- Get current user's ID from session/context
CREATE OR REPLACE FUNCTION current_user_id() 
RETURNS UUID AS $$
BEGIN
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
-- USER MANAGEMENT PROCEDURES
-- ================================================================

-- Create user from Cognito
CREATE OR REPLACE PROCEDURE sp_create_user_from_cognito(
    p_tenant_id INTEGER,
    p_cognito_user_id TEXT,
    p_cognito_username TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_first_name TEXT,
    p_last_name TEXT,
    OUT p_user_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO users (
        tenant_id,
        cognito_user_id,
        cognito_username,
        first_name,
        last_name,
        status
    ) VALUES (
        p_tenant_id,
        p_cognito_user_id,
        p_cognito_username,
        p_first_name,
        p_last_name,
        'active'
    ) RETURNING id INTO p_user_id;
END;
$$;

-- Update user profile
CREATE OR REPLACE PROCEDURE sp_update_user_profile(
    p_user_id UUID,
    p_first_name TEXT,
    p_last_name TEXT,
    p_display_name TEXT,
    p_profile_picture_url TEXT,
    p_preferred_language CHAR(2),
    p_timezone VARCHAR(50)
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE users SET
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        display_name = COALESCE(p_display_name, display_name),
        profile_picture_url = COALESCE(p_profile_picture_url, profile_picture_url),
        preferred_language = COALESCE(p_preferred_language, preferred_language),
        timezone = COALESCE(p_timezone, timezone),
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;

-- ================================================================
-- FFC MANAGEMENT PROCEDURES
-- ================================================================

-- Create FFC
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

-- Add persona to FFC
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

-- Update FFC member role
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

-- Remove FFC member
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

-- ================================================================
-- SIMPLIFIED STUB PROCEDURES FOR TESTING
-- ================================================================

-- Asset procedures
CREATE OR REPLACE PROCEDURE sp_create_asset(
    p_tenant_id INTEGER,
    p_category_id UUID,
    p_name TEXT,
    p_description TEXT,
    p_value DECIMAL,
    p_owner_persona_id UUID,
    p_metadata JSONB,
    OUT p_asset_id UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO assets (tenant_id, category_id, name, description, estimated_value)
    VALUES (p_tenant_id, p_category_id, p_name, p_description, p_value)
    RETURNING id INTO p_asset_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_update_asset(
    p_asset_id UUID,
    p_name TEXT,
    p_description TEXT,
    p_value DECIMAL,
    p_metadata JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE assets SET
        name = COALESCE(p_name, name),
        description = COALESCE(p_description, description),
        estimated_value = COALESCE(p_value, estimated_value),
        updated_at = NOW()
    WHERE id = p_asset_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_delete_asset(p_asset_id UUID)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM assets WHERE id = p_asset_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_transfer_asset_ownership(
    p_asset_id UUID,
    p_from_persona_id UUID,
    p_to_persona_id UUID,
    p_ownership_percentage DECIMAL
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Simplified transfer logic
    UPDATE asset_persona
    SET persona_id = p_to_persona_id
    WHERE asset_id = p_asset_id
    AND persona_id = p_from_persona_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_update_asset_value(
    p_asset_id UUID,
    p_new_value DECIMAL,
    p_valuation_date DATE,
    p_notes TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE assets SET
        estimated_value = p_new_value,
        last_valued_date = p_valuation_date,
        updated_at = NOW()
    WHERE id = p_asset_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_get_asset_details(p_asset_id UUID)
RETURNS TABLE(
    id UUID,
    name TEXT,
    description TEXT,
    estimated_value DECIMAL,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.name, a.description, a.estimated_value, a.created_at
    FROM assets a
    WHERE a.id = p_asset_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_search_assets(
    p_tenant_id INTEGER,
    p_search_term TEXT,
    p_category_id UUID,
    p_min_value DECIMAL,
    p_max_value DECIMAL,
    p_owner_persona_id UUID
)
RETURNS TABLE(
    id UUID,
    name TEXT,
    estimated_value DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.name, a.estimated_value
    FROM assets a
    WHERE a.tenant_id = p_tenant_id
    AND (p_search_term IS NULL OR a.name ILIKE '%' || p_search_term || '%');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_assign_asset_to_persona(
    p_asset_id UUID,
    p_persona_id UUID,
    p_ownership_type ownership_type_enum,
    p_ownership_percentage DECIMAL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    SELECT tenant_id INTO v_tenant_id FROM assets WHERE id = p_asset_id;
    
    INSERT INTO asset_persona (
        tenant_id,
        asset_id,
        persona_id,
        ownership_type,
        ownership_percentage
    ) VALUES (
        v_tenant_id,
        p_asset_id,
        p_persona_id,
        p_ownership_type,
        p_ownership_percentage
    );
END;
$$;

-- Contact procedures
CREATE OR REPLACE PROCEDURE sp_add_email_to_persona(
    p_persona_id UUID,
    p_email TEXT,
    p_email_type email_type_enum,
    p_usage_type email_usage_type_enum,
    p_is_primary BOOLEAN
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Simplified stub
    NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_add_phone_to_persona(
    p_persona_id UUID,
    p_phone TEXT,
    p_phone_type phone_type_enum,
    p_usage_type phone_usage_type_enum,
    p_is_primary BOOLEAN
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Simplified stub
    NULL;
END;
$$;

-- Session procedures
CREATE OR REPLACE PROCEDURE sp_set_session_context(
    p_user_id UUID,
    p_tenant_id INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, true);
    PERFORM set_config('app.current_tenant_id', p_tenant_id::TEXT, true);
END;
$$;

CREATE OR REPLACE PROCEDURE sp_clear_session_context()
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM set_config('app.current_user_id', NULL, true);
    PERFORM set_config('app.current_tenant_id', NULL, true);
END;
$$;

-- Stub procedures for remaining functions
CREATE OR REPLACE PROCEDURE sp_create_invitation(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_invited_by_user_id UUID,
    p_invitee_email TEXT,
    p_invitee_phone TEXT,
    p_invitee_first_name TEXT,
    p_invitee_last_name TEXT,
    p_role ffc_role_enum,
    OUT p_invitation_id UUID,
    OUT p_email_token TEXT,
    OUT p_phone_token TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    p_invitation_id := gen_random_uuid();
    p_email_token := 'test_email_token';
    p_phone_token := 'test_phone_token';
END;
$$;

-- Audit procedures
CREATE OR REPLACE PROCEDURE sp_log_audit_event(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_action audit_action_enum,
    p_entity_type audit_entity_type_enum,
    p_entity_id UUID,
    p_details JSONB,
    p_ip_address TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        metadata,  -- Changed from details to metadata
        ip_address,
        change_summary
    ) VALUES (
        p_tenant_id,
        p_user_id,
        p_action,
        p_entity_type,
        p_entity_id,
        p_details,
        p_ip_address::INET,
        p_details->>'summary'
    );
END;
$$;

CREATE OR REPLACE PROCEDURE sp_create_audit_event(
    p_tenant_id INTEGER,
    p_event_type TEXT,
    p_event_data JSONB,
    p_user_id UUID,
    p_metadata JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO audit_events (
        tenant_id,
        event_type,
        event_category,
        severity,
        description,
        details,  -- Changed from event_data to details
        user_id
    ) VALUES (
        p_tenant_id,
        p_event_type,
        COALESCE(p_metadata->>'category', 'general'),
        COALESCE(p_metadata->>'severity', 'info'),
        COALESCE(p_metadata->>'description', p_event_type),
        p_event_data,
        p_user_id
    );
END;
$$;

CREATE OR REPLACE FUNCTION sp_get_audit_trail(
    p_tenant_id INTEGER,
    p_entity_type audit_entity_type_enum,
    p_entity_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE,
    p_end_date TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE(
    id UUID,
    action audit_action_enum,
    user_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    details JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT al.id, al.action, al.user_id, al.created_at, al.metadata AS details
    FROM audit_log al
    WHERE al.tenant_id = p_tenant_id
    AND al.entity_type = p_entity_type
    AND al.entity_id = p_entity_id
    AND al.created_at BETWEEN p_start_date AND p_end_date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_generate_compliance_report(
    p_tenant_id INTEGER,
    p_report_type TEXT,
    p_start_date TIMESTAMP WITH TIME ZONE,
    p_end_date TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE(
    report_data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_build_object(
        'report_type', p_report_type,
        'start_date', p_start_date,
        'end_date', p_end_date,
        'data', '{}'::jsonb
    );
END;
$$ LANGUAGE plpgsql;

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

-- Trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create stub functions for remaining procedures
CREATE OR REPLACE PROCEDURE sp_append_event(
    p_tenant_id INTEGER,
    p_aggregate_id UUID,
    p_aggregate_type TEXT,
    p_event_type TEXT,
    p_event_data JSONB,
    p_user_id UUID,
    p_metadata JSONB,
    OUT p_event_id UUID
) LANGUAGE plpgsql AS $$ BEGIN p_event_id := gen_random_uuid(); END; $$;

CREATE OR REPLACE FUNCTION sp_replay_events(
    p_aggregate_id UUID,
    p_from_version INTEGER,
    p_to_version INTEGER
) RETURNS TABLE(event_data JSONB) AS $$ BEGIN RETURN QUERY SELECT '{}'::jsonb; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_create_snapshot(
    p_aggregate_id UUID,
    p_aggregate_type TEXT,
    p_version INTEGER,
    p_state JSONB
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE PROCEDURE sp_rebuild_projection(
    p_projection_name TEXT,
    p_aggregate_type TEXT,
    p_aggregate_id UUID
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE FUNCTION sp_detect_pii(
    p_tenant_id INTEGER,
    p_text_content TEXT,
    p_entity_type TEXT,
    p_entity_id UUID
) RETURNS TABLE(has_pii BOOLEAN, pii_types TEXT[]) AS $$ 
BEGIN RETURN QUERY SELECT false, '{}'::TEXT[]; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_update_pii_job_status(
    p_job_id UUID,
    p_status TEXT,
    p_results JSONB
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE PROCEDURE sp_configure_quillt_integration(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_connection_id UUID,
    p_configuration JSONB
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE PROCEDURE sp_sync_quillt_data(
    p_integration_id UUID,
    p_sync_type TEXT
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE FUNCTION sp_validate_quillt_credentials(
    p_user_id UUID,
    p_connection_id UUID
) RETURNS BOOLEAN AS $$ BEGIN RETURN true; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_quillt_sync_status(p_user_id UUID)
RETURNS TABLE(status TEXT) AS $$ BEGIN RETURN QUERY SELECT 'ready'::TEXT; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_sync_real_estate_data(
    p_integration_id UUID,
    p_property_address TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_provider_name TEXT;
    v_api_endpoint TEXT;
    v_property_id UUID;
BEGIN
    v_property_id := gen_random_uuid();
    
    SELECT provider_name, api_endpoint 
    INTO v_provider_name, v_api_endpoint
    FROM real_estate_provider_integrations
    WHERE id = p_integration_id;
    
    UPDATE real_estate_provider_integrations
    SET last_sync_at = NOW()
    WHERE id = p_integration_id;
    
    INSERT INTO real_estate_sync_logs (
        integration_id, property_id, sync_type, sync_status, 
        new_value, data_source, initiated_at, completed_at
    ) VALUES (
        p_integration_id, v_property_id, 'valuation', 'completed'::sync_status_enum,
        jsonb_build_object('address', p_property_address, 'synced', true),
        v_provider_name, NOW(), NOW()
    );
    
    RAISE NOTICE 'Synced property % using provider %', p_property_address, v_provider_name;
END;
$$;

CREATE OR REPLACE FUNCTION sp_get_real_estate_sync_history(
    p_tenant_id INTEGER,
    p_days_back INTEGER
) RETURNS TABLE(sync_data JSONB) AS $$ BEGIN RETURN QUERY SELECT '{}'::jsonb; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_manage_advisor_company(
    p_operation TEXT,
    p_tenant_id INTEGER,
    p_company_name TEXT,
    p_company_type TEXT,
    p_contact_info JSONB,
    p_company_id UUID,
    OUT p_result_id UUID
) LANGUAGE plpgsql AS $$ BEGIN p_result_id := gen_random_uuid(); END; $$;

CREATE OR REPLACE FUNCTION sp_get_advisor_companies(
    p_tenant_id INTEGER,
    p_company_type TEXT,
    p_is_active BOOLEAN
) RETURNS TABLE(company_data JSONB) AS $$ BEGIN RETURN QUERY SELECT '{}'::jsonb; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_integration_health(
    p_tenant_id INTEGER,
    p_integration_type TEXT
) RETURNS TABLE(health_status TEXT) AS $$ BEGIN RETURN QUERY SELECT 'healthy'::TEXT; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_retry_failed_integration(
    p_integration_type TEXT,
    p_integration_id UUID,
    p_retry_count INTEGER
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE PROCEDURE sp_configure_builder_io(
    p_tenant_id INTEGER,
    p_api_key TEXT,
    p_space_id TEXT,
    p_environment TEXT
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

CREATE OR REPLACE PROCEDURE sp_refresh_builder_content(
    p_integration_id UUID,
    p_content_type TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE builder_io_integrations
    SET 
        last_sync_at = NOW(),
        connection_status = 'connected'::integration_status_enum
    WHERE id = p_integration_id;
    
    RAISE NOTICE 'Refreshed % content for integration %', p_content_type, p_integration_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_get_builder_content_status(p_tenant_id INTEGER)
RETURNS TABLE(status TEXT) AS $$ BEGIN RETURN QUERY SELECT 'synced'::TEXT; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_manage_translation(
    p_operation TEXT,
    p_entity_type TEXT,
    p_entity_id UUID,
    p_language_code TEXT,
    p_field_name TEXT,
    p_original_text TEXT,
    p_translated_text TEXT,
    p_translation_id UUID,
    OUT p_result_id UUID
) LANGUAGE plpgsql AS $$ BEGIN p_result_id := gen_random_uuid(); END; $$;

CREATE OR REPLACE FUNCTION sp_get_translations(
    p_entity_type TEXT,
    p_entity_id UUID,
    p_language_code TEXT
) RETURNS TABLE(translation_data JSONB) AS $$ BEGIN RETURN QUERY SELECT '{}'::jsonb; END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE sp_update_system_configuration(
    p_tenant_id INTEGER,
    p_config_key TEXT,
    p_config_value JSONB,
    p_updated_by UUID
) LANGUAGE plpgsql AS $$ BEGIN NULL; END; $$;

-- ================================================================
-- SUBSCRIPTION AND PAYMENT MANAGEMENT PROCEDURES
-- ================================================================

-- Create FFC with automatic free plan subscription
CREATE OR REPLACE PROCEDURE sp_create_ffc_with_subscription(
    p_tenant_id INTEGER,
    p_name TEXT,
    p_description TEXT,
    p_owner_user_id UUID,
    p_owner_persona_id UUID,
    OUT p_ffc_id UUID,
    OUT p_subscription_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_plan_id UUID;
    v_persona_id UUID;
BEGIN
    -- Get the free plan for this tenant
    SELECT id INTO v_plan_id 
    FROM plans 
    WHERE tenant_id = p_tenant_id 
    AND plan_code = 'FAMILY_UNLIMITED_FREE' 
    AND status = 'active'
    LIMIT 1;
    
    IF v_plan_id IS NULL THEN
        RAISE EXCEPTION 'No free plan found for tenant %', p_tenant_id;
    END IF;
    
    -- Create the FFC directly (sp_create_ffc may have different signature)
    INSERT INTO fwd_family_circles (
        tenant_id,
        name,
        description,
        owner_user_id,
        status
    ) VALUES (
        p_tenant_id,
        p_name,
        p_description,
        p_owner_user_id,
        'active'
    ) RETURNING id INTO p_ffc_id;
    
    -- Add owner persona to FFC if provided
    IF p_owner_persona_id IS NOT NULL THEN
        INSERT INTO ffc_personas (
            tenant_id,
            ffc_id,
            persona_id,
            ffc_role
        ) VALUES (
            p_tenant_id,
            p_ffc_id,
            p_owner_persona_id,
            'owner'
        );
    END IF;
    
    -- Create the free subscription
    INSERT INTO subscriptions (
        tenant_id,
        ffc_id,
        plan_id,
        owner_user_id,
        payer_type,
        status,
        billing_amount,
        metadata
    ) VALUES (
        p_tenant_id,
        p_ffc_id,
        v_plan_id,
        p_owner_user_id,
        'none', -- No payment for free plan
        'active',
        0.00,
        jsonb_build_object(
            'auto_created', true,
            'created_at', NOW()
        )
    ) RETURNING id INTO p_subscription_id;
    
    -- Get or use the owner persona
    IF p_owner_persona_id IS NOT NULL THEN
        v_persona_id := p_owner_persona_id;
    ELSE
        -- Get the owner's persona
        SELECT id INTO v_persona_id
        FROM personas
        WHERE user_id = p_owner_user_id
        AND tenant_id = p_tenant_id
        LIMIT 1;
    END IF;
    
    -- Assign owner a pro seat if persona exists
    IF v_persona_id IS NOT NULL THEN
        INSERT INTO seat_assignments (
            subscription_id,
            persona_id,
            seat_type,
            status,
            activated_at
        ) VALUES (
            p_subscription_id,
            v_persona_id,
            'pro',
            'active',
            NOW()
        );
    END IF;
    
    -- Log to audit
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        change_summary
    ) VALUES (
        p_tenant_id,
        p_owner_user_id,
        'create',
        'subscription',
        p_subscription_id,
        p_name,
        'Auto-created free subscription for new FFC'
    );
END;
$$;

-- Process seat invitation after approval
CREATE OR REPLACE PROCEDURE sp_process_seat_invitation(
    p_invitation_id UUID,
    p_subscription_id UUID,
    p_persona_id UUID,
    p_seat_type seat_type_enum DEFAULT 'pro'
)
LANGUAGE plpgsql AS $$
DECLARE
    v_invitation_status invitation_status_enum;
    v_existing_seat_id UUID;
    v_plan_id UUID;
    v_included_quantity INTEGER;
    v_used_seats INTEGER;
BEGIN
    -- Verify invitation is approved
    SELECT status INTO v_invitation_status
    FROM ffc_invitations
    WHERE id = p_invitation_id;
    
    IF v_invitation_status != 'approved' THEN
        RAISE EXCEPTION 'Invitation % is not approved (status: %)', p_invitation_id, v_invitation_status;
    END IF;
    
    -- Check for existing active seat assignment
    SELECT id INTO v_existing_seat_id
    FROM seat_assignments
    WHERE subscription_id = p_subscription_id
    AND persona_id = p_persona_id
    AND status = 'active';
    
    IF v_existing_seat_id IS NOT NULL THEN
        RAISE NOTICE 'Persona % already has an active seat assignment', p_persona_id;
        RETURN;
    END IF;
    
    -- Get plan details to check seat limits
    SELECT s.plan_id INTO v_plan_id
    FROM subscriptions s
    WHERE s.id = p_subscription_id;
    
    -- Check seat availability (NULL included_quantity means unlimited)
    SELECT ps.included_quantity INTO v_included_quantity
    FROM plan_seats ps
    WHERE ps.plan_id = v_plan_id
    AND ps.seat_type = p_seat_type;
    
    IF v_included_quantity IS NOT NULL THEN
        -- Count used seats
        SELECT COUNT(*) INTO v_used_seats
        FROM seat_assignments sa
        WHERE sa.subscription_id = p_subscription_id
        AND sa.seat_type = p_seat_type
        AND sa.status = 'active';
        
        IF v_used_seats >= v_included_quantity THEN
            RAISE EXCEPTION 'No available seats of type % for subscription %', p_seat_type, p_subscription_id;
        END IF;
    END IF;
    
    -- Create seat assignment
    INSERT INTO seat_assignments (
        subscription_id,
        persona_id,
        seat_type,
        status,
        invitation_id,
        invited_at,
        activated_at
    ) VALUES (
        p_subscription_id,
        p_persona_id,
        p_seat_type,
        'active',
        p_invitation_id,
        NOW(),
        NOW()
    );
    
    -- Update invitation status
    UPDATE ffc_invitations
    SET 
        status = 'accepted',
        accepted_at = NOW()
    WHERE id = p_invitation_id;
END;
$$;

-- Purchase one-time service
CREATE OR REPLACE PROCEDURE sp_purchase_service(
    p_tenant_id INTEGER,
    p_service_id UUID,
    p_ffc_id UUID,
    p_purchaser_user_id UUID,
    p_payment_method_id UUID,
    p_stripe_payment_intent_id TEXT,
    OUT p_purchase_id UUID,
    OUT p_payment_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_service_price DECIMAL(10, 2);
    v_service_name TEXT;
BEGIN
    -- Validate service exists and is active
    SELECT price, service_name INTO v_service_price, v_service_name
    FROM services
    WHERE id = p_service_id
    AND tenant_id = p_tenant_id
    AND status = 'active';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Service % not found or inactive', p_service_id;
    END IF;
    
    -- Create service purchase record
    INSERT INTO service_purchases (
        tenant_id,
        service_id,
        ffc_id,
        purchaser_user_id,
        amount,
        stripe_payment_intent_id,
        payment_method_id,
        status,
        purchased_at
    ) VALUES (
        p_tenant_id,
        p_service_id,
        p_ffc_id,
        p_purchaser_user_id,
        v_service_price,
        p_stripe_payment_intent_id,
        p_payment_method_id,
        'pending',
        NOW()
    ) RETURNING id INTO p_purchase_id;
    
    -- Create payment record
    INSERT INTO payments (
        tenant_id,
        payer_id,
        amount,
        currency,
        payment_type,
        reference_id,
        payment_method_id,
        stripe_payment_intent_id,
        status
    ) VALUES (
        p_tenant_id,
        p_purchaser_user_id,
        v_service_price,
        'USD',
        'service',
        p_purchase_id,
        p_payment_method_id,
        p_stripe_payment_intent_id,
        'pending'
    ) RETURNING id INTO p_payment_id;
    
    -- Log to audit
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        change_summary
    ) VALUES (
        p_tenant_id,
        p_purchaser_user_id,
        'create',
        'service_purchase',
        p_purchase_id,
        v_service_name,
        format('Purchased service for $%s', v_service_price)
    );
END;
$$;

-- Process Stripe webhook events
CREATE OR REPLACE PROCEDURE sp_process_stripe_webhook(
    p_stripe_event_id TEXT,
    p_event_type TEXT,
    p_payload JSONB
)
LANGUAGE plpgsql AS $$
DECLARE
    v_existing_event_id UUID;
    v_event_id UUID;
BEGIN
    -- Check for duplicate event (idempotency)
    SELECT id INTO v_existing_event_id
    FROM stripe_events
    WHERE stripe_event_id = p_stripe_event_id;
    
    IF v_existing_event_id IS NOT NULL THEN
        -- Event already processed
        RAISE NOTICE 'Stripe event % already processed', p_stripe_event_id;
        RETURN;
    END IF;
    
    -- Insert event record
    INSERT INTO stripe_events (
        stripe_event_id,
        event_type,
        status,
        payload,
        attempts,
        last_attempt_at
    ) VALUES (
        p_stripe_event_id,
        p_event_type,
        'processing',
        p_payload,
        1,
        NOW()
    ) RETURNING id INTO v_event_id;
    
    -- Route to appropriate handler based on event type
    CASE p_event_type
        WHEN 'payment_intent.succeeded' THEN
            CALL sp_handle_payment_succeeded(v_event_id, p_payload);
        WHEN 'payment_intent.failed' THEN
            CALL sp_handle_payment_failed(v_event_id, p_payload);
        WHEN 'invoice.payment_succeeded' THEN
            CALL sp_handle_invoice_payment_succeeded(v_event_id, p_payload);
        WHEN 'customer.subscription.created' THEN
            CALL sp_handle_subscription_created(v_event_id, p_payload);
        WHEN 'customer.subscription.updated' THEN
            CALL sp_handle_subscription_updated(v_event_id, p_payload);
        WHEN 'customer.subscription.deleted' THEN
            CALL sp_handle_subscription_deleted(v_event_id, p_payload);
        ELSE
            -- Mark as ignored for unsupported event types
            UPDATE stripe_events
            SET status = 'ignored',
                processed_at = NOW()
            WHERE id = v_event_id;
            
            RAISE NOTICE 'Ignoring unsupported event type: %', p_event_type;
    END CASE;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Update event with error
        UPDATE stripe_events
        SET status = 'failed',
            error_message = SQLERRM,
            last_attempt_at = NOW()
        WHERE id = v_event_id;
        
        RAISE;
END;
$$;

-- Helper procedures for webhook handlers (simplified stubs)
CREATE OR REPLACE PROCEDURE sp_handle_payment_succeeded(
    p_event_id UUID,
    p_payload JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Update payment status to succeeded
    UPDATE payments
    SET status = 'succeeded',
        processed_at = NOW()
    WHERE stripe_payment_intent_id = p_payload->>'id';
    
    -- Update service purchase if applicable
    UPDATE service_purchases
    SET status = 'succeeded'
    WHERE stripe_payment_intent_id = p_payload->>'id';
    
    -- Mark event as processed
    UPDATE stripe_events
    SET status = 'processed',
        processed_at = NOW()
    WHERE id = p_event_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_handle_payment_failed(
    p_event_id UUID,
    p_payload JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Update payment status to failed
    UPDATE payments
    SET status = 'failed',
        failure_reason = p_payload->'last_payment_error'->>'message',
        processed_at = NOW()
    WHERE stripe_payment_intent_id = p_payload->>'id';
    
    -- Mark event as processed
    UPDATE stripe_events
    SET status = 'processed',
        processed_at = NOW()
    WHERE id = p_event_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_handle_invoice_payment_succeeded(
    p_event_id UUID,
    p_payload JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Update subscription billing
    UPDATE subscriptions
    SET current_period_start = to_timestamp(((p_payload->'lines'->'data'->0->'period')->>'start')::int),
        current_period_end = to_timestamp(((p_payload->'lines'->'data'->0->'period')->>'end')::int),
        next_billing_date = to_timestamp(((p_payload->'lines'->'data'->0->'period')->>'end')::int)::date
    WHERE stripe_subscription_id = p_payload->>'subscription';
    
    -- Create payment record
    INSERT INTO payments (
        tenant_id,
        payer_id,
        amount,
        currency,
        payment_type,
        reference_id,
        stripe_invoice_id,
        status,
        processed_at
    )
    SELECT 
        s.tenant_id,
        s.payer_id,
        (p_payload->>'amount_paid')::decimal / 100,
        p_payload->>'currency',
        'subscription',
        s.id,
        p_payload->>'id',
        'succeeded',
        NOW()
    FROM subscriptions s
    WHERE s.stripe_subscription_id = p_payload->>'subscription';
    
    -- Mark event as processed
    UPDATE stripe_events
    SET status = 'processed',
        processed_at = NOW()
    WHERE id = p_event_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_handle_subscription_created(p_event_id UUID, p_payload JSONB)
LANGUAGE plpgsql AS $$ 
BEGIN 
    UPDATE stripe_events SET status = 'processed', processed_at = NOW() WHERE id = p_event_id;
END; 
$$;

CREATE OR REPLACE PROCEDURE sp_handle_subscription_updated(p_event_id UUID, p_payload JSONB)
LANGUAGE plpgsql AS $$ 
BEGIN 
    UPDATE stripe_events SET status = 'processed', processed_at = NOW() WHERE id = p_event_id;
END; 
$$;

CREATE OR REPLACE PROCEDURE sp_handle_subscription_deleted(p_event_id UUID, p_payload JSONB)
LANGUAGE plpgsql AS $$ 
BEGIN 
    UPDATE stripe_events SET status = 'processed', processed_at = NOW() WHERE id = p_event_id;
END; 
$$;

-- Check if payment method is in use (using the view)
CREATE OR REPLACE FUNCTION sp_check_payment_method_usage(
    p_payment_method_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_is_in_use BOOLEAN;
BEGIN
    -- Use the view to check usage
    SELECT is_in_use INTO v_is_in_use
    FROM payment_methods_with_usage
    WHERE id = p_payment_method_id;
    
    RETURN COALESCE(v_is_in_use, FALSE);
END;
$$;

-- Safely delete payment method
CREATE OR REPLACE PROCEDURE sp_delete_payment_method(
    p_payment_method_id UUID,
    p_user_id UUID
)
LANGUAGE plpgsql AS $$
DECLARE
    v_is_in_use BOOLEAN;
    v_owner_id UUID;
BEGIN
    -- Verify ownership
    SELECT user_id INTO v_owner_id
    FROM payment_methods
    WHERE id = p_payment_method_id;
    
    IF v_owner_id IS NULL THEN
        RAISE EXCEPTION 'Payment method % not found', p_payment_method_id;
    END IF;
    
    IF v_owner_id != p_user_id THEN
        RAISE EXCEPTION 'User % does not own payment method %', p_user_id, p_payment_method_id;
    END IF;
    
    -- Check if in use using our function
    v_is_in_use := sp_check_payment_method_usage(p_payment_method_id);
    
    IF v_is_in_use THEN
        RAISE EXCEPTION 'Payment method % is currently in use and cannot be deleted', p_payment_method_id;
    END IF;
    
    -- Soft delete the payment method
    UPDATE payment_methods
    SET status = 'deleted',
        updated_at = NOW()
    WHERE id = p_payment_method_id;
    
    -- Log to audit
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        change_summary
    )
    SELECT 
        tenant_id,
        p_user_id,
        'delete',
        'payment_method',
        p_payment_method_id,
        'Payment method deleted'
    FROM payment_methods
    WHERE id = p_payment_method_id;
END;
$$;

-- Transition subscription plan
CREATE OR REPLACE PROCEDURE sp_transition_subscription_plan(
    p_subscription_id UUID,
    p_new_plan_id UUID,
    p_initiated_by UUID,
    p_reason TEXT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_old_plan_id UUID;
    v_transition_type VARCHAR(50);
    v_old_price DECIMAL(10, 2);
    v_new_price DECIMAL(10, 2);
BEGIN
    -- Get current plan
    SELECT plan_id INTO v_old_plan_id
    FROM subscriptions
    WHERE id = p_subscription_id;
    
    -- Get plan prices to determine transition type
    SELECT base_price INTO v_old_price
    FROM plans WHERE id = v_old_plan_id;
    
    SELECT base_price INTO v_new_price
    FROM plans WHERE id = p_new_plan_id;
    
    -- Determine transition type
    IF v_new_price > v_old_price THEN
        v_transition_type := 'upgrade';
    ELSIF v_new_price < v_old_price THEN
        v_transition_type := 'downgrade';
    ELSE
        v_transition_type := 'lateral';
    END IF;
    
    -- Record transition
    INSERT INTO subscription_transitions (
        subscription_id,
        from_plan_id,
        to_plan_id,
        transition_type,
        effective_date,
        initiated_by,
        reason
    ) VALUES (
        p_subscription_id,
        v_old_plan_id,
        p_new_plan_id,
        v_transition_type,
        CURRENT_DATE,
        p_initiated_by,
        p_reason
    );
    
    -- Update subscription
    UPDATE subscriptions
    SET plan_id = p_new_plan_id,
        updated_at = NOW()
    WHERE id = p_subscription_id;
END;
$$;

-- Get subscription details with plan info
CREATE OR REPLACE FUNCTION sp_get_subscription_details(
    p_ffc_id UUID
)
RETURNS TABLE (
    subscription_id UUID,
    plan_name VARCHAR(100),
    plan_type plan_type_enum,
    billing_frequency billing_frequency_enum,
    billing_amount DECIMAL(10, 2),
    status subscription_status_enum,
    current_period_end DATE,
    next_billing_date DATE,
    seat_counts JSONB
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id as subscription_id,
        p.plan_name,
        p.plan_type,
        p.billing_frequency,
        s.billing_amount,
        s.status,
        s.current_period_end,
        s.next_billing_date,
        (
            SELECT jsonb_object_agg(
                seat_type_counts.seat_type,
                seat_type_counts.counts
            )
            FROM (
                SELECT 
                    sa.seat_type::text as seat_type,
                    jsonb_build_object(
                        'active', COUNT(*) FILTER (WHERE sa.status = 'active'),
                        'total', COUNT(*)
                    ) as counts
                FROM seat_assignments sa
                WHERE sa.subscription_id = s.id
                GROUP BY sa.seat_type
            ) as seat_type_counts
        ) as seat_counts
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE s.ffc_id = p_ffc_id
    AND s.status = 'active';
END;
$$;

-- Create general ledger entry
CREATE OR REPLACE PROCEDURE sp_create_ledger_entry(
    p_tenant_id INTEGER,
    p_transaction_type transaction_type_enum,
    p_account_type ledger_account_type_enum,
    p_amount DECIMAL(10, 2),
    p_reference_type VARCHAR(50),
    p_reference_id UUID,
    p_description TEXT,
    p_stripe_reference VARCHAR(255) DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO general_ledger (
        tenant_id,
        transaction_type,
        transaction_date,
        account_type,
        amount,
        currency,
        reference_type,
        reference_id,
        stripe_reference,
        category,
        description
    ) VALUES (
        p_tenant_id,
        p_transaction_type,
        CURRENT_DATE,
        p_account_type,
        p_amount,
        'USD',
        p_reference_type,
        p_reference_id,
        p_stripe_reference,
        CASE 
            WHEN p_reference_type = 'subscription' AND p_transaction_type = 'charge' THEN 'recurring_monthly'
            WHEN p_reference_type = 'service' THEN 'one_time'
            WHEN p_transaction_type = 'refund' THEN 'refund'
            ELSE NULL
        END,
        p_description
    );
END;
$$;

-- ================================================================
-- END OF STORED PROCEDURES FILE
-- ================================================================