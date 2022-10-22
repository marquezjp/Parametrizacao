set serveroutput on
/

-- Exemplo para Listar Validações 
-- Especificação do Layout do Arquivo de Migração => docJSON = PKGMIGCAPAPAGAMENTO.especificacaoLayout()
-- Cursor para os Dados do Arquivo de Migração => PKGMIGCAPAPAGAMENTO.obterArquivoMigracao('emigcapapagamento2'))
--
select * from table(PKGMIGVALIDACAO.listar( -- Listar as Criticas de Validação por Registro e Campo do Arquivo de Migração
                    PKGMIGCAPAPAGAMENTO.especificacaoLayout(), -- Especificação do Layout do Arquivo de Migração
                    PKGMIGCAPAPAGAMENTO.obterArquivoMigracao('emigcapapagamento2')) -- Cursor para os Dados do Arquivo de Migração
                   );
/

-- Exemplo para Separar os Campos da Chave Única
--
select nmarquivo, nuregistro, -- Referencia do Arquivo de Migração
 sgorgao, numatriculalegado, -- Chave Única do Arquivo de Migração (jschaveunica)
 decampo, deconteudo, decritica, dtcritica -- Informações da Critica
from table(PKGMIGVALIDACAO.listar(PKGMIGCAPAPAGAMENTO.especificacaoLayout(),
                                  PKGMIGCAPAPAGAMENTO.obterArquivoMigracao('emigcapapagamento2'))),
json_table(jschaveunica, '$' columns (
sgorgao varchar2(250) path '$.SGORGAO',
numatriculalegado varchar2(250) path '$.NUMATRICULALEGADO'
))
;
/

-- Exemplo para Validar um Campo
--
declare
  retorno varchar2(400);
   
procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

begin
  retorno := PKGMIGVALIDACAO.validar( --'01/01/1901','Não','','validarData');
   pConteudo => 'joao@teste.com.br'
  ,pCampo => 'detipoafastamento'
--  ,pObrigatorio => 'Sim'
--  ,pTamanho => '10'
  ,pRegravalidacao => 'validarNumero'
--  ,pDominio => '["M","F"]'
--  ,pTipo => ''
);
  
  print(retorno);
end;
/

-- Remover o Pacote
drop package PKGMIGVALIDACAO;
/

-- Criar o Especificação do Pacote
create or replace
package PKGMIGVALIDACAO is

type validacaoTabelaLinha is record(
  nmarquivo varchar2(50),
  nuregistro number(8),
  jschaveunica varchar2(500),
  decampo varchar2(50),
  deconteudo varchar2(500),
  decritica varchar2(500),
  dtcritica timestamp(6)
);
type validacaoTabela is table of validacaoTabelaLinha;

type resumoValidacaoTabelaLinha is record(
  decampo varchar2(50),
  decritica varchar2(500)
);
type resumoValidacaoTabela is table of resumoValidacaoTabelaLinha;

type tLista is varray(50) of varchar2(100);

function listar(
  pdocJSON in clob,
  pArquivoMigracao in sys_refcursor
--  pNomeTabela in varchar2
--  pProprietario in varchar2 default null
) return validacaoTabela pipelined;

function validar(
  pConteudo in varchar2,
  pCampo in varchar2,
  pObrigatorio in varchar2 default 'Não',
  pTamanho in varchar2 default null,
  pRegravalidacao in varchar2 default null,
  pDominio in varchar2 default null,
  pTipo in varchar2 default 'VARCHAR2'
) return varchar2;

function gerarLista(pConteudo in varchar2, pSeparator in varchar2 default ',') return tLista;

