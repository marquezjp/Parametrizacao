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
/

set serveroutput on

declare
qtde number(6);

cursor c1 is
select tab.table_name  as Tab, seq.sequence_name  as Seq, col.column_name as Col, seq.last_number as Last
from user_tables tab
inner join user_sequences seq on seq.sequence_name = 'S' || Substr(tab.table_name, 2, 250)
inner join user_tab_columns col on col.table_name = tab.table_name and col.column_id = 1
where substr(tab.table_name,1,1) = 'E'
  and tab.table_name in ('EPAGNIVELREFCEFAGRUP',
                         'EPAGNIVELREFCEFAGRUPVERSAO',
                         'EPAGHISTNIVELREFCEFAGRUP',
                         'EPAGHISTNIVELREFCARRCEFAGRUP',
                         'EPAGVALORCARREIRACEFAGRUP')
order by tab.table_name;

begin
  for item in c1
    loop
    
      execute immediate 'select nvl(max(' || item.col || '),0) as qtde from ' || item.tab
      into qtde;
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Last = ' || item.Last || ' Qtde = ' || qtde);

      execute immediate 'alter sequence ' || item.seq || ' restart start with ' || case when qtde = 0 then 1 else qtde end;
      execute immediate 'analyze table ' || upper(item.tab) || ' compute statistics';

    end loop;
end;
/