--- Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoRubricas AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoRubricas
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
  --               ├── Consignacoes => epagConsignacao
  --               │    ├── Vigencias => epagHistConsignacao
  --               │    │
  --               │    ├── Consignataria => epagConsignataria
  --               │    │    ├── Suspensao => epagConsignatariaSuspensao
  --               │    │    └── TaxaServico => epagConsignatariaTaxaServico
  --               │    │
  --               │    ├── TipoServico => epagTipoServico
  --               │    │    ├── Vigencias = > epagHistTipoServico
  --               │    │    └── ParametroBase = > epagParametroBaseConsignacao
  --               │    │
  --               │    └── ContratoServico => epagContratoServico
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
  --                                             └── RubricasBloco = > epagFormCalcBlocoExpRubAgrup
  --
  -- PROCEDURE:
  --   pExportar
  --   pImportar
  --   pExcluirRubrica
  --   pImportarVigencias
  --   PKGMIG_ParametrizacaoRubricaAgrupamento.pImportar
  --   fnCursorBases
  --
  -- ###########################################################################
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pExportar(
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportar(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirRubrica(
    psgAgrupamentoDestino IN VARCHAR2, 
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2, 
    pcdIdentificacao      IN VARCHAR2,
    pcdRubrica            IN NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubrica            IN NUMBER,
    pVigenciasTipo        IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL);

  FUNCTION fnExportarRubricas(
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pcdIdentificacao  IN VARCHAR2,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
  ) RETURN tpemigParametrizacaoTabela PIPELINED;
END PKGMIG_ParametrizacaoRubricas;
/
