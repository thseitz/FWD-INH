-- ================================================================
-- Converted from: sp_create_invitation()
-- Type: Single INSERT with Generated Values
-- Description: Create FFC invitation with verification codes
-- Parameters:
--   $1: p_tenant_id INTEGER - Tenant ID
--   $2: p_ffc_id UUID - FFC ID
--   $3: p_invitee_email_id UUID - Invitee's email ID
--   $4: p_invitee_phone_id UUID - Invitee's phone ID
--   $5: p_role ffc_role_enum - Proposed role
--   $6: p_invited_by UUID - Inviter user ID
--   $7: p_persona_first_name TEXT - Invitee first name
--   $8: p_persona_last_name TEXT - Invitee last name
-- Returns: Created invitation record
-- ================================================================

-- This query creates an FFC invitation with generated verification codes
-- Uses PostgreSQL random functions to generate 6-digit codes

INSERT INTO ffc_invitations (
    tenant_id,
    ffc_id,
    inviter_user_id,
    invitee_email_id,
    invitee_phone_id,
    invitee_name,
    proposed_role,
    email_verification_code,
    phone_verification_code,
    status,
    sent_at
) VALUES (
    $1::INTEGER,
    $2::UUID,
    $6::UUID,
    $3::UUID,
    $4::UUID,
    $7::TEXT || ' ' || $8::TEXT,
    $5::ffc_role_enum,
    LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),
    LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),
    'sent',
    NOW()
)
RETURNING 
    id,
    invitee_name,
    proposed_role,
    email_verification_code,
    phone_verification_code,
    status,
    sent_at;