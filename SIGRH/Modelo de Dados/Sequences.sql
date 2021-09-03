--- Alterando o incremento da sequence para acertar e depois retornando pra 1
alter sequence ssegfuncionalidadegestor increment by (1864-831)+1;
select ssegfuncionalidadegestor.nextval from dual;
alter sequence ssegfuncionalidadegestor increment by 1;

-- Força bruta 
select max(cdFuncionalidadeGestor) from esegfuncionalidadegestor; -- 831
select ssegfuncionalidadegestor.nextval from dual; -- 1864

declare
 vcont integer;
begin
   for i IN  831 .. 1864
     loop
       
       select ssegfuncionalidadegestor.nextval into vcont from dual;
       
     end loop;
end;
