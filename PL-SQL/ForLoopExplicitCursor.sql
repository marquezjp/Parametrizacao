-- Querying Data with PL/SQL: Explicit Cursor FOR Loops
declare cursor c1 is
  select
   lower(tab.table_name) as TableName,
   tab.num_rows as NumRows
  from user_tables tab
  where num_rows != 0
    and tab.table_name like upper('eseg%')
    and rownum <= 5
  order by tab.table_name;

begin
  for item in c1
    loop
      dbms_output.put_line('TableName = ' || item.TableName || 'NumRows = ' || item.NumRows );
    end loop;
end;