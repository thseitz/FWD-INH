/** Types generated for queries found in "apps/api/src/app/database/queries/09_event_sourcing/projections/call_sp_rebuild_projection.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** Query 'CallSpRebuildProjection' is invalid, so its result is assigned type 'never'.
 *  */
export type ICallSpRebuildProjectionResult = never;

/** Query 'CallSpRebuildProjection' is invalid, so its parameters are assigned type 'never'.
 *  */
export type ICallSpRebuildProjectionParams = never;

const callSpRebuildProjectionIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Wrapper for: sp_rebuild_projection()\n-- Type: FUNCTION call wrapper\n-- Description: Rebuild event projection from event store\n-- Parameters:\n--   $1: p_tenant_id INTEGER - Tenant ID\n--   $2: p_projection_name TEXT - Projection name\n--   $3: p_aggregate_id UUID - Aggregate ID (optional)\n-- Returns: VOID\n-- ================================================================\n\n-- Call stored procedure to rebuild projection\n\nSELECT sp_rebuild_projection(\n    $1::INTEGER,                    -- p_tenant_id\n    $2::TEXT,                       -- p_projection_name\n    $3::UUID                        -- p_aggregate_id (optional)\n)"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Wrapper for: sp_rebuild_projection()
 * -- Type: FUNCTION call wrapper
 * -- Description: Rebuild event projection from event store
 * -- Parameters:
 * --   $1: p_tenant_id INTEGER - Tenant ID
 * --   $2: p_projection_name TEXT - Projection name
 * --   $3: p_aggregate_id UUID - Aggregate ID (optional)
 * -- Returns: VOID
 * -- ================================================================
 * 
 * -- Call stored procedure to rebuild projection
 * 
 * SELECT sp_rebuild_projection(
 *     $1::INTEGER,                    -- p_tenant_id
 *     $2::TEXT,                       -- p_projection_name
 *     $3::UUID                        -- p_aggregate_id (optional)
 * )
 * ```
 */
export const callSpRebuildProjection = new PreparedQuery<ICallSpRebuildProjectionParams,ICallSpRebuildProjectionResult>(callSpRebuildProjectionIR);


