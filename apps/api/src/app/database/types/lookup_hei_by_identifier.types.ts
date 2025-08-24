/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/lookup_hei_by_identifier.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'LookupHeiByIdentifier' parameters type */
export type ILookupHeiByIdentifierParams = void;

/** 'LookupHeiByIdentifier' return type */
export interface ILookupHeiByIdentifierResult {
  address_line_1: string;
  amount_funded: string;
  city: string;
  effective_date: Date;
  equity_share_pct: string;
  hei_asset_id: string;
  hei_asset_name: string;
  hei_id: string;
  persona_id: string;
  persona_name: string | null;
  postal_code: string;
  property_asset_id: string;
  property_asset_name: string;
  source_application_id: string;
  source_system: string;
  state_province: string;
}

/** 'LookupHeiByIdentifier' query type */
export interface ILookupHeiByIdentifierQuery {
  params: ILookupHeiByIdentifierParams;
  result: ILookupHeiByIdentifierResult;
}

const lookupHeiByIdentifierIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- HEI Lookup by Identifier SQL\n-- Type: SELECT\n-- Description: Find existing HEI by loan number or external ID for self-registration\n-- Parameters:\n--   $1: identifier TEXT - Loan number, external ID, or property address\n-- Returns: HEI record with linked persona and FFC information\n-- ================================================================\n\nSELECT \n    hei.id as hei_id,\n    hei.asset_id as hei_asset_id,\n    hei.property_asset_id,\n    hei.amount_funded,\n    hei.equity_share_pct,\n    hei.effective_date,\n    hei.source_system,\n    hei.source_application_id,\n    \n    -- Persona information  \n    p.id as persona_id,\n    p.first_name || ' ' || p.last_name as persona_name,\n    \n    -- Property information from address\n    addr.address_line_1,\n    addr.city,\n    addr.state_province,\n    addr.postal_code,\n    \n    -- Asset information\n    a_hei.name as hei_asset_name,\n    a_prop.name as property_asset_name\n\nFROM hei_assets hei\nJOIN assets a_hei ON hei.asset_id = a_hei.id\nJOIN real_estate re ON hei.property_asset_id = re.asset_id  \nJOIN assets a_prop ON re.asset_id = a_prop.id\nJOIN address addr ON re.property_address_id = addr.id\nJOIN asset_persona ap ON hei.asset_id = ap.asset_id\nJOIN personas p ON ap.persona_id = p.id\n\nWHERE hei.hei_status = 'active'\nAND (\n    hei.source_application_id = $1\n    OR LOWER(addr.address_line_1) LIKE LOWER('%' || $1 || '%')\n    OR LOWER(a_prop.name) LIKE LOWER('%' || $1 || '%')\n)\n\nORDER BY hei.created_at DESC\nLIMIT 5"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- HEI Lookup by Identifier SQL
 * -- Type: SELECT
 * -- Description: Find existing HEI by loan number or external ID for self-registration
 * -- Parameters:
 * --   $1: identifier TEXT - Loan number, external ID, or property address
 * -- Returns: HEI record with linked persona and FFC information
 * -- ================================================================
 * 
 * SELECT 
 *     hei.id as hei_id,
 *     hei.asset_id as hei_asset_id,
 *     hei.property_asset_id,
 *     hei.amount_funded,
 *     hei.equity_share_pct,
 *     hei.effective_date,
 *     hei.source_system,
 *     hei.source_application_id,
 *     
 *     -- Persona information  
 *     p.id as persona_id,
 *     p.first_name || ' ' || p.last_name as persona_name,
 *     
 *     -- Property information from address
 *     addr.address_line_1,
 *     addr.city,
 *     addr.state_province,
 *     addr.postal_code,
 *     
 *     -- Asset information
 *     a_hei.name as hei_asset_name,
 *     a_prop.name as property_asset_name
 * 
 * FROM hei_assets hei
 * JOIN assets a_hei ON hei.asset_id = a_hei.id
 * JOIN real_estate re ON hei.property_asset_id = re.asset_id  
 * JOIN assets a_prop ON re.asset_id = a_prop.id
 * JOIN address addr ON re.property_address_id = addr.id
 * JOIN asset_persona ap ON hei.asset_id = ap.asset_id
 * JOIN personas p ON ap.persona_id = p.id
 * 
 * WHERE hei.hei_status = 'active'
 * AND (
 *     hei.source_application_id = $1
 *     OR LOWER(addr.address_line_1) LIKE LOWER('%' || $1 || '%')
 *     OR LOWER(a_prop.name) LIKE LOWER('%' || $1 || '%')
 * )
 * 
 * ORDER BY hei.created_at DESC
 * LIMIT 5
 * ```
 */
export const lookupHeiByIdentifier = new PreparedQuery<ILookupHeiByIdentifierParams,ILookupHeiByIdentifierResult>(lookupHeiByIdentifierIR);


