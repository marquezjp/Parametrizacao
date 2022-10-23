set serveroutput on
/

select * from table(PKGMIGLAYOUT.listar(PKGMIGPESSOA.especificacaoLayout()));
/

select json_serialize(PKGMIGPESSOA.especificacaoLayout() returning clob pretty ) from dual;
/

--select listagg(campo, ', ') within group (order by rownum)
--from table(PKGMIGLAYOUT.listar(PKGMIGPESSOA.especificacaoLayout()))

select p.*
from table(PKGMIGPESSOA.listar(PKGMIGPESSOA.obter('emigpessoa', pCriterio => 'nmpessoa like ''CARLA%'''))),
json_table(jscampos, '$' columns (
  NUCPF, DTNASCIMENTO, FLSEXO, NMPESSOA, NMSOCIAL, NMUSUAL, NMREDUZIDO, NMRAIS, NMMAE, NMPAI, NMPAIS, SGESTADO,
  NMLOCALIDADENASC, NMESTADOCIVIL, NMRACA, DTNATURALIZACAO, DEEMAIL, NMTIPOHABITACAO, NMTIPOLOGRADOURORES, NMLOGRADOURORES,
  NUNUMERORES, DECOMPLEMENTORES, NMBAIRRORES, NMLOCALIDADERES, SGESTADORES, NUCEPRES, FLMESMOENDERECO, NMTIPOLOGRADOUROCORRRESP,
  NMLOGRADOUROCORRESP, NUNUMEROCORRESP, DECOMPLEMENTOCORRESP, NMBAIRROCORRESP, NMLOCALIDADECORRESP, SGESTADOCORRESP, NUCEPCORRESP,
  NUDDDRES, NUTELEFONERES, NUDDDCONT, NUTELEFONECONT, NUDDDCEL, NUCELULAR, NUCARTEIRAIDENTIDADE, SGORGAOEMISSOR, NMORGAOEMISSOR,
  SGESTADOCI, DTEXPEDICAO, NUTITULO, NUZONA, NUSECAO, DTEMISSAOTITULO, NMLOCALIDADETITULO, SGESTADOTITULO, NUCARTEIRAHAB, NMCATEGORIA,
  SGESTADOHABILITACAO, DTPRIMHABILITACAO, DTVALIDADEHABILITACAO, NUNIS, DTCADASTRONIS, NUCTPS, NUSERIECTPS, SGESTADOCTPS, DTEMISSAOCTPS,
  DTINICIOEMPREGO, DTFIMEMPREGO, NMTIPOEMPRESA, NUOCUPACAO, NMREGIMETRABALHO, NMREGIMEPREVIDENCIARIO, NMPAISORIGEM, DTENTRADA, DTLIMITEPERM,
  NRRNE, ORGAOEMISSORRNE, DTEXPEDICAORNE, CLASSTRABESTRANGEIRO, NURESERVISTA, NUSERIE, SGORGAORESERVISTA, DEUNIDADE, NUANO,
  DTEMISSAORESERVISTA, SGESTADORESERVISTA, NMCATEGCERTRESERVISTA, NMREGIAOMILITAR, NMCIRCUNSCRICAO, NMTIPONECESSIDADE, NMTIPODEFICIENCIA,
  FLVAGADEFICIENTE, NMFATORRH, NMTIPOSANGUINEO)
) p
;
/

select * from table(PKGMIGPESSOA.listarValidacao('emigpessoa', pCriterio => 'nmpessoa like ''CARLA%'''));
/

select * from table(PKGMIGPESSOA.listarResumoValidacao('emigpessoa', pCriterio => 'nmpessoa like ''CARLA%'''));
/

-- Remover o Pacote
drop package PKGMIGPESSOA;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGPESSOA is

type arquivoMigracaoTabelaLinha is record(
nmarquivo varchar2(50),
nuregistro number(8),
jschaveunica varchar(500),
jscampos clob
);
type arquivoMigracaoTabela is table of arquivoMigracaoTabelaLinha;