function validarTamanho(pConteudo in varchar2, pTamanho in varchar2 default null) return varchar2;
function validarNumero(pConteudo in varchar2, pCaracteresEspeciais in varchar2 default '-,.') return varchar2;
function validarValorMonetario(pConteudo in varchar2, pTipo in varchar2 default 'NUMBER(10,2)', pCaracteresEspeciais in varchar2 default '-,.') return varchar2;
function validarData(pConteudo in varchar2, pFormato in varchar2 default 'DD/MM/YYYY') return varchar2;
function validarDataNascimento(pConteudo in varchar2, pFormato in varchar2 default 'DD/MM/YYYY') return varchar2;
function validarNome(pConteudo in varchar2) return varchar2;
function validarEMail(pConteudo in varchar2) return varchar2;
function validarLista(pConteudo in varchar2, pDominio in varchar2 default null) return varchar2;
function validarDominio(pConteudo in varchar2, pCampo in varchar2 default null) return varchar2;

--function validarFaixa(pConteudo in varchar2) return varchar2;
--function validarIndice(pConteudo in varchar2) return varchar2;

/*
function validarCEP(pConteudo in varchar2) return varchar2;
function validarCNPJ(pConteudo in varchar2) return varchar2;
function validarCPF(pConteudo in varchar2) return varchar2;
function validarCargo(pConteudo in varchar2) return varchar2;
function validarCargoComissionado(pConteudo in varchar2) return varchar2;
function validarCarreira(pConteudo in varchar2) return varchar2;
function validarClasse(pConteudo in varchar2) return varchar2;
function validarCompetencia(pConteudo in varchar2) return varchar2;
function validarEspecialidade(pConteudo in varchar2) return varchar2;
function validarGrupoComissionado(pConteudo in varchar2) return varchar2;
function validarGrupoMotivoAfastamento(pConteudo in varchar2) return varchar2;
function validarGrupoOcupacional(pConteudo in varchar2) return varchar2;
function validarMotivoAfastamento(pConteudo in varchar2) return varchar2;
*/

end PKGMIGVALIDACAO;
/

--- Criar o Corpo do Pacote
create or replace
package body PKGMIGVALIDACAO is

function listar(
  pdocJSON in clob,
  pArquivoMigracao in sys_refcursor
) return validacaoTabela pipelined as

  vCritica varchar2(400);
  vdtCritica timestamp;
  
  vArquivoMigracaoRefCursor sys_refcursor;
  vValidacaoRefCursor sys_refcursor;
  vLayoutRefCursor sys_refcursor;

  type arquivoMigracaoLinha is record(
    nmarquivo varchar2(50),
    nuregistro number(8),
    jschaveunica varchar(500),
    jscampos clob
  );
  mig arquivoMigracaoLinha;

  type layoutValidacaoTabelaLinha is record(
    campo VARCHAR2(50),
    obrigatorio VARCHAR2(3),
    tamanho VARCHAR2(5),
    regravalidacao VARCHAR2(250),
    dominio VARCHAR2(250),
    tipo VARCHAR2(10),
    ordem number(3)
  );
  layout layoutValidacaoTabelaLinha;

begin

  vdtCritica := systimestamp;

  vArquivoMigracaoRefCursor := pArquivoMigracao;
  loop fetch vArquivoMigracaoRefCursor into mig;
    exit when vArquivoMigracaoRefCursor%NOTFOUND;

    vLayoutRefCursor := PKGMIGLAYOUT.listarValidacao(pdocJSON);
    loop fetch vLayoutRefCursor into layout;
      exit when vLayoutRefCursor%NOTFOUND;

      vCritica := PKGMIGVALIDACAO.validar(
         pConteudo => json_value(mig.jscampos, '$.' || layout.campo)
        ,pCampo => layout.campo
        ,pObrigatorio => layout.obrigatorio
        ,pTamanho => layout.tamanho
        ,pRegravalidacao => layout.regravalidacao
        ,pDominio => layout.dominio
        ,pTipo => layout.tipo
      );
  
      if vCritica is not null then
        pipe row(validacaoTabelaLinha(
          mig.nmarquivo,
          mig.nuregistro,
          mig.jschaveunica,
          layout.campo, -- decampo
          json_value(mig.jscampos, '$.' || layout.campo), -- deconteudo
          vCritica, -- decritica,
          vdtCritica -- dtcritica
        ));
      end if;

    end loop;
    close vLayoutRefCursor;

  end loop;
  close vArquivoMigracaoRefCursor;
  
