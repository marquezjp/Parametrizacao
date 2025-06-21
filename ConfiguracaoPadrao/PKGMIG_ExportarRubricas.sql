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
  --               │    │
  --               │    ├── GeracaoRubrica.Carreiras => epagHistRubricaAgrupCarreira
  --               │    ├── GeracaoRubrica.NiveisReferencias => epagHistRubricaAgrupNivelRef
  --               │    ├── GeracaoRubrica.CargosComissionados => epagHistRubricaAgrupCCO
  --               │    ├── GeracaoRubrica.FuncoesChefia => epagHistRubricaAgrupFUC
  --               │    ├── GeracaoRubrica.Programas => epagHistRubricaAgrupPrograma
  --               │    ├── GeracaoRubrica.ModelosAposentadoria => epagHistRubricaAgrupModeloApo
  --               │    ├── GeracaoRubrica.CargasHorarias => epagHistRubAgrupLocCHO
  --               │    │
  --               │    ├── PermissoesRubrica.Orgaos => epagHistRubricaAgrupOrgao
  --               │    ├── PermissoesRubrica.UnidadesOrganizacionais => epagHistRubricaAgrupUO
  --               │    ├── PermissoesRubrica.NaturezasVinculo => epagHistRubricaAgrupNatVinc
  --               │    ├── PermissoesRubrica.RelacoesTrabalho=> epagHistRubricaAgrupRelTrab
  --               │    ├── PermissoesRubrica.RegimesTrabalho => epagHistRubricaAgrupRegTrab
  --               │    ├── PermissoesRubrica.RegimesPrevidenciarios => epagHistRubricaAgrupRegPrev
  --               │    ├── PermissoesRubrica.SituacoesPrevidenciarias => epagHistRubricaAgrupSitPrev
  --               │    ├── PermissoesRubrica.MotivosAfastamentoImpedem => epagRubAgrupMotAfastTempImp
  --               │    ├── PermissoesRubrica.MotivosAfastamentoExigidos => epagRubAgrupMotAfastTempEx
  --               │    ├── PermissoesRubrica.MotivosMovimentacao => epagHistRubricaAgrupMotMovi
  --               │    ├── PermissoesRubrica.MotivosConvocacao => epagHistRubricaAgrupMotConv
  --               │    ├── PermissoesRubrica.RubricasImpedem => epagHistRubricaAgrupImpeditiva
  --               │    └── PermissoesRubrica.RubricasExigidas => epagHistRubricaAgrupExigida
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
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE PExportar(psgAgrupamento IN VARCHAR2, pnuNivelAuditoria IN NUMBER DEFAULT NULL);
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarRubricas;
/
