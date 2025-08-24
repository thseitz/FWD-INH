/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/ui_masks/get_ui_mask_by_entity_code.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetUiMaskByEntityCode' parameters type */
export type IGetUiMaskByEntityCodeParams = void;

/** 'GetUiMaskByEntityCode' return type */
export interface IGetUiMaskByEntityCodeResult {
  column_name: string;
  display_order: number;
  entity_code: string;
  field_type: string | null;
  note: string | null;
  requirement: string | null;
  table_name: string;
}

/** 'GetUiMaskByEntityCode' query type */
export interface IGetUiMaskByEntityCodeQuery {
  params: IGetUiMaskByEntityCodeParams;
  result: IGetUiMaskByEntityCodeResult;
}

const getUiMaskByEntityCodeIR: any = {"usedParamSet":{},"params":[],"statement":"-- Get UI collection mask configuration by entity code\nSELECT \n  e.entity_code,\n  e.table_name,\n  m.column_name,\n  m.requirement::text   AS requirement,\n  m.field_type::text    AS field_type,\n  m.display_order,\n  m.note\nFROM ui_entity e\nJOIN ui_collection_mask m USING (entity_code)\nWHERE e.entity_code = $1\nORDER BY m.display_order"};

/**
 * Query generated from SQL:
 * ```
 * -- Get UI collection mask configuration by entity code
 * SELECT 
 *   e.entity_code,
 *   e.table_name,
 *   m.column_name,
 *   m.requirement::text   AS requirement,
 *   m.field_type::text    AS field_type,
 *   m.display_order,
 *   m.note
 * FROM ui_entity e
 * JOIN ui_collection_mask m USING (entity_code)
 * WHERE e.entity_code = $1
 * ORDER BY m.display_order
 * ```
 */
export const getUiMaskByEntityCode = new PreparedQuery<IGetUiMaskByEntityCodeParams,IGetUiMaskByEntityCodeResult>(getUiMaskByEntityCodeIR);


