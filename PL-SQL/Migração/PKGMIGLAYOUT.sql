select PKGMIGLAYOUT.mostrar(PKGMIGCAPAPAGAMENTO.especificacaoLayout()) from dual;
/

select * from table(PKGMIGLAYOUT.listar(PKGMIGCAPAPAGAMENTO.especificacaoLayout()));
/

select PKGMIGCAPAPAGAMENTO.especificacaoLayout() from dual;
/

select * from table(PKGMIGLAYOUT.listarEstatisticaDescritiva('emigcapapagamento2','sigrhmig'));
/

declare
vRefCursor sys_refcursor;

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
item validacaoTabelaLinha;

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

begin
  vRefCursor := PKGMIGLAYOUT.listarValidacao((PKGMIGCAPAPAGAMENTO.especificacaoLayout()));

  loop fetch vRefCursor into item;
    exit when vRefCursor%NOTFOUND;
    print(
      item.campo || ' ' ||
      item.obrigatorio || ' ' ||
      item.tamanho || ' ' ||
      item.regravalidacao || ' ' ||
      item.dominio || ' ' ||
      item.tipo || ' ' ||
      item.ordem
    );
  end loop;

end;
/

-- Remover o Pacote
drop package PKGMIGLAYOUT;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGLAYOUT is

type layoutTabelaLinha is record(
  familiaarquivos VARCHAR2(250),
  arquivo VARCHAR2(250),
  versao VARCHAR2(250),
  tabela VARCHAR2(250),
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
--  sigrh_conceito VARCHAR2(250),
--  sigrh_coluna VARCHAR2(250)
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

type estatisticaDescritivaTabelaLinha is record(
  campo     varchar2(50),
  ordem     number(6),
  registros number(6),
  unicos    number(6),
  nulos     number(6),
  zeros     number(6),
  numericos number(6),
  datas     number(6),
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
  pOrdem in number
) return varchar2;

function listarEstatisticaDescritiva(
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
  familiaarquivos,
  arquivo,
  versao,
  tabela,
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
--  sigrh_conceito,
--  sigrh_coluna
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
--         nested path '$.SIGRH[*]' columns (
--           sigrh_conceito varchar2(250) path '$.Conceito',
--           sigrh_coluna varchar2(250) path '$.Coluna'
--         )
       )
     )
   )
 ));

begin
  for item in cListaLayout(docJSON) loop
    pipe row(layoutTabelaLinha(
      item.familiaarquivos,
      item.arquivo,
      item.versao,
      item.tabela,
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
      --item.sigrh_conceito,
      --item.sigrh_coluna
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
  pOrdem in number
) return varchar2 is
begin
  return '
with  
unicos as (select distinct ' || pCampo || ' from ' || pNomeTabela || '),
lista as (
select ''' || pCampo || ''' as campolista, listagg(' || pCampo || ', ''; '') within group (order by ' || pCampo || ') as dominio
from unicos
where (select count(*) from unicos) < 50  
),
estatistica as (
select ''' || pCampo || ''' as campo, ' || pOrdem || ' as ordem,
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

select campo, ordem, registros, unicos, nulos, zeros, numericos, datas, minimos, maximos,
case when unicos = 1 then dominio else null end as padrao,
case when unicos > 1 then dominio else null end as dominio
from estatistica
left join lista on campolista = campo
';
end gerarSQLEstatisticasArquivo;

function listarEstatisticaDescritiva(
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return estatisticaDescritivaTabela pipelined as
vSQL varchar2(32000);
vNomeTabela varchar2(50);

type camposTabelaRecord is record (campo varchar2(50),
                                   ordem number(6));
camposTabela camposTabelaRecord;
 
cursor cCamposTabela (vNomeTabela varchar2, vProprietario varchar2) is
   select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
   where owner = vProprietario
     and table_name = vNomeTabela
--     and column_id between 1 and 20
--     and column_id = 2
   order by column_id;

type estatisticasArquivoRecord is record (campo     varchar2(50),
                                   ordem     number(6),
                                   registros number(6),
                                   unicos    number(6),
                                   nulos     number(6),
                                   zeros     number(6),
                                   numericos number(6),
                                   datas     number(6),
                                   minimos   number(20),
                                   maximos   number(20),
                                   padrao    varchar2(50),
                                   dominio   varchar2(1500)
                                  );
estatisticasArquivo estatisticasArquivoRecord;

begin
  if pProprietario is null then vNomeTabela := upper(pNomeTabela);
  else vNomeTabela := upper(pProprietario) || '.' || upper(pNomeTabela);
  end if;
  
  open cCamposTabela(upper(pNomeTabela), upper(pProprietario));
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

    vSQL := gerarSQLEstatisticasArquivo(vNomeTabela, camposTabela.campo, camposTabela.ordem);
    
    execute immediate vSQL into estatisticasArquivo;

    pipe row(estatisticaDescritivaTabelaLinha(
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
    ));

  end loop; 
   
end listarEstatisticaDescritiva;

end PKGMIGLAYOUT;
/