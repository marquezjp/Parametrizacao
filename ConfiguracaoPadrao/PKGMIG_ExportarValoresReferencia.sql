--- Pacote de Exportação das Parametrizações de Valores de Referencia
CREATE OR REPLACE PACKAGE PKGMIG_ExportarValoresReferencia AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarValoresReferencia
  --   Exportar dados de Valores de Referencia para Configuração Padrão JSON
  -- 
  -- ValorReferencia => epagValorReferencia
  --  └── Versões => epagValorReferenciaVersao
  --          └── Vigencias => epagHistValorReferencia
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

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2, pnuDEBUG IN NUMBER DEFAULT NULL);
  FUNCTION fnCursorValoresReferencia(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarValoresReferencia;
/
