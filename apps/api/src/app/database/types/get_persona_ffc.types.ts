/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/personas/get_persona_ffc.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

/** 'GetPersonaFfc' parameters type */
export type IGetPersonaFfcParams = void;

/** 'GetPersonaFfc' return type */
export interface IGetPersonaFfcResult {
  ffc_created_at: Date | null;
  ffc_id: string;
  ffc_name: string;
  ffc_role: ffc_role_enum;
  is_active: boolean | null;
  persona_id: string;
}

/** 'GetPersonaFfc' query type */
export interface IGetPersonaFfcQuery {
  params: IGetPersonaFfcParams;
  result: IGetPersonaFfcResult;
}

const getPersonaFfcIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Name: get_persona_ffc\n-- Type: SELECT\n-- Description: Get FFC ID for a persona\n-- Parameters:\n--   $1: p_persona_id UUID - Persona ID\n-- Returns: FFC record\n-- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()\n-- ================================================================\n\nSELECT \n    fp.ffc_id,\n    fp.persona_id,\n    fp.ffc_role,\n    fp.is_active,\n    f.name as ffc_name,\n    f.created_at as ffc_created_at\nFROM ffc_personas fp\nJOIN fwd_family_circles f ON fp.ffc_id = f.id\nWHERE \n    fp.persona_id = $1::UUID\n    AND fp.is_active = TRUE\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Name: get_persona_ffc
 * -- Type: SELECT
 * -- Description: Get FFC ID for a persona
 * -- Parameters:
 * --   $1: p_persona_id UUID - Persona ID
 * -- Returns: FFC record
 * -- Used by: QuilttIntegrationService.createFinancialAssetFromQuiltt()
 * -- ================================================================
 * 
 * SELECT 
 *     fp.ffc_id,
 *     fp.persona_id,
 *     fp.ffc_role,
 *     fp.is_active,
 *     f.name as ffc_name,
 *     f.created_at as ffc_created_at
 * FROM ffc_personas fp
 * JOIN fwd_family_circles f ON fp.ffc_id = f.id
 * WHERE 
 *     fp.persona_id = $1::UUID
 *     AND fp.is_active = TRUE
 * LIMIT 1
 * ```
 */
export const getPersonaFfc = new PreparedQuery<IGetPersonaFfcParams,IGetPersonaFfcResult>(getPersonaFfcIR);


