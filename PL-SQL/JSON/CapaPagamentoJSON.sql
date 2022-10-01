SELECT
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
 sigrh
FROM JSON_TABLE('
{
	"FamiliaArquivos" : "Informações de Pagamento",
	"Arquivos" : {
		"Arquivo" : "Capa de Pagamento",
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
			"Domínio" : "",
			"SIGRH" : ["ECADORGAO.SGORGAO"]
		},
		{
			"Campo" : "NUMATRICULALEGADO",
			"Descrição" : "Matrícula no sistema legado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "10",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADVINCULO.MATRICULA_LEGADO"]
		},
		{
			"Campo" : "NUCPF",
			"Descrição" : "CPF da pessoa.",
			"Tipo" : "Char",
			"Tamanho" : "11",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "PLANILHA_PESSOA",
			"SIGRH" : ["ECADPESSOA.NUCPF"]
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
			"Domínio" : "",
			"SIGRH" : ["EPAGFOLHAPAGAMENTO.NUANOREFERENCIA"]
		},
		{
			"Campo" : "NUMESREFERENCIA",
			"Descrição" : "Mês de referência da folha de pagamento.",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGFOLHAPAGAMENTO.NUMESREFERENCIA"]
		},
		{
			"Campo" : "NMTIPOFOLHA",
			"Descrição" : "Nome do tipo de folha de pagamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "40",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "NORMAL RESCISÃO 13º SALÁRIO FÉRIAS ADIANTAMENTO DE 13º SALÁRIO INSTITUIDORES DE PENSÃO APOSENTADORIA 13º SALÁRIO DE APOSENTADORIA ADIANTAMENTO DE 13º DE APOSENTADORIA OUTROS TIPOS DE FOLHA BOLSISTA RESIDENTE RESIDENTE - 13º SALÁRIO PESQUISADOR COMISSIONADO PURO FÚNEBRE FÚNEBRE - 13º SALÁRIO",
			"SIGRH" : ["EPAGTIPOFOLHA.NMTIPOFOLHA"]
		},
		{
			"Campo" : "NMTIPOCALCULO",
			"Descrição" : "Nome do tipo de cálculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "40",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "NORMAL SIMULAÇÃO RECÁLCULO DO MÊS CÁLCULO RETROATIVO SUPLEMENTAR RECÁLCULO COMPLEMENTAR",
			"SIGRH" : ["EPAGTIPOCALCULO.NMTIPOCALCULO"]
		},
		{
			"Campo" : "NUSEQUENCIALFOLHA",
			"Descrição" : " Número de sequencial da folha",
			"Tipo" : "NUMBER",
			"Tamanho" : "6",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGFOLHAPAGAMENTO.NUSEQUENCIALFOLHA"]
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
			"Domínio" : "DD/MM/AAAA",
			"SIGRH" : ["EPAGFOLHAPAGAMENTO.DTCALCULO"]
		},
		{
			"Campo" : "DTCREDITO",
			"Descrição" : "Data de crédito",
			"Tipo" : "DATE",
			"Tamanho" : "",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "DD/MM/AAAA",
			"SIGRH" : ["EPAGFOLHAPAGAMENTO.DTCREDITO"]
		},
		{
			"Campo" : "VLPROVENTOS",
			"Descrição" : "Valor dos proventos",
			"Tipo" : "NUMBER",
			"Tamanho" : "13,2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.VLPROVENTOS"]
		},
		{
			"Campo" : "VLDESCONTOS",
			"Descrição" : "Valor dos descontos",
			"Tipo" : "NUMBER",
			"Tamanho" : "13,2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.VLDESCONTOS"]
		},
		{
			"Campo" : "INSISTEMAORIGEM",
			"Descrição" : "Indicativo de contracheque do sistema legado",
			"Tipo" : "NUMBER",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.INSISTEMAORIGEM"]
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
			"Domínio" : "PLANILHA_PESSOA",
			"SIGRH" : ["ECADPESSOA.NMPESSOA"]
		},
		{
			"Campo" : "DTNASCIMENTO",
			"Descrição" : "Data de nascimento da pessoa.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["ECADPESSOA.DTNASCIMENTO"]
		},
		{
			"Campo" : "FLSEXO",
			"Descrição" : "Sexo.",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "M - Masculino F - Feminino",
			"SIGRH" : ["ECADPESSOA.FLSEXO"]
		},
		{
			"Campo" : "NMMAE",
			"Descrição" : "Nome da mãe.",
			"Tipo" : "Varchar2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADPESSOA.NMMAE"]
		},
		{
			"Campo" : "NMPAIS",
			"Descrição" : "Nome do país. Indica a nacionalidade da pessoa.",
			"Tipo" : "Varchar2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "ACORES;AFEGANISTAO;AFRICA DO SUL;ALASCA (EUA); ALBANIA;ALEMANHA;ANDORRA;ANGOLA;ANTARTICA;ANTIGUA;ANTILHAS HOLANDESAS;ARABIA SAUDITA;ARGELIA;ARGENTINA;ARMENIA;AUSTRALIA;AUSTRIA;AZERBAIJAO;BAHAMAS;BAHREIN (BAREINE);BANGLADESH;BARBADOS;BASHKORTOSTAN;BELARUS;BELGICA;BELIZE;BENIN;BERMUDAS;BOLIVIA;BOSNIA-HERZEGOVINA;BOTSWANA;BRASIL;BRUNEI;BULGARIA;BURKINA FASSO;BURUNDI;BUTAO;CABO VERDE (REPUBLICA DO);CAMAROES;CAMBOJA;CANADA;CATAR;CAZAQUISTAO;CHADE;CHILE;CHINA;CHIPRE (REPUBLICA DE);CHUVASH (REPUBLICA DE);CINGAPURA;COLOMBIA;COMOROS (REPUBLICA FEDERAL ISLAMICA DE);CONGO (ZAIRE);COREIA DO NORTE;COREIA DO SUL;COSTA DO MARFIM;COSTA RICA;CROACIA;CUBA;DINAMARCA;DJIBOUTI;DOMINICA;EGITO;EL SALVADOR;EMIRADOS ARABES UNIDOS;EQUADOR;ERITEIA (ERITREIA);ESCOCIA (GBR);ESLOVAQUIA;ESLOVENIA;ESPANHA;ESTADOS UNIDOS DA AMERICA;ESTONIA;ETIOPIA;FIJI (ILHAS);FILIPINAS;FINLANDIA;FORMOSA TAIWAN (CHINA);FRANCA;GABAO;GAMBIA;GANA;GEORGIA (REPUBLICA DE);GIBRALTAR (GBR);GRA-BRETANHA;GRANADA;GRECIA;GROENLANDIA (DINAMARCA);GUADALUPE (FRANCA);GUAM (EUA);GUATEMALA;GUERNSEY (GRB);GUIANA;GUIANA FRANCESA;GUINE;GUINE EQUATORIAL;GUINE-BISSAU;GUINE-CONACRI;HAITI;HONDURAS;HONG KONG;HUNGRIA;IEMEN (REPUBLICA DO);ILHA NORFOLK;ILHAS CAIMA;ILHAS CANARIAS;ILHAS COCOS (KEELING);ILHAS COOK;ILHAS MARSHALL;INDIA;INDONESIA;INGLATERRA;IRA;IRAQUE;IRLANDA;ISLANDIA;ISRAEL;ITALIA;IUGOSLAVIA;JAMAICA;JAPAO;JORDANIA;KUWAIT;LAOS;LESOTO;LETONIA (REPUBLICA DA);LIBANO;LIBERIA;LIBIA;LIECHTENSTEIN;LITUANIA;LUXEMBURGO;MACAU;MACEDONIA;MADAGASCAR;MALASIA;MALDIVAS (ILHAS);MALI;MALTA;MARROCOS;MARTINICA (FRANCA);MAURITANIA;MAURITIUS (MAURICIO);MAYOTTE (FRANCA);MEXICO;MICRONESIA;MOCAMBIQUE;MOLDAVIA (REPUBLICA DE);MONACO (PRINCIPADO DE);MONGOLIA;MONTSERRAT (GBR);NAMIBIA;NAURU;NEPAL;NEVIS;NICARAGUA;NIGER;NIGERIA;NORUEGA;NOVA CALEDONIA;NOVA ZELANDIA;OMA (MUSCAT);PAISES BAIXOS (HOLANDA);PALAU (REPUBLICA DE);PANAMA;PAPUA NOVA GUINE;PAQUISTAO;PARAGUAI;PERU;POLINESIA FRANCESA;POLONIA;PORTO RICO (EUA);PORTUGAL;QATAR (DOHA);QUENIA;REPUBLICA CENTRO AFRICANA;REPUBLICA DEMOCRATICA DE TIMOR-LESTE;REPUBLICA DOMINICANA;REPUBLICA TCHECA;ROMENIA;RUANDA;RUSSIA;SAARA OCIDENTAL;SAMOA AMERICANA (EUA.);SAMOA OCIDENTAL;SAN MARINO;SANTA HELENA (GBR);SANTA LUCIA;SANTA SE (CIDADE DO VATICANO);SAO KITTS (E NEVIS) INDEPENDENTE;SAO PEDRO E MIQUELON (FRANCA);SAO TOME E PRINCIPE;SAO VICENTE E GRANADINAS;SENEGAL;SERRA LEOA;SERVIA;SIRIA;SOMALIA;SRI LANKA (CEILAO);SUAZILANDIA;SUDAO;SUECIA;SUICA;SURINAME;TADJIQUISTAO (REPUBLICA);TAILANDIA;TAITI (POLINESIA FRANCESA);TANZANIA;TOGO;TOKELAU (ILHAS);TONGA;TRINIDAD E TOBAGO;TUNISIA;TURCOMENISTAO (TURCOMENIA);TURQUIA;TUVALU;UCRANIA;UGANDA;URUGUAI;UZBEQUISTAO;VANUATU;VENEZUELA;VIETNA;ZAIRE;ZAMBIA;ZANZIBAR E PEMBA (TANGANICA);ZIMBABUE (ZIMBABWE)",
			"SIGRH" : ["ECADPAIS.NMPAIS"]
		},
		{
			"Campo" : "NMESTADOCIVIL",
			"Descrição" : "Nome do estado civil.",
			"Tipo" : "Varchar2",
			"Tamanho" : "30",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "SOLTEIRO CASADO VIUVO SEPARADO JUDICIALMENTE DIVORCIADO MARITAL NAO INFORMADO UNIAO ESTAVEL",
			"SIGRH" : ["ECADPESSOA.CDESTADOCIVIL", "ECADESTADOCIVIL.NMESTADOCIVIL"]
		},
		{
			"Campo" : "NMRACA",
			"Descrição" : "Nome da raça.",
			"Tipo" : "Varchar2",
			"Tamanho" : "30",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "INDIGENA BRANCA NEGRA AMARELA PARDA NAO INFORMADO",
			"SIGRH" : ["ECADPESSOA.CDRACA", "ECADRACA.NMRACA"]
		},
		{
			"Campo" : "DTADMISSAO",
			"Descrição" : "Data de admissão.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["ECADVINCULO.DTADMISSAO"]
		},
		{
			"Campo" : "DTFIMPREVISTO",
			"Descrição" : "Data de fim previsto.",
			"Tipo" : "Data",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["ECADHISTCARGOEFETIVO.DTFIMPREVISTO"]
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
			"Domínio" : "",
			"SIGRH" : ["ECADRELACAOTRABALHO.NMRELACAOTRABALHO"]
		},
		{
			"Campo" : "NMREGIMETRABALHO",
			"Descrição" : "Descrição do regime de trabalho",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADREGIMETRABALHO.NMREGIMETRABALHO"]
		},
		{
			"Campo" : "NMNATUREZAVINCULO",
			"Descrição" : "Descrição da natureza de vínculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "CARGO PERMANENTE CARGO TEMPORÁRIO EMPREGO PERMANENTE EMPREGO TEMPORÁRIO FUNÇÃO PÚBLICA TEMPORÁRIA PENSIONISTA FUNÇÃO PÚBLICA ESPECIAL",
			"SIGRH" : ["ECADNATUREZAVINCULO.DENATUREZAVINCULO"]
		},
		{
			"Campo" : "NMREGIMEPREVIDENCIARIO",
			"Descrição" : "Regime previdenciário da relação de vinculo. ",
			"Tipo" : "Varchar2",
			"Tamanho" : "60",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "REGIME GERAL REGIME PRÓPRIO - IPREV SEM CONTRIBUIÇÃO REGIME PRÓPRIO (OUTROS ESTADOS, MUNICÍPIOS E FEDERAL) CONTRIBUIÇÃO DE PROTEÇÃO SOCIAL DOS MILITARES",
			"SIGRH" : ["ECADHISTCARGOEFETIVO.CDREGIMEPREVIDENCIARIO", "ECADREGIMEPREVIDENCIARIO.NMREGIMEPREVIDENCIARIO"]
		},
		{
			"Campo" : "NMSITUACAOPREVIDENCIARIA",
			"Descrição" : "Descrição da situação previdenciária do vínculo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "ATIVO INATIVO/APOSENTADO INSTITUIDOR DE PENSÃO PENSIONISTA NÃO PREVIDENCIÁRIA FALECIDO SEM PENSÃO SEM VÍNCULO PREVIDENCIÁRIO APOSENTADORIA ENCERRADA ATIVO COM DIREITO A APOSENTADORIA COMPULSÓRIA PENSIONISTA PREVIDENCIÁRIA BENEFICIÁRIO DE AUXÍLIO RECLUSÃO EX-PARLAMENTAR FALECIDO DECISÃO JUDICIAL MORTE PRESUMIDA AUXÍLIO RECLUSÃO",
			"SIGRH" : ["ECADSITUACAOPREVIDENCIARIA.DESITUACAOPREVIDENCIARIA"]
		},
		{
			"Campo" : "NMTIPOREGIMEPROPRIOPREV",
			"Descrição" : " Nome  de tipo de  Regime Próprio de Previdência Social",
			"Tipo" : "Varchar2",
			"Tamanho" : "80",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "FUNDO FINANCEIRO FUNDO PREVIDENCIÁRIO FUNDO FINANCEIRO LC 662/15",
			"SIGRH" : ["ECADVINCULO.CDTIPOREGIMEPROPRIOPREV", "ECADTIPOREGIMEPROPRIOPREV.NMTIPOREGIMEPROPRIOPREV"]
		},
		{
			"Campo" : "FLPREVIDENCIACOMP",
			"Descrição" : "Indicador de previdência complementar. ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "S - Sim N - Não",
			"SIGRH" : ["ECADVINCULO.FLPREVIDENCIACOMP"]
		},
		{
			"Campo" : "FLATIVO",
			"Descrição" : "Indica se servidor é considerado ativo ou inativo",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "S",
			"Domínio" : "S - Sim N - Não",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.FLATIVO"]
		},
		{
			"Campo" : "NMTIPOCARGAHORARIA",
			"Descrição" : "Nome do tipo de carga horária.",
			"Tipo" : "Varchar2",
			"Tamanho" : "30",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "DIÁRIA SEMANAL MENSAL QUINZENAL HORISTA",
			"SIGRH" : ["ECADHISTCARGAHORARIA.CDTIPOCARGAHORARIA", "ECADTIPOCARGAHORARIA.NMTIPOCARGAHORARIA"]
		},
		{
			"Campo" : "NUCARGAHORARIA",
			"Descrição" : "Carga horária padrão da carreira",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.NUCHO"]
		},
		{
			"Campo" : "NUCARGAHORARIARELACAO",
			"Descrição" : "Carga horária do servidor",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.NUCHORELACAO"]
		},
		{
			"Campo" : "SGUNIDADEORGANIZACIONAL",
			"Descrição" : "Sigla da Unidade Organizacional (lotação do servidor)",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "15",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADUNIDADEORGANIZACIONAL.SGUNIDADEORGANIZACIONAL"]
		},
		{
			"Campo" : "NMJORNADATRABALHO",
			"Descrição" : "Nome da jornada de trabalho.",
			"Tipo" : "Varchar2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADHISTJORNADATRABALHO.CDJORNADATRABALHO", "ECADJORNADATRABALHO.NMJORNADATRABALHO"]
		},
		{
			"Campo" : "DECENTROCUSTO",
			"Descrição" : "Nome do centro de custo",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADCENTROCUSTO.DECENTROCUSTO"]
		},
		{
			"Campo" : "NUDEPENDENTES",
			"Descrição" : "Número de Dependentes  para Desconto do IRRF",
			"Tipo" : "NUMBER",
			"Tamanho" : "2",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ""
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
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["EAFAFASTAMENTOVINCULO.DTINICIO"]
		},
		{
			"Campo" : "DTFIMAFASTAMENTO",
			"Descrição" : "Data fim do afastamento",
			"Tipo" : "DATE",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["EAFAFASTAMENTOVINCULO.DTFIM"]
		},
		{
			"Campo" : "DTFIMPREVISTOAFASTAMENTO",
			"Descrição" : "Data fim prevista do afastamento",
			"Tipo" : "DATE",
			"Tamanho" : "8",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "DD/MM/YYYY",
			"SIGRH" : ["EAFAFASTAMENTOVINCULO.DTFIMPREVISTA"]
		},
		{
			"Campo" : "FLTIPOAFASTAMENTO",
			"Descrição" : "Indicativo do tipo de afastamento",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "TEMPORÁRIO DEFINITIVO",
			"SIGRH" : ["EAFAAFASTAMENTOVINCULO.FLTIPOAFASTAMENTO"]
		},
		{
			"Campo" : "FLREMUNERADO",
			"Descrição" : "Indica se o afastamento é remunerado ou não",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "S-SIM N-NÃO",
			"SIGRH" : ["EAFAAFASTAMENTOVINCULO.FLREMUNERADO", "EAFAHISTMOTIVOAFASTTEMP.FLREMUNERADO", "EAFAHISTMOTIVOAFASTDEF.FLREMUNERADO"]
		},
		{
			"Campo" : "FLREMUNERACAOINTEGRAL",
			"Descrição" : "Indica se a remuneração é integral",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "S-SIM N-NÃO",
			"SIGRH" : ["EAFAHISTMOTIVAFASTTEMP.FLREMUNERACAOINTEGRAL"]
		},
		{
			"Campo" : "DEMOTIVOAFASTAMENTO",
			"Descrição" : "Descrição do motivo de afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EAFAHISTMOTIVAFASTTEMP.DEMOTIVOAFASTTEMPORARIO", "EAFAHISTMOTIVOAFASTDEF.DEMOTIVOAFASTDEFINITIVO"]
		},
		{
			"Campo" : "NMGRUPOMOTIVOAFASTAMENTO",
			"Descrição" : "Descrição do grupo de motivos de afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "90",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : " ",
			"SIGRH" : ["EAFAGRUPOMOTIVOAFASTAMENTO.NMGRUPOMOTIVOAFASTAMENTO", "EAFAHISTMOTIVOAFASTTEMP.CDGRUPOMOTIVOAFASTAMENTO", "EAFAHISTMOTIVOAFASTDEF.CDGRUPOMOTIVOAFASTAMENTO"]
		},
		{
			"Campo" : "FLACIDENTETRABALHO",
			"Descrição" : "Indica se o motivo de afastamento é relacionado a acidente de trabalho",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "S-SIM N-NÃO",
			"SIGRH" : ["EAFAAFASTAMENTOVINCULO.FLACIDENTETRABALHO"]
		},
		{
			"Campo" : "DEOBSERVACAO",
			"Descrição" : "Observações sobre o afastamento",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "400",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EAFAAFASTAMENTOVINCULO.DEOBSERVACAO"]
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
			"Domínio" : "",
			"SIGRH" : ["ECADBANCO.NUBANCO"]
		},
		{
			"Campo" : "NUAGENCIACREDITO",
			"Descrição" : "Número da agência para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "5",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADAGENCIA.NUAGENCIA"]
		},
		{
			"Campo" : "NUCONTACREDITO",
			"Descrição" : "Número da conta para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "12",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.NUCONTACREDITO"]
		},
		{
			"Campo" : "NUDVCONTACREDITO",
			"Descrição" : "Dígito da conta para crédito",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.NUDVCONTACREDITO"]
		},
		{
			"Campo" : "FLTIPOCONTACREDITO",
			"Descrição" : "Tipo de conta crédito",
			"Tipo" : "CHAR",
			"Tamanho" : "1",
			"Obrigatório" : "Não",
			"Padrão" : "C",
			"Domínio" : "C - Conta Corrente P - Conta Poupança",
			"SIGRH" : ["EPAGCAPAHISTRUBRICAVINCULO.FLTIPOCONTACREDITO"]
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
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "DEGRUPOOCUPACIONAL",
			"Descrição" : "Descrição do grupo ocupacional da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "DECARGO",
			"Descrição" : "Descrição da cargo da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "DECLASSE",
			"Descrição" : "Descrição da classe da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "DECOMPETENCIA",
			"Descrição" : "Descrição da competencia da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "DEESPECIALIDADE",
			"Descrição" : "Descrição da especialidade da estrutura.",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADITEMCARREIRA.DEITEMCARREIRA"]
		},
		{
			"Campo" : "NUNIVELCEF",
			"Descrição" : "Nivel de pagamento",
			"Tipo" : "Varchar2",
			"Tamanho" : "3",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADHISTCARGOEFETIVO.NUNIVELPAGAMENTO"]
		},
		{
			"Campo" : "NUREFERENCIACEF",
			"Descrição" : "Referencia de pagamento",
			"Tipo" : "Varchar2",
			"Tamanho" : "3",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADHISTCARGOEFETIVO.NUREFERENCIAPAGAMENTO"]
		},
		{
			"Campo" : "FLTIPOOCUPACAO",
			"Descrição" : "Tipo de ocupação da carga horária:  ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "D - Definitiva T - Temporária",
			"SIGRH" : ["ECADHISTCARGAHORARIA.FLTIPOOCUPACAO"]
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
			"Domínio" : "",
			"SIGRH" : ["ECADGRUPOOCUPACIONAL.NMGRUPOOCUPACIONAL"]
		},
		{
			"Campo" : "DECARGOCOMISSIONADO",
			"Descrição" : "Descrição do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "200",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADEVOLUCAOCARGOCOMISSIONADO.DECARGOCOMISSIONADO"]
		},
		{
			"Campo" : "NUNIVELCCO",
			"Descrição" : "Nível do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "10",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADHISTOPCAOREMUNERACAOCCO.NUNIVEL"]
		},
		{
			"Campo" : "NUREFERENCIACCO",
			"Descrição" : "Referência do cargo comissionado",
			"Tipo" : "VARCHAR2",
			"Tamanho" : "10",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["ECADHISTOPCAOREMUNERACAOCCO.NUREFERENCIA"]
		},
		{
			"Campo" : "FLPRINCIPAL",
			"Descrição" : "Indica se a relação de vínculo é a principal do vínculo. ",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "S - Sim N - Não",
			"SIGRH" : ["ECADHISTCARGOCOM.FLPRINCIPAL"]
		},
		{
			"Campo" : "FLTIPOPROVIMENTO",
			"Descrição" : "Tipo de provimento do cargo comissionado.",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "D - Designação N - Nomeação S - Substituido",
			"SIGRH" : ["ECADHISTCARGOCOM.FLTIPOPROVIMENTO"]
		},
		{
			"Campo" : "NMOPCAOREMUNERACAO",
			"Descrição" : "Nome da opção de remuneração.",
			"Tipo" : "Varchar2",
			"Tamanho" : "100",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "PELO CARGO EFETIVO COM PERCENTUAL SOBRE O COMISSIONADO PELO CARGO COMISSIONADO PELA REMUNERAÇÃO ORIGEM COMO MILITAR NA ORIGEM PELO F.G. OU F.T.G EXCLUSIVAMENTE PELO CARGO EFETIVO RECEBIMENTO PELO LEGISLATIVO",
			"SIGRH" : ["ECADHISTCARGOCOM.CDOPCAOREMUNERACAO", "ECADOPCAOREMUNERACAO.NMOPCAOREMUNERACAO"]
		},
		{
			"Campo" : "FLPAGASUBSIDIO",
			"Descrição" : "Indicador de paga subsidio",
			"Tipo" : "Char",
			"Tamanho" : "1",
			"Obrigatório" : "Sim",
			"Padrão" : "",
			"Domínio" : "S - Sim N - Não",
			"SIGRH" : ["ECADHISTCARGOCOM.FLPAGASUBSIDIO"]
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
			"Domínio" : "",
			"SIGRH" : ""
		},
		{
			"Campo" : "NUPERCENTCOTA",
			"Descrição" : "Percentual da cota do beneficiário da pensão previdenciária",
			"Tipo" : "NUMBER",
			"Tamanho" : "5,2",
			"Obrigatório" : "Não",
			"Padrão" : "",
			"Domínio" : "",
			"SIGRH" : ["EPVDHISTPENSAOPREVIDENCIARIA.NUPERCENTFIXOQUOTA"]
		}
	]
}

		]
	}
}

', '$' COLUMNS (
  familiaarquivos VARCHAR2(250) PATH '$.FamiliaArquivos',
  NESTED PATH '$.Arquivos' COLUMNS (
    arquivo VARCHAR2(250) PATH '$.Arquivo',
    versao VARCHAR2(250) PATH '$.Versão',
    tabela VARCHAR2(250) PATH '$.Tabela',
    NESTED PATH '$.Grupos[*]' COLUMNS (
      grupo VARCHAR2(32) PATH '$.Grupo',
      NESTED PATH '$.Campos[*]' COLUMNS (
        campo VARCHAR2(32) PATH '$.Campo',
        descricao VARCHAR2(250) PATH '$.Descrição',
        tipo VARCHAR2(10) PATH '$.Tipo',
        tamanho VARCHAR2(5) PATH '$.Tamanho',
        obrigatorio VARCHAR2(3) PATH '$.Obrigatório',
        padrao VARCHAR2(250) PATH '$.Padrão',
        dominio VARCHAR2(250) FORMAT JSON PATH '$.Domínio',
        sigrh VARCHAR2(250) FORMAT JSON PATH '$.SIGRH'
        )
      )
    )
  )
);
