-- Get UI collection mask configuration by entity code
SELECT 
  e.entity_code,
  e.table_name,
  m.column_name,
  m.requirement::text   AS requirement,
  m.field_type::text    AS field_type,
  m.display_order,
  m.note
FROM ui_entity e
JOIN ui_collection_mask m USING (entity_code)
WHERE e.entity_code = $1
ORDER BY m.display_order;