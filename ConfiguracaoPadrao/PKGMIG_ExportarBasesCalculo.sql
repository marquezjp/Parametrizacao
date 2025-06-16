--- Pacote de Exportação das Parametrizações de Bases de Calculo
CREATE OR REPLACE PACKAGE PKGMIG_ExportarBasesCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarBasesCalculo
  --   Exportar dados de Bases de Calculo para Configuração Padrão JSON
  -- 
  -- Bases => epagBaseCalculo
  --  └── Versões => epagBaseCalculoVersao
  --      └── Vigências => epagHistBaseCalculo
  --          └── Blocos => epagBaseCalculoBloco
  --               └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
  --                    └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup
  --
  -- PROCEDURE:
  --   PExportar
  --   fnCursorBases
  --
  -- ###########################################################################
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE PExportar(psgAgrupamento IN VARCHAR2, pnuDEBUG IN NUMBER DEFAULT NULL);
  FUNCTION fnCursorBases(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarBasesCalculo;
/
