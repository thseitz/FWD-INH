-- Fix missing test data for failing stored procedures
-- Run this after the basic test data to enable all procedures to pass

-- 1. Add FREE plan for sp_create_ffc_with_subscription
INSERT INTO plans (
    id,
    tenant_id,
    plan_code,
    plan_name,
    plan_description,
    plan_type,
    base_price,
    billing_frequency,
    trial_days,
    features,
    ui_config,
    status,
    is_public,
    sort_order,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    1,
    'FAMILY_UNLIMITED_FREE',
    'Family Unlimited - Free',
    'Free plan for unlimited family members',
    'free',
    0.00,
    'monthly',
    0,
    '{"max_ffcs": 1, "max_members": "unlimited", "max_assets": 100}'::jsonb,
    '{"color": "green", "icon": "family"}'::jsonb,
    'active',
    true,
    1,
    NOW(),
    NOW()
) ON CONFLICT (tenant_id, plan_code) DO NOTHING;

-- 2. Add Builder.io integration for sp_refresh_builder_content
INSERT INTO builder_io_integrations (
    id,
    tenant_id,
    space_id,
    api_key,
    is_active,
    metadata,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    1,
    'test_space',
    'test_api_key_123',
    true,
    '{"environment": "test"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- 3. Add a real estate asset for sp_sync_real_estate_data
INSERT INTO real_estate (
    id,
    tenant_id,
    asset_id,
    property_type,
    address_line1,
    city,
    state_province,
    postal_code,
    country,
    square_footage,
    lot_size_acres,
    year_built,
    bedrooms,
    bathrooms,
    property_tax_annual,
    insurance_annual,
    hoa_fees_monthly,
    mortgage_balance,
    mortgage_payment_monthly,
    rental_income_monthly,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    1,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Using existing asset
    'residential',
    '123 Test Street',
    'Test City',
    'CA',
    '90210',
    'USA',
    2500,
    0.25,
    2000,
    3,
    2,
    5000.00,
    1200.00,
    NULL,
    300000.00,
    2000.00,
    NULL,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- 4. Add a real estate provider integration for completeness
INSERT INTO real_estate_provider_integrations (
    id,
    tenant_id,
    provider_name,
    provider_type,
    api_endpoint,
    api_key,
    sync_frequency_hours,
    last_sync_at,
    is_active,
    metadata,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    1,
    'Test Provider',
    'zillow',
    'https://api.test.com',
    'test_key_456',
    24,
    NULL,
    true,
    '{"version": "1.0"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- 5. Add plan seats for the free plan
INSERT INTO plan_seats (
    id,
    plan_id,
    seat_type,
    included_seats,
    max_seats,
    price_per_additional_seat,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    (SELECT id FROM plans WHERE plan_code = 'FAMILY_UNLIMITED_FREE' AND tenant_id = 1),
    'member',
    1000, -- Effectively unlimited for a family
    1000,
    0.00,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

-- 6. Add services for service purchases
INSERT INTO services (
    id,
    tenant_id,
    service_code,
    service_name,
    description,
    price,
    billing_type,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    1,
    'TRUST_SETUP',
    'Trust Setup Service',
    'Professional trust setup and documentation',
    500.00,
    'one_time',
    true,
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;

SELECT 'Missing test data added successfully!' as result;