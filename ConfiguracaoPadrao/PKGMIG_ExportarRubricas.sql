--- Pacote de Exportação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE PKGMIG_ExportarRubricas AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarRubricas
  --   Exportar dados das Rubricas, Eventos e Formulas de Calculo
  --     para Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --      └── TipoRubrica => epagRubrica
  --          └── TipoRubrica.GruposRubrica => epagGrupoRubricaPagamento
  --          └── TipoRubricaVigencia => epagHistRubrica
  --          │
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               ├── RubricaAgrupamentoVigencia => epagHistRubricaAgrupamento
  --               │    ├── RubricaAgrupamentoVigencia.Abrangencias.NaturezaVinculo => epagHistRubricaAgrupNatVinc
  --               │    ├── RubricaAgrupamentoVigencia.Abrangencias.RegimePrevidenciario => epagHistRubricaAgrupRegPrev
  --               │    ├── RubricaAgrupamentoVigencia.Abrangencias.RegimeTrabalho => epagHistRubricaAgrupRegTrab
  --               │    ├── RubricaAgrupamentoVigencia.Abrangencias.RelacaoTrabalho => epagHistRubricaAgrupRelTrab
  --               │    └── RubricaAgrupamentoVigencia.Abrangencias.SituacaoPrevidenciaria => epagHistRubricaAgrupSitPrev
  --               │
  --               ├── Evento => epagEventoPagAgrup
  --               │    └── VigenciaEvento => epagHistEventoPagAgrup
  --               │        ├── GrupoOrgaoEvento => epagEventoPagAgrupOrgao
  --               │        └── GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
  --               │
  --               └── Formula => epagFormulaCalculo
  --                    └── VersoesFormula => epagFormulaVersao
  --                         └── VigenciasFormula => epagHistFormulaCalculo
  --                              └── ExpressaoFormula => epagExpressaoFormCalc
  --                                   └── BlocosFormula => epagFormulaCalculoBloco
  --                                        └── BlocoExpressao => epagFormulaCalcBlocoExpressao
  --                                             └── BlocoExpressaoRubricas= > epagFormCalcBlocoExpRubAgrup
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
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarRubricas;
/
