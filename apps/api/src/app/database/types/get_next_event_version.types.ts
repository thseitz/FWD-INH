/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/events/get_next_event_version.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetNextEventVersion' parameters type */
export type IGetNextEventVersionParams = void;

/** 'GetNextEventVersion' return type */
export interface IGetNextEventVersionResult {
  next_version: number | null;
}

/** 'GetNextEventVersion' query type */
export interface IGetNextEventVersionQuery {
  params: IGetNextEventVersionParams;
  result: IGetNextEventVersionResult;
}

const getNextEventVersionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_append_event()\n-- Type: SELECT\n-- Description: Get next event version for an aggregate\n-- Parameters:\n--   $1: p_aggregate_id UUID - Aggregate ID\n-- Returns: Next version number\n-- ================================================================\n\n-- Get the next event version for this aggregate\n\nSELECT COALESCE(MAX(event_version), 0) + 1 as next_version\nFROM event_store\nWHERE aggregate_id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_append_event()
 * -- Type: SELECT
 * -- Description: Get next event version for an aggregate
 * -- Parameters:
 * --   $1: p_aggregate_id UUID - Aggregate ID
 * -- Returns: Next version number
 * -- ================================================================
 * 
 * -- Get the next event version for this aggregate
 * 
 * SELECT COALESCE(MAX(event_version), 0) + 1 as next_version
 * FROM event_store
 * WHERE aggregate_id = $1::UUID
 * ```
 */
export const getNextEventVersion = new PreparedQuery<IGetNextEventVersionParams,IGetNextEventVersionResult>(getNextEventVersionIR);


