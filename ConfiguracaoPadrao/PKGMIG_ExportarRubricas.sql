--- Pacote de Exportação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ExportarRubricas AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarRubricas
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Evento => epagEventoPagAgrup
  --                    └── VigenciaEvento => epagHistEventoPagAgrup
  --                         └── GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
  --                         └── GrupoOrgaoEvento => epagEventoPagAgrupOrgao
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
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarRubricas;
/
