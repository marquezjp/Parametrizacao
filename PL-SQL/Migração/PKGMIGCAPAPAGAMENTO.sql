set serveroutput on
/

select PKGMIGCAPAPAGAMENTO.especificacaoLayout() from dual;
/

select json_query(PKGMIGCAPAPAGAMENTO.especificacaoLayout(), '$.Arquivos[0].Grupos[0]' pretty ) from dual;
/

select json_serialize(PKGMIGCAPAPAGAMENTO.especificacaoLayout() returning clob pretty ) from dual;
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
  vRefCursor := PKGMIGCAPAPAGAMENTO.obterArquivoMigracao('emigcapapagamento2');

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
drop package PKGMIGCAPAPAGAMENTO;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGCAPAPAGAMENTO is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default null) return sys_refcursor;
function especificacaoLayout return clob;

end PKGMIGCAPAPAGAMENTO;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGCAPAPAGAMENTO is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default null) return sys_refcursor is
  vNomeCompletoTabela varchar2(50);
  vSQL varchar2(500);
  vRefCursor sys_refcursor;
begin
  if pProprietario is null then
    vNomeCompletoTabela := upper('sigrhmig') || '.' ||upper(pNomeTabela);
  else
    vNomeCompletoTabela := upper(pProprietario) || '.' || upper(pNomeTabela);
  end if;

  vSQL := 'select ' ||
'''' || upper(pNomeTabela) || ''' as nmarquivo,
rownum as nuregistro,
json_object(SGORGAO, NUMATRICULALEGADO) as jschaveunica,
json_object(*) as jscampos
from ' || vNomeCompletoTabela || ' mig
';

    open vRefCursor for vSQL;
    return vRefCursor;
end obterArquivoMigracao;

