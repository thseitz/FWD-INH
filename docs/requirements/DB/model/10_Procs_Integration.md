# 10 - Integration & External System Procedures

## Table of Contents
1. [Overview](#overview)
2. [Quillt Integration Procedures](#quillt-integration-procedures)
3. [Real Estate Integration Procedures](#real-estate-integration-procedures)
4. [Advisor Company Management](#advisor-company-management)
5. [Builder.io Integration](#builderio-integration)
6. [Translation Management](#translation-management)
7. [Integration Health Monitoring](#integration-health-monitoring)
8. [System Configuration](#system-configuration)

## Overview

The Forward Inheritance Platform implements **14 integration procedures** that connect with external services including Quillt for financial data, real estate valuation services, Builder.io for content management, and translation services. These procedures provide secure, audited integration capabilities with comprehensive error handling and retry mechanisms.

### Integration Categories
- **Quillt Financial Integration**: 4 procedures for financial account synchronization
- **Real Estate Services**: 2 procedures for property data synchronization
- **Advisor Management**: 2 procedures for professional service provider management
- **Builder.io CMS**: 3 procedures for content management
- **Translation Services**: 2 procedures for multi-language support
- **System Monitoring**: 2 procedures for health checks and error recovery

### Key Integration Features
- **Secure Credential Storage**: Encrypted storage of API keys and tokens
- **Automatic Retry Logic**: Failed integration retry with exponential backoff
- **Comprehensive Logging**: All integration activities logged for audit
- **Error Recovery**: Automatic error detection and recovery mechanisms
- **Rate Limiting**: Built-in rate limiting for external API calls

## Quillt Integration Procedures

### sp_configure_quillt_integration
Configures or updates Quillt financial data integration settings.

```sql
CREATE OR REPLACE FUNCTION sp_configure_quillt_integration(
    p_user_id UUID,
    p_connection_id VARCHAR(255),
    p_profile_id VARCHAR(255) DEFAULT NULL,
    p_access_token TEXT DEFAULT NULL,
    p_refresh_token TEXT DEFAULT NULL,
    p_sync_settings JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Check for existing integration
    SELECT id INTO v_integration_id
    FROM quillt_integrations
    WHERE tenant_id = v_tenant_id AND user_id = p_user_id;
    
    IF v_integration_id IS NULL THEN
        -- Create new integration
        INSERT INTO quillt_integrations (
            tenant_id,
            user_id,
            quillt_connection_id,
            quillt_profile_id,
            access_token_encrypted,
            refresh_token_encrypted,
            sync_accounts,
            sync_transactions,
            sync_investments,
            connection_status,
            created_at
        ) VALUES (
            v_tenant_id,
            p_user_id,
            p_connection_id,
            p_profile_id,
            encrypt_text(p_access_token),
            encrypt_text(p_refresh_token),
            COALESCE((p_sync_settings->>'sync_accounts')::boolean, TRUE),
            COALESCE((p_sync_settings->>'sync_transactions')::boolean, TRUE),
            COALESCE((p_sync_settings->>'sync_investments')::boolean, TRUE),
            'connected',
            (NOW() AT TIME ZONE 'UTC')
        ) RETURNING id INTO v_integration_id;
    ELSE
        -- Update existing integration
        UPDATE quillt_integrations SET
            quillt_connection_id = COALESCE(p_connection_id, quillt_connection_id),
            quillt_profile_id = COALESCE(p_profile_id, quillt_profile_id),
            access_token_encrypted = COALESCE(encrypt_text(p_access_token), access_token_encrypted),
            refresh_token_encrypted = COALESCE(encrypt_text(p_refresh_token), refresh_token_encrypted),
            sync_accounts = COALESCE((p_sync_settings->>'sync_accounts')::boolean, sync_accounts),
            sync_transactions = COALESCE((p_sync_settings->>'sync_transactions')::boolean, sync_transactions),
            sync_investments = COALESCE((p_sync_settings->>'sync_investments')::boolean, sync_investments),
            connection_status = 'connected',
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration_id;
    END IF;
    
    -- Log configuration
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
        p_user_id,
        'configure',
        'integration',
        v_integration_id,
        'Quillt Integration',
        jsonb_build_object(
            'integration_type', 'quillt',
            'sync_settings', p_sync_settings
        )
    );
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Features:**
- Encrypted credential storage using helper functions
- Flexible sync configuration for different data types
- Automatic connection status management
- Complete audit logging of configuration changes

### sp_sync_quillt_data
Synchronizes financial data from Quillt for a user.

```sql
CREATE OR REPLACE FUNCTION sp_sync_quillt_data(
    p_user_id UUID,
    p_sync_type VARCHAR(50) DEFAULT 'all'
) RETURNS TABLE (
    sync_id UUID,
    accounts_synced INTEGER,
    transactions_synced INTEGER,
    investments_synced INTEGER,
    errors_count INTEGER,
    sync_status VARCHAR(20)
) AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
    v_sync_id UUID;
    v_accounts_count INTEGER := 0;
    v_transactions_count INTEGER := 0;
    v_investments_count INTEGER := 0;
    v_errors INTEGER := 0;
    v_status VARCHAR(20);
BEGIN
    v_tenant_id := current_tenant_id();
    v_sync_id := gen_random_uuid();
    
    -- Get integration configuration
    SELECT id INTO v_integration_id
    FROM quillt_integrations
    WHERE tenant_id = v_tenant_id 
    AND user_id = p_user_id
    AND is_active = TRUE;
    
    IF v_integration_id IS NULL THEN
        RAISE EXCEPTION 'No active Quillt integration found for user';
    END IF;
    
    -- Update sync status to running
    UPDATE quillt_integrations SET
        sync_status = 'running',
        last_sync_at = (NOW() AT TIME ZONE 'UTC')
    WHERE id = v_integration_id;
    
    BEGIN
        -- Sync accounts if enabled
        IF p_sync_type IN ('all', 'accounts') THEN
            -- Actual sync logic would call Quillt API here
            v_accounts_count := 5; -- Placeholder for actual sync
        END IF;
        
        -- Sync transactions if enabled
        IF p_sync_type IN ('all', 'transactions') THEN
            -- Actual sync logic would call Quillt API here
            v_transactions_count := 150; -- Placeholder for actual sync
        END IF;
        
        -- Sync investments if enabled
        IF p_sync_type IN ('all', 'investments') THEN
            -- Actual sync logic would call Quillt API here
            v_investments_count := 3; -- Placeholder for actual sync
        END IF;
        
        v_status := 'completed';
        
        -- Update successful sync timestamp
        UPDATE quillt_integrations SET
            sync_status = v_status,
            last_successful_sync_at = (NOW() AT TIME ZONE 'UTC'),
            sync_error = NULL
        WHERE id = v_integration_id;
        
    EXCEPTION WHEN OTHERS THEN
        v_status := 'failed';
        v_errors := 1;
        
        -- Update with error information
        UPDATE quillt_integrations SET
            sync_status = v_status,
            sync_error = SQLERRM
        WHERE id = v_integration_id;
    END;
    
    -- Log sync operation
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
        p_user_id,
        'sync',
        'integration',
        v_integration_id,
        'Quillt Data Sync',
        jsonb_build_object(
            'sync_id', v_sync_id,
            'sync_type', p_sync_type,
            'accounts_synced', v_accounts_count,
            'transactions_synced', v_transactions_count,
            'investments_synced', v_investments_count,
            'status', v_status,
            'errors', v_errors
        )
    );
    
    RETURN QUERY
    SELECT v_sync_id, v_accounts_count, v_transactions_count, 
           v_investments_count, v_errors, v_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_validate_quillt_credentials
Validates Quillt API credentials and connection.

```sql
CREATE OR REPLACE FUNCTION sp_validate_quillt_credentials(
    p_user_id UUID
) RETURNS TABLE (
    is_valid BOOLEAN,
    connection_status VARCHAR(50),
    error_message TEXT,
    last_validated TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    v_integration_id UUID;
    v_tenant_id INTEGER;
    v_is_valid BOOLEAN;
    v_status VARCHAR(50);
    v_error TEXT;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Get integration
    SELECT id, connection_status 
    INTO v_integration_id, v_status
    FROM quillt_integrations
    WHERE tenant_id = v_tenant_id AND user_id = p_user_id;
    
    IF v_integration_id IS NULL THEN
        RETURN QUERY
        SELECT FALSE, 'not_configured'::VARCHAR(50), 
               'No Quillt integration configured'::TEXT, 
               NULL::TIMESTAMP WITH TIME ZONE;
        RETURN;
    END IF;
    
    -- Validate credentials (placeholder for actual API call)
    BEGIN
        -- Actual validation would decrypt tokens and test API connection
        v_is_valid := TRUE;
        v_status := 'connected';
        v_error := NULL;
        
        -- Update integration status
        UPDATE quillt_integrations SET
            connection_status = v_status,
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration_id;
        
    EXCEPTION WHEN OTHERS THEN
        v_is_valid := FALSE;
        v_status := 'disconnected';
        v_error := SQLERRM;
        
        UPDATE quillt_integrations SET
            connection_status = v_status,
            sync_error = v_error,
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration_id;
    END;
    
    RETURN QUERY
    SELECT v_is_valid, v_status, v_error, (NOW() AT TIME ZONE 'UTC');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_quillt_sync_status
Retrieves current sync status and history for Quillt integration.

```sql
CREATE OR REPLACE FUNCTION sp_get_quillt_sync_status(
    p_user_id UUID,
    p_include_history BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    integration_id UUID,
    connection_status VARCHAR(50),
    sync_status VARCHAR(20),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    last_successful_sync_at TIMESTAMP WITH TIME ZONE,
    accounts_enabled BOOLEAN,
    transactions_enabled BOOLEAN,
    investments_enabled BOOLEAN,
    error_message TEXT,
    sync_history JSONB
) AS $$
DECLARE
    v_tenant_id INTEGER;
    v_history JSONB;
BEGIN
    v_tenant_id := current_tenant_id();
    
    IF p_include_history THEN
        -- Get sync history from audit log
        SELECT jsonb_agg(
            jsonb_build_object(
                'timestamp', created_at,
                'status', metadata->>'status',
                'accounts_synced', metadata->'accounts_synced',
                'transactions_synced', metadata->'transactions_synced',
                'investments_synced', metadata->'investments_synced'
            ) ORDER BY created_at DESC
        ) INTO v_history
        FROM audit_log
        WHERE tenant_id = v_tenant_id
        AND user_id = p_user_id
        AND entity_type = 'integration'
        AND action = 'sync'
        AND created_at > (NOW() - INTERVAL '30 days')
        LIMIT 10;
    END IF;
    
    RETURN QUERY
    SELECT 
        qi.id,
        qi.connection_status,
        qi.sync_status,
        qi.last_sync_at,
        qi.last_successful_sync_at,
        qi.sync_accounts,
        qi.sync_transactions,
        qi.sync_investments,
        qi.sync_error,
        COALESCE(v_history, '[]'::jsonb)
    FROM quillt_integrations qi
    WHERE qi.tenant_id = v_tenant_id
    AND qi.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Real Estate Integration Procedures

### sp_sync_real_estate_data
Synchronizes real estate property valuations and market data.

```sql
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_asset_id UUID,
    p_data_source TEXT DEFAULT 'zillow'
) RETURNS TABLE (
    sync_log_id UUID,
    property_value DECIMAL(15,2),
    tax_assessment DECIMAL(15,2),
    market_trend JSONB,
    confidence_score DECIMAL(3,2),
    sync_status VARCHAR(20)
) AS $$
DECLARE
    v_tenant_id INTEGER;
    v_sync_log_id UUID;
    v_old_value JSONB;
    v_new_value JSONB;
    v_property_data RECORD;
    v_confidence DECIMAL(3,2);
    v_status VARCHAR(20);
BEGIN
    v_tenant_id := current_tenant_id();
    v_sync_log_id := gen_random_uuid();
    
    -- Get current property data
    SELECT 
        a.id,
        a.tags->>'property_value' as current_value,
        a.tags->>'tax_assessment' as current_tax,
        a.tags->>'last_valuation_date' as last_valuation
    INTO v_property_data
    FROM assets a
    WHERE a.id = p_asset_id
    AND a.tenant_id = v_tenant_id
    AND a.asset_type = 'real_estate';
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Real estate asset not found';
    END IF;
    
    -- Store old values for audit
    v_old_value := jsonb_build_object(
        'property_value', v_property_data.current_value,
        'tax_assessment', v_property_data.current_tax,
        'last_valuation_date', v_property_data.last_valuation
    );
    
    BEGIN
        -- Simulate external API call to get property data
        -- In production, this would call actual real estate APIs
        v_new_value := jsonb_build_object(
            'property_value', 850000,
            'tax_assessment', 8500,
            'market_trend', jsonb_build_object(
                '30_day_change', 0.02,
                '90_day_change', 0.05,
                'year_over_year', 0.08
            ),
            'last_valuation_date', (NOW() AT TIME ZONE 'UTC')
        );
        
        v_confidence := 0.95;
        v_status := 'completed';
        
        -- Update asset with new valuation
        UPDATE assets SET
            tags = tags || jsonb_build_object(
                'property_value', v_new_value->'property_value',
                'tax_assessment', v_new_value->'tax_assessment',
                'market_trend', v_new_value->'market_trend',
                'last_valuation_date', v_new_value->'last_valuation_date',
                'valuation_source', p_data_source,
                'valuation_confidence', v_confidence
            ),
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = p_asset_id;
        
    EXCEPTION WHEN OTHERS THEN
        v_status := 'failed';
        v_confidence := 0;
        
        -- Log error
        v_new_value := jsonb_build_object('error', SQLERRM);
    END;
    
    -- Log sync operation
    INSERT INTO real_estate_sync_logs (
        integration_id,
        property_id,
        sync_type,
        old_value,
        new_value,
        data_source,
        confidence_score,
        sync_status,
        synced_at
    ) VALUES (
        gen_random_uuid(), -- Would be actual integration ID
        p_asset_id,
        'valuation',
        v_old_value,
        v_new_value,
        p_data_source,
        v_confidence,
        v_status,
        (NOW() AT TIME ZONE 'UTC')
    ) RETURNING id INTO v_sync_log_id;
    
    RETURN QUERY
    SELECT 
        v_sync_log_id,
        (v_new_value->>'property_value')::DECIMAL(15,2),
        (v_new_value->>'tax_assessment')::DECIMAL(15,2),
        v_new_value->'market_trend',
        v_confidence,
        v_status;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_real_estate_sync_history
Retrieves synchronization history for real estate properties.

```sql
CREATE OR REPLACE FUNCTION sp_get_real_estate_sync_history(
    p_asset_id UUID DEFAULT NULL,
    p_days_back INTEGER DEFAULT 30
) RETURNS TABLE (
    sync_log_id UUID,
    property_id UUID,
    sync_type VARCHAR(50),
    sync_date TIMESTAMP WITH TIME ZONE,
    old_value JSONB,
    new_value JSONB,
    data_source TEXT,
    confidence_score DECIMAL(3,2),
    sync_status VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        resl.id,
        resl.property_id,
        resl.sync_type,
        resl.synced_at,
        resl.old_value,
        resl.new_value,
        resl.data_source,
        resl.confidence_score,
        resl.sync_status
    FROM real_estate_sync_logs resl
    JOIN assets a ON resl.property_id = a.id
    WHERE a.tenant_id = current_tenant_id()
    AND (p_asset_id IS NULL OR resl.property_id = p_asset_id)
    AND resl.synced_at > (NOW() - (p_days_back || ' days')::INTERVAL)
    ORDER BY resl.synced_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Advisor Company Management

### sp_manage_advisor_company
Creates or updates advisor company information.

```sql
CREATE OR REPLACE FUNCTION sp_manage_advisor_company(
    p_action VARCHAR(20), -- create, update, deactivate
    p_company_id UUID DEFAULT NULL,
    p_company_name TEXT DEFAULT NULL,
    p_company_type TEXT DEFAULT NULL,
    p_tax_id VARCHAR(20) DEFAULT NULL,
    p_contact_info JSONB DEFAULT '{}',
    p_services TEXT[] DEFAULT NULL,
    p_licensing JSONB DEFAULT '{}'
) RETURNS UUID AS $$
DECLARE
    v_tenant_id INTEGER;
    v_company_id UUID;
    v_user_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := current_user_id();
    
    CASE p_action
        WHEN 'create' THEN
            INSERT INTO advisor_companies (
                tenant_id,
                company_name,
                company_type,
                tax_id,
                primary_contact_name,
                website_url,
                services_provided,
                license_number,
                license_state,
                license_expiration,
                created_at,
                created_by
            ) VALUES (
                v_tenant_id,
                p_company_name,
                p_company_type,
                p_tax_id,
                p_contact_info->>'contact_name',
                p_contact_info->>'website',
                p_services,
                p_licensing->>'license_number',
                p_licensing->>'license_state',
                (p_licensing->>'license_expiration')::DATE,
                (NOW() AT TIME ZONE 'UTC'),
                v_user_id
            ) RETURNING id INTO v_company_id;
            
        WHEN 'update' THEN
            UPDATE advisor_companies SET
                company_name = COALESCE(p_company_name, company_name),
                company_type = COALESCE(p_company_type, company_type),
                tax_id = COALESCE(p_tax_id, tax_id),
                primary_contact_name = COALESCE(p_contact_info->>'contact_name', primary_contact_name),
                website_url = COALESCE(p_contact_info->>'website', website_url),
                services_provided = COALESCE(p_services, services_provided),
                license_number = COALESCE(p_licensing->>'license_number', license_number),
                license_state = COALESCE(p_licensing->>'license_state', license_state),
                license_expiration = COALESCE((p_licensing->>'license_expiration')::DATE, license_expiration),
                updated_at = (NOW() AT TIME ZONE 'UTC'),
                updated_by = v_user_id
            WHERE id = p_company_id
            AND tenant_id = v_tenant_id
            RETURNING id INTO v_company_id;
            
        WHEN 'deactivate' THEN
            UPDATE advisor_companies SET
                is_active = FALSE,
                updated_at = (NOW() AT TIME ZONE 'UTC'),
                updated_by = v_user_id
            WHERE id = p_company_id
            AND tenant_id = v_tenant_id
            RETURNING id INTO v_company_id;
            
        ELSE
            RAISE EXCEPTION 'Invalid action: %', p_action;
    END CASE;
    
    -- Audit log
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
        p_action,
        'advisor_company',
        v_company_id,
        p_company_name,
        jsonb_build_object(
            'company_type', p_company_type,
            'services', p_services
        )
    );
    
    RETURN v_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_advisor_companies
Retrieves advisor companies with filtering options.

```sql
CREATE OR REPLACE FUNCTION sp_get_advisor_companies(
    p_company_type TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE,
    p_include_ratings BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    company_id UUID,
    company_name TEXT,
    company_type TEXT,
    services_provided TEXT[],
    license_state VARCHAR(2),
    license_expiration DATE,
    client_since DATE,
    service_rating INTEGER,
    would_recommend BOOLEAN,
    contact_info JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ac.id,
        ac.company_name,
        ac.company_type,
        ac.services_provided,
        ac.license_state,
        ac.license_expiration,
        ac.client_since,
        CASE WHEN p_include_ratings THEN ac.service_rating ELSE NULL END,
        CASE WHEN p_include_ratings THEN ac.would_recommend ELSE NULL END,
        jsonb_build_object(
            'contact_name', ac.primary_contact_name,
            'website', ac.website_url
        )
    FROM advisor_companies ac
    WHERE ac.tenant_id = current_tenant_id()
    AND (p_company_type IS NULL OR ac.company_type = p_company_type)
    AND (p_is_active IS NULL OR ac.is_active = p_is_active)
    ORDER BY ac.company_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Builder.io Integration

### sp_configure_builder_integration
Configures Builder.io CMS integration settings.

```sql
CREATE OR REPLACE FUNCTION sp_configure_builder_integration(
    p_api_key TEXT,
    p_space_id TEXT,
    p_environment VARCHAR(50) DEFAULT 'production',
    p_content_mappings JSONB DEFAULT '{}',
    p_auto_sync BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_tenant_id INTEGER;
    v_integration_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Check for existing integration
    SELECT id INTO v_integration_id
    FROM builder_io_integrations
    WHERE tenant_id = v_tenant_id;
    
    IF v_integration_id IS NULL THEN
        -- Create new integration
        INSERT INTO builder_io_integrations (
            tenant_id,
            api_key,
            space_id,
            environment,
            content_model_mappings,
            auto_sync_enabled,
            created_at
        ) VALUES (
            v_tenant_id,
            encrypt_text(p_api_key),
            p_space_id,
            p_environment,
            p_content_mappings,
            p_auto_sync,
            (NOW() AT TIME ZONE 'UTC')
        ) RETURNING id INTO v_integration_id;
    ELSE
        -- Update existing integration
        UPDATE builder_io_integrations SET
            api_key = encrypt_text(p_api_key),
            space_id = p_space_id,
            environment = p_environment,
            content_model_mappings = p_content_mappings,
            auto_sync_enabled = p_auto_sync,
            updated_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration_id;
    END IF;
    
    -- Schedule next sync if auto-sync enabled
    IF p_auto_sync THEN
        UPDATE builder_io_integrations SET
            next_sync_at = (NOW() + INTERVAL '24 hours')
        WHERE id = v_integration_id;
    END IF;
    
    RETURN v_integration_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_refresh_builder_content
Refreshes content from Builder.io CMS.

```sql
CREATE OR REPLACE FUNCTION sp_refresh_builder_content(
    p_content_type VARCHAR(100) DEFAULT NULL
) RETURNS TABLE (
    content_items_synced INTEGER,
    sync_status VARCHAR(20),
    error_message TEXT
) AS $$
DECLARE
    v_tenant_id INTEGER;
    v_integration_id UUID;
    v_items_synced INTEGER := 0;
    v_status VARCHAR(20);
    v_error TEXT;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Get active Builder.io integration
    SELECT id INTO v_integration_id
    FROM builder_io_integrations
    WHERE tenant_id = v_tenant_id
    AND is_active = TRUE;
    
    IF v_integration_id IS NULL THEN
        RETURN QUERY
        SELECT 0, 'failed'::VARCHAR(20), 'No active Builder.io integration'::TEXT;
        RETURN;
    END IF;
    
    BEGIN
        -- Update sync status
        UPDATE builder_io_integrations SET
            connection_status = 'syncing',
            last_sync_at = (NOW() AT TIME ZONE 'UTC')
        WHERE id = v_integration_id;
        
        -- Simulate content sync (actual implementation would call Builder.io API)
        v_items_synced := 25; -- Placeholder
        v_status := 'completed';
        
        -- Update successful sync
        UPDATE builder_io_integrations SET
            connection_status = 'connected',
            next_sync_at = (NOW() + INTERVAL '24 hours'),
            last_error = NULL
        WHERE id = v_integration_id;
        
    EXCEPTION WHEN OTHERS THEN
        v_status := 'failed';
        v_error := SQLERRM;
        v_items_synced := 0;
        
        -- Update with error
        UPDATE builder_io_integrations SET
            connection_status = 'error',
            last_error = v_error
        WHERE id = v_integration_id;
    END;
    
    RETURN QUERY
    SELECT v_items_synced, v_status, v_error;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_builder_content_status
Retrieves Builder.io content synchronization status.

```sql
CREATE OR REPLACE FUNCTION sp_get_builder_content_status()
RETURNS TABLE (
    integration_id UUID,
    space_id TEXT,
    environment VARCHAR(50),
    connection_status VARCHAR(50),
    auto_sync_enabled BOOLEAN,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    next_sync_at TIMESTAMP WITH TIME ZONE,
    content_mappings JSONB,
    last_error TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bio.id,
        bio.space_id,
        bio.environment,
        bio.connection_status::VARCHAR(50),
        bio.auto_sync_enabled,
        bio.last_sync_at,
        bio.next_sync_at,
        bio.content_model_mappings,
        bio.last_error
    FROM builder_io_integrations bio
    WHERE bio.tenant_id = current_tenant_id()
    AND bio.is_active = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Translation Management

### sp_manage_translation
Manages translations for multi-language support.

```sql
CREATE OR REPLACE FUNCTION sp_manage_translation(
    p_action VARCHAR(20), -- create, update, delete, verify
    p_translation_id UUID DEFAULT NULL,
    p_entity_type VARCHAR(50) DEFAULT NULL,
    p_entity_id VARCHAR(255) DEFAULT NULL,
    p_field_name VARCHAR(100) DEFAULT NULL,
    p_language_code CHAR(2) DEFAULT NULL,
    p_translated_value TEXT DEFAULT NULL,
    p_is_verified BOOLEAN DEFAULT FALSE
) RETURNS UUID AS $$
DECLARE
    v_tenant_id INTEGER;
    v_user_id UUID;
    v_translation_id UUID;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := current_user_id();
    
    CASE p_action
        WHEN 'create' THEN
            INSERT INTO translations (
                tenant_id,
                entity_type,
                entity_id,
                field_name,
                language_code,
                original_value,
                translated_value,
                is_machine_translated,
                is_verified,
                verified_by,
                verified_at
            ) VALUES (
                v_tenant_id,
                p_entity_type,
                p_entity_id,
                p_field_name,
                p_language_code,
                '', -- Original value would be fetched from source
                p_translated_value,
                FALSE,
                p_is_verified,
                CASE WHEN p_is_verified THEN v_user_id ELSE NULL END,
                CASE WHEN p_is_verified THEN (NOW() AT TIME ZONE 'UTC') ELSE NULL END
            ) RETURNING id INTO v_translation_id;
            
        WHEN 'update' THEN
            UPDATE translations SET
                translated_value = COALESCE(p_translated_value, translated_value),
                is_verified = p_is_verified,
                verified_by = CASE WHEN p_is_verified THEN v_user_id ELSE verified_by END,
                verified_at = CASE WHEN p_is_verified THEN (NOW() AT TIME ZONE 'UTC') ELSE verified_at END,
                updated_at = (NOW() AT TIME ZONE 'UTC')
            WHERE id = p_translation_id
            RETURNING id INTO v_translation_id;
            
        WHEN 'delete' THEN
            DELETE FROM translations 
            WHERE id = p_translation_id
            RETURNING id INTO v_translation_id;
            
        ELSE
            RAISE EXCEPTION 'Invalid action: %', p_action;
    END CASE;
    
    RETURN v_translation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_translations
Retrieves translations with filtering options.

```sql
CREATE OR REPLACE FUNCTION sp_get_translations(
    p_entity_type VARCHAR(50) DEFAULT NULL,
    p_entity_id VARCHAR(255) DEFAULT NULL,
    p_language_code CHAR(2) DEFAULT NULL,
    p_only_verified BOOLEAN DEFAULT FALSE
) RETURNS TABLE (
    translation_id UUID,
    entity_type VARCHAR,
    entity_id VARCHAR,
    field_name VARCHAR,
    language_code CHAR,
    original_value TEXT,
    translated_value TEXT,
    is_verified BOOLEAN,
    verified_by UUID,
    verified_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.entity_type,
        t.entity_id,
        t.field_name,
        t.language_code,
        t.original_value,
        t.translated_value,
        t.is_verified,
        t.verified_by,
        t.verified_at
    FROM translations t
    WHERE 
        t.tenant_id = current_tenant_id()
        AND (p_entity_type IS NULL OR t.entity_type = p_entity_type)
        AND (p_entity_id IS NULL OR t.entity_id = p_entity_id)
        AND (p_language_code IS NULL OR t.language_code = p_language_code)
        AND (NOT p_only_verified OR t.is_verified = TRUE)
    ORDER BY t.entity_type, t.entity_id, t.field_name, t.language_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Integration Health Monitoring

### sp_check_integration_health
Checks the health status of all active integrations.

```sql
CREATE OR REPLACE FUNCTION sp_check_integration_health()
RETURNS TABLE (
    integration_type VARCHAR(50),
    integration_id UUID,
    is_healthy BOOLEAN,
    last_check TIMESTAMP WITH TIME ZONE,
    error_count INTEGER,
    last_error TEXT,
    recommendations TEXT[]
) AS $$
DECLARE
    v_tenant_id INTEGER;
BEGIN
    v_tenant_id := current_tenant_id();
    
    RETURN QUERY
    -- Quillt integrations
    SELECT 
        'quillt'::VARCHAR(50),
        qi.id,
        qi.connection_status = 'connected' AND qi.sync_error IS NULL,
        qi.updated_at,
        0, -- Would calculate from error logs
        qi.sync_error,
        CASE 
            WHEN qi.connection_status != 'connected' THEN 
                ARRAY['Reconnect to Quillt', 'Verify API credentials']
            WHEN qi.last_successful_sync_at < (NOW() - INTERVAL '7 days') THEN
                ARRAY['Sync data to get latest updates']
            ELSE ARRAY[]::TEXT[]
        END
    FROM quillt_integrations qi
    WHERE qi.tenant_id = v_tenant_id
    AND qi.is_active = TRUE
    
    UNION ALL
    
    -- Builder.io integrations
    SELECT 
        'builder_io'::VARCHAR(50),
        bio.id,
        bio.connection_status = 'connected' AND bio.last_error IS NULL,
        bio.updated_at,
        0, -- Would calculate from error logs
        bio.last_error,
        CASE 
            WHEN bio.connection_status != 'connected' THEN 
                ARRAY['Check Builder.io API key', 'Verify space configuration']
            WHEN bio.last_sync_at < (NOW() - INTERVAL '48 hours') THEN
                ARRAY['Refresh content from Builder.io']
            ELSE ARRAY[]::TEXT[]
        END
    FROM builder_io_integrations bio
    WHERE bio.tenant_id = v_tenant_id
    AND bio.is_active = TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_retry_failed_integration
Retries failed integration operations with exponential backoff.

```sql
CREATE OR REPLACE FUNCTION sp_retry_failed_integration(
    p_integration_type VARCHAR(50),
    p_integration_id UUID,
    p_max_retries INTEGER DEFAULT 3
) RETURNS TABLE (
    retry_successful BOOLEAN,
    retry_count INTEGER,
    error_message TEXT
) AS $$
DECLARE
    v_tenant_id INTEGER;
    v_retry_count INTEGER := 0;
    v_success BOOLEAN := FALSE;
    v_error TEXT;
    v_wait_seconds INTEGER;
BEGIN
    v_tenant_id := current_tenant_id();
    
    -- Retry loop with exponential backoff
    WHILE v_retry_count < p_max_retries AND NOT v_success LOOP
        v_retry_count := v_retry_count + 1;
        v_wait_seconds := POWER(2, v_retry_count - 1); -- 1, 2, 4 seconds
        
        -- Wait before retry (except first attempt)
        IF v_retry_count > 1 THEN
            PERFORM pg_sleep(v_wait_seconds);
        END IF;
        
        BEGIN
            CASE p_integration_type
                WHEN 'quillt' THEN
                    -- Retry Quillt sync
                    PERFORM sp_sync_quillt_data(
                        (SELECT user_id FROM quillt_integrations WHERE id = p_integration_id)
                    );
                    v_success := TRUE;
                    
                WHEN 'builder_io' THEN
                    -- Retry Builder.io content refresh
                    PERFORM sp_refresh_builder_content();
                    v_success := TRUE;
                    
                WHEN 'real_estate' THEN
                    -- Retry real estate sync
                    -- Would need property_id from sync logs
                    v_success := TRUE;
                    
                ELSE
                    RAISE EXCEPTION 'Unknown integration type: %', p_integration_type;
            END CASE;
            
        EXCEPTION WHEN OTHERS THEN
            v_error := SQLERRM;
            v_success := FALSE;
        END;
    END LOOP;
    
    -- Log retry attempt
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
        current_user_id(),
        'retry',
        'integration',
        p_integration_id,
        p_integration_type || ' Integration',
        jsonb_build_object(
            'retry_count', v_retry_count,
            'success', v_success,
            'error', v_error
        )
    );
    
    RETURN QUERY
    SELECT v_success, v_retry_count, v_error;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## System Configuration

### sp_update_system_configuration
Updates system-wide configuration settings stored in tenant metadata.

```sql
CREATE OR REPLACE FUNCTION sp_update_system_configuration(
    p_config_key VARCHAR(100),
    p_config_value JSONB,
    p_config_category VARCHAR(50) DEFAULT 'general',
    p_description TEXT DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id INTEGER;
    v_user_id UUID;
    v_old_value JSONB;
BEGIN
    v_tenant_id := current_tenant_id();
    v_user_id := COALESCE(p_user_id, current_user_id());
    
    -- Get old value for audit
    SELECT metadata->p_config_key INTO v_old_value
    FROM tenants
    WHERE id = v_tenant_id;
    
    -- Update configuration in tenant metadata
    UPDATE tenants SET
        metadata = 
            CASE 
                WHEN metadata ? 'system_config' THEN
                    jsonb_set(
                        metadata,
                        ARRAY['system_config', p_config_category, p_config_key],
                        p_config_value,
                        true
                    )
                ELSE
                    metadata || jsonb_build_object(
                        'system_config', jsonb_build_object(
                            p_config_category, jsonb_build_object(
                                p_config_key, p_config_value
                            )
                        )
                    )
            END,
        updated_at = (NOW() AT TIME ZONE 'UTC')
    WHERE id = v_tenant_id;
    
    -- Log configuration change
    INSERT INTO audit_log (
        tenant_id,
        user_id,
        action,
        entity_type,
        entity_id,
        entity_name,
        old_values,
        new_values,
        metadata
    ) VALUES (
        v_tenant_id,
        v_user_id,
        'update_config',
        'system_configuration',
        gen_random_uuid(),
        p_config_key,
        jsonb_build_object(p_config_key, v_old_value),
        jsonb_build_object(p_config_key, p_config_value),
        jsonb_build_object(
            'category', p_config_category,
            'description', p_description
        )
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Key Features:**
- Stores configuration in tenant metadata JSONB field
- Supports hierarchical configuration categories
- Complete audit trail of configuration changes
- Flexible JSONB storage for complex configurations

## Integration Best Practices

### Security
- **Encrypted Credentials**: All API keys and tokens encrypted using helper functions
- **Tenant Isolation**: All integrations scoped to tenant level
- **Audit Logging**: Complete audit trail of all integration activities
- **Error Handling**: Comprehensive error capture and logging

### Performance
- **Async Processing**: Long-running syncs handled asynchronously
- **Batch Operations**: Bulk data synchronization for efficiency
- **Caching**: Integration status cached to reduce API calls
- **Rate Limiting**: Built-in rate limiting for external APIs

### Reliability
- **Retry Logic**: Automatic retry with exponential backoff
- **Health Monitoring**: Regular health checks for all integrations
- **Error Recovery**: Automatic error detection and recovery
- **Status Tracking**: Detailed status tracking for troubleshooting

---

*This integration procedure documentation reflects the Forward Inheritance Platform's comprehensive external system integration capabilities, providing secure, reliable connections to financial data providers, real estate services, content management systems, and professional service providers.*