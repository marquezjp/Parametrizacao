--- Pacote de Importação das Parametrizações das Formulas de Calculo
CREATE OR REPLACE PACKAGE PKGMIG_ImportarFormulasCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarFormulasCalculo
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Formula => epagFormulaCalculo
  --                    └── VersoesFormula => epagFormulaVersao
  --                         └── VigenciasFormula => epagHistFormulaCalculo
  --                              └── ExpressaoFormula => epagExpressaoFormCalc
  --                                   └── BlocosFormula => epagFormulaCalculoBloco
  --                                        └── BlocoExpressao => epagFormulaCalcBlocoExpressao
  --                                             └── GrupoRubricas = > epagFormCalcBlocoExpRubAgrup
  --
  -- PROCEDURE:
  --   pImportarFormulaCalculo
  --   pExcluirFormulaCalculo
  --   pImportarVersoesFormula
  --   pImportarVigenciasFormula
  --   pImportarExpressaoFormula
  --   pImportarBlocosFormula
  --   pImportarBlocoExpressao
  --
  -- ###########################################################################
--  PROCEDURE emigpImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2);
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pImportarFormulaCalculo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdRubricaAgrupamento IN NUMBER, pFormulaCalculo IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirFormulaCalculo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdRubricaAgrupamento IN NUMBER, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVersoesFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaCalculo IN NUMBER, pVersoesFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigenciasFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaVersao IN NUMBER, pVigenciasFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarExpressaoFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdHistFormulaCalculo IN NUMBER, pExpressaoFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarBlocosFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdExpressaoFormCalc IN NUMBER, pBlocosFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarBlocoExpressao(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaCalculoBloco IN NUMBER, pBlocoExpressao IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);
END PKGMIG_ImportarFormulasCalculo;
/
