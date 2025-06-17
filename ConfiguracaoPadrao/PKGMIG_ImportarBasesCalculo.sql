--- Pacote de Exportação e e Importação das Parametrizações das Bases Cálculo
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoBasesCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoBasesCalculo
  --   Exportar e Importar dados dos Base de Cáculo do Documento JSON
  --     BaseCalculo contido na tabela emigConfiguracaoPadrao.
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
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirBaseCalculo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdBaseCalculo IN NUMBER,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVersoes(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdBaseCalculo IN NUMBER, pVersoes IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
	  pcdIdentificacao IN VARCHAR2, pcdVersaoBaseCalculo IN NUMBER, pVigencias IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarBlocos(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdHistBaseCalculo IN NUMBER, pBlocos IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarExpressaoBloco(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdBaseCalculoBloco IN NUMBER, pExpressaoBloco IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  FUNCTION fnCursorBases(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ParametrizacaoBasesCalculo;
/
