set serveroutput on
/

select PKGMIGPESSOA.especificacaoLayout() from dual;
/

select json_query(PKGMIGPESSOA.especificacaoLayout(), '$.Arquivos[0].Grupos[0]' pretty ) from dual;
/

select json_serialize(PKGMIGPESSOA.especificacaoLayout() returning clob pretty ) from dual;
/

select * from table(PKGMIGPESSOA.listarValidacao('emigpessoa'));
/

--- Exemplo Listar o Arquivo de Migração
declare
vRefCursor sys_refcursor;

type arquivoMigracaoLinha is record(
nmarquivo varchar2(50),
nuregsitro number(8),
jschaveunica varchar(500),
jscampos clob
);
item arquivoMigracaoLinha;

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

begin
  vRefCursor := PKGMIGPESSOA.obterArquivoMigracao('emigpessoa');

  loop fetch vRefCursor into item;
    exit when vRefCursor%NOTFOUND;
    print(item.nmarquivo || ' ' ||
          item.nuregsitro || ' ' ||
          item.jschaveunica || ' ' ||
          item.jscampos
    );
  end loop;

end;
/

-- Remover o Pacote
drop package PKGMIGPESSOA;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGPESSOA is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default 'sigrhmig', pCriterio varchar2 default null) return sys_refcursor;
function listarValidacao(pNomeTabela varchar2) return PKGMIGVALIDACAO.validacaoTabela pipelined;
function listarResumoValidacao(pNomeTabela varchar2) return PKGMIGVALIDACAO.resumoValidacaoTabela pipelined;
function especificacaoLayout return clob;

end PKGMIGPESSOA;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGPESSOA is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default 'sigrhmig', pCriterio varchar2 default null) return sys_refcursor is
  vNomeCompletoTabela varchar2(50);
  vListaCampos varchar2(5000);
  vCriterio varchar2(100);
  vSQL varchar2(10000);
  vRefCursor sys_refcursor;
begin
  vNomeCompletoTabela := upper(pProprietario) || '.' || upper(pNomeTabela);

  vSQL := '
select listagg(nvl(tab.campo,''null'') || '' as '' || layout.campo, '', '')
       within group (order by layout.ordem) as campos
from (select campo, rownum as ordem
      from table(PKGMIGLAYOUT.listar(PKGMIGPESSOA.especificacaoLayout()))) layout
left join (select column_name as campo from sys.all_tab_columns
           where owner = upper(:pProprietario)
             and table_name = upper(:pNomeTabela)
          ) tab on tab.campo = layout.campo 
';

  execute immediate vSQL into vListaCampos using pProprietario, pNomeTabela;

  if vCriterio is not null then vCriterio := ' where ' || vCriterio || ' '; end if;
  
  vSQL := '
select ''' || upper(pNomeTabela) || ''' as nmarquivo, rownum as nuregistro,
json_object(NUCPF) as jschaveunica,
json_object(*) as jscampos
from (select ' || vListaCampos || ' from ' || vNomeCompletoTabela || vCriterio || ' ) mig
';

    open vRefCursor for vSQL;
    return vRefCursor;
end obterArquivoMigracao;

function listarValidacao(pNomeTabela varchar2) return PKGMIGVALIDACAO.validacaoTabela pipelined is
item PKGMIGVALIDACAO.validacaoTabelaLinha;
begin
  for item in (
    select * from table(PKGMIGVALIDACAO.listar(
                          PKGMIGPESSOA.especificacaoLayout(),
                          PKGMIGPESSOA.obterArquivoMigracao(pNomeTabela)
                        ))
  ) loop
    pipe row(PKGMIGVALIDACAO.validacaoTabelaLinha(
      item.nmarquivo,
      item.nuregistro,
      item.jschaveunica,
      item.decampo,
      item.deconteudo,
      item.decritica,
      item.dtcritica
    ));
  end loop;

end listarValidacao;

