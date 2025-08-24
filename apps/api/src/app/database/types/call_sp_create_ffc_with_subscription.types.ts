/** Types generated for queries found in "apps/api/src/app/database/queries/01_core/family_circles/call_sp_create_ffc_with_subscription.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpCreateFfcWithSubscription' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpCreateFfcWithSubscriptionResult = never;

/** Query 'CallSpCreateFfcWithSubscription' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpCreateFfcWithSubscriptionParams = never;

const callSpCreateFfcWithSubscriptionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_create_ffc_with_subscription()\n-- Type: PROCEDURE call wrapper\n-- Description: Create FFC with subscription\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_name TEXT - FFC name\n--   $3: p_description TEXT - FFC description\n--   $4: p_owner_user_id UUID - Owner user ID\n--   $5: p_owner_persona_id UUID - Owner persona ID\n-- Returns: (p_ffc_id UUID, p_subscription_id UUID)\n-- ================================================================\n\n-- Call stored procedure to create FFC with subscription\n\nCALL sp_create_ffc_with_subscription(\n    $1::INTEGER,      -- p_tenant_id\n    $2::TEXT,         -- p_name\n    $3::TEXT,         -- p_description\n    $4::UUID,         -- p_owner_user_id\n    $5::UUID,         -- p_owner_persona_id\n    NULL,             -- OUT p_ffc_id\n    NULL              -- OUT p_subscription_id\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_create_ffc_with_subscription()
 * -- Type: PROCEDURE call wrapper
 * -- Description: Create FFC with subscription
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_name TEXT - FFC name
 * --   $3: p_description TEXT - FFC description
 * --   $4: p_owner_user_id UUID - Owner user ID
 * --   $5: p_owner_persona_id UUID - Owner persona ID
 * -- Returns: (p_ffc_id UUID, p_subscription_id UUID)
 * -- ================================================================
 * 
 * -- Call stored procedure to create FFC with subscription
 * 
 * CALL sp_create_ffc_with_subscription(
 *     $1::INTEGER,      -- p_tenant_id
 *     $2::TEXT,         -- p_name
 *     $3::TEXT,         -- p_description
 *     $4::UUID,         -- p_owner_user_id
 *     $5::UUID,         -- p_owner_persona_id
 *     NULL,             -- OUT p_ffc_id
 *     NULL              -- OUT p_subscription_id
 * )
 * ```
 */
export const callSpCreateFfcWithSubscription = new PreparedQuery<ICallSpCreateFfcWithSubscriptionParams,ICallSpCreateFfcWithSubscriptionResult>(callSpCreateFfcWithSubscriptionIR);


