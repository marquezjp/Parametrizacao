-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ImportarBasesCalculo AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados das Bases de Calculo a partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão ou atualização das Bases de Calculo na tabela epagBaseCalculo
  --     - Importação das Versões das Bases
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem   IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino  IN VARCHAR2: Sigla do agrupamento de destino para os dados
  --
  -- ###########################################################################
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15) := Null;
    vsgModulo           CHAR(3)      := 'PAG';
    vsgConceito         VARCHAR2(20) := 'BASE';
	vtpOperacao         VARCHAR2(15) := 'IMPORTACAO';
	vdtOperacao         TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(50) := Null;
    vcdBaseCalculoNova  NUMBER       := Null;
    vnuInseridos        NUMBER       := 0;
    vnuAtualizados      NUMBER       := 0;
    vResumoEstatisticas CLOB         := Null;
    
    -- Cursor que extrai e transforma os dados JSON das Bases
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
      BasesCalculo as (
      SELECT
      cfg.cdIdentificacao,
      base.cdBaseCalculo,
      o.cdAgrupamento,
      o.cdOrgao,
      js.nmBaseCalculo,
      js.sgBaseCalculo,
      'N' AS flAnulado,
      NULL AS dtAnulado,
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      SYSTIMESTAMP AS dtUltAlteracao,
      js.Versoes
      FROM emigConfiguracaoPadrao cfg
      CROSS APPLY JSON_TABLE(cfg.jsConteudo, '$.PAG.Base' COLUMNS (
        sgBaseCalculo PATH '$.sgBaseCalculo',
        nmBaseCalculo PATH '$.nmBaseCalculo',
        Versoes       CLOB FORMAT JSON PATH '$.Versoes'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(cfg.sgOrgao,' ')
      LEFT JOIN epagBaseCalculo base on base.cdAgrupamento = o.cdAgrupamento and base.sgBaseCalculo = js.sgBaseCalculo
      WHERE cfg.sgModulo = 'PAG' AND cfg.sgConceito = 'BASE' AND cfg.flAnulado = 'N'
        AND cfg.sgAgrupamento = psgAgrupamentoOrigem AND cfg.sgOrgao IS NULL
      )
      SELECT * FROM BasesCalculo;
      
    -- Cursor que extrai as estatísticas do Log
    CURSOR cLog IS
      WITH
      Estatisticas AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
        CASE nmEntidade
          WHEN 'BASE CALCULO' THEN 10
          WHEN 'VERCAO' THEN 20
          WHEN 'VIGENCIA' THEN 30
          WHEN 'DOCUMENTO' THEN 40
          WHEN 'BLOCOS' THEN 50
          WHEN 'EXPRESSAO BLOCO' THEN 60
          WHEN 'GRUPO RUBRICAS' THEN 70
        END AS cdEntidade,
        nmEntidade,
        CASE nmEvento WHEN 'EXCLUSAO' THEN 1 WHEN 'ATUALIZACAO' THEN 2 WHEN 'INCLUSAO' THEN 3 END AS cdEvento,
        COUNT(*) As qtde
      FROM emigConfiguracaoPadraoLog
      WHERE nmEvento != 'RESUMO'
      GROUP BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
        CASE nmEntidade
          WHEN 'BASE CALCULO' THEN 10
          WHEN 'VERCAO' THEN 20
          WHEN 'VIGENCIA' THEN 30
          WHEN 'DOCUMENTO' THEN 40
          WHEN 'BLOCOS' THEN 50
          WHEN 'EXPRESSAO BLOCO' THEN 60
          WHEN 'GRUPO RUBRICAS' THEN 70
        END,
        nmEntidade,
        CASE nmEvento WHEN 'EXCLUSAO' THEN 1 WHEN 'ATUALIZACAO' THEN 2 WHEN 'INCLUSAO' THEN 3 END
      ),
      Resumo AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
      cdEntidade, nmEntidade,
      nvl(Incluidos,0) AS Incluidos, nvl(Atualizados,0) AS Atualizados, nvl(Excluidos,0) AS Excluidos,
      nvl(Incluidos,0) + nvl(Atualizados,0) + nvl(Excluidos,0) As Total
      FROM Estatisticas
      PIVOT (SUM(Qtde) FOR cdEvento IN (1 AS Excluidos, 2 As Atualizados, 3 AS Incluidos))
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      )
      SELECT JSON_SERIALIZE (TO_CLOB(JSON_OBJECT(
        sgModulo VALUE JSON_OBJECT(
          sgConceito VALUE JSON_OBJECT(
            tpOperacao,
            sgAgrupamento,
            'sgOrgao' value NVL(sgOrgao,'TODOS'),
            'dtOperacao' VALUE TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI'),
            'Registros' VALUE JSON_ARRAYAGG(JSON_OBJECT(
              nmEntidade VALUE JSON_OBJECT(
                'Incluídos' VALUE Incluidos,
                'Atualizados' VALUE Atualizados,
                'Excluídos' VALUE Excluidos,
                'Total' VALUE Total)
            ) ORDER By cdEntidade)
          RETURNING CLOB)
        RETURNING CLOB)
      RETURNING CLOB)) RETURNING CLOB PRETTY) AS ResumoEstatisticas
      FROM Resumo
      WHERE Resumo.sgModulo = 'PAG' AND Resumo.sgConceito = 'BASE'
        AND tpOperacao = 'IMPORTACAO' AND dtOperacao = vdtOperacao
        AND Resumo.sgAgrupamento = psgAgrupamentoDestino
      GROUP BY sgAgrupamento, sgOrgao, dtOperacao, tpOperacao, sgModulo, sgConceito;

  BEGIN
    
	vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Importação das Configurações do Agrupamento ' || psgAgrupamentoOrigem ||
      ' para o Agrupamento ' || psgAgrupamentoDestino || ', Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI'));

    -- Loop principal de processamento
    FOR r IN cDados LOOP
  
      vsgOrgao := r.cdOrgao;
      vcdIdentificacao := r.cdIdentificacao;
  
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Base ' || vcdIdentificacao);

      IF r.cdBaseCalculo IS NULL THEN
        -- Incluir Nova Base de Cálculo
        SELECT NVL(MAX(cdBaseCalculo), 0) + 1 INTO vcdBaseCalculoNova FROM epagBaseCalculo;

        INSERT INTO epagBaseCalculo (
          cdBaseCalculo, cdAgrupamento, cdOrgao, nmBaseCalculo, sgBaseCalculo,
          nuCPFCadastrador, dtInclusao, flAnulado, dtAnulado, dtUltAlteracao
        ) VALUES (
		  vcdBaseCalculoNova, r.cdAgrupamento, r.cdOrgao, r.nmBaseCalculo, r.sgBaseCalculo,
          r.nuCPFCadastrador, r.dtInclusao, r.flAnulado, r.dtAnulado, r.dtUltAlteracao
        );

		vnuInseridos := vnuInseridos + 1;
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao,
          'BASE CALCULO', 'INCLUSAO', 'Base de Cálculo incluidas com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      ELSE
        -- Atualizar Base de Cálculo Existente
        vcdBaseCalculoNova := r.cdBaseCalculo;

        UPDATE epagBaseCalculo SET
		  cdAgrupamento    = r.cdAgrupamento,
		  cdOrgao          = r.cdOrgao,
		  nmBaseCalculo    = r.nmBaseCalculo,
		  sgBaseCalculo    = r.sgBaseCalculo,
          nuCPFCadastrador = r.nuCPFCadastrador,
		  dtInclusao       = r.dtInclusao,
		  flAnulado        = r.flAnulado,
		  dtAnulado        = r.dtAnulado,
		  dtUltAlteracao   = r.dtUltAlteracao
        WHERE cdBaseCalculo = vcdBaseCalculoNova;

        vnuAtualizados := vnuAtualizados + 1;
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao,
          'BASE CALCULO', 'ATUALIZACAO', 'Base de Cálculo atualizada com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      END IF;

      -- Importar Versões da Base de Cálculo
      pImportarVersoes(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdBaseCalculoNova, r.Versoes);

    END LOOP;

    -- Gerar as Estatísticas da Importação das Bases de Calculo
    OPEN cLog;
    FETCH cLog INTO vResumoEstatisticas;
    CLOSE cLog;

    -- Registro de Resumo da Importação das Bases de Calculo
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
      vsgModulo, vsgConceito, Null,
      'BASE CALCULO', 'RESUMO', vResumoEstatisticas,
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Resumo da Importação das Configurações do Agrupamento ');

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Estatísticas: ' || vResumoEstatisticas);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Importação das Configurações do Agrupamento ' || psgAgrupamentoOrigem ||
      ' para o Agrupamento ' || psgAgrupamentoDestino || ', Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI'));

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo ' || vcdIdentificacao || ' BASE CALCULO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
        vsgModulo, vsgConceito, vcdIdentificacao,
        'BASE CALCULO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pImportarVersoes(
  -- ###########################################################################
  -- PROCEDURE: pImportarVersoes
  -- Objetivo:
  --   Importar dados das Versões da Base do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Exclusão dos Grupos de Rubricas dos Blocos da Base
  --       tabela epagBaseCalcBlocoExprRubAgrup
  --     - Exclusão das Expressões dos Blocos da Base
  --       tabela epagBaseCalculoBlocoExpressao
  --     - Exclusão dos Blocos da Base tabela epagBaseCalculoBloco
  --     - Exclusão das Vigências da Base tabela epagHistBaseCalculo
  --     - Exclusão das Versões da Base tabela epagBaseCalculoVersao
  --     - Inclusão das Versões da Base tabela epagBaseCalculoVersao
  --     - Importação das Vigências das Bases
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
  --   pcdBaseCalculo        IN NUMBER: 
  --   pVersoes              IN CLOB: 
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdBaseCalculo        IN NUMBER,
    pVersoes              IN CLOB
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao         VARCHAR2(50) := Null;
    vcdVersaoBaseCalculoNova NUMBER := 0;
	vnuInseridos             NUMBER := 0;

    -- Cursor que extrai as Versões das Bases do Documento Versões JSON
    CURSOR cDados IS
      WITH
      Versoes as (
      SELECT
        (SELECT NVL(MAX(cdVersaoBaseCalculo),0) + 1 FROM epagBaseCalculoVersao) AS cdVersaoBaseCalculo,
        pcdBaseCalculo as cdBaseCalculo,
        js.nuVersao,
        SYSTIMESTAMP AS dtUltAlteracao,
        js.Vigencias
      FROM JSON_TABLE(JSON_QUERY(pVersoes, '$'), '$[*]' COLUMNS (
        nuVersao  PATH '$.nuVersao',
        Vigencias CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Versões ' || vcdIdentificacao);
 
    -- Excluir as Expressões das Rubricas dos Blocos da Base de Cálculo
    DELETE FROM epagBaseCalcBlocoExprRubAgrup
      WHERE cdBaseCalculoBlocoExpressao IN (
        SELECT Expressao.cdBaseCalculoBlocoExpressao FROM epagBaseCalculoBlocoExpressao Expressao
        INNER JOIN epagBaseCalculoBloco Blocos ON Blocos.cdBaseCalculoBloco = Expressao.cdBaseCalculoBloco
        INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
      psgModulo, psgConceito, vcdIdentificacao,
      'GRUPO RUBRICAS', 'EXCLUSAO', 'Grupo de Rubricas do Blocos da Base de Cálculo excluidas com sucesso',
      cDEBUG_DESLIGADO, pnuDEBUG);

    -- Excluir a Expressão da Base de Cálculo
    DELETE FROM epagBaseCalculoBlocoExpressao
      WHERE cdBaseCalculoBloco IN (
        SELECT Blocos.cdBaseCalculoBloco FROM epagBaseCalculoBloco Blocos
        INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
      psgModulo, psgConceito, vcdIdentificacao,
      'EXPRESSAO BLOCO', 'EXCLUSAO', 'Expressão do Bloco da Base de Cálculo excluidos com sucesso',
      cDEBUG_DESLIGADO, pnuDEBUG);

    -- Excluir as Blocos da Base de Cálculo
    DELETE FROM epagBaseCalculoBloco
      WHERE cdHistBaseCalculo IN (
        SELECT Vigencia.cdHistBaseCalculo FROM epagHistBaseCalculo Vigencia
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
      psgModulo, psgConceito, vcdIdentificacao,
      'BLOCOS', 'EXCLUSAO', 'Blocos da Base de Cálculo excluidas com sucesso',
      cDEBUG_DESLIGADO, pnuDEBUG);
      
    -- Excluir os Documentos das Vigências da Base de Cálculo
    FOR d IN (
      SELECT Vigencia.cdHistBaseCalculo, Vigencia.cdDocumento FROM epagHistBaseCalculo Vigencia
      INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
        WHERE Versao.cdBaseCalculo = pcdBaseCalculo AND Vigencia.cdDocumento IS NOT NULL
    ) LOOP
      UPDATE epagHistBaseCalculo Vigencia SET Vigencia.cdDocumento = NULL
        WHERE Vigencia.cdHistBaseCalculo = d.cdHistBaseCalculo;

      DELETE FROM eatoDocumento
        WHERE cdDocumento = d.cdDocumento;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao,
        'DOCUMENTO', 'EXCLUSAO', 'Documentos de Amparo ao Fato da Base de Cálculo excluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);
    END LOOP;      

    -- Excluir as Vigências da Base de Cálculo
    DELETE FROM epagHistBaseCalculo
      WHERE cdVersaoBaseCalculo IN (
        SELECT Versao.cdVersaoBaseCalculo FROM epagBaseCalculoVersao Versao
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
      psgModulo, psgConceito, vcdIdentificacao,
      'VIGENCIA', 'EXCLUSAO', 'Vigências da Base de Cálculo excluidas com sucesso',
      cDEBUG_DESLIGADO, pnuDEBUG);

    -- Excluir as Versões da Base de Cálculo
    DELETE FROM epagBaseCalculoVersao Versao
      WHERE Versao.cdBaseCalculo = pcdBaseCalculo;

    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
      psgModulo, psgConceito, vcdIdentificacao,
      'VERCAO', 'EXCLUSAO', 'Versões da Base de Cálculo excluidas com sucesso',
      cDEBUG_DESLIGADO, pnuDEBUG);
  
    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || r.nuversao;
	  
	  -- Inserir na tabela epagBaseCalculoVersao
	  SELECT NVL(MAX(cdVersaoBaseCalculo), 0) + 1 INTO vcdVersaoBaseCalculoNova FROM epagBaseCalculoVersao;

      INSERT INTO epagBaseCalculoVersao (
	    cdVersaoBaseCalculo, cdBaseCalculo, nuVersao, dtUltAlteracao
      ) VALUES (
		vcdVersaoBaseCalculoNova, pcdBaseCalculo, r.nuversao, r.dtultalteracao
      );

      vnuInseridos := vnuInseridos + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'VERCAO', 'INCLUSAO', 'Versão da Base incluida com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      -- Importar Vigências da Base de Cálculo
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdVersaoBaseCalculoNova, r.Vigencias);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo ' || vcdIdentificacao || ' VERCAO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'VERCAO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVersoes;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências da Base do Documento Vigências JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Vigências da Base na tabela epagHistBaseCalculo
  --     - Inclusão do Documento de Amparo ao Fato tabela eatoDocumento
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
  --   pcdVersaoBaseCalculo  IN NUMBER:
  --   pVigencias            IN CLOB:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdVersaoBaseCalculo  IN NUMBER,
    pVigencias            IN CLOB
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(50) := Null;
    vcdHistBaseCalculoNova     NUMBER       := Null;
    vcdDocumentoNovo           NUMBER       := Null;
    vnuInseridos               NUMBER       := 0;

    -- Cursor que extrai as Vigências das Bases do Documento pVigencias JSON
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
      Vigencias as (
      SELECT
--      (SELECT NVL(MAX(cdHistBaseCalculo),0) + 1 FROM epagHistBaseCalculo) AS cdHistBaseCalculo,
--      pcdVersaoBaseCalculo as cdVersaoBaseCalculo,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicioVigencia,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicioVigencia,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFimVigencia,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFimVigencia,
      js.deFormula,
      js.deExpressaoCalculo,
      
      js.deLimiteInferior,
      js.deLimiteSuperior,
      vlrefinf.cdValorReferencia as cdValorReferenciaInferior,
      js.nuQtdeValReferenciaInferior,
      vlrefsup.cdValorReferencia as cdValorReferenciaSuperior,
      js.nuQtdeValReferenciaSuperior,
      
	  -- eatoDocumento
      js.nuAnoDocumento,
      tpdoc.cdTipoDocumento,
	  CASE WHEN js.dtDocumento IS NULL THEN NULL
        ELSE TO_DATE(js.dtDocumento, 'YYYY-MM-DD') END AS dtDocumento,
      js.deObservacao,
      js.nuNumeroAtoLegal,
      js.nmArquivoDocumento,
      js.deCaminhoArquivoDocumento,

      meiopub.cdMeioPublicacao,
      tppub.cdTipoPublicacao,
	  CASE WHEN js.dtPublicacao IS NULL THEN NULL
        ELSE TO_DATE(js.dtPublicacao, 'YYYY-MM-DD') END AS dtPublicacao,
      js.nuPublicacao,
      js.nuPagInicial,
      js.deOutroMeio,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      SYSTIMESTAMP AS dtUltAlteracao,
      
      js.Blocos
      FROM JSON_TABLE(JSON_QUERY(pVigencias, '$'), '$.Vigencia' COLUMNS (
        nuAnoMesInicioVigencia      PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia         PATH '$.nuAnoMesFimVigencia',
        deFormula                   PATH '$.Expressao.deFormula',
        deExpressaoCalculo          PATH '$.Expressao.deExpressaoCalculo',
        deLimiteInferior            PATH '$.Expressao.Limites.deLimiteInferior',
        deLimiteSuperior            PATH '$.Expressao.Limites.deLimiteSuperior',
        sgValorReferenciaInferior   PATH '$.Expressao.Limites.sgValorReferenciaInferior',
        nuQtdeValReferenciaInferior PATH '$.Expressao.Limites.nuQtdeValReferenciaInferior',
        sgValorReferenciaSuperior   PATH '$.Expressao.Limites.sgValorReferenciaSuperior',
        nuQtdeValReferenciaSuperior PATH '$.Expressao.Limites.nuQtdeValReferenciaSuperior',
      
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
      
        Blocos                      CLOB FORMAT JSON PATH '$.Expressao.Blocos'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagValorReferencia vlrefinf ON vlrefinf.cdAgrupamento = o.cdAgrupamento
                                            AND vlrefinf.sgValorReferencia = js.sgValorReferenciaInferior
      LEFT JOIN epagValorReferencia vlrefsup ON vlrefsup.cdAgrupamento = o.cdAgrupamento
                                            AND vlrefsup.sgValorReferencia = js.sgValorReferenciaSuperior
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      )
      SELECT * FROM Vigencias;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Vigências ' || vcdIdentificacao);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := pcdIdentificacao || ' ' || lpad(r.nuAnoInicioVigencia,4,0) || lpad(r.nuMesInicioVigencia,2,0);
       
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
          psgModulo, psgConceito, vcdIdentificacao,
          'DOCUMENTO', 'INCLUSAO', 'Documentos de Amparo ao Fato da Base de Cálculo incluidas com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
	  END IF;

      -- Incluir Nova Vigência da Base
      SELECT NVL(MAX(cdhistbasecalculo), 0) + 1 INTO vcdHistBaseCalculoNova FROM epagHistBaseCalculo;

      INSERT INTO epagHistBaseCalculo (
	    cdHistBaseCalculo, cdVersaoBaseCalculo,
		nuAnoInicioVigencia, nuMesInicioVigencia, nuAnoFimVigencia, nuMesFimVigencia,
        deExpressaoCalculo, deFormula, deLimiteInferior, deLimiteSuperior,
		cdDocumento, cdTipoPublicacao, cdMeioPublicacao, dtPublicacao, nuPagInicial, nuPublicacao, deOutromeio,
		nuCPFCadastrador, dtInclusao, dtUltAlteracao,
        cdValorReferenciaInferior, nuQtdeValReferenciaInferior, cdValorReferenciaSuperior, nuQtdeValReferenciaSuperior
      ) VALUES (
        vcdHistBaseCalculoNova, pcdVersaoBaseCalculo,
		r.nuAnoInicioVigencia, r.nuMesInicioVigencia, r.nuAnoFimVigencia, r.nuMesFimVigencia,
        r.deExpressaoCalculo, r.deFormula, r.deLimiteInferior, r.deLimiteSuperior,
		vcdDocumentoNovo, r.cdTipoPublicacao, r.cdMeioPublicacao, r.dtPublicacao, r.nuPagInicial, r.nuPublicacao, r.deOutromeio,
		r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao,
        r.cdValorReferenciaInferior, r.nuQtdeValReferenciaInferior, r.cdValorReferenciaSuperior, r.nuQtdeValReferenciaSuperior
      );

      vnuInseridos := vnuInseridos + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'VIGENCIA', 'INCLUSAO', 'Vigência da Base incluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      -- Importar Blocos da Base de Cálculo
      pImportarBlocos(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdHistBaseCalculoNova, r.Blocos);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo ' || vcdIdentificacao || ' VIGENCIA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;
    
  PROCEDURE pImportarBlocos(
  -- ###########################################################################
  -- PROCEDURE: pImportarBlocos
  -- Objetivo:
  --   Importar os Blocos Base de Calculo contida no Documento Blocos JSON
  --     na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão dos Blocos da Base na tabela epagBaseCalculoBloco
  --     - Importar Expressão do Bloco
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
  --   pcdHistBaseCalculo    IN NUMBER:
  --   pBlocos               IN CLOB: 
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdHistBaseCalculo    IN NUMBER,
    pBlocos               IN CLOB
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao        VARCHAR2(50) := Null;
    vcdBaseCalculoBlocoNova NUMBER       := Null;
    vnuInseridos            NUMBER       := 0;

    -- Cursor que extrai as Vigências da Rubrica do Agrupamento do Documento pVigencias Agrupamento JSON
    CURSOR cDados IS
      WITH
      Blocos AS (
      SELECT 
      (SELECT NVL(MAX(cdBaseCalculoBloco),0) + 1 FROM epagBaseCalculoBloco) AS cdBaseCalculoBloco,
      pcdHistBaseCalculo as cdHistBaseCalculo,
      js.sgBloco,
      SYSTIMESTAMP AS dtUltAlteracao,
      js.ExpressaoBloco
      FROM JSON_TABLE(JSON_QUERY(pBlocos, '$'), '$[*]' COLUMNS (
        sgBloco        PATH '$.sgBloco',
        ExpressaoBloco CLOB FORMAT JSON PATH '$.Expressao'
      )) js
      )
      SELECT * FROM Blocos;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Blocos ' || vcdIdentificacao);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

      vcdIdentificacao := pcdIdentificacao || ' ' || r.sgbloco;

      SELECT NVL(MAX(cdBaseCalculoBloco), 0) + 1 INTO vcdBaseCalculoBlocoNova FROM epagBaseCalculoBloco;

      INSERT INTO epagBaseCalculoBloco (
	    cdBaseCalculoBloco, cdhistbasecalculo, sgbloco, dtultalteracao
      ) VALUES (
        vcdBaseCalculoBlocoNova, pcdHistBaseCalculo, r.sgbloco, r.dtultalteracao
      );

      vnuInseridos := vnuInseridos + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao,
        'BLOCOS', 'INCLUSAO', 'Inclusão dos Blocos da Base incluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      -- Importar Expressão do Bloco da Base de Cálculo
      pImportarExpressaoBloco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdBaseCalculoBlocoNova, r.ExpressaoBloco);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo ' || vcdIdentificacao || ' BLOCOS Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'BLOCOS', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarBlocos;

  PROCEDURE pImportarExpressaoBloco(
  -- ###########################################################################
  -- PROCEDURE: pImportarExpressaoBloco
  -- Objetivo:
  --   Importar a Expressão do Bloco Base de Cálculo contida no
  --     Documento Expressão do Bloco JSON na tabela emigConfiguracaoPadrao,
  --     realizando:
  --     - Inclusão da Expressão do Bloco da Base
  --       na tabela epagBaseCalculoBlocoExpressao
  --     - Incluir o Grupo de Rubricas do Base de Cálculo
  --       na tabela epagBaseCalcBlocoExprRubAgrup
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
  --   pcdBaseCalculoBloco   IN NUMBER: 
  --   pExpressaoBloco       IN CLOB: 
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
	ptpOperacao           IN VARCHAR2,
	pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pcdBaseCalculoBloco   IN NUMBER,
    pExpressaoBloco       IN CLOB
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao                 VARCHAR2(50) := Null;
    vcdBaseCalculoBlocoExpressaoNova NUMBER   := Null;
    vnuInseridos                     NUMBER   := 0;

    -- Cursor que extrai a Expressão do Base de Cálculo do Documento pExpressaoBloco JSON
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
      Rub AS (
      SELECT LPAD(tpr.nuTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0) AS nuRubrica, ra.cdAgrupamento, ra.cdRubricaAgrupamento
      FROM epagRubrica r
      INNER JOIN epagTipoRubrica tpr ON tpr.cdtiporubrica = r.cdtiporubrica
      INNER JOIN epagRubricaAgrupamento ra ON ra.cdrubrica = r.cdrubrica
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
      (SELECT NVL(MAX(cdBaseCalculoBlocoExpressao),0) + 1 FROM epagBaseCalculoBlocoExpressao) AS cdBaseCalculoBlocoExpressao,
      pcdBaseCalculoBloco as cdBaseCalculoBloco,
	  js.sgTipoMneumonico,
      mneu.cdTipoMneumonico,
      js.deOperacao,
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
      js.nuMeses,
      js.nuValor,
      js.inTipoRetorno,
      js.inValorHoraMinuto,
      rubagrup.cdRubricaAgrupamento,
      js.nuMesRubrica,
      js.nuAnoRubrica,
      vlref.cdValorReferencia,
      baseexp.cdBaseCalculo,
      tabgeral.cdValorGeralCEFAgrup,
      EstruturaCarreira.cdEstruturaCarreira as cdEstruturaCarreira,
      NULL as cdFuncaoChefia,
      js.deNivel,
      js.deReferencia,
      js.deCodigoCCO,
      NULL as cdTipoAdicionalTempServ,
      
      SYSTIMESTAMP AS dtUltAlteracao,
      
      (SELECT JSON_ARRAYAGG(rub.cdRubricaAgrupamento RETURNING CLOB) AS GRP FROM JSON_TABLE(js.GrupoRubricas, '$[*]' COLUMNS (nuRubrica PATH '$')) js
      LEFT JOIN Rub ON rub.nuRubrica = js.nuRubrica AND rub.cdAgrupamento = 19) As GrupoRubricas
      
      FROM JSON_TABLE(JSON_QUERY(pExpressaoBloco, '$'), '$[*]' COLUMNS (
        sgTipoMneumonico        PATH '$.sgTipoMneumonico',
        deOperacao              PATH '$.deOperacao',
        inTipoRubrica           PATH '$.inTipoRubrica',
        inRelacaoRubrica        PATH '$.inRelacaoRubrica',
        inMes                   PATH '$.inMes',
        nuMeses                 PATH '$.nuMeses',
        nuValor                 PATH '$.nuValor',
        inTipoRetorno           PATH '$.inTipoRetorno',
        inValorHoraMinuto       PATH '$.inValorHoraMinuto',
        nuRubrica               PATH '$.nuRubrica',
        nuMesRubrica            PATH '$.nuMesRubrica',
        nuAnoRubrica            PATH '$.nuAnoRubrica',
        nmValorReferencia       PATH '$.nmValorReferencia',
        sgBaseCalculo           PATH '$.sgBaseCalculo',
        sgTabelaValorGeralCEF   PATH '$.sgTabelaValorGeralCEF',
        CarreiraCargo           PATH '$.CarreiraCargo',
      --  cdFuncaoChefia        PATH '$.cdFuncaoChefia',
        deNivel                 PATH '$.deNivel',
        deReferencia            PATH '$.deReferencia',
        deCodigoCCO             PATH '$.deCodigoCCO',
      --  cdTipoAdicionalTempServ PATH '$.cdTipoAdicionalTempServ',
      
        GrupoRubricas           CLOB FORMAT JSON PATH '$.GrupoRubricas'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagTipoMneumonico mneu ON mneu.sgTipoMneumonico = js.sgTipoMneumonico
      LEFT JOIN epagTipoRubrica tprub ON tprub.nuTipoRubrica = SUBSTR(js.nuRubrica,1,2)
      LEFT JOIN epagRubrica rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,3,4) AND rub.cdTipoRubrica = tprub.cdTipoRubrica
      LEFT JOIN epagRubricaAgrupamento rubagrup ON rubagrup.cdRubrica = rub.cdRubrica
                                               AND rubagrup.cdAgrupamento = o.cdAgrupamento
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

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Expressão do Bloco ' || vcdIdentificacao);

    -- Loop principal de processamento para Incluir a Expressão do Bloco da Base de Cálculo
    FOR r IN cDados LOOP

      vcdIdentificacao := pcdIdentificacao || ' ' || r.sgTipoMneumonico;

      SELECT NVL(MAX(cdBaseCalculoBlocoExpressao), 0) + 1 INTO vcdBaseCalculoBlocoExpressaoNova FROM epagBaseCalculoBlocoExpressao;

      INSERT INTO epagBaseCalculoBlocoExpressao (
	    cdBaseCalculoBlocoExpressao, cdBaseCalculoBloco, cdTipoMneumonico, deOperacao, cdValorReferencia, cdBaseCalculo,
        cdTipoAdicionalTempServ, cdValorGeralCEFAgrup, cdEstruturaCarreira, cdFuncaoChefia, inTipoRubrica, inRelacaoRubrica, deNivel,
        deReferencia, deCodigoCCO, nuMeses, nuValor, dtUltAlteracao, inMes, cdRubricaAgrupamento, inTipoRetorno, inValorHoraMinuto,
        nuMesRubrica, nuAnoRubrica
      ) VALUES (
        vcdBaseCalculoBlocoExpressaoNova, pcdBaseCalculoBloco,
		r.cdTipoMneumonico, r.deOperacao, r.cdValorReferencia, r.cdBaseCalculo, r.cdTipoAdicionalTempServ,
		r.cdValorGeralCEFAgrup, r.cdEstruturaCarreira, r.cdFuncaoChefia, r.inTipoRubrica, r.inRelacaoRubrica,
		r.deNivel, r.deReferencia, r.deCodigoCCO, r.nuMeses, r.nuValor, r.dtUltAlteracao,
		r.inMes, r.cdRubricaAgrupamento, r.inTipoRetorno, r.inValorHoraMinuto, r.nuMesRubrica, r.nuAnoRubrica
      );

      vnuInseridos := vnuInseridos + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao,
        'EXPRESSAO BLOCO', 'INCLUSAO', 'Expressão do Bloco da Base de Cálculo incluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Grupo de Rubricas ' || vcdIdentificacao);

	  -- Incluir Incluir o Grupo de Rubricas do Bloco da Base de Cálculo
      FOR i IN (
        SELECT js.cdRubricaAgrupamento
          FROM json_table(r.GrupoRubricas, '$[*]' COLUMNS (cdRubricaAgrupamento PATH '$')) js
      ) LOOP

--        PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Grupo de Rubricas - RUBRICA' ||
--          vcdIdentificacao || ' ' || i.cdRubricaAgrupamento);

        IF i.cdRubricaAgrupamento IS NULL THEN
          PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo - Grupo de Rubricas Inexistente' ||
            vcdIdentificacao || ' ' || i.cdRubricaAgrupamento);

          PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || i.cdRubricaAgrupamento,
            'GRUPO RUBRICAS', 'NAO INCLUSAO', 'Grupo de Rubricas do Bloco da Base de Cálculo NÃO incluidas',
            cDEBUG_DESLIGADO, pnuDEBUG);
		ELSE
		  INSERT INTO epagBaseCalcBlocoExprRubAgrup VALUES (vcdBaseCalculoBlocoExpressaoNova, i.cdRubricaAgrupamento);

          PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || i.cdRubricaAgrupamento,
            'GRUPO RUBRICAS', 'INCLUSAO', 'Grupo de Rubricas do Bloco da Base de Cálculo incluidas com sucesso',
            cDEBUG_DESLIGADO, pnuDEBUG);
		END IF;
      
      END LOOP;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Base de Cálculo ' || vcdIdentificacao || ' GRUPO RUBRICAS Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        'GRUPO RUBRICAS', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarExpressaoBloco;

END PKGMIG_ImportarBasesCalculo;
/
