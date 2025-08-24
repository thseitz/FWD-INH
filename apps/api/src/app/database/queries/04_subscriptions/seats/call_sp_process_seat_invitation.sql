/* @name callSpProcessSeatInvitation */
-- ================================================================
-- Wrapper for: sp_process_seat_invitation()
-- Type: PROCEDURE call wrapper
-- Description: Process seat assignment invitation
-- Parameters:
--   $1: p_invitation_id UUID - Invitation ID
--   $2: p_subscription_id UUID - Subscription ID
--   $3: p_persona_id UUID - Persona ID
--   $4: p_seat_type seat_type_enum - Seat type (default 'pro')
-- Returns: void (procedure)
-- ================================================================

-- Call stored procedure to process seat invitation

CALL sp_process_seat_invitation(
    $1::UUID,                                     -- p_invitation_id
    $2::UUID,                                     -- p_subscription_id
    $3::UUID,                                     -- p_persona_id
    COALESCE($4::seat_type_enum, 'pro')         -- p_seat_type
);