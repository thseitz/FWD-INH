/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/ownership/assign_asset_to_persona_upsert.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type ownership_type_enum = 'beneficiary' | 'executor' | 'owner' | 'trustee';

/** 'AssignAssetToPersonaUpsert' parameters type */
export type IAssignAssetToPersonaUpsertParams = void;

/** 'AssignAssetToPersonaUpsert' return type */
export interface IAssignAssetToPersonaUpsertResult {
  asset_id: string;
  id: string;
  is_primary: boolean | null;
  ownership_percentage: string | null;
  ownership_type: ownership_type_enum;
  persona_id: string;
  updated_at: Date | null;
}

/** 'AssignAssetToPersonaUpsert' query type */
export interface IAssignAssetToPersonaUpsertQuery {
  params: IAssignAssetToPersonaUpsertParams;
  result: IAssignAssetToPersonaUpsertResult;
}

const assignAssetToPersonaUpsertIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_assign_asset_to_persona()\n-- Type: UPSERT with conditional logic\n-- Description: Assign or update asset-persona relationship\n-- Parameters:\n--   $1: p_asset_id UUID - Asset ID\n--   $2: p_persona_id UUID - Persona ID  \n--   $3: p_ownership_type ownership_type_enum - Ownership type (default 'owner')\n--   $4: p_ownership_percentage DECIMAL(5,2) - Ownership percentage (default 100.00)\n--   $5: p_is_primary BOOLEAN - Is primary owner (default FALSE)\n--   $6: p_assigned_by UUID - User making assignment (optional)\n-- Returns: Asset-persona record\n-- NOTE: Service layer should:\n--   1. Validate total ownership doesn't exceed 100%\n--   2. Handle primary owner updates separately if needed\n--   3. Create audit log entry\n-- ================================================================\n\n-- This query inserts a new asset-persona relationship\n-- Service layer should check for existing relationship first and use UPDATE if needed\n-- If is_primary is TRUE, a separate query should unset other primary assignments\n\nINSERT INTO asset_persona (\n    tenant_id,\n    asset_id,\n    persona_id,\n    ownership_type,\n    ownership_percentage,\n    is_primary,\n    created_at,\n    updated_at,\n    created_by,\n    updated_by\n) \nSELECT\n    a.tenant_id,\n    $1::UUID,\n    $2::UUID,\n    COALESCE($3::ownership_type_enum, 'owner'::ownership_type_enum),\n    COALESCE($4::DECIMAL(5,2), 100.00),\n    COALESCE($5::BOOLEAN, FALSE),\n    NOW(),\n    NOW(),\n    COALESCE(\n        $6::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    ),\n    COALESCE(\n        $6::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\nFROM assets a\nWHERE a.id = $1::UUID\n  AND NOT EXISTS (\n    SELECT 1 FROM asset_persona ap \n    WHERE ap.asset_id = $1::UUID \n      AND ap.persona_id = $2::UUID\n  )\nRETURNING \n    id,\n    asset_id,\n    persona_id,\n    ownership_type,\n    ownership_percentage,\n    is_primary,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_assign_asset_to_persona()
 * -- Type: UPSERT with conditional logic
 * -- Description: Assign or update asset-persona relationship
 * -- Parameters:
 * --   $1: p_asset_id UUID - Asset ID
 * --   $2: p_persona_id UUID - Persona ID  
 * --   $3: p_ownership_type ownership_type_enum - Ownership type (default 'owner')
 * --   $4: p_ownership_percentage DECIMAL(5,2) - Ownership percentage (default 100.00)
 * --   $5: p_is_primary BOOLEAN - Is primary owner (default FALSE)
 * --   $6: p_assigned_by UUID - User making assignment (optional)
 * -- Returns: Asset-persona record
 * -- NOTE: Service layer should:
 * --   1. Validate total ownership doesn't exceed 100%
 * --   2. Handle primary owner updates separately if needed
 * --   3. Create audit log entry
 * -- ================================================================
 * 
 * -- This query inserts a new asset-persona relationship
 * -- Service layer should check for existing relationship first and use UPDATE if needed
 * -- If is_primary is TRUE, a separate query should unset other primary assignments
 * 
 * INSERT INTO asset_persona (
 *     tenant_id,
 *     asset_id,
 *     persona_id,
 *     ownership_type,
 *     ownership_percentage,
 *     is_primary,
 *     created_at,
 *     updated_at,
 *     created_by,
 *     updated_by
 * ) 
 * SELECT
 *     a.tenant_id,
 *     $1::UUID,
 *     $2::UUID,
 *     COALESCE($3::ownership_type_enum, 'owner'::ownership_type_enum),
 *     COALESCE($4::DECIMAL(5,2), 100.00),
 *     COALESCE($5::BOOLEAN, FALSE),
 *     NOW(),
 *     NOW(),
 *     COALESCE(
 *         $6::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     ),
 *     COALESCE(
 *         $6::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * FROM assets a
 * WHERE a.id = $1::UUID
 *   AND NOT EXISTS (
 *     SELECT 1 FROM asset_persona ap 
 *     WHERE ap.asset_id = $1::UUID 
 *       AND ap.persona_id = $2::UUID
 *   )
 * RETURNING 
 *     id,
 *     asset_id,
 *     persona_id,
 *     ownership_type,
 *     ownership_percentage,
 *     is_primary,
 *     updated_at
 * ```
 */
export const assignAssetToPersonaUpsert = new PreparedQuery<IAssignAssetToPersonaUpsertParams,IAssignAssetToPersonaUpsertResult>(assignAssetToPersonaUpsertIR);


