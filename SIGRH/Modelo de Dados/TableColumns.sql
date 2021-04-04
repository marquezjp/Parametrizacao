select lower(substr(col.table_name,1,4)) as SubSystem, lower(col.table_name) as TableName, lower(col.column_name) as ColumnName, lower(col.table_name) || '.' || lower(col.column_name) as FullName, trim(cmt.comments) as ColumnComments, col.nullable as Nullable, col.column_id as Id
from user_tab_columns col
left join all_col_comments cmt on cmt.table_name = col.table_name and cmt.column_name = col.column_name 
--where col.table_name = upper('ecadvinculo')
--where col.table_name like upper('eafa%')
--where col.column_name = upper('cdafastamento')
order by col.table_name, col.column_id
;