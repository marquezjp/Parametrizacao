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