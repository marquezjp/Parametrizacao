-- Querying Data with PL/SQL: Implicit Cursor FOR Loop
begin
  for item in (
    select
     lower(tab.table_name) as TableName,
     tab.num_rows as NumRows
    from user_tables tab
    where num_rows != 0
      and tab.table_name like upper('eseg%')
      and rownum <= 5
    order by tab.table_name
    )
    
    loop
      dbms_output.put_line('TableName = ' || item.TableName || ', NumRows = ' || item.NumRows );
    end loop;
end;