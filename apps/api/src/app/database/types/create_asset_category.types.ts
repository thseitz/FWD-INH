/** Types generated for queries found in "apps/api/src/app/database/queries/02_assets/categories/create_asset_category.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateAssetCategory' parameters type */
export type ICreateAssetCategoryParams = void;

/** 'CreateAssetCategory' return type */
export interface ICreateAssetCategoryResult {
  code: string;
  description: string | null;
  icon: string | null;
  id: string;
  is_active: boolean | null;
  name: string;
  sort_order: number | null;
}

/** 'CreateAssetCategory' query type */
export interface ICreateAssetCategoryQuery {
  params: ICreateAssetCategoryParams;
  result: ICreateAssetCategoryResult;
}

const createAssetCategoryIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_create_asset_category()\n-- Type: Single INSERT with Generated ID\n-- Description: Create new asset category\n-- Parameters:\n--   $1: p_name VARCHAR(100) - Category name\n--   $2: p_description TEXT - Category description (optional)\n--   $3: p_icon VARCHAR(50) - Icon identifier (optional)\n--   $4: p_sort_order INTEGER - Sort order (default 999)\n-- Returns: Created category record\n-- ================================================================\n\n-- This query creates a new asset category\n-- Generates UUID and derives code from name\n\nINSERT INTO asset_categories (\n    id,\n    name,\n    code,\n    description,\n    icon,\n    sort_order,\n    is_active,\n    created_at,\n    updated_at\n) VALUES (\n    gen_random_uuid(),\n    $1::VARCHAR(100),\n    UPPER(REPLACE($1::VARCHAR(100), ' ', '_')),\n    $2::TEXT,\n    $3::VARCHAR(50),\n    COALESCE($4::INTEGER, 999),\n    TRUE,\n    NOW(),\n    NOW()\n)\nRETURNING \n    id,\n    name,\n    code,\n    description,\n    icon,\n    sort_order,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_create_asset_category()
 * -- Type: Single INSERT with Generated ID
 * -- Description: Create new asset category
 * -- Parameters:
 * --   $1: p_name VARCHAR(100) - Category name
 * --   $2: p_description TEXT - Category description (optional)
 * --   $3: p_icon VARCHAR(50) - Icon identifier (optional)
 * --   $4: p_sort_order INTEGER - Sort order (default 999)
 * -- Returns: Created category record
 * -- ================================================================
 * 
 * -- This query creates a new asset category
 * -- Generates UUID and derives code from name
 * 
 * INSERT INTO asset_categories (
 *     id,
 *     name,
 *     code,
 *     description,
 *     icon,
 *     sort_order,
 *     is_active,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     gen_random_uuid(),
 *     $1::VARCHAR(100),
 *     UPPER(REPLACE($1::VARCHAR(100), ' ', '_')),
 *     $2::TEXT,
 *     $3::VARCHAR(50),
 *     COALESCE($4::INTEGER, 999),
 *     TRUE,
 *     NOW(),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     name,
 *     code,
 *     description,
 *     icon,
 *     sort_order,
 *     is_active
 * ```
 */
export const createAssetCategory = new PreparedQuery<ICreateAssetCategoryParams,ICreateAssetCategoryResult>(createAssetCategoryIR);


