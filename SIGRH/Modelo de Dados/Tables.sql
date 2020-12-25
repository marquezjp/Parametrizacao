select table_name, num_rows
from user_tables
where num_rows != 0
  and table_name like upper('ecad%')
  and table_name in (select table_name from user_tab_columns
                      where column_name = upper('nucpfcadastrador'))
order by table_name;