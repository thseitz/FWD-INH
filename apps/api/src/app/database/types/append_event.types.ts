/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/events/append_event.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'AppendEvent' parameters type */
export type IAppendEventParams = void;

/** 'AppendEvent' return type */
export interface IAppendEventResult {
  aggregate_id: string;
  aggregate_type: string;
  created_at: Date;
  event_type: string;
  event_version: number;
  id: string;
}

/** 'AppendEvent' query type */
export interface IAppendEventQuery {
  params: IAppendEventParams;
  result: IAppendEventResult;
}

const appendEventIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_append_event()\n-- Type: INSERT\n-- Description: Append event to event store\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_aggregate_id UUID - Aggregate ID\n--   $3: p_aggregate_type TEXT - Aggregate type\n--   $4: p_event_type TEXT - Event type\n--   $5: p_event_data JSONB - Event data\n--   $6: p_event_metadata JSONB - Event metadata (optional)\n--   $7: p_event_version INTEGER - Event version (from get_next_event_version.sql)\n--   $8: p_user_id UUID - User creating event (optional)\n-- Returns: Event store entry\n-- NOTE: Service layer should:\n--   1. Call get_next_event_version.sql first\n--   2. Use the version number in this query\n-- ================================================================\n\n-- This query appends an event to the event store\n\nINSERT INTO event_store (\n    tenant_id,\n    aggregate_id,\n    aggregate_type,\n    event_type,\n    event_data,\n    event_metadata,\n    event_version,\n    created_at,\n    created_by\n) VALUES (\n    $1::INTEGER,\n    $2::UUID,\n    $3::TEXT,\n    $4::TEXT,\n    $5::JSONB,\n    $6::JSONB,\n    $7::INTEGER,  -- Version from get_next_event_version.sql\n    NOW(),\n    COALESCE(\n        $8::UUID,\n        CASE \n            WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''\n            THEN NULL\n            ELSE current_setting('app.current_user_id', true)::UUID\n        END\n    )\n)\nRETURNING \n    id,\n    aggregate_id,\n    aggregate_type,\n    event_type,\n    event_version,\n    created_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_append_event()
 * -- Type: INSERT
 * -- Description: Append event to event store
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_aggregate_id UUID - Aggregate ID
 * --   $3: p_aggregate_type TEXT - Aggregate type
 * --   $4: p_event_type TEXT - Event type
 * --   $5: p_event_data JSONB - Event data
 * --   $6: p_event_metadata JSONB - Event metadata (optional)
 * --   $7: p_event_version INTEGER - Event version (from get_next_event_version.sql)
 * --   $8: p_user_id UUID - User creating event (optional)
 * -- Returns: Event store entry
 * -- NOTE: Service layer should:
 * --   1. Call get_next_event_version.sql first
 * --   2. Use the version number in this query
 * -- ================================================================
 * 
 * -- This query appends an event to the event store
 * 
 * INSERT INTO event_store (
 *     tenant_id,
 *     aggregate_id,
 *     aggregate_type,
 *     event_type,
 *     event_data,
 *     event_metadata,
 *     event_version,
 *     created_at,
 *     created_by
 * ) VALUES (
 *     $1::INTEGER,
 *     $2::UUID,
 *     $3::TEXT,
 *     $4::TEXT,
 *     $5::JSONB,
 *     $6::JSONB,
 *     $7::INTEGER,  -- Version from get_next_event_version.sql
 *     NOW(),
 *     COALESCE(
 *         $8::UUID,
 *         CASE 
 *             WHEN current_setting('app.current_user_id', true) IS NULL OR current_setting('app.current_user_id', true) = ''
 *             THEN NULL
 *             ELSE current_setting('app.current_user_id', true)::UUID
 *         END
 *     )
 * )
 * RETURNING 
 *     id,
 *     aggregate_id,
 *     aggregate_type,
 *     event_type,
 *     event_version,
 *     created_at
 * ```
 */
export const appendEvent = new PreparedQuery<IAppendEventParams,IAppendEventResult>(appendEventIR);


