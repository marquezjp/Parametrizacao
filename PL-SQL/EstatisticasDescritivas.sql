-- Estatisticas Descritivas de Tabela

set serveroutput on

declare

vProprietario varchar2(20);
vNomeTabela varchar2(50);
vSQL varchar2(32000);

type recCamposTabela is record (campo varchar2(50),
                               ordem number(6));
camposTabela recCamposTabela;
 
cursor cCamposTabela (vProprietario varchar2, vNomeTabela varchar2) is
   select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
   where owner = vProprietario
     and table_name = vNomeTabela
     and column_id between 1 and 20
   order by column_id;

type tpEstatisticasArquivo is ref cursor;
cEstatisticasArquivo tpEstatisticasArquivo;

type recEstatisticasArq is record (campo     varchar2(50),
                                   ordem     number(6),
                                   registros number(6),
                                   unicos    number(6),
                                   nulos     number(6),
                                   zeros     number(6),
                                   numericos number(6),
                                   datas     number(6),
                                   minimos   long,
                                   maximos   long,
                                   padrao    varchar2(50),
                                   dominio   varchar2(1500)
                                  );
estatisticasArquivo recEstatisticasArq;

begin
  vProprietario := upper('sigrhmig');
  vNomeTabela := upper('emigdependente');
--  vProprietario := upper('sigrh');
--  vNomeTabela := upper('ecaddependente');

  vSQL := '';
  
  open cCamposTabela(vProprietario, vNomeTabela);
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

    if vSQL is not null then
      vSQL := vSQL || ' union ';
    end if;

    vSQL := vSQL || 
    'select * from (' ||

    'with campos as (' ||
    'select ' || 
    '''' || camposTabela.campo || ''' as campo, ' ||
    camposTabela.ordem || ' as ordem, ' ||
    'count(*) as registros, ' ||
    'count(distinct ' || camposTabela.campo || ') as unicos, ' ||
    'count(case when ' || camposTabela.campo || ' is null then 1 else null end) as nulos, ' ||
    'count(case when to_char(' || camposTabela.campo || ') = ''0'' then 1 else null end) as zeros, ' ||
    'count(case when ' || camposTabela.campo || ' is not null ' ||
                'and trim(TRANSLATE(' || camposTabela.campo || ', ''0123456789 -,.'', '' '')) is null ' ||
               'then 1 else null end) as numericos,' ||
    'count(FMIG_VALIDA_DATA(' || camposTabela.campo || ',''DD/MM/YYYY'')) as datas, ' ||
    'min(case when trim(TRANSLATE(' || camposTabela.campo || ', ''0123456789 -,.'', '' '')) is null ' ||
             'then ' || 'trim(TRANSLATE(' || camposTabela.campo || ', '' -,.'', '' '')) ' ||
             'else null end) as minimos, ' ||
    'max(case when trim(TRANSLATE(' || camposTabela.campo || ', ''0123456789 -,.'', '' '')) is null ' ||
             'then ' || 'trim(TRANSLATE(' || camposTabela.campo || ', '' -,.'', '' '')) ' ||
             'else null end) as maximos ' ||
    'from ' || vProprietario || '.' || vNomeTabela ||
    '), ' ||

    'listas as (' ||
    'select ' ||
    'c.campo, ' ||
    '(select listagg(' || camposTabela.campo || ', ''; '') within group (order by ' || camposTabela.campo || ') ' ||
    'from (' ||
    'select distinct ' ||
    'translate(regexp_replace(upper(trim(' || camposTabela.campo || ')) ' ||
    ', ''[[:space:]]+'', chr(32)),' ||
    '''ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽ'',' ||
    '''AEIOUAEIOUAEIOUAOEIOUCNSYYZ'') ' ||
    'as ' || camposTabela.campo || ' ' ||
    'from ' || vProprietario || '.' || vNomeTabela ||
    ')' ||
    ') as lista ' ||
    'from campos c ' ||
    'where c.unicos < 50' ||
    ') ' ||

    'select ' ||
    'c.*, ' ||
    'case when c.unicos = 1 then l.lista else null end as padrao, ' ||
    'case when c.unicos > 1 then l.lista else null end as dominio ' ||
    'from campos c ' ||
    'left join listas l on l.campo = c.campo' ||
    ')'
    ;

  end loop;
  
  close cCamposTabela;

  vSQL := 'select * from (' || vSQL || ' ' || ') order by ordem';
  
  --dbms_output.put_line(vSQL);
  
  open cEstatisticasArquivo for vSQL;
   
  dbms_output.put_line(
          rpad('campo',30)     || ' | ' ||
          lpad('ordem',06)     || ' | ' ||
          lpad('registros',06) || ' | ' ||
          lpad('unicos',06)    || ' | ' ||
          lpad('nulos',06)     || ' | ' ||
          lpad('zeros',06)     || ' | ' ||
          lpad('numericos',06) || ' | ' ||
          lpad('datas',06)     || ' | ' ||
          lpad('minimos',11)   || ' | ' ||
          lpad('maximos',11)   || ' | ' ||
          rpad('padrao',50)    || ' | ' ||
          rpad('dominio',100)
          );

  dbms_output.put_line(
          rpad('-',30,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',06,'-')     || ' + ' ||
          lpad('-',11,'-')     || ' + ' ||
          lpad('-',11,'-')     || ' + ' ||
          rpad('-',50,'-')     || ' + ' ||
          rpad('-',100,'-')
          );

  loop
    fetch cEstatisticasArquivo into estatisticasArquivo;
      exit when cEstatisticasArquivo%notfound;
      dbms_output.put_line(
          rpad(estatisticasArquivo.campo,30) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.ordem,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.registros,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.unicos,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.nulos,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.zeros,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.numericos,06) || ' | ' ||
          FMIG_CENTRALIZAR_STRING(estatisticasArquivo.datas,06) || ' | ' ||
          lpad(nvl(estatisticasArquivo.minimos, ' '),11) || ' | ' ||
          lpad(nvl(estatisticasArquivo.maximos, ' '),11) || ' | ' ||
          rpad(nvl(estatisticasArquivo.padrao, ' '),50) || ' | ' ||
          rpad(nvl(estatisticasArquivo.dominio, ' '),100)
          );
  end loop;
   
  close cEstatisticasArquivo;
   
end;
