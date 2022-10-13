--select last_number from user_sequences
--where sequence_name = upper('SCADORGAOCARREIRA');

--select nvl(max(cdorgaocarreira),0) from ecadorgaocarreira;

--alter sequence SCADORGAOCARREIRA increment by -381 minvalue 0;
--select SCADORGAOCARREIRA.nextval from dual;
--alter sequence SCADORGAOCARREIRA increment by 1 minvalue 0;

declare
  i number;
  last_number NUMBER;
begin
  select nvl(max(cdorgaocarreira),0) INTO last_number from ecadorgaocarreira;
  loop
   select SCADORGAOCARREIRA.nextval
   into i
   from dual;
  exit when i >= last_number;
  end loop;
end;
/

select tab.table_name  as Tab, seq.sequence_name  as Seq, col.column_name as Col, seq.last_number as Last
from user_tables tab
inner join user_sequences seq on seq.sequence_name = 'S' || Substr(tab.table_name, 2, 250)
inner join user_tab_columns col on col.table_name = tab.table_name and col.column_id = 1
where substr(tab.table_name,1,1) = 'E'
order by tab.table_name
;