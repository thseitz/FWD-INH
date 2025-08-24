/** Types generated for queries found in "apps/api/src/app/database/queries/06_communications/invitations/create_invitation.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

export type invitation_status_enum = 'accepted' | 'approved' | 'cancelled' | 'declined' | 'expired' | 'phone_verified' | 'sent';

/** 'CreateInvitation' parameters type */
export type ICreateInvitationParams = void;

/** 'CreateInvitation' return type */
export interface ICreateInvitationResult {
  email_verification_code: string | null;
  id: string;
  invitee_name: string;
  phone_verification_code: string | null;
  proposed_role: ffc_role_enum;
  sent_at: Date | null;
  status: invitation_status_enum;
}

/** 'CreateInvitation' query type */
export interface ICreateInvitationQuery {
  params: ICreateInvitationParams;
  result: ICreateInvitationResult;
}

const createInvitationIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_invitation()\n-- Type: Single INSERT with Generated Values\n-- Description: Create FFC invitation with verification codes\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_ffc_id UUID - FFC ID\n--   $3: p_invitee_email_id UUID - Invitee's email ID\n--   $4: p_invitee_phone_id UUID - Invitee's phone ID\n--   $5: p_role ffc_role_enum - Proposed role\n--   $6: p_invited_by UUID - Inviter user ID\n--   $7: p_persona_first_name TEXT - Invitee first name\n--   $8: p_persona_last_name TEXT - Invitee last name\n-- Returns: Created invitation record\n-- ================================================================\n\n-- This query creates an FFC invitation with generated verification codes\n-- Uses PostgreSQL random functions to generate 6-digit codes\n\nINSERT INTO ffc_invitations (\n    tenant_id,\n    ffc_id,\n    inviter_user_id,\n    invitee_email_id,\n    invitee_phone_id,\n    invitee_name,\n    proposed_role,\n    email_verification_code,\n    phone_verification_code,\n    status,\n    sent_at\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $6::UUID,\n    $3::UUID,\n    $4::UUID,\n    $7::TEXT || ' ' || $8::TEXT,\n    $5::ffc_role_enum,\n    LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),\n    LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),\n    'sent',\n    NOW()\n)\nRETURNING \n    id,\n    invitee_name,\n    proposed_role,\n    email_verification_code,\n    phone_verification_code,\n    status,\n    sent_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_invitation()
 * -- Type: Single INSERT with Generated Values
 * -- Description: Create FFC invitation with verification codes
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_ffc_id UUID - FFC ID
 * --   $3: p_invitee_email_id UUID - Invitee's email ID
 * --   $4: p_invitee_phone_id UUID - Invitee's phone ID
 * --   $5: p_role ffc_role_enum - Proposed role
 * --   $6: p_invited_by UUID - Inviter user ID
 * --   $7: p_persona_first_name TEXT - Invitee first name
 * --   $8: p_persona_last_name TEXT - Invitee last name
 * -- Returns: Created invitation record
 * -- ================================================================
 * 
 * -- This query creates an FFC invitation with generated verification codes
 * -- Uses PostgreSQL random functions to generate 6-digit codes
 * 
 * INSERT INTO ffc_invitations (
 *     tenant_id,
 *     ffc_id,
 *     inviter_user_id,
 *     invitee_email_id,
 *     invitee_phone_id,
 *     invitee_name,
 *     proposed_role,
 *     email_verification_code,
 *     phone_verification_code,
 *     status,
 *     sent_at
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $6::UUID,
 *     $3::UUID,
 *     $4::UUID,
 *     $7::TEXT || ' ' || $8::TEXT,
 *     $5::ffc_role_enum,
 *     LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),
 *     LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0'),
 *     'sent',
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     invitee_name,
 *     proposed_role,
 *     email_verification_code,
 *     phone_verification_code,
 *     status,
 *     sent_at
 * ```
 */
export const createInvitation = new PreparedQuery<ICreateInvitationParams,ICreateInvitationResult>(createInvitationIR);


