-- ================================================================
-- Wrapper for: sp_process_stripe_webhook()
-- Type: PROCEDURE call wrapper
-- Description: Process incoming Stripe webhook events
-- Parameters:
--   $1: p_stripe_event_id VARCHAR - Stripe event ID
--   $2: p_event_type VARCHAR - Event type
--   $3: p_payload JSONB - Event payload data
-- Returns: void (procedure)
-- ================================================================

-- Call stored procedure to process Stripe webhook

CALL sp_process_stripe_webhook(
    $1::VARCHAR,       -- p_stripe_event_id
    $2::VARCHAR,       -- p_event_type
    $3::JSONB          -- p_payload
);