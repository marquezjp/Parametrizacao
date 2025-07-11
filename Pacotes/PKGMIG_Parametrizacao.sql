--- Declaração dos Tipos de Objetos e Tabelas para o Pacote de Exportação e Importação das Parametrizações
DROP TYPE tpmigParametrizacaoResumoTabela;
CREATE OR REPLACE TYPE tpmigParametrizacaoResumo AS OBJECT (
-- Tipo Objeto: Resumo das Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  nuConteudos     NUMBER
);
CREATE OR REPLACE TYPE tpmigParametrizacaoResumoTabela AS TABLE OF tpmigParametrizacaoResumo;

DROP TYPE tpmigParametrizacaoListarTabela;
CREATE OR REPLACE TYPE tpmigParametrizacaoListar AS OBJECT (
-- Tipo Objeto: Listar Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  cdIdentificacao VARCHAR2(20), 
  jsConteudo      CLOB
);
CREATE OR REPLACE TYPE tpmigParametrizacaoListarTabela AS TABLE OF tpmigParametrizacaoListar;
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
  ) RETURN tpmigParametrizacaoResumoTabela PIPELINED;

  FUNCTION fnListar (
    pjsParametros         IN VARCHAR2 DEFAULT NULL
  ) RETURN tpmigParametrizacaoListarTabela PIPELINED;
END PKGMIG_Parametrizacao;
/
