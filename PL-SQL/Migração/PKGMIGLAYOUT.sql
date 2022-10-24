select PKGMIGLAYOUT.mostrar(PKGMIGCAPAPAGAMENTO.especificacaoLayout()) from dual;
/

select * from table(PKGMIGLAYOUT.listar(PKGMIGCAPAPAGAMENTO.especificacaoLayout()));
/

select PKGMIGCAPAPAGAMENTO.especificacaoLayout() from dual;
/

select * from table(PKGMIGLAYOUT.listarEstatisticaDescritiva(PKGMIGCAPAPAGAMENTO.especificacaoLayout(), 'emigcapapagamento2','sigrhmig'));
/

-- Remover o Pacote
drop package PKGMIGLAYOUT;
/

--- Remover o Pacote
drop package PKGMIGLAYOUT;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGLAYOUT is

type layoutTabelaLinha is record(
  grupo VARCHAR2(50),
  campo VARCHAR2(50),
  descricao VARCHAR2(250),
  tipo VARCHAR2(10),
  tamanho VARCHAR2(5),
  obrigatorio VARCHAR2(3),
  padrao VARCHAR2(250),
  dominio VARCHAR2(250),
  regrasvalidacao VARCHAR2(250),
  sigrh VARCHAR2(250)
);
type layoutTabela is table of layoutTabelaLinha;

type validacaoTabelaLinha is record(
  campo VARCHAR2(50),
  obrigatorio VARCHAR2(3),
  tamanho VARCHAR2(5),
  regravalidacao VARCHAR2(250),
  dominio VARCHAR2(250),
  tipo VARCHAR2(10),
  ordem number(3)
);
type validacaoTabela is table of validacaoTabelaLinha;

type arquivoMigracaoTabelaLinha is record(
nmarquivo varchar2(50),
nuregistro number(8),
jschaveunica varchar(500),
jscampos clob
);
type arquivoMigracaoTabela is table of arquivoMigracaoTabelaLinha;

type estatisticaDescritivaTabelaLinha is record(
  campo     varchar2(50),
  ordem     number(3),
  status    varchar2(50),
  registros number(8),
  unicos    number(8),
  nulos     number(8),
  zeros     number(8),
  numericos number(8),
  datas     number(8),
  invalidos number(8),
  validos   number(5,2),
  minimos   number(20),
  maximos   number(20),
  padrao    varchar2(50),
  dominio   varchar2(1500)
);
type estatisticaDescritivaTabela is table of estatisticaDescritivaTabelaLinha;

function normalizarString(pTexto varchar2) return varchar2;
function centralizarString(pTexto varchar2, pTamanho number) return varchar2;

function mostrar(docJSON in clob) return clob;
function listar(docJSON in clob) return layoutTabela pipelined;

function listarValidacao(docJSON in clob) return sys_refcursor;

function gerarSQLEstatisticasArquivo(
  pNomeTabela in varchar2,
  pCampo in varchar2,
  pOrdem in number,
  pStatus in varchar2 default null
) return varchar2;

