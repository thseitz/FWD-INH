/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/billing/create_invoice_payment.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type payment_status_enum = 'failed' | 'partially_refunded' | 'pending' | 'refunded' | 'succeeded';

/** 'CreateInvoicePayment' parameters type */
export type ICreateInvoicePaymentParams = void;

/** 'CreateInvoicePayment' return type */
export interface ICreateInvoicePaymentResult {
  amount: string;
  currency: string;
  id: string;
  payer_id: string;
  status: payment_status_enum;
  stripe_invoice_id: string | null;
}

/** 'CreateInvoicePayment' query type */
export interface ICreateInvoicePaymentQuery {
  params: ICreateInvoicePaymentParams;
  result: ICreateInvoicePaymentResult;
}

const createInvoicePaymentIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_invoice_payment_succeeded() - Step 1\n-- Type: INSERT\n-- Description: Create payment record for successful invoice payment\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_payer_id UUID - Payer user ID (from service layer)\n--   $3: p_amount INTEGER - Amount in cents\n--   $4: p_currency VARCHAR(3) - Currency code\n--   $5: p_stripe_invoice_id TEXT - Stripe invoice ID\n--   $6: p_reference_id UUID - Reference subscription ID (optional)\n-- Returns: Created payment record\n-- NOTE: Service layer should get payer_id and reference_id before calling\n-- ================================================================\n\n-- Create payment record for invoice\n\nINSERT INTO payments (\n    tenant_id,\n    payer_id,\n    amount,\n    currency,\n    payment_type,\n    reference_id,\n    stripe_invoice_id,\n    status,\n    processed_at,\n    created_at,\n    updated_at\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::DECIMAL / 100,  -- Convert cents to dollars\n    $4::VARCHAR(3),\n    'subscription',\n    $6::UUID,\n    $5::TEXT,\n    'succeeded',\n    NOW(),\n    NOW(),\n    NOW()\n)\nRETURNING \n    id,\n    payer_id,\n    amount,\n    currency,\n    stripe_invoice_id,\n    status"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_invoice_payment_succeeded() - Step 1
 * -- Type: INSERT
 * -- Description: Create payment record for successful invoice payment
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_payer_id UUID - Payer user ID (from service layer)
 * --   $3: p_amount INTEGER - Amount in cents
 * --   $4: p_currency VARCHAR(3) - Currency code
 * --   $5: p_stripe_invoice_id TEXT - Stripe invoice ID
 * --   $6: p_reference_id UUID - Reference subscription ID (optional)
 * -- Returns: Created payment record
 * -- NOTE: Service layer should get payer_id and reference_id before calling
 * -- ================================================================
 * 
 * -- Create payment record for invoice
 * 
 * INSERT INTO payments (
 *     tenant_id,
 *     payer_id,
 *     amount,
 *     currency,
 *     payment_type,
 *     reference_id,
 *     stripe_invoice_id,
 *     status,
 *     processed_at,
 *     created_at,
 *     updated_at
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::DECIMAL / 100,  -- Convert cents to dollars
 *     $4::VARCHAR(3),
 *     'subscription',
 *     $6::UUID,
 *     $5::TEXT,
 *     'succeeded',
 *     NOW(),
 *     NOW(),
 *     NOW()
 * )
 * RETURNING 
 *     id,
 *     payer_id,
 *     amount,
 *     currency,
 *     stripe_invoice_id,
 *     status
 * ```
 */
export const createInvoicePayment = new PreparedQuery<ICreateInvoicePaymentParams,ICreateInvoicePaymentResult>(createInvoicePaymentIR);


