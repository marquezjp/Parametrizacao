select table_name, num_rows
from user_tables
where table_name like upper('%eafa%')
  and num_rows != 0
order by table_name

select table_name, num_rows
from user_tables
where num_rows != 0
  and table_name in (select table_name from user_tab_columns
                      where column_name = upper('cdafastamento'))
order by table_name

select table_name, column_name, data_type, data_length
from user_tab_columns
--where table_name = upper('eafaafastamentovinculo')
--where table_name like upper('%eafaafastamentovinculo%')
where column_name = upper('cdafastamento')
--where column_name like upper('%cdafastamento%')

select distinct table_name as TableName
from user_constraints
where table_name like upper('%eafaafastamentovinculo%')
order by table_name

select p.table_name as TableName, f.table_name as TableConstraint
from user_constraints p
inner join user_constraints f
  on p.constraint_name = f.r_constraint_name 
where p.table_name = upper('eafaafastamentovinculo')
order by p.table_name, f.table_name

select p.table_name as TableName, f.table_name as TableConstraint
from user_constraints p
inner join user_constraints f
  on p.constraint_name = f.r_constraint_name 
where f.table_name = upper('eafaafastamentovinculo')
order by p.table_name, f.table_name