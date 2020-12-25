select lower(subtrac(table_name,1,3)) as SubSystem, lower(table_name) as TableName, lower(column_name) as ColumnName
from user_tab_columns
where table_name = upper('esegsolicitacaocliente');