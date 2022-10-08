select PKGMIGLAYOUT.mostrar(PKGMIGCAPAPAGAMENTOLAYOUT.CapaPagamento()) from dual;
/

select * from table(PKGMIGLAYOUT.listar(PKGMIGCAPAPAGAMENTOLAYOUT.CapaPagamento()));
/

select PKGMIGCAPAPAGAMENTOLAYOUT.CapaPagamento() from dual;
/

-- Remover o Pacote
drop package PKGMIGLAYOUT;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGLAYOUT is

type layoutRow is record(
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

type layoutTable is table of layoutRow;

function mostrar(docJSON in clob) return clob;
function listar(docJSON in clob) return layoutTable pipelined;

end PKGMIGLAYOUT;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGLAYOUT is

function mostrar(docJSON in clob) return clob as
begin
 return json_query(docJSON, '$' returning clob pretty);
end mostrar;

function listar(docJSON in clob) return layoutTable pipelined as

cursor cListaLayout is
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
  for item in cListaLayout loop
    pipe row(layoutRow(
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

end PKGMIGLAYOUT;
