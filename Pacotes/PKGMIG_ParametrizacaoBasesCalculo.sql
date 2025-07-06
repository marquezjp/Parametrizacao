--- Pacote de Exportação e e Importação das Parametrizações das Bases Cálculo
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoBasesCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoBasesCalculo
  --   Exportar e Importar dados dos Base de Cáculo do Documento JSON
  --     BaseCalculo contido na tabela emigParametrizacao.
  -- 
  -- Bases => epagBaseCalculo
  --  └── Versões => epagBaseCalculoVersao
  --      └── Vigências => epagHistBaseCalculo
  --          └── Blocos => epagBaseCalculoBloco
  --               └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
  --                    └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup
  --
  -- PROCEDURE:
  --   pImportar
  --   PExportar
  --   pImportarVersoes
  --   pImportarVigencias
  --   pImportarBlocos
  --   pImportarExpressaoBloco
  --   fnCursorBases
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

  PROCEDURE pExcluirBaseCalculo(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdBaseCalculo        IN NUMBER,
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
    pcdBaseCalculo        IN NUMBER,
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
    pcdVersaoBaseCalculo  IN NUMBER,
    pVigencias            IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarBlocos(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdHistBaseCalculo    IN NUMBER,
    pBlocos               IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarExpressaoBloco(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdBaseCalculoBloco   IN NUMBER,
    pExpressaoBloco       IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  FUNCTION fnCursorBases(
    psgAgrupamento        IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pdtExportacao         IN TIMESTAMP,
    pnuVersao             IN CHAR,
    pflAnulado            IN CHAR
  ) RETURN SYS_REFCURSOR;
END PKGMIG_ParametrizacaoBasesCalculo;
/
