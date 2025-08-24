/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/stripe/mark_stripe_event_processed.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'MarkStripeEventProcessed' parameters type */
export type IMarkStripeEventProcessedParams = void;

/** 'MarkStripeEventProcessed' return type */
export interface IMarkStripeEventProcessedResult {
  event_type: string;
  id: string;
  processed_at: Date | null;
  status: string;
  stripe_event_id: string;
}

/** 'MarkStripeEventProcessed' query type */
export interface IMarkStripeEventProcessedQuery {
  params: IMarkStripeEventProcessedParams;
  result: IMarkStripeEventProcessedResult;
}

const markStripeEventProcessedIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_handle_subscription_created/updated/deleted()\n-- Type: UPDATE\n-- Description: Mark a Stripe event as processed\n-- Parameters:\n--   $1: p_event_id UUID - Stripe event ID\n-- Returns: Updated stripe event record\n-- Note: This single query replaces 3 identical procedures:\n--       sp_handle_subscription_created\n--       sp_handle_subscription_updated\n--       sp_handle_subscription_deleted\n-- ================================================================\n\n-- Mark Stripe event as processed\n\nUPDATE stripe_events \nSET \n    status = 'processed', \n    processed_at = NOW() \nWHERE id = $1::UUID\nRETURNING \n    id,\n    stripe_event_id,\n    event_type,\n    status,\n    processed_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_handle_subscription_created/updated/deleted()
 * -- Type: UPDATE
 * -- Description: Mark a Stripe event as processed
 * -- Parameters:
 * --   $1: p_event_id UUID - Stripe event ID
 * -- Returns: Updated stripe event record
 * -- Note: This single query replaces 3 identical procedures:
 * --       sp_handle_subscription_created
 * --       sp_handle_subscription_updated
 * --       sp_handle_subscription_deleted
 * -- ================================================================
 * 
 * -- Mark Stripe event as processed
 * 
 * UPDATE stripe_events 
 * SET 
 *     status = 'processed', 
 *     processed_at = NOW() 
 * WHERE id = $1::UUID
 * RETURNING 
 *     id,
 *     stripe_event_id,
 *     event_type,
 *     status,
 *     processed_at
 * ```
 */
export const markStripeEventProcessed = new PreparedQuery<IMarkStripeEventProcessedParams,IMarkStripeEventProcessedResult>(markStripeEventProcessedIR);


