/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/check_payment_method_usage.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CheckPaymentMethodUsage' parameters type */
export type ICheckPaymentMethodUsageParams = void;

/** 'CheckPaymentMethodUsage' return type */
export interface ICheckPaymentMethodUsageResult {
  is_in_use: boolean | null;
}

/** 'CheckPaymentMethodUsage' query type */
export interface ICheckPaymentMethodUsageQuery {
  params: ICheckPaymentMethodUsageParams;
  result: ICheckPaymentMethodUsageResult;
}

const checkPaymentMethodUsageIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_check_payment_method_usage()\n-- Type: Simple SELECT Query\n-- Description: Check if payment method is in use\n-- Parameters:\n--   $1: p_payment_method_id UUID - Payment method ID to check\n--   $2: p_tenant_id INTEGER - Tenant ID (optional, not used)\n-- Returns: Boolean indicating if payment method is in use\n-- ================================================================\n\n-- This query checks if a payment method is in use\n-- Uses the payment_methods_with_usage view\n\nSELECT COALESCE(is_in_use, FALSE) as is_in_use\nFROM payment_methods_with_usage\nWHERE id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_check_payment_method_usage()
 * -- Type: Simple SELECT Query
 * -- Description: Check if payment method is in use
 * -- Parameters:
 * --   $1: p_payment_method_id UUID - Payment method ID to check
 * --   $2: p_tenant_id INTEGER - Tenant ID (optional, not used)
 * -- Returns: Boolean indicating if payment method is in use
 * -- ================================================================
 * 
 * -- This query checks if a payment method is in use
 * -- Uses the payment_methods_with_usage view
 * 
 * SELECT COALESCE(is_in_use, FALSE) as is_in_use
 * FROM payment_methods_with_usage
 * WHERE id = $1::UUID
 * ```
 */
export const checkPaymentMethodUsage = new PreparedQuery<ICheckPaymentMethodUsageParams,ICheckPaymentMethodUsageResult>(checkPaymentMethodUsageIR);


