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