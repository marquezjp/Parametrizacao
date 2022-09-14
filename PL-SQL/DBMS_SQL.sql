set serveroutput on

declare

vProprietario varchar2(20);
vNomeTabela varchar2(50);
vSQL varchar2(12000);

type recCamposTabela is record (campo varchar2(50),
                               ordem number(6));
camposTabela recCamposTabela;
 
cursor cCamposTabela (vProprietario varchar2, vNomeTabela varchar2) is
   select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
   where owner = vProprietario
     and table_name = vNomeTabela;

cEstatisticasArquivo SYS_REFCURSOR;

begin
  vProprietario := upper('sigrhmig');
  vNomeTabela := upper('emigdependente');

  vSQL := 'select * from (';
  
  open cCamposTabela(vProprietario, vNomeTabela);
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

    vSQL := vSQL || 
    'select ' || 
    '''' || camposTabela.campo || ''' as campo, ' ||
    camposTabela.ordem || ' as ordem, ' ||
    'count(*) as registros, ' ||
    'count(distinct ' || camposTabela.campo || ') as unicos, ' ||
    'count(case when ' || camposTabela.campo || ' is null then 1 else null end) as nulos, ' ||
    'count(case when ' || camposTabela.campo || ' = ''0'' then 1 else null end) as zeros ' ||
    'from sigrhmig.emigdependente union '
    ;
  end loop;
  
  close cCamposTabela;

  vSQL := vSQL || ' ' ||
  'select null as campo, 0 as ordem, null as registros, null as unicos, null as nulos, null as zeros from dual ' ||
  ') where campo is not null order by ordem';
   
  open cEstatisticasArquivo for vSQL;
  
  dbms_sql.return_result(cEstatisticasArquivo);
   
end;