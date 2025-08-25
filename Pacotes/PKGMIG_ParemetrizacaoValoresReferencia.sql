--- Pacote de Exportação e Importação das Parametrizações dos Valores de Referencia
CREATE OR REPLACE PACKAGE PKGMIG_ParemetrizacaoValoresReferencia AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParemetrizacaoValoresReferencia
  --   Exportar e Importar dados dos Valores de Referencia do Documento JSON
  --     ValoresReferencia contido na tabela emigParametrizacao.
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
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pExportar(
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportar(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pExcluirVersoesVigencias(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdValorReferencia    IN NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarVersoes(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdValorReferencia    IN NUMBER,
    pVersoes              IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarVigencias(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
	  pcdIdentificacao      IN VARCHAR2,
    pcdValorReferenciaVersao IN NUMBER,
    pVigencias            IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  FUNCTION fnExportarValoresReferencia(
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pcdIdentificacao  IN VARCHAR2,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  ) RETURN tpemigParametrizacaoTabela PIPELINED;
END PKGMIG_ParemetrizacaoValoresReferencia;
/
