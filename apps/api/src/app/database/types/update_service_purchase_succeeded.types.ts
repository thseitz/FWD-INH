/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/stripe/update_service_purchase_succeeded.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type payment_status_enum = 'failed' | 'partially_refunded' | 'pending' | 'refunded' | 'succeeded';

/** 'UpdateServicePurchaseSucceeded' parameters type */
export type IUpdateServicePurchaseSucceededParams = void;

/** 'UpdateServicePurchaseSucceeded' return type */
export interface IUpdateServicePurchaseSucceededResult {
  id: string;
  purchaser_user_id: string;
  service_id: string;
  status: payment_status_enum;
  tenant_id: number;
  updated_at: Date;
}

/** 'UpdateServicePurchaseSucceeded' query type */
export interface IUpdateServicePurchaseSucceededQuery {
  params: IUpdateServicePurchaseSucceededParams;
  result: IUpdateServicePurchaseSucceededResult;
}

const updateServicePurchaseSucceededIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_payment_succeeded() - Part 2\n-- Type: UPDATE\n-- Description: Update service purchase status to succeeded\n-- Parameters:\n--   $1: p_stripe_payment_id TEXT - Stripe payment intent ID\n--   $2: p_tenant_id INTEGER - Tenant ID\n-- Returns: Updated service purchase record\n-- ================================================================\n\n-- Update service purchase status when payment succeeds\n\nUPDATE service_purchases\nSET \n    status = 'succeeded',\n    updated_at = NOW()\nWHERE stripe_payment_intent_id = $1::TEXT\n  AND tenant_id = $2::INTEGER\nRETURNING \n    id,\n    tenant_id,\n    service_id,\n    purchaser_user_id,\n    status,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_payment_succeeded() - Part 2
 * -- Type: UPDATE
 * -- Description: Update service purchase status to succeeded
 * -- Parameters:
 * --   $1: p_stripe_payment_id TEXT - Stripe payment intent ID
 * --   $2: p_tenant_id INTEGER - Tenant ID
 * -- Returns: Updated service purchase record
 * -- ================================================================
 * 
 * -- Update service purchase status when payment succeeds
 * 
 * UPDATE service_purchases
 * SET 
 *     status = 'succeeded',
 *     updated_at = NOW()
 * WHERE stripe_payment_intent_id = $1::TEXT
 *   AND tenant_id = $2::INTEGER
 * RETURNING 
 *     id,
 *     tenant_id,
 *     service_id,
 *     purchaser_user_id,
 *     status,
 *     updated_at
 * ```
 */
export const updateServicePurchaseSucceeded = new PreparedQuery<IUpdateServicePurchaseSucceededParams,IUpdateServicePurchaseSucceededResult>(updateServicePurchaseSucceededIR);


