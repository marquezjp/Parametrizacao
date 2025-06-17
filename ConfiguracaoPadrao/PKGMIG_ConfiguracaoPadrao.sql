--- Pacote de Exportação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ConfiguracaoPadrao AS

  TYPE tpLista IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;

  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;
  FUNCTION fnObterNivelDebug(pDEBUG IN VARCHAR2) RETURN PLS_INTEGER;

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pConsoleLog(pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuDEBUG IN NUMBER DEFAULT NULL
  );

  PROCEDURE pRegistrarLog(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2, pnuRegistros IN NUMBER,
    pnmEntidade IN VARCHAR2, pnmEvento IN VARCHAR2, pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuDEBUG IN NUMBER DEFAULT NULL
  );

  PROCEDURE pAtualizarSequence(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pListaTabelas IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL
  );

  PROCEDURE pGerarResumo(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pdtTermino IN TIMESTAMP, pnuTempoExcusao IN INTERVAL DAY TO SECOND,
    pnuDEBUG IN NUMBER DEFAULT NULL
  );

  FUNCTION fnResumo (psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL, pdtExportacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpConfiguracaoResumoTabela PIPELINED;

  FUNCTION fnListar (psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN VARCHAR2
  ) RETURN tpConfiguracaoListarTabela PIPELINED;

  FUNCTION fnResumoLog(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpConfiguracaoLogResumoTabela PIPELINED;

  FUNCTION fnResumoLogEntidades(ptpOperacao IN VARCHAR2, pdtOperacao IN VARCHAR2
  ) RETURN tpConfiguracaoLogResumoEntidadesTabela PIPELINED;

  FUNCTION fnListarLog(ptpOperacao IN VARCHAR2, pdtOperacao IN VARCHAR2
  ) RETURN tpConfiguracaoLogListarTabela PIPELINED;
    
  PROCEDURE pExcluirLog(ptpOperacao  IN VARCHAR2, pdtOperacao IN VARCHAR2,
    psgAgrupamento IN VARCHAR2, psgModulo  IN CHAR, psgConceito IN VARCHAR2
  );
END PKGMIG_ConfiguracaoPadrao;
/
