--- Pacote de Importação das Parametrizações das Consignações
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoConsignacoes AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ParametrizacaoConsignacoes
  --   Importar dados das Consignações a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Consignacoes => epagConsignacao
  --                    ├── Vigencias => epagHistConsignacao
  --                    │
  --                    ├── Consignataria => epagConsignataria
  --                    │    ├── Suspensao => epagConsignatariaSuspensao
  --                    │    └── TaxaServico => epagConsignatariaTaxaServico
  --                    │
  --                    ├── TipoServico => epagTipoServico
  --                    │    ├── Vigencias = > epagHistTipoServico
  --                    │    └── ParametroBase = > epagParametroBaseConsignacao
  --                    │
  --                    └── ContratoServico => epagContratoServico
  --
  -- PROCEDURE:
  --   pImportar
  --   pImportarVigencias
  --
  -- ###########################################################################
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  PROCEDURE pImportar(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER,
    pConsignacao          IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarVigencias(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdFormulaVersao      IN NUMBER,
    pVigenciasConsignacao IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );
END PKGMIG_ParametrizacaoConsignacoes;
/
