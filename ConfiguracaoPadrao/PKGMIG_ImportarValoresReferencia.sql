--- Pacote de Exportação e Importação das Parametrizações dos Valores de Referencia
CREATE OR REPLACE PACKAGE PKGMIG_ParemetrizacaoValoresReferencia AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParemetrizacaoValoresReferencia
  --   Exportar e Importar dados dos Valores de Referencia do Documento JSON
  --     ValoresReferencia contido na tabela emigConfiguracaoPadrao.
  -- 
  -- ValorReferencia => epagValorReferencia
  --  └── Versões => epagValorReferenciaVersao
  --      └── Vigências => epagHistValorReferencia
  --
  -- PROCEDURE:
  --   pImportar
  --   PExportar
  --   pImportarVersoes
  --   pImportarVigencias
  --   fnCursorValoresReferencia
  --
  -- ###########################################################################
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirVersoesVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdValorReferencia IN NUMBER,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVersoes(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdValorReferencia IN NUMBER, pVersoes IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
	  pcdIdentificacao IN VARCHAR2, pcdValorReferenciaVersao IN NUMBER, pVigencias IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  FUNCTION fnCursorValoresReferencia(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ParemetrizacaoValoresReferencia;
/
