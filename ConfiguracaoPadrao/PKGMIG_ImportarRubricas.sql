--- Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE PKGMIG_ImportarRubricas AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarRubricas
  --   Importar dados de rubricas a partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão ou atualização de registros na tabela epagRubrica
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
  --     - Registro de Logs de Auditoria por evento
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
  --   pImportar
  --   pImportarVigencias
  --   pImportarAgrupamento
  --   pImportarAgrupamentoVigencias
  --   PKGMIG_ImportarFormulasCalculo.pImportarFormulaCalculo
  --   PKGMIG_ImportarFormulasCalculo.pImportarEventos
  --   pImportarResumo
  --
  -- ###########################################################################
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubrica IN NUMBER, pVigenciasTipo IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarAgrupamento(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubrica IN NUMBER, pAgrupamento IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarAgrupamentoVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER, pVigenciasAgrupamento IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE PAtuializarSequence(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarResumo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pdtTermino IN TIMESTAMP, pnuTempoExcusao IN INTERVAL DAY TO SECOND, pnuDEBUG IN NUMBER DEFAULT NULL);
END PKGMIG_ImportarRubricas;
/
