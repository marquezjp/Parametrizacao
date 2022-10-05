select * from table(PKGMIGLAYOUT.listar(PKGMIGLAYOUT.CapaPagamento()));
/

select PKGMIGLAYOUT.CapaPagamento() from dual;
/

-- Remover o Pacote
drop package PKGMIGLAYOUT;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGLAYOUT is

type layoutRow is record (
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
);

type layoutTable is table of layoutRow;

function listar(docJSON in JSON_OBJECT_T) return layoutTable;

function CapaPagamento return JSON_OBJECT_T;

end PKGMIGLAYOUT;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGLAYOUT is

function listar(docJSON in JSON_OBJECT_T) return layoutTable
is
    v_ret   layoutTable;
begin
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
    bulk collect into v_ret
    from json_table(docJSON, '$' columns (
      familiaarquivos varchar2(250) path '$.FamiliaArquivos',
      nested path '$.Arquivos' columns (
        arquivo varchar2(250) path '$.Arquivo',
        versao varchar2(250) path '$.Versão',
        tabela varchar2(250) path '$.Tabela',
        Nested Path '$.Grupos[*]' columns (
          grupo Varchar2(50) Path '$.Grupo',
          nested path '$.Campos[*]' columns (
            campo varchar2(50) path '$.Campo',
            descricao Varchar2(250) Path '$.Descrição',
            tipo Varchar2(10) Path '$.Tipo',
            tamanho varchar2(5) path '$.Tamanho',
            obrigatorio varchar2(3) path '$.Obrigatório',
            padrao varchar2(250) path '$.Padrão',
            dominio varchar2(250) format json path '$.Domínio',
            regrasvalidacao Varchar2(250) format json path '$.RegrasValidação',
            sigrh Varchar2(250) Format Json Path '$.SIGRH'
            )
          )
        )
      )
    );
  
    return v_ret;
  
end listar;

function CapaPagamento return JSON_OBJECT_T
is
  docJSON     JSON_OBJECT_T;
begin
  docJSON := JSON_OBJECT_T.parse('
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
			"RegrasValidação" : ["validarSiglaOrgao"]
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
			"RegrasValidação" : ["validarTipoFolha"]
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
			"RegrasValidação" : ["validarTipoCalculo"]
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
			"Domínio" : ["M - Masculino", "F - Feminino"],
			"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "FLSEXO"}],
			"RegrasValidação" : ["validarLista(F, M)"]
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
			"RegrasValidação" : ["validarPais"]
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
			"RegrasValidação" : ["validarEstadoCivil"]
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
			"RegrasValidação" : ["validarRaca"]
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
			"RegrasValidação" : ["validarRelacaoTrabalho"]
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
			"RegrasValidação" : ["validarRegimeTrabalho"]
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
			"RegrasValidação" : ["validarNaturezaVinculo"]
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
			"RegrasValidação" : ["validarSituacaoPrevidenciaria"]
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
			"RegrasValidação" : ["validarRegimeProprioPrevidenciario"]
		},
		{
			"Campo" : "FLPREVIDENCIACOMP",
			"Descrição" : "Indicador de previdência complementar. ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S - Sim", "N - Não"],
			"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "FLPREVIDENCIACOMP"}],
			"RegrasValidação" : ["validarLista(S, N)"]
		},
		{
			"Campo" : "FLATIVO",
			"Descrição" : "Indica se servidor é considerado ativo ou inativo",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "S",
			"Domínio" : ["S - Sim", "N - Não"],
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "FLATIVO"}],
			"RegrasValidação" : ["validarLista(S, N)"]
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
			"RegrasValidação" : ["validarCargaHoraria"]
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
			"RegrasValidação" : ["validarSiglaUO"]
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
			"Domínio" : ["TEMPORÁRIO", "DEFINITIVO"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLTIPOAFASTAMENTO"}],
			"RegrasValidação" : ["validarTipoAfastamento"]
		},
		{
			"Campo" : "FLREMUNERADO",
			"Descrição" : "Indica se o afastamento é remunerado ou não",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S-SIM", "N-NÃO"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLREMUNERADO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTTEMP", "Coluna" : "FLREMUNERADO"}, {"Conceito" : "EAFAHISTMOTIVOAFASTDEF", "Coluna" : "FLREMUNERADO"}],
			"RegrasValidação" : ["validarLista(S, N)"]
		},
		{
			"Campo" : "FLREMUNERACAOINTEGRAL",
			"Descrição" : "Indica se a remuneração é integral",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S-SIM", "N-NÃO"],
			"SIGRH" : [{"Conceito" : "EAFAHISTMOTIVAFASTTEMP", "Coluna" : "FLREMUNERACAOINTEGRAL"}],
			"RegrasValidação" : ["validarLista(S, N)"]
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
			"Domínio" : ["S-SIM", "N-NÃO"],
			"SIGRH" : [{"Conceito" : "EAFAAFASTAMENTOVINCULO", "Coluna" : "FLACIDENTETRABALHO"}],
			"RegrasValidação" : ["validarLista(S, N)"]
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
			"RegrasValidação" : ["validarBanco"]
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
			"RegrasValidação" : ["validarAgencia"]
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
			"RegrasValidação" : ["validarNumero"]
		},
		{
			"Campo" : "FLTIPOCONTACREDITO",
			"Descrição" : "Tipo de conta crédito",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "C",
			"Domínio" : ["C - Conta Corrente", "P - Conta Poupança"],
			"SIGRH" : [{"Conceito" : "EPAGCAPAHISTRUBRICAVINCULO", "Coluna" : "FLTIPOCONTACREDITO"}],
			"RegrasValidação" : ["validarTipoContaCredito"]
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
			"Domínio" : ["D - Definitiva", "T - Temporária"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGAHORARIA", "Coluna" : "FLTIPOOCUPACAO"}],
			"RegrasValidação" : ["validarTipoOcupacao"]
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
			"Domínio" : ["S - Sim", "N - Não"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLPRINCIPAL"}],
			"RegrasValidação" : ["validarLista(S, N)"]
		},
		{
			"Campo" : "FLTIPOPROVIMENTO",
			"Descrição" : "Tipo de provimento do cargo comissionado.",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["D - Designação", "N - Nomeação", "S - Substituido"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLTIPOPROVIMENTO"}],
			"RegrasValidação" : ["validarTipoProvimento"]
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
			"RegrasValidação" : ["validarOpcaoRemuneracao"]
		},
		{
			"Campo" : "FLPAGASUBSIDIO",
			"Descrição" : "Indicador de paga subsidio",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : ["S - Sim", "N - Não"],
			"SIGRH" : [{"Conceito" : "ECADHISTCARGOCOM", "Coluna" : "FLPAGASUBSIDIO"}],
			"RegrasValidação" : ["validarLista(S, N)"]
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
');
    return docJSON;
  
end CapaPagamento;

end PKGMIGLAYOUT;
