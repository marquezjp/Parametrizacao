-- Corpo do Pacote de Importação das Parametrizações dos Valores de Referencia
CREATE OR REPLACE PACKAGE BODY PKGMIG_ImportarValoresReferencia AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados dos Valores Referencia partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão ou atualização os Valores de Referencia na tabela epagValorReferencia
  --     - Importação das Versões dos Valores de Referencia
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino IN VARCHAR2: Sigla do agrupamento de destino para os dados
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
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15) := Null;
    vsgModulo              CHAR(3)      := 'PAG';
    vsgConceito            VARCHAR2(20) := 'VALORREFERENCIA';
    vtpOperacao            VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(50) := Null;
    vcdValorReferenciaNova NUMBER       := Null;
    vnuInseridos           NUMBER       := 0;
    vnuAtualizados         NUMBER       := 0;
    vtxResumo              VARCHAR2(4000) := NULL;
    vResumoEstatisticas    CLOB         := Null;

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
      
    -- Cursor que extrai e transforma os dados JSON dos Valores de Referencia
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
      ValorReferencia as (
      SELECT o.cdAgrupamento, o.cdOrgao, vlref.cdValorReferencia,
      js.sgValorReferencia,
      js.nmValorReferencia,
      NVL(js.flValeTransporte, 'N') AS flValeTransporte,
      NVL(js.flCorrecaoMonetaria, 'N') AS flCorrecaoMonetaria,
      NVL(js.flBloqueioRemuneracao, 'N') AS flBloqueioRemuneracao,
      NVL(js.flPermiteValorRetroativo, 'N') AS flPermiteValorRetroativo,
      NVL(js.flTetoAuxilioFuneral, 'N') AS flTetoAuxilioFuneral,
      
      SYSTIMESTAMP AS dtUltAlteracao,
      
      js.Versoes
      
      FROM emigConfiguracaoPadrao cfg
      CROSS APPLY JSON_TABLE(cfg.jsConteudo, '$.PAG.ValorReferencia' COLUMNS (
        sgValorReferencia        PATH '$.sgValorReferencia',
        nmValorReferencia        PATH '$.nmValorReferencia',
        flValeTransporte         PATH '$.Parametrizacao.flValeTransporte',
        flCorrecaoMonetaria      PATH '$.Parametrizacao.flCorrecaoMonetaria',
        flBloqueioRemuneracao    PATH '$.Parametrizacao.flBloqueioRemuneracao',
        flPermiteValorRetroativo PATH '$.Parametrizacao.flPermiteValorRetroativo',
        flTetoAuxilioFuneral     PATH '$.Parametrizacao.flTetoAuxilioFuneral',
        Versoes                  CLOB FORMAT JSON PATH '$.Versoes'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(cfg.sgOrgao,' ')
      LEFT JOIN epagValorReferencia vlref on vlref.cdAgrupamento = o.cdAgrupamento AND vlref.sgValorReferencia = js.sgValorReferencia
      WHERE cfg.sgModulo = 'PAG' AND cfg.sgConceito = 'VALORREFERENCIA' AND cfg.flAnulado = 'N'
        AND cfg.sgAgrupamento = psgAgrupamentoOrigem AND nvl(o.sgOrgao,' ') = nvl(vsgOrgao,' ')
      )
      SELECT * FROM ValorReferencia;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;
    vnuInseridos := 0;
    vnuAtualizados := 0;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Importação das Parametrizações dos ' ||
      'Valores de Referencia do Agrupamento ' || psgAgrupamentoOrigem || ' ' ||
      'para o Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cDEBUG_DESLIGADO, pnuDEBUG);

    IF cDEBUG_DESLIGADO != pnuDEBUG THEN
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Nível de Debug Habilitado ' || pnuDEBUG, cDEBUG_DESLIGADO, pnuDEBUG);
    END IF;

    -- Loop principal de processamento para Incluir os Valores de Referencia
    FOR r IN cDados LOOP
  
      vsgOrgao := r.cdOrgao;
      vcdIdentificacao := r.sgValorReferencia;
  
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao,
        cDEBUG_DESLIGADO, pnuDEBUG);

      IF r.cdValorReferencia IS NULL THEN
        -- Incluir Novo Valor de Referencia

	    SELECT NVL(MAX(cdValorReferencia), 0) + 1 INTO vcdValorReferenciaNova FROM epagValorReferencia;

        INSERT INTO epagValorReferencia (cdValorReferencia, cdAgrupamento,
          sgValorReferencia, nmValorReferencia,
          flValeTransporte, flCorrecaoMonetaria, flBloqueioRemuneracao, flPermiteValorRetroativo, flTetoAuxilioFuneral,
          dtUltAlteracao
        ) VALUES (vcdValorReferenciaNova, r.cdAgrupamento,
          r.sgValorReferencia, r.nmValorReferencia,
          r.flValeTransporte, r.flCorrecaoMonetaria, r.flBloqueioRemuneracao, r.flPermiteValorRetroativo, r.flTetoAuxilioFuneral,
          r.dtUltAlteracao
        );

        vnuInseridos := vnuInseridos + 1;
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'VALOR REFERENCIA', 'INCLUSAO', 'Valor de Referencia incluido com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      ELSE
        -- Atualizar Valor de Referencia Existente
        vcdValorReferenciaNova := r.cdValorReferencia;

        UPDATE epagValorReferencia SET
          cdAgrupamento            = r.cdAgrupamento,
          sgValorReferencia        = r.sgValorReferencia,
          nmValorReferencia        = r.nmValorReferencia,
          flValeTransporte         = r.flValeTransporte,
          flCorrecaoMonetaria      = r.flCorrecaoMonetaria,
          flBloqueioRemuneracao    = r.flBloqueioRemuneracao,
          flPermiteValorRetroativo = r.flPermiteValorRetroativo,
          flTetoAuxilioFuneral     = r.flTetoAuxilioFuneral,
          dtUltAlteracao           = r.dtUltAlteracao
        WHERE cdValorReferencia = vcdValorReferenciaNova;

        vnuAtualizados := vnuAtualizados + 1;
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'VALOR REFERENCIA', 'ATUALIZACAO', 'Valor de Referencia atualizado com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      END IF;

      -- Excluir Versões e Vigências do Valor de Referencia
      pExcluirVersoesVigencias(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdValorReferenciaNova, pnuDEBUG);

      -- Importar Versões do Valor de Referencia
      pImportarVersoes(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdValorReferenciaNova, r.Versoes, pnuDEBUG);

      COMMIT;

    END LOOP;

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação das Rubricas
    --PAtuializarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
    --  vsgModulo, vsgConceito);

    -- Gerar as Estatísticas da Importação dos Valores de Referencia
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 
      'Agrupamento ' || psgAgrupamentoOrigem || ' para o ' ||
      'Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Operação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	  'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	  'Total de Parametrizações dos Valores de Referencia Incluidas: ' || vnuInseridos ||
      ' e Alteradas: ' || vnuAtualizados;

    --pImportarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
    --  vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao);

    -- Registro de Resumo da Exportação dos Valores de Referencia
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'VALORES REFERENCIA', 'RESUMO', 'Importação das Parametrizações dos Valores de Referencia do ' || vtxResumo, 
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Importação das Parametrizações dos Valores de Referencia do ' ||
      vtxResumo, cDEBUG_DESLIGADO, pnuDEBUG);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VALOR REFERENCIA Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALOR REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pExcluirVersoesVigencias(
  -- ###########################################################################
  -- PROCEDURE: pExcluirVersoesVigencias
  -- Objetivo:
  --   Excluir as Versões e Vigencias do Valor de Referencia do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Exclusão das Vigências do Valor de Referencia tabela epagHistValorReferencia
  --     - Exclusão das Versões do Valor de Referencia tabela epagValorReferenciaVersao
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
  --   pcdValorReferencia    IN NUMBER: 
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
    pcdValorReferencia    IN NUMBER,
    pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - ' ||
      'Excluir Versões e Vigencias ' || vcdIdentificacao, cDEBUG_NIVEL_2, pnuDEBUG);

    -- Excluir as Vigências do Valor de Referencia
	SELECT COUNT(*) INTO vnuRegistros FROM epagHistValorReferencia Vigencias
        WHERE Vigencias.cdValorReferenciaVersao IN (
          SELECT Versoes.cdValorReferenciaVersao FROM epagValorReferenciaVersao Versoes
            WHERE Versoes.cdValorReferencia = pcdValorReferencia);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagHistValorReferencia Vigencias
        WHERE Vigencias.cdValorReferenciaVersao IN (
          SELECT Versoes.cdValorReferenciaVersao FROM epagValorReferenciaVersao Versoes
            WHERE Versoes.cdValorReferencia = pcdValorReferencia);

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'VIGENCIA', 'EXCLUSAO', 'Vigências do Valore de Referencia excluidos com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
	END IF;

    -- Excluir as Versões do Valore Referencia
	SELECT COUNT(*) INTO vnuRegistros FROM epagValorReferenciaVersao Versoes
      WHERE Versoes.cdValorReferencia = pcdValorReferencia;

	IF vnuRegistros > 0 THEN
      DELETE FROM epagValorReferenciaVersao Versoes
        WHERE Versoes.cdValorReferencia = pcdValorReferencia;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'VERCAO', 'EXCLUSAO', 'Versões do Valore de Referencia excluidos com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' EXCLUIR VALOR REFERENCIA Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VALOR REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pExcluirVersoesVigencias;

  PROCEDURE pImportarVersoes(
  -- ###########################################################################
  -- PROCEDURE: pImportarValoresReferencia
  -- Objetivo:
  --   Importar dados das Versões do Valor de Referencia do Documento Versões JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Versões da Formula de Calculo tabela epagValorReferenciaVersao
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
  --   pcdValorReferencia    IN NUMBER: 
  --   pVersoes              IN CLOB: 
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
    pcdValorReferencia    IN NUMBER,
    pVersoes              IN CLOB,
    pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao             VARCHAR2(70) := Null;
    vcdValorReferenciaVersaoNova NUMBER := 0;
    vnuRegistros                 NUMBER := 0;

    -- Cursor que extrai as Versões do Valor de Referencia do Documento Versões JSON
    CURSOR cDados IS
      WITH
      Versoes as (
      SELECT
      (SELECT NVL(MAX(cdValorReferenciaVersao),0) + 1 FROM epagValorReferenciaVersao) AS cdValorReferenciaVersao,
      pcdValorReferencia as cdValorReferencia,
      js.nuVersao,
      js.Vigencias
      FROM JSON_TABLE(JSON_QUERY(pVersoes, '$'), '$[*]' COLUMNS (
        nuVersao  PATH '$.nuVersao',
        Vigencias CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - Versões ' ||
      vcdIdentificacao, cDEBUG_NIVEL_1, pnuDEBUG);

    -- Loop principal de processamento para Incluir as Versões do Valor de Referencia
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || r.nuVersao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - Versões ' || vcdIdentificacao,
      cDEBUG_NIVEL_2, pnuDEBUG);

	  -- Inserir na tabela epagBaseCalculoVersao
	  SELECT NVL(MAX(cdValorReferenciaVersao), 0) + 1 INTO vcdValorReferenciaVersaoNova FROM epagValorReferenciaVersao;

      INSERT INTO epagValorReferenciaVersao (
	    cdValorReferenciaVersao, cdValorReferencia, nuVersao
      ) VALUES (
		vcdValorReferenciaVersaoNova, pcdValorReferencia, r.nuVersao
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VERCAO', 'INCLUSAO', 'Versão do Valor de Referencia incluido com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Importar Vigências da Formula de Cálculo
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdValorReferenciaVersaoNova, r.Vigencias, pnuDEBUG);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VERCAO Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VERCAO', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVersoes;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências do Valor de Referencia do Documento Vigências JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão das Vigências do Valor de Referencia na tabela epagHistValorReferencia
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino    IN VARCHAR2:
  --   psgOrgao                 IN VARCHAR2:
  --   ptpOperacao              IN VARCHAR2:
  --   pdtOperacao              IN TIMESTAMP:
  --   psgModulo                IN CHAR:
  --   psgConceito              IN VARCHAR2:
  --   pcdIdentificacao         IN VARCHAR2:
  --   pcdValorReferenciaVersao IN NUMBER:
  --   pVigencias               IN CLOB:
  --   pnuDEBUG                 IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino    IN VARCHAR2,
    psgOrgao                 IN VARCHAR2,
    ptpOperacao              IN VARCHAR2,
    pdtOperacao              IN TIMESTAMP,
    psgModulo                IN CHAR,
    psgConceito              IN VARCHAR2,
    pcdIdentificacao         IN VARCHAR2,
    pcdValorReferenciaVersao IN NUMBER,
    pVigencias               IN CLOB,
    pnuDEBUG                 IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := NULL;
    vcdHistFormulaCalculoNova  NUMBER := NULL;
    vnuRegistros               NUMBER := 0;
    vvlReferencia              NUMBER := NULL;

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
      (SELECT NVL(MAX(cdHistValorReferencia),0) + 1 FROM epagHistValorReferencia) AS cdHistValorReferencia,
      pcdValorReferenciaVersao as cdValorReferenciaVersao,
      
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicioVigencia,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicioVigencia,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFimVigencia,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFimVigencia,
      js.vlReferencia,
      js.qtValorReferencia,
      js.nuPercentual,
      DECODE(js.inTipoReferencia, 'Valor', 'V', 'Índice', 'I', NULL) AS inTipoReferencia,
      tabgeral.cdValorGeralCEFAgrup, js.sgValorGeralCEFAgrup,
      js.nuNivel,
      js.nuReferencia,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      SYSTIMESTAMP AS dtUltAlteracao
      
      FROM JSON_TABLE(JSON_QUERY(pVigencias, '$'), '$[*]' COLUMNS (
        nuAnoMesInicioVigencia PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia    PATH '$.nuAnoMesFimVigencia',
        vlReferencia           PATH '$.Valor.vlReferencia',
        qtValorReferencia      PATH '$.Valor.qtValorReferencia',
        nuPercentual           PATH '$.Valor.nuPercentual',
        inTipoReferencia       PATH '$.Valor.inTipoReferencia',
        sgValorGeralCEFAgrup   PATH '$.TabelaGeral.sgValorGeralCEFAgrup',
        nuNivel                PATH '$.TabelaGeral.nuNivel',
        nuReferencia           PATH '$.TabelaGeral.nuReferencia'
      )) js
      LEFT JOIN Orgao o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = o.cdAgrupamento
                                               AND tabgeral.cdValorGeralCEFAgrup = js.sgValorGeralCEFAgrup
      )
      SELECT * FROM Vigencias;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - ' || 'Vigências ' || vcdIdentificacao,
      cDEBUG_NIVEL_1, pnuDEBUG);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      vcdIdentificacao := pcdIdentificacao || ' ' || lpad(r.nuAnoInicioVigencia,4,0) || lpad(r.nuMesInicioVigencia,2,0);

      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - Vigências ' || vcdIdentificacao,
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Verificar se existe a Tabela Geral de Salarios dos Cargos Efetivos no Agrupamento Destino
      IF r.cdValorGeralCEFAgrup IS NULL AND r.sgValorGeralCEFAgrup IS NOT NULL THEN
        PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia  - Vigências ' || vcdIdentificacao ||
          ' Sigla da Tabela Geral CEF' || ' (' || r.sgValorGeralCEFAgrup || ') ' ||
          'da Vigência do Valor de Referencia não encontrada no Agrupamento',
          cDEBUG_DESLIGADO, pnuDEBUG);

        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'VIGENCIA', 'INCONSISTENCIA',
          'Sigla da Tabela Geral CEF' || ' (' || r.sgValorGeralCEFAgrup || ') ' ||
          'da Vigência do Valor de Referencia não encontrada no Agrupamento',
          cDEBUG_DESLIGADO, pnuDEBUG);
      END IF;

      -- Verificar se vlReferncia é Numerico e formatar para número.
      IF NOT REGEXP_LIKE(TO_CHAR(r.vlReferencia), '^[-+]?\d+(\.\d+)?$') THEN
        PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia - Vigências ' || vcdIdentificacao ||
          'Valor da Referencia é não numerico ou nulo (' || TO_CHAR(r.vlReferencia) || ')',
          cDEBUG_DESLIGADO, pnuDEBUG);

        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'VIGENCIA', 'INCONSISTENCIA',
          ' Valor da Referencia é não numerico ou nulo (' || TO_CHAR(r.vlReferencia) || ')',
          cDEBUG_DESLIGADO, pnuDEBUG);
          
          vvlReferencia := 0;
      ELSE
          vvlReferencia := TO_NUMBER(r.vlReferencia, '9999999990D99', 'NLS_NUMERIC_CHARACTERS=''.,''');
      END IF;

      -- Incluir Nova Vigência do Valor de Referencia
      SELECT NVL(MAX(cdHistValorReferencia), 0) + 1 INTO vcdHistFormulaCalculoNova FROM epagHistValorReferencia;

      INSERT INTO epagHistValorReferencia (
        cdHistValorReferencia, cdValorReferenciaVersao,
        nuMesInicioVigencia, nuAnoInicioVigencia, nuMesFimVigencia, nuAnoFimVigencia,
        vlReferencia, qtValorReferencia, nuPercentual, inTipoReferencia,
        cdValorGeralCEFAgrup, nuNivel, nuReferencia,
        nuCPFCadastrador, dtInclusao, dtUltAlteracao
      ) VALUES (
        vcdHistFormulaCalculoNova, pcdValorReferenciaVersao,
        r.nuMesInicioVigencia, r.nuAnoInicioVigencia, r.nuMesFimVigencia, r.nuAnoFimVigencia,
        vvlReferencia, r.qtValorReferencia, r.nuPercentual, r.inTipoReferencia, 
        r.cdValorGeralCEFAgrup, r.nuNivel, r.nuReferencia,
        r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VIGENCIA', 'INCLUSAO', 'Vigência do Valor de Referencia incluidos com sucesso',
        cDEBUG_NIVEL_1, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VIGENCIA Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;

END PKGMIG_ImportarValoresReferencia;
/