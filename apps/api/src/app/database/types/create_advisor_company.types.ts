/** Types generated for queries found in "apps/api/src/app/database/queries/12_stored_procedures/helpers/create_advisor_company.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CreateAdvisorCompany' parameters type */
export type ICreateAdvisorCompanyParams = void;

/** 'CreateAdvisorCompany' return type */
export interface ICreateAdvisorCompanyResult {
  company_name: string;
  company_type: string;
  id: string;
  is_active: boolean | null;
  primary_contact_name: string | null;
  website_url: string | null;
}

/** 'CreateAdvisorCompany' query type */
export interface ICreateAdvisorCompanyQuery {
  params: ICreateAdvisorCompanyParams;
  result: ICreateAdvisorCompanyResult;
}

const createAdvisorCompanyIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_manage_advisor_company() - CREATE action\n-- Type: INSERT\n-- Description: Create new advisor company\n-- Parameters:\n--   $1: p_company_name TEXT - Company name\n--   $2: p_company_type VARCHAR(50) - Company type (default 'General')\n--   $3: p_contact_phone VARCHAR(20) - Primary contact phone\n--   $4: p_website TEXT - Website URL\n-- Returns: New advisor company record\n-- NOTE: Service layer should handle audit logging separately\n-- ================================================================\n\n-- This query creates a new advisor company\n\nINSERT INTO advisor_companies (\n    tenant_id,\n    company_name,\n    company_type,\n    primary_contact_name,  -- Note: storing phone in contact name field\n    website_url,\n    is_active,\n    created_at,\n    updated_at\n) VALUES (\n    COALESCE(\n        CASE \n            WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_tenant_id', true)::INTEGER\n        END,\n        1\n    ),\n    $1::TEXT,\n    COALESCE($2::VARCHAR(50), 'General'),\n    $3::VARCHAR(20),  -- Primary contact phone\n    $4::TEXT,\n    TRUE,\n    NOW(),\n    NOW()\n)\nRETURNING \n    id,\n    company_name,\n    company_type,\n    primary_contact_name,\n    website_url,\n    is_active"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_manage_advisor_company() - CREATE action
 * -- Type: INSERT
 * -- Description: Create new advisor company
 * -- Parameters:
 * --   $1: p_company_name TEXT - Company name
 * --   $2: p_company_type VARCHAR(50) - Company type (default 'General')
 * --   $3: p_contact_phone VARCHAR(20) - Primary contact phone
 * --   $4: p_website TEXT - Website URL
 * -- Returns: New advisor company record
 * -- NOTE: Service layer should handle audit logging separately
 * -- ================================================================
 * 
 * -- This query creates a new advisor company
 * 
 * INSERT INTO advisor_companies (
 *     tenant_id,
 *     company_name,
 *     company_type,
 *     primary_contact_name,  -- Note: storing phone in contact name field
 *     website_url,
 *     is_active,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     COALESCE(
 *         CASE 
 *             WHEN current_setting('app.current_tenant_id', true) IS NULL OR current_setting('app.current_tenant_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_tenant_id', true)::INTEGER
 *         END,
 *         1
 *     ),
 *     $1::TEXT,
 *     COALESCE($2::VARCHAR(50), 'General'),
 *     $3::VARCHAR(20),  -- Primary contact phone
 *     $4::TEXT,
 *     TRUE,
 *     NOW(),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     company_name,
 *     company_type,
 *     primary_contact_name,
 *     website_url,
 *     is_active
 * ```
 */
export const createAdvisorCompany = new PreparedQuery<ICreateAdvisorCompanyParams,ICreateAdvisorCompanyResult>(createAdvisorCompanyIR);


