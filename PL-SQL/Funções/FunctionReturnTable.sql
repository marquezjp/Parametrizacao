--drop type jotape_row;

create or replace type jotape_row as object(
campo     varchar2(30),
ordem     number(6),
registros number(6),
unicos    number(6),
nulos     number(6),
zeros     number(6)
);

--drop type jotape_table;

create or replace type jotape_table as table of jotape_row;

--drop function jotape;

create or replace function jotape
return jotape_table
as
begin
  return jotape_table(
    jotape_row('NOME',   1, 100,  80,   5,  0),
    jotape_row('CPF',    2, 100, 100, 100,  0),
    jotape_row('DTNASC', 3, 100,  50,  15, 30),
    jotape_row('END',    4, 100,  10,  60,  0)
    );
end;

create or replace function jotape
return jotape_table
as
v_ret jotape_table;
begin
  v_ret := jotape_table();
  
  v_ret.extend;
  v_ret(v_ret.count) := jotape_row('NOME',   1, 100,  80,   5,  0);

  v_ret.extend;
  v_ret(v_ret.count) := jotape_row('CPF',    2, 100, 100, 100,  0);

  v_ret.extend;
  v_ret(v_ret.count) := jotape_row('DTNASC', 3, 100,  50,  15, 30);

  v_ret.extend;
  v_ret(v_ret.count) := jotape_row('END',    4, 100,  10,  60,  0);

  return v_ret;
end;

select * from table(jotape);