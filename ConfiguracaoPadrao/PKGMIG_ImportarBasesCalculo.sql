--- Pacote de Importação das Parametrizações das Bases
CREATE OR REPLACE PACKAGE PKGMIG_ImportarBasesCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarBasesCalculo
  --   Importar dados das Bases a partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão ou atualização de registros na tabela epagRubrica
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
  --     - Registro de Logs de Auditoria por evento
  -- 
  -- Bases => epagBaseCalculo
  --  └── Versões => epagBaseCalculoVersao
  --      └── Vigências => epagHistBaseCalculo
  --          └── Blocos => epagBaseCalculoBloco
  --               └── Expressão do Bloco => epagBaseCalculoBlocoExpressao
  --                    └── Grupo de Rubricas => epagBaseCalcBlocoExprRubAgrup
  --
  -- PROCEDURE:
  --   pImportar
  --   pImportarVersoes
  --   pImportarVigencias
  --   pImportarBlocos
  --   pImportarExpressaoBloco
  --
  -- ###########################################################################
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2);

  PROCEDURE pImportarVersoes(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdBaseCalculo IN NUMBER, pVersoes IN CLOB);

  PROCEDURE pImportarVigencias(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
	pcdIdentificacao IN VARCHAR2, pcdVersaoBaseCalculo IN NUMBER, pVigencias IN CLOB);

  PROCEDURE pImportarBlocos(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdHistBaseCalculo IN NUMBER, pBlocos IN CLOB);

  PROCEDURE pImportarExpressaoBloco(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP, psgModulo IN CHAR, psgConceito IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2, pcdBaseCalculoBloco IN NUMBER, pExpressaoBloco IN CLOB);
END PKGMIG_ImportarBasesCalculo;
/
