--- Declaração dos Tipos de Objetos e Tabelas para o Pacote de Exportação e Importação das Parametrizações
DROP TYPE tpParametrizacaoResumoTabela;
CREATE OR REPLACE TYPE tpParametrizacaoResumo AS OBJECT (
-- Tipo Objeto: Resumo das Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  nuConteudos     NUMBER
);
CREATE OR REPLACE TYPE tpParametrizacaoResumoTabela AS TABLE OF tpParametrizacaoResumo;

DROP TYPE tpParametrizacaoListarTabela;
CREATE OR REPLACE TYPE tpParametrizacaoListar AS OBJECT (
-- Tipo Objeto: Listar Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  cdIdentificacao VARCHAR2(20), 
  jsConteudo      CLOB
);
CREATE OR REPLACE TYPE tpParametrizacaoListarTabela AS TABLE OF tpParametrizacaoListar;
/

--- Pacote de Exportação e Importação das Parametrizações
CREATE OR REPLACE PACKAGE PKGMIG_Parametrizacao AS

  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pExportar(
    pjsParametros         IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pImportar(
    pjsParametros         IN VARCHAR2 DEFAULT NULL
  );

  FUNCTION fnResumo (
    pjsParametros         IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoResumoTabela PIPELINED;

  FUNCTION fnListar (
    pjsParametros         IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoListarTabela PIPELINED;
END PKGMIG_Parametrizacao;
/
