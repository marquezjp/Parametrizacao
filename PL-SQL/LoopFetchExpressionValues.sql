-- Defining Aliases for Expression Values in a Cursor FOR Loop
declare
 col_tablename   user_tab_columns.table_name%TYPE  := 'esegautorizacaoacesso';
 col_column_name user_tab_columns.column_name%TYPE := 'cdorgao';
 my_record user_tab_columns%ROWTYPE;
 
 cursor c1 (col_tablename varchar2, col_column_name varchar2) is
   select * from user_tab_columns col
   where col.table_name = upper(col_tablename)
     and col.column_name = upper(col_column_name)
   order by col.table_name, col.column_name;

begin
  -- open c1(col_tablename, col_column_name);
  -- open c1('esegautorizacaoacesso', 'cdorgao');
  open c1('esegteste', 'cdorgao');
  loop fetch c1 into my_record;
  exit when c1%notfound;
  
    dbms_output.put_line(
       'TableName = '    || my_record.table_name || ', ' ||
       'ColumnName = '   || my_record.column_name || ', ' ||
       'ColumnType = '   || my_record.data_type || ', ' ||
       'ColumnLength = ' || my_record.data_length || ', ' ||
       'Nullable = '     || my_record.nullable || ', ' ||
       'Id = '           || my_record.column_id
    );
    
  end loop;
  
  exception
    when others then
      dbms_output.put_line('Error code:' || sqlcode);
      dbms_output.put_line('Error message:' || sqlerrm);
      raise;

end;