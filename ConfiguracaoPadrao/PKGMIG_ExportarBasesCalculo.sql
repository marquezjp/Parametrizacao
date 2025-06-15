--- Pacote de Exportação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ExportarBasesCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarBasesCalculo
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
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

  PROCEDURE PExportar(psgAgrupamento IN VARCHAR2);
  FUNCTION fnCursorBases(psgAgrupamento IN VARCHAR2) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarBasesCalculo;
/
