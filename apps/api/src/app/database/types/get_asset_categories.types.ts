/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/categories/get_asset_categories.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetAssetCategories' parameters type */
export type IGetAssetCategoriesParams = void;

/** 'GetAssetCategories' return type */
export interface IGetAssetCategoriesResult {
  category_description: string | null;
  category_icon: string | null;
  category_id: string;
  category_name: string | null;
  is_active: boolean | null;
  sort_order: number | null;
}

/** 'GetAssetCategories' query type */
export interface IGetAssetCategoriesQuery {
  params: IGetAssetCategoriesParams;
  result: IGetAssetCategoriesResult;
}

const getAssetCategoriesIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_asset_categories(p_include_inactive BOOLEAN)\n-- Type: Simple Read-Only Query\n-- Description: Get list of asset categories\n-- Parameters:\n--   $1: p_include_inactive BOOLEAN - Whether to include inactive categories (default FALSE)\n-- Returns: Table of category information\n-- ================================================================\n\n-- This query retrieves all asset categories from the system\n-- By default only returns active categories unless p_include_inactive is TRUE\n\nSELECT \n    ac.id as category_id,\n    ac.name::VARCHAR as category_name,\n    ac.description as category_description,\n    ac.icon::VARCHAR as category_icon,\n    ac.sort_order,\n    ac.is_active\nFROM asset_categories ac\nWHERE ac.is_active = TRUE OR COALESCE($1::BOOLEAN, FALSE) = TRUE\nORDER BY ac.sort_order, ac.name"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_asset_categories(p_include_inactive BOOLEAN)
 * -- Type: Simple Read-Only Query
 * -- Description: Get list of asset categories
 * -- Parameters:
 * --   $1: p_include_inactive BOOLEAN - Whether to include inactive categories (default FALSE)
 * -- Returns: Table of category information
 * -- ================================================================
 * 
 * -- This query retrieves all asset categories from the system
 * -- By default only returns active categories unless p_include_inactive is TRUE
 * 
 * SELECT 
 *     ac.id as category_id,
 *     ac.name::VARCHAR as category_name,
 *     ac.description as category_description,
 *     ac.icon::VARCHAR as category_icon,
 *     ac.sort_order,
 *     ac.is_active
 * FROM asset_categories ac
 * WHERE ac.is_active = TRUE OR COALESCE($1::BOOLEAN, FALSE) = TRUE
 * ORDER BY ac.sort_order, ac.name
 * ```
 */
export const getAssetCategories = new PreparedQuery<IGetAssetCategoriesParams,IGetAssetCategoriesResult>(getAssetCategoriesIR);