type resumoValidacaoTabelaLinha is record(
decritica varchar2(500),
nutotal number(8), 
nucpf number(8), 
dtnascimento number(8), 
flsexo number(8), 
nmpessoa number(8), 
nmsocial number(8), 
nmusual number(8), 
nmreduzido number(8), 
nmrais number(8), 
nmmae number(8), 
nmpai number(8), 
nmpais number(8), 
sgestado number(8), 
nmlocalidadenasc number(8), 
nmestadocivil number(8), 
nmraca number(8), 
dtnaturalizacao number(8), 
deemail number(8), 
nmtipohabitacao number(8), 
nmtipologradourores number(8), 
nmlogradourores number(8), 
nunumerores number(8), 
decomplementores number(8), 
nmbairrores number(8), 
nmlocalidaderes number(8), 
sgestadores number(8), 
nucepres number(8), 
flmesmoendereco number(8), 
nmtipologradourocorrresp number(8), 
nmlogradourocorresp number(8), 
nunumerocorresp number(8), 
decomplementocorresp number(8), 
nmbairrocorresp number(8), 
nmlocalidadecorresp number(8), 
sgestadocorresp number(8), 
nucepcorresp number(8), 
nudddres number(8), 
nutelefoneres number(8), 
nudddcont number(8), 
nutelefonecont number(8), 
nudddcel number(8), 
nucelular number(8), 
nucarteiraidentidade number(8), 
sgorgaoemissor number(8), 
nmorgaoemissor number(8), 
sgestadoci number(8), 
dtexpedicao number(8), 
nutitulo number(8), 
nuzona number(8), 
nusecao number(8), 
dtemissaotitulo number(8), 
nmlocalidadetitulo number(8), 
sgestadotitulo number(8), 
nucarteirahab number(8), 
nmcategoria number(8), 
sgestadohabilitacao number(8), 
dtprimhabilitacao number(8), 
dtvalidadehabilitacao number(8), 
nunis number(8), 
dtcadastronis number(8), 
nuctps number(8), 
nuseriectps number(8), 
sgestadoctps number(8), 
dtemissaoctps number(8), 
dtinicioemprego number(8), 
dtfimemprego number(8), 
nmtipoempresa number(8), 
nuocupacao number(8), 
nmregimetrabalho number(8), 
nmregimeprevidenciario number(8), 
nmpaisorigem number(8), 
dtentrada number(8), 
dtlimiteperm number(8), 
nrrne number(8), 
orgaoemissorrne number(8), 
dtexpedicaorne number(8), 
classtrabestrangeiro number(8), 
nureservista number(8), 
nuserie number(8), 
sgorgaoreservista number(8), 
deunidade number(8), 
nuano number(8), 
dtemissaoreservista number(8), 
sgestadoreservista number(8), 
nmcategcertreservista number(8), 
nmregiaomilitar number(8), 
nmcircunscricao number(8), 
nmtiponecessidade number(8), 
nmtipodeficiencia number(8), 
flvagadeficiente number(8), 
nmfatorrh number(8), 
nmtiposanguineo number(8)
);
type resumoValidacaoTabela is table of resumoValidacaoTabelaLinha;

function obter(pNomeTabela varchar2, pProprietario varchar2 default 'sigrhmig', pCriterio varchar2 default null) return sys_refcursor;
function listar(pArquivoMigracaoRefCursor sys_refcursor) return PKGMIGPESSOA.arquivoMigracaoTabela pipelined;
function listarValidacao(pNomeTabela varchar2, pProprietario varchar2 default null, pCriterio varchar2 default null) return PKGMIGVALIDACAO.validacaoTabela pipelined;
function listarResumoValidacao(pNomeTabela varchar2, pProprietario varchar2 default null, pCriterio varchar2 default null) return PKGMIGPESSOA.resumoValidacaoTabela pipelined;
function especificacaoLayout return clob;

end PKGMIGPESSOA;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGPESSOA is

