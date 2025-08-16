-- Simple test data that matches actual database structure
-- Clean existing data first
DELETE FROM audit_log WHERE tenant_id = 1;
DELETE FROM asset_permissions WHERE tenant_id = 1;
DELETE FROM asset_persona WHERE tenant_id = 1;
DELETE FROM assets WHERE tenant_id = 1;
DELETE FROM ffc_personas WHERE tenant_id = 1;
DELETE FROM fwd_family_circles WHERE tenant_id = 1;
DELETE FROM personas WHERE tenant_id = 1;
DELETE FROM users WHERE tenant_id = 1;
DELETE FROM tenants WHERE id = 1;

-- Insert test tenant
INSERT INTO tenants (id, name, display_name, is_active, created_at, updated_at) 
VALUES (1, 'Test Family Trust', 'Test Family Trust', TRUE, NOW(), NOW());

-- Insert test users
INSERT INTO users (id, tenant_id, cognito_user_id, cognito_username, first_name, last_name, status, created_at, updated_at) VALUES
('11111111-1111-1111-1111-111111111111', 1, 'test-cognito-1', 'testuser1', 'John', 'Smith', 'active', NOW(), NOW()),
('22222222-2222-2222-2222-222222222222', 1, 'test-cognito-2', 'testuser2', 'Jane', 'Smith', 'active', NOW(), NOW());

-- Insert test personas
INSERT INTO personas (id, tenant_id, first_name, last_name, date_of_birth, is_living, status, created_at, updated_at) VALUES
('33333333-3333-3333-3333-333333333333', 1, 'John', 'Smith', '1970-01-15', TRUE, 'active', NOW(), NOW()),
('44444444-4444-4444-4444-444444444444', 1, 'Jane', 'Smith', '1975-03-22', TRUE, 'active', NOW(), NOW()),
('55555555-5555-5555-5555-555555555555', 1, 'Michael', 'Smith', '2000-07-10', TRUE, 'active', NOW(), NOW());

-- Insert test family circles
INSERT INTO fwd_family_circles (id, tenant_id, name, description, owner_user_id, status, created_at, updated_at) VALUES
('66666666-6666-6666-6666-666666666666', 1, 'Smith Family Circle', 'Smith family wealth management', '11111111-1111-1111-1111-111111111111', 'active', NOW(), NOW());

-- Insert FFC memberships
INSERT INTO ffc_personas (id, tenant_id, ffc_id, persona_id, ffc_role, joined_at, invited_at, is_active, created_at) VALUES
('77777777-7777-7777-7777-777777777777', 1, '66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', 'owner', NOW(), NOW(), TRUE, NOW()),
('88888888-8888-8888-8888-888888888888', 1, '66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', 'beneficiary', NOW(), NOW(), TRUE, NOW()),
('99999999-9999-9999-9999-999999999999', 1, '66666666-6666-6666-6666-666666666666', '55555555-5555-5555-5555-555555555555', 'beneficiary', NOW(), NOW(), TRUE, NOW());

-- Insert test assets
INSERT INTO assets (id, tenant_id, category_id, name, description, estimated_value, currency_code, status, created_at, updated_at) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, (SELECT id FROM asset_categories WHERE name = 'Personal Property' LIMIT 1), 'Family Home', 'Primary residence', 500000, 'USD', 'active', NOW(), NOW()),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 1, (SELECT id FROM asset_categories WHERE name = 'Trust' LIMIT 1), 'Family Trust', 'Revocable living trust', 1000000, 'USD', 'active', NOW(), NOW());

-- Insert asset ownership
INSERT INTO asset_persona (id, tenant_id, asset_id, persona_id, ownership_percentage, ownership_type, created_at) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccccc', 1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 50, 'direct', NOW()),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 50, 'direct', NOW()),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 1, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 100, 'trust', NOW());

-- Insert asset permissions
INSERT INTO asset_permissions (id, tenant_id, asset_id, persona_id, permission_level, granted_by_persona_id, granted_at, created_at) VALUES
('ffffffff-ffff-ffff-ffff-ffffffffffff', 1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', 'read', '33333333-3333-3333-3333-333333333333', NOW(), NOW()),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 1, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444', 'edit', '33333333-3333-3333-3333-333333333333', NOW(), NOW());

SELECT 'Test data inserted successfully!' as result;