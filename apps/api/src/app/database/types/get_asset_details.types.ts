/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/management/get_asset_details.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetAssetDetails' parameters type */
export type IGetAssetDetailsParams = void;

/** 'GetAssetDetails' return type */
export interface IGetAssetDetailsResult {
  asset_description: string | null;
  asset_id: string;
  asset_name: string;
  category_name: string;
  currency_code: string | null;
  estimated_value: string | null;
  ffc_name: string;
  last_valued_date: Date | null;
  owners: Json | null;
  status: status_enum;
  tags: Json | null;
}

/** 'GetAssetDetails' query type */
export interface IGetAssetDetailsQuery {
  params: IGetAssetDetailsParams;
  result: IGetAssetDetailsResult;
}

const getAssetDetailsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_asset_details(p_asset_id UUID, p_requesting_user UUID)\n-- Type: Read-Only Query with Access Check\n-- Description: Get detailed information about an asset\n-- Parameters:\n--   $1: p_asset_id UUID - The asset ID to get details for\n--   $2: p_requesting_user UUID - Optional user ID for access check\n-- Returns: Detailed asset information\n-- ================================================================\n\n-- This query retrieves detailed asset information including owners and tags\n-- Note: Access check is implemented via WHERE clause when user is provided\n-- If user doesn't have access, no rows will be returned\n\nSELECT \n    a.id AS asset_id,\n    a.name::TEXT AS asset_name,\n    a.description::TEXT AS asset_description,\n    ac.name::TEXT AS category_name,\n    a.estimated_value::DECIMAL AS estimated_value,\n    a.currency_code AS currency_code,\n    a.last_valued_date AS last_valued_date,\n    a.status AS status,\n    f.name::TEXT AS ffc_name,\n    (\n        SELECT jsonb_agg(jsonb_build_object(\n            'persona_id', ap.persona_id,\n            'persona_name', p.first_name || ' ' || p.last_name,\n            'ownership_type', ap.ownership_type,\n            'ownership_percentage', ap.ownership_percentage,\n            'is_primary', ap.is_primary\n        ))\n        FROM asset_persona ap\n        JOIN personas p ON ap.persona_id = p.id\n        WHERE ap.asset_id = a.id\n    ) AS owners,\n    a.tags AS tags\nFROM assets a\nJOIN asset_categories ac ON a.category_id = ac.id\nLEFT JOIN LATERAL (\n    SELECT DISTINCT f.id, f.name\n    FROM asset_persona ap\n    JOIN ffc_personas fp ON ap.persona_id = fp.persona_id\n    JOIN fwd_family_circles f ON fp.ffc_id = f.id\n    WHERE ap.asset_id = a.id\n    LIMIT 1\n) f ON true\nWHERE a.id = $1::UUID\n  -- Access check: Only apply if requesting_user is provided\n  AND ($2::UUID IS NULL OR EXISTS (\n      SELECT 1\n      FROM asset_persona ap\n      JOIN ffc_personas fp ON ap.persona_id = fp.persona_id\n      JOIN personas p ON fp.persona_id = p.id\n      WHERE ap.asset_id = a.id\n      AND p.user_id = $2::UUID\n  ))"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_asset_details(p_asset_id UUID, p_requesting_user UUID)
 * -- Type: Read-Only Query with Access Check
 * -- Description: Get detailed information about an asset
 * -- Parameters:
 * --   $1: p_asset_id UUID - The asset ID to get details for
 * --   $2: p_requesting_user UUID - Optional user ID for access check
 * -- Returns: Detailed asset information
 * -- ================================================================
 * 
 * -- This query retrieves detailed asset information including owners and tags
 * -- Note: Access check is implemented via WHERE clause when user is provided
 * -- If user doesn't have access, no rows will be returned
 * 
 * SELECT 
 *     a.id AS asset_id,
 *     a.name::TEXT AS asset_name,
 *     a.description::TEXT AS asset_description,
 *     ac.name::TEXT AS category_name,
 *     a.estimated_value::DECIMAL AS estimated_value,
 *     a.currency_code AS currency_code,
 *     a.last_valued_date AS last_valued_date,
 *     a.status AS status,
 *     f.name::TEXT AS ffc_name,
 *     (
 *         SELECT jsonb_agg(jsonb_build_object(
 *             'persona_id', ap.persona_id,
 *             'persona_name', p.first_name || ' ' || p.last_name,
 *             'ownership_type', ap.ownership_type,
 *             'ownership_percentage', ap.ownership_percentage,
 *             'is_primary', ap.is_primary
 *         ))
 *         FROM asset_persona ap
 *         JOIN personas p ON ap.persona_id = p.id
 *         WHERE ap.asset_id = a.id
 *     ) AS owners,
 *     a.tags AS tags
 * FROM assets a
 * JOIN asset_categories ac ON a.category_id = ac.id
 * LEFT JOIN LATERAL (
 *     SELECT DISTINCT f.id, f.name
 *     FROM asset_persona ap
 *     JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
 *     JOIN fwd_family_circles f ON fp.ffc_id = f.id
 *     WHERE ap.asset_id = a.id
 *     LIMIT 1
 * ) f ON true
 * WHERE a.id = $1::UUID
 *   -- Access check: Only apply if requesting_user is provided
 *   AND ($2::UUID IS NULL OR EXISTS (
 *       SELECT 1
 *       FROM asset_persona ap
 *       JOIN ffc_personas fp ON ap.persona_id = fp.persona_id
 *       JOIN personas p ON fp.persona_id = p.id
 *       WHERE ap.asset_id = a.id
 *       AND p.user_id = $2::UUID
 *   ))
 * ```
 */
export const getAssetDetails = new PreparedQuery<IGetAssetDetailsParams,IGetAssetDetailsResult>(getAssetDetailsIR);


