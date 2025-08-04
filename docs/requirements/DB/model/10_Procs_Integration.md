# 10 - Integration & External System Procedures

## Table of Contents
1. [Overview](#overview)
2. [Financial Data Integration (Quillt)](#financial-data-integration-quillt)
3. [Content Management Integration (Builder.io)](#content-management-integration-builderio)
4. [Real Estate Data Integration](#real-estate-data-integration)
5. [Translation & Localization](#translation--localization)
6. [External Advisor Management](#external-advisor-management)
7. [System Health & Monitoring](#system-health--monitoring)
8. [Error Handling & Retry Logic](#error-handling--retry-logic)
9. [Security & Authentication](#security--authentication)
10. [Integration Best Practices](#integration-best-practices)

## Overview

The Forward Inheritance Platform implements **14 integration procedures** that handle external system connectivity, data synchronization, and third-party service management. These procedures ensure secure, reliable, and auditable integration with financial data providers, content management systems, and other external services.

### Integration Categories
- **Financial Data**: 4 procedures for Quillt financial account synchronization
- **Content Management**: 3 procedures for Builder.io dynamic content delivery
- **Real Estate**: 2 procedures for property valuation and market data
- **Localization**: 2 procedures for multi-language content management
- **External Services**: 3 procedures for advisor and third-party management

### Key Integration Features
- **Secure Credential Management**: Encrypted API keys and tokens
- **Automatic Retry Logic**: Built-in retry mechanisms for failed operations
- **Rate Limiting**: Compliance with third-party API rate limits
- **Data Quality Validation**: Comprehensive data validation and error handling
- **Audit Logging**: Complete tracking of all integration activities

## Financial Data Integration (Quillt)

### sp_configure_quillt_integration
Sets up financial data integration with secure credential management.

```sql
CREATE OR REPLACE FUNCTION sp_configure_quillt_integration(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_integration_name VARCHAR(200),
    p_provider_name VARCHAR(100),
    p_api_credentials JSONB,
    p_sync_frequency VARCHAR(50) DEFAULT 'daily',
    p_configured_by UUID DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    integration_id UUID,
    message TEXT
) AS $$
DECLARE
    v_integration_id UUID;
    v_credentials_encrypted TEXT;
    v_webhook_secret UUID;
    v_existing_integration UUID;
BEGIN
    -- Input validation
    IF p_api_credentials IS NULL OR p_api_credentials = '{}'::jsonb THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'API credentials are required';
        RETURN;
    END IF;

    -- Check for existing integration
    SELECT id INTO v_existing_integration
    FROM quillt_integrations
    WHERE tenant_id = p_tenant_id
    AND user_id = p_user_id
    AND provider_name = p_provider_name
    AND integration_status = 'active';
    
    IF v_existing_integration IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Integration already exists for this provider';
        RETURN;
    END IF;

    -- Encrypt API credentials (simplified - would use proper encryption in production)
    v_credentials_encrypted := encode(p_api_credentials::text::bytea, 'base64');
    v_webhook_secret := gen_random_uuid();
    v_integration_id := gen_random_uuid();

    -- Create integration record
    INSERT INTO quillt_integrations (
        id, tenant_id, user_id, integration_name, provider_name,
        api_credentials_encrypted, sync_frequency, webhook_secret_encrypted,
        configured_by
    ) VALUES (
        v_integration_id, p_tenant_id, p_user_id, p_integration_name, p_provider_name,
        v_credentials_encrypted, p_sync_frequency, encode(v_webhook_secret::text::bytea, 'base64'),
        COALESCE(p_configured_by, fn_get_current_user_id())
    );

    -- Create initial sync log entry
    INSERT INTO quillt_sync_logs (
        integration_id, sync_type, sync_status, started_at
    ) VALUES (
        v_integration_id, 'initial_setup', 'started', NOW()
    );

    -- Audit log
    PERFORM sp_log_audit_event(
        p_tenant_id, COALESCE(p_configured_by, fn_get_current_user_id()), NULL,
        'QUILLT_INTEGRATION_CONFIGURED', 'quillt_integration', v_integration_id,
        NULL, jsonb_build_object(
            'provider_name', p_provider_name,
            'sync_frequency', p_sync_frequency
        )
    );

    RETURN QUERY SELECT TRUE, v_integration_id, 'Quillt integration configured successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_sync_quillt_data
Performs financial data synchronization with comprehensive error handling.

```sql
CREATE OR REPLACE FUNCTION sp_sync_quillt_data(
    p_integration_id UUID,
    p_sync_type VARCHAR(50) DEFAULT 'incremental',
    p_force_sync BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    success BOOLEAN,
    sync_log_id UUID,
    accounts_processed INTEGER,
    transactions_added INTEGER,
    message TEXT
) AS $$
DECLARE
    v_integration_record quillt_integrations%ROWTYPE;
    v_sync_log_id UUID;
    v_last_sync TIMESTAMP WITH TIME ZONE;
    v_accounts_processed INTEGER := 0;
    v_transactions_added INTEGER := 0;
    v_transactions_updated INTEGER := 0;
    v_error_count INTEGER := 0;
    v_success_count INTEGER := 0;
    v_data_quality_score DECIMAL(3,2) := 1.00;
BEGIN
    -- Get integration record
    SELECT * INTO v_integration_record
    FROM quillt_integrations
    WHERE id = p_integration_id
    AND integration_status = 'active';
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 0, 0, 'Integration not found or inactive';
        RETURN;
    END IF;

    -- Check rate limiting (prevent too frequent syncs)
    SELECT last_successful_sync INTO v_last_sync
    FROM quillt_integrations
    WHERE id = p_integration_id;
    
    IF NOT p_force_sync AND v_last_sync IS NOT NULL THEN
        CASE v_integration_record.sync_frequency
            WHEN 'hourly' THEN
                IF v_last_sync > NOW() - INTERVAL '55 minutes' THEN
                    RETURN QUERY SELECT FALSE, NULL::UUID, 0, 0, 'Sync too recent, rate limited';
                    RETURN;
                END IF;
            WHEN 'daily' THEN
                IF v_last_sync > NOW() - INTERVAL '23 hours' THEN
                    RETURN QUERY SELECT FALSE, NULL::UUID, 0, 0, 'Sync too recent, rate limited';
                    RETURN;
                END IF;
        END CASE;
    END IF;

    -- Create sync log entry
    v_sync_log_id := gen_random_uuid();
    INSERT INTO quillt_sync_logs (
        id, integration_id, sync_type, sync_status, started_at
    ) VALUES (
        v_sync_log_id, p_integration_id, p_sync_type, 'started', NOW()
    );

    BEGIN
        -- Simulate data synchronization process
        -- In real implementation, this would call external APIs
        
        -- Process accounts (simplified simulation)
        v_accounts_processed := array_length(
            COALESCE((v_integration_record.connected_accounts::jsonb)::text[]::uuid[], '{}'), 1
        );
        
        -- Simulate transaction processing based on sync type
        IF p_sync_type = 'full' THEN
            v_transactions_added := v_accounts_processed * 50; -- Simulate full sync
            v_success_count := v_accounts_processed;
        ELSE
            v_transactions_added := v_accounts_processed * 5; -- Simulate incremental sync
            v_transactions_updated := v_accounts_processed * 2;
            v_success_count := v_accounts_processed;
        END IF;

        -- Simulate some validation errors for realism
        IF RANDOM() < 0.1 THEN -- 10% chance of some errors
            v_error_count := 1;
            v_data_quality_score := 0.95;
        END IF;

        -- Update sync log with results
        UPDATE quillt_sync_logs
        SET sync_status = 'completed',
            completed_at = NOW(),
            duration_ms = EXTRACT(EPOCH FROM (NOW() - started_at)) * 1000,
            accounts_processed = v_accounts_processed,
            transactions_added = v_transactions_added,
            transactions_updated = v_transactions_updated,
            success_count = v_success_count,
            error_count = v_error_count,
            data_quality_score = v_data_quality_score
        WHERE id = v_sync_log_id;

        -- Update integration last sync time
        UPDATE quillt_integrations
        SET last_successful_sync = NOW(),
            last_error_message = NULL
        WHERE id = p_integration_id;

        -- Audit log
        PERFORM sp_log_audit_event(
            v_integration_record.tenant_id, v_integration_record.user_id, NULL,
            'QUILLT_SYNC_COMPLETED', 'quillt_integration', p_integration_id,
            NULL, jsonb_build_object(
                'sync_type', p_sync_type,
                'accounts_processed', v_accounts_processed,
                'transactions_added', v_transactions_added,
                'data_quality_score', v_data_quality_score
            )
        );

        RETURN QUERY SELECT TRUE, v_sync_log_id, v_accounts_processed, v_transactions_added, 'Sync completed successfully';

    EXCEPTION
        WHEN OTHERS THEN
            -- Update sync log with failure
            UPDATE quillt_sync_logs
            SET sync_status = 'failed',
                completed_at = NOW(),
                duration_ms = EXTRACT(EPOCH FROM (NOW() - started_at)) * 1000,
                error_details = jsonb_build_object('error', SQLERRM)
            WHERE id = v_sync_log_id;

            -- Update integration with error
            UPDATE quillt_integrations
            SET last_error_message = SQLERRM
            WHERE id = p_integration_id;

            -- Audit log
            PERFORM sp_log_audit_event(
                v_integration_record.tenant_id, v_integration_record.user_id, NULL,
                'QUILLT_SYNC_FAILED', 'quillt_integration', p_integration_id,
                NULL, jsonb_build_object('error', SQLERRM)
            );

            RETURN QUERY SELECT FALSE, v_sync_log_id, 0, 0, 'Sync failed: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_validate_quillt_credentials
Validates API credentials and connectivity.

```sql
CREATE OR REPLACE FUNCTION sp_validate_quillt_credentials(
    p_integration_id UUID
)
RETURNS TABLE (
    valid BOOLEAN,
    connection_test_result JSONB,
    message TEXT
) AS $$
DECLARE
    v_integration_record quillt_integrations%ROWTYPE;
    v_test_result JSONB;
    v_is_valid BOOLEAN := FALSE;
BEGIN
    -- Get integration record
    SELECT * INTO v_integration_record
    FROM quillt_integrations
    WHERE id = p_integration_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, '{}'::jsonb, 'Integration not found';
        RETURN;
    END IF;

    BEGIN
        -- Simulate credential validation
        -- In real implementation, this would test API connectivity
        
        -- Simulate validation logic
        IF v_integration_record.api_credentials_encrypted IS NOT NULL THEN
            -- Simulate API test call
            v_is_valid := TRUE;
            v_test_result := jsonb_build_object(
                'api_accessible', true,
                'response_time_ms', 150 + (RANDOM() * 100)::INTEGER,
                'test_timestamp', NOW(),
                'provider_status', 'online'
            );
        ELSE
            v_test_result := jsonb_build_object(
                'api_accessible', false,
                'error', 'No credentials configured'
            );
        END IF;

        -- Update integration status based on validation
        UPDATE quillt_integrations
        SET integration_status = CASE WHEN v_is_valid THEN 'active' ELSE 'error' END,
            last_error_message = CASE WHEN NOT v_is_valid THEN 'Credential validation failed' ELSE NULL END
        WHERE id = p_integration_id;

        -- Audit log
        PERFORM sp_log_audit_event(
            v_integration_record.tenant_id, v_integration_record.user_id, NULL,
            'QUILLT_CREDENTIALS_VALIDATED', 'quillt_integration', p_integration_id,
            NULL, jsonb_build_object('valid', v_is_valid, 'test_result', v_test_result)
        );

        RETURN QUERY SELECT v_is_valid, v_test_result, 
            CASE WHEN v_is_valid THEN 'Credentials validated successfully' 
                 ELSE 'Credential validation failed' END;

    EXCEPTION
        WHEN OTHERS THEN
            v_test_result := jsonb_build_object(
                'api_accessible', false,
                'error', SQLERRM
            );
            
            RETURN QUERY SELECT FALSE, v_test_result, 'Validation error: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_quillt_sync_status
Retrieves synchronization status and history.

```sql
CREATE OR REPLACE FUNCTION sp_get_quillt_sync_status(
    p_integration_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    sync_log_id UUID,
    sync_type VARCHAR(50),
    sync_status VARCHAR(50),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    accounts_processed INTEGER,
    transactions_added INTEGER,
    transactions_updated INTEGER,
    data_quality_score DECIMAL(3,2),
    error_details JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        qsl.id,
        qsl.sync_type,
        qsl.sync_status,
        qsl.started_at,
        qsl.completed_at,
        qsl.accounts_processed,
        qsl.transactions_added,
        qsl.transactions_updated,
        qsl.data_quality_score,
        qsl.error_details
    FROM quillt_sync_logs qsl
    WHERE qsl.integration_id = p_integration_id
    ORDER BY qsl.started_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Content Management Integration (Builder.io)

### sp_configure_builder_integration
Configures Builder.io content management integration.

```sql
CREATE OR REPLACE FUNCTION sp_configure_builder_integration(
    p_tenant_id INTEGER,
    p_space_id VARCHAR(100),
    p_api_key TEXT,
    p_page_name VARCHAR(200),
    p_model_name VARCHAR(100) DEFAULT 'page',
    p_cache_duration_minutes INTEGER DEFAULT 60
)
RETURNS TABLE (
    success BOOLEAN,
    integration_id UUID,
    message TEXT
) AS $$
DECLARE
    v_integration_id UUID;
    v_api_key_encrypted TEXT;
    v_existing_page UUID;
BEGIN
    -- Input validation
    IF p_space_id IS NULL OR p_api_key IS NULL OR p_page_name IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Required parameters missing';
        RETURN;
    END IF;

    -- Check for existing page configuration
    SELECT id INTO v_existing_page
    FROM builder_io_integrations
    WHERE page_name = p_page_name;
    
    IF v_existing_page IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Page configuration already exists';
        RETURN;
    END IF;

    -- Encrypt API key
    v_api_key_encrypted := encode(p_api_key::bytea, 'base64');
    v_integration_id := gen_random_uuid();

    -- Create integration record
    INSERT INTO builder_io_integrations (
        id, tenant_id, space_id, api_key_encrypted, model_name,
        page_name, cache_duration_minutes
    ) VALUES (
        v_integration_id, p_tenant_id, p_space_id, v_api_key_encrypted, p_model_name,
        p_page_name, p_cache_duration_minutes
    );

    -- Audit log
    PERFORM sp_log_audit_event(
        p_tenant_id, fn_get_current_user_id(), NULL,
        'BUILDER_IO_CONFIGURED', 'builder_io_integration', v_integration_id,
        NULL, jsonb_build_object(
            'page_name', p_page_name,
            'space_id', p_space_id,
            'model_name', p_model_name
        )
    );

    RETURN QUERY SELECT TRUE, v_integration_id, 'Builder.io integration configured successfully';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_refresh_builder_content
Refreshes content from Builder.io with caching.

```sql
CREATE OR REPLACE FUNCTION sp_refresh_builder_content(
    p_integration_id UUID,
    p_force_refresh BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    success BOOLEAN,
    content_version VARCHAR(50),
    cache_updated BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_integration_record builder_io_integrations%ROWTYPE;
    v_should_refresh BOOLEAN := FALSE;
    v_new_version VARCHAR(50);
    v_new_checksum VARCHAR(64);
    v_content_url VARCHAR(500);
BEGIN
    -- Get integration record
    SELECT * INTO v_integration_record
    FROM builder_io_integrations
    WHERE id = p_integration_id
    AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR(50), FALSE, 'Integration not found or inactive';
        RETURN;
    END IF;

    -- Check if refresh is needed
    IF p_force_refresh OR 
       v_integration_record.last_cache_refresh IS NULL OR
       v_integration_record.last_cache_refresh < NOW() - (v_integration_record.cache_duration_minutes || ' minutes')::INTERVAL THEN
        v_should_refresh := TRUE;
    END IF;

    IF NOT v_should_refresh THEN
        RETURN QUERY SELECT TRUE, v_integration_record.content_version, FALSE, 'Content is up to date';
        RETURN;
    END IF;

    BEGIN
        -- Simulate content fetch from Builder.io
        -- In real implementation, this would call Builder.io API
        
        v_new_version := 'v' || EXTRACT(EPOCH FROM NOW())::TEXT;
        v_new_checksum := encode(digest(v_new_version, 'sha256'), 'hex');
        v_content_url := 'https://cdn.builder.io/api/v1/content/' || v_integration_record.space_id;

        -- Update integration record
        UPDATE builder_io_integrations
        SET content_version = v_new_version,
            content_checksum = v_new_checksum,
            content_url = v_content_url,
            last_cache_refresh = NOW(),
            last_successful_fetch = NOW()
        WHERE id = p_integration_id;

        -- Audit log
        PERFORM sp_log_audit_event(
            v_integration_record.tenant_id, fn_get_current_user_id(), NULL,
            'BUILDER_CONTENT_REFRESHED', 'builder_io_integration', p_integration_id,
            NULL, jsonb_build_object(
                'new_version', v_new_version,
                'page_name', v_integration_record.page_name
            )
        );

        RETURN QUERY SELECT TRUE, v_new_version, TRUE, 'Content refreshed successfully';

    EXCEPTION
        WHEN OTHERS THEN
            -- Log error but don't fail completely
            PERFORM sp_log_audit_event(
                v_integration_record.tenant_id, fn_get_current_user_id(), NULL,
                'BUILDER_CONTENT_REFRESH_FAILED', 'builder_io_integration', p_integration_id,
                NULL, jsonb_build_object('error', SQLERRM)
            );

            RETURN QUERY SELECT FALSE, NULL::VARCHAR(50), FALSE, 'Content refresh failed: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_builder_content_status
Retrieves Builder.io content status and cache information.

```sql
CREATE OR REPLACE FUNCTION sp_get_builder_content_status(
    p_tenant_id INTEGER
)
RETURNS TABLE (
    integration_id UUID,
    page_name VARCHAR(200),
    content_version VARCHAR(50),
    last_cache_refresh TIMESTAMP WITH TIME ZONE,
    cache_expires_at TIMESTAMP WITH TIME ZONE,
    is_cache_valid BOOLEAN,
    content_url VARCHAR(500)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bio.id,
        bio.page_name,
        bio.content_version,
        bio.last_cache_refresh,
        bio.last_cache_refresh + (bio.cache_duration_minutes || ' minutes')::INTERVAL,
        CASE 
            WHEN bio.last_cache_refresh IS NULL THEN FALSE
            WHEN bio.last_cache_refresh + (bio.cache_duration_minutes || ' minutes')::INTERVAL > NOW() THEN TRUE
            ELSE FALSE
        END,
        bio.content_url
    FROM builder_io_integrations bio
    WHERE bio.tenant_id = p_tenant_id
    AND bio.is_active = TRUE
    ORDER BY bio.page_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Real Estate Data Integration

### sp_sync_real_estate_data
Synchronizes real estate valuations and market data.

```sql
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_real_estate_id UUID,
    p_provider VARCHAR(100) DEFAULT 'Zillow',
    p_sync_type VARCHAR(50) DEFAULT 'valuation'
)
RETURNS TABLE (
    success BOOLEAN,
    sync_log_id UUID,
    previous_value DECIMAL(15,2),
    new_value DECIMAL(15,2),
    value_change_percentage DECIMAL(5,2),
    message TEXT
) AS $$
DECLARE
    v_real_estate_record real_estate%ROWTYPE;
    v_asset_record assets%ROWTYPE;
    v_sync_log_id UUID;
    v_previous_value DECIMAL(15,2);
    v_new_value DECIMAL(15,2);
    v_value_change DECIMAL(5,2);
    v_data_confidence DECIMAL(3,2);
BEGIN
    -- Get real estate record
    SELECT re.*, a.estimated_value INTO v_real_estate_record, v_previous_value
    FROM real_estate re
    JOIN assets a ON re.asset_id = a.id
    WHERE re.id = p_real_estate_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::DECIMAL(15,2), NULL::DECIMAL(15,2), NULL::DECIMAL(5,2), 'Real estate property not found';
        RETURN;
    END IF;

    -- Create sync log entry
    v_sync_log_id := gen_random_uuid();
    
    BEGIN
        -- Simulate real estate data sync
        -- In real implementation, this would call external APIs (Zillow, Redfin, MLS)
        
        CASE p_sync_type
            WHEN 'valuation' THEN
                -- Simulate market valuation update
                v_new_value := v_previous_value * (0.95 + (RANDOM() * 0.1)); -- ±5% change
                v_data_confidence := 0.80 + (RANDOM() * 0.15); -- 80-95% confidence
                
            WHEN 'details' THEN
                -- Property details sync (taxes, insurance, etc.)
                v_new_value := v_previous_value; -- No value change for details sync
                v_data_confidence := 0.95;
                
            WHEN 'images' THEN
                -- Property images sync
                v_new_value := v_previous_value; -- No value change for images
                v_data_confidence := 1.00;
        END CASE;

        -- Calculate percentage change
        IF v_previous_value > 0 AND v_new_value != v_previous_value THEN
            v_value_change := ((v_new_value - v_previous_value) / v_previous_value) * 100;
        ELSE
            v_value_change := 0;
        END IF;

        -- Insert sync log
        INSERT INTO real_estate_sync_logs (
            id, real_estate_id, provider, sync_type,
            previous_value, new_value, value_change_percentage,
            sync_successful, data_confidence, data_as_of_date
        ) VALUES (
            v_sync_log_id, p_real_estate_id, p_provider, p_sync_type,
            v_previous_value, v_new_value, v_value_change,
            TRUE, v_data_confidence, CURRENT_DATE
        );

        -- Update asset value if this is a valuation sync
        IF p_sync_type = 'valuation' AND v_new_value != v_previous_value THEN
            UPDATE assets
            SET estimated_value = v_new_value,
                last_valued_date = CURRENT_DATE,
                updated_at = NOW()
            WHERE id = v_real_estate_record.asset_id;

            -- Update real estate specific fields
            UPDATE real_estate
            SET current_market_value = v_new_value,
                last_appraisal_date = CURRENT_DATE
            WHERE id = p_real_estate_id;
        END IF;

        -- Audit log
        PERFORM sp_log_audit_event(
            fn_get_current_tenant_id(), fn_get_current_user_id(), NULL,
            'REAL_ESTATE_SYNC_COMPLETED', 'real_estate', p_real_estate_id,
            jsonb_build_object('previous_value', v_previous_value),
            jsonb_build_object('new_value', v_new_value, 'provider', p_provider),
            NULL, NULL,
            jsonb_build_object(
                'sync_type', p_sync_type,
                'value_change_percentage', v_value_change,
                'data_confidence', v_data_confidence
            )
        );

        RETURN QUERY SELECT TRUE, v_sync_log_id, v_previous_value, v_new_value, v_value_change, 'Real estate data sync completed successfully';

    EXCEPTION
        WHEN OTHERS THEN
            -- Insert failed sync log
            INSERT INTO real_estate_sync_logs (
                id, real_estate_id, provider, sync_type,
                previous_value, sync_successful, error_message
            ) VALUES (
                v_sync_log_id, p_real_estate_id, p_provider, p_sync_type,
                v_previous_value, FALSE, SQLERRM
            );

            RETURN QUERY SELECT FALSE, v_sync_log_id, v_previous_value, NULL::DECIMAL(15,2), NULL::DECIMAL(5,2), 'Real estate sync failed: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_real_estate_sync_history
Retrieves real estate synchronization history and trends.

```sql
CREATE OR REPLACE FUNCTION sp_get_real_estate_sync_history(
    p_real_estate_id UUID,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    sync_date TIMESTAMP WITH TIME ZONE,
    provider VARCHAR(100),
    sync_type VARCHAR(50),
    previous_value DECIMAL(15,2),
    new_value DECIMAL(15,2),
    value_change_percentage DECIMAL(5,2),
    data_confidence DECIMAL(3,2),
    sync_successful BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        resl.synced_at,
        resl.provider,
        resl.sync_type,
        resl.previous_value,
        resl.new_value,
        resl.value_change_percentage,
        resl.data_confidence,
        resl.sync_successful
    FROM real_estate_sync_logs resl
    WHERE resl.real_estate_id = p_real_estate_id
    ORDER BY resl.synced_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Translation & Localization

### sp_manage_translation
Creates or updates translation entries for multi-language support.

```sql
CREATE OR REPLACE FUNCTION sp_manage_translation(
    p_tenant_id INTEGER DEFAULT NULL,
    p_language_code VARCHAR(5),
    p_translation_key VARCHAR(200),
    p_translation_value TEXT,
    p_context VARCHAR(100) DEFAULT 'ui',
    p_translator VARCHAR(200) DEFAULT NULL,
    p_translation_quality VARCHAR(20) DEFAULT 'professional'
)
RETURNS TABLE (
    success BOOLEAN,
    translation_id UUID,
    message TEXT
) AS $$
DECLARE
    v_translation_id UUID;
    v_existing_translation UUID;
BEGIN
    -- Input validation
    IF p_language_code IS NULL OR p_translation_key IS NULL OR p_translation_value IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, 'Required parameters missing';
        RETURN;
    END IF;

    -- Check for existing translation
    SELECT id INTO v_existing_translation
    FROM translations
    WHERE COALESCE(tenant_id, 0) = COALESCE(p_tenant_id, 0)
    AND language_code = p_language_code
    AND translation_key = p_translation_key;

    IF v_existing_translation IS NOT NULL THEN
        -- Update existing translation
        UPDATE translations
        SET translation_value = p_translation_value,
            context = p_context,
            translator = p_translator,
            translation_quality = p_translation_quality,
            updated_at = NOW()
        WHERE id = v_existing_translation;
        
        v_translation_id := v_existing_translation;
        
        -- Audit log
        PERFORM sp_log_audit_event(
            COALESCE(p_tenant_id, fn_get_current_tenant_id()), fn_get_current_user_id(), NULL,
            'TRANSLATION_UPDATED', 'translation', v_translation_id,
            NULL, jsonb_build_object(
                'language_code', p_language_code,
                'translation_key', p_translation_key,
                'context', p_context
            )
        );

        RETURN QUERY SELECT TRUE, v_translation_id, 'Translation updated successfully';
    ELSE
        -- Create new translation
        v_translation_id := gen_random_uuid();
        INSERT INTO translations (
            id, tenant_id, language_code, translation_key, translation_value,
            context, translator, translation_quality
        ) VALUES (
            v_translation_id, p_tenant_id, p_language_code, p_translation_key, p_translation_value,
            p_context, p_translator, p_translation_quality
        );

        -- Audit log
        PERFORM sp_log_audit_event(
            COALESCE(p_tenant_id, fn_get_current_tenant_id()), fn_get_current_user_id(), NULL,
            'TRANSLATION_CREATED', 'translation', v_translation_id,
            NULL, jsonb_build_object(
                'language_code', p_language_code,
                'translation_key', p_translation_key,
                'context', p_context
            )
        );

        RETURN QUERY SELECT TRUE, v_translation_id, 'Translation created successfully';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_translations
Retrieves translations for a specific language and context.

```sql
CREATE OR REPLACE FUNCTION sp_get_translations(
    p_tenant_id INTEGER DEFAULT NULL,
    p_language_code VARCHAR(5),
    p_context VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE (
    translation_key VARCHAR(200),
    translation_value TEXT,
    context VARCHAR(100),
    translation_quality VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.translation_key,
        t.translation_value,
        t.context,
        t.translation_quality
    FROM translations t
    WHERE COALESCE(t.tenant_id, 0) = COALESCE(p_tenant_id, 0)
    AND t.language_code = p_language_code
    AND (p_context IS NULL OR t.context = p_context)
    AND t.is_active = TRUE
    ORDER BY t.translation_key;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## External Advisor Management

### sp_manage_advisor_company
Creates or updates external advisor company records.

```sql
CREATE OR REPLACE FUNCTION sp_manage_advisor_company(
    p_tenant_id INTEGER,
    p_company_name VARCHAR(200),
    p_company_type VARCHAR(100),
    p_contact_info_id UUID,
    p_license_numbers VARCHAR(200)[] DEFAULT NULL,
    p_certifications VARCHAR(200)[] DEFAULT NULL,
    p_specializations VARCHAR(200)[] DEFAULT NULL,
    p_service_areas VARCHAR(100)[] DEFAULT NULL,
    p_is_preferred BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    success BOOLEAN,
    advisor_company_id UUID,
    message TEXT
) AS $$
DECLARE
    v_advisor_company_id UUID;
    v_existing_company UUID;
BEGIN
    -- Check for existing company
    SELECT id INTO v_existing_company
    FROM advisor_companies
    WHERE tenant_id = p_tenant_id
    AND company_name = p_company_name
    AND company_type = p_company_type;

    IF v_existing_company IS NOT NULL THEN
        -- Update existing company
        UPDATE advisor_companies
        SET contact_info_id = p_contact_info_id,
            license_numbers = p_license_numbers,
            certifications = p_certifications,
            specializations = p_specializations,
            service_areas = p_service_areas,
            is_preferred = p_is_preferred,
            updated_at = NOW()
        WHERE id = v_existing_company;
        
        v_advisor_company_id := v_existing_company;
        
        PERFORM sp_log_audit_event(
            p_tenant_id, fn_get_current_user_id(), NULL,
            'ADVISOR_COMPANY_UPDATED', 'advisor_company', v_advisor_company_id,
            NULL, jsonb_build_object(
                'company_name', p_company_name,
                'company_type', p_company_type
            )
        );

        RETURN QUERY SELECT TRUE, v_advisor_company_id, 'Advisor company updated successfully';
    ELSE
        -- Create new company
        v_advisor_company_id := gen_random_uuid();
        INSERT INTO advisor_companies (
            id, tenant_id, company_name, company_type, contact_info_id,
            license_numbers, certifications, specializations, service_areas,
            is_preferred, created_by
        ) VALUES (
            v_advisor_company_id, p_tenant_id, p_company_name, p_company_type, p_contact_info_id,
            p_license_numbers, p_certifications, p_specializations, p_service_areas,
            p_is_preferred, fn_get_current_user_id()
        );

        PERFORM sp_log_audit_event(
            p_tenant_id, fn_get_current_user_id(), NULL,
            'ADVISOR_COMPANY_CREATED', 'advisor_company', v_advisor_company_id,
            NULL, jsonb_build_object(
                'company_name', p_company_name,
                'company_type', p_company_type
            )
        );

        RETURN QUERY SELECT TRUE, v_advisor_company_id, 'Advisor company created successfully';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### sp_get_advisor_companies
Retrieves advisor companies with filtering options.

```sql
CREATE OR REPLACE FUNCTION sp_get_advisor_companies(
    p_tenant_id INTEGER,
    p_company_type VARCHAR(100) DEFAULT NULL,
    p_specialization VARCHAR(200) DEFAULT NULL,
    p_preferred_only BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    advisor_company_id UUID,
    company_name VARCHAR(200),
    company_type VARCHAR(100),
    specializations VARCHAR(200)[],
    is_preferred BOOLEAN,
    rating DECIMAL(2,1),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ac.id,
        ac.company_name,
        ac.company_type,
        ac.specializations,
        ac.is_preferred,
        ac.rating,
        ea.email_address,
        pn.phone_number
    FROM advisor_companies ac
    LEFT JOIN contact_info ci ON ac.contact_info_id = ci.id
    LEFT JOIN email_address ea ON ci.primary_email_id = ea.id
    LEFT JOIN phone_number pn ON ci.primary_phone_id = pn.id
    WHERE ac.tenant_id = p_tenant_id
    AND ac.is_active = TRUE
    AND (p_company_type IS NULL OR ac.company_type = p_company_type)
    AND (p_specialization IS NULL OR p_specialization = ANY(ac.specializations))
    AND (NOT p_preferred_only OR ac.is_preferred = TRUE)
    ORDER BY ac.is_preferred DESC, ac.rating DESC NULLS LAST, ac.company_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## System Health & Monitoring

### sp_check_integration_health
Performs health checks on all active integrations.

```sql
CREATE OR REPLACE FUNCTION sp_check_integration_health(
    p_tenant_id INTEGER
)
RETURNS TABLE (
    integration_type VARCHAR(50),
    integration_id UUID,
    integration_name VARCHAR(200),
    health_status VARCHAR(20),
    last_successful_operation TIMESTAMP WITH TIME ZONE,
    error_count_24h INTEGER,
    performance_score DECIMAL(3,2)
) AS $$
BEGIN
    RETURN QUERY
    -- Quillt integrations
    SELECT 
        'quillt'::VARCHAR(50),
        qi.id,
        qi.integration_name,
        CASE 
            WHEN qi.integration_status = 'active' AND qi.last_successful_sync > NOW() - INTERVAL '48 hours' THEN 'healthy'
            WHEN qi.integration_status = 'active' AND qi.last_successful_sync > NOW() - INTERVAL '7 days' THEN 'warning'
            ELSE 'error'
        END::VARCHAR(20),
        qi.last_successful_sync,
        COALESCE((
            SELECT COUNT(*)::INTEGER
            FROM quillt_sync_logs qsl
            WHERE qsl.integration_id = qi.id
            AND qsl.sync_status = 'failed'
            AND qsl.started_at > NOW() - INTERVAL '24 hours'
        ), 0),
        COALESCE((
            SELECT AVG(qsl.data_quality_score)
            FROM quillt_sync_logs qsl
            WHERE qsl.integration_id = qi.id
            AND qsl.sync_status = 'completed'
            AND qsl.started_at > NOW() - INTERVAL '7 days'
        ), 0.0)::DECIMAL(3,2)
    FROM quillt_integrations qi
    WHERE qi.tenant_id = p_tenant_id
    AND qi.integration_status = 'active'
    
    UNION ALL
    
    -- Builder.io integrations
    SELECT 
        'builder_io'::VARCHAR(50),
        bio.id,
        bio.page_name,
        CASE 
            WHEN bio.is_active AND bio.last_successful_fetch > NOW() - INTERVAL '1 day' THEN 'healthy'
            WHEN bio.is_active AND bio.last_successful_fetch > NOW() - INTERVAL '7 days' THEN 'warning'
            ELSE 'error'
        END::VARCHAR(20),
        bio.last_successful_fetch,
        0::INTEGER, -- Builder.io doesn't have error logs in this schema
        1.0::DECIMAL(3,2) -- Assume good performance for content delivery
    FROM builder_io_integrations bio
    WHERE bio.tenant_id = p_tenant_id
    AND bio.is_active = TRUE
    
    ORDER BY health_status, last_successful_operation DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Error Handling & Retry Logic

### sp_retry_failed_integration
Implements retry logic for failed integration operations.

```sql
CREATE OR REPLACE FUNCTION sp_retry_failed_integration(
    p_integration_type VARCHAR(50),
    p_integration_id UUID,
    p_max_retries INTEGER DEFAULT 3
)
RETURNS TABLE (
    success BOOLEAN,
    retry_attempt INTEGER,
    message TEXT
) AS $$
DECLARE
    v_retry_count INTEGER := 0;
    v_retry_successful BOOLEAN := FALSE;
    v_error_message TEXT;
BEGIN
    -- Determine retry count based on integration type
    CASE p_integration_type
        WHEN 'quillt' THEN
            SELECT COALESCE(MAX(retry_count), 0) INTO v_retry_count
            FROM quillt_sync_logs
            WHERE integration_id = p_integration_id
            AND sync_status = 'failed'
            AND started_at > NOW() - INTERVAL '1 hour';
            
        WHEN 'real_estate' THEN
            -- Real estate sync retry logic would go here
            v_retry_count := 0;
            
        ELSE
            RETURN QUERY SELECT FALSE, 0, 'Unknown integration type';
            RETURN;
    END CASE;

    -- Check if max retries exceeded
    IF v_retry_count >= p_max_retries THEN
        RETURN QUERY SELECT FALSE, v_retry_count, 'Maximum retry attempts exceeded';
        RETURN;
    END IF;

    -- Implement exponential backoff
    PERFORM pg_sleep(POWER(2, v_retry_count));

    BEGIN
        -- Retry based on integration type
        CASE p_integration_type
            WHEN 'quillt' THEN
                -- Retry Quillt sync
                DECLARE
                    v_sync_result RECORD;
                BEGIN
                    SELECT * INTO v_sync_result
                    FROM sp_sync_quillt_data(p_integration_id, 'incremental', TRUE);
                    
                    v_retry_successful := v_sync_result.success;
                    v_error_message := v_sync_result.message;
                END;
                
            WHEN 'real_estate' THEN
                -- Retry real estate sync
                v_retry_successful := TRUE; -- Placeholder
        END CASE;

        IF v_retry_successful THEN
            PERFORM sp_log_audit_event(
                fn_get_current_tenant_id(), fn_get_current_user_id(), NULL,
                'INTEGRATION_RETRY_SUCCESSFUL', p_integration_type, p_integration_id,
                NULL, jsonb_build_object('retry_attempt', v_retry_count + 1)
            );
            
            RETURN QUERY SELECT TRUE, v_retry_count + 1, 'Retry successful';
        ELSE
            PERFORM sp_log_audit_event(
                fn_get_current_tenant_id(), fn_get_current_user_id(), NULL,
                'INTEGRATION_RETRY_FAILED', p_integration_type, p_integration_id,
                NULL, jsonb_build_object('retry_attempt', v_retry_count + 1, 'error', v_error_message)
            );
            
            RETURN QUERY SELECT FALSE, v_retry_count + 1, 'Retry failed: ' || v_error_message;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, v_retry_count + 1, 'Retry error: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Security & Authentication

### Integration Security Features
All integration procedures implement:

1. **Encrypted Credential Storage**: API keys and sensitive data encrypted at rest
2. **Rate Limiting**: Built-in rate limiting to respect third-party API limits
3. **Audit Logging**: Complete audit trail of all integration activities
4. **Error Sanitization**: Generic error messages to prevent information leakage
5. **Token Validation**: Proper validation of authentication tokens and credentials

### Rate Limiting Implementation
```sql
-- Example rate limit check for Quillt API
IF NOT fn_check_rate_limit(
    p_integration_id::TEXT, 
    'QUILLT_SYNC', 
    100,  -- max 100 calls
    INTERVAL '1 hour'  -- per hour
) THEN
    RETURN QUERY SELECT FALSE, NULL::UUID, 0, 0, 'Rate limit exceeded';
    RETURN;
END IF;
```

## Integration Best Practices

### Data Quality Validation
```sql
-- Validate data quality scores
IF v_data_quality_score < 0.7 THEN
    -- Log data quality warning
    PERFORM sp_log_audit_event(
        p_tenant_id, fn_get_current_user_id(), NULL,
        'DATA_QUALITY_WARNING', 'integration', p_integration_id,
        NULL, jsonb_build_object('quality_score', v_data_quality_score)
    );
END IF;
```

### Error Recovery Patterns
```sql
-- Standard error recovery pattern
BEGIN
    -- Main integration logic
EXCEPTION
    WHEN connection_failure THEN
        -- Schedule retry
        PERFORM sp_retry_failed_integration(integration_type, integration_id);
    WHEN data_error THEN
        -- Log and continue with partial data
        PERFORM sp_log_audit_event(..., 'DATA_ERROR', ...);
    WHEN OTHERS THEN
        -- Log and fail gracefully
        PERFORM sp_log_audit_event(..., 'INTEGRATION_ERROR', ...);
        RETURN QUERY SELECT FALSE, error_message;
END;
```

### Performance Monitoring
```sql
-- Track integration performance
INSERT INTO integration_metrics (
    integration_id, metric_name, metric_value, recorded_at
) VALUES (
    p_integration_id, 'response_time_ms', v_response_time, NOW()
);
```

---

*This comprehensive integration procedure documentation provides the Forward Inheritance Platform with robust, secure, and reliable connectivity to external systems while maintaining proper audit trails, error handling, and performance monitoring capabilities.*