select lower(col.table_name) as TableName, lower(col.column_name) as ColumnName, data_type as ColumnType, data_length as ColumnLength, col.column_id as Id
from all_tab_columns col
--where col.table_name = upper('ecadvinculo') order by  col.column_id;
where col.column_name like upper('cdafastamento')
  and col.table_name like upper('eafa%')
order by col.table_name, col.column_name
;

---------------------------------------------------

select
 lower(substr(col.table_name,1,4)) as SubSystem,
 lower(col.table_name) as TableName,
 lower(col.column_name) as ColumnName,
 data_type as ColumnType,
 data_length as ColumnLength,
 trim(cmt.comments) as ColumnComments,
 case col.nullable when 'Y' then 'Yes' when 'N' then 'No' else col.nullable end as Nullable,
 case when constpk.table_name is not null then 'Yes' else 'No' end as primary_key,
 case when constfk.table_name is not null then 'Yes' else 'No' end as foreign_key,
 col.column_id as Id,
 constfk.constraint_name as ConstraintName,
 lower(col.table_name) || '.' || lower(col.column_name) as FullName

from user_tab_columns col
left join user_col_comments cmt on cmt.table_name = col.table_name and cmt.column_name = col.column_name
left join user_cons_columns constcol on constcol.table_name = col.table_name and constcol.column_name = col.column_name and position is not null
left join user_constraints constpk on constpk.constraint_name = constcol.constraint_name and constpk.constraint_type = 'P'
left join user_constraints constfk on constfk.constraint_name = constcol.constraint_name and constfk.constraint_type = 'R'

where col.column_name = upper('cdafastamento')

--where col.table_name = upper('ecadvinculo')
--where col.table_name like upper('eafa%')

--where constfk.constraint_name like upper('RAFAAFASTVINCCADHISTJORNTRAB')
--where col.column_name like upper('cdafastamento%') and constfk.table_name is not null
--  and col.table_name like upper('ecad%')

order by col.table_name, col.column_name
;