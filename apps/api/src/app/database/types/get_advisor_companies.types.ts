/** Types generated for queries found in "apps/api/src/app/database/queries/12_stored_procedures/helpers/get_advisor_companies.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'GetAdvisorCompanies' parameters type */
export type IGetAdvisorCompaniesParams = void;

/** 'GetAdvisorCompanies' return type */
export interface IGetAdvisorCompaniesResult {
  company_id: string;
  company_name: string;
  company_type: string;
  created_at: Date | null;
  is_active: boolean | null;
  metadata: Json | null;
  primary_contact_name: string | null;
  website_url: string | null;
}

/** 'GetAdvisorCompanies' query type */
export interface IGetAdvisorCompaniesQuery {
  params: IGetAdvisorCompaniesParams;
  result: IGetAdvisorCompaniesResult;
}

const getAdvisorCompaniesIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_get_advisor_companies()\n-- Type: Simple Read-Only Query with Search\n-- Description: List advisor companies with optional filters and search\n-- Parameters:\n--   $1: p_company_type VARCHAR(50) - Optional filter by company type\n--   $2: p_is_active BOOLEAN - Filter by active status (default TRUE)\n--   $3: p_search_term TEXT - Optional search term\n--   $4: p_limit INTEGER - Maximum records to return (default 100)\n--   $5: p_offset INTEGER - Pagination offset (default 0)\n-- Returns: List of advisor companies\n-- ================================================================\n\n-- This query retrieves advisor companies with filtering and search capabilities\n-- Supports partial text search across multiple fields\n\nSELECT \n    ac.id as company_id,\n    ac.company_name,\n    ac.company_type,\n    ac.primary_contact_name,\n    ac.website_url,\n    ac.is_active,\n    ac.created_at,\n    jsonb_build_object(\n        'license_number', ac.license_number,\n        'license_state', ac.license_state,\n        'license_expiration', ac.license_expiration\n    ) as metadata\nFROM advisor_companies ac\nWHERE \n    ac.tenant_id = COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END, \n        1\n    )\n    AND (COALESCE($2::BOOLEAN, TRUE) IS NULL OR ac.is_active = COALESCE($2::BOOLEAN, TRUE))\n    AND ($1::VARCHAR IS NULL OR ac.company_type = $1)\n    AND ($3::TEXT IS NULL OR \n         ac.company_name ILIKE '%' || $3 || '%' OR\n         ac.primary_contact_name ILIKE '%' || $3 || '%' OR\n         ac.website_url ILIKE '%' || $3 || '%')\nORDER BY ac.company_name\nLIMIT COALESCE($4::INTEGER, 100)\nOFFSET COALESCE($5::INTEGER, 0)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_get_advisor_companies()
 * -- Type: Simple Read-Only Query with Search
 * -- Description: List advisor companies with optional filters and search
 * -- Parameters:
 * --   $1: p_company_type VARCHAR(50) - Optional filter by company type
 * --   $2: p_is_active BOOLEAN - Filter by active status (default TRUE)
 * --   $3: p_search_term TEXT - Optional search term
 * --   $4: p_limit INTEGER - Maximum records to return (default 100)
 * --   $5: p_offset INTEGER - Pagination offset (default 0)
 * -- Returns: List of advisor companies
 * -- ================================================================
 * 
 * -- This query retrieves advisor companies with filtering and search capabilities
 * -- Supports partial text search across multiple fields
 * 
 * SELECT 
 *     ac.id as company_id,
 *     ac.company_name,
 *     ac.company_type,
 *     ac.primary_contact_name,
 *     ac.website_url,
 *     ac.is_active,
 *     ac.created_at,
 *     jsonb_build_object(
 *         'license_number', ac.license_number,
 *         'license_state', ac.license_state,
 *         'license_expiration', ac.license_expiration
 *     ) as metadata
 * FROM advisor_companies ac
 * WHERE 
 *     ac.tenant_id = COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END, 
 *         1
 *     )
 *     AND (COALESCE($2::BOOLEAN, TRUE) IS NULL OR ac.is_active = COALESCE($2::BOOLEAN, TRUE))
 *     AND ($1::VARCHAR IS NULL OR ac.company_type = $1)
 *     AND ($3::TEXT IS NULL OR 
 *          ac.company_name ILIKE '%' || $3 || '%' OR
 *          ac.primary_contact_name ILIKE '%' || $3 || '%' OR
 *          ac.website_url ILIKE '%' || $3 || '%')
 * ORDER BY ac.company_name
 * LIMIT COALESCE($4::INTEGER, 100)
 * OFFSET COALESCE($5::INTEGER, 0)
 * ```
 */
export const getAdvisorCompanies = new PreparedQuery<IGetAdvisorCompaniesParams,IGetAdvisorCompaniesResult>(getAdvisorCompaniesIR);


