--- Pacote de Exportação e Importação das Parametrizações
CREATE OR REPLACE PACKAGE PKGMIG_Parametrizacao AS

--  TYPE tpLista IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;

  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  FUNCTION fnObterNivelAuditoria(pNivelAuditoria IN VARCHAR2) RETURN PLS_INTEGER;

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2,
    psgConceito IN VARCHAR2, pNivelAuditoria VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    psgConceito IN VARCHAR2, pNivelAuditoria VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pConsoleLog(pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  PROCEDURE pRegistrarLog(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2, pnuRegistros IN NUMBER,
    pnmEntidade IN VARCHAR2, pnmEvento IN VARCHAR2, pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  PROCEDURE pAtualizarSequence(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pListaTabelas IN CLOB, pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  PROCEDURE pGerarResumo(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pdtTermino IN TIMESTAMP, pnuTempoExcusao IN INTERVAL DAY TO SECOND,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  );

  FUNCTION fnResumo (psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL, pdtExportacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoResumoTabela PIPELINED;

  FUNCTION fnListar (psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN VARCHAR2  DEFAULT NULL
  ) RETURN tpParametrizacaoListarTabela PIPELINED;

  FUNCTION fnResumoLog(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoTabela PIPELINED;

  FUNCTION fnResumoLogEntidades(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL, pdtOperacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoEntidadesTabela PIPELINED;

  FUNCTION fnListarLog(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL, pdtOperacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogListarTabela PIPELINED;
    
  PROCEDURE pExcluirLog(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL, pdtOperacao IN VARCHAR2 DEFAULT NULL
  );
END PKGMIG_Parametrizacao;
/
