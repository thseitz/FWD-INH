/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/check_payment_method_owner.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

/** 'CheckPaymentMethodOwner' parameters type */
export type ICheckPaymentMethodOwnerParams = void;

/** 'CheckPaymentMethodOwner' return type */
export interface ICheckPaymentMethodOwnerResult {
  id: string;
  is_owner: boolean | null;
  status: status_enum;
  tenant_id: number;
  user_id: string;
  validation_message: string | null;
}

/** 'CheckPaymentMethodOwner' query type */
export interface ICheckPaymentMethodOwnerQuery {
  params: ICheckPaymentMethodOwnerParams;
  result: ICheckPaymentMethodOwnerResult;
}

const checkPaymentMethodOwnerIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_delete_payment_method (Step 1)\n-- Type: SELECT for validation\n-- Description: Verify payment method ownership\n-- Parameters:\n--   $1: p_payment_method_id UUID - Payment method ID\n--   $2: p_user_id UUID - User attempting deletion\n-- Returns: Owner verification result\n-- ================================================================\n\n-- Check if user owns the payment method\n\nSELECT \n    id,\n    user_id,\n    status,\n    tenant_id,\n    CASE \n        WHEN user_id = $2::UUID THEN TRUE\n        ELSE FALSE\n    END as is_owner,\n    CASE\n        WHEN id IS NULL THEN 'Payment method not found'\n        WHEN user_id != $2::UUID THEN 'User does not own this payment method'\n        WHEN status = 'deleted' THEN 'Payment method already deleted'\n        ELSE 'OK'\n    END as validation_message\nFROM payment_methods\nWHERE id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_delete_payment_method (Step 1)
 * -- Type: SELECT for validation
 * -- Description: Verify payment method ownership
 * -- Parameters:
 * --   $1: p_payment_method_id UUID - Payment method ID
 * --   $2: p_user_id UUID - User attempting deletion
 * -- Returns: Owner verification result
 * -- ================================================================
 * 
 * -- Check if user owns the payment method
 * 
 * SELECT 
 *     id,
 *     user_id,
 *     status,
 *     tenant_id,
 *     CASE 
 *         WHEN user_id = $2::UUID THEN TRUE
 *         ELSE FALSE
 *     END as is_owner,
 *     CASE
 *         WHEN id IS NULL THEN 'Payment method not found'
 *         WHEN user_id != $2::UUID THEN 'User does not own this payment method'
 *         WHEN status = 'deleted' THEN 'Payment method already deleted'
 *         ELSE 'OK'
 *     END as validation_message
 * FROM payment_methods
 * WHERE id = $1::UUID
 * ```
 */
export const checkPaymentMethodOwner = new PreparedQuery<ICheckPaymentMethodOwnerParams,ICheckPaymentMethodOwnerResult>(checkPaymentMethodOwnerIR);


