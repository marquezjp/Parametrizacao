--- Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoRubricasAgrupamento AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoRubricasAgrupamento
  --   Importar dados de rubricas a partir da Configuração Padrão JSON
  --   contida na tabela emigParametrizacao, realizando:
  --     - Inclusão ou atualização de registros na tabela epagRubrica
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
  --     - Registro de Logs de Auditoria por evento
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --      └── TipoRubrica => epagRubrica
  --          └── GruposRubrica => epagGrupoRubricaPagamento
  --          └── Vigencias => epagHistRubrica
  --          │
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               ├── Vigencias => epagHistRubricaAgrupamento
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
  --               ├── Eventos => epagEventoPagAgrup
  --               │    └── Vigencias => epagHistEventoPagAgrup
  --               │        ├── GrupoOrgao => epagEventoPagAgrupOrgao
  --               │        └── GrupoCarreira => epagHistEventoPagAgrupCarreira
  --               │
  --               └── Formula => epagFormulaCalculo
  --                    └── Versoes => epagFormulaVersao
  --                         └── Vigencias => epagHistFormulaCalculo
  --                              └── Expressao => epagExpressaoFormCalc
  --                                   └── Blocos => epagFormulaCalculoBloco
  --                                        └── ExpressaoBloco => epagFormulaCalcBlocoExpressao
  --                                             └── RubricasBloco= > epagFormCalcBlocoExpRubAgrup
  --
  -- PROCEDURE:
  --   pImportar
  --   pExcluirRubricaAgrupamento
  --   pImportarVigencias
  --   pImportarListasRubricaAgrupamento
  --   PKGMIG_ParametrizacaoEventosPagamento.pImportar
  --   PKGMIG_ParametrizacaoFormulasCalculo.pImportar
  --
  -- ###########################################################################
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pImportar(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubrica IN NUMBER, pAgrupamento IN CLOB, pnuNivelAuditoria IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirRubricaAgrupamento(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER, pnuNivelAuditoria IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER, pVigenciasAgrupamento IN CLOB, pnuNivelAuditoria IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarListasRubricaAgrupamento(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
    pcdHistRubricaAgrupamento IN NUMBER, pListasVigenciasAgrupamento IN CLOB, pnuNivelAuditoria IN NUMBER DEFAULT NULL);
END PKGMIG_ParametrizacaoRubricasAgrupamento;
/
