/** Types generated for queries found in "apps/api/src/app/database/queries/05_integrations/real_estate/update_hei_status.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

export type hei_status_enum = 'active' | 'bought_out' | 'defaulted' | 'matured' | 'sold';

/** 'UpdateHeiStatus' parameters type */
export type IUpdateHeiStatusParams = void;

/** 'UpdateHeiStatus' return type */
export interface IUpdateHeiStatusResult {
  amount_funded: string;
  asset_id: string;
  effective_date: Date;
  equity_share_pct: string;
  hei_status: hei_status_enum;
  id: string;
  property_asset_id: string;
  source_application_id: string;
  source_system: string;
  updated_at: Date | null;
}

/** 'UpdateHeiStatus' query type */
export interface IUpdateHeiStatusQuery {
  params: IUpdateHeiStatusParams;
  result: IUpdateHeiStatusResult;
}

const updateHeiStatusIR: any = {"usedParamSet":{},"params":[],"statement":"-- ================================================================\n-- Update HEI Status SQL\n-- Type: UPDATE\n-- Description: Update HEI status for lifecycle management\n-- Parameters:\n--   $1: hei_asset_id UUID - HEI asset ID\n--   $2: new_status hei_status_enum - New status value\n--   $3: notes TEXT - Optional status change notes\n-- Returns: Updated HEI record\n-- ================================================================\n\nUPDATE hei_assets SET\n    hei_status = $2::hei_status_enum,\n    updated_at = NOW(),\n    updated_by = current_user_id()\nWHERE asset_id = $1::UUID\n\nRETURNING \n    id,\n    asset_id,\n    amount_funded,\n    equity_share_pct,\n    effective_date,\n    property_asset_id,\n    hei_status,\n    source_system,\n    source_application_id,\n    updated_at"};

/**
 * Query generated from SQL:
 * ```
 * -- ================================================================
 * -- Update HEI Status SQL
 * -- Type: UPDATE
 * -- Description: Update HEI status for lifecycle management
 * -- Parameters:
 * --   $1: hei_asset_id UUID - HEI asset ID
 * --   $2: new_status hei_status_enum - New status value
 * --   $3: notes TEXT - Optional status change notes
 * -- Returns: Updated HEI record
 * -- ================================================================
 * 
 * UPDATE hei_assets SET
 *     hei_status = $2::hei_status_enum,
 *     updated_at = NOW(),
 *     updated_by = current_user_id()
 * WHERE asset_id = $1::UUID
 * 
 * RETURNING 
 *     id,
 *     asset_id,
 *     amount_funded,
 *     equity_share_pct,
 *     effective_date,
 *     property_asset_id,
 *     hei_status,
 *     source_system,
 *     source_application_id,
 *     updated_at
 * ```
 */
export const updateHeiStatus = new PreparedQuery<IUpdateHeiStatusParams,IUpdateHeiStatusResult>(updateHeiStatusIR);