function especificacaoLayout return clob is
begin
  return '
{
	"FamiliaArquivos" : "Informações de Pagamento",
	"Arquivos" : {
		"Arquivo" : "Capa de Pagamento",
		"SiglaArquivo" : "CAPAPAGAMENTO",
		"Versão" : "2.1",
		"Tabela" : "EMIGCAPAPAGAMENTO",
		"Grupos" : [
{
	"Grupo" : "Identificação do Vínculo",
	"Campos" : [
		{
			"Campo" : "SGORGAO",
			"Descrição" : "Sigla do órgão da folha de pagamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "20",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADORGAO", "Coluna" : "SGORGAO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NUMATRICULALEGADO",
			"Descrição" : "Matrícula no sistema legado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "MATRICULA_LEGADO"}],
			"RegrasValidação" : ["validarNumero"]
		},
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
		}
	]
},
{
	"Grupo" : "Identificação da Folha",
	"Campos" : [
		{
			"Campo" : "NUANOREFERENCIA",
			"Descrição" : "Ano de referência da folha de pagamento.",
			"Tipo" : "NUMBER",
			"Tamanho" : "4",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUANOREFERENCIA"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUMESREFERENCIA",
			"Descrição" : "Mês de referência da folha de pagamento.",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUMESREFERENCIA"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NMTIPOFOLHA",
			"Descrição" : "Nome do tipo de folha de pagamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "40",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["NORMAL", "RESCISÃO", "13º SALÁRIO", "FÉRIAS", "ADIANTAMENTO DE 13º SALÁRIO", "INSTITUIDORES DE PENSÃO", "APOSENTADORIA", "13º SALÁRIO DE APOSENTADORIA", "ADIANTAMENTO DE 13º DE APOSENTADORIA", "OUTROS TIPOS DE FOLHA", "BOLSISTA", "RESIDENTE", "RESIDENTE - 13º SALÁRIO", "PESQUISADOR", "COMISSIONADO PURO", "FÚNEBRE", "FÚNEBRE - 13º SALÁRIO"],
			"SIGRH" : [{"Conceito" : "EPAGTIPOFOLHA", "Coluna" : "NMTIPOFOLHA"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMTIPOCALCULO",
			"Descrição" : "Nome do tipo de cálculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "40",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["NORMAL", "SIMULAÇÃO", "RECÁLCULO DO MÊS", "CÁLCULO RETROATIVO", "SUPLEMENTAR", "RECÁLCULO COMPLEMENTAR"],
			"SIGRH" : [{"Conceito" : "EPAGTIPOCALCULO", "Coluna" : "NMTIPOCALCULO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NUSEQUENCIALFOLHA",
			"Descrição" : " Número de sequencial da folha",
			"Tipo" : "NUMBER",
			"Tamanho" : "6",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUSEQUENCIALFOLHA"}],
			"RegrasValidação" : ["validarNumero"]
		}
	]
},
{
	"Grupo" : "Informações do Contracheque",
	"Campos" : [
		{
			"Campo" : "DTCALCULO",
			"Descrição" : "Data do cálculo da folha que deu origem ao contracheque",
			"Tipo" : "DATE",
			"Tamanho" : "",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "DTCALCULO"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "DTCREDITO",
			"Descrição" : "Data de crédito",
			"Tipo" : "DATE",
			"Tamanho" : "",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "DTCREDITO"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "VLPROVENTOS",
			"Descrição" : "Valor dos proventos",
			"Tipo" : "NUMBER",
			"Tamanho" : "13,2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "VLPROVENTOS"}],
			"RegrasValidação" : ["validarValorMonetario"]
		},
		{
			"Campo" : "VLDESCONTOS",
			"Descrição" : "Valor dos descontos",
			"Tipo" : "NUMBER",
			"Tamanho" : "13,2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "VLDESCONTOS"}],
			"RegrasValidação" : ["validarValorMonetario"]
		},
		{
			"Campo" : "INSISTEMAORIGEM",
			"Descrição" : "Indicativo de contracheque do sistema legado",
			"Tipo" : "NUMBER",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "INSISTEMAORIGEM"}],
			"RegrasValidação" : ["validarFaixa"]
		}
	]
},
{
	"Grupo" : "Dados Pessoais Básicos",
	"Campos" : [
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
			"Campo" : "DTNASCIMENTO",
			"Descrição" : "Data de nascimento da pessoa.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "DTNASCIMENTO"}],
			"RegrasValidação" : ["validarDataNascimento"]
		},
		{
			"Campo" : "FLSEXO",
			"Descrição" : "Sexo.",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["M", "F"],
			"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "FLSEXO"}],
			"RegrasValidação" : ["validarLista"]
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
			"Campo" : "NMPAIS",
			"Descrição" : "Nome do país. Indica a nacionalidade da pessoa.",
			"Tipo" : "Varchar2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["ACORES", "AFEGANISTAO", "AFRICA DO SUL", "ALASCA (EUA)", "ALBANIA", "ALEMANHA", "ANDORRA", "ANGOLA", "ANTARTICA", "ANTIGUA", "ANTILHAS HOLANDESAS", "ARABIA SAUDITA", "ARGELIA", "ARGENTINA", "ARMENIA", "AUSTRALIA", "AUSTRIA", "AZERBAIJAO", "BAHAMAS", "BAHREIN (BAREINE)", "BANGLADESH", "BARBADOS", "BASHKORTOSTAN", "BELARUS", "BELGICA", "BELIZE", "BENIN", "BERMUDAS", "BOLIVIA", "BOSNIA-HERZEGOVINA", "BOTSWANA", "BRASIL", "BRUNEI", "BULGARIA", "BURKINA FASSO", "BURUNDI", "BUTAO", "CABO VERDE (REPUBLICA DO)", "CAMAROES", "CAMBOJA", "CANADA", "CATAR", "CAZAQUISTAO", "CHADE", "CHILE", "CHINA", "CHIPRE (REPUBLICA DE)", "CHUVASH (REPUBLICA DE)", "CINGAPURA", "COLOMBIA", "COMOROS (REPUBLICA FEDERAL ISLAMICA DE)", "CONGO (ZAIRE)", "COREIA DO NORTE", "COREIA DO SUL", "COSTA DO MARFIM", "COSTA RICA", "CROACIA", "CUBA", "DINAMARCA", "DJIBOUTI", "DOMINICA", "EGITO", "EL SALVADOR", "EMIRADOS ARABES UNIDOS", "EQUADOR", "ERITEIA (ERITREIA)", "ESCOCIA (GBR)", "ESLOVAQUIA", "ESLOVENIA", "ESPANHA", "ESTADOS UNIDOS DA AMERICA", "ESTONIA", "ETIOPIA", "FIJI (ILHAS)", "FILIPINAS", "FINLANDIA", "FORMOSA TAIWAN (CHINA)", "FRANCA", "GABAO", "GAMBIA", "GANA", "GEORGIA (REPUBLICA DE)", "GIBRALTAR (GBR)", "GRA-BRETANHA", "GRANADA", "GRECIA", "GROENLANDIA (DINAMARCA)", "GUADALUPE (FRANCA)", "GUAM (EUA)", "GUATEMALA", "GUERNSEY (GRB)", "GUIANA", "GUIANA FRANCESA", "GUINE", "GUINE EQUATORIAL", "GUINE-BISSAU", "GUINE-CONACRI", "HAITI", "HONDURAS", "HONG KONG", "HUNGRIA", "IEMEN (REPUBLICA DO)", "ILHA NORFOLK", "ILHAS CAIMA", "ILHAS CANARIAS", "ILHAS COCOS (KEELING)", "ILHAS COOK", "ILHAS MARSHALL", "INDIA", "INDONESIA", "INGLATERRA", "IRA", "IRAQUE", "IRLANDA", "ISLANDIA", "ISRAEL", "ITALIA", "IUGOSLAVIA", "JAMAICA", "JAPAO", "JORDANIA", "KUWAIT", "LAOS", "LESOTO", "LETONIA (REPUBLICA DA)", "LIBANO", "LIBERIA", "LIBIA", "LIECHTENSTEIN", "LITUANIA", "LUXEMBURGO", "MACAU", "MACEDONIA", "MADAGASCAR", "MALASIA", "MALDIVAS (ILHAS)", "MALI", "MALTA", "MARROCOS", "MARTINICA (FRANCA)", "MAURITANIA", "MAURITIUS (MAURICIO)", "MAYOTTE (FRANCA)", "MEXICO", "MICRONESIA", "MOCAMBIQUE", "MOLDAVIA (REPUBLICA DE)", "MONACO (PRINCIPADO DE)", "MONGOLIA", "MONTSERRAT (GBR)", "NAMIBIA", "NAURU", "NEPAL", "NEVIS", "NICARAGUA", "NIGER", "NIGERIA", "NORUEGA", "NOVA CALEDONIA", "NOVA ZELANDIA", "OMA (MUSCAT)", "PAISES BAIXOS (HOLANDA)", "PALAU (REPUBLICA DE)", "PANAMA", "PAPUA NOVA GUINE", "PAQUISTAO", "PARAGUAI", "PERU", "POLINESIA FRANCESA", "POLONIA", "PORTO RICO (EUA)", "PORTUGAL", "QATAR (DOHA)", "QUENIA", "REPUBLICA CENTRO AFRICANA", "REPUBLICA DEMOCRATICA DE TIMOR-LESTE", "REPUBLICA DOMINICANA", "REPUBLICA TCHECA", "ROMENIA", "RUANDA", "RUSSIA", "SAARA OCIDENTAL", "SAMOA AMERICANA (EUA.)", "SAMOA OCIDENTAL", "SAN MARINO", "SANTA HELENA (GBR)", "SANTA LUCIA", "SANTA SE (CIDADE DO VATICANO)", "SAO KITTS (E NEVIS) INDEPENDENTE", "SAO PEDRO E MIQUELON (FRANCA)", "SAO TOME E PRINCIPE", "SAO VICENTE E GRANADINAS", "SENEGAL", "SERRA LEOA", "SERVIA", "SIRIA", "SOMALIA", "SRI LANKA (CEILAO)", "SUAZILANDIA", "SUDAO", "SUECIA", "SUICA", "SURINAME", "TADJIQUISTAO (REPUBLICA)", "TAILANDIA", "TAITI (POLINESIA FRANCESA)", "TANZANIA", "TOGO", "TOKELAU (ILHAS)", "TONGA", "TRINIDAD E TOBAGO", "TUNISIA", "TURCOMENISTAO (TURCOMENIA)", "TURQUIA", "TUVALU", "UCRANIA", "UGANDA", "URUGUAI", "UZBEQUISTAO", "VANUATU", "VENEZUELA", "VIETNA", "ZAIRE", "ZAMBIA", "ZANZIBAR E PEMBA (TANGANICA)", "ZIMBABUE (ZIMBABWE)"],
			"SIGRH" : [{"Conceito" : "ECADPAIS", "Coluna" : "NMPAIS"}],
			"RegrasValidação" : ["validarDominio"]
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
			"Campo" : "DTADMISSAO",
			"Descrição" : "Data de admissão.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "DTADMISSAO"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "DTFIMPREVISTO",
			"Descrição" : "Data de fim previsto.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOEFETIVO", "Coluna" : "DTFIMPREVISTO"}],
			"RegrasValidação" : ["validarData"]
		}
	]
},
{
	"Grupo" : "Informações do Vínculo",
	"Campos" : [
		{
			"Campo" : "NMRELACAOTRABALHO",
			"Descrição" : "Descrição da relação de trabalho",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADRELACAOTRABALHO", "Coluna" : "NMRELACAOTRABALHO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMREGIMETRABALHO",
			"Descrição" : "Descrição do regime de trabalho",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADREGIMETRABALHO", "Coluna" : "NMREGIMETRABALHO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMNATUREZAVINCULO",
			"Descrição" : "Descrição da natureza de vínculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["CARGO PERMANENTE", "CARGO TEMPORÁRIO", "EMPREGO PERMANENTE", "EMPREGO TEMPORÁRIO", "FUNÇÃO PÚBLICA TEMPORÁRIA", "PENSIONISTA", "FUNÇÃO PÚBLICA ESPECIAL"],
			"SIGRH" : [{"Conceito" : "ECADNATUREZAVINCULO", "Coluna" : "DENATUREZAVINCULO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMREGIMEPREVIDENCIARIO",
			"Descrição" : "Regime previdenciário da relação de vinculo. ",
			"Tipo" : "Varchar2",
			"Tamanho" : "60",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["REGIME GERAL", "REGIME PRÓPRIO - IPREV", "SEM CONTRIBUIÇÃO", "REGIME PRÓPRIO (OUTROS ESTADOS, MUNICÍPIOS E FEDERAL)", "CONTRIBUIÇÃO DE PROTEÇÃO SOCIAL DOS MILITARES"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOEFETIVO", "Coluna" : "CDREGIMEPREVIDENCIARIO"}, {"Conceito" : "ECADREGIMEPREVIDENCIARIO", "Coluna" : "NMREGIMEPREVIDENCIARIO"}],
			"RegrasValidação" : ["validarRegimePrevidenciario"]
		},
		{
			"Campo" : "NMSITUACAOPREVIDENCIARIA",
			"Descrição" : "Descrição da situação previdenciária do vínculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["ATIVO", "INATIVO/APOSENTADO", "INSTITUIDOR DE PENSÃO", "PENSIONISTA NÃO PREVIDENCIÁRIA", "FALECIDO SEM PENSÃO", "SEM VÍNCULO PREVIDENCIÁRIO", "APOSENTADORIA ENCERRADA", "ATIVO COM DIREITO A APOSENTADORIA COMPULSÓRIA", "PENSIONISTA PREVIDENCIÁRIA", "BENEFICIÁRIO DE AUXÍLIO RECLUSÃO", "EX-PARLAMENTAR", "FALECIDO", "DECISÃO JUDICIAL", "MORTE PRESUMIDA", "AUXÍLIO RECLUSÃO"],
			"SIGRH" : [{"Conceito" : "ECADSITUACAOPREVIDENCIARIA", "Coluna" : "DESITUACAOPREVIDENCIARIA"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMTIPOREGIMEPROPRIOPREV",
			"Descrição" : " Nome  de tipo de  Regime Próprio de Previdência Social",
			"Tipo" : "Varchar2",
			"Tamanho" : "80",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["FUNDO FINANCEIRO", "FUNDO PREVIDENCIÁRIO", "FUNDO FINANCEIRO LC 662/15"],
			"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "CDTIPOREGIMEPROPRIOPREV"}, {"Conceito" : "ECADTIPOREGIMEPROPRIOPREV", "Coluna" : "NMTIPOREGIMEPROPRIOPREV"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "FLPREVIDENCIACOMP",
			"Descrição" : "Indicador de previdência complementar. ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "FLPREVIDENCIACOMP"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "FLATIVO",
			"Descrição" : "Indica se servidor é considerado ativo ou inativo",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "S",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "FLATIVO"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "NMTIPOCARGAHORARIA",
			"Descrição" : "Nome do tipo de carga horária.",
			"Tipo" : "Varchar2",
			"Tamanho" : "30",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["DIÁRIA", "SEMANAL", "MENSAL", "QUINZENAL", "HORISTA"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGAHORARIA", "Coluna" : "CDTIPOCARGAHORARIA"}, {"Conceito" : "ECADTIPOCARGAHORARIA", "Coluna" : "NMTIPOCARGAHORARIA"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NUCARGAHORARIA",
			"Descrição" : "Carga horária padrão da carreira",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "NUCHO"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUCARGAHORARIARELACAO",
			"Descrição" : "Carga horária do servidor",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "NUCHORELACAO"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "SGUNIDADEORGANIZACIONAL",
			"Descrição" : "Sigla da Unidade Organizacional (lotação do servidor)",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "15",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADUNIDADEORGANIZACIONAL", "Coluna" : "SGUNIDADEORGANIZACIONAL"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NMJORNADATRABALHO",
			"Descrição" : "Nome da jornada de trabalho.",
			"Tipo" : "Varchar2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADHISTJORNADATRABALHO", "Coluna" : "CDJORNADATRABALHO"}, {"Conceito" : "ECADJORNADATRABALHO", "Coluna" : "NMJORNADATRABALHO"}],
			"RegrasValidação" : ["validarNome"]
		},
		{
			"Campo" : "DECENTROCUSTO",
			"Descrição" : "Nome do centro de custo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADCENTROCUSTO", "Coluna" : "DECENTROCUSTO"}],
			"RegrasValidação" : ["validarCentroCusto"]
		},
		{
			"Campo" : "NUDEPENDENTES",
			"Descrição" : "Número de Dependentes  para Desconto do IRRF",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : null,
			"RegrasValidação" : ["validarNumero"]
		}
	]
},
{
	"Grupo" : "Informações do último afastamento",
	"Campos" : [
		{
			"Campo" : "DTINICIOAFASTAMENTO",
			"Descrição" : "Data de inicio do afastamento",
			"Tipo" : "DATE",
			"Tamanho" : "8",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "EAFAFASTAMENTOVINCULO", "Coluna" : "DTINICIO"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "DTFIMAFASTAMENTO",
			"Descrição" : "Data fim do afastamento",
			"Tipo" : "DATE",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "EAFAFASTAMENTOVINCULO", "Coluna" : "DTFIM"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "DTFIMPREVISTOAFASTAMENTO",
			"Descrição" : "Data fim prevista do afastamento",
			"Tipo" : "DATE",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["DD/MM/AAAA"],
			"SIGRH" : [{"Conceito" : "EAFAFASTAMENTOVINCULO", "Coluna" : "DTFIMPREVISTA"}],
			"RegrasValidação" : ["validarData"]
		},
		{
			"Campo" : "FLTIPOAFASTAMENTO",
			"Descrição" : "Indicativo do tipo de afastamento",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["TEMPORARIO", "DEFINITIVO"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLTIPOAFASTAMENTO"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "FLREMUNERADO",
			"Descrição" : "Indica se o afastamento é remunerado ou não",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLREMUNERADO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTTEMP", "Coluna" : "FLREMUNERADO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTDEF", "Coluna" : "FLREMUNERADO"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "FLREMUNERACAOINTEGRAL",
			"Descrição" : "Indica se a remuneração é integral",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "EAFAHISTMOTIVAFASTTEMP", "Coluna" : "FLREMUNERACAOINTEGRAL"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "DEMOTIVOAFASTAMENTO",
			"Descrição" : "Descrição do motivo de afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EAFAHISTMOTIVAFASTTEMP", "Coluna" : "DEMOTIVOAFASTTEMPORARIO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTDEF", "Coluna" : "DEMOTIVOAFASTDEFINITIVO"}],
			"RegrasValidação" : ["validarMotivoAfastamento"]
		},
		{
			"Campo" : "NMGRUPOMOTIVOAFASTAMENTO",
			"Descrição" : "Descrição do grupo de motivos de afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["", ""],
			"SIGRH" : [{"Conceito" : "EAFAGRUPOMOTIVOAFASTAMENTO", "Coluna" : "NMGRUPOMOTIVOAFASTAMENTO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTTEMP", "Coluna" : "CDGRUPOMOTIVOAFASTAMENTO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTDEF", "Coluna" : "CDGRUPOMOTIVOAFASTAMENTO"}],
			"RegrasValidação" : ["validarGrupoMotivoAfastamento"]
		},
		{
			"Campo" : "FLACIDENTETRABALHO",
			"Descrição" : "Indica se o motivo de afastamento é relacionado a acidente de trabalho",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLACIDENTETRABALHO"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "DEOBSERVACAO",
			"Descrição" : "Observações sobre o afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "400",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "DEOBSERVACAO"}],
			"RegrasValidação" : null
		}
	]
},
{
	"Grupo" : "Dados Bancários",
	"Campos" : [
		{
			"Campo" : "NUBANCOCREDITO",
			"Descrição" : "Número do banco para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "4",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADBANCO", "Coluna" : "NUBANCO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NUAGENCIACREDITO",
			"Descrição" : "Número da agência para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "5",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADAGENCIA", "Coluna" : "NUAGENCIA"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "NUCONTACREDITO",
			"Descrição" : "Número da conta para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "12",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "NUCONTACREDITO"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUDVCONTACREDITO",
			"Descrição" : "Dígito da conta para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "NUDVCONTACREDITO"}],
			"RegrasValidação" : null
		},
		{
			"Campo" : "FLTIPOCONTACREDITO",
			"Descrição" : "Tipo de conta crédito",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "C",
			"Domínio" : ["C", "P"],
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "FLTIPOCONTACREDITO"}],
			"RegrasValidação" : ["validarLista"]
		}
	]
},
{
	"Grupo" : "Informações do Cargo Efetivo ou Temporário Básicos",
	"Campos" : [
		{
			"Campo" : "DECARREIRA",
			"Descrição" : "Descrição da carreira da estrutura.",
			"Tipo" : "Varchar2",
			"Tamanho" : "200",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarCarreira"]
		},
		{
			"Campo" : "DEGRUPOOCUPACIONAL",
			"Descrição" : "Descrição do grupo ocupacional da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarGrupoOcupacional"]
		},
		{
			"Campo" : "DECARGO",
			"Descrição" : "Descrição da cargo da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarCargo"]
		},
		{
			"Campo" : "DECLASSE",
			"Descrição" : "Descrição da classe da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarClasse"]
		},
		{
			"Campo" : "DECOMPETENCIA",
			"Descrição" : "Descrição da competencia da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarCompetencia"]
		},
		{
			"Campo" : "DEESPECIALIDADE",
			"Descrição" : "Descrição da especialidade da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADITEMCARREIRA", "Coluna" : "DEITEMCARREIRA"}],
			"RegrasValidação" : ["validarEspecialidade"]
		},
		{
			"Campo" : "NUNIVELCEF",
			"Descrição" : "Nivel de pagamento",
			"Tipo" : "Varchar2",
			"Tamanho" : "3",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOEFETIVO", "Coluna" : "NUNIVELPAGAMENTO"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUREFERENCIACEF",
			"Descrição" : "Referencia de pagamento",
			"Tipo" : "Varchar2",
			"Tamanho" : "3",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOEFETIVO", "Coluna" : "NUREFERENCIAPAGAMENTO"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "FLTIPOOCUPACAO",
			"Descrição" : "Tipo de ocupação da carga horária:  ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["D", "T"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGAHORARIA", "Coluna" : "FLTIPOOCUPACAO"}],
			"RegrasValidação" : ["validarLista"]
		}
	]
},
{
	"Grupo" : "Informações do Cargo Comissionado Básicos",
	"Campos" : [
		{
			"Campo" : "DEGRUPOCOMISSIONADO",
			"Descrição" : "Nome do Grupo Ocupacional de Comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADGRUPOOCUPACIONAL", "Coluna" : "NMGRUPOOCUPACIONAL"}],
			"RegrasValidação" : ["validarGrupoComissionado"]
		},
		{
			"Campo" : "DECARGOCOMISSIONADO",
			"Descrição" : "Descrição do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADEVOLUCAOCARGOCOMISSIONADO", "Coluna" : "DECARGOCOMISSIONADO"}],
			"RegrasValidação" : ["validarCargoComissionado"]
		},
		{
			"Campo" : "NUNIVELCCO",
			"Descrição" : "Nível do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "10",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADHISTOPCAOREMUNERACAOCCO", "Coluna" : "NUNIVEL"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUREFERENCIACCO",
			"Descrição" : "Referência do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "10",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "ECADHISTOPCAOREMUNERACAOCCO", "Coluna" : "NUREFERENCIA"}],
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "FLPRINCIPAL",
			"Descrição" : "Indica se a relação de vínculo é a principal do vínculo. ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLPRINCIPAL"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "FLTIPOPROVIMENTO",
			"Descrição" : "Tipo de provimento do cargo comissionado: D - Designação, N - Nomeação, S - Substituido",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["D", "N", "S"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLTIPOPROVIMENTO"}],
			"RegrasValidação" : ["validarLista"]
		},
		{
			"Campo" : "NMOPCAOREMUNERACAO",
			"Descrição" : "Nome da opção de remuneração.",
			"Tipo" : "Varchar2",
			"Tamanho" : "100",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["PELO CARGO EFETIVO COM PERCENTUAL SOBRE O COMISSIONADO", "PELO CARGO COMISSIONADO", "PELA REMUNERAÇÃO ORIGEM", "COMO MILITAR NA ORIGEM", "PELO F.G. OU F.T.G", "EXCLUSIVAMENTE PELO CARGO EFETIVO", "RECEBIMENTO PELO LEGISLATIVO"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "CDOPCAOREMUNERACAO"}, {"Conceito" : "ECADOPCAOREMUNERACAO", "Coluna" : "NMOPCAOREMUNERACAO"}],
			"RegrasValidação" : ["validarDominio"]
		},
		{
			"Campo" : "FLPAGASUBSIDIO",
			"Descrição" : "Indicador de paga subsidio",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S", "N"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLPAGASUBSIDIO"}],
			"RegrasValidação" : ["validarLista"]
		}
	]
},
{
	"Grupo" : "Informações da Pensão Previdenciária",
	"Campos" : [
		{
			"Campo" : "NUMATINSTITUIDORLEGADO",
			"Descrição" : "Matrícula do instituidor de pensão previdenciária",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : null,
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "NUPERCENTCOTA",
			"Descrição" : "Percentual da cota do beneficiário da pensão previdenciária",
			"Tipo" : "NUMBER",
			"Tamanho" : "5,2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : null,
			"SIGRH" : [{"Conceito" : "EPVDHISTPENSAOPREVIDENCIARIA", "Coluna" : "NUPERCENTFIXOQUOTA"}],
			"RegrasValidação" : ["validarNumero"]
		}
	]
}

		]
	}
}
';
end especificacaoLayout;

end PKGMIGCAPAPAGAMENTO;
/