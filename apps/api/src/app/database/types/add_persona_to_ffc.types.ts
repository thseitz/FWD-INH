/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/add_persona_to_ffc.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

/** 'AddPersonaToFfc' parameters type */
export type IAddPersonaToFfcParams = void;

/** 'AddPersonaToFfc' return type */
export interface IAddPersonaToFfcResult {
  ffc_id: string;
  ffc_role: ffc_role_enum;
  joined_at: Date | null;
  persona_id: string;
  updated_at: Date | null;
}

/** 'AddPersonaToFfc' query type */
export interface IAddPersonaToFfcQuery {
  params: IAddPersonaToFfcParams;
  result: IAddPersonaToFfcResult;
}

const addPersonaToFfcIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_add_persona_to_ffc()\n-- Type: INSERT with ON CONFLICT UPDATE (UPSERT)\n-- Description: Add or update persona in FFC\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_ffc_id UUID - FFC ID\n--   $3: p_persona_id UUID - Persona ID\n--   $4: p_role ffc_role_enum - Role in FFC\n--   $5: p_added_by UUID - User adding the persona\n-- Returns: FFC persona record\n-- ================================================================\n\n-- This query adds a persona to an FFC or updates their role if they already exist\n-- Uses ON CONFLICT to handle both insert and update cases\n\nINSERT INTO ffc_personas (\n    tenant_id,\n    ffc_id,\n    persona_id,\n    ffc_role,\n    joined_at,\n    created_at,\n    created_by,\n    updated_at,\n    updated_by\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::UUID,\n    $4::ffc_role_enum,\n    NOW(),\n    NOW(),\n    $5::UUID,\n    NOW(),\n    $5::UUID\n)\nON CONFLICT (ffc_id, persona_id) DO UPDATE SET\n    ffc_role = EXCLUDED.ffc_role,\n    updated_at = NOW(),\n    updated_by = EXCLUDED.updated_by\nRETURNING \n    ffc_id,\n    persona_id,\n    ffc_role,\n    joined_at,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_add_persona_to_ffc()
 * -- Type: INSERT with ON CONFLICT UPDATE (UPSERT)
 * -- Description: Add or update persona in FFC
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_ffc_id UUID - FFC ID
 * --   $3: p_persona_id UUID - Persona ID
 * --   $4: p_role ffc_role_enum - Role in FFC
 * --   $5: p_added_by UUID - User adding the persona
 * -- Returns: FFC persona record
 * -- ================================================================
 * 
 * -- This query adds a persona to an FFC or updates their role if they already exist
 * -- Uses ON CONFLICT to handle both insert and update cases
 * 
 * INSERT INTO ffc_personas (
 *     tenant_id,
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     joined_at,
 *     created_at,
 *     created_by,
 *     updated_at,
 *     updated_by
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::UUID,
 *     $4::ffc_role_enum,
 *     NOW(),
 *     NOW(),
 *     $5::UUID,
 *     NOW(),
 *     $5::UUID
 * )
 * ON CONFLICT (ffc_id, persona_id) DO UPDATE SET
 *     ffc_role = EXCLUDED.ffc_role,
 *     updated_at = NOW(),
 *     updated_by = EXCLUDED.updated_by
 * RETURNING 
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     joined_at,
 *     updated_at
 * ```
 */
export const addPersonaToFfc = new PreparedQuery<IAddPersonaToFfcParams,IAddPersonaToFfcResult>(addPersonaToFfcIR);


