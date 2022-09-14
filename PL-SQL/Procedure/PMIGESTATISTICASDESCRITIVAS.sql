create or replace procedure PMIGESTATISTICASDESCRITIVAS(
  pProprietario varchar2,
  pNomeTabela varchar2,
  resultado OUT TYPES.REF_CURSOR
)

is

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
   order by column_id;

type tpEstatisticasArquivo is ref cursor;
cEstatisticasArquivo tpEstatisticasArquivo;

type recEstatisticasArq is record (campo     varchar2(50),
                               ordem     number(6),
                               registros number(6),
                               unicos    number(6),
                               nulos     number(6),
                               zeros     number(6));
estatisticasArquivo recEstatisticasArq;

begin

  vProprietario := upper(pProprietario);
  vNomeTabela := upper(pNomeTabela);

  vSQL := '';

  open cCamposTabela(vProprietario, vNomeTabela);
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

    if vSQL is not null then
      vSQL := vSQL || ' union ';
    end if;

    vSQL := vSQL ||
    'select ' ||
    '''' || camposTabela.campo || ''' as campo, ' ||
    camposTabela.ordem || ' as ordem, ' ||
    'count(*) as registros, ' ||
    'count(distinct ' || camposTabela.campo || ') as unicos, ' ||
    'count(case when ' || camposTabela.campo || ' is null then 1 else null end) as nulos, ' ||
    'count(case when to_char(' || camposTabela.campo || ') = ''0'' then 1 else null end) as zeros ' ||
    'from ' || vProprietario || '.' || vNomeTabela
    ;

  end loop;

  close cCamposTabela;

  vSQL := 'select * from (' || vSQL || ' ' || ') order by ordem';

  open resultado for vSQL;

end PMIGESTATISTICASDESCRITIVAS;