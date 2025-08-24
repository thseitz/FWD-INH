/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/events/get_current_event_version.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetCurrentEventVersion' parameters type */
export type IGetCurrentEventVersionParams = void;

/** 'GetCurrentEventVersion' return type */
export interface IGetCurrentEventVersionResult {
  current_version: number | null;
}

/** 'GetCurrentEventVersion' query type */
export interface IGetCurrentEventVersionQuery {
  params: IGetCurrentEventVersionParams;
  result: IGetCurrentEventVersionResult;
}

const getCurrentEventVersionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Supporting query for: sp_create_snapshot()\n-- Type: SELECT\n-- Description: Get current event version for an aggregate\n-- Parameters:\n--   $1: p_aggregate_id UUID - Aggregate ID\n-- Returns: Current version number\n-- ================================================================\n\n-- Get the current event version for this aggregate\n\nSELECT COALESCE(MAX(event_version), 0) as current_version\nFROM event_store\nWHERE aggregate_id = $1::UUID"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Supporting query for: sp_create_snapshot()
 * -- Type: SELECT
 * -- Description: Get current event version for an aggregate
 * -- Parameters:
 * --   $1: p_aggregate_id UUID - Aggregate ID
 * -- Returns: Current version number
 * -- ================================================================
 * 
 * -- Get the current event version for this aggregate
 * 
 * SELECT COALESCE(MAX(event_version), 0) as current_version
 * FROM event_store
 * WHERE aggregate_id = $1::UUID
 * ```
 */
export const getCurrentEventVersion = new PreparedQuery<IGetCurrentEventVersionParams,IGetCurrentEventVersionResult>(getCurrentEventVersionIR);


