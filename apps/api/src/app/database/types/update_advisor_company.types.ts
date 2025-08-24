/** Types generated for queries found in "apps/api/src/app/database/queries/12_stored_procedures/helpers/update_advisor_company.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'UpdateAdvisorCompany' parameters type */
export type IUpdateAdvisorCompanyParams = void;

/** 'UpdateAdvisorCompany' return type */
export interface IUpdateAdvisorCompanyResult {
  company_name: string;
  company_type: string;
  id: string;
  is_active: boolean | null;
  primary_contact_name: string | null;
  website_url: string | null;
}

/** 'UpdateAdvisorCompany' query type */
export interface IUpdateAdvisorCompanyQuery {
  params: IUpdateAdvisorCompanyParams;
  result: IUpdateAdvisorCompanyResult;
}

const updateAdvisorCompanyIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_manage_advisor_company() - UPDATE action\n-- Type: UPDATE\n-- Description: Update existing advisor company\n-- Parameters:\n--   $1: p_company_id UUID - Company ID to update\n--   $2: p_company_name TEXT - Company name (optional)\n--   $3: p_company_type VARCHAR(50) - Company type (optional)\n--   $4: p_contact_phone VARCHAR(20) - Primary contact phone (optional)\n--   $5: p_website TEXT - Website URL (optional)\n-- Returns: Updated advisor company record\n-- NOTE: Service layer should handle audit logging separately\n-- ================================================================\n\n-- This query updates an existing advisor company\n-- Only provided fields will be updated\n\nUPDATE advisor_companies SET\n    company_name = COALESCE($2::TEXT, company_name),\n    company_type = COALESCE($3::VARCHAR(50), company_type),\n    primary_contact_name = COALESCE($4::VARCHAR(20), primary_contact_name),\n    website_url = COALESCE($5::TEXT, website_url),\n    updated_at = NOW()\nWHERE id = $1::UUID\n  AND tenant_id = COALESCE(\n      CASE \n          WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n          THEN NULL\n          ELSE current_setting('app.current_tenant_id', true)::INTEGER\n      END,\n      1\n  )\nRETURNING \n    id,\n    company_name,\n    company_type,\n    primary_contact_name,\n    website_url,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_manage_advisor_company() - UPDATE action
 * -- Type: UPDATE
 * -- Description: Update existing advisor company
 * -- Parameters:
 * --   $1: p_company_id UUID - Company ID to update
 * --   $2: p_company_name TEXT - Company name (optional)
 * --   $3: p_company_type VARCHAR(50) - Company type (optional)
 * --   $4: p_contact_phone VARCHAR(20) - Primary contact phone (optional)
 * --   $5: p_website TEXT - Website URL (optional)
 * -- Returns: Updated advisor company record
 * -- NOTE: Service layer should handle audit logging separately
 * -- ================================================================
 * 
 * -- This query updates an existing advisor company
 * -- Only provided fields will be updated
 * 
 * UPDATE advisor_companies SET
 *     company_name = COALESCE($2::TEXT, company_name),
 *     company_type = COALESCE($3::VARCHAR(50), company_type),
 *     primary_contact_name = COALESCE($4::VARCHAR(20), primary_contact_name),
 *     website_url = COALESCE($5::TEXT, website_url),
 *     updated_at = NOW()
 * WHERE id = $1::UUID
 *   AND tenant_id = COALESCE(
 *       CASE 
 *           WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *           THEN NULL
 *           ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *       END,
 *       1
 *   )
 * RETURNING 
 *     id,
 *     company_name,
 *     company_type,
 *     primary_contact_name,
 *     website_url,
 *     is_active
 * ```
 */
export const updateAdvisorCompany = new PreparedQuery<IUpdateAdvisorCompanyParams,IUpdateAdvisorCompanyResult>(updateAdvisorCompanyIR);


