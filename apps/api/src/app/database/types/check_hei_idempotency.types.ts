/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/check_hei_idempotency.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'CheckHeiIdempotency' parameters type */
export type ICheckHeiIdempotencyParams = void;

/** 'CheckHeiIdempotency' return type */
export interface ICheckHeiIdempotencyResult {
  hei_asset_id: string;
  hei_id: string;
  last_updated_at: Date | null;
  message: string | null;
  originally_ingested_at: Date | null;
  persona_id: string;
  persona_name: string | null;
  property_asset_id: string;
  source_application_id: string;
  source_system: string;
  status: string | null;
}

/** 'CheckHeiIdempotency' query type */
export interface ICheckHeiIdempotencyQuery {
  params: ICheckHeiIdempotencyParams;
  result: ICheckHeiIdempotencyResult;
}

const checkHeiIdempotencyIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- HEI Idempotency Check SQL\n-- Type: SELECT\n-- Description: Check if HEI already exists by source system and application ID\n-- Parameters:\n--   $1: source_system TEXT - External system identifier\n--   $2: source_application_id TEXT - External application ID\n-- Returns: Existing HEI record if found, null if new\n-- ================================================================\n\nSELECT \n    hei.id as hei_id,\n    hei.asset_id as hei_asset_id,\n    hei.property_asset_id,\n    \n    -- Persona information\n    p.id as persona_id,\n    p.first_name || ' ' || p.last_name as persona_name,\n    \n    -- Ingestion metadata\n    hei.source_system,\n    hei.source_application_id,\n    hei.created_at as originally_ingested_at,\n    hei.updated_at as last_updated_at,\n    \n    -- Status\n    'duplicate' as status,\n    'HEI already exists with this source system and application ID' as message\n\nFROM hei_assets hei\nJOIN asset_persona ap ON hei.asset_id = ap.asset_id\nJOIN personas p ON ap.persona_id = p.id\n\nWHERE hei.source_system = $1\nAND hei.source_application_id = $2\nAND hei.hei_status != 'defaulted'\n\nLIMIT 1"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- HEI Idempotency Check SQL
 * -- Type: SELECT
 * -- Description: Check if HEI already exists by source system and application ID
 * -- Parameters:
 * --   $1: source_system TEXT - External system identifier
 * --   $2: source_application_id TEXT - External application ID
 * -- Returns: Existing HEI record if found, null if new
 * -- ================================================================
 * 
 * SELECT 
 *     hei.id as hei_id,
 *     hei.asset_id as hei_asset_id,
 *     hei.property_asset_id,
 *     
 *     -- Persona information
 *     p.id as persona_id,
 *     p.first_name || ' ' || p.last_name as persona_name,
 *     
 *     -- Ingestion metadata
 *     hei.source_system,
 *     hei.source_application_id,
 *     hei.created_at as originally_ingested_at,
 *     hei.updated_at as last_updated_at,
 *     
 *     -- Status
 *     'duplicate' as status,
 *     'HEI already exists with this source system and application ID' as message
 * 
 * FROM hei_assets hei
 * JOIN asset_persona ap ON hei.asset_id = ap.asset_id
 * JOIN personas p ON ap.persona_id = p.id
 * 
 * WHERE hei.source_system = $1
 * AND hei.source_application_id = $2
 * AND hei.hei_status != 'defaulted'
 * 
 * LIMIT 1
 * ```
 */
export const checkHeiIdempotency = new PreparedQuery<ICheckHeiIdempotencyParams,ICheckHeiIdempotencyResult>(checkHeiIdempotencyIR);


