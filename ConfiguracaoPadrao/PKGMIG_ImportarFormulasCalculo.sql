--- Pacote de Importação das Parametrizações das Formulas de Calculo
CREATE OR REPLACE PACKAGE PKGMIG_ImportarFormulasCalculo AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ImportarFormulasCalculo
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Formula => epagFormulaCalculo
  --                    └── VersoesFormula => epagFormulaVersao
  --                         └── VigenciasFormula => epagHistFormulaCalculo
  --                              └── ExpressaoFormula => epagExpressaoFormCalc
  --                                   └── BlocosFormula => epagFormulaCalculoBloco
  --                                        └── BlocoExpressao => epagFormulaCalcBlocoExpressao
  --                                             └── GrupoRubricas = > epagFormCalcBlocoExpRubAgrup
  --
  -- PROCEDURE:
  --   pImportarFormulaCalculo
  --   pExcluirFormulaCalculo
  --   pImportarVersoesFormula
  --   pImportarVigenciasFormula
  --   pImportarExpressaoFormula
  --   pImportarBlocosFormula
  --   pImportarBlocoExpressao
  --
  -- ###########################################################################
--  PROCEDURE emigpImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2);
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE pImportarFormulaCalculo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdRubricaAgrupamento IN NUMBER, pFormulaCalculo IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pExcluirFormulaCalculo(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdRubricaAgrupamento IN NUMBER, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVersoesFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaCalculo IN NUMBER, pVersoesFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarVigenciasFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaVersao IN NUMBER, pVigenciasFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarExpressaoFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdHistFormulaCalculo IN NUMBER, pExpressaoFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarBlocosFormula(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdExpressaoFormCalc IN NUMBER, pBlocosFormula IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);

  PROCEDURE pImportarBlocoExpressao(psgAgrupamentoDestino IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
	psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2,
	pcdFormulaCalculoBloco IN NUMBER, pBlocoExpressao IN CLOB, pnuDEBUG IN NUMBER DEFAULT NULL);
END PKGMIG_ImportarFormulasCalculo;
/

-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ImportarFormulasCalculo AS

  PROCEDURE pImportarFormulaCalculo(
  -- ###########################################################################
  -- PROCEDURE: pImportarFormulaCalculo
  -- Objetivo:
  --   Importar dados das Formulas de Calculo do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Exclusão da Formula de Calculo e as Entidades Filhas
  --     - Inclusão da Formula de Calculo tabela epagFormulaCalculo
  --     - Importação das Vigências da Formula de Calculo
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2: 
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR: 
  --   psgConceito           IN VARCHAR2: 
  --   pcdIdentificacao      IN VARCHAR2: 
  --   pcdRubricaAgrupamento IN NUMBER: 
  --   pFormulaCalculo       IN CLOB: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'DEBUG NIVEL 0' omite todas as mensagens;
  --                         - Se informado 'DEBUG NIVEL 1' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DEBUG NIVEL 2' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER,
    pFormulaCalculo       IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vcdFormulaCalculoNova NUMBER := 0;
    vnuRegistros          NUMBER := 0;

    -- Cursor que extrai as Formula de Calculo do Documento Versões JSON
    CURSOR cDados IS
      WITH
      Orgao AS (
      SELECT g.sgGrupoAgrupamento, UPPER(p.nmPoder) AS nmPoder, a.sgAgrupamento, vgcorg.sgOrgao,
        vgcorg.dtInicioVigencia, vgcorg.dtFimVigencia,
        UPPER(tporgao.nmTipoOrgao) AS nmTipoOrgao,
        o.cdAgrupamento, o.cdOrgao, vgcorg.cdHistOrgao, vgcorg.cdTipoOrgao
      FROM ecadAgrupamento a
      INNER JOIN ecadPoder p ON p.cdPoder = a.cdPoder
      INNER JOIN ecadGrupoAgrupamento g ON g.cdGrupoAgrupamento = a.cdGrupoAgrupamento
      INNER JOIN ecadOrgao o ON o.cdAgrupamento = a.cdAgrupamento
      INNER JOIN (
        SELECT sgOrgao, dtInicioVigencia, dtFimVigencia, cdOrgao, cdHistOrgao, cdTipoOrgao FROM (
          SELECT sgOrgao, dtInicioVigencia, dtFimVigencia, cdOrgao, cdHistOrgao, cdTipoOrgao, 
          RANK() OVER (PARTITION BY cdOrgao ORDER BY dtInicioVigencia DESC, dtFimVigencia DESC NULLS FIRST) AS nuOrder
          FROM ecadHistOrgao WHERE flAnulado = 'N'
        ) WHERE nuOrder = 1
      ) vgcorg ON vgcorg.cdOrgao = o.cdOrgao
      LEFT JOIN ecadTipoOrgao tporgao ON tporgao.cdTipoOrgao = vgcorg.cdTipoOrgao
      UNION
      SELECT g.sgGrupoAgrupamento, UPPER(p.nmPoder) AS nmPoder, a.sgAgrupamento, NULL AS sgOrgao,
        NULL AS dtInicioVigencia,NULL AS dtFimVigencia, NULL AS nmTipoOrgao,
        a.cdAgrupamento, NULL AS cdOrgao, NULL AS cdHistOrgao, NULL AS cdTipoOrgao
      FROM ecadAgrupamento a
      INNER JOIN ecadPoder p ON p.cdPoder = a.cdPoder
      INNER JOIN ecadGrupoAgrupamento g ON g.cdGrupoAgrupamento = a.cdGrupoAgrupamento
      ORDER BY sgGrupoAgrupamento, nmPoder, sgAgrupamento, sgOrgao nulls FIRST, dtInicioVigencia DESC NULLS FIRST
      ),
      FormulaCalculo as (
      SELECT
      (SELECT NVL(MAX(cdFormulaCalculo),0) + 1 FROM epagFormulaCalculo) AS cdFormulaCalculo,
      pcdRubricaAgrupamento as cdRubricaAgrupamento,
      js.sgFormulaCalculo,
      js.deFormulaCalculo,
      SYSTIMESTAMP AS dtUltAlteracao,
      o.cdAgrupamento,
      o.cdOrgao,
      
      js.Versoes
      FROM JSON_TABLE(JSON_QUERY(pFormulaCalculo, '$'), '$[*]' COLUMNS (
          sgformulacalculo  PATH '$.sgformulacalculo',
          deformulacalculo  PATH '$.deformulacalculo',
          Versoes           CLOB FORMAT JSON PATH '$.Versoes'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      )
      SELECT * FROM FormulaCalculo;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Formula de Cálculo ' || vcdIdentificacao);
	
    -- Excluir a Formula de Cálculo e as Entidades Filhas
    pExcluirFormulaCalculo(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, vcdIdentificacao, pcdRubricaAgrupamento, pnuDEBUG);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || r.sgFormulaCalculo;
	  
	  -- Inserir na tabela epagFormulaCalculo
	  SELECT NVL(MAX(cdFormulaCalculo), 0) + 1 INTO vcdFormulaCalculoNova FROM epagFormulaCalculo;

      INSERT INTO epagFormulaCalculo (
	    cdFormulaCalculo, cdRubricaAgrupamento, sgFormulaCalculo, deFormulaCalculo, dtUltAlteracao, cdAgrupamento, cdOrgao
      ) VALUES (
		vcdFormulaCalculoNova, pcdRubricaAgrupamento, r.sgFormulaCalculo, r.deFormulaCalculo, r.dtUltAlteracao, r.cdAgrupamento, r.cdOrgao
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO', 'INCLUSAO', 'Formula de Calculo incluida com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      -- Importar Versão da Formula de Cálculo
      pImportarVersoesFormula(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaCalculoNova, r.Versoes, pnuDEBUG);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Calculo ' || vcdIdentificacao || ' FORMULA CALCULO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarFormulaCalculo;

  PROCEDURE pExcluirFormulaCalculo(
  -- ###########################################################################
  -- PROCEDURE: pExcluirFormulaCalculo
  -- Objetivo:
  --   Importar dados das Formulas de Calculo do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Exclusão dos Grupos de Rubricas dos Blocos da Formula de Calculo
  --       tabela epagFormCalcBlocoExpRubAgrup
  --     - Exclusão das Expressões dos Blocos da Base
  --       tabela epagBaseCalculoBlocoExpressao
  --     - Exclusão dos Blocos da Formula de Calculo tabela epagFormulaCalculoBloco
  --     - Exclusão das Expressão da Formula de Calculo tabela epagExpressaoFormCalc
  --     - Exclusão das Vigências da Formula de Calculo tabela epagHistFormulaCalculo
  --     - Exclusão das Versões da Formula de Calculo tabela epagFormulaVersao
  --     - Exclusão da Formula de Calculo tabela epagFormulaCalculo
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2: 
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR: 
  --   psgConceito           IN VARCHAR2: 
  --   pcdIdentificacao      IN VARCHAR2: 
  --   pcdRubricaAgrupamento IN NUMBER: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'DEBUG NIVEL 0' omite todas as mensagens;
  --                         - Se informado 'DEBUG NIVEL 1' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DEBUG NIVEL 2' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdRubricaAgrupamento IN NUMBER,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Excluir Formula de Cálculo ' || vcdIdentificacao);

    -- Excluir as Rubricas do Grupo de Rubricas da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagFormCalcBlocoExpRubAgrup GrupoRubricas
      WHERE GrupoRubricas.cdFormulaCalcBlocoExpressao IN (
        SELECT BlocoExpressao.cdFormulaCalcBlocoExpressao FROM epagFormulaCalcBlocoExpressao BlocoExpressao
        INNER JOIN epagFormulaCalculoBloco Blocos ON Blocos.cdFormulaCalculoBloco = BlocoExpressao.cdFormulaCalculoBloco
        INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
        INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
        INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
        INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagFormCalcBlocoExpRubAgrup GrupoRubricas
        WHERE GrupoRubricas.cdFormulaCalcBlocoExpressao IN (
          SELECT BlocoExpressao.cdFormulaCalcBlocoExpressao FROM epagFormulaCalcBlocoExpressao BlocoExpressao
          INNER JOIN epagFormulaCalculoBloco Blocos ON Blocos.cdFormulaCalculoBloco = BlocoExpressao.cdFormulaCalculoBloco
          INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
          INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
          INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
          INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO GRUPO RUBRICAS', 'EXCLUSAO', 'Grupo de Rubricas do Blocos da Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir a Expressão do Bloco da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagFormulaCalcBlocoExpressao BlocoExpressao
      WHERE BlocoExpressao.cdFormulaCalculoBloco IN (
        SELECT Blocos.cdFormulaCalculoBloco FROM epagFormulaCalculoBloco Blocos
        INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
        INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
        INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
        INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagFormulaCalcBlocoExpressao BlocoExpressao
        WHERE BlocoExpressao.cdFormulaCalculoBloco IN (
          SELECT Blocos.cdFormulaCalculoBloco FROM epagFormulaCalculoBloco Blocos
          INNER JOIN epagExpressaoFormCalc Expressao ON Expressao.cdExpressaoFormCalc = Blocos.cdExpressaoFormCalc
          INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
          INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
          INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO EXPRESSAO BLOCO', 'EXCLUSAO', 'Expressão do Bloco da Formula de Cálculo excluidos com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir as Blocos da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagFormulaCalculoBloco Blocos
      WHERE Blocos.cdExpressaoFormCalc IN (
        SELECT Expressao.cdExpressaoFormCalc FROM epagExpressaoFormCalc Expressao
        INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
        INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
        INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagFormulaCalculoBloco Blocos
        WHERE Blocos.cdExpressaoFormCalc IN (
          SELECT Expressao.cdExpressaoFormCalc FROM epagExpressaoFormCalc Expressao
          INNER JOIN epagHistFormulaCalculo Vigencias ON Vigencias.cdHistFormulaCalculo = Expressao.cdHistFormulaCalculo
          INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
          INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO BLOCOS', 'EXCLUSAO', 'Blocos da Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir a Expressão da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagExpressaoFormCalc Expressao
      WHERE Expressao.cdHistFormulaCalculo IN (
        SELECT Vigencias.cdHistFormulaCalculo FROM epagHistFormulaCalculo Vigencias
        INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
        INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagExpressaoFormCalc Expressao
        WHERE Expressao.cdHistFormulaCalculo IN (
          SELECT Vigencias.cdHistFormulaCalculo FROM epagHistFormulaCalculo Vigencias
          INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
          INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO EXPRESSAO FORMULA', 'EXCLUSAO', 'Expressão da Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir os Documentos das Vigências da Formula de Cálculo
    FOR d IN (
      SELECT Vigencias.cdHistFormulaCalculo, Vigencias.cdDocumento FROM epagHistFormulaCalculo Vigencias
      INNER JOIN epagFormulaVersao Versoes ON Versoes.cdFormulaVersao = Vigencias.cdFormulaVersao
      INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
        WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento AND Vigencias.cdDocumento IS NOT NULL
    ) LOOP
      UPDATE epagHistFormulaCalculo Vigencias SET Vigencias.cdDocumento = NULL
        WHERE Vigencias.cdHistFormulaCalculo = d.cdHistFormulaCalculo;

      DELETE FROM eatoDocumento
        WHERE cdDocumento = d.cdDocumento;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'DOCUMENTO', 'EXCLUSAO', 'Documentos de Amparo ao Fato da Formula de Cálculo excluídos com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
    END LOOP;      

    -- Excluir as Vigências da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagHistFormulaCalculo Vigencias
      WHERE Vigencias.cdFormulaVersao IN (
        SELECT Versoes.cdFormulaVersao FROM epagFormulaVersao Versoes 
        INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagHistFormulaCalculo Vigencias
        WHERE Vigencias.cdFormulaVersao IN (
          SELECT Versoes.cdFormulaVersao FROM epagFormulaVersao Versoes 
          INNER JOIN epagFormulaCalculo Formula ON Formula.cdFormulaCalculo = Versoes.cdFormulaCalculo
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO VIGENCIA', 'EXCLUSAO', 'Vigências da Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir as Versões da Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagFormulaVersao Versoes
      WHERE Versoes.cdFormulaCalculo IN (
        SELECT Formula.cdFormulaCalculo FROM epagFormulaCalculo Formula
          WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagFormulaVersao Versoes 
        WHERE Versoes.cdFormulaCalculo IN (
          SELECT Formula.cdFormulaCalculo FROM epagFormulaCalculo Formula
            WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO VERCAO', 'EXCLUSAO', 'Versões da Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

    -- Excluir a Formula de Cálculo
	SELECT COUNT(*) INTO vnuRegistros FROM epagFormulaCalculo Formula
      WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento;

	IF vnuRegistros > 0 THEN
      DELETE FROM epagFormulaCalculo Formula
        WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CALCULO', 'EXCLUSAO', 'Formula de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Calculo ' || vcdIdentificacao || ' EXCLUIR FORMULA CALCULO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pExcluirFormulaCalculo;

  PROCEDURE pImportarVersoesFormula(
  -- ###########################################################################
  -- PROCEDURE: pImportarVersoesFormula
  -- Objetivo:
  --   Importar dados das Versões da Formula de Calculo do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Versões da Formula de Calculo tabela epagFormulaVersao
  --     - Importação das Vigências da Formula de Calculo
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2: 
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR: 
  --   psgConceito           IN VARCHAR2: 
  --   pcdIdentificacao      IN VARCHAR2: 
  --   pcdFormulaCalculo     IN NUMBER: 
  --   pVersoesFormula       IN CLOB: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdFormulaCalculo     IN NUMBER,
    pVersoesFormula       IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao     VARCHAR2(70) := Null;
    vcdFormulaVersaoNova NUMBER := 0;
    vnuRegistros         NUMBER := 0;

    -- Cursor que extrai as Versões das Bases do Documento Versões JSON
    CURSOR cDados IS
      WITH
      Versoes as (
      SELECT
      (SELECT NVL(MAX(cdFormulaVersao),0) + 1 FROM epagFormulaVersao) AS cdFormulaVersao,
      js.nuFormulaVersao,
      pcdFormulaCalculo,
      SYSTIMESTAMP AS dtUltAlteracao,
      js.VigenciasFormula
      FROM JSON_TABLE(JSON_QUERY(pVersoesFormula, '$'), '$[*]' COLUMNS (
        nuFormulaVersao  PATH '$.nuformulaversao',
        VigenciasFormula CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Versões da Formula de Cálculo - Versões ' || vcdIdentificacao);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || r.nuFormulaVersao;
	  
	  -- Inserir na tabela epagBaseCalculoVersao
	  SELECT NVL(MAX(cdFormulaVersao), 0) + 1 INTO vcdFormulaVersaoNova FROM epagFormulaVersao;

      INSERT INTO epagFormulaVersao (
	    cdFormulaVersao, nuFormulaVersao, cdFormulaCalculo, dtUltAlteracao
      ) VALUES (
		vcdFormulaVersaoNova, r.nuFormulaVersao, pcdFormulaCalculo, r.dtUltAlteracao
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO VERCAO', 'INCLUSAO', 'Versão da Formula de Cálculo incluida com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      -- Importar Vigências da Formula de Cálculo
      pImportarVigenciasFormula(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaVersaoNova, r.VigenciasFormula, pnuDEBUG);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Versão da Formula de Cálculo ' || vcdIdentificacao || ' VERCAO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO VERCAO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVersoesFormula;

  PROCEDURE pImportarVigenciasFormula(
  -- ###########################################################################
  -- PROCEDURE: emigpImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências da Formula de Calculo do Documento Vigências JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Vigências da Base na tabela epagHistFormulaCalculo
  --     - Importar Blocos da Base
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pcdFormulaVersao      IN NUMBER:
  --   pVigenciasFormula     IN CLOB:
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdFormulaVersao      IN NUMBER,
    pVigenciasFormula     IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := Null;
    vcdHistFormulaCalculoNova  NUMBER := Null;
    vcdDocumentoNovo           NUMBER := Null;
    vnuRegistros               NUMBER := 0;

    -- Cursor que extrai as Vigências das Bases do Documento pVigencias JSON
    CURSOR cDados IS
      WITH
      VigenciasFormula as (
      SELECT
      (SELECT NVL(MAX(cdHistFormulaCalculo),0) + 1 FROM epagHistFormulaCalculo) AS cdHistFormulaCalculo,
      pcdFormulaVersao as cdFormulaVersao,
      
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicio,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicio,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFim,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFim,
      
      NULL as cdDocumento,
      --JSON_OBJECT(
        js.nuAnoDocumento,
        tpdoc.cdTipoDocumento,
        js.dtDocumento,
        js.deObservacao,
        js.nuNumeroAtoLegal,
        js.nmArquivoDocumento,
        js.deCaminhoArquivoDocumento,
      --) AS cdDocumento,
      meiopub.cdMeioPublicacao,
      tppub.cdTipoPublicacao,
      TO_DATE(js.dtPublicacao, 'yyyy-mm-dd') AS dtPublicacao,
      js.nuPublicacao,
      js.nuPagInicial,
      js.deOutroMeio,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      systimestamp AS dtUltAlteracao,
      
      js.ExpressaoFormula
      FROM JSON_TABLE(JSON_QUERY(pVigenciasFormula, '$'), '$[*]' COLUMNS (
        nuAnoMesInicioVigencia      PATH '$.nuanomesiniciovigencia',
        nuAnoMesFimVigencia         PATH '$.nuanomesfimvigencia',
      
        nuAnoDocumento              PATH '$.Documento.nuAnoDocumento',
        detipodocumento             PATH '$.Documento.detipodocumento',
        dtDocumento                 PATH '$.Documento.dtDocumento',
        nuNumeroAtoLegal            PATH '$.Documento.nuNumeroAtoLegal',
        deObservacao                PATH '$.Documento.deObservacao',
        nmMeioPublicacao            PATH '$.Documento.nmMeioPublicacao',
        nmTipoPublicacao            PATH '$.Documento.nmTipoPublicacao',
        dtPublicacao                PATH '$.Documento.dtPublicacao',
        nuPublicacao                PATH '$.Documento.nuPublicacao',
        nuPagInicial                PATH '$.Documento.nuPagInicial',
        deOutroMeio                 PATH '$.Documento.deOutroMeio',
        nmArquivoDocumento          PATH '$.Documento.nmArquivoDocumento',
        deCaminhoArquivoDocumento   PATH '$.Documento.deCaminhoArquivoDocumento',
      
        ExpressaoFormula            CLOB FORMAT JSON PATH '$.Expressao'
      )) js
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      )
      SELECT * FROM VigenciasFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Vigências ' || vcdIdentificacao);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := pcdIdentificacao || ' ' || lpad(r.nuAnoInicio,4,0) || lpad(r.nuMesInicio,2,0);
       
	  -- Incluir Novo Documento se as informações não forem nulas
	  IF  r.nuAnoDocumento IS NULL AND r.cdTipoDocumento IS NULL AND r.dtDocumento IS NULL AND
	      r.deObservacao IS NULL AND r.nuNumeroAtoLegal IS NULL AND
	      r.nmArquivoDocumento IS NULL AND r.deCaminhoArquivoDocumento IS NULL THEN

	    vcdDocumentoNovo := NULL;

	  ELSE
        SELECT NVL(MAX(cdDocumento), 0) + 1 INTO vcdDocumentoNovo FROM eatoDocumento;

        INSERT INTO eatoDocumento (
          cdDocumento, nuAnoDocumento, cdTipoDocumento, dtDocumento, deObservacao, nuNumeroAtoLegal,
          nmArquivoDocumento, deCaminhoArquivoDocumento
        ) VALUES (
          vcdDocumentoNovo, r.nuAnoDocumento, r.cdTipoDocumento, r.dtDocumento, r.deObservacao, r.nuNumeroAtoLegal,
          r.nmArquivoDocumento, r.deCaminhoArquivoDocumento
        );

        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'FORMULA CALCULO DOCUMENTO', 'INCLUSAO', 'Documentos de Amparo ao Fato da Formula de Cálculo incluidas com sucesso');
	  END IF;

      -- Incluir Nova Vigência da Formula de Calculo
      SELECT NVL(MAX(cdHistFormulaCalculo), 0) + 1 INTO vcdHistFormulaCalculoNova FROM epagHistFormulaCalculo;

      INSERT INTO epagHistFormulaCalculo (
	    cdHistFormulaCalculo, cdFormulaVersao,
	    nuAnoInicio, nuMesInicio, nuCPFCadastrador, dtUltAlteracao, dtInclusao, nuAnoFim, nuMesFim,
	    cdDocumento, cdTipoPublicacao, nuPublicacao, dtPublicacao, nuPagInicial, cdMeioPublicacao, deObservacao
      ) VALUES (
        vcdHistFormulaCalculoNova, pcdFormulaVersao,
		r.nuAnoInicio, r.nuMesInicio, r.nuCPFCadastrador, r.dtUltAlteracao, r.dtInclusao, r.nuAnoFim, r.nuMesFim,
	    r.cdDocumento, r.cdTipoPublicacao, r.nuPublicacao, r.dtPublicacao, r.nuPagInicial, r.cdMeioPublicacao, r.deObservacao
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO VIGENCIA', 'INCLUSAO', 'Vigência da Formula de Cálculo incluidas com sucesso');

      -- Importar Blocos da Base de Cálculo
      pImportarExpressaoFormula(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdHistFormulaCalculoNova, r.ExpressaoFormula, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Vigência da Formula de Cálculo ' || vcdIdentificacao || ' VIGENCIA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM);
    ROLLBACK;
    RAISE;
  END pImportarVigenciasFormula;
    
  PROCEDURE pImportarExpressaoFormula(
  -- ###########################################################################
  -- PROCEDURE: pImportarExpressaoFormula
  -- Objetivo:
  --   Importar dados da Expressão da Formula de Calculo do Documento Vigências JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Vigências da Base na tabela epagExpressaoFormCalc
  --     - Importar Blocos da Base
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pcdHistFormulaCalculo IN NUMBER:
  --   pExpressaoFormula     IN CLOB:
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdHistFormulaCalculo IN NUMBER,
    pExpressaoFormula     IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao         VARCHAR2(70) := Null;
    vcdExpressaoFormCalcNova NUMBER := Null;
    vcdDocumentoNovo         NUMBER := Null;
    vnuRegistros             NUMBER := 0;

    -- Cursor que extrai a Expressão da Formula de Calculo do Documento pExpressaoFormula JSON
    CURSOR cDados IS
      WITH
      ExpressaoFormula as (
      SELECT
      (SELECT NVL(MAX(cdExpressaoFormCalc),0) + 1 FROM epagExpressaoFormCalc) AS cdExpressaoFormCalc,
      pcdHistFormulaCalculo as cdHistFormulaCalculo,
      
      js.deFormulaExpressao,
      js.deExpressao,
      js.deIndiceExpressao,
      
      NVL(js.flExpGeral, 'N') AS flExpGeral,
      NVL(js.flValorHoraMinuto, 'N') AS flValorHoraMinuto,
      NVL(js.flDesprezaPropCHORubrica, 'N') AS flDesprezaPropCHORubrica,
      NVL(js.flExigeIndice, 'N') AS flExigeIndice,
      
      js.cdFormulaEspecifica,
      js.deFormulaEspecifica,
      js.nuFormulaEspecifica,
      
      js.cdEstruturaCarreira,
      js.cdUnidadeOrganizacional,
      js.cdCargoComissionado,
      
      js.cdValorRefLimInfParcial,
      js.nuQtdeLimInfParcial,
      js.cdValorRefLimSupParcial,
      js.nuQtdeLimiteSupParcial,
      
      js.cdValorRefLimInfFinal,
      js.nuQtdeLimiteInfFinal,
      js.cdValorRefLimSupFinal,
      js.nuQtdeLimiteSupFinal,
      
      js.vlIndiceLimInferiorMensal,
      js.vlIndiceLimSuperiorMensal,
      js.vlIndiceLimSuperiorSemestral,
      js.vlIndiceLimSuperiorAnual,
      
      systimestamp AS dtUltAlteracao,
      
      js.BlocosFormula
      FROM JSON_TABLE(JSON_QUERY(pExpressaoFormula, '$'), '$' COLUMNS (
        deFormulaExpressao           PATH '$.deformulaexpressao',
        deExpressao                  PATH '$.deexpressao',
        deIndiceExpressao            PATH '$.deindiceexpressao',
      
        flExpGeral                   PATH '$.flexpgeral',
        flDesprezaPropCHORubrica     PATH '$.fldesprezapropchorubrica',
        flExigeIndice                PATH '$.flexigeindice',
        flValorHoraMinuto            PATH '$.flvalorhoraminuto',
      
        cdEstruturaCarreira          PATH '$.cdestruturacarreira',
        cdUnidadeOrganizacional      PATH '$.cdunidadeorganizacional',
        cdCargoComissionado          PATH '$.cdcargocomissionado',
      
        cdFormulaEspecifica          PATH '$.FormulaEspecifica.cdformulaespecifica',
        deFormulaEspecifica          PATH '$.FormulaEspecifica.deformulaespecifica',
        nuFormulaEspecifica          PATH '$.FormulaEspecifica.nuformulaespecifica',
      
        cdValorRefLimInfParcial      PATH '$.Limites.cdvalorrefliminfparcial',
        nuQtdeLimInfParcial          PATH '$.Limites.nuqtdeliminfparcial',
        cdValorRefLimSupParcial      PATH '$.Limites.cdvalorreflimsupparcial',
        nuQtdeLimiteSupParcial       PATH '$.Limites.nuqtdelimitesupparcial',
      
        cdValorRefLimInfFinal        PATH '$.Limites.cdvalorrefliminffinal',
        nuQtdeLimiteInfFinal         PATH '$.Limites.nuqtdelimiteinffinal',
        cdValorRefLimSupFinal        PATH '$.Limites.cdvalorreflimsupfinal',
        nuQtdeLimiteSupFinal         PATH '$.Limites.nuqtdelimitesupfinal',
      
        vlIndiceLimInferiorMensal    PATH '$.Limites.vlindiceliminferiormensal',
        vlIndiceLimSuperiorMensal    PATH '$.Limites.vlindicelimsuperiormensal',
        vlIndiceLimSuperiorSemestral PATH '$.Limites.vlindicelimsuperiorsemestral',
        vlIndiceLimSuperiorAnual     PATH '$.Limites.vlindicelimsuperioranual',
      
        BlocosFormula                CLOB FORMAT JSON PATH '$.Blocos'
      )) js
      )
      SELECT * FROM ExpressaoFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Expressão da Formula de Calculo ' || vcdIdentificacao);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := pcdIdentificacao;
       
      -- Incluir Nova Expressão da Formula de Calculo
      SELECT NVL(MAX(cdExpressaoFormCalc), 0) + 1 INTO vcdExpressaoFormCalcNova FROM epagExpressaoFormCalc;

      INSERT INTO epagExpressaoFormCalc (
        cdExpressaoFormCalc, cdHistFormulaCalculo,
        cdEstruturaCarreira, cdUnidadeOrganizacional, cdCargoComissionado, flExpGeral, deFormulaExpressao, deExpressao, 
        cdValorRefLimInfParcial, nuQtdeLimInfParcial, cdValorRefLimSupParcial, nuQtdeLimiteSupParcial,
        cdValorRefLimInfFinal, nuQtdeLimiteInfFinal, cdValorRefLimSupFinal, nuQtdeLimiteSupFinal,
        vlIndiceLimInferiorMensal, vlIndiceLimSuperiorMensal, vlIndiceLimSuperiorSemestral, vlIndiceLimSuperiorAnual,
        deIndiceExpressao, dtUltAlteracao, flValorHoraMinuto, cdFormulaEspecifica, deFormulaEspecifica, nuFormulaEspecifica,
        flDesprezaPropCHORubrica, flExigeIndice	    
      ) VALUES (
        vcdExpressaoFormCalcNova, pcdHistFormulaCalculo,
		r.cdEstruturaCarreira, r.cdUnidadeOrganizacional, r.cdCargoComissionado, r.flExpGeral, r.deFormulaExpressao, r.deExpressao, 
        r.cdValorRefLimInfParcial, r.nuQtdeLimInfParcial, r.cdValorRefLimSupParcial, r.nuQtdeLimiteSupParcial,
        r.cdValorRefLimInfFinal, r.nuQtdeLimiteInfFinal, r.cdValorRefLimSupFinal, r.nuQtdeLimiteSupFinal,
        r.vlIndiceLimInferiorMensal, r.vlIndiceLimSuperiorMensal, r.vlIndiceLimSuperiorSemestral, r.vlIndiceLimSuperiorAnual,
        r.deIndiceExpressao, r.dtUltAlteracao, r.flValorHoraMinuto, r.cdFormulaEspecifica, r.deFormulaEspecifica, r.nuFormulaEspecifica,
        r.flDesprezaPropCHORubrica, r.flExigeIndice
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO EXPRESSAO FORMULA', 'INCLUSAO', 'Expressão da Formula de Calculo incluidas com sucesso');

      -- Importar Blocos da Base de Cálculo
      pImportarBlocosFormula(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdExpressaoFormCalcNova, r.BlocosFormula, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Expressão da Formula de Calculo ' || vcdIdentificacao || ' EXPRESSAO FORMULA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO EXPRESSAO FORMULA', 'ERRO', 'Erro: ' || SQLERRM);
    ROLLBACK;
    RAISE;
  END pImportarExpressaoFormula;
    
  PROCEDURE pImportarBlocosFormula(
  -- ###########################################################################
  -- PROCEDURE: pImportarBlocosFormula
  -- Objetivo:
  --   Importar dados dos Blocos da Formula de Calculo do Documento Vigências JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Vigências da Base na tabela epagFormulaCalculoBloco
  --     - Importar Blocos da Base
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pcdExpressaoFormCalc  IN NUMBER:
  --   pBlocosFormula        IN CLOB:
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdExpressaoFormCalc  IN NUMBER,
    pBlocosFormula        IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := Null;
    vcdFormulaCalculoBlocoNova NUMBER := Null;
    vnuRegistros               NUMBER := 0;

    -- Cursor que extrai os Blocos da Formula de Calculo do Documento pBlocosFormula Agrupamento JSON
    CURSOR cDados IS
      WITH
      BlocosFormula as (
      SELECT
      (SELECT NVL(MAX(cdFormulaCalculoBloco),0) + 1 FROM epagFormulaCalculoBloco) AS cdFormulaCalculoBloco,
      pcdExpressaoFormCalc as cdExpressaoFormCalc,
      sgBloco,
      NVL(js.flLimiteParcial, 'N') AS flLimiteParcial,
      systimestamp AS dtUltAlteracao,
      
      js.BlocoExpressao
      FROM JSON_TABLE(JSON_QUERY(pBlocosFormula, '$'), '$[*]' COLUMNS (
        sgBloco         PATH '$.sgbloco',
        flLimiteParcial PATH '$.fllimiteparcial',
      
        BlocoExpressao  CLOB FORMAT JSON PATH '$.expressao'
      )) js
      )
      SELECT * FROM BlocosFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Calculo - Blocos ' || vcdIdentificacao);

    -- Loop principal de processamento para Incluir os Blocos da Formula de Calculo
    FOR r IN cDados LOOP

      vcdIdentificacao := pcdIdentificacao || ' ' || r.sgBloco;

      SELECT NVL(MAX(cdFormulaCalculoBloco), 0) + 1 INTO vcdFormulaCalculoBlocoNova FROM epagFormulaCalculoBloco;

      INSERT INTO epagFormulaCalculoBloco (
	    cdFormulaCalculoBloco, cdExpressaoFormCalc,
        sgBloco, dtUltAlteracao, flLimiteParcial
      ) VALUES (
        vcdFormulaCalculoBlocoNova, pcdExpressaoFormCalc, r.sgBloco, r.dtUltAlteracao, r.flLimiteParcial
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO BLOCOS', 'INCLUSAO', 'Inclusão dos Blocos da Formula de Calculo incluidas com sucesso');

      -- Importar Expressão do Bloco da Formula de Calculo
      pImportarBlocoExpressao(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaCalculoBlocoNova, r.BlocoExpressao, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação dos Bloco da Formula de Calculo ' || vcdIdentificacao || ' BLOCOS Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO BLOCOS', 'ERRO', 'Erro: ' || SQLERRM);
    ROLLBACK;
    RAISE;
  END pImportarBlocosFormula;

  PROCEDURE pImportarBlocoExpressao(
  -- ###########################################################################
  -- PROCEDURE: pImportarBlocoExpressao
  -- Objetivo:
  --   Importar dados a Expressão do Bloco da Formula de Cálculo
  --     do Documento Vigências JSON contido na tabela emigConfiguracaoPadrao,
  --       realizando:
  --     - Inclusão da Expressão do Bloco da Formula de Cálculo
  --       na tabela epagFormulaCalcBlocoExpressao
  --     - Inclusão do Grupo de Rubricas do Bloco da Formula de Calculo
  --       na tabela epagFormCalcBlocoExpRubAgrup
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pcdFFormulaCalculoBloco IN NUMBER:
  --   pBlocoExpressao       IN CLOB:
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdFormulaCalculoBloco IN NUMBER,
    pBlocoExpressao       IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao                 VARCHAR2(70) := Null;
    vcdFormulaCalcBlocoExpressaoNova NUMBER := Null;
    vnuRegistros                     NUMBER := 0;

    -- Cursor que extrai o Expressão do Bloco da Formula de Cálculo
	-- do Documento pBlocoExpressao JSON
    CURSOR cDados IS
      WITH
      Orgao AS (
      SELECT g.sgGrupoAgrupamento, UPPER(p.nmPoder) AS nmPoder, a.sgAgrupamento, vgcorg.sgOrgao,
        vgcorg.dtInicioVigencia, vgcorg.dtFimVigencia,
        UPPER(tporgao.nmTipoOrgao) AS nmTipoOrgao,
        o.cdAgrupamento, o.cdOrgao, vgcorg.cdHistOrgao, vgcorg.cdTipoOrgao
      FROM ecadAgrupamento a
      INNER JOIN ecadPoder p ON p.cdPoder = a.cdPoder
      INNER JOIN ecadGrupoAgrupamento g ON g.cdGrupoAgrupamento = a.cdGrupoAgrupamento
      INNER JOIN ecadOrgao o ON o.cdAgrupamento = a.cdAgrupamento
      INNER JOIN (
        SELECT sgOrgao, dtInicioVigencia, dtFimVigencia, cdOrgao, cdHistOrgao, cdTipoOrgao FROM (
          SELECT sgOrgao, dtInicioVigencia, dtFimVigencia, cdOrgao, cdHistOrgao, cdTipoOrgao, 
          RANK() OVER (PARTITION BY cdOrgao ORDER BY dtInicioVigencia DESC, dtFimVigencia DESC NULLS FIRST) AS nuOrder
          FROM ecadHistOrgao WHERE flAnulado = 'N'
        ) WHERE nuOrder = 1
      ) vgcorg ON vgcorg.cdOrgao = o.cdOrgao
      LEFT JOIN ecadTipoOrgao tporgao ON tporgao.cdTipoOrgao = vgcorg.cdTipoOrgao
      UNION
      SELECT g.sgGrupoAgrupamento, UPPER(p.nmPoder) AS nmPoder, a.sgAgrupamento, NULL AS sgOrgao,
        NULL AS dtInicioVigencia,NULL AS dtFimVigencia, NULL AS nmTipoOrgao,
        a.cdAgrupamento, NULL AS cdOrgao, NULL AS cdHistOrgao, NULL AS cdTipoOrgao
      FROM ecadAgrupamento a
      INNER JOIN ecadPoder p ON p.cdPoder = a.cdPoder
      INNER JOIN ecadGrupoAgrupamento g ON g.cdGrupoAgrupamento = a.cdGrupoAgrupamento
      ORDER BY sgGrupoAgrupamento, nmPoder, sgAgrupamento, sgOrgao nulls FIRST, dtInicioVigencia DESC NULLS FIRST
      ),
      RUB AS (
      SELECT LPAD(tpr.nuTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0) AS nuRubrica,
      tpr.deTipoRubrica || ' ' || vg.deRubricaAgrupResumida as deRubrica,
      ra.cdAgrupamento, ra.cdRubricaAgrupamento
      FROM epagRubrica r
      INNER JOIN epagTipoRubrica tpr ON tpr.cdtiporubrica = r.cdtiporubrica
      INNER JOIN epagRubricaAgrupamento ra ON ra.cdrubrica = r.cdrubrica
      INNER JOIN (
        SELECT deRubricaAgrupResumida, nuAnoMesInicioVigencia, nuAnoMesFimVigencia, cdRubricaAgrupamento, cdHistRubricaAgrupamento
        FROM (SELECT deRubricaAgrupResumida,
          LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
          CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
          cdRubricaAgrupamento, cdHistRubricaAgrupamento,
          RANK() OVER (PARTITION BY cdRubricaAgrupamento
                       ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
                           CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
                           ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
                           END DESC nulls FIRST) AS nuOrder
          FROM epagHistRubricaAgrupamento
        ) WHERE nuOrder = 1
      ) vg ON vg.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
      ),
      EstruturaCarreira AS (
      SELECT e.cdAgrupamento, e.cdEstruturaCarreira,
        NVL2(nivel4.cdEstruturaCarreira, item4.deItemCarreira || '#', '') ||
        NVL2(nivel3.cdEstruturaCarreira, item3.deItemCarreira || '#', '') ||
        NVL2(nivel2.cdEstruturaCarreira, item2.deItemCarreira || '#', '') ||
        NVL2(nivel1.cdEstruturaCarreira, item1.deItemCarreira, item.deItemCarreira) ||
        CASE WHEN e.cdEstruturaCarreira IS NOT NULL THEN '#' || item.deItemCarreira ELSE '' END CarreiraCargo
      FROM ecadestruturacarreira e
      LEFT JOIN ecadItemCarreira item ON item.cdAgrupamento = e.cdagrupamento AND item.cdItemCarreira = e.cdItemCarreira
      LEFT JOIN ecadEstruturaCarreira nivel1 ON nivel1.cdAgrupamento = e.cdAgrupamento AND nivel1.cdEstruturaCarreira = e.cdEstruturaCarreiraPai
      LEFT JOIN ecadEstruturaCarreira nivel2 ON nivel2.cdAgrupamento = e.cdAgrupamento AND nivel2.cdEstruturaCarreira = nivel1.cdEstruturaCarreiraPai
      LEFT JOIN ecadEstruturaCarreira nivel3 ON nivel3.cdAgrupamento = e.cdAgrupamento AND nivel3.cdEstruturaCarreira = nivel2.cdEstruturaCarreiraPai
      LEFT JOIN ecadEstruturaCarreira nivel4 ON nivel4.cdAgrupamento = e.cdAgrupamento AND nivel4.cdEstruturaCarreira = nivel3.cdEstruturaCarreiraPai
      LEFT JOIN ecadItemCarreira item1 ON item1.cdAgrupamento = e.cdAgrupamento AND item1.cdItemCarreira = nivel1.cdItemCarreira
      LEFT JOIN ecadItemCarreira item2 ON item2.cdAgrupamento = e.cdAgrupamento AND item2.cdItemCarreira = nivel2.cdItemCarreira
      LEFT JOIN ecadItemCarreira item3 ON item3.cdAgrupamento = e.cdAgrupamento AND item3.cdItemCarreira = nivel3.cdItemCarreira
      LEFT JOIN ecadItemCarreira item4 ON item4.cdAgrupamento = e.cdAgrupamento AND item4.cdItemCarreira = nivel4.cdItemCarreira
      ),

      BlocoExpressao as (
      SELECT
      (SELECT NVL(MAX(cdFormulaCalcBlocoExpressao),0) + 1 FROM epagFormulaCalcBlocoExpressao) AS cdFormulaCalcBlocoExpressao,
      pcdFormulaCalculoBloco as cdFormulaCalculoBloco,

      mneu.cdTipoMneumonico, js.sgTipoMneumonico,
      js.deOperacao,
/*      
      DECODE(js.inTipoRubrica,
        'Valor Integral', 'I', 
        'Valor Pago', 'P', 
        'Valor Real', 'R', 
        js.inTipoRubrica) as inTipoRubrica,
      DECODE(js.inRelacaoRubrica,
        'Relação de Trabalho', 'R', 
        'Somatório', 'S', 
        js.inRelacaoRubrica) as inRelacaoRubrica,
      DECODE(js.inMes,
        'Valor Referente ao Mês Atual', 'AT', 
        'Valor Referente ao Mês Anterior', 'AN', 
        js.inMes) as inMes,
*/
      js.inTipoRubrica,
      js.inRelacaoRubrica,
      js.inMes,

      js.nuMeses,
      js.nuValor,
      NVL(js.flValorHoraMinuto, 'N') AS flValorHoraMinuto,
      
      rub.cdRubricaAgrupamento, js.nuRubrica,
      js.nuMesRubrica,
      js.nuAnoRubrica,
      
      vlref.cdValorReferencia, js.nmValorReferencia,
      baseexp.cdBaseCalculo, js.sgBaseCalculo,
      tabgeral.cdValorGeralCEFAgrup, js.sgTabelaValorGeralCEF,
      EstruturaCarreira.cdEstruturaCarreira as cdEstruturaCarreira, js.CarreiraCargo,
      NULL as cdFuncaoChefia,
      js.deNivel,
      js.deReferencia,
      js.deCodigoCCO,
      NULL as cdTipoAdicionalTempServ,
      
      systimestamp AS dtUltAlteracao,
      
      (SELECT JSON_ARRAYAGG(JSON_OBJECT(SUBSTR(js.nuRubrica,1,7) value rub.cdRubricaAgrupamento) RETURNING CLOB) AS GRP
      FROM JSON_TABLE(js.GrupoRubricas, '$[*]' COLUMNS (nuRubrica PATH '$')) js
      LEFT JOIN RUB rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,1,7) AND rub.cdAgrupamento = o.cdAgrupamento) AS GrupoRubricas
      
      FROM JSON_TABLE(JSON_QUERY(pBlocoExpressao, '$'), '$' COLUMNS (
        sgTipoMneumonico        PATH '$.sgtipomneumonico',
        deOperacao              PATH '$.deoperacao',
      
        inTipoRubrica           PATH '$.intiporubrica',
        inRelacaoRubrica        PATH '$.inrelacaorubrica',
        inMes                   PATH '$.inmes',
        nuMeses                 PATH '$.numeses',
        nuValor                 PATH '$.nuvalor',
        flValorHoraMinuto       PATH '$.flValorHoraMinuto',
      
        nuRubrica               PATH '$.nurubrica',
        nuMesRubrica            PATH '$.numesrubrica',
        nuAnoRubrica            PATH '$.nuanorubrica',
      
        nmValorReferencia       PATH '$.nmvalorreferencia',
        sgBaseCalculo           PATH '$.sgbasecalculo',
        sgTabelaValorGeralCEF   PATH '$.sgtabelavalorgeralcef',
        CarreiraCargo           PATH '$.carreiracargo',
      --  cdFuncaoChefia        PATH '$.cdFuncaoChefia',
        deNivel                 PATH '$.denivel',
        deReferencia            PATH '$.dereferencia',
        deCodigoCCO             PATH '$.decodigocco',
      --  cdTipoAdicionalTempServ PATH '$.cdtipoadicionaltempserv',
      
        GrupoRubricas  CLOB FORMAT JSON PATH '$.GrupoRubricas'
      )) js
      
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagTipoMneumonico mneu ON mneu.sgTipoMneumonico = js.sgTipoMneumonico
      LEFT JOIN RUB rub on rub.nuRubrica = js.nuRubrica
      LEFT JOIN epagValorReferencia vlref ON vlref.cdAgrupamento = o.cdAgrupamento AND vlref.nmValorReferencia = js.nmValorReferencia
      LEFT JOIN epagBaseCalculo baseexp ON baseexp.cdAgrupamento = o.cdAgrupamento AND baseexp.sgBaseCalculo = js.sgBaseCalculo
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = o.cdAgrupamento
                                               AND tabgeral.sgTabelaValorGeralCEF = js.sgTabelaValorGeralCEF
      LEFT JOIN EstruturaCarreira ON EstruturaCarreira.cdAgrupamento = o.cdAgrupamento
                                 AND EstruturaCarreira.CarreiraCargo = js.CarreiraCargo
      )
      SELECT * FROM BlocoExpressao;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - FORMULA CALCULO EXPRESSAO BLOCO pcdIdentificacao: ' || pcdIdentificacao);

    -- Loop principal de processamento para Incluir a Expressão do Bloco da Formula de Cálculo
    FOR r IN cDados LOOP

      vcdIdentificacao := pcdIdentificacao || ' ' || r.sgTipoMneumonico;

      SELECT NVL(MAX(cdFormulaCalcBlocoExpressao), 0) + 1 INTO vcdFormulaCalcBlocoExpressaoNova FROM epagFormulaCalcBlocoExpressao;

      INSERT INTO epagFormulaCalcBlocoExpressao (
        cdFormulaCalcBlocoExpressao, cdFormulaCalculoBloco,
	    cdTipoMneumonico, deOperacao, cdValorReferencia, cdBaseCalculo, inTipoRubrica, inRelacaoRubrica, inMes,
	    cdTipoAdicionalTempServ, cdValorGeralCEFAgrup, deNivel, deReferencia, deCodigoCCO, cdEstruturaCarreira, cdFuncaoChefia,
	    nuMeses, nuValor, cdRubricaAgrupamento, dtUltAlteracao, flValorHoraMinuto, nuMesRubrica, nuAnoRubrica
      ) VALUES (
        vcdFormulaCalcBlocoExpressaoNova, pcdFormulaCalculoBloco,
		r.cdTipoMneumonico, r.deOperacao, r.cdValorReferencia, r.cdBaseCalculo, r.inTipoRubrica, r.inRelacaoRubrica, r.inMes,
		r.cdTipoAdicionalTempServ, r.cdValorGeralCEFAgrup, r.deNivel, r.deReferencia, r.deCodigoCCO, r.cdEstruturaCarreira, r.cdFuncaoChefia, 
		r.nuMeses, r.nuValor, r.cdRubricaAgrupamento, r.dtUltAlteracao, r.flValorHoraMinuto, r.nuMesRubrica, r.nuAnoRubrica
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO EXPRESSAO BLOCO', 'INCLUSAO', 'Expressão do Bloco da Formula de Cálculo incluidas com sucesso');

      --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Grupo de Rubricas ' || vcdIdentificacao);

	  -- Incluir Incluir o Grupo de Rubricas do Bloco da Formula de Cálculo
      FOR i IN (
        SELECT js.cdRubricaAgrupamento
          FROM json_table(r.GrupoRubricas, '$[*]' COLUMNS (cdRubricaAgrupamento PATH '$')) js
      ) LOOP

--        PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Grupo de Rubricas - RUBRICA' ||
--          vcdIdentificacao || ' ' || i.cdRubricaAgrupamento);

        IF i.cdRubricaAgrupamento IS NULL THEN
          PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Formula de Cálculo - Grupo de Rubricas Inexistente' ||
            vcdIdentificacao || ' ' || i.cdRubricaAgrupamento);

          PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || i.cdRubricaAgrupamento, 1,
            'FORMULA CALCULO GRUPO RUBRICAS', 'NAO INCLUSAO', 'Grupo de Rubricas do Bloco da Formula de Cálculo NÃO incluidas',
            cDEBUG_DESLIGADO, pnuDEBUG);
		ELSE
		  INSERT INTO epagFormCalcBlocoExpRubAgrup VALUES (vcdFormulaCalcBlocoExpressaoNova, i.cdRubricaAgrupamento);

          PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || i.cdRubricaAgrupamento, 1,
            'FORMULA CALCULO GRUPO RUBRICAS', 'INCLUSAO', 'Grupo de Rubricas do Bloco da Formula de Cálculo incluidas com sucesso',
            cDEBUG_DESLIGADO, pnuDEBUG);
		END IF;
      
      END LOOP;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Expressão do Bloco da Formula de Cálculo ' || vcdIdentificacao || ' EXPRESSAO BLOCO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CALCULO EXPRESSAO BLOCO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarBlocoExpressao;

END PKGMIG_ImportarFormulasCalculo;
/
