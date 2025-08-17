-- ================================================================
-- Converted from: sp_transition_subscription_plan() - Part 3
-- Type: INSERT
-- Description: Record subscription plan transition
-- Parameters:
--   $1: p_subscription_id UUID - Subscription ID
--   $2: p_from_plan_id UUID - Current plan ID
--   $3: p_to_plan_id UUID - New plan ID
--   $4: p_transition_type VARCHAR(50) - Type (upgrade/downgrade/lateral)
--   $5: p_initiated_by UUID - User initiating transition
--   $6: p_reason TEXT - Reason for transition (optional)
-- Returns: Created transition record
-- ================================================================

-- Record subscription plan transition

INSERT INTO subscription_transitions (
    subscription_id,
    from_plan_id,
    to_plan_id,
    transition_type,
    effective_date,
    initiated_by,
    reason
) VALUES (
    $1::UUID,
    $2::UUID,
    $3::UUID,
    $4::VARCHAR(50),
    CURRENT_DATE,
    $5::UUID,
    $6::TEXT
)
RETURNING 
    id,
    subscription_id,
    from_plan_id,
    to_plan_id,
    transition_type,
    effective_date,
    initiated_by,
    reason,
    created_at;