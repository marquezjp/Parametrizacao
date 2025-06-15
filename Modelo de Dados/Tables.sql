select lower(substr(tab.table_name,1,4)) as SubSystem, lower(tab.table_name) as TableName, tab.num_rows, trim(tabcmt.comments) as TableComments
from user_tables tab
left join all_tab_comments tabcmt on tabcmt.table_name = tab.table_name
--where num_rows != 0
--  and tab.table_name like upper('ecad%')
--  and tab.table_name in (select table_name from user_tab_columns
--                          where column_name = upper('nucpfcadastrador'))
order by tab.table_name;