/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/create_ffc_step1.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateFfcStep1' parameters type */
export type ICreateFfcStep1Params = void;

/** 'CreateFfcStep1' return type */
export interface ICreateFfcStep1Result {
  description: string | null;
  id: string;
  is_active: boolean | null;
  name: string;
  owner_user_id: string;
  tenant_id: number;
}

/** 'CreateFfcStep1' query type */
export interface ICreateFfcStep1Query {
  params: ICreateFfcStep1Params;
  result: ICreateFfcStep1Result;
}

const createFfcStep1IR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_ffc() - Step 1\n-- Type: Single INSERT\n-- Description: Create a new Forward Family Circle\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_owner_user_id UUID - Owner user ID\n--   $3: p_name TEXT - FFC name\n--   $4: p_description TEXT - FFC description (optional)\n-- Returns: Created FFC record\n-- ================================================================\n\n-- Step 1 of 2: Create the FFC\n-- Step 2 (create_ffc_step2.sql) adds the owner as a member\n\nINSERT INTO fwd_family_circles (\n    tenant_id,\n    owner_user_id,\n    name,\n    description,\n    is_active,\n    status,\n    created_at,\n    updated_at\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::TEXT,\n    $4::TEXT,\n    TRUE,\n    'active',\n    NOW(),\n    NOW()\n)\nRETURNING \n    id,\n    tenant_id,\n    owner_user_id,\n    name,\n    description,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_ffc() - Step 1
 * -- Type: Single INSERT
 * -- Description: Create a new Forward Family Circle
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_owner_user_id UUID - Owner user ID
 * --   $3: p_name TEXT - FFC name
 * --   $4: p_description TEXT - FFC description (optional)
 * -- Returns: Created FFC record
 * -- ================================================================
 * 
 * -- Step 1 of 2: Create the FFC
 * -- Step 2 (create_ffc_step2.sql) adds the owner as a member
 * 
 * INSERT INTO fwd_family_circles (
 *     tenant_id,
 *     owner_user_id,
 *     name,
 *     description,
 *     is_active,
 *     status,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::TEXT,
 *     $4::TEXT,
 *     TRUE,
 *     'active',
 *     NOW(),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     tenant_id,
 *     owner_user_id,
 *     name,
 *     description,
 *     is_active
 * ```
 */
export const createFfcStep1 = new PreparedQuery<ICreateFfcStep1Params,ICreateFfcStep1Result>(createFfcStep1IR);


