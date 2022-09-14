--select * from table(FMIGEstatisticasDescritivas('sigrh', 'ecaddependente'));

--declare
--vSQL varchar2(2000);
--begin
--  vSQL := FMIGEstatisticasDescritivasSQL(upper('sigrhmig'), upper('emigdependente'), upper('nuregistro'), 25);
--  dbms_output.put_line(vSQL);
--end;

--select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
--where owner = upper('sigrhmig')
--  and table_name = upper('emigdependente')
--  and column_id between 1 and 2
--order by column_id;

--drop type tmigEstatisticasDescritivasRow;

create or replace type tmigEstatisticasDescritivasRow as object(
campo     varchar2(50),
ordem     number(4),
registros number(8),
unicos    number(8),
nulos     number(8),
zeros     number(8),
numericos number(8),
datas     number(8),
minimos   number(11),
maximos   number(11),
padrao    varchar2(50),
dominio   varchar2(1500)
);

--drop type tmigEstatisticasDescritivasTable;

create or replace type tmigEstatisticasDescritivasTable as table of tmigEstatisticasDescritivasRow;

drop function FMIGEstatisticasDescritivasSQL;

create or replace function FMIGEstatisticasDescritivasSQL(
  pProprietario varchar2,
  pNomeTabela varchar2,
  pCampo varchar2,
  pOrdem number
)
return varchar2
as
begin
    return
    'select * from (' ||

    'with campos as (' ||
    'select ' || 
    '''' || pCampo || ''' as campo, ' ||
    pOrdem || ' as ordem, ' ||
    'count(*) as registros, ' ||
    'count(distinct ' || pCampo || ') as unicos, ' ||
    'count(case when ' || pCampo || ' is null then 1 else null end) as nulos, ' ||
    'count(case when to_char(' || pCampo || ') = ''0'' then 1 else null end) as zeros, ' ||
    'count(case when ' || pCampo || ' is not null ' ||
                'and translate(trim(' || pCampo || '), ''0123456789-,.'', '' '') is null ' ||
               'then 1 else null end) as numericos, ' ||
    'count(FMIG_VALIDA_DATA(' || pCampo || ',''DD/MM/YYYY'')) as datas, ' ||
    'min(case when translate(trim(' || pCampo || '), ''0123456789-,.'', '' '') is null ' ||
             'then ' || 'translate(trim(' || pCampo || '), '' -,.'', '' '') ' ||
             'else null end) as minimos, ' ||
    'max(case when translate(trim(' || pCampo || '), ''0123456789-,.'', '' '') is null ' ||
             'then ' || 'translate(trim(' || pCampo || '), '' -,.'', '' '') ' ||
             'else null end) as maximos ' ||
    'from ' || pProprietario || '.' || pNomeTabela ||
    '), ' ||

    'listas as (' ||
    'select ' ||
    'c.campo, ' ||
    '(select listagg(' || pCampo || ', ''; '') within group (order by ' || pCampo || ') ' ||
    'from (' ||
    'select distinct ' ||
    'translate(regexp_replace(upper(trim(' || pCampo || ')) ' ||
    ', ''[[:space:]]+'', chr(32)),' ||
    '''ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽ'',' ||
    '''AEIOUAEIOUAEIOUAOEIOUCNSYYZ'') ' ||
    'as ' || pCampo || ' ' ||
    'from ' || pProprietario || '.' || pNomeTabela || ' ' ||
    'order by ' || pCampo ||
    ')' ||
    ') as lista ' ||
    'from campos c ' ||
    'where c.unicos < 50' ||
    ') ' ||

    'select ' ||
    'c.*, ' ||
    'case when c.unicos = 1 then substr(l.lista,0,50) else null end as padrao, ' ||
    'case when c.unicos > 1 then substr(l.lista,0,1500) else null end as dominio ' ||
    'from campos c ' ||
    'left join listas l on l.campo = c.campo' ||
    ')'
    ;
end;

drop function FMIGEstatisticasDescritivas;

create or replace function FMIGEstatisticasDescritivas(
  pProprietario varchar2,
  pNomeTabela varchar2
)
return tmigEstatisticasDescritivasTable
as
v_ret tmigEstatisticasDescritivasTable;

vProprietario varchar2(20);
vNomeTabela varchar2(50);
vSQL varchar2(2000);

type recCamposTabela is record (campo varchar2(50),
                                ordem number(4));
camposTabela recCamposTabela;

cursor cCamposTabela (vProprietario varchar2, vNomeTabela varchar2) is
   select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
   where owner = vProprietario
     and table_name = vNomeTabela
   order by column_id;

type tpEstatisticasArquivo is ref cursor;
cEstatisticasArquivo tpEstatisticasArquivo;

type recEstatisticasArq is record (
 campo     varchar2(50),
 ordem     number(4),
 registros number(8),
 unicos    number(8),
 nulos     number(8),
 zeros     number(8),
 numericos number(8),
 datas     number(8),
 minimos   number(11),
 maximos   number(11),
 padrao    varchar2(50),
 dominio   varchar2(1500)
);
estatisticasArquivo recEstatisticasArq;

begin

  vProprietario := upper(pProprietario);
  vNomeTabela := upper(pNomeTabela);

  v_ret := tmigEstatisticasDescritivasTable();

  open cCamposTabela(vProprietario, vNomeTabela);

  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

    vSQL := FMIGEstatisticasDescritivasSQL(vProprietario, vNomeTabela, camposTabela.campo, camposTabela.ordem);

    open cEstatisticasArquivo for vSQL;

    loop
      fetch cEstatisticasArquivo into estatisticasArquivo;
        exit when cEstatisticasArquivo%notfound;

        v_ret.extend;
        v_ret(v_ret.count) := tmigEstatisticasDescritivasRow(
          estatisticasArquivo.campo,
          estatisticasArquivo.ordem,
          estatisticasArquivo.registros,
          estatisticasArquivo.unicos,
          estatisticasArquivo.nulos,
          estatisticasArquivo.zeros,
          estatisticasArquivo.numericos,
          estatisticasArquivo.datas,
          estatisticasArquivo.minimos,
          estatisticasArquivo.maximos,
          estatisticasArquivo.padrao,
          estatisticasArquivo.dominio
        );

    end loop;

    close cEstatisticasArquivo;

  end loop;

  close cCamposTabela;

  return v_ret;

end;