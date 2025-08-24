/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/stripe/call_sp_purchase_service.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpPurchaseService' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpPurchaseServiceResult = never;

/** Query 'CallSpPurchaseService' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpPurchaseServiceParams = never;

const callSpPurchaseServiceIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_purchase_service()\n-- Type: PROCEDURE call wrapper\n-- Description: Process service purchase with payment\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_service_type VARCHAR(50) - Type of service\n--   $3: p_amount INTEGER - Amount in cents\n--   $4: p_currency VARCHAR(3) - Currency code\n--   $5: p_purchased_by UUID - User making the purchase\n--   $6: p_payment_method_id UUID - Payment method ID\n-- Returns: void (procedure)\n-- ================================================================\n\n-- Call stored procedure to purchase service\n\nCALL sp_purchase_service(\n    $1::INTEGER,       -- p_tenant_id\n    $2::VARCHAR(50),   -- p_service_type\n    $3::INTEGER,       -- p_amount\n    $4::VARCHAR(3),    -- p_currency\n    $5::UUID,          -- p_purchased_by\n    $6::UUID           -- p_payment_method_id\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_purchase_service()
 * -- Type: PROCEDURE call wrapper
 * -- Description: Process service purchase with payment
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_service_type VARCHAR(50) - Type of service
 * --   $3: p_amount INTEGER - Amount in cents
 * --   $4: p_currency VARCHAR(3) - Currency code
 * --   $5: p_purchased_by UUID - User making the purchase
 * --   $6: p_payment_method_id UUID - Payment method ID
 * -- Returns: void (procedure)
 * -- ================================================================
 * 
 * -- Call stored procedure to purchase service
 * 
 * CALL sp_purchase_service(
 *     $1::INTEGER,       -- p_tenant_id
 *     $2::VARCHAR(50),   -- p_service_type
 *     $3::INTEGER,       -- p_amount
 *     $4::VARCHAR(3),    -- p_currency
 *     $5::UUID,          -- p_purchased_by
 *     $6::UUID           -- p_payment_method_id
 * )
 * ```
 */
export const callSpPurchaseService = new PreparedQuery<ICallSpPurchaseServiceParams,ICallSpPurchaseServiceResult>(callSpPurchaseServiceIR);


