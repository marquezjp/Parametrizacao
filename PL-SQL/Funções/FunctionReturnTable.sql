select * from table(return_table);
/

select * from table(return_objects);
/

drop type     t_table;
drop type     t_record;
drop function return_table;
drop function return_objects;
/

create or replace type t_record as object (
  cdcodigo number(22),
  nmdescricao varchar2(90),
  dedescricao varchar2(90),
  dtinicio date
);
/

create or replace type t_table as table of t_record;
/

create or replace function return_table return t_table as

v_ret   t_table;
  
cursor cLista is
select
  rownum as cdcodigo,
  'GRUPO' as nmdescricao,
  'MOTIVO' as dedescricao,
  to_date('30/04/2022','DD/MM/YYYY') as dtinicio
from all_objects
where rownum <= 4;

begin

  v_ret  := t_table();
  
  for item in cLista loop
    v_ret.extend;
    v_ret(v_ret.count) := t_record(
      item.cdcodigo,
      item.nmdescricao,
      item.dedescricao,
      item.dtinicio
    );
  end loop;

  return v_ret;

end return_table;
/

create or replace
function return_objects return t_table
as
    v_ret   t_table;
begin

    select t_record(
      rownum,
      'GRUPO' as nmdescricao,
      'MOTIVO' as dedescricao,
      to_date('30/04/2022','DD/MM/YYYY')
    )
    bulk collect into v_ret
    from all_objects
    where rownum <= 4;
  
    return v_ret;
  
end return_objects;
/
