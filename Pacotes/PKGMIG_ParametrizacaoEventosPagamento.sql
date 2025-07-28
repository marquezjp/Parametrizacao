-- Corpo do Pacote de Importação das Parametrizações de Eventos de Pagamento
CREATE OR REPLACE PACKAGE PKGMIG_ParametrizacaoEventosPagamento AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarEventosPagamento
  --   Importar dados das Eventos de Pagamento a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Eventos => epagEventoPagAgrup
  --                    └── Vigencias => epagHistEventoPagAgrup
  --                        ├── GrupoOrgao => epagEventoPagAgrupOrgao
  --                        └── GrupoCarreira => epagHistEventoPagAgrupCarreira
  --
  -- PROCEDURE:
  --   pImportar
  --   pExcluirEventos
  --   pImportarVigencias
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
  ) RETURN tpParametrizacaoTabela PIPELINED;

  PROCEDURE pImportar(
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarEventos(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER,
    pEventoPagamento      IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  PROCEDURE pExcluirEventos(
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER,
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
    pcdEventoPagAgrup     IN NUMBER,
    pVigenciasEvento      IN CLOB, 
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  );

  FUNCTION fnCursorEventos(
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2
  ) RETURN SYS_REFCURSOR;
END PKGMIG_ParametrizacaoEventosPagamento;
/
