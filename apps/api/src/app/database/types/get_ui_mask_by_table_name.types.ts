/** Types generated for queries found in "apps/api/src/app/database/queries/11_system/ui_masks/get_ui_mask_by_table_name.sql" */
import { PreparedQuery } from '@pgtyped/runtime';

/** 'GetUiMaskByTableName' parameters type */
export type IGetUiMaskByTableNameParams = void;

/** 'GetUiMaskByTableName' return type */
export interface IGetUiMaskByTableNameResult {
  column_name: string;
  display_order: number;
  field_type: string | null;
  note: string | null;
  requirement: string | null;
  table_name: string;
}

/** 'GetUiMaskByTableName' query type */
export interface IGetUiMaskByTableNameQuery {
  params: IGetUiMaskByTableNameParams;
  result: IGetUiMaskByTableNameResult;
}

const getUiMaskByTableNameIR: any = {"usedParamSet":{},"params":[],"statement":"-- Get UI collection mask configuration by table name\nSELECT \n  e.table_name,\n  m.column_name,\n  m.requirement::text   AS requirement,\n  m.field_type::text    AS field_type,\n  m.display_order,\n  m.note\nFROM ui_entity e\nJOIN ui_collection_mask m USING (entity_code)\nWHERE e.table_name = $1\nORDER BY m.display_order"};

/**
 * Query generated from SQL:
 * ```
 * -- Get UI collection mask configuration by table name
 * SELECT 
 *   e.table_name,
 *   m.column_name,
 *   m.requirement::text   AS requirement,
 *   m.field_type::text    AS field_type,
 *   m.display_order,
 *   m.note
 * FROM ui_entity e
 * JOIN ui_collection_mask m USING (entity_code)
 * WHERE e.table_name = $1
 * ORDER BY m.display_order
 * ```
 */
export const getUiMaskByTableName = new PreparedQuery<IGetUiMaskByTableNameParams,IGetUiMaskByTableNameResult>(getUiMaskByTableNameIR);