function obter(pNomeTabela varchar2, pProprietario varchar2 default 'sigrhmig', pCriterio varchar2 default null) return sys_refcursor is
  vProprietario varchar2(50);
  vNomeCompletoTabela varchar2(50);
  vListaCampos varchar2(5000);
  vCriterio varchar2(100);
  vSQL varchar2(10000);
  vRefCursor sys_refcursor;
begin
  if pProprietario is null then
    vProprietario := 'sigrhmig';
  else
    vProprietario := pProprietario;
  end if;
  vNomeCompletoTabela := upper(vProprietario) || '.' || upper(pNomeTabela);

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

  if pCriterio is not null then vCriterio := ' where ' || pCriterio || ' '; end if;
  
  vSQL := '
select ''' || upper(pNomeTabela) || ''' as nmarquivo, rownum as nuregistro,
json_object(NUCPF) as jschaveunica,
json_object(*) as jscampos
from (select ' || vListaCampos || ' from ' || vNomeCompletoTabela || vCriterio || ' ) mig
';

    open vRefCursor for vSQL;
    return vRefCursor;
end obter;

function listar(pArquivoMigracaoRefCursor sys_refcursor) return PKGMIGPESSOA.arquivoMigracaoTabela pipelined is
item PKGMIGPESSOA.arquivoMigracaoTabelaLinha;
begin
  loop fetch pArquivoMigracaoRefCursor into item;
    exit when pArquivoMigracaoRefCursor%notfound;
    pipe row(PKGMIGPESSOA.arquivoMigracaoTabelaLinha(
      item.nmarquivo,
      item.nuregistro,
      item.jschaveunica,
      item.jscampos
    ));
  end loop;

end listar;

function listarValidacao(pNomeTabela varchar2, pProprietario varchar2 default null, pCriterio varchar2 default null) return PKGMIGVALIDACAO.validacaoTabela pipelined is
item PKGMIGVALIDACAO.validacaoTabelaLinha;
begin
  for item in (
    select * from table(PKGMIGVALIDACAO.listar(
                          PKGMIGPESSOA.especificacaoLayout(),
                          PKGMIGPESSOA.obter('emigpessoa', pCriterio => 'nmpessoa like ''CARLA%''')
                        ))
  ) loop
    pipe row(item);
  end loop;

end listarValidacao;

