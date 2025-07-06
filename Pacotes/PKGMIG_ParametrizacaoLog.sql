--- Declaração dos Tipos de Objetos e Tabelas para o Pacote de Logs das Parametrizações
CREATE OR REPLACE TYPE tpParametroEntrada AS OBJECT (
-- Tipo Objeto: Parametrizações
  sgAgrupamento        VARCHAR2(15),
  sgAgrupamentoDestino VARCHAR2(15),
  sgOrgao              VARCHAR2(15),
  sgModulo             VARCHAR2(03),
  sgConceito           VARCHAR2(20),
  cdIdentificacao      VARCHAR2(20), 
  tpOperacao           VARCHAR2(15),
  dtOperacao           VARCHAR2(25),
  nuNivelAuditoria     NUMBER
);

CREATE OR REPLACE TYPE tpRetorno AS OBJECT (
  deStatus             VARCHAR2(20),
  cdStatus             NUMBER,
  txMensagem           VARCHAR2(100),
  jsErros              VARCHAR2(1000),
  jsDados              CLOB
);

DROP TYPE tpParametrizacaoLogResumoTabela;
CREATE OR REPLACE TYPE tpParametrizacaoLogResumo AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Parametrizações
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  nuEventos       NUMBER,
  nuRegistros     NUMBER
);
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoTabela AS TABLE OF tpParametrizacaoLogResumo;

DROP TYPE tpParametrizacaoLogResumoEntidadesTabela; 
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoEntidades AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Parametrizações por Entidades
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  nmEntidade      VARCHAR2(50),
  nuEventos       NUMBER,
  nuRegistros     NUMBER
);
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoEntidadesTabela AS TABLE OF tpParametrizacaoLogResumoEntidades;

DROP TYPE tpParametrizacaoLogListarTabela; 
CREATE OR REPLACE TYPE tpParametrizacaoLogListar AS OBJECT (
-- Tipo Objeto: Listar o Log da Operação de Exportação ou Importação das Parametrizações
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  nmEntidade      VARCHAR2(50),
  cdIdentificacao VARCHAR2(50),
  nmEvento        VARCHAR2(50),
  nuRegistros     NUMBER,
  deMensagem      VARCHAR2(4000),
  dtInclusao      TIMESTAMP(6)
 );
CREATE OR REPLACE TYPE tpParametrizacaoLogListarTabela AS TABLE OF tpParametrizacaoLogListar;
/

--- Pacote de Log das Parametrizações
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoLog AS

  -- Constantes de Código de Erros
  --- Validação de parâmetros
  ---- -20000 a -20049 Erros de validação de entrada (parâmetros, formatos)
  cERRO_PARAMETRO_NAO_INFORMADO CONSTANT PLS_INTEGER := -20000;
  cERRO_PARAMETRO_OBRIGATORIO   CONSTANT PLS_INTEGER := -20001;

  --- Regras de negócio
  ---- -20050 a -20099 Erros de negócio (ex: conceito não suportado, dados ausentes)
  cERRO_NAO_EXISTE              CONSTANT PLS_INTEGER := -20050;
  cERRO_EXISTENTE               CONSTANT PLS_INTEGER := -20051;
  cERRO_AGRUPAMENTO_INVALIDO    CONSTANT PLS_INTEGER := -20060;
  cERRO_ORGAO_INVALIDO          CONSTANT PLS_INTEGER := -20062;
  cERRO_MODULO_INVALIDO         CONSTANT PLS_INTEGER := -20063;
  cERRO_CONCEITO_INVALIDO       CONSTANT PLS_INTEGER := -20064;
  cERRO_TIPO_OPERACAO_INVALIDO  CONSTANT PLS_INTEGER := -20065;
  cERRO_DATA_OPERACAO_INVALIDA  CONSTANT PLS_INTEGER := -20066;

  --- Infraestrutura
  ---- -20100 a -20149 Erros de infraestrutura (DB, rede, JSON inválido)
  cERRO_PARAMETRO_INVALIDO      CONSTANT PLS_INTEGER := -20100;

  --- Genéricos
  ---- -20900 a -20999 Erros genéricos ou não classificados

  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  FUNCTION fnObterParametro(
    pjsParametros     IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametroEntrada;

  FUNCTION fnObterChave(
    pjsParametros     IN VARCHAR2 DEFAULT NULL,
    pnmChave          IN VARCHAR2 DEFAULT NULL,
    ptxPadrao         IN VARCHAR2 DEFAULT NULL,
    ptxFormato        IN VARCHAR2 DEFAULT 'YYYY-MM-DD'
  ) RETURN VARCHAR2;

  FUNCTION fnObterNivelAuditoria(
    pNivelAuditoria   IN VARCHAR2
  ) RETURN PLS_INTEGER;

  FUNCTION fnValidarAgrupamento(
    psgAgrupamento    IN VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION fnValidarOrgao(
    psgOrgao          IN VARCHAR2
  ) RETURN VARCHAR2;
/*
  PROCEDURE pConsoleLog(
    pdeMensagem       IN VARCHAR2,
    pnuNivelLog       IN NUMBER DEFAULT NULL,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  PROCEDURE pRegistrarLog(
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pcdIdentificacao  IN VARCHAR2,
    pnuRegistros      IN NUMBER,
    pnmEntidade       IN VARCHAR2,
    pnmEvento         IN VARCHAR2,
    pdeMensagem       IN VARCHAR2,
    pnuNivelLog       IN NUMBER DEFAULT NULL,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  PROCEDURE pGerarResumo(
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pdtTermino        IN TIMESTAMP,
    pnuTempoExcusao   IN INTERVAL DAY TO SECOND,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  FUNCTION fnResumo(
    psgAgrupamento    IN VARCHAR2 DEFAULT NULL,
    psgModulo         IN CHAR DEFAULT NULL,
    psgConceito       IN VARCHAR2 DEFAULT NULL,
    ptpOperacao       IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoTabela PIPELINED;

  FUNCTION fnResumoEntidades(
    psgAgrupamento    IN VARCHAR2,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoEntidadesTabela PIPELINED;

  FUNCTION fnListar(
    psgAgrupamento    IN VARCHAR2,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogListarTabela PIPELINED;
    
  PROCEDURE pExcluir(
    psgAgrupamento    IN VARCHAR2,
    psgModulo         IN CHAR, 
    psgConceito       IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN VARCHAR2
  );
*/  
END PKGMIG_ParametrizacaoLog;
/