function listarEstatisticaDescritiva(
  pdocJSON in clob,
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return estatisticaDescritivaTabela pipelined;

end PKGMIGLAYOUT;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGLAYOUT is

function normalizarString(pTexto varchar2) return varchar2 as
begin
 return translate(
    regexp_replace(
      upper(trim(replace(pTexto, '''', ''))),
      '[[:space:]]+', chr(32)
    ),
    'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
    'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz'
  );
end normalizarString;

function centralizarString(pTexto varchar2, pTamanho number) return varchar2 as  
begin  
 return lpad(rpad(pTexto,length(pTexto) + (pTamanho - length(pTexto) - 1) / 2,' '),pTamanho,' ');
end centralizarString;

function mostrar(docJSON in clob) return clob as
begin
 return json_query(docJSON, '$' returning clob pretty);
end mostrar;

function listar(docJSON in clob) return layoutTabela pipelined as

cursor cListaLayout(docJSON in clob) is
select
  grupo,
  campo,
  descricao,
  tipo,
  tamanho,
  obrigatorio,
  padrao,
  dominio,
  regrasvalidacao,
  sigrh
from json_table(docJSON, '$' columns (
  familiaarquivos varchar2(250) path '$.FamiliaArquivos',
  nested path '$.Arquivos' columns (
    arquivo varchar2(250) path '$.Arquivo',
    versao varchar2(250) path '$.Versão',
    tabela varchar2(250) path '$.Tabela',
    nested Path '$.Grupos[*]' columns (
      grupo Varchar2(50) Path '$.Grupo',
      nested path '$.Campos[*]' columns (
        campo varchar2(50) path '$.Campo',
        descricao varchar2(250) Path '$.Descrição',
        tipo varchar2(10) Path '$.Tipo',
        tamanho varchar2(5) path '$.Tamanho',
        obrigatorio varchar2(3) path '$.Obrigatório',
        padrao varchar2(250) path '$.Padrão',
        dominio varchar2(250) format json path '$.Domínio',
        regrasvalidacao varchar2(250) format json path '$.RegrasValidação',
        sigrh varchar2(250) format json path '$.SIGRH'
       )
     )
   )
 ));

begin
  for item in cListaLayout(docJSON) loop
    pipe row(layoutTabelaLinha(
      item.grupo,
      item.campo,
      item.descricao,
      item.tipo,
      item.tamanho,
      item.obrigatorio,
      item.padrao,
      item.dominio,
      item.regrasvalidacao,
      item.sigrh
    ));
  end loop; 

end listar;

function listarValidacao(docJSON in clob) return sys_refcursor as

vValidacaoRefCursor sys_refcursor;
vValidacaoTabela validacaoTabela;

cursor cListaLayout(docJSON clob) is
select
  campo,
  obrigatorio,
  tamanho,
  regravalidacao,
  dominio,
  tipo,
  rownum as ordem
from json_table(docJSON, '$.Arquivos.Grupos[*].Campos[*]' columns (
    campo varchar2(50) path '$.Campo',
    descricao varchar2(250) Path '$.Descrição',
    tipo varchar2(10) Path '$.Tipo',
    tamanho varchar2(5) path '$.Tamanho',
    obrigatorio varchar2(3) path '$.Obrigatório',
    padrao varchar2(250) path '$.Padrão',
    dominio varchar2(250) format json path '$.Domínio',
    nested path '$.RegrasValidação[*]' columns (
      regravalidacao varchar2(250) path '$'
    )
 ));

begin
  open cListaLayout(docJSON);
  fetch cListaLayout bulk collect into vValidacaoTabela;
  close cListaLayout;
  open vValidacaoRefCursor for select * from table (vValidacaoTabela);
  return vValidacaoRefCursor;
end listarValidacao;

function gerarSQLEstatisticasArquivo(
  pNomeTabela in varchar2,
  pCampo in varchar2,
  pOrdem in number,
  pStatus in varchar2 default null
) return varchar2 is
begin

  if pStatus = 'Ausente' then
    return 'select ' || pCampo || ' as campo, ' || pOrdem || ' as ordem, ' || pStatus || ' as status,
            null as registros,
            null as unicos,
            null as nulos,
            null as zeros,
            null as numericos,
            null as datas,
            null as invalidos,
            null as validos,
            null as minimos,
            null as maximos,
            null as padrao,
            null as dominio
            from dual';
  end if;

  return '
with  
listaunicos as (select distinct ' || pCampo || ' from ' || pNomeTabela || '),
lista as (
select ''' || pCampo || ''' as campolista, listagg(' || pCampo || ', ''; '') within group (order by ' || pCampo || ') as dominio
from listaunicos
where (select count(*) from listaunicos) < 50  
),
estatistica as (
select ''' || pCampo || ''' as campo, ' || pOrdem || ' as ordem, null as status,
count(*) as registros,
count(distinct ' || pCampo || ') as unicos,
count(case when ' || pCampo || ' is null then 1 else null end) as nulos,
count(case when to_char(' || pCampo || ') = ''0'' then 1 else null end) as zeros,
count(case when ' || pCampo || ' is not null and trim(TRANSLATE(' || pCampo || ', ''0123456789 -,.'', '' '')) is null then 1 else null end) as numericos,
count(case PKGMIGVALIDACAO.validarData(' || pCampo || ') when null then 1 else null end) as datas,
min(case PKGMIGVALIDACAO.validarNumero(' || pCampo || ') when null then trim(translate(' || pCampo || ', '' -,.'', '' '')) else null end) as minimos,
max(case PKGMIGVALIDACAO.validarNumero(' || pCampo || ') when null then trim(translate(' || pCampo || ', '' -,.'', '' '')) else null end) as maximos
from ' || pNomeTabela || '
)

select campo, ordem, status, registros, unicos, nulos, zeros, numericos, datas,
(select count(*) from table(PKGMIGPESSOA.listarValidacao(''emigpessoa'', pListaCampos => ''["' || pCampo || '"]''))) as invalidos,
null as validos,
minimos, maximos,
case
  when unicos = 0 then ''NULL''
  when unicos = 1 then dominio
  else null
end as padrao,
case when unicos > 1 then null else null end as dominio
from estatistica
left join lista on campolista = campo
';

end gerarSQLEstatisticasArquivo;

function listarEstatisticaDescritiva(
  pdocJSON in clob,
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return estatisticaDescritivaTabela pipelined as
vSQL varchar2(2000);
vNomeTabela varchar2(50);

type camposTabelaRecord is record (
  campo varchar2(50),
  ordem number(6),
  status varchar2(50)
);
camposTabela camposTabelaRecord;
 
cursor cCamposTabela (pdocJSON clob, vNomeTabela varchar2, vProprietario varchar2) is
with
layout as (select campo, rownum as ordem from table(PKGMIGLAYOUT.listar(pdocJSON))),
tab as (select column_name as campo, column_id as ordem from sys.all_tab_columns
        where owner = upper(vProprietario) and table_name = upper(vNomeTabela))
select
nvl(tab.campo,layout.campo) as campo,
nvl(tab.ordem,layout.ordem) as ordem,
case
 when tab.campo is null then 'Ausente'
 when layout.campo is null then 'Ignorado'
 else 'Presente'
end as tipo
from tab
full join layout on layout.campo = tab.campo
--where nvl(tab.ordem,layout.ordem) < 10
order by ordem
;

type estatisticaDescritivaLinha is record(
  campo     varchar2(50),
  ordem     number(3),
  status    varchar2(50),
  registros number(8),
  unicos    number(8),
  nulos     number(8),
  zeros     number(8),
  numericos number(8),
  datas     number(8),
  invalidos number(8),
  validos   number(5,2),
  minimos   number(20),
  maximos   number(20),
  padrao    varchar2(50),
  dominio   varchar2(1500)
);
estatisticasArquivo estatisticaDescritivaLinha;
--vRegistros number(8);

begin
  if pProprietario is null then vNomeTabela := upper(pNomeTabela);
  else vNomeTabela := upper(pProprietario) || '.' || upper(pNomeTabela);
  end if;
  
  open cCamposTabela(pdocJSON, upper(pNomeTabela), upper(pProprietario));
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

/*
    if camposTabela.status = 'Ausente' then
      pipe row(estatisticaDescritivaTabelaLinha(
        camposTabela.campo,
        camposTabela.ordem,
        camposTabela.status,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
      ));
    else
*/
      vSQL := gerarSQLEstatisticasArquivo(vNomeTabela, camposTabela.campo, camposTabela.ordem, camposTabela.status);
      execute immediate vSQL into estatisticasArquivo;

--      vSQL := 'select null as campo, null as ordem, null as status, null as registros, null as unicos, null as nulos, null as zeros, null as numericos, null as datas, null as minimos, null as maximos, null as padrao, null as dominio from dual';
--      execute immediate vSQL into estatisticasArquivo;

--      vSQL := 'select count(*) as registros from SIGRHMIG.EMIGCAPAPAGAMENTO2';
--      execute immediate vSQL into vRegistros;
  
      pipe row(estatisticaDescritivaTabelaLinha(
        camposTabela.campo,
        camposTabela.ordem,
        camposTabela.status,
        estatisticasArquivo.registros,
        estatisticasArquivo.unicos,
        estatisticasArquivo.nulos,
        estatisticasArquivo.zeros,
        estatisticasArquivo.numericos,
        estatisticasArquivo.datas,
        estatisticasArquivo.invalidos,
        null, --round((nvl(estatisticasArquivo.invalidos,0)/nullif(nvl(estatisticasArquivo.registros,0),0))*100,2),
        estatisticasArquivo.minimos,
        estatisticasArquivo.maximos,
        estatisticasArquivo.padrao,
        estatisticasArquivo.dominio
      ));
--    end if;

  end loop; 
   
end listarEstatisticaDescritiva;

end PKGMIGLAYOUT;
/