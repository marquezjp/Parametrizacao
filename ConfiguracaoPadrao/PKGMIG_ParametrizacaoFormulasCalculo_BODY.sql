-- Corpo do Pacote de Importação das Parametrizações de Formulas de Cálculo
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoFormulasCalculo AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados das Formulas de Cálculo do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Exclusão da Formula de Cálculo e as Entidades Filhas
  --     - Inclusão da Formula de Cálculo tabela epagFormulaCalculo
  --     - Importação das Vigências da Formula de Cálculo
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
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'SILENCIADO' omite todas as mensagens;
  --                         - Se informado 'ESSENCIAL' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DETALHADO' inclui as mensagens de todas 
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
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vcdFormulaCalculoNova NUMBER := 0;
    vnuRegistros          NUMBER := 0;

    -- Cursor que extrai as Formula de Cálculo do Documento Versões JSON
    CURSOR cDados IS
      WITH
      --- Informações referente as lista de Órgãos, Rubricas, Carreiras, Cargos Comissionados, Motivos
      -- OrgaoLista: lista dos Agrupamentos e Órgãos
      OrgaoLista AS (
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
      
      JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes

      FROM JSON_TABLE(pFormulaCalculo, '$' COLUMNS (
          sgFormulaCalculo  PATH '$.sgFormulaCalculo',
          deFormulaCalculo  PATH '$.deFormulaCalculo',
          Versoes           CLOB FORMAT JSON PATH '$.Versoes'
      )) js
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      )
      SELECT * FROM FormulaCalculo;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
	
    -- Excluir a Formula de Cálculo e as Entidades Filhas
    pExcluirFormulaCalculo(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, vcdIdentificacao, pcdRubricaAgrupamento, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

	    vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgFormulaCalculo,1,70);

	    -- Inserir na tabela epagFormulaCalculo
	    SELECT NVL(MAX(cdFormulaCalculo), 0) + 1 INTO vcdFormulaCalculoNova FROM epagFormulaCalculo;

      INSERT INTO epagFormulaCalculo (
	      cdFormulaCalculo, cdRubricaAgrupamento, sgFormulaCalculo, deFormulaCalculo, dtUltAlteracao, cdAgrupamento, cdOrgao
      ) VALUES (
		    vcdFormulaCalculoNova, pcdRubricaAgrupamento, r.sgFormulaCalculo, r.deFormulaCalculo, r.dtUltAlteracao, r.cdAgrupamento, r.cdOrgao
      );

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO', 'INCLUSAO',
        'Formula de Cálculo incluída com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Versão da Formula de Cálculo
      pImportarVersoes(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaCalculoNova, r.Versoes, pnuNivelAuditoria);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' FORMULA CÁLCULO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pExcluirFormulaCalculo(
  -- ###########################################################################
  -- PROCEDURE: pExcluirFormulaCalculo
  -- Objetivo:
  --   Importar dados das Formulas de Cálculo do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Exclusão dos Grupos de Rubricas dos Blocos da Formula de Cálculo
  --       tabela epagFormCalcBlocoExpRubAgrup
  --     - Exclusão das Expressões dos Blocos da Base
  --       tabela epagBaseCalculoBlocoExpressao
  --     - Exclusão dos Blocos da Formula de Cálculo tabela epagFormulaCalculoBloco
  --     - Exclusão das Expressão da Formula de Cálculo tabela epagExpressaoFormCalc
  --     - Exclusão das Vigências da Formula de Cálculo tabela epagHistFormulaCalculo
  --     - Exclusão das Versões da Formula de Cálculo tabela epagFormulaVersao
  --     - Exclusão da Formula de Cálculo tabela epagFormulaCalculo
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
  --   pnuNivelAuditoria              IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'SILENCIADO' omite todas as mensagens;
  --                         - Se informado 'ESSENCIAL' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DETALHADO' inclui as mensagens de todas 
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
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      'Excluir Formula de Cálculo ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO GRUPO RUBRICAS', 'EXCLUSAO',
        'Grupo de Rubricas do Blocos da Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO EXPRESSAO BLOCO', 'EXCLUSAO',
        'Expressão do Bloco da Formula de Cálculo excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO BLOCOS', 'EXCLUSAO',
        'Blocos da Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO EXPRESSAO FORMULA', 'EXCLUSAO',
        'Expressão da Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'DOCUMENTO', 'EXCLUSAO',
        'Documentos de Amparo ao Fato da Formula de Cálculo excluídos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO VIGENCIA', 'EXCLUSAO',
        'Vigências da Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO VERCAO', 'EXCLUSAO',
        'Versões da Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
	  END IF;

    -- Excluir a Formula de Cálculo
	  SELECT COUNT(*) INTO vnuRegistros FROM epagFormulaCalculo Formula
      WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento;

	  IF vnuRegistros > 0 THEN
      DELETE FROM epagFormulaCalculo Formula
        WHERE Formula.cdRubricaAgrupamento = pcdRubricaAgrupamento;

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'FORMULA CÁLCULO', 'EXCLUSAO',
        'Formula de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
	  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' EXCLUIR FORMULA CÁLCULO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pExcluirFormulaCalculo;

  PROCEDURE pImportarVersoes(
  -- ###########################################################################
  -- PROCEDURE: pImportarVersoes
  -- Objetivo:
  --   Importar dados das Versões da Formula de Cálculo do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão das Versões da Formula de Cálculo tabela epagFormulaVersao
  --     - Importação das Vigências da Formula de Cálculo
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
  --   pnuNivelAuditoria              IN NUMBER DEFAULT NULL:
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
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
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

      JSON_SERIALIZE(TO_CLOB(js.VigenciasFormula) RETURNING CLOB) AS VigenciasFormula

      FROM JSON_TABLE(pVersoesFormula, '$[*]' COLUMNS (
        nuFormulaVersao  PATH '$.nuFormulaVersao',
        VigenciasFormula CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' ||
      '- Versões ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

	    vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuFormulaVersao,1,70);
	  
	    -- Inserir na tabela epagBaseCalculoVersao
	    SELECT NVL(MAX(cdFormulaVersao), 0) + 1 INTO vcdFormulaVersaoNova FROM epagFormulaVersao;

      INSERT INTO epagFormulaVersao (
	      cdFormulaVersao, nuFormulaVersao, cdFormulaCalculo, dtUltAlteracao
      ) VALUES (
		    vcdFormulaVersaoNova, r.nuFormulaVersao, pcdFormulaCalculo, r.dtUltAlteracao
      );

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO VERCAO', 'INCLUSAO',
        'Versão da Formula de Cálculo incluída com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Vigências da Formula de Cálculo
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaVersaoNova, r.VigenciasFormula, pnuNivelAuditoria);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' VERCAO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO VERCAO', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVersoes;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências da Formula de Cálculo do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
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
	pnuNivelAuditoria       IN NUMBER DEFAULT NULL
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
      
      JSON_SERIALIZE(TO_CLOB(js.ExpressaoFormula) RETURNING CLOB) AS ExpressaoFormula

      FROM JSON_TABLE(pVigenciasFormula, '$[*]' COLUMNS (
        nuAnoMesInicioVigencia      PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia         PATH '$.nuAnoMesFimVigencia',
      
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

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
         lpad(r.nuAnoInicio,4,0) || lpad(r.nuMesInicio,2,0),1,70);
       
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

        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'FORMULA CÁLCULO DOCUMENTO', 'INCLUSAO',
          'Documentos de Amparo ao Fato da Formula de Cálculo incluídas com sucesso',
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
	  END IF;

      -- Incluir Nova Vigência da Formula de Cálculo
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO VIGENCIA', 'INCLUSAO',
        'Vigência da Formula de Cálculo incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Expressão da Formula de Cálculo
      pImportarExpressao(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdHistFormulaCalculoNova, r.ExpressaoFormula, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' VIGENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;
    
  PROCEDURE pImportarExpressao(
  -- ###########################################################################
  -- PROCEDURE: pImportarExpressao
  -- Objetivo:
  --   Importar dados da Expressão da Formula de Cálculo do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
  --   pnuNivelAuditoria              IN NUMBER DEFAULT NULL:
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
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao         VARCHAR2(70) := Null;
    vcdExpressaoFormCalcNova NUMBER := Null;
    vcdDocumentoNovo         NUMBER := Null;
    vnuRegistros             NUMBER := 0;

    -- Cursor que extrai a Expressão da Formula de Cálculo do Documento pExpressaoFormula JSON
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
      
      JSON_SERIALIZE(TO_CLOB(js.BlocosFormula) RETURNING CLOB) AS BlocosFormula

      FROM JSON_TABLE(pExpressaoFormula, '$' COLUMNS (
        deFormulaExpressao           PATH '$.deFormulaExpressao',
        deExpressao                  PATH '$.deExpressao',
        deIndiceExpressao            PATH '$.deiIndiceExpressao',
      
        flExpGeral                   PATH '$.flExpGeral',
        flDesprezaPropCHORubrica     PATH '$.flDesprezaPropCHORubrica',
        flExigeIndice                PATH '$.flExigeIndice',
        flValorHoraMinuto            PATH '$.flValorHoraMinuto',
      
        cdEstruturaCarreira          PATH '$.cdEstruturaCarreira',
        cdUnidadeOrganizacional      PATH '$.cdUnidadeOrganizacional',
        cdCargoComissionado          PATH '$.cdCargoComissionado',
      
        cdFormulaEspecifica          PATH '$.FormulaEspecifica.cdFormulaEspecifica',
        deFormulaEspecifica          PATH '$.FormulaEspecifica.deFormulaEspecifica',
        nuFormulaEspecifica          PATH '$.FormulaEspecifica.nuFormulaEspecifica',
      
        cdValorRefLimInfParcial      PATH '$.Limites.cdValorRefLimInfParcial',
        nuQtdeLimInfParcial          PATH '$.Limites.nuQtdeLimInfParcial',
        cdValorRefLimSupParcial      PATH '$.Limites.cdValorRefLimSupParcial',
        nuQtdeLimiteSupParcial       PATH '$.Limites.nuQtdeLimiteSupParcial',
      
        cdValorRefLimInfFinal        PATH '$.Limites.cdValorRefLimInfFinal',
        nuQtdeLimiteInfFinal         PATH '$.Limites.nuQtdeLimiteInfFinal',
        cdValorRefLimSupFinal        PATH '$.Limites.cdValorRefLimSupFinal',
        nuQtdeLimiteSupFinal         PATH '$.Limites.nuQtdeLimiteSupFinal',
      
        vlIndiceLimInferiorMensal    PATH '$.Limites.vlIndiceLimInferiorMensal',
        vlIndiceLimSuperiorMensal    PATH '$.Limites.vlIndiceLimSuperiorMensal',
        vlIndiceLimSuperiorSemestral PATH '$.Limites.vlIndiceLimSuperiorSemestral',
        vlIndiceLimSuperiorAnual     PATH '$.Limites.vlIndiceLimSuperiorAnual',
      
        BlocosFormula                CLOB FORMAT JSON PATH '$.Blocos'
      )) js
      )
      SELECT * FROM ExpressaoFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      'Expressão da Formula de Cálculo ' || vcdIdentificacao,
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := pcdIdentificacao;
       
      -- Incluir Nova Expressão da Formula de Cálculo
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO EXPRESSAO FORMULA', 'INCLUSAO',
        'Expressão da Formula de Cálculo incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Blocos da Formula de Cálculo
      pImportarBlocos(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdExpressaoFormCalcNova, r.BlocosFormula, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' EXPRESSAO FORMULA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO EXPRESSAO FORMULA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarExpressao;
    
  PROCEDURE pImportarBlocos(
  -- ###########################################################################
  -- PROCEDURE: pImportarBlocos
  -- Objetivo:
  --   Importar dados dos Blocos da Formula de Cálculo do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
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
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := Null;
    vcdFormulaCalculoBlocoNova NUMBER := Null;
    vnuRegistros               NUMBER := 0;

    -- Cursor que extrai os Blocos da Formula de Cálculo do Documento pBlocosFormula Agrupamento JSON
    CURSOR cDados IS
      WITH
      BlocosFormula as (
      SELECT
      (SELECT NVL(MAX(cdFormulaCalculoBloco),0) + 1 FROM epagFormulaCalculoBloco) AS cdFormulaCalculoBloco,
      pcdExpressaoFormCalc as cdExpressaoFormCalc,
      sgBloco,
      NVL(js.flLimiteParcial, 'N') AS flLimiteParcial,
      systimestamp AS dtUltAlteracao,
      
      JSON_SERIALIZE(TO_CLOB(js.BlocoExpressao) RETURNING CLOB) AS BlocoExpressao

      FROM JSON_TABLE(pBlocosFormula, '$[*]' COLUMNS (
        sgBloco         PATH '$.sgBloco',
        flLimiteParcial PATH '$.flLimiteParcial',
      
        BlocoExpressao  CLOB FORMAT JSON PATH '$.Expressao'
      )) js
      )
      SELECT * FROM BlocosFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      'Blocos ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir os Blocos da Formula de Cálculo
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgBloco,1,70);

      SELECT NVL(MAX(cdFormulaCalculoBloco), 0) + 1 INTO vcdFormulaCalculoBlocoNova FROM epagFormulaCalculoBloco;

      INSERT INTO epagFormulaCalculoBloco (
	      cdFormulaCalculoBloco, cdExpressaoFormCalc,
        sgBloco, dtUltAlteracao, flLimiteParcial
      ) VALUES (
        vcdFormulaCalculoBlocoNova, pcdExpressaoFormCalc, r.sgBloco, r.dtUltAlteracao, r.flLimiteParcial
      );

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO BLOCOS', 'INCLUSAO',
        'Inclusão dos Blocos da Formula de Cálculo incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Expressão do Bloco da Formula de Cálculo
      pImportarExpressaoBloco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaCalculoBlocoNova, r.BlocoExpressao, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' BLOCOS Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO BLOCOS', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarBlocos;

  PROCEDURE pImportarExpressaoBloco(
  -- ###########################################################################
  -- PROCEDURE: pImportarExpressaoBloco
  -- Objetivo:
  --   Importar dados a Expressão do Bloco da Formula de Cálculo
  --     do Documento Vigências JSON contido na tabela emigParametrizacao,
  --       realizando:
  --     - Inclusão da Expressão do Bloco da Formula de Cálculo
  --       na tabela epagFormulaCalcBlocoExpressao
  --     - Inclusão do Grupo de Rubricas do Bloco da Formula de Cálculo
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
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
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
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao                 VARCHAR2(70) := Null;
    vcdFormulaCalcBlocoExpressaoNova NUMBER := Null;
    vnuRegistros                     NUMBER := 0;

    -- Cursor que extrai o Expressão do Bloco da Formula de Cálculo
	-- do Documento pBlocoExpressao JSON
    CURSOR cDados IS
      WITH
      --- Informações referente as lista de Órgãos, Rubricas, Carreiras, Cargos Comissionados, Motivos
      -- OrgaoLista: lista dos Agrupamentos e Órgãos
      OrgaoLista AS (
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
      -- RubricaLista: lista Rubricas
      RubricaLista AS (
      SELECT rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento, rub.cdRubrica,
        LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
        CASE WHEN tprub.nuTipoRubrica IN (1, 5, 9) THEN NULL ELSE tprub.deTipoRubrica || ' ' END ||
          NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.deRubrica,
            NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.deRubrica,NULL)) as deRubrica,
        NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesInicioVigencia,
          NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesInicioVigencia,NULL)) as nuAnoMesInicioVigencia,
        NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesFimVigencia,
          NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesFimVigencia,NULL)) as nuAnoMesFimVigencia
      FROM epagRubrica rub
      INNER JOIN epagTipoRubrica tprub ON tprub.cdtiporubrica = rub.cdtiporubrica
      INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdrubrica = rub.cdrubrica
      LEFT JOIN (SELECT cdRubricaAgrupamento, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
        SELECT cdRubricaAgrupamento, deRubricaAgrupamento as deRubrica,
          LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
          CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
          RANK() OVER (PARTITION BY cdRubricaAgrupamento
            ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
              CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
              ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
              END DESC nulls FIRST) AS nuOrder
        FROM epagHistRubricaAgrupamento) WHERE nuOrder = 1
      ) UltVigenciaAgrupamento ON UltVigenciaAgrupamento.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
      LEFT JOIN (SELECT nuRubrica, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
        SELECT rub.cdRubrica, vigenciarub.deRubrica,
          LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) as nuRubrica,
          NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0), '190101') AS nuAnoMesInicioVigencia,
          CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
          RANK() OVER (PARTITION BY rub.cdRubrica
            ORDER BY NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0),'190101') DESC,
              CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
              ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0)
              END DESC nulls FIRST) AS nuOrder
        FROM epagRubrica rub
        INNER JOIN epagTipoRubrica tprub on tprub.cdTipoRubrica = rub.cdTipoRubrica
        LEFT JOIN epagHistRubrica vigenciarub on vigenciarub.cdRubrica = rub.cdRubrica
        WHERE tprub.nuTipoRubrica IN (1, 5, 9)) WHERE nuOrder = 1
      ) UltVigenciaRub ON UltVigenciaRub.nuRubrica =
          CASE WHEN tprub.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
               WHEN tprub.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
               WHEN tprub.nuTipoRubrica = 9 THEN '09'
          END || '-' || LPAD(rub.nuRubrica,4,0)
      ),
      -- EstruturaCarreiraLista: lista da Estrutura de Carreira e Cargos
      EstruturaCarreiraLista AS (
      SELECT e.cdAgrupamento, e.cdEstruturaCarreira,
        NVL2(nivel4.cdEstruturaCarreira, item4.deItemCarreira || ' / ', '') ||
        NVL2(nivel3.cdEstruturaCarreira, item3.deItemCarreira || ' / ', '') ||
        NVL2(nivel2.cdEstruturaCarreira, item2.deItemCarreira || ' / ', '') ||
        NVL2(nivel1.cdEstruturaCarreira, item1.deItemCarreira, item.deItemCarreira) ||
        CASE WHEN e.cdEstruturaCarreira IS NOT NULL THEN ' / ' || item.deItemCarreira ELSE '' END nmEstruturaCarreira
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

      DECODE(js.inTipoRubrica,
        'VALOR INTEGRAL', 'I', 
        'VALOR PAGO', 'P', 
        'VALOR REAL', 'R', 
        NULL) as inTipoRubrica,
      DECODE(js.inRelacaoRubrica,
        'RELACAO DE TRABALHO', 'R', 
        'SOMATORIO', 'S', 
        NULL) as inRelacaoRubrica,
      DECODE(js.inMes,
        'VALOR REFERENTE AO MES ATUAL', 'AT', 
        'VALOR REFERENTE AO MES ANTERIOR', 'AN', 
        NULL) as inMes,

      js.nuMeses,
      js.nuValor,
      NVL(js.flValorHoraMinuto, 'N') AS flValorHoraMinuto,
      
      rub.cdRubricaAgrupamento, js.nuRubrica,
      js.nuMesRubrica,
      js.nuAnoRubrica,
      
      vlref.cdValorReferencia, js.nmValorReferencia,
      baseexp.cdBaseCalculo, js.sgBaseCalculo,
      tabgeral.cdValorGeralCEFAgrup, js.sgTabelaValorGeralCEF,
      cef.cdEstruturaCarreira as cdEstruturaCarreira, js.nmEstruturaCarreira,
      NULL as cdFuncaoChefia, js.nmFuncaoChefia,
      js.deNivel,
      js.deReferencia,
      js.deCodigoCCO,
      NULL as cdTipoAdicionalTempServ, js.deTipoAdicionalTempServ,
      
      SYSTIMESTAMP AS dtUltAlteracao,
      
      (SELECT JSON_ARRAYAGG(JSON_OBJECT(
         'nuRubrica' VALUE SUBSTR(js.nuRubrica,1,7),
         'cdRubricaAgrupamento' VALUE rub.cdRubricaAgrupamento
       RETURNING CLOB) RETURNING CLOB) AS GRP
       FROM JSON_TABLE(js.GrupoRubricas, '$[*]' COLUMNS (nuRubrica PATH '$')) js
       LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,1,7)
                                 AND rub.cdAgrupamento = o.cdAgrupamento
      ) As GrupoRubricas

      FROM JSON_TABLE(pBlocoExpressao, '$' COLUMNS (
        sgTipoMneumonico        PATH '$.sgTipoMneumonico',
        deOperacao              PATH '$.deOperacao',
      
        inTipoRubrica           PATH '$.inTipoRubrica',
        inRelacaoRubrica        PATH '$.inRelacaoRubrica',
        inMes                   PATH '$.inMes',
        nuMeses                 PATH '$.nuMeses',
        nuValor                 PATH '$.nuValor',
        flValorHoraMinuto       PATH '$.flValorHoraMinuto',
      
        nuRubrica               PATH '$.nuRubrica',
        nuMesRubrica            PATH '$.nuMesRubrica',
        nuAnoRubrica            PATH '$.nuAnoRubrica',
      
        nmValorReferencia       PATH '$.nmValorReferencia',
        sgBaseCalculo           PATH '$.sgBaseCalculo',
        sgTabelaValorGeralCEF   PATH '$.sgTabelaValorGeralCEF',
        nmEstruturaCarreira     PATH '$.nmEstruturaCarreira',
        nmFuncaoChefia          PATH '$.nmFuncaoChefia',
        deNivel                 PATH '$.deNivel',
        deReferencia            PATH '$.deReferencia',
        deCodigoCCO             PATH '$.deCodigoCCO',
        deTipoAdicionalTempServ PATH '$.deTipoAdicionalTempServ',
      
        GrupoRubricas           CLOB FORMAT JSON PATH '$.GrupoRubricas'
      )) js
      
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagTipoMneumonico mneu ON mneu.sgTipoMneumonico = js.sgTipoMneumonico
      LEFT JOIN RubricaLista rub on rub.nuRubrica = js.nuRubrica
                                AND rub.cdAgrupamento = o.cdAgrupamento
      LEFT JOIN epagValorReferencia vlref ON vlref.cdAgrupamento = o.cdAgrupamento AND vlref.nmValorReferencia = js.nmValorReferencia
      LEFT JOIN epagBaseCalculo baseexp ON baseexp.cdAgrupamento = o.cdAgrupamento AND baseexp.sgBaseCalculo = js.sgBaseCalculo
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = o.cdAgrupamento
                                               AND tabgeral.sgTabelaValorGeralCEF = js.sgTabelaValorGeralCEF
      LEFT JOIN EstruturaCarreiraLista cef ON cef.cdAgrupamento = o.cdAgrupamento
                                          AND cef.nmEstruturaCarreira = js.nmEstruturaCarreira
      )
      SELECT * FROM BlocoExpressao;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
      'FORMULA CÁLCULO EXPRESSAO BLOCO ' || pcdIdentificacao,
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir a Expressão do Bloco da Formula de Cálculo
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgTipoMneumonico,1,70);

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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO EXPRESSAO BLOCO', 'INCLUSAO',
        'Expressão do Bloco da Formula de Cálculo incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo - ' ||
        'Grupo de Rubricas ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      -- Incluir Incluir o Grupo de Rubricas do Bloco da Formula de Cálculo
      vnuRegistros := 0;
      SELECT COUNT(*) INTO vnuRegistros
      FROM JSON_TABLE(r.GrupoRubricas, '$[*]' COLUMNS (
        nuRubrica            PATH '$.nuRubrica',
        cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
      )) js
      WHERE js.cdRubricaAgrupamento IS NOT NULL;
      
      IF vnuRegistros > 0 THEN
        INSERT INTO epagFormCalcBlocoExpRubAgrup
        SELECT vcdFormulaCalcBlocoExpressaoNova as cdFormulaCalcBlocoExpressao, js.cdRubricaAgrupamento
        FROM JSON_TABLE(r.GrupoRubricas, '$[*]' COLUMNS (
          cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
        )) js
        WHERE js.cdRubricaAgrupamento IS NOT NULL;

        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
            'FORMULA CÁLCULO GRUPO RUBRICAS', 'INCLUSAO',
            'Grupo de Rubricas do Bloco da Formula de Cálculo incluídas com sucesso',
          cAUDITORIA_COMPLETO, pnuNivelAuditoria);
      END IF;
        
      FOR i IN (
        SELECT js.nuRubrica, js.cdRubricaAgrupamento
        FROM JSON_TABLE(r.GrupoRubricas, '$[*]' COLUMNS (
          nuRubrica            PATH '$.nuRubrica',
          cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
        )) js
        WHERE js.cdRubricaAgrupamento IS NULL
      )
      LOOP
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || i.nuRubrica,1,70), 1,
            'FORMULA CÁLCULO GRUPO RUBRICAS', 'INCONSISTENTE',
            'Rubricas do Grupo do Bloco da Formula de Cálculo Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Formula de Cálculo ' || vcdIdentificacao ||
        ' EXPRESSAO BLOCO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'FORMULA CÁLCULO EXPRESSAO BLOCO', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarExpressaoBloco;

END PKGMIG_ParametrizacaoFormulasCalculo;
/