function listarResumoValidacao(pNomeTabela varchar2, pProprietario varchar2 default null, pCriterio varchar2 default null) return PKGMIGPESSOA.resumoValidacaoTabela pipelined is
item PKGMIGPESSOA.resumoValidacaoTabelaLinha;
begin
  for item in (
    with
    campos as (
    select decritica, decampo, count(*) as qtde
    from table(PKGMIGVALIDACAO.listar(
               PKGMIGPESSOA.especificacaoLayout(),
               PKGMIGPESSOA.obter('emigpessoa', pCriterio => 'nmpessoa like ''CARLA%''')))
    group by decritica, decampo
    ),
    
    criticas as (
    select decritica, sum(qtde) as qtde
    from campos
    group by decritica
    )
    
    select * from (
    select decritica, 'NUTOTAL' as decampo, qtde from criticas
    union
    select decritica, decampo, qtde from campos
    order by decritica, decampo
    )
    pivot (sum(qtde) for decampo in (
    'NUTOTAL' as NUTOTAL,
    'NUCPF' as NUCPF,
    'DTNASCIMENTO' as DTNASCIMENTO,
    'FLSEXO' as FLSEXO,
    'NMPESSOA' as NMPESSOA,
    'NMSOCIAL' as NMSOCIAL,
    'NMUSUAL' as NMUSUAL,
    'NMREDUZIDO' as NMREDUZIDO,
    'NMRAIS' as NMRAIS,
    'NMMAE' as NMMAE,
    'NMPAI' as NMPAI,
    'NMPAIS' as NMPAIS,
    'SGESTADO' as SGESTADO,
    'NMLOCALIDADENASC' as NMLOCALIDADENASC,
    'NMESTADOCIVIL' as NMESTADOCIVIL,
    'NMRACA' as NMRACA,
    'DTNATURALIZACAO' as DTNATURALIZACAO,
    'DEEMAIL' as DEEMAIL,
    'NMTIPOHABITACAO' as NMTIPOHABITACAO,
    'NMTIPOLOGRADOURORES' as NMTIPOLOGRADOURORES,
    'NMLOGRADOURORES' as NMLOGRADOURORES,
    'NUNUMERORES' as NUNUMERORES,
    'DECOMPLEMENTORES' as DECOMPLEMENTORES,
    'NMBAIRRORES' as NMBAIRRORES,
    'NMLOCALIDADERES' as NMLOCALIDADERES,
    'SGESTADORES' as SGESTADORES,
    'NUCEPRES' as NUCEPRES,
    'FLMESMOENDERECO' as FLMESMOENDERECO,
    'NMTIPOLOGRADOUROCORRRESP' as NMTIPOLOGRADOUROCORRRESP,
    'NMLOGRADOUROCORRESP' as NMLOGRADOUROCORRESP,
    'NUNUMEROCORRESP' as NUNUMEROCORRESP,
    'DECOMPLEMENTOCORRESP' as DECOMPLEMENTOCORRESP,
    'NMBAIRROCORRESP' as NMBAIRROCORRESP,
    'NMLOCALIDADECORRESP' as NMLOCALIDADECORRESP,
    'SGESTADOCORRESP' as SGESTADOCORRESP,
    'NUCEPCORRESP' as NUCEPCORRESP,
    'NUDDDRES' as NUDDDRES,
    'NUTELEFONERES' as NUTELEFONERES,
    'NUDDDCONT' as NUDDDCONT,
    'NUTELEFONECONT' as NUTELEFONECONT,
    'NUDDDCEL' as NUDDDCEL,
    'NUCELULAR' as NUCELULAR,
    'NUCARTEIRAIDENTIDADE' as NUCARTEIRAIDENTIDADE,
    'SGORGAOEMISSOR' as SGORGAOEMISSOR,
    'NMORGAOEMISSOR' as NMORGAOEMISSOR,
    'SGESTADOCI' as SGESTADOCI,
    'DTEXPEDICAO' as DTEXPEDICAO,
    'NUTITULO' as NUTITULO,
    'NUZONA' as NUZONA,
    'NUSECAO' as NUSECAO,
    'DTEMISSAOTITULO' as DTEMISSAOTITULO,
    'NMLOCALIDADETITULO' as NMLOCALIDADETITULO,
    'SGESTADOTITULO' as SGESTADOTITULO,
    'NUCARTEIRAHAB' as NUCARTEIRAHAB,
    'NMCATEGORIA' as NMCATEGORIA,
    'SGESTADOHABILITACAO' as SGESTADOHABILITACAO,
    'DTPRIMHABILITACAO' as DTPRIMHABILITACAO,
    'DTVALIDADEHABILITACAO' as DTVALIDADEHABILITACAO,
    'NUNIS' as NUNIS,
    'DTCADASTRONIS' as DTCADASTRONIS,
    'NUCTPS' as NUCTPS,
    'NUSERIECTPS' as NUSERIECTPS,
    'SGESTADOCTPS' as SGESTADOCTPS,
    'DTEMISSAOCTPS' as DTEMISSAOCTPS,
    'DTINICIOEMPREGO' as DTINICIOEMPREGO,
    'DTFIMEMPREGO' as DTFIMEMPREGO,
    'NMTIPOEMPRESA' as NMTIPOEMPRESA,
    'NUOCUPACAO' as NUOCUPACAO,
    'NMREGIMETRABALHO' as NMREGIMETRABALHO,
    'NMREGIMEPREVIDENCIARIO' as NMREGIMEPREVIDENCIARIO,
    'NMPAISORIGEM' as NMPAISORIGEM,
    'DTENTRADA' as DTENTRADA,
    'DTLIMITEPERM' as DTLIMITEPERM,
    'NRRNE' as NRRNE,
    'ORGAOEMISSORRNE' as ORGAOEMISSORRNE,
    'DTEXPEDICAORNE' as DTEXPEDICAORNE,
    'CLASSTRABESTRANGEIRO' as CLASSTRABESTRANGEIRO,
    'NURESERVISTA' as NURESERVISTA,
    'NUSERIE' as NUSERIE,
    'SGORGAORESERVISTA' as SGORGAORESERVISTA,
    'DEUNIDADE' as DEUNIDADE,
    'NUANO' as NUANO,
    'DTEMISSAORESERVISTA' as DTEMISSAORESERVISTA,
    'SGESTADORESERVISTA' as SGESTADORESERVISTA,
    'NMCATEGCERTRESERVISTA' as NMCATEGCERTRESERVISTA,
    'NMREGIAOMILITAR' as NMREGIAOMILITAR,
    'NMCIRCUNSCRICAO' as NMCIRCUNSCRICAO,
    'NMTIPONECESSIDADE' as NMTIPONECESSIDADE,
    'NMTIPODEFICIENCIA' as NMTIPODEFICIENCIA,
    'FLVAGADEFICIENTE' as FLVAGADEFICIENTE,
    'NMFATORRH' as NMFATORRH,
    'NMTIPOSANGUINEO' as NMTIPOSANGUINEO
    ))
    order by decritica
  ) loop
    pipe row(PKGMIGPESSOA.resumoValidacaoTabelaLinha(
      item.decritica,
      item.nutotal,
      item.nucpf,
      item.dtnascimento,
      item.flsexo,
      item.nmpessoa,
      item.nmsocial,
      item.nmusual,
      item.nmreduzido,
      item.nmrais,
      item.nmmae,
      item.nmpai,
      item.nmpais,
      item.sgestado,
      item.nmlocalidadenasc,
      item.nmestadocivil,
      item.nmraca,
      item.dtnaturalizacao,
      item.deemail,
      item.nmtipohabitacao,
      item.nmtipologradourores,
      item.nmlogradourores,
      item.nunumerores,
      item.decomplementores,
      item.nmbairrores,
      item.nmlocalidaderes,
      item.sgestadores,
      item.nucepres,
      item.flmesmoendereco,
      item.nmtipologradourocorrresp,
      item.nmlogradourocorresp,
      item.nunumerocorresp,
      item.decomplementocorresp,
      item.nmbairrocorresp,
      item.nmlocalidadecorresp,
      item.sgestadocorresp,
      item.nucepcorresp,
      item.nudddres,
      item.nutelefoneres,
      item.nudddcont,
      item.nutelefonecont,
      item.nudddcel,
      item.nucelular,
      item.nucarteiraidentidade,
      item.sgorgaoemissor,
      item.nmorgaoemissor,
      item.sgestadoci,
      item.dtexpedicao,
      item.nutitulo,
      item.nuzona,
      item.nusecao,
      item.dtemissaotitulo,
      item.nmlocalidadetitulo,
      item.sgestadotitulo,
      item.nucarteirahab,
      item.nmcategoria,
      item.sgestadohabilitacao,
      item.dtprimhabilitacao,
      item.dtvalidadehabilitacao,
      item.nunis,
      item.dtcadastronis,
      item.nuctps,
      item.nuseriectps,
      item.sgestadoctps,
      item.dtemissaoctps,
      item.dtinicioemprego,
      item.dtfimemprego,
      item.nmtipoempresa,
      item.nuocupacao,
      item.nmregimetrabalho,
      item.nmregimeprevidenciario,
      item.nmpaisorigem,
      item.dtentrada,
      item.dtlimiteperm,
      item.nrrne,
      item.orgaoemissorrne,
      item.dtexpedicaorne,
      item.classtrabestrangeiro,
      item.nureservista,
      item.nuserie,
      item.sgorgaoreservista,
      item.deunidade,
      item.nuano,
      item.dtemissaoreservista,
      item.sgestadoreservista,
      item.nmcategcertreservista,
      item.nmregiaomilitar,
      item.nmcircunscricao,
      item.nmtiponecessidade,
      item.nmtipodeficiencia,
      item.flvagadeficiente,
      item.nmfatorrh,
      item.nmtiposanguineo    
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