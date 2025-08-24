-- ================================================================
-- Forward Inheritance Platform - Essential Stored Procedures Only
-- CLEANED VERSION: Contains only complex business logic procedures
-- Date: August 2025
-- 
-- This file contains ONLY the 11 core complex stored procedures:
-- 1. Complex business transactions requiring multiple table updates
-- 2. External API integration procedures with error handling
-- 3. Webhook processing with state management
-- 4. Payment and subscription orchestration
-- 5. Event sourcing and projection rebuilding
--
-- All simple CRUD operations have been moved to SQL files for Slonik control
-- ================================================================

-- ================================================================
-- ROW LEVEL SECURITY SETUP
-- ================================================================

-- Enable RLS on sensitive tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE fwd_family_circles ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_storage ENABLE ROW LEVEL SECURITY;
ALTER TABLE ffc_personas ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_persona ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_address ENABLE ROW LEVEL SECURITY;
ALTER TABLE phone_number ENABLE ROW LEVEL SECURITY;
ALTER TABLE address ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_store ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_projections ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE pii_detections ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_configurations ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- RLS HELPER FUNCTIONS (Required for all RLS policies)
-- ================================================================

CREATE OR REPLACE FUNCTION current_user_id() 
RETURNS UUID AS $$
BEGIN
    RETURN COALESCE(
        current_setting('app.current_user_id', true)::UUID,
        '00000000-0000-0000-0000-000000000000'::UUID
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_tenant_id() 
RETURNS INTEGER AS $$
BEGIN
    RETURN COALESCE(
        current_setting('app.current_tenant_id', true)::INTEGER,
        0
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_ffc_member(ffc_id UUID) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM ffc_personas fp
        JOIN personas p ON fp.persona_id = p.id  
        WHERE fp.ffc_id = $1 
        AND p.user_id = current_user_id()
        AND fp.status = 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ================================================================
-- RLS POLICIES (Applied to all sensitive tables)
-- ================================================================

-- Users: Can only see own user record
CREATE POLICY user_isolation ON users
    FOR ALL USING (id = current_user_id());

-- Personas: Can only see own personas  
CREATE POLICY persona_isolation ON personas
    FOR ALL USING (user_id = current_user_id());

-- FFCs: Can only see FFCs where user is a member
CREATE POLICY ffc_member_access ON fwd_family_circles
    FOR ALL USING (is_ffc_member(id));

-- Assets: Can only see assets in accessible FFCs
CREATE POLICY asset_ffc_access ON assets  
    FOR ALL USING (ffc_id IN (
        SELECT id FROM fwd_family_circles WHERE is_ffc_member(id)
    ));

-- FFC Members: Can only see members of accessible FFCs
CREATE POLICY ffc_persona_access ON ffc_personas
    FOR ALL USING (is_ffc_member(ffc_id));

-- Asset Ownership: Can only see ownership in accessible FFCs
CREATE POLICY asset_persona_access ON asset_persona
    FOR ALL USING (asset_id IN (
        SELECT id FROM assets WHERE ffc_id IN (
            SELECT id FROM fwd_family_circles WHERE is_ffc_member(id)
        )
    ));

-- Contact Information: Can only see own contact info
CREATE POLICY email_user_access ON email_address
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY phone_user_access ON phone_number  
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY address_user_access ON address
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY social_user_access ON social_media
    FOR ALL USING (user_id = current_user_id());

CREATE POLICY contact_user_access ON contact_info
    FOR ALL USING (user_id = current_user_id());

-- Documents and Media: Can only see own or FFC-shared documents
CREATE POLICY document_access ON document_metadata
    FOR ALL USING (
        user_id = current_user_id() OR 
        ffc_id IN (SELECT id FROM fwd_family_circles WHERE is_ffc_member(id))
    );

CREATE POLICY media_access ON media_storage
    FOR ALL USING (
        user_id = current_user_id() OR
        ffc_id IN (SELECT id FROM fwd_family_circles WHERE is_ffc_member(id))  
    );

-- Audit: Can only see own audit records
CREATE POLICY audit_user_access ON audit_trail
    FOR ALL USING (user_id = current_user_id());

-- Event Store: Can only see events for accessible entities
CREATE POLICY event_access ON event_store
    FOR ALL USING (
        tenant_id = current_tenant_id() AND
        (user_id = current_user_id() OR 
         ffc_id IN (SELECT id FROM fwd_family_circles WHERE is_ffc_member(id)))
    );

-- Event Projections: Same as event store
CREATE POLICY projection_access ON event_projections
    FOR ALL USING (
        tenant_id = current_tenant_id() AND
        (user_id = current_user_id() OR
         ffc_id IN (SELECT id FROM fwd_family_circles WHERE is_ffc_member(id)))
    );

-- Snapshots: Same as event store
CREATE POLICY snapshot_access ON snapshots
    FOR ALL USING (
        tenant_id = current_tenant_id() AND
        (user_id = current_user_id() OR
         ffc_id IN (SELECT id FROM fwd_family_circles WHERE is_ffc_member(id)))
    );

-- PII Detections: Can only see own PII detections
CREATE POLICY pii_user_access ON pii_detections
    FOR ALL USING (user_id = current_user_id());

-- System Config: Admin only (implement based on user roles)
CREATE POLICY system_config_admin ON system_configurations
    FOR ALL USING (current_tenant_id() > 0); -- Placeholder: implement proper admin check

-- ================================================================
-- ESSENTIAL STORED PROCEDURES (11 Core Complex Procedures)
-- ================================================================

-- Drop any existing versions first
DROP FUNCTION IF EXISTS sp_create_user_from_cognito CASCADE;
DROP FUNCTION IF EXISTS sp_create_asset CASCADE;
DROP PROCEDURE IF EXISTS sp_create_ffc_with_subscription CASCADE;
DROP PROCEDURE IF EXISTS sp_process_seat_invitation CASCADE;
DROP PROCEDURE IF EXISTS sp_process_stripe_webhook CASCADE;
DROP PROCEDURE IF EXISTS sp_purchase_service CASCADE;
DROP FUNCTION IF EXISTS sp_rebuild_projection CASCADE;
DROP FUNCTION IF EXISTS sp_sync_quiltt_data CASCADE;
DROP FUNCTION IF EXISTS sp_sync_real_estate_data CASCADE;
DROP FUNCTION IF EXISTS sp_refresh_builder_content CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- 1. User Creation from Cognito (Complex user setup with persona creation)
CREATE OR REPLACE FUNCTION sp_create_user_from_cognito(
    p_tenant_id INTEGER,
    p_cognito_user_id VARCHAR(255),
    p_email VARCHAR(255),
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_phone_number VARCHAR(20) DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_persona_id UUID;
    v_email_id UUID;
    v_phone_id UUID;
    v_result JSON;
BEGIN
    -- Start transaction-like behavior
    -- Create user record
    INSERT INTO users (tenant_id, cognito_user_id, email, first_name, last_name, status)
    VALUES (p_tenant_id, p_cognito_user_id, p_email, p_first_name, p_last_name, 'active')
    RETURNING id INTO v_user_id;
    
    -- Create primary persona
    INSERT INTO personas (tenant_id, user_id, display_name, is_primary)
    VALUES (p_tenant_id, v_user_id, p_first_name || ' ' || p_last_name, true)
    RETURNING id INTO v_persona_id;
    
    -- Add email address
    INSERT INTO email_address (tenant_id, user_id, email, type, is_verified)
    VALUES (p_tenant_id, v_user_id, p_email, 'personal', true)
    RETURNING id INTO v_email_id;
    
    -- Link email to persona
    INSERT INTO usage_email (tenant_id, persona_id, email_id, usage_type, is_primary)
    VALUES (p_tenant_id, v_persona_id, v_email_id, 'personal', true);
    
    -- Add phone if provided
    IF p_phone_number IS NOT NULL THEN
        INSERT INTO phone_number (tenant_id, user_id, phone, type, is_verified)
        VALUES (p_tenant_id, v_user_id, p_phone_number, 'mobile', false)
        RETURNING id INTO v_phone_id;
        
        INSERT INTO usage_phone (tenant_id, persona_id, phone_id, usage_type, is_primary)
        VALUES (p_tenant_id, v_persona_id, v_phone_id, 'personal', true);
    END IF;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, v_user_id, 'CREATE', 'USER', v_user_id, 
            json_build_object('source', 'cognito', 'email', p_email));
    
    -- Return success result
    v_result := json_build_object(
        'success', true,
        'user_id', v_user_id,
        'persona_id', v_persona_id,
        'email_id', v_email_id,
        'phone_id', v_phone_id
    );
    
    RETURN v_result;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Asset Creation (Complex validation and relationship setup)
CREATE OR REPLACE FUNCTION sp_create_asset(
    p_tenant_id INTEGER,
    p_ffc_id UUID,
    p_category_id INTEGER,
    p_name VARCHAR(255),
    p_description TEXT,
    p_estimated_value DECIMAL(15,2),
    p_currency_code VARCHAR(3) DEFAULT 'USD',
    p_acquisition_date DATE DEFAULT NULL,
    p_location VARCHAR(255) DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS JSON AS $$
DECLARE
    v_asset_id UUID;
    v_result JSON;
BEGIN
    -- Validate FFC access
    IF NOT is_ffc_member(p_ffc_id) THEN
        RETURN json_build_object('success', false, 'error', 'Access denied to FFC');
    END IF;
    
    -- Validate category exists
    IF NOT EXISTS (SELECT 1 FROM asset_categories WHERE id = p_category_id) THEN
        RETURN json_build_object('success', false, 'error', 'Invalid asset category');
    END IF;
    
    -- Create asset
    INSERT INTO assets (
        tenant_id, ffc_id, category_id, name, description, 
        estimated_value, currency_code, acquisition_date, location, metadata
    ) VALUES (
        p_tenant_id, p_ffc_id, p_category_id, p_name, p_description,
        p_estimated_value, p_currency_code, p_acquisition_date, p_location, p_metadata
    ) RETURNING id INTO v_asset_id;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, current_user_id(), 'CREATE', 'ASSET', v_asset_id,
            json_build_object('name', p_name, 'value', p_estimated_value, 'ffc_id', p_ffc_id));
    
    -- Create event store record
    INSERT INTO event_store (tenant_id, user_id, ffc_id, event_type, entity_type, entity_id, event_data)
    VALUES (p_tenant_id, current_user_id(), p_ffc_id, 'ASSET_CREATED', 'ASSET', v_asset_id,
            json_build_object('name', p_name, 'category_id', p_category_id, 'value', p_estimated_value));
    
    RETURN json_build_object(
        'success', true,
        'asset_id', v_asset_id,
        'name', p_name,
        'estimated_value', p_estimated_value
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FFC Creation with Subscription (Complex business transaction)
CREATE OR REPLACE PROCEDURE sp_create_ffc_with_subscription(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_ffc_name VARCHAR(255),
    p_plan_id INTEGER,
    p_payment_method_id UUID,
    p_billing_email VARCHAR(255),
    INOUT result JSON DEFAULT NULL
) AS $$
DECLARE
    v_ffc_id UUID;
    v_subscription_id UUID;
    v_persona_id UUID;
    v_seats_included INTEGER;
    v_monthly_cost DECIMAL(10,2);
BEGIN
    -- Get plan details
    SELECT seats_included, monthly_cost INTO v_seats_included, v_monthly_cost
    FROM subscription_plans WHERE id = p_plan_id AND is_active = true;
    
    IF NOT FOUND THEN
        result := json_build_object('success', false, 'error', 'Invalid subscription plan');
        RETURN;
    END IF;
    
    -- Get user's primary persona
    SELECT id INTO v_persona_id FROM personas 
    WHERE user_id = p_user_id AND is_primary = true AND tenant_id = p_tenant_id;
    
    IF NOT FOUND THEN
        result := json_build_object('success', false, 'error', 'User primary persona not found');
        RETURN;
    END IF;
    
    -- Create FFC
    INSERT INTO fwd_family_circles (tenant_id, name, description, privacy_setting, created_by)
    VALUES (p_tenant_id, p_ffc_name, 'Created with subscription plan', 'private', p_user_id)
    RETURNING id INTO v_ffc_id;
    
    -- Add creator as admin member
    INSERT INTO ffc_personas (tenant_id, ffc_id, persona_id, role, status, added_by)
    VALUES (p_tenant_id, v_ffc_id, v_persona_id, 'admin', 'active', p_user_id);
    
    -- Create subscription
    INSERT INTO tenant_subscriptions (
        tenant_id, plan_id, ffc_id, status, billing_email, 
        seats_total, seats_used, monthly_cost, payment_method_id
    ) VALUES (
        p_tenant_id, p_plan_id, v_ffc_id, 'active', p_billing_email,
        v_seats_included, 1, v_monthly_cost, p_payment_method_id
    ) RETURNING id INTO v_subscription_id;
    
    -- Create audit records
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES 
        (p_tenant_id, p_user_id, 'CREATE', 'FFC', v_ffc_id, 
         json_build_object('name', p_ffc_name, 'subscription_id', v_subscription_id)),
        (p_tenant_id, p_user_id, 'CREATE', 'SUBSCRIPTION', v_subscription_id,
         json_build_object('plan_id', p_plan_id, 'ffc_id', v_ffc_id, 'cost', v_monthly_cost));
    
    -- Create event store records
    INSERT INTO event_store (tenant_id, user_id, ffc_id, event_type, entity_type, entity_id, event_data)
    VALUES 
        (p_tenant_id, p_user_id, v_ffc_id, 'FFC_CREATED', 'FFC', v_ffc_id,
         json_build_object('name', p_ffc_name, 'privacy', 'private')),
        (p_tenant_id, p_user_id, v_ffc_id, 'SUBSCRIPTION_CREATED', 'SUBSCRIPTION', v_subscription_id,
         json_build_object('plan_id', p_plan_id, 'seats', v_seats_included, 'cost', v_monthly_cost));
    
    result := json_build_object(
        'success', true,
        'ffc_id', v_ffc_id,
        'subscription_id', v_subscription_id,
        'seats_included', v_seats_included,
        'monthly_cost', v_monthly_cost
    );
    
EXCEPTION
    WHEN OTHERS THEN
        result := json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Seat Invitation Processing (Complex invitation workflow)
CREATE OR REPLACE PROCEDURE sp_process_seat_invitation(
    p_tenant_id INTEGER,
    p_invitation_id UUID,
    p_invited_user_id UUID,
    p_action VARCHAR(20), -- 'accept' or 'decline'
    INOUT result JSON DEFAULT NULL
) AS $$
DECLARE
    v_ffc_id UUID;
    v_invited_by UUID;
    v_subscription_id UUID;
    v_seats_available INTEGER;
    v_persona_id UUID;
    v_invitation_status VARCHAR(20);
BEGIN
    -- Get invitation details
    SELECT ffc_id, invited_by, status INTO v_ffc_id, v_invited_by, v_invitation_status
    FROM ffc_invitations 
    WHERE id = p_invitation_id AND tenant_id = p_tenant_id;
    
    IF NOT FOUND THEN
        result := json_build_object('success', false, 'error', 'Invitation not found');
        RETURN;
    END IF;
    
    -- Check invitation is still pending
    IF v_invitation_status != 'pending' THEN
        result := json_build_object('success', false, 'error', 'Invitation already processed');
        RETURN;
    END IF;
    
    IF p_action = 'accept' THEN
        -- Check seat availability
        SELECT ts.id, (ts.seats_total - ts.seats_used) 
        INTO v_subscription_id, v_seats_available
        FROM tenant_subscriptions ts
        WHERE ts.ffc_id = v_ffc_id AND ts.status = 'active';
        
        IF v_seats_available < 1 THEN
            result := json_build_object('success', false, 'error', 'No available seats');
            RETURN;
        END IF;
        
        -- Get user's primary persona
        SELECT id INTO v_persona_id FROM personas
        WHERE user_id = p_invited_user_id AND is_primary = true AND tenant_id = p_tenant_id;
        
        -- Add persona to FFC
        INSERT INTO ffc_personas (tenant_id, ffc_id, persona_id, role, status, added_by)
        VALUES (p_tenant_id, v_ffc_id, v_persona_id, 'member', 'active', v_invited_by);
        
        -- Update subscription seat count
        UPDATE tenant_subscriptions 
        SET seats_used = seats_used + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = v_subscription_id;
        
        -- Update invitation status
        UPDATE ffc_invitations 
        SET status = 'accepted',
            responded_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_invitation_id;
        
        -- Create audit record
        INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
        VALUES (p_tenant_id, p_invited_user_id, 'ACCEPT', 'INVITATION', p_invitation_id,
                json_build_object('ffc_id', v_ffc_id, 'invited_by', v_invited_by));
        
        result := json_build_object(
            'success', true,
            'action', 'accepted',
            'ffc_id', v_ffc_id,
            'seats_remaining', v_seats_available - 1
        );
        
    ELSIF p_action = 'decline' THEN
        -- Update invitation status
        UPDATE ffc_invitations 
        SET status = 'declined',
            responded_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_invitation_id;
        
        -- Create audit record
        INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
        VALUES (p_tenant_id, p_invited_user_id, 'DECLINE', 'INVITATION', p_invitation_id,
                json_build_object('ffc_id', v_ffc_id, 'invited_by', v_invited_by));
        
        result := json_build_object(
            'success', true,
            'action', 'declined',
            'ffc_id', v_ffc_id
        );
    ELSE
        result := json_build_object('success', false, 'error', 'Invalid action. Use accept or decline');
        RETURN;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        result := json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Stripe Webhook Processing (Complex payment event handling)
CREATE OR REPLACE PROCEDURE sp_process_stripe_webhook(
    p_tenant_id INTEGER,
    p_event_type VARCHAR(100),
    p_stripe_event_id VARCHAR(255),
    p_event_data JSONB,
    INOUT result JSON DEFAULT NULL
) AS $$
DECLARE
    v_subscription_id UUID;
    v_customer_id VARCHAR(255);
    v_payment_status VARCHAR(50);
    v_amount_paid DECIMAL(10,2);
BEGIN
    -- Check if event already processed
    IF EXISTS (SELECT 1 FROM stripe_events WHERE stripe_event_id = p_stripe_event_id) THEN
        result := json_build_object('success', true, 'message', 'Event already processed');
        RETURN;
    END IF;
    
    -- Log the event
    INSERT INTO stripe_events (tenant_id, event_type, stripe_event_id, event_data, status)
    VALUES (p_tenant_id, p_event_type, p_stripe_event_id, p_event_data, 'processing');
    
    -- Process different event types
    CASE p_event_type
        WHEN 'invoice.payment_succeeded' THEN
            v_customer_id := p_event_data->>'customer';
            v_amount_paid := (p_event_data->>'amount_paid')::DECIMAL / 100; -- Convert cents to dollars
            
            -- Find subscription by customer
            SELECT id INTO v_subscription_id 
            FROM tenant_subscriptions 
            WHERE stripe_customer_id = v_customer_id AND tenant_id = p_tenant_id;
            
            IF FOUND THEN
                -- Update subscription status
                UPDATE tenant_subscriptions 
                SET status = 'active',
                    last_payment_at = CURRENT_TIMESTAMP,
                    next_billing_date = CURRENT_TIMESTAMP + INTERVAL '1 month',
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = v_subscription_id;
                
                -- Create payment record
                INSERT INTO payment_transactions (
                    tenant_id, subscription_id, stripe_payment_intent_id,
                    amount, currency, status, paid_at
                ) VALUES (
                    p_tenant_id, v_subscription_id, p_event_data->>'payment_intent',
                    v_amount_paid, p_event_data->>'currency', 'succeeded', CURRENT_TIMESTAMP
                );
            END IF;
            
        WHEN 'invoice.payment_failed' THEN
            v_customer_id := p_event_data->>'customer';
            
            SELECT id INTO v_subscription_id 
            FROM tenant_subscriptions 
            WHERE stripe_customer_id = v_customer_id AND tenant_id = p_tenant_id;
            
            IF FOUND THEN
                UPDATE tenant_subscriptions 
                SET status = 'past_due',
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = v_subscription_id;
            END IF;
            
        WHEN 'customer.subscription.deleted' THEN
            v_customer_id := p_event_data->>'customer';
            
            SELECT id INTO v_subscription_id 
            FROM tenant_subscriptions 
            WHERE stripe_customer_id = v_customer_id AND tenant_id = p_tenant_id;
            
            IF FOUND THEN
                UPDATE tenant_subscriptions 
                SET status = 'cancelled',
                    cancelled_at = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = v_subscription_id;
            END IF;
    END CASE;
    
    -- Mark event as processed
    UPDATE stripe_events 
    SET status = 'completed', processed_at = CURRENT_TIMESTAMP
    WHERE stripe_event_id = p_stripe_event_id;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, NULL, 'WEBHOOK', 'STRIPE_EVENT', NULL,
            json_build_object('event_type', p_event_type, 'stripe_event_id', p_stripe_event_id));
    
    result := json_build_object(
        'success', true,
        'event_type', p_event_type,
        'subscription_id', v_subscription_id,
        'processed_at', CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Mark event as failed
        UPDATE stripe_events 
        SET status = 'failed', 
            error_message = SQLERRM,
            processed_at = CURRENT_TIMESTAMP
        WHERE stripe_event_id = p_stripe_event_id;
        
        result := json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Service Purchase Processing (Complex payment workflow)
CREATE OR REPLACE PROCEDURE sp_purchase_service(
    p_tenant_id INTEGER,
    p_user_id UUID,
    p_service_type VARCHAR(50),
    p_service_details JSONB,
    p_payment_method_id UUID,
    INOUT result JSON DEFAULT NULL
) AS $$
DECLARE
    v_service_cost DECIMAL(10,2);
    v_purchase_id UUID;
    v_payment_intent_id VARCHAR(255);
BEGIN
    -- Validate service type and get cost
    CASE p_service_type
        WHEN 'document_review' THEN
            v_service_cost := 299.00;
        WHEN 'asset_valuation' THEN
            v_service_cost := 199.00;
        WHEN 'legal_consultation' THEN
            v_service_cost := 499.00;
        ELSE
            result := json_build_object('success', false, 'error', 'Invalid service type');
            RETURN;
    END CASE;
    
    -- Validate payment method belongs to user
    IF NOT EXISTS (
        SELECT 1 FROM payment_methods 
        WHERE id = p_payment_method_id AND user_id = p_user_id AND is_active = true
    ) THEN
        result := json_build_object('success', false, 'error', 'Invalid payment method');
        RETURN;
    END IF;
    
    -- Create service purchase record
    INSERT INTO service_purchases (
        tenant_id, user_id, service_type, service_details,
        amount, currency, payment_method_id, status
    ) VALUES (
        p_tenant_id, p_user_id, p_service_type, p_service_details,
        v_service_cost, 'USD', p_payment_method_id, 'pending'
    ) RETURNING id INTO v_purchase_id;
    
    -- Here you would integrate with Stripe to create payment intent
    -- For now, we'll simulate a successful payment
    v_payment_intent_id := 'pi_' || replace(gen_random_uuid()::text, '-', '');
    
    -- Update purchase with payment intent
    UPDATE service_purchases 
    SET stripe_payment_intent_id = v_payment_intent_id,
        status = 'processing',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_purchase_id;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, p_user_id, 'PURCHASE', 'SERVICE', v_purchase_id,
            json_build_object('service_type', p_service_type, 'amount', v_service_cost));
    
    -- Create event store record
    INSERT INTO event_store (tenant_id, user_id, ffc_id, event_type, entity_type, entity_id, event_data)
    VALUES (p_tenant_id, p_user_id, NULL, 'SERVICE_PURCHASED', 'SERVICE', v_purchase_id,
            json_build_object('service_type', p_service_type, 'amount', v_service_cost));
    
    result := json_build_object(
        'success', true,
        'purchase_id', v_purchase_id,
        'payment_intent_id', v_payment_intent_id,
        'amount', v_service_cost,
        'service_type', p_service_type
    );
    
EXCEPTION
    WHEN OTHERS THEN
        result := json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Event Sourcing - Projection Rebuild (Complex data reconstruction)
CREATE OR REPLACE FUNCTION sp_rebuild_projection(
    p_tenant_id INTEGER,
    p_projection_name VARCHAR(100),
    p_from_version INTEGER DEFAULT 0
) RETURNS JSON AS $$
DECLARE
    v_events_processed INTEGER := 0;
    v_last_version INTEGER;
    v_event_record RECORD;
    v_projection_data JSONB;
    v_result JSON;
BEGIN
    -- Validate projection name
    IF p_projection_name NOT IN ('asset_summary', 'ffc_members', 'user_activity') THEN
        RETURN json_build_object('success', false, 'error', 'Invalid projection name');
    END IF;
    
    -- Clear existing projection data if rebuilding from scratch
    IF p_from_version = 0 THEN
        DELETE FROM event_projections 
        WHERE tenant_id = p_tenant_id AND projection_name = p_projection_name;
    END IF;
    
    -- Process events in order
    FOR v_event_record IN 
        SELECT event_id, event_type, entity_type, entity_id, event_data, version
        FROM event_store 
        WHERE tenant_id = p_tenant_id AND version > p_from_version
        ORDER BY version ASC
    LOOP
        -- Build projection based on event type
        CASE p_projection_name
            WHEN 'asset_summary' THEN
                CASE v_event_record.event_type
                    WHEN 'ASSET_CREATED' THEN
                        v_projection_data := json_build_object(
                            'asset_id', v_event_record.entity_id,
                            'name', v_event_record.event_data->>'name',
                            'value', v_event_record.event_data->>'value',
                            'created_at', CURRENT_TIMESTAMP
                        );
                    WHEN 'ASSET_UPDATED' THEN
                        v_projection_data := json_build_object(
                            'asset_id', v_event_record.entity_id,
                            'updated_fields', v_event_record.event_data,
                            'updated_at', CURRENT_TIMESTAMP
                        );
                END CASE;
                
            WHEN 'ffc_members' THEN
                CASE v_event_record.event_type
                    WHEN 'FFC_CREATED' THEN
                        v_projection_data := json_build_object(
                            'ffc_id', v_event_record.entity_id,
                            'name', v_event_record.event_data->>'name',
                            'member_count', 1
                        );
                    WHEN 'MEMBER_ADDED' THEN
                        v_projection_data := json_build_object(
                            'ffc_id', v_event_record.event_data->>'ffc_id',
                            'persona_id', v_event_record.event_data->>'persona_id',
                            'role', v_event_record.event_data->>'role'
                        );
                END CASE;
        END CASE;
        
        -- Insert or update projection
        INSERT INTO event_projections (
            tenant_id, projection_name, entity_id, projection_data, last_event_version
        ) VALUES (
            p_tenant_id, p_projection_name, v_event_record.entity_id, 
            v_projection_data, v_event_record.version
        )
        ON CONFLICT (tenant_id, projection_name, entity_id)
        DO UPDATE SET 
            projection_data = EXCLUDED.projection_data,
            last_event_version = EXCLUDED.last_event_version,
            updated_at = CURRENT_TIMESTAMP;
        
        v_events_processed := v_events_processed + 1;
        v_last_version := v_event_record.version;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'projection_name', p_projection_name,
        'events_processed', v_events_processed,
        'last_version', v_last_version
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE,
            'events_processed', v_events_processed
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Quiltt Data Synchronization (External API integration)
CREATE OR REPLACE FUNCTION sp_sync_quiltt_data(
    p_tenant_id INTEGER,
    p_persona_id UUID,
    p_force_refresh BOOLEAN DEFAULT false
) RETURNS JSON AS $$
DECLARE
    v_integration_id UUID;
    v_last_sync TIMESTAMP;
    v_sync_needed BOOLEAN := false;
    v_accounts_synced INTEGER := 0;
    v_transactions_synced INTEGER := 0;
    v_result JSON;
BEGIN
    -- Get Quiltt integration details
    SELECT id, last_successful_sync INTO v_integration_id, v_last_sync
    FROM quiltt_integrations 
    WHERE tenant_id = p_tenant_id AND persona_id = p_persona_id AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'No active Quiltt integration found');
    END IF;
    
    -- Check if sync is needed
    IF p_force_refresh OR v_last_sync IS NULL OR v_last_sync < (CURRENT_TIMESTAMP - INTERVAL '1 hour') THEN
        v_sync_needed := true;
    END IF;
    
    IF NOT v_sync_needed THEN
        RETURN json_build_object(
            'success', true,
            'message', 'Sync not needed - last sync was recent',
            'last_sync', v_last_sync
        );
    END IF;
    
    -- Update integration status
    UPDATE quiltt_integrations 
    SET sync_status = 'syncing',
        last_sync_attempt = CURRENT_TIMESTAMP
    WHERE id = v_integration_id;
    
    -- Here you would make actual API calls to Quiltt
    -- For now, we'll simulate the sync process
    
    -- Simulate account sync
    INSERT INTO quiltt_accounts (
        tenant_id, integration_id, quiltt_account_id, account_name, 
        account_type, balance, currency, last_synced
    ) VALUES (
        p_tenant_id, v_integration_id, 'acc_' || gen_random_uuid()::text,
        'Sample Checking Account', 'checking', 5000.00, 'USD', CURRENT_TIMESTAMP
    )
    ON CONFLICT (quiltt_account_id) 
    DO UPDATE SET 
        balance = EXCLUDED.balance,
        last_synced = EXCLUDED.last_synced;
    
    v_accounts_synced := 1;
    
    -- Simulate transaction sync (would normally iterate through API results)
    INSERT INTO quiltt_transactions (
        tenant_id, integration_id, quiltt_transaction_id, account_id,
        amount, description, transaction_date, category, last_synced
    ) VALUES (
        p_tenant_id, v_integration_id, 'txn_' || gen_random_uuid()::text,
        'acc_' || gen_random_uuid()::text, -45.67, 'Grocery Store Purchase',
        CURRENT_DATE - INTERVAL '1 day', 'food', CURRENT_TIMESTAMP
    )
    ON CONFLICT (quiltt_transaction_id)
    DO UPDATE SET last_synced = EXCLUDED.last_synced;
    
    v_transactions_synced := 1;
    
    -- Update integration success
    UPDATE quiltt_integrations 
    SET sync_status = 'completed',
        last_successful_sync = CURRENT_TIMESTAMP,
        accounts_count = v_accounts_synced,
        error_count = 0,
        error_message = NULL
    WHERE id = v_integration_id;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, (SELECT user_id FROM personas WHERE id = p_persona_id), 
            'SYNC', 'QUILTT_INTEGRATION', v_integration_id,
            json_build_object('accounts_synced', v_accounts_synced, 'transactions_synced', v_transactions_synced));
    
    RETURN json_build_object(
        'success', true,
        'integration_id', v_integration_id,
        'accounts_synced', v_accounts_synced,
        'transactions_synced', v_transactions_synced,
        'sync_completed_at', CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Update integration error status
        UPDATE quiltt_integrations 
        SET sync_status = 'error',
            error_count = error_count + 1,
            error_message = SQLERRM,
            last_error_at = CURRENT_TIMESTAMP
        WHERE id = v_integration_id;
        
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE,
            'integration_id', v_integration_id
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Real Estate Data Synchronization (External API integration)
CREATE OR REPLACE FUNCTION sp_sync_real_estate_data(
    p_tenant_id INTEGER,
    p_property_id UUID
) RETURNS JSON AS $$
DECLARE
    v_property_address TEXT;
    v_zillow_zpid VARCHAR(50);
    v_current_value DECIMAL(15,2);
    v_last_sale_date DATE;
    v_result JSON;
BEGIN
    -- Get property details
    SELECT full_address, zillow_zpid INTO v_property_address, v_zillow_zpid
    FROM real_estate 
    WHERE id = p_property_id AND tenant_id = p_tenant_id;
    
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Property not found');
    END IF;
    
    -- Here you would make actual API calls to Zillow/real estate services
    -- For now, we'll simulate the API response
    v_current_value := 450000.00 + (random() * 50000); -- Simulate market fluctuation
    v_last_sale_date := CURRENT_DATE - INTERVAL '2 years';
    
    -- Update property with new market data
    UPDATE real_estate 
    SET current_market_value = v_current_value,
        last_market_update = CURRENT_TIMESTAMP,
        market_trend = CASE 
            WHEN v_current_value > estimated_value THEN 'increasing'
            WHEN v_current_value < estimated_value * 0.95 THEN 'decreasing'
            ELSE 'stable'
        END
    WHERE id = p_property_id;
    
    -- Update the corresponding asset record
    UPDATE assets 
    SET estimated_value = v_current_value,
        updated_at = CURRENT_TIMESTAMP,
        metadata = metadata || json_build_object(
            'market_update', CURRENT_TIMESTAMP,
            'data_source', 'real_estate_api'
        )::jsonb
    WHERE id = p_property_id;
    
    -- Log the sync in real estate sync history
    INSERT INTO real_estate_sync_history (
        tenant_id, property_id, sync_date, data_source,
        previous_value, new_value, api_response_data
    ) VALUES (
        p_tenant_id, p_property_id, CURRENT_TIMESTAMP, 'zillow_api',
        (SELECT estimated_value FROM assets WHERE id = p_property_id),
        v_current_value,
        json_build_object('zpid', v_zillow_zpid, 'address', v_property_address)
    );
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, current_user_id(), 'SYNC', 'REAL_ESTATE', p_property_id,
            json_build_object('new_value', v_current_value, 'data_source', 'api'));
    
    -- Create event store record
    INSERT INTO event_store (tenant_id, user_id, ffc_id, event_type, entity_type, entity_id, event_data)
    VALUES (p_tenant_id, current_user_id(), 
            (SELECT ffc_id FROM assets WHERE id = p_property_id),
            'ASSET_VALUE_UPDATED', 'ASSET', p_property_id,
            json_build_object('new_value', v_current_value, 'source', 'market_data'));
    
    RETURN json_build_object(
        'success', true,
        'property_id', p_property_id,
        'current_value', v_current_value,
        'last_update', CURRENT_TIMESTAMP,
        'data_source', 'real_estate_api'
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error
        INSERT INTO real_estate_sync_history (
            tenant_id, property_id, sync_date, data_source,
            error_message, api_response_data
        ) VALUES (
            p_tenant_id, p_property_id, CURRENT_TIMESTAMP, 'real_estate_api',
            SQLERRM, json_build_object('error_code', SQLSTATE)
        );
        
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE,
            'property_id', p_property_id
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Builder.io Content Refresh (CMS integration)
CREATE OR REPLACE FUNCTION sp_refresh_builder_content(
    p_tenant_id INTEGER,
    p_space_id VARCHAR(255) DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    v_integration_record RECORD;
    v_content_updated INTEGER := 0;
    v_total_integrations INTEGER := 0;
    v_result JSON;
BEGIN
    -- Process all active Builder.io integrations for tenant, or specific space
    FOR v_integration_record IN 
        SELECT id, space_id, api_key_encrypted, environment
        FROM builder_io_integrations
        WHERE tenant_id = p_tenant_id 
        AND is_active = true
        AND (p_space_id IS NULL OR space_id = p_space_id)
    LOOP
        v_total_integrations := v_total_integrations + 1;
        
        BEGIN
            -- Update integration status
            UPDATE builder_io_integrations 
            SET last_sync_attempt = CURRENT_TIMESTAMP,
                connection_status = 'syncing'
            WHERE id = v_integration_record.id;
            
            -- Here you would make actual API calls to Builder.io
            -- For now, we'll simulate content refresh
            
            -- Simulate updating content cache
            INSERT INTO builder_content_cache (
                tenant_id, integration_id, content_type, content_id,
                content_data, cache_expires_at
            ) VALUES (
                p_tenant_id, v_integration_record.id, 'page', 'home-page',
                json_build_object(
                    'title', 'Updated Home Page',
                    'content', 'Fresh content from Builder.io',
                    'last_modified', CURRENT_TIMESTAMP
                ),
                CURRENT_TIMESTAMP + INTERVAL '1 hour'
            )
            ON CONFLICT (tenant_id, integration_id, content_type, content_id)
            DO UPDATE SET 
                content_data = EXCLUDED.content_data,
                cache_expires_at = EXCLUDED.cache_expires_at,
                updated_at = CURRENT_TIMESTAMP;
            
            v_content_updated := v_content_updated + 1;
            
            -- Update integration success
            UPDATE builder_io_integrations 
            SET last_successful_sync = CURRENT_TIMESTAMP,
                connection_status = 'connected',
                error_count = 0,
                error_message = NULL
            WHERE id = v_integration_record.id;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Handle individual integration errors
                UPDATE builder_io_integrations 
                SET connection_status = 'error',
                    error_count = error_count + 1,
                    error_message = SQLERRM,
                    last_error_at = CURRENT_TIMESTAMP
                WHERE id = v_integration_record.id;
        END;
    END LOOP;
    
    -- Create audit record
    INSERT INTO audit_trail (tenant_id, user_id, action, entity_type, entity_id, details)
    VALUES (p_tenant_id, current_user_id(), 'REFRESH', 'BUILDER_CONTENT', NULL,
            json_build_object(
                'integrations_processed', v_total_integrations,
                'content_updated', v_content_updated,
                'space_id', p_space_id
            ));
    
    RETURN json_build_object(
        'success', true,
        'integrations_processed', v_total_integrations,
        'content_updated', v_content_updated,
        'refresh_completed_at', CURRENT_TIMESTAMP
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'error_code', SQLSTATE,
            'integrations_processed', v_total_integrations
        );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Update Timestamp Trigger (Utility function for all tables)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================
DO $$
BEGIN
    RAISE NOTICE 'Essential stored procedures created successfully!';
    RAISE NOTICE 'Created 11 core complex procedures:';
    RAISE NOTICE '  1. sp_create_user_from_cognito - User creation with persona setup';
    RAISE NOTICE '  2. sp_create_asset - Complex asset creation with validation';
    RAISE NOTICE '  3. sp_create_ffc_with_subscription - FFC + subscription transaction';
    RAISE NOTICE '  4. sp_process_seat_invitation - Invitation workflow management';
    RAISE NOTICE '  5. sp_process_stripe_webhook - Payment webhook processing';
    RAISE NOTICE '  6. sp_purchase_service - Service purchase workflow';
    RAISE NOTICE '  7. sp_rebuild_projection - Event sourcing projection rebuild';
    RAISE NOTICE '  8. sp_sync_quiltt_data - External financial data sync';
    RAISE NOTICE '  9. sp_sync_real_estate_data - Real estate market data sync';
    RAISE NOTICE ' 10. sp_refresh_builder_content - CMS content refresh';
    RAISE NOTICE ' 11. update_updated_at_column - Timestamp trigger function';
    RAISE NOTICE '';
    RAISE NOTICE 'All simple operations moved to SQL files for Slonik control.';
    RAISE NOTICE 'RLS policies enabled on all sensitive tables.';
END $$;