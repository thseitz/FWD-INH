/** Types generated for queries found in "apps/api/src/app/database/queries/12_stored_procedures/helpers/delete_advisor_company.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'DeleteAdvisorCompany' parameters type */
export type IDeleteAdvisorCompanyParams = void;

/** 'DeleteAdvisorCompany' return type */
export interface IDeleteAdvisorCompanyResult {
  company_name: string;
  company_type: string;
  id: string;
  is_active: boolean | null;
}

/** 'DeleteAdvisorCompany' query type */
export interface IDeleteAdvisorCompanyQuery {
  params: IDeleteAdvisorCompanyParams;
  result: IDeleteAdvisorCompanyResult;
}

const deleteAdvisorCompanyIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_manage_advisor_company() - DELETE action\n-- Type: UPDATE (soft delete)\n-- Description: Soft delete advisor company by setting is_active to FALSE\n-- Parameters:\n--   $1: p_company_id UUID - Company ID to delete\n-- Returns: Deleted advisor company record\n-- NOTE: Service layer should handle audit logging separately\n-- ================================================================\n\n-- This query performs a soft delete by setting is_active to FALSE\n\nUPDATE advisor_companies SET\n    is_active = FALSE,\n    updated_at = NOW()\nWHERE id = $1::UUID\n  AND tenant_id = COALESCE(\n      CASE \n          WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n          THEN NULL\n          ELSE current_setting('app.current_tenant_id', true)::INTEGER\n      END,\n      1\n  )\nRETURNING \n    id,\n    company_name,\n    company_type,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_manage_advisor_company() - DELETE action
 * -- Type: UPDATE (soft delete)
 * -- Description: Soft delete advisor company by setting is_active to FALSE
 * -- Parameters:
 * --   $1: p_company_id UUID - Company ID to delete
 * -- Returns: Deleted advisor company record
 * -- NOTE: Service layer should handle audit logging separately
 * -- ================================================================
 * 
 * -- This query performs a soft delete by setting is_active to FALSE
 * 
 * UPDATE advisor_companies SET
 *     is_active = FALSE,
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
 *     is_active
 * ```
 */
export const deleteAdvisorCompany = new PreparedQuery<IDeleteAdvisorCompanyParams,IDeleteAdvisorCompanyResult>(deleteAdvisorCompanyIR);


