/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/delete_payment_method.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type status_enum = 'active' | 'deleted' | 'inactive' | 'pending' | 'suspended';

/** 'DeletePaymentMethod' parameters type */
export type IDeletePaymentMethodParams = void;

/** 'DeletePaymentMethod' return type */
export interface IDeletePaymentMethodResult {
  id: string;
  status: status_enum;
  tenant_id: number;
  updated_at: Date;
  user_id: string;
}

/** 'DeletePaymentMethod' query type */
export interface IDeletePaymentMethodQuery {
  params: IDeletePaymentMethodParams;
  result: IDeletePaymentMethodResult;
}

const deletePaymentMethodIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_delete_payment_method (Step 2)\n-- Type: UPDATE (soft delete)\n-- Description: Soft delete payment method\n-- Parameters:\n--   $1: p_payment_method_id UUID - Payment method to delete\n-- Returns: Deleted payment method record\n-- NOTE: Service layer should:\n--   1. Check ownership first (check_payment_method_owner.sql)\n--   2. Check usage (check_payment_method_usage.sql - already exists)\n--   3. Execute this delete\n--   4. Log audit event\n-- ================================================================\n\n-- Soft delete the payment method\n\nUPDATE payment_methods\nSET \n    status = 'deleted',\n    updated_at = NOW()\nWHERE id = $1::UUID\n  AND status != 'deleted'  -- Prevent double deletion\nRETURNING \n    id,\n    user_id,\n    tenant_id,\n    status,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_delete_payment_method (Step 2)
 * -- Type: UPDATE (soft delete)
 * -- Description: Soft delete payment method
 * -- Parameters:
 * --   $1: p_payment_method_id UUID - Payment method to delete
 * -- Returns: Deleted payment method record
 * -- NOTE: Service layer should:
 * --   1. Check ownership first (check_payment_method_owner.sql)
 * --   2. Check usage (check_payment_method_usage.sql - already exists)
 * --   3. Execute this delete
 * --   4. Log audit event
 * -- ================================================================
 * 
 * -- Soft delete the payment method
 * 
 * UPDATE payment_methods
 * SET 
 *     status = 'deleted',
 *     updated_at = NOW()
 * WHERE id = $1::UUID
 *   AND status != 'deleted'  -- Prevent double deletion
 * RETURNING 
 *     id,
 *     user_id,
 *     tenant_id,
 *     status,
 *     updated_at
 * ```
 */
export const deletePaymentMethod = new PreparedQuery<IDeletePaymentMethodParams,IDeletePaymentMethodResult>(deletePaymentMethodIR);