end listar;

function validar(
  pConteudo in varchar2,
  pCampo in varchar2,
  pObrigatorio in varchar2 default 'Não',
  pTamanho in varchar2 default null,
  pRegravalidacao in varchar2 default null,
  pDominio in varchar2 default null,
  pTipo in varchar2 default 'VARCHAR2'
) return varchar2 is

  vConteudo varchar2(500);
  vValidarFuncao varchar2(200);
  vCritica varchar2(400);

begin

  vConteudo := PKGMIGLAYOUT.normalizarString(replace(pConteudo, '''', ' '));

  if pObrigatorio = 'Não' and vConteudo is null then return '';
  end if;

  if pObrigatorio = 'Sim' and vConteudo is null then return 'Campo Obrigatorio não Informado';
  end if;

  vCritica := validarTamanho(vConteudo, pTamanho);
  if vCritica is not null then return vCritica; end if;

  vCritica := null;

  vValidarFuncao :=
    case pRegravalidacao
      when 'validarNumero' then 'validarNumero(''' || vConteudo ||''')'
      when 'validarValorMonetario' then 'validarValorMonetario(''' || vConteudo || ''', ''' || pTipo ||''')'
      when 'validarData' then 'validarData(''' || vConteudo || ''')'
      when 'validarDataNascimento' then 'validarDataNascimento(''' || vConteudo ||''')'
      when 'validarNome' then 'validarNome(''' || vConteudo || ''')'
      when 'validarEMail' then 'validarEMail(''' || vConteudo || ''')'
      when 'validarLista' then 'validarLista(''' || vConteudo || ''', ''' || pDominio ||''')'
      when 'validarDominio' then 'validarDominio(''' || vConteudo || ''', ''' || pCampo ||''')'
      else ''
    end;

  if vValidarFuncao is not null then
    execute immediate 'BEGIN :CRITICA := PKGMIGVALIDACAO.' || vValidarFuncao || '; END;'
      using out vCritica;
  end if;
  
  return vCritica;

end validar;

function gerarLista(
  pConteudo in varchar2,
  pSeparator in varchar2 default ','
) return tLista as
  vConteudo varchar2(1000);
  vLista tLista := tLista();
  pos number;
begin
  vConteudo := trim(translate(pConteudo, '[]"', ' ')) || pSeparator;
  loop
  exit when vConteudo is null;
    pos := instr (vConteudo, pSeparator);
    vLista.extend;
    vLista (vLista.count) := ltrim (rtrim (substr (vConteudo, 1, pos - 1)));
    vConteudo := substr (vConteudo, pos + 1);
  end loop;
  return vLista;
end gerarLista;

function validarTamanho(
  pConteudo in varchar2,
  pTamanho in varchar2 default null
) return varchar2 is
  vTamanho number;
begin
  if trim(translate(vTamanho, '01234567890', ' ')) is not null then
    vTamanho := '4000';
  else
    vTamanho := to_number(pTamanho);
  end if;

  if vTamanho >= 4000 then
    vTamanho := 4000;
  end if;

  if length(trim(pConteudo)) > pTamanho then return 'Campo com tamanho maior que permitido'; end if;

  return null;

end validarTamanho;

function validarNumero(
  pConteudo in varchar2,
  pCaracteresEspeciais in varchar2 default '-,.'
) return varchar2 is
  vCritica varchar2(400);
begin
  if trim(translate(pConteudo, '01234567890' || pCaracteresEspeciais, ' ')) is not null then
    return 'Campo Numerico com caracteres não numéricos';
  end if;

  return null;
end validarNumero;

function validarValorMonetario(
  pConteudo in varchar2,
  pTipo in varchar2 default 'NUMBER(10,2)',
  pCaracteresEspeciais in varchar2 default '-,.'
) return varchar2 is
  vCritica varchar2(400);
begin
  vCritica := validarNumero(pConteudo);
  if vCritica is not null then return vCritica; end if;

  return null;
end validarValorMonetario;

function validarData (
  pConteudo in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return varchar2 is
  lData date;
  vCritica varchar2(400);
begin
  lData := to_date(pConteudo, pFormato);
  return null;
exception
    when others then return 'Campo Data com Formato Invalido';
end validarData;

function validarDataNascimento (
  pConteudo in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return varchar2 is
  lData date;
  vCritica varchar2(400);
begin
  vCritica := validarData(pConteudo, pFormato);
  if vCritica is not null then return vCritica; end if;
  
  if lData not between add_months( trunc(sysdate), -12*100 ) and trunc(sysdate) then
    return 'Campo com Data de Nascimento Invalida';
  end if;

  return null;
end validarDataNascimento;

function validarNome(
  pConteudo in varchar2
) return varchar2 is
  vCritica varchar2(400);
begin
  if length(trim(pConteudo)) < 3 then return 'Campo com tamanho menor que permitido'; end if;
  return null;
end  validarNome;

function validarEMail(
  pConteudo in varchar2
) return varchar2 is
  vCritica varchar2(400);
begin
  if not regexp_like(pConteudo, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') then
    return 'Campo de eMail com formato invalido';
  end if;

  return null;
end validarEMail;

function validarLista(
  pConteudo in varchar2,
  pDominio in varchar2 default null
) return varchar2 is
  vCritica varchar2(400);
  vLista tLista := tLista();
begin
  vLista := gerarLista(pDominio);
  for i in 1 .. vLista.count loop 
    if trim(pConteudo) = vLista(i) then return null;
    end if;
  end loop;
  
  return 'Informação diferente do dominio definido';

end  validarLista;

function validarDominio(
  pConteudo in varchar2,
  pCampo in varchar2 default null
) return varchar2 is
  vCritica varchar2(400);
  vConceito JSON_OBJECT_T := JSON_OBJECT_T.parse('
{
	"DETIPOAFASTAMENTO" : "EAFATIPOAFASTAMENTO",
	"NMCENTROCUSTO" : "ECADCENTROCUSTO",
	"NMESTADOCIVIL" : "ECADESTADOCIVIL",
	"NMNATUREZAVINCULO" : "ECADNATUREZAVINCULO",
	"NMOPCAOREMUNERACAO" : "ECADOPCAOREMUNERACAO",
	"NMPAIS" : "ECADPAIS",
	"NMRACA" : "ECADRACA",
	"NMREGIMETRABALHO" : "ECADREGIMETRABALHO",
	"NMRELACAOTRABALHO" : "ECADRELACAOTRABALHO",
	"NMSITUACAOPREVIDENCIARIA" : "ECADSITUACAOPREVIDENCIARIA",
	"NMTIPOCALCULO" : "EPAGTIPOCALCULO",
	"NMTIPOCARGAHORARIA" : "ECADTIPOCARGAHORARIA",
	"NMTIPOFOLHA" : "EPAGTIPOFOLHA",
	"NMTIPOREGIMEPROPRIOPREV" : "ECADTIPOREGIMEPROPRIOPREV",
	"NUAGENCIA" : "ECADAGENCIA",
	"NUBANCO" : "ECADBANCO",
	"SGORGAO" : "VCADORGAO",
	"SGUNIDADEORGANIZACIONAL" : "VCADUNIDADEORGANIZACIONAL"
}
');

  vRetorno varchar2(500);
  vSQL varchar2(200);
   
begin
  
  if vConceito.has(pCampo) then
    vSQL:= 'select ' || pCampo || ' from ' || vConceito.get_string(pCampo) || ' ' ||
           'where PKGMIGLAYOUT.normalizarString(' || pCampo || ') = :conteudo';
    execute immediate vSQL into vRetorno using pConteudo;
  end if;
  
  return null;

exception
    when no_data_found then return 'Informação diferente do dominio cadastrado';

end  validarDominio;

end PKGMIGVALIDACAO;
/