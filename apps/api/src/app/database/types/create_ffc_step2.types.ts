/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/create_ffc_step2.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ffc_role_enum = 'advisor' | 'beneficiary' | 'non_beneficiary' | 'owner';

/** 'CreateFfcStep2' parameters type */
export type ICreateFfcStep2Params = void;

/** 'CreateFfcStep2' return type */
export interface ICreateFfcStep2Result {
  ffc_id: string;
  ffc_role: ffc_role_enum;
  joined_at: Date | null;
  persona_id: string;
}

/** 'CreateFfcStep2' query type */
export interface ICreateFfcStep2Query {
  params: ICreateFfcStep2Params;
  result: ICreateFfcStep2Result;
}

const createFfcStep2IR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_ffc() - Step 2\n-- Type: Conditional INSERT\n-- Description: Add owner to FFC as member\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_ffc_id UUID - FFC ID (from step 1)\n--   $3: p_owner_user_id UUID - Owner user ID\n-- Returns: Created FFC member record (if persona exists)\n-- ================================================================\n\n-- Step 2 of 2: Add owner as FFC member\n-- Only executes if owner has a persona\n-- Service layer should handle this conditionally based on persona lookup\n\nINSERT INTO ffc_personas (\n    tenant_id,\n    ffc_id,\n    persona_id,\n    ffc_role,\n    joined_at,\n    created_at,\n    updated_at\n)\nSELECT \n    $1::INTEGER,\n    $2::UUID,\n    p.id,\n    'owner'::ffc_role_enum,\n    NOW(),\n    NOW(),\n    NOW()\nFROM personas p\nWHERE p.user_id = $3::UUID\n  AND p.tenant_id = $1::INTEGER\nLIMIT 1\nON CONFLICT (ffc_id, persona_id) DO UPDATE SET\n    updated_at = NOW()\nRETURNING \n    ffc_id,\n    persona_id,\n    ffc_role,\n    joined_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_ffc() - Step 2
 * -- Type: Conditional INSERT
 * -- Description: Add owner to FFC as member
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_ffc_id UUID - FFC ID (from step 1)
 * --   $3: p_owner_user_id UUID - Owner user ID
 * -- Returns: Created FFC member record (if persona exists)
 * -- ================================================================
 * 
 * -- Step 2 of 2: Add owner as FFC member
 * -- Only executes if owner has a persona
 * -- Service layer should handle this conditionally based on persona lookup
 * 
 * INSERT INTO ffc_personas (
 *     tenant_id,
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     joined_at,
 *     created_at,
 *     updated_at
 * )
 * SELECT 
 *     $1::INTEGER,
 *     $2::UUID,
 *     p.id,
 *     'owner'::ffc_role_enum,
 *     NOW(),
 *     NOW(),
 *     NOW()
 * FROM personas p
 * WHERE p.user_id = $3::UUID
 *   AND p.tenant_id = $1::INTEGER
 * LIMIT 1
 * ON CONFLICT (ffc_id, persona_id) DO UPDATE SET
 *     updated_at = NOW()
 * RETURNING 
 *     ffc_id,
 *     persona_id,
 *     ffc_role,
 *     joined_at
 * ```
 */
export const createFfcStep2 = new PreparedQuery<ICreateFfcStep2Params,ICreateFfcStep2Result>(createFfcStep2IR);


