/** Types generated for queries found in "apps/api/src/app/database/queries/10_reporting/dashboards/get_hei_dashboard_data.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type hei_status_enum = 'active' | 'bought_out' | 'defaulted' | 'matured' | 'sold';

export type hei_valuation_method_enum = 'appraisal' | 'avm' | 'bpo' | 'broker_opinion' | 'market_analysis';

export type property_type_enum = 'commercial' | 'condo' | 'farm_ranch' | 'land' | 'multi_family' | 'other' | 'single_family' | 'townhouse' | 'vacation_property';

/** 'GetHeiDashboardData' parameters type */
export type IGetHeiDashboardDataParams = void;

/** 'GetHeiDashboardData' return type */
export interface IGetHeiDashboardDataResult {
  address_line_1: string;
  address_line_2: string | null;
  amount_funded: string;
  building_size_sqft: number | null;
  city: string;
  cltv_at_close: string | null;
  country: string;
  effective_date: Date;
  equity_share_pct: string;
  first_mortgage_balance: string | null;
  funded_at: Date | null;
  hei_asset_id: string;
  hei_asset_name: string;
  hei_created_at: Date | null;
  hei_description: string | null;
  hei_estimated_value: string | null;
  hei_id: string;
  hei_ownership_pct: string | null;
  hei_status: hei_status_enum;
  junior_liens_balance: string | null;
  lot_size_acres: string | null;
  maturity_terms: string | null;
  owner_name: string | null;
  parcel_number: string | null;
  postal_code: string;
  property_asset_id: string;
  property_estimated_value: string | null;
  property_name: string;
  property_type: property_type_enum;
  source_system: string;
  state_province: string;
  valuation_amount: string;
  valuation_effective_date: Date;
  valuation_method: hei_valuation_method_enum;
  year_built: number | null;
}

/** 'GetHeiDashboardData' query type */
export interface IGetHeiDashboardDataQuery {
  params: IGetHeiDashboardDataParams;
  result: IGetHeiDashboardDataResult;
}

const getHeiDashboardDataIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- HEI Dashboard Data SQL\n-- Type: SELECT\n-- Description: Get comprehensive HEI data for user dashboard\n-- Parameters:\n--   $1: persona_id UUID - Persona ID to filter HEIs for\n-- Returns: Complete HEI information with property and document details\n-- ================================================================\n\nSELECT \n    -- HEI Investment Details\n    hei.id as hei_id,\n    hei.asset_id as hei_asset_id,\n    hei.amount_funded,\n    hei.equity_share_pct,\n    hei.effective_date,\n    hei.maturity_terms,\n    hei.valuation_amount,\n    hei.valuation_method,\n    hei.valuation_effective_date,\n    hei.hei_status,\n    hei.first_mortgage_balance,\n    hei.junior_liens_balance,\n    hei.cltv_at_close,\n    hei.source_system,\n    hei.funded_at,\n    \n    -- HEI Asset Information\n    a_hei.name as hei_asset_name,\n    a_hei.description as hei_description,\n    a_hei.estimated_value as hei_estimated_value,\n    a_hei.created_at as hei_created_at,\n    \n    -- Property Details from address\n    hei.property_asset_id,\n    addr.address_line_1,\n    addr.address_line_2,\n    addr.city,\n    addr.state_province,\n    addr.postal_code,\n    addr.country,\n    re.parcel_number,\n    re.property_type,\n    re.building_size_sqft,\n    re.lot_size_acres,\n    re.year_built,\n    \n    -- Property Asset Information\n    a_prop.name as property_name,\n    a_prop.estimated_value as property_estimated_value,\n    \n    -- Ownership Information\n    ap_hei.ownership_percentage as hei_ownership_pct,\n    \n    -- Persona Information\n    p.first_name || ' ' || p.last_name as owner_name\n\nFROM hei_assets hei\nJOIN assets a_hei ON hei.asset_id = a_hei.id\nJOIN real_estate re ON hei.property_asset_id = re.asset_id\nJOIN assets a_prop ON re.asset_id = a_prop.id\nJOIN address addr ON re.property_address_id = addr.id\n\n-- HEI ownership\nJOIN asset_persona ap_hei ON hei.asset_id = ap_hei.asset_id\nJOIN personas p ON ap_hei.persona_id = p.id\n\n-- HEI document count (removing for now - would need document linking table)\n-- LEFT JOIN (\n--     SELECT \n--         asset_id,\n--         COUNT(*) as total\n--     FROM asset_documents \n--     WHERE asset_id = hei.asset_id\n--     GROUP BY asset_id\n-- ) hei_doc_count ON hei.asset_id = hei_doc_count.asset_id\n\n-- Property document count (removing for now - would need document linking table)\n-- LEFT JOIN (\n--     SELECT \n--         asset_id,\n--         COUNT(*) as total\n--     FROM asset_documents\n--     WHERE asset_id = re.asset_id\n--     GROUP BY asset_id  \n-- ) prop_doc_count ON re.asset_id = prop_doc_count.asset_id\n\nWHERE p.id = $1::UUID  -- Filter by persona_id instead\nAND hei.hei_status = 'active'\nAND a_hei.status = 'active'\nAND a_prop.status = 'active'\n\nORDER BY hei.effective_date DESC"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- HEI Dashboard Data SQL
 * -- Type: SELECT
 * -- Description: Get comprehensive HEI data for user dashboard
 * -- Parameters:
 * --   $1: persona_id UUID - Persona ID to filter HEIs for
 * -- Returns: Complete HEI information with property and document details
 * -- ================================================================
 * 
 * SELECT 
 *     -- HEI Investment Details
 *     hei.id as hei_id,
 *     hei.asset_id as hei_asset_id,
 *     hei.amount_funded,
 *     hei.equity_share_pct,
 *     hei.effective_date,
 *     hei.maturity_terms,
 *     hei.valuation_amount,
 *     hei.valuation_method,
 *     hei.valuation_effective_date,
 *     hei.hei_status,
 *     hei.first_mortgage_balance,
 *     hei.junior_liens_balance,
 *     hei.cltv_at_close,
 *     hei.source_system,
 *     hei.funded_at,
 *     
 *     -- HEI Asset Information
 *     a_hei.name as hei_asset_name,
 *     a_hei.description as hei_description,
 *     a_hei.estimated_value as hei_estimated_value,
 *     a_hei.created_at as hei_created_at,
 *     
 *     -- Property Details from address
 *     hei.property_asset_id,
 *     addr.address_line_1,
 *     addr.address_line_2,
 *     addr.city,
 *     addr.state_province,
 *     addr.postal_code,
 *     addr.country,
 *     re.parcel_number,
 *     re.property_type,
 *     re.building_size_sqft,
 *     re.lot_size_acres,
 *     re.year_built,
 *     
 *     -- Property Asset Information
 *     a_prop.name as property_name,
 *     a_prop.estimated_value as property_estimated_value,
 *     
 *     -- Ownership Information
 *     ap_hei.ownership_percentage as hei_ownership_pct,
 *     
 *     -- Persona Information
 *     p.first_name || ' ' || p.last_name as owner_name
 * 
 * FROM hei_assets hei
 * JOIN assets a_hei ON hei.asset_id = a_hei.id
 * JOIN real_estate re ON hei.property_asset_id = re.asset_id
 * JOIN assets a_prop ON re.asset_id = a_prop.id
 * JOIN address addr ON re.property_address_id = addr.id
 * 
 * -- HEI ownership
 * JOIN asset_persona ap_hei ON hei.asset_id = ap_hei.asset_id
 * JOIN personas p ON ap_hei.persona_id = p.id
 * 
 * -- HEI document count (removing for now - would need document linking table)
 * -- LEFT JOIN (
 * --     SELECT 
 * --         asset_id,
 * --         COUNT(*) as total
 * --     FROM asset_documents 
 * --     WHERE asset_id = hei.asset_id
 * --     GROUP BY asset_id
 * -- ) hei_doc_count ON hei.asset_id = hei_doc_count.asset_id
 * 
 * -- Property document count (removing for now - would need document linking table)
 * -- LEFT JOIN (
 * --     SELECT 
 * --         asset_id,
 * --         COUNT(*) as total
 * --     FROM asset_documents
 * --     WHERE asset_id = re.asset_id
 * --     GROUP BY asset_id  
 * -- ) prop_doc_count ON re.asset_id = prop_doc_count.asset_id
 * 
 * WHERE p.id = $1::UUID  -- Filter by persona_id instead
 * AND hei.hei_status = 'active'
 * AND a_hei.status = 'active'
 * AND a_prop.status = 'active'
 * 
 * ORDER BY hei.effective_date DESC
 * ```
 */
export const getHeiDashboardData = new PreparedQuery<IGetHeiDashboardDataParams,IGetHeiDashboardDataResult>(getHeiDashboardDataIR);


