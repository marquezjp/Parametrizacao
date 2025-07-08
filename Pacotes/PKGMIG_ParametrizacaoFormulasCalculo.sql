--- Pacote de Importação das Parametrizações das Formulas de Calculo
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoFormulasCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoFormulasCalculo
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Formula => epagFormulaCalculo
  --                    └── Versoes => epagFormulaVersao
  --                         └── Vigencias => epagHistFormulaCalculo
  --                              └── Expressao => epagExpressaoFormCalc
  --                                   └── Blocos => epagFormulaCalculoBloco
  --                                        └── ExpressaoBloco => epagFormulaCalcBlocoExpressao
  --                                             └── GrupoRubricas = > epagFormCalcBlocoExpRubAgrup
  --
  -- PROCEDURE:
  --   pImportar
  --   pExcluirFormulaCalculo
  --   pImportarVersoes
  --   pImportarVigencias
  --   pImportarExpressao
  --   pImportarBlocos
  --   pImportarExpressaoBloco
  --
  -- ###########################################################################
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pImportar(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
	  psgModulo             IN CHAR, 
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
	  pcdRubricaAgrupamento IN NUMBER,
    pFormulaCalculo       IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pExcluirFormulaCalculo(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
	  psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
	  pcdRubricaAgrupamento IN NUMBER,
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
	  pcdFormulaCalculo     IN NUMBER,
    pVersoesFormula       IN CLOB,
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
	  pcdFormulaVersao      IN NUMBER,
    pVigenciasFormula     IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarExpressao(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
	  psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
	  pcdHistFormulaCalculo IN NUMBER,
    pExpressaoFormula     IN CLOB,
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
	  pcdExpressaoFormCalc  IN NUMBER,
    pBlocosFormula        IN CLOB,
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
	  pcdFormulaCalculoBloco IN NUMBER,
    pBlocoExpressao       IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );
END PKGMIG_ParametrizacaoFormulasCalculo;
/
