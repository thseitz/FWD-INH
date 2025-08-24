/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/stripe/call_sp_process_stripe_webhook.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpProcessStripeWebhook' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpProcessStripeWebhookResult = never;

/** Query 'CallSpProcessStripeWebhook' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpProcessStripeWebhookParams = never;

const callSpProcessStripeWebhookIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_process_stripe_webhook()\n-- Type: PROCEDURE call wrapper\n-- Description: Process incoming Stripe webhook events\n-- Parameters:\n--   $1: p_stripe_event_id VARCHAR - Stripe event ID\n--   $2: p_event_type VARCHAR - Event type\n--   $3: p_payload JSONB - Event payload data\n-- Returns: void (procedure)\n-- ================================================================\n\n-- Call stored procedure to process Stripe webhook\n\nCALL sp_process_stripe_webhook(\n    $1::VARCHAR,       -- p_stripe_event_id\n    $2::VARCHAR,       -- p_event_type\n    $3::JSONB          -- p_payload\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_process_stripe_webhook()
 * -- Type: PROCEDURE call wrapper
 * -- Description: Process incoming Stripe webhook events
 * -- Parameters:
 * --   $1: p_stripe_event_id VARCHAR - Stripe event ID
 * --   $2: p_event_type VARCHAR - Event type
 * --   $3: p_payload JSONB - Event payload data
 * -- Returns: void (procedure)
 * -- ================================================================
 * 
 * -- Call stored procedure to process Stripe webhook
 * 
 * CALL sp_process_stripe_webhook(
 *     $1::VARCHAR,       -- p_stripe_event_id
 *     $2::VARCHAR,       -- p_event_type
 *     $3::JSONB          -- p_payload
 * )
 * ```
 */
export const callSpProcessStripeWebhook = new PreparedQuery<ICallSpProcessStripeWebhookParams,ICallSpProcessStripeWebhookResult>(callSpProcessStripeWebhookIR);


