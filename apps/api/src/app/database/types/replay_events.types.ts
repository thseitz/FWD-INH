/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/replay/replay_events.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type Json = null | boolean | number | string | Json[] | { [key: string]: Json };

/** 'ReplayEvents' parameters type */
export type IReplayEventsParams = void;

/** 'ReplayEvents' return type */
export interface IReplayEventsResult {
  created_at: Date;
  created_by: string;
  event_data: Json;
  event_metadata: Json | null;
  event_type: string;
  event_version: number;
}

/** 'ReplayEvents' query type */
export interface IReplayEventsQuery {
  params: IReplayEventsParams;
  result: IReplayEventsResult;
}

const replayEventsIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Converted from: sp_replay_events()\n-- Type: SELECT returning TABLE\n-- Description: Replay events for an aggregate from event store\n-- Parameters:\n--   $1: p_aggregate_id UUID - Aggregate ID\n--   $2: p_from_version INTEGER - Start version (default 1)\n--   $3: p_to_version INTEGER - End version (optional)\n-- Returns: Event records in order\n-- ================================================================\n\n-- Retrieve events for an aggregate within version range\n\nSELECT \n    event_version,\n    event_type,\n    event_data,\n    event_metadata,\n    created_at,\n    created_by\nFROM event_store\nWHERE aggregate_id = $1::UUID\n  AND event_version >= COALESCE($2::INTEGER, 1)\n  AND ($3::INTEGER IS NULL OR event_version <= $3::INTEGER)\nORDER BY event_version"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Converted from: sp_replay_events()
 * -- Type: SELECT returning TABLE
 * -- Description: Replay events for an aggregate from event store
 * -- Parameters:
 * --   $1: p_aggregate_id UUID - Aggregate ID
 * --   $2: p_from_version INTEGER - Start version (default 1)
 * --   $3: p_to_version INTEGER - End version (optional)
 * -- Returns: Event records in order
 * -- ================================================================
 * 
 * -- Retrieve events for an aggregate within version range
 * 
 * SELECT 
 *     event_version,
 *     event_type,
 *     event_data,
 *     event_metadata,
 *     created_at,
 *     created_by
 * FROM event_store
 * WHERE aggregate_id = $1::UUID
 *   AND event_version >= COALESCE($2::INTEGER, 1)
 *   AND ($3::INTEGER IS NULL OR event_version <= $3::INTEGER)
 * ORDER BY event_version
 * ```
 */
export const replayEvents = new PreparedQuery<IReplayEventsParams,IReplayEventsResult>(replayEventsIR);