function listarResumoValidacao(pNomeTabela varchar2) return PKGMIGVALIDACAO.resumoValidacaoTabela pipelined is
item PKGMIGVALIDACAO.resumoValidacaoTabelaLinha;
begin
  for item in (
    select decritica, decampo, count(*) as qtde
    from table(PKGMIGVALIDACAO.listar(
              PKGMIGPESSOA.especificacaoLayout(),
              PKGMIGPESSOA.obterArquivoMigracao(pNomeTabela)))
    group by decritica, decampo
  ) loop
    pipe row(PKGMIGVALIDACAO.resumoValidacaoTabelaLinha(
      item.decampo,
      item.decritica
    ));
  end loop;

end listarResumoValidacao;

function especificacaoLayout return clob is
begin
  return '
{
"FamiliaArquivos" : "Informações de Pagamento",
"Arquivos" : {
"Arquivo" : "Pessoa",
"SiglaArquivo" : "PESSOA",
"Versão" : "2.0",
"Tabela" : "EMIGPESSOA",
"Grupos" : [
{
"Grupo" : "Dados Pessoais",
"Campos" : [
{
"Campo" : "NUCPF",
"Descrição" : "CPF da pessoa.",
"Tipo" : "Char",
"Tamanho" : "11",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUCPF"}],
"RegrasValidação" : ["validarCPF"]
},
{
"Campo" : "DTNASCIMENTO",
"Descrição" : "Data de nascimento da pessoa.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["DD/MM/AAAA"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTNASCIMENTO"}],
"RegrasValidação" : ["validarDataNascimento"]
},
{
"Campo" : "FLSEXO",
"Descrição" : "Sexo. (M - Masculino; F - Feminino)",
"Tipo" : "Char",
"Tamanho" : "1",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["M", "F"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "FLSEXO"}],
"RegrasValidação" : ["validarLista"]
},
{
"Campo" : "NMPESSOA",
"Descrição" : "Nome completo da pessoa.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMPESSOA"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMSOCIAL",
"Descrição" : "Nome Social da Pessoa. Obrigatório arquivo anexo comprovando a existencia do nome Social.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMSOCIAL"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMUSUAL",
"Descrição" : "Nome usual ou nome de guerra.",
"Tipo" : "Varchar2",
"Tamanho" : "50",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMUSUAL"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMREDUZIDO",
"Descrição" : "Nome reduzido da pessoa.",
"Tipo" : "Varchar2",
"Tamanho" : "40",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMREDUZIDO"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMRAIS",
"Descrição" : "Nome para RAIS e DIRF.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMRAIS"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMMAE",
"Descrição" : "Nome da mãe.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMMAE"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMPAI",
"Descrição" : "Nome do pai.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMPAI"}],
"RegrasValidação" : ["validarNome"]
},
{
"Campo" : "NMPAIS",
"Descrição" : "Nome do país. Indica a nacionalidade da pessoa.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPAIS", "Coluna" : "NMPAIS"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "SGESTADO",
"Descrição" : "Sigla do estado de nascimento da pessoa.",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGESTADO"}],
"RegrasValidação" : ["validarLista"]
},
{
"Campo" : "NMLOCALIDADENASC",
"Descrição" : "Nome do município de nascimento",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADLOCALIDADE", "Coluna" : "NMLOCALIDADE"}],
"RegrasValidação" : null
},
{
"Campo" : "NMESTADOCIVIL",
"Descrição" : "Nome do estado civil.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["SOLTEIRO", "CASADO", "VIUVO", "SEPARADO JUDICIALMENTE", "DIVORCIADO", "MARITAL", "NAO INFORMADO", "UNIAO ESTAVEL"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDESTADOCIVIL"}, {"Conceito" : "ECADESTADOCIVIL", "Coluna" : "NMESTADOCIVIL"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMRACA",
"Descrição" : "Nome da raça.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["INDIGENA", "BRANCA", "NEGRA", "AMARELA", "PARDA", "NAO INFORMADO"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDRACA"}, {"Conceito" : "ECADRACA", "Coluna" : "NMRACA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "DTNATURALIZACAO",
"Descrição" : "Data de naturalização da pessoa.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTNATURALIZACAO"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "DEEMAIL",
"Descrição" : "Endereço eletrônico da pessoa. Deve ser obrigatório quando a pessoa for tipo de usuário cadastrador ou operador.",
"Tipo" : "Varchar2",
"Tamanho" : "200",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DEEMAIL"}],
"RegrasValidação" : ["validarEMail"]
}
]
},
{
"Grupo" : "Endereço",
"Campos" : [
{
"Campo" : "NMTIPOHABITACAO",
"Descrição" : "Nome do tipo de habitação.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["RESIDÊNCIA PRÓPRIA", "RESIDÊNCIA ALUGADA", "RESIDÊNCIA CEDIDA", "PENSÃO", "HOTEL", "NÃO INFORMADO"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDTIPOHABITACAO"}, {"Conceito" : "ECADTIPOHABITACAO", "Coluna" : "NMTIPOHABITACAO"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMTIPOLOGRADOURORES",
"Descrição" : "Nome do tipo de logradouro do endereço residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["RUA", "ALAMEDA", "RODOVIA", "PRACA", "QUADRA", "SERVIDAO", "ETC", ""],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDENDERECO"}, {"Conceito" : "ECADTIPOLOGRADOURO", "Coluna" : "NMTIPOLOGRADOURO"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMLOGRADOURORES",
"Descrição" : "Nome do logradouro residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NMLOGRADOURO"}],
"RegrasValidação" : null
},
{
"Campo" : "NUNUMERORES",
"Descrição" : "Número do logradouro residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NUNUMERO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "DECOMPLEMENTORES",
"Descrição" : "Complemento do endereço residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "100",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "DECOMPLLOGRADOURO"}],
"RegrasValidação" : null
},
{
"Campo" : "NMBAIRRORES",
"Descrição" : "Nome do bairro residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "CDBAIRRO"}, {"Conceito" : "ECADBAIRRO", "Coluna" : "NMBAIRRO"}],
"RegrasValidação" : null
},
{
"Campo" : "NMLOCALIDADERES",
"Descrição" : "Nome do município residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "CDLOCALIDADE"}, {"Conceito" : "ECADLOCALIDADE", "Coluna" : "NMLOCALIDADE"}],
"RegrasValidação" : null
},
{
"Campo" : "SGESTADORES",
"Descrição" : "Sigla do Estado residencial",
"Tipo" : "VARCHAR",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADLOCALIDADE", "Coluna" : "SGESTADO"}],
"RegrasValidação" : null
},
{
"Campo" : "NUCEPRES",
"Descrição" : "Numero do cep residencial",
"Tipo" : "VARCHAR2",
"Tamanho" : "8",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NUCEP"}],
"RegrasValidação" : ["validarCEP"]
},
{
"Campo" : "FLMESMOENDERECO",
"Descrição" : "Indica se o endereço para correspondência é o mesmo do endereço residencial. (S - Sim; N - Não)",
"Tipo" : "Char",
"Tamanho" : "1",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["S", "N"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "FLMESMOENDERECO"}],
"RegrasValidação" : ["validarLista"]
},
{
"Campo" : "NMTIPOLOGRADOUROCORRRESP",
"Descrição" : "Nome do tipo de logradouro do endereço de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["RUA", "ALAMEDA", "RODOVIA", "PRACA", "QUADRA", "SERVIDAO", "ETC", ""],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDENDERECOCORRESP"}, {"Conceito" : "ECADTIPOLOGRADOURO", "Coluna" : "NMTIPOLOGRADOURO"}],
"RegrasValidação" : null
},
{
"Campo" : "NMLOGRADOUROCORRESP",
"Descrição" : "Nome do logradouro de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NMLOGRADOURO"}],
"RegrasValidação" : null
},
{
"Campo" : "NUNUMEROCORRESP",
"Descrição" : "Número do logradouro de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NUNUMERO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "DECOMPLEMENTOCORRESP",
"Descrição" : "Complemento do endereço de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "100",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "DECOMPLLOGRADOURO"}],
"RegrasValidação" : null
},
{
"Campo" : "NMBAIRROCORRESP",
"Descrição" : "Nome do bairro de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "CDBAIRRO"}, {"Conceito" : "ECADBAIRRO", "Coluna" : "NMBAIRRO"}],
"RegrasValidação" : null
},
{
"Campo" : "NMLOCALIDADECORRESP",
"Descrição" : "Nome do município de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "CDLOCALIDADE"}, {"Conceito" : "ECADLOCALIDADE", "Coluna" : "NMLOCALIDADE"}],
"RegrasValidação" : null
},
{
"Campo" : "SGESTADOCORRESP",
"Descrição" : "Sigla do Estado de correspondência",
"Tipo" : "VARCHAR",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADLOCALIDADE", "Coluna" : "SGESTADO"}],
"RegrasValidação" : null
},
{
"Campo" : "NUCEPCORRESP",
"Descrição" : "Numero do cep de correspondência",
"Tipo" : "VARCHAR2",
"Tamanho" : "8",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADENDERECO", "Coluna" : "NUCEP"}],
"RegrasValidação" : ["validarCEP"]
},
{
"Campo" : "NUDDDRES",
"Descrição" : "DDD do telefone residencial.",
"Tipo" : "Varchar2",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUDDDRES"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUTELEFONERES",
"Descrição" : "Número do telefone residencial.",
"Tipo" : "Varchar2",
"Tamanho" : "9",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUTELEFONERES"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUDDDCONT",
"Descrição" : "DDD do telefone de contato.",
"Tipo" : "Varchar2",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUDDDCONT"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUTELEFONECONT",
"Descrição" : "Número do telefone de contato.",
"Tipo" : "Varchar2",
"Tamanho" : "9",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUTELEFONECONT"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUDDDCEL",
"Descrição" : "DDD do telefone celular.",
"Tipo" : "Varchar2",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUDDDCEL"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUCELULAR",
"Descrição" : "Número do telefone celular.",
"Tipo" : "Varchar2",
"Tamanho" : "9",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUCELULAR"}],
"RegrasValidação" : ["validarNumero"]
}
]
},
{
"Grupo" : "Documento de Identidade",
"Campos" : [
{
"Campo" : "NUCARTEIRAIDENTIDADE",
"Descrição" : "Número da carteira de identidade.",
"Tipo" : "Varchar2",
"Tamanho" : "13",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUCARTEIRAIDENTIDADE"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "SGORGAOEMISSOR",
"Descrição" : "Sigla do Órgão emissor",
"Tipo" : "Varchar2",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["SSP ", "MAE", "MEX", "MMA", "DPF", "OAB"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDORGAOEMISSOR"}, {"Conceito" : "ECADORGAOEMISSOR", "Coluna" : "SGORGAOEMISSOR"}],
"RegrasValidação" : ["validarOrgaoEmissior"]
},
{
"Campo" : "NMORGAOEMISSOR",
"Descrição" : "Nome do Órgao Expedidor",
"Tipo" : "Varchar2",
"Tamanho" : "100",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["Secretaria de Seguranca Publica ", "Ministerio da Aeronautica", "Ministerio do Exercito", "Departamento da Policia Federal", "Ordem dos Advogados do Brasil"],
"SIGRH" : [{"Conceito" : "ECADORGAOEMISSOR", "Coluna" : "NMORGAOEMISSOR"}],
"RegrasValidação" : ["validarOrgaoEmissior"]
},
{
"Campo" : "SGESTADOCI",
"Descrição" : "Sigla do Estado da carteira de identidade.",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGESTADOCI"}],
"RegrasValidação" : null
},
{
"Campo" : "DTEXPEDICAO",
"Descrição" : "Data de expedição da carteira de identidade.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTEXPEDICAO"}],
"RegrasValidação" : ["validarData"]
}
]
},
{
"Grupo" : "Documento Título de Eleitor",
"Campos" : [
{
"Campo" : "NUTITULO",
"Descrição" : "Número do título de eleitor.",
"Tipo" : "Varchar2",
"Tamanho" : "12",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUTITULO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUZONA",
"Descrição" : "Número da zona eleitoral.",
"Tipo" : "Number",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUZONA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUSECAO",
"Descrição" : "Número da seção eleitoral.",
"Tipo" : "Number",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUSECAO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "DTEMISSAOTITULO",
"Descrição" : "Data de emissão do título de eleitor.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTEMISSAOTITULO"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "NMLOCALIDADETITULO",
"Descrição" : "Nome do município do título de eleitor.",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDMUNICIPIOTITULO"}],
"RegrasValidação" : null
},
{
"Campo" : "SGESTADOTITULO",
"Descrição" : "Sigla do Estado do título de eleitor. ",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGESTADOTITULO"}],
"RegrasValidação" : null
}
]
},
{
"Grupo" : "Documento Carteira de Habilitação",
"Campos" : [
{
"Campo" : "NUCARTEIRAHAB",
"Descrição" : "Número da carteira de habilitação.",
"Tipo" : "Varchar2",
"Tamanho" : "12",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUCARTEIRAHAB"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NMCATEGORIA",
"Descrição" : "Categoria da carteira de habilitação.",
"Tipo" : "Varchar2",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NMCATEGORIA"}],
"RegrasValidação" : null
},
{
"Campo" : "SGESTADOHABILITACAO",
"Descrição" : "Sigla do Estado.",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGESTADOHABILITACAO"}],
"RegrasValidação" : null
},
{
"Campo" : "DTPRIMHABILITACAO",
"Descrição" : "Data da primeira habilitação.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTPRIMHABILITACAO"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "DTVALIDADEHABILITACAO",
"Descrição" : "Data de validade da habilitação.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTVALIDADEHABILITACAO"}],
"RegrasValidação" : ["validarData"]
}
]
},
{
"Grupo" : "Número de Identificação Social",
"Campos" : [
{
"Campo" : "NUNIS",
"Descrição" : "Número de Identificação Social (NIS) ou PIS/PASEP ou Número de Registro do Trabalhador (NIT).",
"Tipo" : "Varchar2",
"Tamanho" : "11",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUPIS"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "DTCADASTRONIS",
"Descrição" : "Data de cadastro do Número de Identificação Social (NIS) ou PIS/PASEP ou Número de Registro do Trabalhador (NIT).",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTCADASTROPIS"}],
"RegrasValidação" : ["validarData"]
}
]
},
{
"Grupo" : "Documento Carteira de Trabalho (CTPS)",
"Campos" : [
{
"Campo" : "NUCTPS",
"Descrição" : "Número da CTPS da pessoa.",
"Tipo" : "Varchar2",
"Tamanho" : "7",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOACTPS", "Coluna" : "CDPESSOA"}, {"Conceito" : "ECADPESSOACTPS", "Coluna" : "NUCTPS"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUSERIECTPS",
"Descrição" : "Número de série da CTPS.",
"Tipo" : "Varchar2",
"Tamanho" : "5",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOACTPS", "Coluna" : "NUSERIE"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "SGESTADOCTPS",
"Descrição" : "Sigla do Estado.",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOACTPS", "Coluna" : "SGESTADO"}],
"RegrasValidação" : null
},
{
"Campo" : "DTEMISSAOCTPS",
"Descrição" : "Data de emissão da CTPS.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOACTPS", "Coluna" : "DTEMISSAO"}],
"RegrasValidação" : ["validarData"]
}
]
},
{
"Grupo" : "Dados do Primeiro Emprego",
"Campos" : [
{
"Campo" : "DTINICIOEMPREGO",
"Descrição" : "Data de início do primeiro emprego.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTINICIOEMPREGO"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "DTFIMEMPREGO",
"Descrição" : "Data de fim do primeiro emprego.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTFIMEMPREGO"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "NMTIPOEMPRESA",
"Descrição" : " Nome de tipo de empresa",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["PRIVADA", "PÚBLICA", "ENTIDADE SOCIAL", "ONG"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDTIPOEMPRESA"}, {"Conceito" : "ECADTIPOEMPRESA", "Coluna" : "NMTIPOEMPRESA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NUOCUPACAO",
"Descrição" : "Numero da Classificação Brasileira de Ocupações (CBO)",
"Tipo" : "Number",
"Tamanho" : "6",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDOCUPACAO"}, {"Conceito" : "ECADOCUPACAO", "Coluna" : "NUOCUPACAO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NMREGIMETRABALHO",
"Descrição" : "Nome do regime de trabalho do primeiro emprego.",
"Tipo" : "Number",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["CLT", "ESTATUTÁRIO", "ADMINISTRATIVO ESPECIAL", "NÃO QUALIFICADO", "EXCEDENTE", "CONTRIBUINTE INDIVIDUAL", "VOLUNTÁRIO"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDREGIMETRABALHO"}, {"Conceito" : "ECADREGIMETRABALHO", "Coluna" : "NMREGIMETRABALHO"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMREGIMEPREVIDENCIARIO",
"Descrição" : "Nome do regime previdenciário do primeiro emprego. ",
"Tipo" : "Varchar2",
"Tamanho" : "60",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["REGIME GERAL", "REGIME PRÓPRIO", "SEM CONTRIBUIÇÃO", "REGIME PRÓPRIO (OUTROS ESTADOS, MUNICÍPIOS E FEDERAL)", "CONTRIBUIÇÃO DE PROTEÇÃO SOCIAL DOS MILITARES", ""],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDREGIMEPREVIDENCIARIO"}],
"RegrasValidação" : ["validarDominio"]
}
]
},
{
"Grupo" : "Dados de Migração",
"Campos" : [
{
"Campo" : "NMPAISORIGEM",
"Descrição" : "Nome do país de Origem",
"Tipo" : "Varchar2",
"Tamanho" : "90",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDPAISORIGEM"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "DTENTRADA",
"Descrição" : "Data de entrada no Brasil.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTENTRADA"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "DTLIMITEPERM",
"Descrição" : "Data limite de permanência no Brasil.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTLIMITEPERM"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "NRRNE",
"Descrição" : "Número de inscrição no Registro Nacional de Estrangeiros",
"Tipo" : "Varchar2",
"Tamanho" : "14",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NRRNE"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "ORGAOEMISSORRNE",
"Descrição" : "Órgão de emissão do RNE",
"Tipo" : "Varchar2",
"Tamanho" : "20",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "ORGAOEMISSORRNE"}],
"RegrasValidação" : null
},
{
"Campo" : "DTEXPEDICAORNE",
"Descrição" : "Data da expedição do RNE",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTEXPEDICAORNE"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "CLASSTRABESTRANGEIRO",
"Descrição" : "Classificação da condição de ingresso do trabalhador estrangeiro no Brasil: 1 - Visto permanente; 2 - Visto temporário; 3 - Asilado; 4 - Refugiado; 5 - Solicitante de Refúgio; 6 - Residente fora do Brasil; 7 - Deficiente físico e com mais de 51 anos; 8 - Com residência provisória e anistiado, em situação irregular; 9 - Permanência no Brasil em razão de filhos ou cônjuge brasileiros; 10 - Beneficiado pelo acordo entre países do Mercosul; 11 - Dependente de agente diplomático e/ou consular de países que mantém convênio de reciprocidade para o exercício de atividade remunerada no Brasil; 12 - Beneficiado pelo Tratado de Amizade, Cooperação e Consulta entre a República Federativa do Brasil e a República Portuguesa.",
"Tipo" : "Number",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CLASSTRABESTRANGEIRO"}],
"RegrasValidação" : ["validarDominio"]
}
]
},
{
"Grupo" : "Documento Carteira de Reservista",
"Campos" : [
{
"Campo" : "NURESERVISTA",
"Descrição" : "Número da carteira de reservista.",
"Tipo" : "Varchar2",
"Tamanho" : "12",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NURESERVISTA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUSERIE",
"Descrição" : "Número de série da carteira de reservista.",
"Tipo" : "Varchar2",
"Tamanho" : "1",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUSERIE"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "SGORGAORESERVISTA",
"Descrição" : "Sigla do Órgão da carteira de reservista.",
"Tipo" : "Varchar2",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGORGAORESERVISTA"}],
"RegrasValidação" : null
},
{
"Campo" : "DEUNIDADE",
"Descrição" : "Unidade da carteira de reservista.",
"Tipo" : "Varchar2",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DEUNIDADE"}],
"RegrasValidação" : null
},
{
"Campo" : "NUANO",
"Descrição" : "Ano da reserva.",
"Tipo" : "Char",
"Tamanho" : "4",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUANO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "DTEMISSAORESERVISTA",
"Descrição" : "Data de emissão da carteira de reservista.",
"Tipo" : "Data",
"Tamanho" : "10",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTEMISSAORESERVISTA"}],
"RegrasValidação" : ["validarData"]
},
{
"Campo" : "SGESTADORESERVISTA",
"Descrição" : "Sigla do Estado.",
"Tipo" : "Char",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "SGESTADORESERVISTA"}],
"RegrasValidação" : null
},
{
"Campo" : "NMCATEGCERTRESERVISTA",
"Descrição" : "Nome da categoria de reservista.",
"Tipo" : "Varchar2",
"Tamanho" : "80",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["1a. CATEGORIA", "2a. CATEGORIA", "3a. CATEGORIA", "DISPENSA DE INCORPORAÇÃO"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDCATEGCERTRESERVISTA"}, {"Conceito" : "ECADCATEGCERTRESERVISTA", "Coluna" : "NMCATEGCERTRESERVISTA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMREGIAOMILITAR",
"Descrição" : "Descrição da região militar do certificado de reservista ",
"Tipo" : "Varchar2",
"Tamanho" : "80",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDREGIAOMILITAR"}, {"Conceito" : "ECADREGIAOMILITAR", "Coluna" : "NMREGIAOMILITAR"}],
"RegrasValidação" : null
},
{
"Campo" : "NMCIRCUNSCRICAO",
"Descrição" : "Descrição da circunscrição do certificado de reservista. ",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["1. CSM", "2. CSM", "....", "31. CSM", ""],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDCIRCUNSCRICAO"}, {"Conceito" : "ECADCIRCUNSCRICAO", "Coluna" : "NMCIRCUNSCRICAO"}],
"RegrasValidação" : null
}
]
},
{
"Grupo" : "Dados de Portador de Necessidades Especiais",
"Campos" : [
{
"Campo" : "NMTIPONECESSIDADE",
"Descrição" : "Nome do tipo de necessidade.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["ESPECIAL", "ESPECIAL PERMANENTE", "INCAPACIDADE"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDTIPONECESSIDADE"}, {"Conceito" : "ECADTIPONECESSIDADE", "Coluna" : "NMTIPONECESSIDADE"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMTIPODEFICIENCIA",
"Descrição" : "Nome do tipo de deficiência. ",
"Tipo" : "Varchar2",
"Tamanho" : "80",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["FÍSICA", "AUDITIVA", "VISUAL", "MENTAL", "MÚLTIPLA", "OUTRAS", "INTELECTUAL"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDTIPODEFICIENCIA"}, {"Conceito" : "ECADTIPODEFICIENCIA", "Coluna" : "NMTIPODEFICIENCIA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "FLVAGADEFICIENTE",
"Descrição" : "INDICA SE A PESSOA OCUPA VAGA DE PESSOA COM DEFICIENCIA OU REABILITADA",
"Tipo" : "Char",
"Tamanho" : "1",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "FLVAGADEFICIENTE"}],
"RegrasValidação" : ["validarLista"]
}
]
},
{
"Grupo" : "Dados Biométricos",
"Campos" : [
{
"Campo" : "NMFATORRH",
"Descrição" : "Nome do fator RH.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["POSITIVO", "NEGATIVO", ""],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDFATORRH"}, {"Conceito" : "ECADFATORRH", "Coluna" : "NMFATORRH"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMTIPOSANGUINEO",
"Descrição" : "Nome do tipo sanguíneo.",
"Tipo" : "Varchar2",
"Tamanho" : "30",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["A", "B", "AB", "O"],
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "CDTIPOSANGUINEO"}, {"Conceito" : "ECADTIPOSANGUINEO", "Coluna" : "NMTIPOSANGUINEO"}],
"RegrasValidação" : ["validarDominio"]
}
]
}
]
}
}
';
end especificacaoLayout;

end PKGMIGPESSOA;
/