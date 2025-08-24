/* @name markStripeEventProcessed */
-- ================================================================
-- Converted from: sp_handle_subscription_created/updated/deleted()
-- Type: UPDATE
-- Description: Mark a Stripe event as processed
-- Parameters:
--   $1: p_event_id UUID - Stripe event ID
-- Returns: Updated stripe event record
-- Note: This single query replaces 3 identical procedures:
--       sp_handle_subscription_created
--       sp_handle_subscription_updated
--       sp_handle_subscription_deleted
-- ================================================================

-- Mark Stripe event as processed

UPDATE stripe_events 
SET 
    status = 'processed', 
    processed_at = NOW() 
WHERE id = $1::UUID
RETURNING 
    id,
    stripe_event_id,
    event_type,
    status,
    processed_at;