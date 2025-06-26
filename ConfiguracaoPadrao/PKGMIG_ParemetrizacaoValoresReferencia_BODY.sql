-- Corpo do Pacote de Exportação e Importação das Parametrizações dos Valores de Referencia
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParemetrizacaoValoresReferencia AS
  PROCEDURE pExportar(
  -- ###########################################################################
  -- PROCEDURE: pExportar
  -- Objetivo:
  --   Exportar as Parametrizações de Valores de Referencia para a Configuração Padrão JSON
  --   realizando:
  --     - Inclusão do Documento JSON ValoresReferecia na tabela emigConfigracaoPadrao
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2: Sigla do agrupamento de origem da configuração
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
    psgAgrupamento        IN VARCHAR2,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15)          := NULL;
    vsgModulo           CONSTANT CHAR(3)      := 'PAG';
    vsgConceito         CONSTANT VARCHAR2(20) := 'VALORREFERENCIA';
    vtpOperacao         CONSTANT VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20)          := NULL;
    vnuVersao           CONSTANT CHAR(04)     := '1.00';
    vflAnulado          CONSTANT CHAR(01)     := 'N';

    rsgAgrupamento      VARCHAR2(15) := NULL;
    rsgOrgao            VARCHAR2(15) := NULL;
    rsgModulo           CHAR(3)      := NULL;
    rsgConceito         VARCHAR2(20) := NULL;
    rdtExportacao       TIMESTAMP(6) := NULL;
    rcdIdentificacao    VARCHAR2(20) := NULL;
    rjsConteudo         CLOB         := NULL;
    rnuVersao           CHAR(04)     := NULL;
    rflAnulado          CHAR(01)     := NULL;
    rdtInclusao         TIMESTAMP(6) := NULL;

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;
    vtxResumo           VARCHAR2(4000) := NULL;
    vListaTabelas          CLOB := '[
      "EPAGVALORREFERENCIA",
      "EPAGVALORREFERENCIAVERSAO",
      "EPAGHISTVALORREFERENCIA"
    ]';

    -- Cursor que extrai e transforma os dados JSON de Valores de Referencia
    vRefCursor SYS_REFCURSOR;

  BEGIN
  
    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_Parametrizacao.PConsoleLog('Inicio da Exportações das Parametrizações dos ' ||
      'Valores de Referencia do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	    'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_Parametrizacao.PConsoleLog('Nível de Auditoria Habilitado ' ||
          CASE pnuNivelAuditoria
            WHEN cAUDITORIA_SILENCIADO THEN 'SILENCIADO'
            WHEN cAUDITORIA_ESSENCIAL  THEN 'ESSENCIAL'
            WHEN cAUDITORIA_DETALHADO  THEN 'DETALHADO'
            WHEN cAUDITORIA_COMPLETO   THEN 'COMPLETO'
            ELSE 'ESSENCIAL'
          END, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

	  -- Defini o Cursos com a Query que Gera o Documento JSON ValoresReferencia
	  vRefCursor := fnCursorValoresReferencia(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito,
      vdtOperacao, vnuVersao, vflAnulado);

	  vnuRegistros := 0;

	  -- Loop principal de processamento
	LOOP
      FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
        rcdIdentificacao, rjsConteudo,
        rnuVersao,
        rflAnulado, rdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      vcdIdentificacao := rcdIdentificacao;
      
      PKGMIG_Parametrizacao.PConsoleLog('Exportação do Valor de Referencia ' || vcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      INSERT INTO emigParametrizacao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
        cdIdentificacao, jsConteudo, nuVersao, flAnulado
      ) VALUES (
        rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
        rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado
      );

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'INCLUSAO', 'Documento JSON ValoresReferencia incluído com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    CLOSE vRefCursor;

    COMMIT;

    -- Gerar as Estatísticas da Exportação dos Valores de Referencia
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 'Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Exportação  ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	    'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	    'Total de Parametrizações dos Valores de Referencia Exportadas: ' || vnuRegistros;

    -- Registro de Resumo da Exportação dos Valores de Referencia
    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'VALORES REFERENCIA', 'RESUMO', 'Exportação das Parametrizações dos Valores de Referencia do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    PKGMIG_Parametrizacao.PConsoleLog('Termino da Exportação das Parametrizações dos Valores de Referencia do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Exportação de Valores de Referencia ' || vcdIdentificacao ||
      ' VALORES REFERENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pExportar;

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados dos Valores Referencia partir da Configuração Padrão JSON
  --   contida na tabela emigParametrizacao, realizando:
  --     - Inclusão ou atualização os Valores de Referencia na tabela epagValorReferencia
  --     - Importação das Versões dos Valores de Referencia
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino IN VARCHAR2: Sigla do agrupamento de destino para os dados
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
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15)          := Null;
    vsgModulo              CONSTANT CHAR(3)      := 'PAG';
    vsgConceito            CONSTANT VARCHAR2(20) := 'VALORREFERENCIA';
    vtpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(50)          := Null;
    vcdValorReferenciaNova NUMBER                := Null;

    vnuInseridos           NUMBER         := 0;
    vnuAtualizados         NUMBER         := 0;
    vtxResumo              VARCHAR2(4000) := NULL;
    vResumoEstatisticas    CLOB           := Null;
    vListaTabelas          CLOB := '[
      "EPAGBASECALCULO",
      "EPAGBASECALCULOVERSAO",
      "EPAGHISTBASECALCULO",
      "EPAGBASECALCULOBLOCO",
      "EPAGBASECALCULOBLOCOEXPRESSAO",
      "EPAGBASECALCBLOCOEXPRRUBAGRUP"
    ]';

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
      
    -- Cursor que extrai e transforma os dados JSON dos Valores de Referencia
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
      
      JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes
      
      FROM emigParametrizacao cfg
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
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(cfg.sgOrgao,' ')
      LEFT JOIN epagValorReferencia vlref on vlref.cdAgrupamento = o.cdAgrupamento AND vlref.sgValorReferencia = js.sgValorReferencia
      WHERE cfg.sgModulo = 'PAG' AND cfg.sgConceito = 'VALORREFERENCIA' AND cfg.flAnulado = 'N'
        AND cfg.sgAgrupamento = psgAgrupamentoOrigem AND nvl(o.sgOrgao,' ') = nvl(vsgOrgao,' ')
      )
      SELECT * FROM ValorReferencia;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;
    vnuInseridos := 0;
    vnuAtualizados := 0;

    PKGMIG_Parametrizacao.PConsoleLog('Inicio da Importação das Parametrizações dos ' ||
      'Valores de Referencia do Agrupamento ' || psgAgrupamentoOrigem || ' ' ||
      'para o Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_Parametrizacao.PConsoleLog('Nível de Auditoria Habilitado ' ||
          CASE pnuNivelAuditoria
            WHEN cAUDITORIA_SILENCIADO THEN 'SILENCIADO'
            WHEN cAUDITORIA_ESSENCIAL  THEN 'ESSENCIAL'
            WHEN cAUDITORIA_DETALHADO  THEN 'DETALHADO'
            WHEN cAUDITORIA_COMPLETO   THEN 'COMPLETO'
            ELSE 'ESSENCIAL'
          END, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

    -- Loop principal de processamento para Incluir os Valores de Referencia
    FOR r IN cDados LOOP
  
      vsgOrgao := r.cdOrgao;
      vcdIdentificacao := r.sgValorReferencia;
  
      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

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
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'VALOR REFERENCIA', 'INCLUSAO', 'Valor de Referencia incluido com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'VALOR REFERENCIA', 'ATUALIZACAO', 'Valor de Referencia atualizado com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Excluir Versões e Vigências do Valor de Referencia
      pExcluirVersoesVigencias(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdValorReferenciaNova, pnuNivelAuditoria);

      -- Importar Versões do Valor de Referencia
      pImportarVersoes(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdValorReferenciaNova, r.Versoes, pnuNivelAuditoria);

      COMMIT;

    END LOOP;

    -- Gerar as Estatísticas da Importação dos Valores de Referencia
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 
      'Agrupamento ' || psgAgrupamentoOrigem || ' para o ' ||
      'Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Operação  ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Operação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	    'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	    'Total de Parametrizações dos Valores de Referencia Incluídas: ' || vnuInseridos ||
      ' e Alteradas: ' || vnuAtualizados;

    PKGMIG_Parametrizacao.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Exportação dos Valores de Referencia
    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'VALORES REFERENCIA', 'RESUMO', 'Importação das Parametrizações dos Valores de Referencia do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação dos Valores de Referencia
    PKGMIG_Parametrizacao.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_Parametrizacao.PConsoleLog('Termino da Importação das Parametrizações dos Valores de Referencia do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VALOR REFERENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALOR REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pExcluirVersoesVigencias(
  -- ###########################################################################
  -- PROCEDURE: pExcluirVersoesVigencias
  -- Objetivo:
  --   Excluir as Versões e Vigencias do Valor de Referencia do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
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
    pcdValorReferencia    IN NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - ' ||
      'Excluir Versões e Vigencias ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'VIGENCIA', 'EXCLUSAO', 'Vigências do Valore de Referencia excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
	  END IF;

    -- Excluir as Versões do Valore Referencia
	  SELECT COUNT(*) INTO vnuRegistros FROM epagValorReferenciaVersao Versoes
      WHERE Versoes.cdValorReferencia = pcdValorReferencia;

	  IF vnuRegistros > 0 THEN
      DELETE FROM epagValorReferenciaVersao Versoes
        WHERE Versoes.cdValorReferencia = pcdValorReferencia;

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'VERCAO', 'EXCLUSAO', 'Versões do Valore de Referencia excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
	  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' EXCLUIR VALOR REFERENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VALOR REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pExcluirVersoesVigencias;

  PROCEDURE pImportarVersoes(
  -- ###########################################################################
  -- PROCEDURE: pImportarVersoes
  -- Objetivo:
  --   Importar dados das Versões do Valor de Referencia do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
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
    pcdValorReferencia    IN NUMBER,
    pVersoes              IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
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
      js.nuVersao,

      JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias

      FROM JSON_TABLE(pVersoes, '$[*]' COLUMNS (
        nuVersao  PATH '$.nuVersao',
        Vigencias CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - Versões ' ||
      vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Versões do Valor de Referencia
    FOR r IN cDados LOOP

	    vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuVersao,1,70);

      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - Versões ' || vcdIdentificacao,
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);

	    -- Inserir na tabela epagBaseCalculoVersao
	    SELECT NVL(MAX(cdValorReferenciaVersao), 0) + 1 INTO vcdValorReferenciaVersaoNova FROM epagValorReferenciaVersao;

      INSERT INTO epagValorReferenciaVersao (
	      cdValorReferenciaVersao, cdValorReferencia, nuVersao
      ) VALUES (
		    vcdValorReferenciaVersaoNova, pcdValorReferencia, r.nuVersao
      );

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VERCAO', 'INCLUSAO', 'Versão do Valor de Referencia incluido com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Vigências da Formula de Cálculo
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdValorReferenciaVersaoNova, r.Vigencias, pnuNivelAuditoria);
  
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VERCAO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VERCAO', 'ERRO', 'Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVersoes;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências do Valor de Referencia do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
  --   pnuNivelAuditoria        IN NUMBER DEFAULT NULL:
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
    pnuNivelAuditoria        IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := NULL;
    vcdHistFormulaCalculoNova  NUMBER := NULL;
    vnuRegistros               NUMBER := 0;
    vvlReferencia              NUMBER := NULL;

    -- Cursor que extrai as Vigências das Bases do Documento pVigencias JSON
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
      Vigencias as (
      SELECT
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

      FROM JSON_TABLE(pVigencias, '$[*]' COLUMNS (
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
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = o.cdAgrupamento
                                               AND tabgeral.cdValorGeralCEFAgrup = js.sgValorGeralCEFAgrup
      )
      SELECT * FROM Vigencias;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
        lpad(r.nuAnoInicioVigencia,4,0) || lpad(r.nuMesInicioVigencia,2,0),1,70);

      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - ' ||
        'Vigências ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      -- Verificar se existe a Tabela Geral de Salarios dos Cargos Efetivos no Agrupamento Destino
      IF r.cdValorGeralCEFAgrup IS NULL AND r.sgValorGeralCEFAgrup IS NOT NULL THEN
        PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia  - Vigências ' || vcdIdentificacao ||
          ' Sigla da Tabela Geral CEF' || ' (' || r.sgValorGeralCEFAgrup || ') ' ||
          'da Vigência do Valor de Referencia não encontrada no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'VIGENCIA', 'INCONSISTENTE',
          'Sigla da Tabela Geral CEF' || ' (' || r.sgValorGeralCEFAgrup || ') ' ||
          'da Vigência do Valor de Referencia não encontrada no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Verificar se vlReferncia é Numerico e formatar para número.
      IF NOT REGEXP_LIKE(TO_CHAR(r.vlReferencia), '^[-+]?\d+(\.\d+)?$') THEN
        PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia - Vigências ' || vcdIdentificacao ||
          'Valor da Referencia é não numerico ou nulo (' || TO_CHAR(r.vlReferencia) || ')',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'VIGENCIA', 'INCONSISTENTE',
          ' Valor da Referencia é não numerico ou nulo (' || TO_CHAR(r.vlReferencia) || ')',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
          
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VIGENCIA', 'INCLUSAO', 'Vigência do Valor de Referencia incluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação do Valor de Referencia ' || vcdIdentificacao ||
        ' VIGENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações dos Valores de Referencia
  FUNCTION fnCursorValoresReferencia(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR
    ) RETURN SYS_REFCURSOR IS

    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Valores de Referencia de um Agrupamento
      WITH
      VigenciasValorReferencia AS (
      SELECT vigencia.cdValorReferenciaVersao,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuAnoMesInicioVigencia'  VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0),
          'nuAnoMesFimVigencia'     VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia,2,0),
          'Valor'                   VALUE
            CASE WHEN vigencia.vlReferencia IS NULL AND vigencia.qtValorReferencia IS NULL
                  AND vigencia.nuPercentual IS NULL AND vigencia.inTipoReferencia  IS NULL
                 THEN NULL
            ELSE JSON_OBJECT(
            'vlReferencia'          VALUE vigencia.vlReferencia,
            'qtValorReferencia'     VALUE vigencia.qtValorReferencia,
            'nuPercentual'          VALUE vigencia.nuPercentual,
            'inTipoReferencia'      VALUE DECODE(vigencia.inTipoReferencia,
                                            'V', 'Valor', 'I', 'Índice', 
                                            vigencia.inTipoReferencia)
          ABSENT ON NULL) END,
          'TabelaGeral'             VALUE
            CASE WHEN vigencia.cdValorGeralCEFAgrup IS NULL AND vigencia.nuNivel IS NULL AND vigencia.nuReferencia IS NULL
                 THEN NULL
            ELSE JSON_OBJECT(
            'sgTabelaValorGeralCEF' VALUE tabgeral.sgTabelaValorGeralCEF,
            'nuNivel'               VALUE vigencia.nuNivel,
            'nuReferencia'          VALUE vigencia.nuReferencia
          ABSENT ON NULL) END
        ABSENT ON NULL) ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0) DESC RETURNING CLOB
      ) AS Vigencias
      FROM epagHistValorReferencia vigencia
      INNER JOIN epagValorReferenciaVersao versao ON versao.cdValorReferenciaVersao = vigencia.cdValorReferenciaVersao
      INNER JOIN epagValorReferencia vlref ON vlref.cdValorReferencia = versao.cdValorReferencia
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = vlref.cdAgrupamento
                                               AND tabgeral.cdValorGeralCEFAgrup = vigencia.cdValorGeralCEFAgrup
      GROUP BY vigencia.cdValorReferenciaVersao
      ),
      VersaoValorReferencia AS (
      SELECT versao.cdValorReferencia,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuVersao'                VALUE versao.nuVersao,
          'Vigencias'               VALUE vigencia.Vigencias
        ABSENT ON NULL RETURNING CLOB)
        ORDER BY to_number(versao.nuVersao) RETURNING CLOB) AS Versoes
      FROM epagValorReferenciaVersao versao
      LEFT JOIN VigenciasValorReferencia vigencia ON vigencia.cdValorReferenciaVersao = versao.cdValorReferenciaVersao
      GROUP BY versao.cdValorReferencia
      ),
      ValorReferencia AS (
      SELECT a.sgAgrupamento, vlref.sgValorReferencia,
        JSON_OBJECT(
          'PAG' VALUE JSON_OBJECT(
            'ValorReferencia' VALUE JSON_OBJECT(
              'sgValorReferencia'          VALUE vlref.sgValorReferencia,
              'nmValorReferencia'          VALUE vlref.nmValorReferencia,
              'Parametrizacao'             VALUE
                CASE WHEN NULLIF(vlref.flValeTransporte, 'N')      IS NULL AND NULLIF(vlref.flCorrecaoMonetaria, 'N')      IS NULL
                      AND NULLIF(vlref.flBloqueioRemuneracao, 'N') IS NULL AND NULLIF(vlref.flPermiteValorRetroativo, 'N') IS NULL
                      AND NULLIF(vlref.flTetoAuxilioFuneral, 'N')  IS NULL
                      THEN NULL
                ELSE JSON_OBJECT(
                'flValeTransporte'         VALUE NULLIF(vlref.flValeTransporte, 'N'),
                'flCorrecaoMonetaria'      VALUE NULLIF(vlref.flCorrecaoMonetaria, 'N'),
                'flBloqueioRemuneracao'    VALUE NULLIF(vlref.flBloqueioRemuneracao, 'N'),
                'flPermiteValorRetroativo' VALUE NULLIF(vlref.flPermiteValorRetroativo, 'N'),
                'flTetoAuxilioFuneral'     VALUE NULLIF(vlref.flTetoAuxilioFuneral, 'N')
              ABSENT ON NULL RETURNING CLOB) END,
              'Versoes'                    VALUE versao.Versoes
            ABSENT ON NULL RETURNING CLOB) ABSENT ON NULL RETURNING CLOB)
        ABSENT ON NULL RETURNING CLOB) AS ValorReferencia
      FROM epagValorReferencia vlref
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = vlref.cdAgrupamento
      LEFT JOIN VersaoValorReferencia versao ON versao.cdValorReferencia = vlref.cdValorreferencia
	    WHERE a.sgAgrupamento = psgAgrupamento
      )
      SELECT
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        sgValorReferencia AS cdIdentificacao,
        vlref.ValorReferencia AS jsConteudo,
		pnuVersao AS nuVersao,
		pflAnulado AS flAnulado,
		SYSTIMESTAMP AS dtInclusao
      FROM ValorReferencia vlref
      ORDER BY sgagrupamento, sgorgao, sgModulo, sgConceito, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorValoresReferencia;

END PKGMIG_ParemetrizacaoValoresReferencia;
/