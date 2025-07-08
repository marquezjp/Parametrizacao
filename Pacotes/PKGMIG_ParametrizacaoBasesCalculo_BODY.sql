-- Corpo do Pacote de Importação das Parametrizações das Bases de Cálculo
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoBasesCalculo AS

  PROCEDURE pExportar(
  -- ###########################################################################
  -- PROCEDURE: PExportar
  -- Objetivo:
  --   Exportar as Parametrizações das Bases Cálculo para a Configuração Padrão JSON
  --   realizando:
  --     - Inclusão do Documento JSON Base na tabela emigConfigracaoPadrao
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   pcdIdentificacao      IN VARCHAR2: Código de Identificação do Conceito
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
    psgAgrupamento      IN VARCHAR2,
    pcdIdentificacao    IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria   IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15)          := Null;
    vsgModulo           CONSTANT CHAR(3)      := 'PAG';
    vsgConceito         CONSTANT VARCHAR2(20) := 'BASECALCULO';
    vtpOperacao         CONSTANT VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20)          := Null;
    vnuVersao           CONSTANT CHAR(04)     := '1.00';
    vflAnulado          CONSTANT CHAR(01)     := 'N';

    rsgAgrupamento      VARCHAR2(15) := NULL;
    rsgOrgao            VARCHAR2(15) := NULL;
    rsgModulo           CHAR(3)      := NULL;
    rsgConceito         VARCHAR2(20) := NULL;
    rdtExportacao       TIMESTAMP    := NULL;
    rcdIdentificacao    VARCHAR2(20) := NULL;
    rjsConteudo         CLOB         := NULL;
    rnuVersao           CHAR(04)     := NULL;
    rflAnulado          CHAR(01)     := NULL;
    rdtInclusao         TIMESTAMP(6) := NULL;

    vtxMensagem         VARCHAR2(100)  := NULL;
    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;
    vtxResumo           VARCHAR2(4000) := NULL;

    -- Cursor que extrai e transforma os dados JSON de Bases de Cálculo
    vRefCursor SYS_REFCURSOR;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;

    IF pcdIdentificacao IS NULL THEN
      vtxMensagem := 'Inicio da Exportação das Parametrizações das Bases de Cálculo ';
    ELSE
      vtxMensagem := 'Inicio da Exportação da Parametrização da Base de Cálculo "' || pcdIdentificacao || '" ';
    END IF;

    PKGMIG_ParametrizacaoLog.pAlertar(vtxMensagem ||
      'do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	    'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Nível de Auditoria Habilitado ' ||
          CASE pnuNivelAuditoria
            WHEN cAUDITORIA_SILENCIADO THEN 'SILENCIADO'
            WHEN cAUDITORIA_ESSENCIAL  THEN 'ESSENCIAL'
            WHEN cAUDITORIA_DETALHADO  THEN 'DETALHADO'
            WHEN cAUDITORIA_COMPLETO   THEN 'COMPLETO'
            ELSE 'ESSENCIAL'
          END, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

    -- Defini o Cursos com a Query que Gera o Documento JSON ValoresReferencia
    vRefCursor := fnCursorBases(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito, pcdIdentificacao, 
      vdtOperacao, vnuVersao, vflAnulado);
    
    vnuRegistros := 0;
    
    -- Loop principal de processamento
    LOOP
      FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
	      rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado, rdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      PKGMIG_ParametrizacaoLog.pAlertar('Exportação da Base ' || rcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      INSERT INTO emigParametrizacao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
        cdIdentificacao, jsConteudo, nuVersao, flAnulado
      ) VALUES (
        rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
		    rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado
      );

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, rcdIdentificacao, 1,
        'BASECALCULO', 'INCLUSAO', 'Documento JSON Bases incluído com sucesso',
		    cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    CLOSE vRefCursor;

    COMMIT;

    -- Gerar as Estatísticas da Exportação das Bases de Cálculo
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 'Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Exportação  ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	    'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	    'Total de Parametrizações de Bases de Cálculo Exportadas: ' || vnuRegistros;

    -- Registro de Resumo da Exportação das Bases de Cálculo
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'BASECALCULO', 'RESUMO', 'Exportação das Parametrizações das Bases de Cálculo do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pAlertar('Termino da Exportação das Parametrizações Bases de Cálculo do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 'BASE CALCULO',
        'Exportação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pExportar)', SQLERRM);
    RAISE;
  END pExportar;

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados das Bases de Cálculo a partir da Configuração Padrão JSON
  --   contida na tabela emigParametrizacao, realizando:
  --     - Inclusão ou atualização das Bases de Cálculo na tabela epagBaseCalculo
  --     - Importação das Versões das Bases
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
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15)          := Null;
    vsgModulo              CONSTANT CHAR(3)      := 'PAG';
    vsgConceito            CONSTANT VARCHAR2(20) := 'BASECALCULO';
	  vtpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
	  vdtOperacao            TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(70)          := Null;
    vcdBaseCalculoNova     NUMBER                := Null;

    vtxMensagem            VARCHAR2(100)  := NULL;
    vnuInseridos           NUMBER         := 0;
    vnuAtualizados         NUMBER         := 0;
    vtxResumo              VARCHAR2(4000) := NULL;
    vListaTabelas          CLOB := '[
      "EPAGBASECALCULO",
      "EPAGBASECALCULOVERSAO",
      "EPAGHISTBASECALCULO",
      "EPAGBASECALCULOBLOCO",
      "EPAGBASECALCULOBLOCOEXPRESSAO",
      "EPAGBASECALCBLOCOEXPRRUBAGRUP"
    ]';
    
    vdtTermino             TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao       INTERVAL DAY TO SECOND := NULL;
      
    -- Cursor que extrai e transforma os dados JSON das Bases
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
 
      JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes

      FROM emigParametrizacao cfg
      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO
      CROSS APPLY JSON_TABLE(cfg.jsConteudo, '$.PAG.BaseCalulo' COLUMNS (
        sgBaseCalculo PATH '$.sgBaseCalculo',
        nmBaseCalculo PATH '$.nmBaseCalculo',
        Versoes       CLOB FORMAT JSON PATH '$.Versoes'
      )) js
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(cfg.sgOrgao,' ')
      LEFT JOIN epagBaseCalculo base on base.cdAgrupamento = o.cdAgrupamento and base.sgBaseCalculo = js.sgBaseCalculo
      WHERE cfg.sgModulo = vsgModulo AND cfg.sgConceito = vsgConceito AND cfg.flAnulado = 'N'
        AND cfg.sgAgrupamento = psgAgrupamentoOrigem AND cfg.sgOrgao IS NULL
        AND (cfg.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
      )
      SELECT * FROM BasesCalculo;
      
  BEGIN
    
    vdtOperacao := LOCALTIMESTAMP;
    vnuInseridos := 0;
    vnuAtualizados := 0;

    IF pcdIdentificacao IS NULL THEN
      vtxMensagem := 'Inicio da Importação das Parametrizações das Bases de Cálculo ';
    ELSE
      vtxMensagem := 'Inicio da Importação da Parametrização da Base de Cálculo "' || pcdIdentificacao || '" ';
    END IF;

    PKGMIG_ParametrizacaoLog.pAlertar(vtxMensagem ||
      'do Agrupamento ' || psgAgrupamentoOrigem || ' ' ||
      'para o Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Nível de Auditoria Habilitado ' ||
          CASE pnuNivelAuditoria
            WHEN cAUDITORIA_SILENCIADO THEN 'SILENCIADO'
            WHEN cAUDITORIA_ESSENCIAL  THEN 'ESSENCIAL'
            WHEN cAUDITORIA_DETALHADO  THEN 'DETALHADO'
            WHEN cAUDITORIA_COMPLETO   THEN 'COMPLETO'
            ELSE 'ESSENCIAL'
          END, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

    -- Loop principal de processamento
    FOR r IN cDados LOOP
  
      vsgOrgao := r.cdOrgao;
      vcdIdentificacao := r.cdIdentificacao;
  
      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - Base ' || vcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

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
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'BASE CALCULO', 'INCLUSAO', 'Base de Cálculo incluidas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'BASE CALCULO', 'ATUALIZACAO', 'Base de Cálculo atualizada com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Excluir Versões e Vigências do Valor de Referencia
      pExcluirBaseCalculo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdBaseCalculoNova, pnuNivelAuditoria);

      -- Importar Versões da Base de Cálculo
      pImportarVersoes(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdBaseCalculoNova, r.Versoes, pnuNivelAuditoria);
      
      COMMIT;

    END LOOP;

    -- Gerar as Estatísticas da Importação das Bases de Cálculo
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
	  'Total de Parametrizações das Bases de Cálculo Incluídas: ' || vnuInseridos ||
      ' e Alteradas: ' || vnuAtualizados;

    PKGMIG_ParametrizacaoLog.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Importação dos Valores de Referencia
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'RESUMO', 'RESUMO', 'Importação das Parametrizações das Bases de Cálculo do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação das Bases de Cálculo
    PKGMIG_ParametrizacaoLog.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pAlertar('Termino da Importação das Parametrizações das Bases de Cálculo do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 'BASE CALCULO',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pImportar)', SQLERRM);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pExcluirBaseCalculo(
  -- ###########################################################################
  -- PROCEDURE: pExcluirBaseCalculo
  -- Objetivo:
  --   Excluir Bases de Cálculo do Documento Versões JSON
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
  --   pcdBaseCalculo        IN NUMBER: 
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
    pcdBaseCalculo        IN NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - ' ||
      'Excluir Base de Cálculo ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Excluir as Expressões das Rubricas dos Blocos da Base de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagBaseCalcBlocoExprRubAgrup
      WHERE cdBaseCalculoBlocoExpressao IN (
        SELECT Expressao.cdBaseCalculoBlocoExpressao FROM epagBaseCalculoBlocoExpressao Expressao
        INNER JOIN epagBaseCalculoBloco Blocos ON Blocos.cdBaseCalculoBloco = Expressao.cdBaseCalculoBloco
        INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    IF vnuRegistros > 0 THEN

      DELETE FROM epagBaseCalcBlocoExprRubAgrup
        WHERE cdBaseCalculoBlocoExpressao IN (
          SELECT Expressao.cdBaseCalculoBlocoExpressao FROM epagBaseCalculoBlocoExpressao Expressao
          INNER JOIN epagBaseCalculoBloco Blocos ON Blocos.cdBaseCalculoBloco = Expressao.cdBaseCalculoBloco
          INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
          INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
            WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO GRUPO RUBRICAS', 'EXCLUSAO', 'Grupo de Rubricas do Blocos da Base de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir a Expressão da Base de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagBaseCalculoBlocoExpressao
      WHERE cdBaseCalculoBloco IN (
        SELECT Blocos.cdBaseCalculoBloco FROM epagBaseCalculoBloco Blocos
        INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    IF vnuRegistros > 0 THEN

      DELETE FROM epagBaseCalculoBlocoExpressao
        WHERE cdBaseCalculoBloco IN (
          SELECT Blocos.cdBaseCalculoBloco FROM epagBaseCalculoBloco Blocos
          INNER JOIN epagHistBaseCalculo Vigencia ON Vigencia.cdHistBaseCalculo = Blocos.cdHistBaseCalculo
          INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
            WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO EXPRESSAO BLOCO', 'EXCLUSAO', 'Expressão do Bloco da Base de Cálculo excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Blocos da Base de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagBaseCalculoBloco
      WHERE cdHistBaseCalculo IN (
        SELECT Vigencia.cdHistBaseCalculo FROM epagHistBaseCalculo Vigencia
        INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    IF vnuRegistros > 0 THEN

      DELETE FROM epagBaseCalculoBloco
        WHERE cdHistBaseCalculo IN (
          SELECT Vigencia.cdHistBaseCalculo FROM epagHistBaseCalculo Vigencia
          INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
            WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO BLOCOS', 'EXCLUSAO', 'Blocos da Base de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Documentos das Vigências da Base de Cálculo
    vnuRegistros := 0;
    FOR d IN (
      SELECT Vigencia.cdHistBaseCalculo, Vigencia.cdDocumento FROM epagHistBaseCalculo Vigencia
      INNER JOIN epagBaseCalculoVersao Versao ON Versao.cdVersaoBaseCalculo = Vigencia.cdVersaoBaseCalculo
        WHERE Versao.cdBaseCalculo = pcdBaseCalculo AND Vigencia.cdDocumento IS NOT NULL
    ) LOOP

      UPDATE epagHistBaseCalculo Vigencia SET Vigencia.cdDocumento = NULL
        WHERE Vigencia.cdHistBaseCalculo = d.cdHistBaseCalculo;

      vnuRegistros := vnuRegistros + 1;

      DELETE FROM eatoDocumento
        WHERE cdDocumento = d.cdDocumento;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'BASE CALCULO DOCUMENTO', 'EXCLUSAO', 'Documentos de Amparo ao Fato da Base de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END LOOP;      

    -- Excluir as Vigências da Base de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistBaseCalculo
      WHERE cdVersaoBaseCalculo IN (
        SELECT Versao.cdVersaoBaseCalculo FROM epagBaseCalculoVersao Versao
          WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

    IF vnuRegistros > 0 THEN

      DELETE FROM epagHistBaseCalculo
        WHERE cdVersaoBaseCalculo IN (
          SELECT Versao.cdVersaoBaseCalculo FROM epagBaseCalculoVersao Versao
            WHERE Versao.cdBaseCalculo = pcdBaseCalculo);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO VIGENCIA', 'EXCLUSAO', 'Vigências da Base de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Versões da Base de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagBaseCalculoVersao
      WHERE cdBaseCalculo = pcdBaseCalculo;

    IF vnuRegistros > 0 THEN

      DELETE FROM epagBaseCalculoVersao
        WHERE cdBaseCalculo = pcdBaseCalculo;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO VERCAO', 'EXCLUSAO', 'Versões da Base de Cálculo excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 'BASE CALCULO EXCLUIR',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pExcluirBaseCalculo)', SQLERRM);
    RAISE;
  END pExcluirBaseCalculo;

  PROCEDURE pImportarVersoes(
  -- ###########################################################################
  -- PROCEDURE: pImportarVersoes
  -- Objetivo:
  --   Importar dados das Versões da Base do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
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
    pcdBaseCalculo        IN NUMBER,
    pVersoes              IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao         VARCHAR2(70) := Null;
    vcdVersaoBaseCalculoNova NUMBER := 0;
    vnuRegistros             NUMBER := 0;

    -- Cursor que extrai as Versões das Bases do Documento Versões JSON
    CURSOR cDados IS
      WITH
      Versoes as (
      SELECT
--        (SELECT NVL(MAX(cdVersaoBaseCalculo),0) + 1 FROM epagBaseCalculoVersao) AS cdVersaoBaseCalculo,
--        pcdBaseCalculo as cdBaseCalculo,
        js.nuVersao,
        SYSTIMESTAMP AS dtUltAlteracao,

        JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias

      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO.Versoes[*]
      FROM JSON_TABLE(pVersoes, '$[*]' COLUMNS (
        nuVersao  PATH '$.nuVersao',
        Vigencias CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      )
      SELECT * FROM Versoes;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'BASE CALCULO VERCAO', 'JSON', SUBSTR(pVersoes,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

   	  vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuversao,1,70);
   
      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - Versões ' ||
        vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
   
   	  -- Inserir na tabela epagBaseCalculoVersao
   	  SELECT NVL(MAX(cdVersaoBaseCalculo), 0) + 1 INTO vcdVersaoBaseCalculoNova FROM epagBaseCalculoVersao;

      INSERT INTO epagBaseCalculoVersao (
   	    cdVersaoBaseCalculo, cdBaseCalculo, nuVersao, dtUltAlteracao
      ) VALUES (
   		  vcdVersaoBaseCalculoNova, pcdBaseCalculo, r.nuversao, r.dtultalteracao
      );

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO VERCAO', 'INCLUSAO', 'Versão da Base incluida com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
   
      -- Importar Vigências da Base de Cálculo
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdVersaoBaseCalculoNova, r.Vigencias, pnuNivelAuditoria);
     
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 'BASE CALCULO VERCAO',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pImportarVersoes)', SQLERRM);
    RAISE;
  END pImportarVersoes;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências da Base do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
    pcdVersaoBaseCalculo  IN NUMBER,
    pVigencias            IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao           VARCHAR2(70) := Null;
    vcdHistBaseCalculoNova     NUMBER       := Null;
    vcdDocumentoNovo           NUMBER       := Null;
    vnuRegistros               NUMBER       := 0;

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
      
      JSON_SERIALIZE(TO_CLOB(js.Blocos) RETURNING CLOB) AS Blocos

      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO.Versoes[*].Vigencias[*].Vigencia
      FROM JSON_TABLE(pVigencias, '$[*].Vigencia' COLUMNS (
        nuAnoMesInicioVigencia      PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia         PATH '$.nuAnoMesFimVigencia',
        deFormula                   PATH '$.Expressao.deFormula',
        deExpressaoCalculo          PATH '$.Expressao.deExpressaoCalculo',
        deLimiteInferior            PATH '$.Expressao.Limites.deLimiteInferior',
        deLimiteSuperior            PATH '$.Expressao.Limites.deLimiteSuperior',
        nmValorReferenciaInferior   PATH '$.Expressao.Limites.nmValorReferenciaInferior',
        nuQtdeValReferenciaInferior PATH '$.Expressao.Limites.nuQtdeValReferenciaInferior',
        nmValorReferenciaSuperior   PATH '$.Expressao.Limites.nmValorReferenciaSuperior',
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
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagValorReferencia vlrefinf ON vlrefinf.cdAgrupamento = o.cdAgrupamento
                                            AND vlrefinf.nmValorReferencia = js.nmValorReferenciaInferior
      LEFT JOIN epagValorReferencia vlrefsup ON vlrefsup.cdAgrupamento = o.cdAgrupamento
                                            AND vlrefsup.nmValorReferencia = js.nmValorReferenciaSuperior
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      )
      SELECT * FROM Vigencias;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'BASE CALCULO VIGENCIA', 'JSON', SUBSTR(pVigencias,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
        lpad(r.nuAnoInicioVigencia,4,0) || lpad(r.nuMesInicioVigencia,2,0),1,70);
       
      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - Vigências ' || vcdIdentificacao,
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

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

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'BASE CALCULO DOCUMENTO', 'INCLUSAO', 'Documentos de Amparo ao Fato da Base de Cálculo incluidas com sucesso',
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
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

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO VIGENCIA', 'INCLUSAO', 'Vigência da Base incluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Blocos da Base de Cálculo
      pImportarBlocos(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdHistBaseCalculoNova, r.Blocos, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 'BASE CALCULO VIGENCIA',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pImportarVigencias)', SQLERRM);
    RAISE;
  END pImportarVigencias;
    
  PROCEDURE pImportarBlocos(
  -- ###########################################################################
  -- PROCEDURE: pImportarBlocos
  -- Objetivo:
  --   Importar os Blocos Base de Cálculo contida no Documento Blocos JSON
  --     na tabela emigParametrizacao, realizando:
  --     - Inclusão dos Blocos da Base na tabela epagBaseCalculoBloco
  --     - Importar Expressão do Bloco
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino   IN VARCHAR2:
  --   psgOrgao                IN VARCHAR2: 
  --   ptpOperacao             IN VARCHAR2:
  --   pdtOperacao             IN TIMESTAMP:
  --   psgModulo               IN CHAR: 
  --   psgConceito             IN VARCHAR2: 
  --   pcdIdentificacao        IN VARCHAR2: 
  --   pcdHistBaseCalculo      IN NUMBER:
  --   pBlocos                 IN CLOB: 
  --   pnuNivelAuditoria                IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino   IN VARCHAR2,
    psgOrgao                IN VARCHAR2,
    ptpOperacao             IN VARCHAR2,
    pdtOperacao             IN TIMESTAMP,
    psgModulo               IN CHAR,
    psgConceito             IN VARCHAR2,
    pcdIdentificacao        IN VARCHAR2,
    pcdHistBaseCalculo      IN NUMBER,
    pBlocos                 IN CLOB,
    pnuNivelAuditoria       IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao        VARCHAR2(70) := Null;
    vcdBaseCalculoBlocoNova NUMBER       := Null;
    vnuRegistros            NUMBER       := 0;

    -- Cursor que extrai as Vigências da Rubrica do Agrupamento do Documento pVigencias Agrupamento JSON
    CURSOR cDados IS
      WITH
      Blocos AS (
      SELECT 
      js.sgBloco,
      SYSTIMESTAMP AS dtUltAlteracao,

      JSON_SERIALIZE(TO_CLOB(js.ExpressaoBloco) RETURNING CLOB) AS ExpressaoBloco

      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO.Versoes[*].Vigencias[*].Vigencia.Blocos[*]
      FROM JSON_TABLE(pBlocos, '$[*]' COLUMNS (
        sgBloco        PATH '$.sgBloco',
        ExpressaoBloco CLOB FORMAT JSON PATH '$.Expressao'
      )) js
      )
      SELECT * FROM Blocos;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'BASE CALCULO BLOCOS', 'JSON', SUBSTR(pBlocos,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Verões da Base
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgbloco,1,70);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - Blocos ' || vcdIdentificacao,
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      SELECT NVL(MAX(cdBaseCalculoBloco), 0) + 1 INTO vcdBaseCalculoBlocoNova FROM epagBaseCalculoBloco;

      INSERT INTO epagBaseCalculoBloco (
	    cdBaseCalculoBloco, cdhistbasecalculo, sgbloco, dtultalteracao
      ) VALUES (
        vcdBaseCalculoBlocoNova, pcdHistBaseCalculo, r.sgbloco, r.dtultalteracao
      );

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO BLOCOS', 'INCLUSAO', 'Inclusão dos Blocos da Base incluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - Blocos ' || vcdIdentificacao,
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      -- Importar Expressão do Bloco da Base de Cálculo
      pImportarExpressaoBloco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdBaseCalculoBlocoNova, r.ExpressaoBloco, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 'BASE CALCULO BLOCOS',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pImportarBlocos)', SQLERRM);
    RAISE;
  END pImportarBlocos;

  PROCEDURE pImportarExpressaoBloco(
  -- ###########################################################################
  -- PROCEDURE: pImportarExpressaoBloco
  -- Objetivo:
  --   Importar a Expressão do Bloco Base de Cálculo contida no
  --     Documento Expressão do Bloco JSON na tabela emigParametrizacao,
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
  --   pnuNivelAuditoria                 IN NUMBER DEFAULT NULL:
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
    pExpressaoBloco       IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao                 VARCHAR2(70) := Null;
    vcdBaseCalculoBlocoExpressaoNova NUMBER   := Null;
    vnuRegistros                     NUMBER   := 0;

    -- Cursor que extrai a Expressão do Base de Cálculo do Documento pExpressaoBloco JSON
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
      rub.cdRubricaAgrupamento, rub.nuRubrica,
      js.nuMesRubrica,
      js.nuAnoRubrica,
      vlref.cdValorReferencia, js.nmValorReferencia,
      baseexp.cdBaseCalculo, js.sgBaseCalculo,
      tabgeral.cdValorGeralCEFAgrup, js.sgTabelaValorGeralCEF,
      cef.cdEstruturaCarreira as cdEstruturaCarreira, js.nmEstruturaCarreira,
      NULL as cdFuncaoChefia,
      js.deNivel,
      js.deReferencia,
      js.deCodigoCCO,
      NULL as cdTipoAdicionalTempServ,
      
      SYSTIMESTAMP AS dtUltAlteracao,
      
      (SELECT JSON_ARRAYAGG(JSON_OBJECT(
         'nuRubrica' VALUE SUBSTR(js.nuRubrica,1,7),
         'cdRubricaAgrupamento' VALUE rub.cdRubricaAgrupamento
       RETURNING CLOB) RETURNING CLOB) AS GRP
      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO.Versoes[*].Vigencias[*].Vigencia.Blocos[*].Expressao.GrupoRubricas[*]
       FROM JSON_TABLE(js.GrupoRubricas, '$[*]' COLUMNS (nuRubrica PATH '$')) js
       LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,1,7)
                                 AND rub.cdAgrupamento = o.cdAgrupamento
      ) As GrupoRubricas
      
      -- Caminho Absoluto no Documento JSON
      -- $.PAG.BASECALCULO.Versoes[*].Vigencias[*].Vigencia.Blocos[*].Expressao
      FROM JSON_TABLE(pExpressaoBloco, '$' COLUMNS (
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
        nmEstruturaCarreira     PATH '$.CarreiraCargo',
      --  cdFuncaoChefia        PATH '$.cdFuncaoChefia',
        deNivel                 PATH '$.deNivel',
        deReferencia            PATH '$.deReferencia',
        deCodigoCCO             PATH '$.deCodigoCCO',
      --  cdTipoAdicionalTempServ PATH '$.cdTipoAdicionalTempServ',
      
        GrupoRubricas           CLOB FORMAT JSON PATH '$.GrupoRubricas'
      )) js
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagTipoMneumonico mneu ON mneu.sgTipoMneumonico = js.sgTipoMneumonico
      LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,1,7)
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

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'BASE CALCULO EXPRESSAO BLOCO', 'JSON', SUBSTR(pExpressaoBloco,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir a Expressão do Bloco da Base de Cálculo
    vnuRegistros := 0;
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgTipoMneumonico,1,70);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - ' ||
        'Expressão do Bloco ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

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

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'BASE CALCULO EXPRESSAO BLOCO', 'INCLUSAO', 'Expressão do Bloco da Base de Cálculo incluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - ' ||
        'Grupo de Rubricas ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

	  -- Incluir Incluir o Grupo de Rubricas do Bloco da Base de Cálculo
      FOR i IN (
        SELECT js.nuRubrica, js.cdRubricaAgrupamento
          FROM json_table(r.GrupoRubricas, '$[*]' COLUMNS (
            nuRubrica            PATH '$.nuRubrica',
            cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
          )) js
      ) LOOP

        PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - ' ||
          'Grupo de Rubrica - RUBRICA ' || vcdIdentificacao || ' ' || i.nuRubrica,
          cAUDITORIA_COMPLETO, pnuNivelAuditoria);

        IF i.cdRubricaAgrupamento IS NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação da Base de Cálculo - ' ||
            'Rubrica do Grupo do Bloco da Base de Cálculo Inexistente no Agrupamento ' || vcdIdentificacao || ' ' || i.nuRubrica,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || i.nuRubrica,1,70), 1,
            'BASE CALCULO GRUPO RUBRICAS', 'INCONSISTENTE', 'Rubrica do Grupo do Bloco da Base de Cálculo Inexistente no Agrupamento',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        ELSE
          INSERT INTO epagBaseCalcBlocoExprRubAgrup VALUES (vcdBaseCalculoBlocoExpressaoNova, i.cdRubricaAgrupamento);

          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || i.nuRubrica,1,70), 1,
            'BASE CALCULO GRUPO RUBRICAS', 'INCLUSAO', 'Rubrica do Grupo do Bloco da Base de Cálculo incluidas com sucesso',
            cAUDITORIA_DETALHADO, pnuNivelAuditoria);
        END IF;
      
      END LOOP;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 'BASE CALCULO EXPRESSAO BLOCO',
        'Importação de Bases de Cálculo (PKGMIG_ParametrizacaoBasesCalculo.pImportarExpressaoBloco)', SQLERRM);
    RAISE;
  END pImportarExpressaoBloco;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações das Bases de Cálculo
  FUNCTION fnCursorBases(
    psgAgrupamento   IN VARCHAR2,
    psgOrgao         IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2,
    pdtExportacao    IN TIMESTAMP,
    pnuVersao        IN CHAR,
    pflAnulado       IN CHAR
    ) RETURN SYS_REFCURSOR IS

    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito das Bases de um Agrupamento
      WITH
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
      BlocoExpressaoRubricas AS (
      SELECT rubrica.cdBaseCalculoBlocoExpressao,
        JSON_ARRAYAGG(rub.nuRubrica || ' ' || rub.deRubrica
        ORDER BY rub.nuRubrica RETURNING CLOB) AS GrupoRubricas
      FROM epagBaseCalcBlocoExprRubAgrup rubrica
      LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = rubrica.cdRubricaAgrupamento
      GROUP BY rubrica.cdBaseCalculoBlocoExpressao
      ),
      BlocoExpressao AS (
      SELECT blexp.cdBaseCalculoBlocoExpressao, blexp.cdBaseCalculoBloco, mneu.sgTipoMneumonico,
        JSON_OBJECT(
          'sgTipoMneumonico'      VALUE mneu.sgTipoMneumonico,
          'deOperacao'            VALUE blexp.deOperacao,
          'inTipoRubrica'         VALUE DECODE(blexp.inTipoRubrica,
                                          'I', 'Valor Integral',
                                          'P', 'Valor Pago',
                                          'R', 'Valor Real',
                                          blexp.inTipoRubrica),
          'inRelacaoRubrica'      VALUE DECODE(blexp.inRelacaoRubrica,
                                          'R', 'Relação de Trabalho',
                                          'S', 'Somatório',
                                          blexp.inRelacaoRubrica),
          'inMes'                 VALUE DECODE(blexp.inMes,
                                          'AT', 'Valor Referente ao Mês Atual',
                                          'AN', 'Valor Referente ao Mês Anterior',
                                          blexp.inMes),
          'nuMeses'               VALUE blexp.nuMeses,
          'nuValor'               VALUE blexp.nuValor,
          'inTipoRetorno'         VALUE blexp.inTipoRetorno,
          'inValorHoraMinuto'     VALUE blexp.inValorHoraMinuto,
          'nuRubrica'             VALUE
            CASE WHEN rub.nuRubrica IS NULL THEN NULL
            ELSE rub.nuRubrica || ' ' || rub.deRubrica END,
          'nuMesRubrica'          VALUE blexp.nuMesRubrica,
          'nuAnoRubrica'          VALUE blexp.nuAnoRubrica,
          'nmValorReferencia'     VALUE vlref.nmValorReferencia,
          'sgBaseCalculo'         VALUE baseexp.sgBaseCalculo,
          'sgTabelaValorGeralCEF' VALUE tabgeral.sgTabelaValorGeralCEF,
          'nmEstruturaCarreira'   VALUE cef.nmEstruturaCarreira,
          -- 'cdFuncaoChefia'     VALUE cdFuncaoChefia,
          'deNivel'               VALUE blexp.deNivel,
          'deReferencia'          VALUE blexp.deReferencia,
          'deCodigoCCO'           VALUE blexp.deCodigoCCO,
          -- 'cdtipoadicionaltempserv' VALUE cdtipoadicionaltempserv,
          'GrupoRubricas'         VALUE gruporub.GrupoRubricas
        ABSENT ON NULL RETURNING CLOB) AS expressao
      FROM epagBaseCalculoBlocoExpressao blexp
      INNER JOIN epagBaseCalculoBloco bloco ON bloco.cdBaseCalculoBloco = blexp.cdBaseCalculoBloco
      INNER JOIN epagHistBaseCalculo vigencia ON vigencia.cdHistBaseCalculo = bloco.cdHistBaseCalculo
      INNER JOIN epagBaseCalculoVersao versao ON  versao.cdVersaoBaseCalculo = vigencia.cdVersaoBaseCalculo
      INNER JOIN epagBaseCalculo base ON base.cdBaseCalculo = versao.cdBaseCalculo
      LEFT JOIN epagTipoMneumonico mneu ON mneu.cdTipoMneumonico = blexp.cdTipoMneumonico
      LEFT JOIN BlocoExpressaoRubricas gruporub ON gruporub.cdBaseCalculoBlocoExpressao = blexp.cdBaseCalculoBlocoExpressao
      LEFT JOIN epagValorReferencia vlref ON vlref.cdAgrupamento = base.cdAgrupamento AND vlref.cdValorReferencia = blexp.cdValorReferencia
      LEFT JOIN epagBaseCalculo baseexp ON baseexp.cdAgrupamento = base.cdAgrupamento AND baseexp.cdBaseCalculo = blexp.cdBaseCalculo
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = base.cdAgrupamento AND tabgeral.cdValorGeralCEFAgrup = blexp.cdValorGeralCEFAgrup
      LEFT JOIN EstruturaCarreiraLista cef ON cef.cdEstruturaCarreira = blexp.cdEstruturaCarreira
      LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = blexp.cdRubricaAgrupamento
      ),
      Blocos AS (
      SELECT bl.cdHistBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'sgBloco'               VALUE bl.sgBloco,
          'Expressao'             VALUE blexp.Expressao
        RETURNING CLOB) ORDER BY bl.sgBloco RETURNING CLOB) AS Blocos
      FROM epagBaseCalculoBloco bl
      LEFT JOIN BlocoExpressao blexp ON blexp.cdBaseCalculoBloco = bl.cdBaseCalculoBloco
      GROUP BY bl.cdHistBaseCalculo
      ),
      Vigencias AS (
      SELECT vigencia.cdVersaoBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'Vigencia' VALUE JSON_OBJECT(
            'nuAnoMesInicioVigencia' VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0),
            'nuAnoMesFimVigencia'    VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia,2,0),
            'Expressao' VALUE JSON_OBJECT(
              'deFormula'            VALUE vigencia.deFormula,
              'deExpressaoCalculo'   VALUE vigencia.deExpressaoCalculo,
              'Blocos'               VALUE bl.Blocos,
              'Limites' VALUE
                CASE WHEN 
                  vigencia.deLimiteInferior IS NULL AND vigencia.deLimiteSuperior IS NULL AND
                  vigencia.cdValorReferenciaInferior IS NULL AND vigencia.nuQtdeValReferenciaInferior IS NULL AND
                  vigencia.cdValorReferenciaSuperior IS NULL AND vigencia.nuQtdeValReferenciaSuperior IS NULL
                  THEN NULL
                ELSE JSON_OBJECT(
                  'deLimiteInferior'            VALUE vigencia.deLimiteInferior,
                  'deLimiteSuperior'            VALUE vigencia.deLimiteSuperior,
                  'nmValorReferenciaInferior'   VALUE vlrefinf.nmValorReferencia,
                  'nuQtdeValReferenciaInferior' VALUE vigencia.nuQtdeValReferenciaInferior,
                  'nmValorReferenciaSuperior'   VALUE vlrefsup.nmValorReferencia,
                  'nuQtdeValReferenciaSuperior' VALUE vigencia.nuQtdeValReferenciaSuperior
              ABSENT ON NULL) END,
              'Documento' VALUE
                CASE WHEN doc.nuAnoDocumento IS NULL AND vigencia.cdTipoPublicacao IS NULL AND
                  doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
                  vigencia.cdMeioPublicacao IS NULL AND vigencia.cdTipoPublicacao IS NULL AND
                  vigencia.dtPublicacao IS NULL AND vigencia.nuPublicacao IS NULL AND vigencia.nuPagInicial IS NULL AND
                  vigencia.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
                  THEN NULL
                ELSE JSON_OBJECT(
                  'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
                  'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
                  'dtDocumento'                 VALUE doc.dtDocumento,
                  'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
                  'deObservacao'                VALUE doc.deObservacao,
                  'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
                  'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
                  'dtPublicacao'                VALUE vigencia.dtPublicacao,
                  'nuPublicacao'                VALUE vigencia.nuPublicacao,
                  'nuPagInicial'                VALUE vigencia.nuPagInicial,
                  'deOutroMeio'                 VALUE vigencia.deOutroMeio,
                  'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
                  'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
                  ABSENT ON NULL) END
            ABSENT ON NULL RETURNING CLOB) 
          ABSENT ON NULL RETURNING CLOB)
        ABSENT ON NULL RETURNING CLOB)
        ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0) desc RETURNING CLOB) AS Vigencias
      FROM epagHistBaseCalculo vigencia
      INNER JOIN epagBaseCalculoVersao versao ON  versao.cdVersaoBaseCalculo = vigencia.cdVersaoBaseCalculo
      INNER JOIN epagBaseCalculo base ON base.cdBaseCalculo = versao.cdBaseCalculo
      LEFT JOIN epagValorReferencia vlrefinf ON vlrefinf.cdAgrupamento = base.cdAgrupamento AND vlrefinf.cdValorReferencia = vigencia.cdValorReferenciaInferior
      LEFT JOIN epagValorReferencia vlrefsup ON vlrefsup.cdAgrupamento = base.cdAgrupamento AND vlrefsup.cdValorReferencia = vigencia.cdValorReferenciaSuperior
      LEFT JOIN Blocos bl ON bl.cdHistBaseCalculo = vigencia.cdHistBaseCalculo
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = vigencia.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = vigencia.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = vigencia.cdTipoPublicacao
      GROUP BY vigencia.cdVersaoBaseCalculo
      ),
      Versoes AS (
      SELECT versao.cdBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuVersao' VALUE LPAD(versao.nuVersao,2,0),
          'Vigencias' VALUE Vigencias.Vigencias
        ABSENT ON NULL RETURNING CLOB)
      ORDER BY versao.nuVersao RETURNING CLOB) AS Versoes
      FROM epagBaseCalculoVersao versao
      LEFT JOIN Vigencias ON Vigencias.cdVersaoBaseCalculo = versao.cdVersaoBaseCalculo
      GROUP BY versao.cdBaseCalculo
      ),
      Bases AS (
      SELECT a.sgAgrupamento, o.sgOrgao, base.sgBaseCalculo,
      JSON_OBJECT(
        'PAG' value JSON_OBJECT(
          'BaseCalulo' value JSON_OBJECT(
            'sgBaseCalculo' VALUE base.sgBaseCalculo,
            'nmBaseCalculo' VALUE base.nmBaseCalculo,
            'Versoes' VALUE Versoes.Versoes
          ABSENT ON NULL RETURNING CLOB)
        RETURNING CLOB) RETURNING CLOB) AS Base
      FROM epagBaseCalculo base
      LEFT JOIN Versoes ON Versoes.cdBaseCalculo = base.cdBaseCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = base.cdAgrupamento
      LEFT JOIN ecadHistOrgao o ON o.cdOrgao = base.cdOrgao
      WHERE a.sgAgrupamento = psgAgrupamento
        AND (sgBaseCalculo LIKE pcdIdentificacao OR pcdIdentificacao IS NULL)
      )
      SELECT
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        sgBaseCalculo AS cdIdentificacao,
        Base AS jsConteudo,
        pnuVersao AS nuVersao,
        pflAnulado AS flAnulado,
        SYSTIMESTAMP AS dtInclusao
      FROM Bases
      ORDER BY sgagrupamento, sgorgao, sgModulo, sgConceito, cdIdentificacao;
    
      RETURN vRefCursor;
  END fnCursorBases;

END PKGMIG_ParametrizacaoBasesCalculo;
/
