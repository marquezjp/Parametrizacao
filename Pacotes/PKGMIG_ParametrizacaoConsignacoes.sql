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
  --   pImportarConsignacao
  --   pImportarVigenciasConsignacao
  --   pImportarContratoServico
  --   pImportarConsignatarias
  --   pImportarTipoServico
  --   pImportarVigenciasTipoServico
  --   pIncluirDocumentosAmparoFato
  --   pIncluirEndereco
  --
  -- ###########################################################################
  -- Constantes de nível de auditoria
  cAUDITORIA_SILENCIADO CONSTANT PLS_INTEGER := 0;
  cAUDITORIA_ESSENCIAL  CONSTANT PLS_INTEGER := 1;
  cAUDITORIA_DETALHADO  CONSTANT PLS_INTEGER := 2;
  cAUDITORIA_COMPLETO   CONSTANT PLS_INTEGER := 3;

  FUNCTION fnExportar(
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) RETURN tpemigParametrizacaoTabela PIPELINED;

  PROCEDURE pImportar(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarConsignacao(
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

  PROCEDURE pImportarVigenciasConsignacao(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdConsignacao        IN NUMBER,
    pVigenciasConsignacao IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarContratoServico(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pContratoServico      IN CLOB,
    pcdContratoServico    OUT NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarConsignatarias(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarTipoServicos(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pImportarVigenciasTipoServico(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdTipoServico        IN NUMBER,
    pVigenciasTipoServico IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pIncluirDocumentoAmparoFato(
    psgAgrupamento             IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    nmEntidade                 IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pDocumento                 IN CLOB,
    pcdDocumento               OUT NUMBER,
    pcdTipoPublicacao          OUT NUMBER,
    pdtPublicacao              OUT DATE,
    pnuPublicacao              OUT VARCHAR2,
    pnuPagInicial              OUT VARCHAR2,
    pcdMeioPublicacao          OUT NUMBER,
    pdeOutroMeio               OUT VARCHAR2,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  );

  PROCEDURE pIncluirEndereco(
    psgAgrupamento             IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    nmEntidade                 IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pEndereco                  IN CLOB,
    pcdEndereco                OUT NUMBER,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  );

  FUNCTION fnCursorConsignacao(
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2
  ) RETURN SYS_REFCURSOR;
END PKGMIG_ParametrizacaoConsignacoes;
/
