/** Types generated for queries found in "apps/api/src/app/database/queries/04_subscriptions/cancellations/record_subscription_transition.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'RecordSubscriptionTransition' parameters type */
export type IRecordSubscriptionTransitionParams = void;

/** 'RecordSubscriptionTransition' return type */
export interface IRecordSubscriptionTransitionResult {
  created_at: Date;
  effective_date: Date;
  from_plan_id: string | null;
  id: string;
  initiated_by: string;
  reason: string | null;
  subscription_id: string;
  to_plan_id: string;
  transition_type: string;
}

/** 'RecordSubscriptionTransition' query type */
export interface IRecordSubscriptionTransitionQuery {
  params: IRecordSubscriptionTransitionParams;
  result: IRecordSubscriptionTransitionResult;
}

const recordSubscriptionTransitionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_transition_subscription_plan() - Part 3\n-- Type: INSERT\n-- Description: Record subscription plan transition\n-- Parameters:\n--   $1: p_subscription_id UUID - Subscription ID\n--   $2: p_from_plan_id UUID - Current plan ID\n--   $3: p_to_plan_id UUID - New plan ID\n--   $4: p_transition_type VARCHAR(50) - Type (upgrade/downgrade/lateral)\n--   $5: p_initiated_by UUID - User initiating transition\n--   $6: p_reason TEXT - Reason for transition (optional)\n-- Returns: Created transition record\n-- ================================================================\n\n-- Record subscription plan transition\n\nINSERT INTO subscription_transitions (\n    subscription_id,\n    from_plan_id,\n    to_plan_id,\n    transition_type,\n    effective_date,\n    initiated_by,\n    reason\n) VALUES (\n    $1::UUID,\n    $2::UUID,\n    $3::UUID,\n    $4::VARCHAR(50),\n    CURRENT_DATE,\n    $5::UUID,\n    $6::TEXT\n)\nRETURNING \n    id,\n    subscription_id,\n    from_plan_id,\n    to_plan_id,\n    transition_type,\n    effective_date,\n    initiated_by,\n    reason,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_transition_subscription_plan() - Part 3
 * -- Type: INSERT
 * -- Description: Record subscription plan transition
 * -- Parameters:
 * --   $1: p_subscription_id UUID - Subscription ID
 * --   $2: p_from_plan_id UUID - Current plan ID
 * --   $3: p_to_plan_id UUID - New plan ID
 * --   $4: p_transition_type VARCHAR(50) - Type (upgrade/downgrade/lateral)
 * --   $5: p_initiated_by UUID - User initiating transition
 * --   $6: p_reason TEXT - Reason for transition (optional)
 * -- Returns: Created transition record
 * -- ================================================================
 * 
 * -- Record subscription plan transition
 * 
 * INSERT INTO subscription_transitions (
 *     subscription_id,
 *     from_plan_id,
 *     to_plan_id,
 *     transition_type,
 *     effective_date,
 *     initiated_by,
 *     reason
 * ) VALUES (
 *     $1::UUID,
 *     $2::UUID,
 *     $3::UUID,
 *     $4::VARCHAR(50),
 *     CURRENT_DATE,
 *     $5::UUID,
 *     $6::TEXT
 * )
 * RETURNING 
 *     id,
 *     subscription_id,
 *     from_plan_id,
 *     to_plan_id,
 *     transition_type,
 *     effective_date,
 *     initiated_by,
 *     reason,
 *     created_at
 * ```
 */
export const recordSubscriptionTransition = new PreparedQuery<IRecordSubscriptionTransitionParams,IRecordSubscriptionTransitionResult>(recordSubscriptionTransitionIR);


