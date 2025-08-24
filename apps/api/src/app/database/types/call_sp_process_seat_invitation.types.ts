/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/seats/call_sp_process_seat_invitation.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpProcessSeatInvitation' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpProcessSeatInvitationResult = never;

/** Query 'CallSpProcessSeatInvitation' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpProcessSeatInvitationParams = never;

const callSpProcessSeatInvitationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_process_seat_invitation()\n-- Type: PROCEDURE call wrapper\n-- Description: Process seat assignment invitation\n-- Parameters:\n--   $1: p_invitation_id UUID - Invitation ID\n--   $2: p_subscription_id UUID - Subscription ID\n--   $3: p_persona_id UUID - Persona ID\n--   $4: p_seat_type seat_type_enum - Seat type (default 'pro')\n-- Returns: void (procedure)\n-- ================================================================\n\n-- Call stored procedure to process seat invitation\n\nCALL sp_process_seat_invitation(\n    $1::UUID,                                     -- p_invitation_id\n    $2::UUID,                                     -- p_subscription_id\n    $3::UUID,                                     -- p_persona_id\n    COALESCE($4::seat_type_enum, 'pro')         -- p_seat_type\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_process_seat_invitation()
 * -- Type: PROCEDURE call wrapper
 * -- Description: Process seat assignment invitation
 * -- Parameters:
 * --   $1: p_invitation_id UUID - Invitation ID
 * --   $2: p_subscription_id UUID - Subscription ID
 * --   $3: p_persona_id UUID - Persona ID
 * --   $4: p_seat_type seat_type_enum - Seat type (default 'pro')
 * -- Returns: void (procedure)
 * -- ================================================================
 * 
 * -- Call stored procedure to process seat invitation
 * 
 * CALL sp_process_seat_invitation(
 *     $1::UUID,                                     -- p_invitation_id
 *     $2::UUID,                                     -- p_subscription_id
 *     $3::UUID,                                     -- p_persona_id
 *     COALESCE($4::seat_type_enum, 'pro')         -- p_seat_type
 * )
 * ```
 */
export const callSpProcessSeatInvitation = new PreparedQuery<ICallSpProcessSeatInvitationParams,ICallSpProcessSeatInvitationResult>(callSpProcessSeatInvitationIR);


