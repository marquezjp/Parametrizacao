--- Pacote de Importação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ImportarValoresReferencia AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarValoresReferencia
  --   Importar dados dos Valors de Referencia a partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  -- 
  -- ValorReferencia => epagValorReferencia
  --  └── Versões => epagValorReferenciaVersao
  --      └── Vigencias => epagHistValorReferencia
  --
  -- PROCEDURE:
  --   pImportar
  --   pImportarVersoes
  --   pImportarVigencias
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

  PROCEDURE pExcluirVersoesVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdValorReferencia IN NUMBER,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVersoes(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdValorReferencia IN NUMBER, pVersoes IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
	  pcdIdentificacao IN VARCHAR2, pcdValorReferenciaVersao IN NUMBER, pVigencias IN CLOB,
    pnuDEBUG IN NUMBER DEFAULT NULL);
END PKGMIG_ImportarValoresReferencia;
/
