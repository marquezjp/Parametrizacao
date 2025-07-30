-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoRubricasAgrupamento AS

  FUNCTION fnExportar(
  -- ###########################################################################
  -- FUNCTION: pExportar
  -- Objetivo:
  --   Exportar as Parametrizações das Rubricas do Agrupamento para a Configuração Padrão JSON,
  --     realizando:
  --     - Gera o Documento JSON Rubricas Agrupamento
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2: Sigla do agrupamento de origem da configuração
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
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) RETURN tpParametrizacaoTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15) := NULL;
    csgModulo           CONSTANT CHAR(3)      := 'PAG';
    csgConceito         CONSTANT VARCHAR2(20) := 'RUBRICA';
    ctpOperacao         CONSTANT VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20) := NULL;
    vjsConteudo         CLOB         := NULL;

    rsgAgrupamento      VARCHAR2(15) := NULL;
    rsgOrgao            VARCHAR2(15) := NULL;
    rcdIdentificacao    VARCHAR2(20) := NULL;
    rjsConteudo         CLOB         := NULL;

    vtxMensagem         VARCHAR2(100) := NULL;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas do Agrupamento
    vRefCursor SYS_REFCURSOR;

    BEGIN

      vdtOperacao := LOCALTIMESTAMP;

      IF pcdIdentificacao IS NULL THEN
        vtxMensagem := 'Inicio da Exportação das Parametrizações das Rubricas do Agrupamento ';
      ELSE
        vtxMensagem := 'Inicio da Exportação da Parametrização da Rubrica do Agrupamento "' || pcdIdentificacao || '" ';
      END IF;

      IF psgAgrupamento IS NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
          'Agrupamento não Informado.');
      ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamento) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
          'Agrupamento Informado não Cadastrado.: "' || SUBSTR(psgAgrupamento,1,50) || '".');
      END IF;

      PKGMIG_ParametrizacaoLog.pAlertar(vtxMensagem ||
        'do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	      'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

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

	    -- Defini o Cursos com a Query que Gera o Documento JSON Rubricas
	    vRefCursor := fnCursorRubricasAgrupamento(psgAgrupamento, pcdIdentificacao);

      -- Loop principal de processamento
	    LOOP
        FETCH vRefCursor INTO rsgAgrupamento, rcdIdentificacao, rjsConteudo;
        EXIT WHEN vRefCursor%NOTFOUND;

        PKGMIG_ParametrizacaoLog.pAlertar('Exportação da Rubrica do Agrupamento ' || rcdIdentificacao,
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);

        PIPE ROW (tpParametrizacao(
          rsgAgrupamento, vsgOrgao, csgModulo, csgConceito, rcdIdentificacao, rjsConteudo
        ));
      END LOOP;
      RETURN;

      CLOSE vRefCursor;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, ctpOperacao, vdtOperacao,  
          csgModulo, csgConceito, vcdIdentificacao, 'RUBRICA AGRUPAMENTO',
          'Exportação de Rubrica (PKGMIG_ParametrizacaoRubricasAgrupamento.fnExportar)', SQLERRM);
      ROLLBACK;
      RAISE;
  END fnExportar;

  FUNCTION fnExportarParametroTributacao(
  -- ###########################################################################
  -- FUNCTION: fnExportarParametroTributacao
  -- Objetivo:
  --   Exportar as Parametrizações dos Parâmetros de Tributação das Rubricas do Agrupamento
  --     para a Configuração Padrão JSON, realizando:
  --     - Gera o Documento JSON Parâmetros de Tributação
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2: Sigla do agrupamento de origem da configuração
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
    psgAgrupamento        IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) RETURN tpParametrizacaoTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15) := NULL;
    csgModulo           CONSTANT CHAR(3)      := 'PAG';
    csgConceito         CONSTANT VARCHAR2(20) := 'RUBRICA';
    ctpOperacao         CONSTANT VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20) := NULL;
    vjsConteudo         CLOB         := NULL;

    rsgAgrupamento      VARCHAR2(15) := NULL;
    rsgOrgao            VARCHAR2(15) := NULL;
    rcdIdentificacao    VARCHAR2(20) := NULL;
    rjsConteudo         CLOB         := NULL;

    vtxMensagem         VARCHAR2(100) := NULL;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Tributações
    vRefCursor SYS_REFCURSOR;

    BEGIN

      vdtOperacao := LOCALTIMESTAMP;

      IF psgAgrupamento IS NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
          'Agrupamento não Informado.');
      ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamento) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
          'Agrupamento Informado não Cadastrado.: "' || SUBSTR(psgAgrupamento,1,50) || '".');
      END IF;

	    -- Defini o Cursos com a Query que Gera o Documento JSON Rubricas
	    vRefCursor := fnCursorParametroTributacao(psgAgrupamento, pcdIdentificacao);

      -- Loop principal de processamento
	    LOOP
        FETCH vRefCursor INTO rsgAgrupamento, rcdIdentificacao, rjsConteudo;
        EXIT WHEN vRefCursor%NOTFOUND;

        PKGMIG_ParametrizacaoLog.pAlertar('Exportação dos Parametros da Tributação da Rubrica do Agrupamento ' || rcdIdentificacao,
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);

        PIPE ROW (tpParametrizacao(
          rsgAgrupamento, vsgOrgao, csgModulo, csgConceito, rcdIdentificacao, rjsConteudo
        ));
      END LOOP;
      RETURN;

      CLOSE vRefCursor;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, ctpOperacao, vdtOperacao,  
          csgModulo, csgConceito, vcdIdentificacao, 'RUBRICA AGRUPAMENTO',
          'Exportação de Tributação (PKGMIG_ParametrizacaoRubricasAgrupamento.fnExportarParametroTributacao)', SQLERRM);
      ROLLBACK;
      RAISE;
  END fnExportarParametroTributacao;

  PROCEDURE pImportarRubricaAgrupamento(
  -- ###########################################################################
  -- PROCEDURE: pImportarRubricaAgrupamento
  -- Objetivo:
  --   Importar dados das Rubricas do Agrupamento Origem para o Agrupamento Destino
  --     do Documento Agrupamento JSON contido na tabela emigParametrizacao,
  --     realizando:
  --     - Inclusão ou atualização de Rubricas do Agrupamento na
  --       tabela epagRubricaAgrupamento
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica
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
  --   pcdRubrica            IN NUMBER: 
  --   pAgrupamento          IN CLOB: 
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
    pcdRubrica            IN NUMBER,
    pAgrupamento          IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao          VARCHAR2(70) := Null;
    vcdRubricaAgrupamentoNova NUMBER := Null;
    vnuRegistros              NUMBER := 0;

    -- Cursor que extrai do as Rubricas do Agrupamento Origem para o Agrupamento Destino do Documento pAgrupamento JSON
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
      epagRubricaAgrupamentoImportar AS (
      SELECT
      rubagp.cdRubricaAgrupamento,
      NULL AS cdRubricaAgrupamentoOrigem,
      o.cdAgrupamento,
      o.cdOrgao,
      pcdRubrica AS cdRubrica,
      
      NVL(js.flIncorporacao, 'N') AS flIncorporacao,
      NVL(js.flPensaoAlimenticia, 'N')AS flPensaoAlimenticia,
      NVL(js.flAdiant13Pensao, 'N') AS flAdiant13Pensao,
      NVL(js.fl13SalPensao, 'N') AS fl13SalPensao,
      NVL(js.flConsignacao, 'N') AS flConsignacao,
      NVL(js.flTributacao, 'N') AS flTributacao,
      NVL(js.flSalarioFamilia, 'N') AS flSalarioFamilia,
      NVL(js.flSalarioMaternidade, 'N') AS flSalarioMaternidade,
      NVL(js.flDevTributacaoIPREV, 'N') AS flDevTributacaoIPREV,
      NVL(js.flDevCorrecaoMonetaria, 'N') AS flDevCorrecaoMonetaria,
      NVL(js.flAbonoPermanencia, 'N') AS flAbonoPermanencia,
      NVL(js.flApostilamento, 'N') AS flApostilamento,
      NVL(js.flContribuicaoSindical, 'N') AS flContribuicaoSindical,

      modRub.cdModalidadeRubrica AS cdModalidadeRubrica, js.nmModalidadeRubrica,
      baseCalc.cdBaseCalculo AS cdBaseCalculo, js.sgBaseCalculo,

      NVL(js.flVisivelServidor, 'S') AS flVisivelServidor, -- DEFAULT S
      NVL(js.flGeraSuplementar, 'S') AS flGeraSuplementar, -- DEFAULT S
      NVL(js.flConsad, 'N') AS flConsad,
      NVL(js.flCompoe13, 'N') AS flCompoe13,
      NVL(js.flPropria13, 'N') AS flPropria13,
      NVL(js.flEmpenhadaFilial, 'N') AS flEmpenhadaFilial,

      js.nuElemDespesaAtivo AS nuElemDespesaAtivo,
      js.nuElemDespesaInativo AS nuElemDespesaInativo,
      js.nuElemDespesaAtivoCLT AS nuElemDespesaAtivoCLT,
      js.nuOrdemConsad AS nuOrdemConsad,

      JSON_SERIALIZE(TO_CLOB(js.VigenciasAgrupamento) RETURNING CLOB) AS VigenciasAgrupamento,
      JSON_SERIALIZE(TO_CLOB(js.Consignacao) RETURNING CLOB) AS Consignacao,
      JSON_SERIALIZE(TO_CLOB(js.EventosPagamento) RETURNING CLOB) AS EventosPagamento,
      JSON_SERIALIZE(TO_CLOB(js.FormulaCalculo) RETURNING CLOB) AS FormulaCalculo,

      SYSTIMESTAMP AS dtUltAlteracao

      -- Caminho Absoluto no Documento JSON
      -- $.PAG.Rubrica.Tipos[*].Agrupamento
      FROM JSON_TABLE(pAgrupamento, '$' COLUMNS (
        flIncorporacao         PATH '$.RubricaPropria.flIncorporacao',
        flPensaoAlimenticia    PATH '$.RubricaPropria.flPensaoAlimenticia',
        flAdiant13Pensao       PATH '$.RubricaPropria.flAdiant13Pensao',
        fl13SalPensao          PATH '$.RubricaPropria.fl13SalPensao',
        flConsignacao          PATH '$.RubricaPropria.flConsignacao',
        flTributacao           PATH '$.RubricaPropria.flTributacao',
        flSalarioFamilia       PATH '$.RubricaPropria.flSalarioFamilia',
        flSalarioMaternidade   PATH '$.RubricaPropria.flSalarioMaternidade',
        flDevTributacaoIPREV   PATH '$.RubricaPropria.flDevTributacaoIPREV',
        flDevCorrecaoMonetaria PATH '$.RubricaPropria.flDevCorrecaoMonetaria',
        flAbonoPermanencia     PATH '$.RubricaPropria.flAbonoPermanencia',
        flApostilamento        PATH '$.RubricaPropria.flApostilamento',
        flContribuicaoSindical PATH '$.RubricaPropria.flContribuicaoSindical',

        nmModalidadeRubrica    PATH '$.ParametrosAgrupamento.nmModalidadeRubrica',
        sgBaseCalculo          PATH '$.ParametrosAgrupamento.sgBaseCalculo',
        flVisivelServidor      PATH '$.ParametrosAgrupamento.flVisivelServidor',
        flGeraSuplementar      PATH '$.ParametrosAgrupamento.flGeraSuplementar',
        flConsad               PATH '$.ParametrosAgrupamento.flConsad',
        flCompoe13             PATH '$.ParametrosAgrupamento.flCompoe13',
        flPropria13            PATH '$.ParametrosAgrupamento.flPropria13',
        flEmpenhadaFilial      PATH '$.ParametrosAgrupamento.flEmpenhadaFilial',

        nuElemDespesaAtivo     PATH '$.ParametrosAgrupamento.nuElemDespesaAtivo',
        nuElemDespesaInativo   PATH '$.ParametrosAgrupamento.nuElemDespesaInativo',
        nuElemDespesaAtivoCLT  PATH '$.ParametrosAgrupamento.nuElemDespesaAtivoCLT',
        nuOrdemConsad          PATH '$.ParametrosAgrupamento.nuOrdemConsad',
      
        VigenciasAgrupamento   CLOB FORMAT JSON PATH '$.VigenciasAgrupamento',
        Consignacao            CLOB FORMAT JSON PATH '$.Consignacao',
        EventosPagamento       CLOB FORMAT JSON PATH '$.Eventos',
        FormulaCalculo         CLOB FORMAT JSON PATH '$.Formula'
      )) js
      INNER JOIN OrgaoLista o ON o.sgAgrupamento = psgAgrupamentoDestino AND NVL(o.sgOrgao, ' ') = NVL(psgOrgao, ' ')
      LEFT JOIN epagRubricaAgrupamento rubAgp ON rubAgp.cdAgrupamento = o.cdAgrupamento AND rubAgp.cdRubrica = pcdRubrica
      LEFT JOIN epagModalidadeRubrica modRub ON UPPER(modRub.nmModalidadeRubrica) = UPPER(js.nmModalidadeRubrica)
      LEFT JOIN epagBaseCalculo baseCalc ON baseCalc.cdAgrupamento = o.cdAgrupamento AND NVL(baseCalc.cdOrgao, 0) = NVL(o.cdOrgao, 0)
                                        AND baseCalc.sgBaseCalculo = js.sgBaseCalculo
      )
      SELECT * FROM epagRubricaAgrupamentoImportar;

    BEGIN
  
      vcdIdentificacao := pcdIdentificacao;

      IF psgAgrupamentoDestino IS NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
          'Agrupamento não Informado.');
      ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamentoDestino) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
          'Agrupamento Informado não Cadastrado.: "' || SUBSTR(psgAgrupamentoDestino,1,50) || '".');
      END IF;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, pcdIdentificacao, 0,
        'RUBRICA AGRUPAMENTO', 'JSON', SUBSTR(pAgrupamento,1,4000),
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      -- Incluir Consignatárias
--      PKGMIG_ParametrizacaoConsignacoes.pImportarConsignatarias(psgAgrupamentoOrigem, psgAgrupamentoDestino,
--        vsgOrgao, ctpOperacao, vdtOperacao,
--        csgModulo, csgConceito, pcdIdentificacao, pnuNivelAuditoria);

      -- Incluir Tipos de Serviços
--      PKGMIG_ParametrizacaoConsignacoes.pImportarTipoServicos(psgAgrupamentoOrigem, psgAgrupamentoDestino,
--        vsgOrgao, ctpOperacao, vdtOperacao,
--        csgModulo, csgConceito, pcdIdentificacao, pnuNivelAuditoria);

      -- Loop principal de processamento
      FOR r IN cDados LOOP
  
        vcdIdentificacao := pcdIdentificacao;
         
        PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - Rubrica Agrupamento ' || vcdIdentificacao,
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
  
        IF r.cdModalidadeRubrica IS NULL AND r.nmModalidadeRubrica IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - Rubrica Agrupamento - ' ||
            vcdIdentificacao || ' ' || r.nmModalidadeRubrica ||
            'Modalidade da Rubrica do Agrupamento Inexistente ',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmModalidadeRubrica, 1,
            'RUBRICA AGRUPAMENTO', 'INCONSISTENTE',
            'Modalidade da Rubrica do Agrupamento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdBaseCalculo IS NULL AND r.sgBaseCalculo IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - Rubrica Agrupamento - ' ||
            vcdIdentificacao || ' ' || r.sgBaseCalculo ||
            'Base de Cálculo da Rubrica do Agrupamento Inexistente ',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.sgBaseCalculo, 1,
            'RUBRICA AGRUPAMENTO', 'INCONSISTENTE',
            'Base de Cálculo da Rubrica do Agrupamento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdrubricaagrupamento IS NULL THEN
          -- Incluir Nova Rubrica de Agrupamento
          SELECT NVL(MAX(cdrubricaAgrupamento), 0) + 1 INTO vcdRubricaAgrupamentoNova FROM epagRubricaAgrupamento;
  
          INSERT INTO epagRubricaAgrupamento (
            cdRubricaAgrupamento, cdRubrica, cdRubricaAgrupamentoOrigem, cdAgrupamento, cdOrgao,
            cdModalidadeRubrica, cdBaseCalculo,
            flEmpenhadaFilial, flIncorporacao, flPensaoAlimenticia, flTributacao, flConsignacao,
            dtUltAlteracao, flSalarioFamilia, flSalarioMaternidade, flDevTributacaoIPREV,
            flDevCorrecaoMonetaria, nuElemDespesaAtivo, nuElemDespesaInativo, flVisivelServidor,
            nuElemDespesaAtivoCLT, flGeraSuplementar, flAdiant13Pensao, fl13SalPensao,
            flConsad, nuOrdemConsad, flCompoe13, flAbonoPermanencia,
            flContribuicaoSindical, flApostilamento, flPropria13
          ) VALUES (
            vcdRubricaAgrupamentoNova, r.cdRubrica, r.cdRubricaAgrupamentoOrigem, r.cdAgrupamento, r.cdOrgao,
            r.cdModalidadeRubrica, r.cdBaseCalculo,
            r.flEmpenhadaFilial, r.flIncorporacao, r.flPensaoAlimenticia, r.flTributacao, r.flConsignacao,
            r.dtUltAlteracao, r.flSalarioFamilia, r.flSalarioMaternidade, r.flDevTributacaoIPREV,
            r.flDevCorrecaoMonetaria, r.nuElemDespesaAtivo, r.nuElemDespesaInativo, r.flVisivelServidor,
            r.nuElemDespesaAtivoClt, r.flGeraSuplementar, r.flAdiant13Pensao,
            r.fl13SalPensao, r.flConsad, r.nuOrdemConsad, r.flCompoe13, r.flAbonoPermanencia,
            r.flContribuicaoSindical, r.flApostilamento, r.flPropria13 
          );
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'RUBRICA AGRUPAMENTO', 'INCLUSAO', 'Rubrica do Agrupamento Incluídas com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        ELSE
          -- Atualizar Rubrica do Agrupamento Existente
          vcdRubricaAgrupamentoNova := r.cdRubricaAgrupamento;
  
          UPDATE epagRubricaAgrupamento SET
            cdRubricaAgrupamentoOrigem = r.cdRubricaAgrupamentoOrigem,
            cdAgrupamento = r.cdAgrupamento,
            cdOrgao = r.cdOrgao,
            cdRubrica = r.cdRubrica,
            cdModalidadeRubrica = r.cdModalidadeRubrica,
            cdBaseCalculo = r.cdBaseCalculo,
            flEmpenhadaFilial = r.flEmpenhadaFilial,
            flIncorporacao = r.flIncorporacao,
            flPensaoAlimenticia = r.flPensaoAlimenticia,
            flTributacao = r.flTributacao,
            flConsignacao = r.flConsignacao,
            dtUltAlteracao = r.dtUltAlteracao,
            flSalarioFamilia = r.flSalarioFamilia,
            flSalarioMaternidade = r.flSalarioMaternidade,
            flDevTributacaoIprev = r.flDevTributacaoIprev,
            flDevCorrecaoMonetaria = r.flDevCorrecaoMonetaria,
            nuElemDespesaAtivo = r.nuElemDespesaAtivo,
            nuElemDespesaInativo = r.nuElemDespesaInativo,
            flVisivelServidor = r.flVisivelServidor,
            nuElemDespesaAtivoCLT = r.nuElemDespesaAtivoCLT,
            flGeraSuplementar = r.flGeraSuplementar,
            flAdiant13Pensao = r.flAdiant13Pensao,
            fl13SalPensao = r.fl13SalPensao,
            flConsad = r.flConsad,
            nuOrdemConsad = r.nuOrdemConsad,
            flCompoe13 = r.flCompoe13,
            flAbonoPermanencia = r.flAbonoPermanencia,
            flContribuicaoSindical = r.flContribuicaoSindical,
            flApostilamento = r.flApostilamento,
            flPropria13 = r.flPropria13
          WHERE cdRubricaAgrupamento = vcdRubricaAgrupamentoNova;
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'RUBRICA AGRUPAMENTO', 'ATUALIZACAO', 'Rubrica do Agrupamento atualizada com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;
  
        -- Excluir da Rubrica do Agrupamento e as Entidades Filhas
        pExcluirRubricaAgrupamento(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, pnuNivelAuditoria);

        -- Importar Vigências da Rubrica do Agrupamento
        pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.VigenciasAgrupamento, pnuNivelAuditoria);

        -- Importar Consignações da Rubrica do Agrupamento
--        PKGMIG_ParametrizacaoConsignacoes.pImportarConsignacao(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
--          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.Consignacao, pnuNivelAuditoria);

        -- Importar Eventos de Pagamento da Rubrica do Agrupamento
--        PKGMIG_ParametrizacaoEventosPagamento.pImportarEventos(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
--          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.EventosPagamento, pnuNivelAuditoria);

        -- Importar Formulas de Calculo da Rubrica do Agrupamento
--        PKGMIG_ParametrizacaoFormulasCalculo.pImportarFormulaCalculo(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
--          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.FormulaCalculo, pnuNivelAuditoria);
  
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
      PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 'RUBRICA AGRUPAMENTO',
        'Importação de Rubrica (PKGMIG_ParametrizacaoRubricasAgrupamento.pImportarRubricaAgrupamento)', SQLERRM);
      RAISE;
  END pImportarRubricaAgrupamento;

  PROCEDURE pExcluirRubricaAgrupamento(
  -- ###########################################################################
  -- PROCEDURE: pExcluirRubricaAgrupamento
  -- Objetivo:
  --   Excluir as Entidades filhas da Rubrica do Agrupamento
  --     - Exclusão da Lista de Carreiras
  --     - Exclusão da Lista de NiveisReferencias
  --     - Exclusão da Lista de CargosComissionados
  --     - Exclusão da Lista de FuncoesChefia
  --     - Exclusão da Lista de Programas
  --     - Exclusão da Lista de ModelosAposentadoria
  --     - Exclusão da Lista de CargasHorarias
  --     - Exclusão da Lista de Órgãos
  --     - Exclusão da Lista de UnidadesOrganizacionais
  --     - Exclusão da Lista de Naturezas do Vínculo Permitidos
  --     - Exclusão da Lista de Relações de Trabalho Permitidos
  --     - Exclusão da Lista de Regimes de Trabalho Permitidos
  --     - Exclusão da Lista de Regimes Previdenciários Permitidas
  --     - Exclusão da Lista de Situações Previdenciárias Permitidas
  --     - Exclusão da Lista de Motivos de Afastamento que Impedem
  --     - Exclusão da Lista de Motivos de Afastamento Exigidos
  --     - Exclusão da Lista de Motivos de Movimentação
  --     - Exclusão da Lista de Motivos de Convocação
  --     - Exclusão da Lista de Rubricas que Impedem
  --     - Exclusão da Lista de Rubricas Exigidas
  --     - Exclusão das Vigências da Rubricas do Agrupamento
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
    pcdRubricaAgrupamento IN NUMBER,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN
    
    vnuRegistros := 0;

    -- Excluir as Carreiras da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupCarreira
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupCarreira
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA CARREIRAS', 'EXCLUSAO',
        'Carreiras na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Níveis e Referencias da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupNivelRef
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupNivelRef
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NIVREF', 'EXCLUSAO',
        'Níveis e Referencias na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Cargos Comissionados da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupCCO
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupCCO
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA COMISSIONADOS', 'EXCLUSAO',
        'Cargos Comissiondos na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Unidades Organizacionais da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupUO
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupUO
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA UNID. ORG.', 'EXCLUSAO',
        'Unidades Organizacionais na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Motivos Afstamento que Impedem da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagRubAgrupMotAfastTempImp
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagRubAgrupMotAfastTempImp
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA AFAST. IMPEDEM', 'EXCLUSAO',
        'Motivos Afastamento que Impedem na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Motivos Afstamento Exigidos da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagRubAgrupMotAfastTempEx
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagRubAgrupMotAfastTempEx
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA AFAST. EXIGIDOS', 'EXCLUSAO',
        'Motivos Afastamento Exigidos na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Motivos Movimentação da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupMotMovi
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupMotMovi
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA MOT. MOVIMENTACAO', 'EXCLUSAO',
        'Motivos Movimentação na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Motivos Convocação da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupMotConv
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupMotConv
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA CONVOCACAO', 'EXCLUSAO',
        'Motivos Convocação na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Órgãos Permitidos da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupOrgao
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupOrgao
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA ORGAOS', 'EXCLUSAO',
        'Órgãos Permitidas na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Rubrica que Impedem da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupImpeditiva
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupImpeditiva
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUB. IMPEDEM', 'EXCLUSAO',
        'Rubricas que Impedem na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Rubrica Exigidas da Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupExigida
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupExigida
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUG. EXIGIDAS', 'EXCLUSAO',
        'Rubricas Exigidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Naturezas de Vinculo Permitidas Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupNatVinc
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupNatVinc
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'EXCLUSAO',
        'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Regimes Previdenciários Permitidas Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupregprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupregprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGPREV', 'EXCLUSAO',
        'Regimes Previdenciários Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir os Regimes de Trabalho Permitidas Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupregtrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupregtrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGTRAB', 'EXCLUSAO',
        'Regimes de Trabalho Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Relações de Trabalho Permitidas Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupreltrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupreltrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RELTRAB', 'EXCLUSAO',
        'Relações de Trabalho Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupsitprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupsitprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epagHistRubricaAgrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA SITPREV', 'EXCLUSAO',
        'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

     -- Excluir as Vigências existentes da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupamento
    WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupamento WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'EXCLUSAO',
        'Vigências existentes da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'RUBRICA AGRUPAMENTO VIGENCIA EXCLUIR',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricasAgrupamento.pExcluirRubricaAgrupamento)', SQLERRM);
      RAISE;
  END pExcluirRubricaAgrupamento;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar as Vigências das Rubricas do Agrupamento
  --   contida no Documento VigenciasAgrupamento JSON na tabela emigParametrizacao, realizando:
  --     - Inclusão das Vigência das Rubricas do Agrupamento
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
  --   pVigenciasAgrupamento IN CLOB: 
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
    pcdRubricaAgrupamento IN NUMBER,
    pVigenciasAgrupamento IN CLOB,
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao              VARCHAR2(70) := Null;
    vcdHistRubricaAgrupamentoNova NUMBER   := Null;
    vnuRegistros                  NUMBER   := 0;

    -- Cursor que extrai as Vigências da Rubrica do Agrupamento do Documento pVigenciasAgrupamento JSON
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
      -- CargoComissionadoLista: lista da Estrutura de Cargos Comissionados
      CargoComissionadoLista as (
      SELECT gp.cdAgrupamento, gp.cdGrupoOcupacional, cco.cdCargoComissionado, 
        a.sgAgrupamento, gp.nmGrupoOcupacional, vigencia.deCargoComissionado
      FROM ecadCargoComissionado cco
      INNER JOIN ecadGrupoOcupacional gp on gp.cdGrupoOcupacional = cco.cdGrupoOcupacional
      INNER JOIN ecadEvolucaoCargoComissionado vigencia on vigencia.cdCargoComissionado = cco.cdCargoComissionado
      INNER JOIN ecadAgrupamento a on a.cdAgrupamento = gp.cdAgrupamento
      UNION ALL
      SELECT gp.cdAgrupamento, gp.cdGrupoOcupacional, NULL AS cdCargoComissionado, 
      a.sgAgrupamento, gp.nmGrupoOcupacional, NULL AS deCargoComissionado
      FROM ecadGrupoOcupacional gp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = gp.cdAgrupamento
      ORDER BY cdAgrupamento, cdGrupoOcupacional, cdCargoComissionado NULLS FIRST
      ),
      MotivoAfastamentoLista AS (
      SELECT cdMotivoAfastTemporario,
      deMotivoAfastTemporario, nmGrupoMotivoAfastamento, DECODE(flRemunerado, 'S', 'REMUNERADO', 'NAO REMUNERADO') AS flRemunerado
      FROM (
        SELECT grupo.nmGrupoMotivoAfastamento, vigencia.deMotivoAfastTemporario, vigencia.flremunerado,
          afamot.cdMotivoAfastTemporario, vigencia.dtInicioVigencia,
          RANK () OVER(PARTITION By vigencia.cdMotivoAfastTemporario ORDER BY vigencia.dtInicioVigencia DESC) AS ordem
        FROM eafaHistMotivoAfastTemp vigencia
        LEFT JOIN eafaMotivoAfastTemporario afamot ON afamot.cdMotivoAfastTemporario = vigencia.cdMotivoAfastTemporario
        LEFT JOIN eafaGrupoMotivoAfastamento grupo ON grupo.cdGrupoMotivoAfastamento = vigencia.cdGrupoMotivoAfastamento
      ) WHERE ordem = 1
      ),
      epagHistRubricaAgrupamentoImportar as (
      SELECT
        (SELECT NVL(MAX(cdHistRubricaAgrupamento),0) FROM epagHistRubricaAgrupamento) + ROWNUM AS cdHistRubricaAgrupamento,
        pcdRubricaAgrupamento as cdRubricaAgrupamento,
      
        CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicioVigencia,
        CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicioVigencia,
        CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFimVigencia,
        CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFimVigencia,

        -- Dados da Rubrica
        js.deRubricaAgrupamento,
        js.deRubricaAgrupResumida,
        relTrabVigencia.cdRelacaoTrabalho as cdRelacaoTrabalho, js.nmRelacaoTrabalho,
        NVL(UPPER(js.flCargaHorariaPadrao), 'S') AS flCargaHorariaPadrao, -- DEFAULT S
        js.nuCargaHorariaSemanal,
        rubOutra.cdRubricaAgrupamento AS cdOutraRubrica, js.nuOutraRubrica,
        
        -- Inventario
        js.deRubricaAgrupDetalhada,
        js.deFormula,
        js.deModulo,
        js.deComposicao,
        js.deVantagensNaoAcumulaveis,
        js.deObservacao,
        
        -- Lancamento Financeiro
        DECODE(UPPER(js.inSePossuirValorInformado),
          'RELACAO VINCULO PRINCIPAL',               '1',
          'PARA CARGO COMISSIONADO',                 '2',
          'PARA SUBSTITUICAO DE CARGO COMISSIONADO', '3',
          'PARA ESPECIALIDADE COMO TITULAR',         '4',
          'PARA SUBSTITUICAO DE ESPECIALIDADE',      '5',
          'PARA APOSENTADORIA',                      '6',
          'PARA CARGO EFETIVO',                      '7',
          '1') AS inPossuiValorInformado,
        
        DECODE(UPPER(js.inLancPropRelVinc),
          'PARA PRINCIPAL',            '1',
          'PARA TODAS',                '2',
          'APENAS CARGO COMISSIONADO', '3',
          'APENAS FUNCAO DE CHEFIA',   '4',
          'APENAS APOSENTADORIA',      '5',
          '2') AS inLancPropRelVinc,
        
        NVL(UPPER(js.flBloqLancFinanc), 'N') AS flBloqLancFinanc,
        NVL(UPPER(js.flSuspensa), 'N') AS flSuspensa,
        NVL(UPPER(js.flSuspensaRetroativoErario), 'N') AS flSuspensaRetroativoErario,
        NVL(UPPER(js.flConsolidaRubrica), 'N') AS flConsolidaRubrica,
        NVL(UPPER(js.flPermiteAfastAcidente), 'N') AS flPermiteAfastAcidente,
        NVL(UPPER(js.flValidaSufixoPrecedenciaLF), 'N') AS flValidaSufixoPrecedenciaLF,
        
        -- Gerar Rubrica
        DECODE(UPPER(js.inGeraRubricaUO),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaUO,
        
        DECODE(UPPER(js.inGeraRubricaCarreira),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaCarreira,
        
        DECODE(UPPER(js.inGeraRubricaNivel),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaNivel,
        
        DECODE(UPPER(js.inGeraRubricaCCO),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaCCO,
        
        DECODE(UPPER(js.inGeraRubricaFUC),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaFUC,
        
        DECODE(UPPER(js.inGeraRubricaPrograma),
          'ALGUMAS IMPEDEM', '1',
          'ALGUMAS EXIGEM',  '2',
          'TODAS PERMITEM',  '3',
          'NENHUMA PERMITE', '4',
          '3') AS inGeraRubricaPrograma,
        
        DECODE(UPPER(js.inAposentadoriaServidor),
          'DEVE ESTAR APOSENTADO',              '1',
          'DEVE TER O DIREITO A APOSENTADORIA', '2',
          '2') AS inAposentadoriaServidor,
        
        DECODE(UPPER(js.inGeraRubricaAfastTemp),
          'MOTIVOS IMPEDEM',     '1',
          'MOTIVOS NAO IMPEDEM', '2',
          'NENHUM IMPEDE',       '3',
          '3') AS inGeraRubricaAfastTemp,
        
        DECODE(UPPER(js.inGeraRubricaMotMovi),
          'MOTIVOS IMPEDEM',     '1',
          'MOTIVOS NAO IMPEDEM', '2',
          'NENHUM IMPEDE',       '3',
          '3') AS inGeraRubricaMotMovi,
        
        NVL(UPPER(js.flPagaEfetivoOrgao), 'N') AS flPagaEfetivoOrgao,
        NVL(UPPER(js.flPagAposentadoria), 'N') AS flPagAposentadoria,
        NVL(UPPER(js.flLaudoAcompanhamento), 'N') AS flLaudoAcompanhamento,
        NVL(UPPER(js.flGeraRubricaCarreiraIncideApo), 'S') AS flGeraRubricaCarreiraIncideApo, -- DEFAULT S
        NVL(UPPER(js.flGeraRubricaCarreiraIncideCCO), 'S') AS flGeraRubricaCarreiraIncideCCO, -- DEFAULT S
        NVL(UPPER(js.flGeraRubricaCCOIncideCEF), 'S') AS flGeraRubricaCCOIncideCEF, -- DEFAULT S
        NVL(UPPER(js.flGeraRubricaFUCIncideCEF), 'N') AS flGeraRubricaFUCIncideCEF,
        NVL(UPPER(js.flGeraRubricaHoraExtra), 'N') AS flGeraRubricaHoraExtra,
        NVL(UPPER(js.flGeraRubricaEscala), 'N') AS flGeraRubricaEscala,
        NVL(UPPER(js.flGeraRubricaServCCO), 'N') AS flGeraRubricaServCCO,
        tpIndice.cdTipoIndice as cdTipoIndice, js.deTipoIndice,
        
        DECODE(UPPER(js.nmRubProporcionalidadeCHO),
          'NAO APLICAR',   '1',
          'APLICAR',       '2',
          'APLICAR MEDIA', '3',
          '1') AS cdRubProporcionalidadeCHO, js.nmRubProporcionalidadeCHO,
        
        js.nuMesesApuracao,
        NVL(UPPER(js.flPropMesComercial), 'S') AS flPropMesComercial, -- DEFAULT S
        NVL(UPPER(js.flCargaHorariaLimitada), 'N') AS flCargaHorariaLimitada,
        NVL(UPPER(js.flIgnoraAfastCEFAgPolitico), 'N') AS flIgnoraAfastCEFAgPolitico,
        NVL(UPPER(js.flIncidParcialContrPrev), 'N') AS flIncidParcialContrPrev,
        NVL(UPPER(js.flPagaMaiorRV), 'N') AS flPagaMaiorRV,
        NVL(UPPER(js.flPercentLimitado100), 'N') AS flPercentLimitado100,
        NVL(UPPER(js.flPercentReducaoAfastRemun), 'N') AS flPercentReducaoAfastRemun,
        NVL(UPPER(js.flPropServRelVinc), 'N') AS flPropServRelVinc,
        NVL(UPPER(js.flPropAfaComissionado), 'N') AS flPropAfaComissionado,
        NVL(UPPER(js.flPropAfaCCOSubst), 'N') AS flPropAfaCCOSubst,
        NVL(UPPER(js.flPropAfaComOpcPercCEF), 'N') AS flPropAfaComOpcPercCEF,
        NVL(UPPER(js.flPropAfaFGFTG), 'N') AS flPropAfaFGFTG,
        NVL(UPPER(js.flPropAfastTempNaoRemun), 'N') AS flPropAfastTempNaoRemun,
        NVL(UPPER(js.flPropAposParidade), 'N') AS flPropAposParidade,
        
        DECODE(UPPER(js.inImpedimentoRubrica),
          'POSSUA TODAS IMPEDIRA',        '1',
          'POSSUA AO MENOS UMA IMPEDIRA', '2',
          'NÃO SE APLICA',                '3',
          '3') AS inImpedimentoRubrica,
        
        DECODE(UPPER(js.inRubricasExigidas),
          'POSSUA TODAS PERMITIRA',        '1',
          'POSSUA AO MENOS UMA PERMITIRA', '2',
          'NÃO SE APLICA',                 '3',
          '3') AS inRubricasExigidas,
        
        NVL(UPPER(js.flAplicaRubricaOrgaos), 'S') AS flAplicaRubricaOrgaos, -- DEFAULT S
        NVL(UPPER(js.flGestaoSobreRubrica), 'N') AS flGestaoSobreRubrica,
        NVL(UPPER(js.flImpedeIdadeCompulsoria), 'N') AS flImpedeIdadeCompulsoria,
        NVL(UPPER(js.flPagaAposEmParidade), 'N') AS flPagaAposEmParidade,
        NVL(UPPER(js.flPagaRespondendo), 'N') AS flPagaRespondendo,
        NVL(UPPER(js.flPagaSubstituicao), 'N') AS flPagaSubstituicao,
        NVL(UPPER(js.flPermiteApoOriginadoCCO), 'N') AS flPermiteApoOriginadoCCO,
        NVL(UPPER(js.flPermiteFGFTG), 'N') AS flPermiteFGFTG,
        NVL(UPPER(js.flPreservaValorIntegral), 'N') AS flPreservaValorIntegral,

        JSON_OBJECT(
          'ListaFuncaoChefia'                 VALUE JSON_SERIALIZE(TO_CLOB(js.ListaFuncaoChefia) RETURNING CLOB),
          'ListaModeloAposentadoria'          VALUE JSON_SERIALIZE(TO_CLOB(js.ListaModeloAposentadoria) RETURNING CLOB),
          'ListaMotivosConvocacao'            VALUE JSON_SERIALIZE(TO_CLOB(js.ListaMotivosConvocacao) RETURNING CLOB),
          'ListaMotivosMovimentacao'          VALUE JSON_SERIALIZE(TO_CLOB(js.ListaMotivosMovimentacao) RETURNING CLOB),
          'ListaPrograma'                     VALUE JSON_SERIALIZE(TO_CLOB(js.ListaPrograma) RETURNING CLOB),
          'ListaUnidadeOrganizacional'        VALUE JSON_SERIALIZE(TO_CLOB(js.ListaUnidadeOrganizacional) RETURNING CLOB),
          'ListaCargasHorarias'               VALUE JSON_SERIALIZE(TO_CLOB(js.ListaCargasHorarias) RETURNING CLOB),
          'ListaMotivosAfastamentoQueImpedem' VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'deMotivoAfastTemporario'       VALUE lst.deMotivoAfastTemporario,
              'cdMotivoAfastTemporario'       VALUE afaLst.cdMotivoAfastTemporario
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaMotivosAfastamentoQueImpedem, '$[*]' COLUMNS (deMotivoAfastTemporario PATH '$')) lst
            LEFT JOIN MotivoAfastamentoLista afaLst ON afaLst.deMotivoAfastTemporario = lst.deMotivoAfastTemporario),
          'ListaMotivosAfastamentoExigidos'   VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'deMotivoAfastTemporario'       VALUE lst.deMotivoAfastTemporario,
              'cdMotivoAfastTemporario'       VALUE afaLst.cdMotivoAfastTemporario
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaMotivosAfastamentoExigidos, '$[*]' COLUMNS (deMotivoAfastTemporario PATH '$')) lst
            LEFT JOIN MotivoAfastamentoLista afaLst ON afaLst.deMotivoAfastTemporario = lst.deMotivoAfastTemporario),

          'ListaEstruturaCarreira'            VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'nmEstruturaCarreira'           VALUE lst.nmEstruturaCarreira,
              'cdEstruturaCarreira'           VALUE cefLst.cdEstruturaCarreira
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaEstruturaCarreira, '$[*]' COLUMNS (nmEstruturaCarreira PATH '$')) lst
            LEFT JOIN EstruturaCarreiraLista cefLst ON cefLst.nmEstruturaCarreira = lst.nmEstruturaCarreira),
          'ListaCargoComissionado'            VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'nmGrupoOcupacional'            VALUE lst.nmGrupoOcupacional,
              'cdGrupoOcupacional'            VALUE ccoLst.cdGrupoOcupacional,
              'deCargoComissionado'           VALUE lst.deCargoComissionado,
              'cdCargoComissionado'           VALUE ccoLst.cdCargoComissionado
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaCargoComissionado, '$[*]' COLUMNS (
              nmGrupoOcupacional              PATH '$.nmGrupoOcupacional',
              deCargoComissionado             PATH '$.deCargoComissionado')) lst
            LEFT JOIN CargoComissionadoLista ccoLst ON ccoLst.nmGrupoOcupacional = lst.nmGrupoOcupacional
                                                   AND NVL(ccoLst.deCargoComissionado, ' ') = NVL(lst.deCargoComissionado, ' ')),
          'ListaNivelReferencia'              VALUE JSON_SERIALIZE(TO_CLOB(js.ListaNivelReferencia) RETURNING CLOB),

          'ListaOrgaoPermitidos'              VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'sgOrgao'                       VALUE lst.sgOrgao,
              'flGestaoRubrica'               VALUE NVL(lst.flGestaoRubrica, 'N'),
              'inLotadoExercicio'             VALUE DECODE(lst.inLotadoExercicio, 'LOTADO', '1', 'EM EXERCICIO', '2', '1'),
              'cdOrgao'                       VALUE orgLst.cdOrgao
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaOrgaoPermitidos, '$[*]' COLUMNS (
              sgOrgao                         PATH '$.sgOrgao',
              flGestaoRubrica                 PATH '$.flGestaoRubrica',
              inLotadoExercicio               PATH '$.inLotadoExercicio')) lst
            LEFT JOIN OrgaoLista orgLst ON orgLst.sgOrgao = lst.sgOrgao
                                       AND orgLst.cdAgrupamento = o.cdAgrupamento),
          'ListaRubricaQueImpedem'            VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'nuRubrica'                     VALUE lst.nuRubrica,
              'cdRubricaAgrupamento'          VALUE rub.cdRubricaAgrupamento
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaRubricaQueImpedem, '$[*]' COLUMNS (nuRubrica PATH '$')) lst
            LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(lst.nuRubrica,1,7)
                                      AND rub.cdAgrupamento = o.cdAgrupamento),
          'ListaRubricaExigidas'              VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'nuRubrica'                     VALUE SUBSTR(lst.nuRubrica,1,7),
              'cdRubricaAgrupamento'          VALUE rub.cdRubricaAgrupamento
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaRubricaExigidas, '$[*]' COLUMNS (nuRubrica PATH '$')) lst
            LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(lst.nuRubrica,1,7)
                                      AND rub.cdAgrupamento = o.cdAgrupamento),

          'NaturezaVinculo'                   VALUE JSON_SERIALIZE(TO_CLOB(js.NaturezaVinculo) RETURNING CLOB),
          'RegimePrevidenciario'              VALUE JSON_SERIALIZE(TO_CLOB(js.RegimePrevidenciario) RETURNING CLOB),
          'RegimeTrabalho'                    VALUE JSON_SERIALIZE(TO_CLOB(js.RegimeTrabalho) RETURNING CLOB),
          'RelacaoTrabalho'                   VALUE JSON_SERIALIZE(TO_CLOB(js.RelacaoTrabalho) RETURNING CLOB),
          'SituacaoPrevidenciaria'            VALUE JSON_SERIALIZE(TO_CLOB(js.SituacaoPrevidenciaria) RETURNING CLOB)
        ABSENT ON NULL RETURNING CLOB) AS ListasVigenciasAgrupamento,

        '11111111111' AS nuCPFCadastrador,
        TRUNC(SYSDATE) AS dtInclusao,
        systimestamp AS dtUltAlteracao

      -- Caminho Absoluto no Documento JSON
      -- $.PAG.Rubrica.Tipos[*].Agrupamento.VigenciasAgrupamento[*]
      FROM JSON_TABLE(pVigenciasAgrupamento, '$[*]' COLUMNS (
        nuAnoMesInicioVigencia            PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia               PATH '$.nuAnoMesFimVigencia',
        
        deRubricaAgrupamento              PATH '$.DadosRubrica.deRubricaAgrupamento',
        deRubricaAgrupResumida            PATH '$.DadosRubrica.deRubricaAgrupResumida',
        nmRelacaoTrabalho                 PATH '$.DadosRubrica.nmRelacaoTrabalho',
        flCargaHorariaPadrao              PATH '$.DadosRubrica.flCargaHorariaPadrao',
        nuCargaHorariaSemanal             PATH '$.DadosRubrica.nuCargaHorariaSemanal',
        nuOutraRubrica                    PATH '$.DadosRubrica.nuOutraRubrica',
        
        deRubricaAgrupDetalhada           PATH '$.Inventario.deRubricaAgrupDetalhada',
        deFormula                         PATH '$.Inventario.deFormula',
        deModulo                          PATH '$.Inventario.deModulo',
        deComposicao                      PATH '$.Inventario.deComposicao',
        deVantagensNaoAcumulaveis         PATH '$.Inventario.deVantagensNaoAcumulaveis',
        deObservacao                      PATH '$.Inventario.deObservacao',
        
        inSePossuirValorInformado         PATH '$.LancamentoFinanceiro.inSePossuirValorInformado',
        inLancPropRelVinc                 PATH '$.LancamentoFinanceiro.inLancPropRelVinc',
        flBloqLancFinanc                  PATH '$.LancamentoFinanceiro.flBloqLancFinanc',
        flSuspensa                        PATH '$.LancamentoFinanceiro.flSuspensa',
        flSuspensaRetroativoErario        PATH '$.LancamentoFinanceiro.flSuspensaRetroativoErario',
        flConsolidaRubrica                PATH '$.LancamentoFinanceiro.flConsolidaRubrica',
        flPermiteAfastAcidente            PATH '$.LancamentoFinanceiro.flPermiteAfastAcidente',
        flValidaSufixoPrecedenciaLF       PATH '$.LancamentoFinanceiro.flValidaSufixoPrecedenciaLF',
        
        inGeraRubricaUO                   PATH '$.GerarRubrica.inGeraRubricaUO',
        inGeraRubricaCarreira             PATH '$.GerarRubrica.inGeraRubricaCarreira',
        inGeraRubricaNivel                PATH '$.GerarRubrica.inGeraRubricaNivel',
        inGeraRubricaCCO                  PATH '$.GerarRubrica.inGeraRubricaCCO',
        inGeraRubricaFUC                  PATH '$.GerarRubrica.inGeraRubricaFUC',
        inGeraRubricaPrograma             PATH '$.GerarRubrica.inGeraRubricaPrograma',
        inAposentadoriaServidor           PATH '$.GerarRubrica.inAposentadoriaServidor',
        inGeraRubricaAfastTemp            PATH '$.GerarRubrica.inGeraRubricaAfastTemp',
        inGeraRubricaMotMovi              PATH '$.GerarRubrica.inGeraRubricaMotMovi',
        flPagaEfetivoOrgao                PATH '$.GerarRubrica.flPagaEfetivoOrgao',
        flPagAposentadoria                PATH '$.GerarRubrica.flPagAposentadoria',
        flLaudoAcompanhamento             PATH '$.GerarRubrica.flLaudoAcompanhamento',
        flGeraRubricaCarreiraIncideApo    PATH '$.GerarRubrica.flGeraRubricaCarreiraIncideApo',
        flGeraRubricaCarreiraIncideCCO    PATH '$.GerarRubrica.flGeraRubricaCarreiraIncideCCO',
        flGeraRubricaCCOIncideCEF         PATH '$.GerarRubrica.flGeraRubricaCCOIncideCEF',
        flGeraRubricaFUCIncideCEF         PATH '$.GerarRubrica.flGeraRubricaFUCIncideCEF',
        flGeraRubricaHoraExtra            PATH '$.GerarRubrica.flGeraRubricaHoraExtra',
        flGeraRubricaEscala               PATH '$.GerarRubrica.flGeraRubricaEscala',
        flGeraRubricaServCCO              PATH '$.GerarRubrica.flGeraRubricaServCCO',
        
        ListaEstruturaCarreira            CLOB FORMAT JSON PATH '$.GerarRubrica.ListaEstruturaCarreira',
        ListaFuncaoChefia                 CLOB FORMAT JSON PATH '$.GerarRubrica.ListaFuncaoChefia',
        ListaCargoComissionado            CLOB FORMAT JSON PATH '$.GerarRubrica.ListaCargoComissionado',
        ListaModeloAposentadoria          CLOB FORMAT JSON PATH '$.GerarRubrica.ListaModeloAposentadoria',
        ListaMotivosConvocacao            CLOB FORMAT JSON PATH '$.GerarRubrica.ListaMotivosConvocacao',
        ListaMotivosMovimentacao          CLOB FORMAT JSON PATH '$.GerarRubrica.ListaMotivosMovimentacao',
        ListaPrograma                     CLOB FORMAT JSON PATH '$.GerarRubrica.ListaPrograma',
        ListaUnidadeOrganizacional        CLOB FORMAT JSON PATH '$.GerarRubrica.ListaUnidadeOrganizacional',
        ListaNivelReferencia              CLOB FORMAT JSON PATH '$.GerarRubrica.ListaNivelReferencia',
        
        deTipoIndice                      PATH '$.Proporcionalidade.deTipoIndice',
        nmRubProporcionalidadeCHO         PATH '$.Proporcionalidade.nmRubProporcionalidadeCHO',
        nuMesesApuracao                   PATH '$.Proporcionalidade.nuMesesApuracao',
        flPropMesComercial                PATH '$.Proporcionalidade.flPropMesComercial',
        flCargaHorariaLimitada            PATH '$.Proporcionalidade.flCargaHorariaLimitada',
        flIgnoraAfastCEFAgPolitico        PATH '$.Proporcionalidade.flIgnoraAfastCEFAgPolitico',
        flIncidParcialContrPrev           PATH '$.Proporcionalidade.flIncidParcialContrPrev',
        flPagaMaiorRV                     PATH '$.Proporcionalidade.flPagaMaiorRV',
        flPercentLimitado100              PATH '$.Proporcionalidade.flPercentLimitado100',
        flPercentReducaoAfastRemun        PATH '$.Proporcionalidade.flPercentReducaoAfastRemun',
        flPropServRelVinc                 PATH '$.Proporcionalidade.flPropServRelVinc',
        flPropAfaComissionado             PATH '$.Proporcionalidade.flPropAfaComissionado',
        flPropAfaCCOSubst                 PATH '$.Proporcionalidade.flPropAfaCCOSubst',
        flPropAfaComOpcPercCEF            PATH '$.Proporcionalidade.flPropAfaComOpcPercCEF',
        flPropAfaFGFTG                    PATH '$.Proporcionalidade.flPropAfaFGFTG',
        flPropAfastTempNaoRemun           PATH '$.Proporcionalidade.flPropAfastTempNaoRemun',
        flPropAposParidade                PATH '$.Proporcionalidade.flPropAposParidade',
        
        ListaCargasHorarias               CLOB FORMAT JSON PATH '$.Proporcionalidade.ListaCargasHorarias',
        ListaMotivosAfastamentoQueImpedem CLOB FORMAT JSON PATH '$.Proporcionalidade.ListaMotivosAfastamentoQueImpedem',
        ListaMotivosAfastamentoExigidos   CLOB FORMAT JSON PATH '$.Proporcionalidade.ListaMotivosAfastamentoExigidos',
        
        inImpedimentoRubrica              PATH '$.PermissoesRubrica.inImpedimentoRubrica',
        inRubricasExigidas                PATH '$.PermissoesRubrica.inRubricasExigidas',
        flAplicaRubricaOrgaos             PATH '$.PermissoesRubrica.flAplicaRubricaOrgaos',
        flGestaoSobreRubrica              PATH '$.PermissoesRubrica.flGestaoSobreRubrica',
        flImpedeIdadeCompulsoria          PATH '$.PermissoesRubrica.flImpedeIdadeCompulsoria',
        flPagaAposEmParidade              PATH '$.PermissoesRubrica.flPagaAposEmParidade',
        flPagaRespondendo                 PATH '$.PermissoesRubrica.flPagaRespondendo',
        flPagaSubstituicao                PATH '$.PermissoesRubrica.flPagaSubstituicao',
        flPermiteApoOriginadoCCO          PATH '$.PermissoesRubrica.flPermiteApoOriginadoCCO',
        flPermiteFGFTG                    PATH '$.PermissoesRubrica.flPermiteFGFTG',
        flPreservaValorIntegral           PATH '$.PermissoesRubrica.flPreservaValorIntegral',
        
        ListaOrgaoPermitidos              CLOB FORMAT JSON PATH '$.PermissoesRubrica.ListaOrgaoPermitidos',
        ListaRubricaQueImpedem            CLOB FORMAT JSON PATH '$.PermissoesRubrica.ListaRubricaQueImpedem',
        ListaRubricaExigidas              CLOB FORMAT JSON PATH '$.PermissoesRubrica.ListaRubricaExigidas',
        
        NaturezaVinculo                   CLOB FORMAT JSON PATH '$.PermissoesRubrica.NaturezaVinculo',
        RegimePrevidenciario              CLOB FORMAT JSON PATH '$.PermissoesRubrica.RegimePrevidenciario',
        RegimeTrabalho                    CLOB FORMAT JSON PATH '$.PermissoesRubrica.RegimeTrabalho',
        RelacaoTrabalho                   CLOB FORMAT JSON PATH '$.PermissoesRubrica.RelacaoTrabalho',
        SituacaoPrevidenciaria            CLOB FORMAT JSON PATH '$.PermissoesRubrica.SituacaoPrevidenciaria'
      )) js
      LEFT JOIN OrgaoLista o ON o.sgAgrupamento = psgAgrupamentoDestino AND NVL(o.sgOrgao, ' ') = NVL(psgOrgao, ' ')
      LEFT JOIN ecadRelacaoTrabalho relTrabVigencia ON relTrabVigencia.nmRelacaoTrabalho = js.nmRelacaoTrabalho
      LEFT JOIN RubricaLista rubOutra ON rubOutra.nuRubrica = js.nuOutraRubrica
      LEFT JOIN epagTipoIndice tpIndice ON tpIndice.deTipoIndice = js.deTipoIndice
      )
      SELECT * FROM epagHistRubricaAgrupamentoImportar;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'RUBRICA AGRUPAMENTO VIGENCIA', 'JSON', SUBSTR(pVigenciasAgrupamento,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir a Vigências da Rubrica do Agrupamento
    FOR r IN cDados LOOP

	    vcdIdentificacao := pcdIdentificacao || ' ' || LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica do Agrupamento - Vigências ' || vcdIdentificacao,
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      SELECT NVL(MAX(cdhistrubricaagrupamento), 0) + 1 INTO vcdHistRubricaAgrupamentoNova FROM epagHistRubricaAgrupamento;

      IF r.cdRelacaoTrabalho IS NULL AND r.nmRelacaoTrabalho IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('da Rubrica do Agrupamento - ' ||
          'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.nmRelacaoTrabalho,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmRelacaoTrabalho, 1,
          'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
          'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdOutraRubrica IS NULL AND r.nuOutraRubrica IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('da Rubrica do Agrupamento - ' ||
          'Outra Rubrica da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.nuOutraRubrica,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nuOutraRubrica, 1,
          'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
          'Outra Rubrica da Vigência da Rubrica do Agrupamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdTipoIndice IS NULL AND r.deTipoIndice IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('da Rubrica do Agrupamento - ' ||
          'Tipo de Índice da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.deTipoIndice,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.deTipoIndice, 1,
          'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
          'Tipo de Índice da Vigência da Rubrica do Agrupamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdRubProporcionalidadeCHO IS NULL AND r.nmRubProporcionalidadeCHO IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('da Rubrica do Agrupamento - ' ||
          'Rubrica Proporcionlidade de Carga Horária da Vigência da Rubrica do Agrupamento Inexistente ' ||
          vcdIdentificacao || ' ' || r.nmRubProporcionalidadeCHO,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmRubProporcionalidadeCHO, 1,
          'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
          'Rubrica Proporcionlidade de Carga Horária da Rubrica do Agrupamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Incluir Nova Vigência da Rubrica do Agrupamento
      INSERT INTO epagHistRubricaAgrupamento (
        cdHistRubricaAgrupamento, cdRubricaAgrupamento,
        deRubricaAgrupamento, deRubricaAgrupResumida, deRubricaAgrupDetalhada,
        nuAnoInicioVigencia, nuMesInicioVigencia, nuAnoFimVigencia, nuMesFimVigencia,
        flPermiteAfastAcidente, flBloqLancFinanc, inLancPropRelVinc, cdRelacaoTrabalho, flCargaHorariaPadrao, nuCargaHorariaSemanal,
        nuMesesApuracao, flAplicaRubricaOrgaos, nuCpfCadastrador, dtInclusao, dtUltAlteracao, flGestaoSobreRubrica, flGeraRubricaEscala,
        flGeraRubricaHoraExtra, flGeraRubricaServCCO, inGeraRubricaCarreira, inGeraRubricaNivel, inGeraRubricaUO, inGeraRubricaCCO,
        inGeraRubricaFUC, flLaudoAcompanhamento, inAposentadoriaServidor, inGeraRubricaAfastTemp, inImpedimentoRubrica, inRubricasExigidas,
        cdRubProporcionalidadeCHO, flPropMesComercial, flPropAposParidade, flPropServRelVinc, cdOutraRubrica, inPossuiValorInformado,
        flPermiteFGFTG, flPermiteApoOriginadoCCO, flPagaSubstituicao, flPagaRespondendo, flConsolidaRubrica, flPropAfastTempNaoRemun,
        flPropAFAFGFTG, flCargaHorariaLimitada, flIncidParcialContrPrev, flPropAFAComissionado, flPropAFAComOpcPercCEF,
        flPreservaValorIntegral, inGeraRubricaMotMovi, flPagaAposEmParidade, flPercentLimitado100, inGeraRubricaPrograma,
        flPropAFAcCoSubst, flImpedeIdadeCompulsoria, flGeraRubricaCarreiraIncideCCO, flGeraRubricaCarreiraIncideApo,
        flGeraRubricaCCOIncideCEF, flSuspensa, flPercentReducaoAfastRemun, flPagaMaiorRV, cdTipoIndice, flGeraRubricaFUCIncideCEF,
        flValidaSufixoPrecedenciaLF, deFormula, deModulo, deComposicao, deVantagensNaoAcumulaveis, deObservacao,
        flSuspensaRetroativoErario, flPagaEfetivoOrgao, flIgnoraAfastCEFagPolitico, flPagAposentadoria
      ) VALUES (
        vcdHistRubricaAgrupamentoNova, r.cdRubricaAgrupamento,
        r.deRubricaAgrupamento, r.deRubricaAgrupResumida, r.deRubricaAgrupDetalhada,
        r.nuAnoInicioVigencia, r.nuMesInicioVigencia, r.nuAnoFimVigencia, r.nuMesFimVigencia,
        r.flPermiteAfastAcidente, r.flBloqLancFinanc, r.inLancPropRelVinc, r.cdRelacaoTrabalho, r.flCargaHorariaPadrao, r.nuCargaHorariaSemanal,
        r.nuMesesApuracao, r.flAplicaRubricaOrgaos, r.nuCpfCadastrador, r.dtInclusao, r.dtUltAlteracao, r.flGestaoSobreRubrica, r.flGeraRubricaEscala,
        r.flGeraRubricaHoraExtra, r.flGeraRubricaServCCO, r.inGeraRubricaCarreira, r.inGeraRubricaNivel, r.inGeraRubricaUO, r.inGeraRubricaCCO,
        r.inGeraRubricaFUC, r.flLaudoAcompanhamento, r.inAposentadoriaServidor, r.inGeraRubricaAfastTemp, r.inImpedimentoRubrica, r.inRubricasExigidas,
        r.cdRubProporcionalidadeCHO, r.flPropMesComercial, r.flPropAposParidade, r.flPropServRelVinc, r.cdOutraRubrica, r.inPossuiValorInformado,
        r.flPermiteFGFTG, r.flPermiteApoOriginadoCCO, r.flPagaSubstituicao, r.flPagaRespondendo, r.flConsolidaRubrica, r.flPropAfastTempNaoRemun,
        r.flPropAFAFGFTG, r.flCargaHorariaLimitada, r.flIncidParcialContrPrev, r.flPropAFAComissionado, r.flPropAFAComOpcPercCEF,
        r.flPreservaValorIntegral, r.inGeraRubricaMotMovi, r.flPagaAposEmParidade, r.flPercentLimitado100, r.inGeraRubricaPrograma,
        r.flPropAFAcCoSubst, r.flImpedeIdadeCompulsoria, r.flGeraRubricaCarreiraIncideCCO, r.flGeraRubricaCarreiraIncideApo,
        r.flGeraRubricaCCOIncideCEF, r.flSuspensa, r.flPercentReducaoAfastRemun, r.flPagaMaiorRV, r.cdTipoIndice, r.flGeraRubricaFUCIncideCEF,
        r.flValidaSufixoPrecedenciaLF, r.deFormula, r.deModulo, r.deComposicao, r.deVantagensNaoAcumulaveis, r.deObservacao,
        r.flSuspensaRetroativoErario, r.flPagaEfetivoOrgao, r.flIgnoraAfastCEFagPolitico, r.flPagAposentadoria
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Incluir Abrangências da Vigencia da Rubrica do Agrupamento
      pImportarAbrangencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdHistRubricaAgrupamentoNova, r.ListasVigenciasAgrupamento, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'RUBRICA AGRUPAMENTO VIGENCIA',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricasAgrupamento.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigencias;

  PROCEDURE pImportarAbrangencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarAbrangencias
  -- Objetivo:
  --   Excluir as Entidades filhas da Rubrica do Agrupamento
  --     - Incluir a Lista de Carreiras
  --     - Incluir a Lista de NiveisReferencias
  --     - Incluir a Lista de CargosComissionados
  --     - Incluir a Lista de FuncoesChefia
  --     - Incluir a Lista de Programas
  --     - Incluir a Lista de ModelosAposentadoria
  --     - Incluir a Lista de CargasHorarias
  --     - Incluir a Lista de UnidadesOrganizacionais
  --     - Incluir a Lista de Motivos de Afastamento que Impedem
  --     - Incluir a Lista de Motivos de Afastamento Exigidos
  --     - Incluir a Lista de Motivos de Movimentação
  --     - Incluir a Lista de Motivos de Convocação
  --     - Incluir a Lista de Órgãos
  --     - Incluir a Lista de Rubricas que Impedem
  --     - Incluir a Lista de Rubricas Exigidas
  --     - Incluir a Lista de Naturezas do Vínculo Permitidos
  --     - Incluir a Lista de Relações de Trabalho Permitidos
  --     - Incluir a Lista de Regimes de Trabalho Permitidos
  --     - Incluir a Lista de Regimes Previdenciários Permitidas
  --     - Incluir a Lista de Situações Previdenciárias Permitidas
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
  --   pcdRubricaAgrupamentoVigencia IN NUMBER: 
  --   pListasVigenciasAgrupamento IN CLOB,
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
    pcdHistRubricaAgrupamento IN NUMBER,
    pListasVigenciasAgrupamento IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN
    
    vnuRegistros := 0;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 0,
      'RUBRICA AGRUPAMENTO VIGENCIA LISTAS', 'JSON', SUBSTR(pListasVigenciasAgrupamento,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Incluir ListaUnidadesOrganizacionais
    -- Incluir ListaMotivosAfastamentoQueImpedem
    -- Incluir ListaMotivosAfastamentoExigidos
    -- Incluir ListaMotivosMovimentacao
    -- Incluir ListaMotivosConvocacao
    -- Incluir ListaFuncaoChefia
    -- Incluir ListaModeloAposentadoria
    -- Incluir ListaPrograma
    -- Incluir ListaUnidadeOrganizacional
    -- Incluir ListaCargasHorarias

    -- Incluir Motivos de Afastamento que Impedem na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaMotivosAfastamentoQueImpedem[*]' COLUMNS (
      cdMotivoAfastTemporario PATH '$.cdMotivoAfastTemporario'
    )) js
    WHERE js.cdMotivoAfastTemporario IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagRubAgrupMotAfastTempImp
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdMotivoAfastTemporario
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaMotivosAfastamentoQueImpedem[*]' COLUMNS (
        cdMotivoAfastTemporario PATH '$.cdMotivoAfastTemporario'
      )) js
      WHERE js.cdMotivoAfastTemporario IS NOT NULL;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
		    'Motivos de Afastamento que Impedem na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.deMotivoAfastTemporario, js.cdMotivoAfastTemporario
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaMotivosAfastamentoQueImpedem[*]' COLUMNS (
        deMotivoAfastTemporario PATH '$.deMotivoAfastTemporario',
        cdMotivoAfastTemporario PATH '$.cdMotivoAfastTemporario'
      )) js
      WHERE js.cdMotivoAfastTemporario IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.deMotivoAfastTemporario,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
		    'Motivos de Afastamento que Impedem da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Estrutura de Carreiras Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaEstruturaCarreira[*]' COLUMNS (
      cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
    )) js
    WHERE js.cdEstruturaCarreira IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupCarreira
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdEstruturaCarreira
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaEstruturaCarreira[*]' COLUMNS (
        cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
      )) js
      WHERE js.cdEstruturaCarreira IS NOT NULL;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Estruturas de Carreiras na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nmEstruturaCarreira, js.cdEstruturaCarreira
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaEstruturaCarreira[*]' COLUMNS (
        nmEstruturaCarreira PATH '$.nmEstruturaCarreira',
        cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
      )) js
      WHERE js.cdEstruturaCarreira IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmEstruturaCarreira,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Esturura de Carreira da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Níveis e Referencia Permitidos na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaNivelReferencia[*]' COLUMNS (
      nuNivel          PATH '$.nuNivel',
      nuReferencia     PATH '$.nuReferencia'
    )) js
    WHERE js.nuNivel IS NOT NULL OR js.nuReferencia IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupNivelRef (cdHistRubricaAgrupamento, nuNivel, nuReferencia)
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.nuNivel, js.nuReferencia
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaNivelReferencia[*]' COLUMNS (
        nuNivel        PATH '$.nuNivel',
        nuReferencia   PATH '$.nuReferencia'
      )) js
      WHERE js.nuNivel IS NOT NULL OR js.nuReferencia IS NOT NULL;
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Níveis e Referencia Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nuNivel, js.nuReferencia
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaNivelReferencia[*]' COLUMNS (
        nuNivel        PATH '$.nuNivel',
        nuReferencia   PATH '$.nuReferencia'
      )) js
      WHERE js.nuNivel IS NULL AND js.nuReferencia IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nuNivel || ' ' || i.nuReferencia,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Níveis e Referencia Permitido da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Cargos Comissionados Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
      nmGrupoOcupacional  PATH '$.nmGrupoOcupacional',
      deCargoComissionado PATH '$.deCargoComissionado',
      cdGrupoOcupacional  PATH '$.cdGrupoOcupacional',
      cdCargoComissionado PATH '$.cdCargoComissionado'
    )) js
    WHERE js.cdGrupoOcupacional  IS NOT NULL
      AND (    (js.deCargoComissionado IS NOT NULL AND js.cdCargoComissionado IS NOT NULL)
            OR (js.deCargoComissionado IS NULL     AND js.cdCargoComissionado IS NULL    ));

    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupCCO
      SELECT (SELECT MAX(NVL(cdHistRubricaAgrupCCO,0)) FROM epagHistRubricaAgrupCCO) + ROWNUM AS cdHistRubricaAgrupCCO,
        js.cdGrupoOcupacional, pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdCargoComissionado
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
        nmGrupoOcupacional  PATH '$.nmGrupoOcupacional',
        deCargoComissionado PATH '$.deCargoComissionado',
        cdGrupoOcupacional  PATH '$.cdGrupoOcupacional',
        cdCargoComissionado PATH '$.cdCargoComissionado'
      )) js
      WHERE js.cdGrupoOcupacional  IS NOT NULL
        AND (    (js.deCargoComissionado IS NOT NULL AND js.cdCargoComissionado IS NOT NULL)
              OR (js.deCargoComissionado IS NULL     AND js.cdCargoComissionado IS NULL    ));
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Cargos Comissionados na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nmGrupoOcupacional, js.deCargoComissionado, js.cdGrupoOcupacional
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
        nmGrupoOcupacional  PATH '$.nmGrupoOcupacional',
        deCargoComissionado PATH '$.deCargoComissionado',
        cdGrupoOcupacional  PATH '$.cdGrupoOcupacional',
        cdCargoComissionado PATH '$.cdCargoComissionado'
      )) js
      WHERE js.cdGrupoOcupacional  IS NULL
         OR (js.deCargoComissionado IS NOT NULL AND js.cdCargoComissionado IS NULL)
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || SUBSTR(i.nmGrupoOcupacional || ' ' || i.deCargoComissionado,1,30),1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Cargo Comissionado da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Órgãos Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaOrgaoPermitidos[*]' COLUMNS (
      cdOrgao           PATH '$.cdOrgao'
    )) js
    WHERE js.cdOrgao IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupOrgao (cdHistRubricaAgrupamento, cdOrgao, flGestaoRubrica, inLotadoExercicio)
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdOrgao, js.flGestaoRubrica, js.inLotadoExercicio
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaOrgaoPermitidos[*]' COLUMNS (
        cdOrgao           PATH '$.cdOrgao',
        flGestaoRubrica   PATH '$.flGestaoRubrica',
        inLotadoExercicio PATH '$.inLotadoExercicio'
      )) js
      WHERE js.cdOrgao IS NOT NULL;
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Órgãos Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.sgOrgao, js.cdOrgao
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaOrgaoPermitidos[*]' COLUMNS (
        sgOrgao           PATH '$.sgOrgao',
        cdOrgao           PATH '$.cdOrgao'
      )) js
      WHERE js.cdOrgao IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.sgOrgao,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Órgao Permitido da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Rubricas que Impedem na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaQueImpedem[*]' COLUMNS (
      nuRubrica            PATH '$.nuRubrica',
      cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
    )) js
    WHERE js.cdRubricaAgrupamento IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupImpeditiva
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdRubricaAgrupamento
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaQueImpedem[*]' COLUMNS (
        cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
      )) js
      WHERE js.cdRubricaAgrupamento IS NOT NULL;
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUBRICAS EXIGIDAS', 'INCLUSAO',
        'Rubricas que Impedem na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nuRubrica, js.cdRubricaAgrupamento
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaQueImpedem[*]' COLUMNS (
        nuRubrica            PATH '$.nuRubrica',
        cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
      )) js
      WHERE js.cdRubricaAgrupamento IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nuRubrica,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Rubrica que Impede na Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Rubricas Exigidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaExigidas[*]' COLUMNS (
      cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
    )) js
    WHERE js.cdRubricaAgrupamento IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupExigida
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdRubricaAgrupamento
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaExigidas[*]' COLUMNS (
        cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
      )) js
      WHERE js.cdRubricaAgrupamento IS NOT NULL;
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Rubricas Exigidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nuRubrica, js.cdRubricaAgrupamento
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaRubricaExigidas[*]' COLUMNS (
        nuRubrica            PATH '$.nuRubrica',
        cdRubricaAgrupamento PATH '$.cdRubricaAgrupamento'
      )) js
      WHERE js.cdRubricaAgrupamento IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nuRubrica,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Rubrica Exigida na Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.NaturezaVinculo[*]' COLUMNS (item PATH '$')) js
    INNER JOIN ecadNaturezaVinculo d ON UPPER(d.nmNaturezaVinculo) = UPPER(js.item);

    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupNatVinc
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdNaturezaVinculo
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.NaturezaVinculo[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadNaturezaVinculo d ON UPPER(d.nmNaturezaVinculo) = UPPER(js.item);
      
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
      psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
      'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO', 
      'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmNaturezaVinculo
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.NaturezaVinculo[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadNaturezaVinculo d ON UPPER(d.nmNaturezaVinculo) = UPPER(js.item)
      WHERE d.cdNaturezaVinculo IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmNaturezaVinculo,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Natureza do Vínculo da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Regimes Previdenciários Permitidas Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimePrevidenciario[*]' COLUMNS (item PATH '$')) js
    INNER JOIN ecadRegimePrevidenciario d ON UPPER(d.nmRegimepreVidenciario) = UPPER(js.item);
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epaghistrubricaagrupregprev
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdRegimePrevidenciario
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimePrevidenciario[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadRegimePrevidenciario d ON UPPER(d.nmRegimePrevidenciario) = UPPER(js.item);
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGPREV', 'INCLUSAO',
        'Regime Previdenciários Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRegimepreVidenciario
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimePrevidenciario[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRegimePrevidenciario d ON UPPER(d.nmRegimepreVidenciario) = UPPER(js.item)
      WHERE d.cdRegimePrevidenciario IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmRegimepreVidenciario,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Regime Previdenciário da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

   -- Incluir Regimes de Trabalho Permitidas Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimeTrabalho[*]' COLUMNS (item PATH '$')) js
    INNER JOIN ecadRegimeTrabalho d ON UPPER(d.nmRegimeTrabalho) = UPPER(js.item);
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupRegTrab
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdRegimeTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimeTrabalho[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadRegimeTrabalho d ON UPPER(d.nmRegimeTrabalho) = UPPER(js.item);
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGTRAB', 'INCLUSAO',
        'Regimes de Trabalho Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRegimeTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimeTrabalho[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRegimeTrabalho d ON UPPER(d.nmRegimeTrabalho) = UPPER(js.item)
      WHERE d.cdRegimeTrabalho IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmRegimeTrabalho,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Regime de Trabalho da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

   -- Incluir Relações de Trabalho Permitidas Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RelacaoTrabalho[*]' COLUMNS (item PATH '$')) js
    INNER JOIN ecadRelacaoTrabalho d ON UPPER(d.nmRelacaoTrabalho) = UPPER(js.item);
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupRelTrab
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdRelacaoTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RelacaoTrabalho[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadRelacaoTrabalho d ON UPPER(d.nmRelacaoTrabalho) = UPPER(js.item);
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RELTRAB', 'INCLUSAO',
        'Relaçao de Trabalho Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRelacaoTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RelacaoTrabalho[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRelacaoTrabalho d ON UPPER(d.nmRelacaoTrabalho) = UPPER(js.item)
      WHERE d.cdRelacaoTrabalho IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmRelacaoTrabalho,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Natureza de Vinculo da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

   -- Incluir Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.SituacaoPrevidenciaria[*]' COLUMNS (item PATH '$')) js
    INNER JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmSituacaoPrevidenciaria) = UPPER(js.item);
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupSitPrev
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdSituacaoPrevidenciaria
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.SituacaoPrevidenciaria[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmSituacaoPrevidenciaria) = UPPER(js.item);
      
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA SITPREV', 'INCLUSAO',
        'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmSituacaoPrevidenciaria
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.SituacaoPrevidenciaria[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmSituacaoPrevidenciaria) = UPPER(js.item)
      WHERE d.cdSituacaoPrevidenciaria IS NULL
    )
    LOOP
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, SUBSTR(pcdIdentificacao || ' ' || i.nmSituacaoPrevidenciaria,1,70), 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Situação Previdenciária da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'RUBRICA AGRUPAMENTO VIGENCIA',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricasAgrupamento.pImportarAbrangencias)', SQLERRM);
      RAISE;
  END pImportarAbrangencias;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações de Tributação
  FUNCTION fnCursorParametroTributacao(
    psgAgrupamento   IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2
  ) RETURN SYS_REFCURSOR IS
    vRefCursor SYS_REFCURSOR;
    vParametroTributacao VARCHAR2(4000) := '{"ParametroTributacao":[
      {"tpRubAgrupParametro": "cdRubAgrupDescINSS",              "tpTributacao": "INSS"},
      {"tpRubAgrupParametro": "cdRubAgrupDescINSSSobre13",       "tpTributacao": "INSS Gratificacao Natalina"},
      
      {"tpRubAgrupParametro": "cdRubAgrupDescIRRF",              "tpTributacao": "IRRF"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobre13",       "tpTributacao": "IRRF Gratificacao Natalina"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobreFerias",   "tpTributacao": "IRRF ferias"},
      
      {"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc",       "tpTributacao": "IPER Fundo Financeiro [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc13",     "tpTributacao": "IPER Fundo Financeiro Gratificação Natalina [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC662",        "tpTributacao": "IPER Fundo LC 662 [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC66213",      "tpTributacao": "IPER Fundo LC 662 Gratificação Natalina [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupIPREVFundPrev",         "tpTributacao": "IPER Fundo Previdenciário [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIPREVLiminar",      "tpTributacao": "IPER Liminar [RRA]"},
      {"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun1613",  "tpTributacao": "IPER Jun 1613 [RRA]"},
      {"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun2016",  "tpTributacao": "IPER Jun 2016 [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIPREVDepois2008",   "tpTributacao": "IPER Fundo Previdenciário Depois 2008"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIPREVAntes2008",    "tpTributacao": "IPER Fundo Previdenciário Antes 2008"},
      
      {"tpRubAgrupParametro": "cdRubricaAgrupDescIPESC",         "tpTributacao": "IPESC"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIPESCSobre13",      "tpTributacao": "IPESC Gratificação Natalina"},
      {"tpRubAgrupParametro": "cdRubricaAgrupDescIPESCJul2008",  "tpTributacao": "IPESC Jul 2008"},
      {"tpRubAgrupParametro": "cdRubAgrupDescIPESCJul200813",    "tpTributacao": "IPESC Jul 2008 Gratificação Natalina"},
      
      {"tpRubAgrupParametro": "cdRubricaAgrupDescCPSM",          "tpTributacao": "CPSM"},
      {"tpRubAgrupParametro": "cdRubAgrupDescCPSMSobre13",       "tpTributacao": "CPSM Gratificação Natalina"},
      {"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera",        "tpTributacao": "CPSM [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera13",      "tpTributacao": "CPSM Gratificação Natalina [RRA]"},
      
      {"tpRubAgrupParametro": "cdRubAgrupPensao13",              "tpTributacao": "Pensão Alimentícia Gratificação Natalina"},
      {"tpRubAgrupParametro": "cdRubricaAdiant13Pensao",         "tpTributacao": "Pensão Alimentícia Adiantamento Gratificação Natalina"},
      {"tpRubAgrupParametro": "cdRubAgrupPensaoAliRRA",          "tpTributacao": "Pensão Alimentícia [RRA]"},
      
      {"tpRubAgrupParametro": "cdRubAgrupDescJudicial",          "tpTributacao": "Desconto Judicial"},
      {"tpRubAgrupParametro": "cdRubricaAgrupDescRRA",           "tpTributacao": "Desconto Judicial [RRA]"},
      
      {"tpRubAgrupParametro": "cdRubAgrupBloqRet",               "tpTributacao": "ABATE TETO"},
      {"tpRubAgrupParametro": "cdRubAgrupBloqRet13Sal",          "tpTributacao": "ABATE TETO GRATIFICACAO NATALINA"},
      {"tpRubAgrupParametro": "cdRubAgrupBloqRetExercFind",      "tpTributacao": "ABATE TETO [RRA]"},
      {"tpRubAgrupParametro": "cdRubAgrupBloqExercFind13Sal",    "tpTributacao": "ABATE TETO GRATIFICACAO NATALINA [RRA]"}
      ]}';

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Rubricas de um Agrupamento
      WITH
      --- Informações referente as lista de Órgãos, Rubricas, Carreiras, Cargos Comissionados, Motivos
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
      --- Informações referente as Prametrizações de Rubricas do Agrupamento
      -- Referente as seguintes Tabelas:
      --   DeParaRubricaTributacao => vParametroTributacao
      --   AgrupamentoParametro => epagAgrupamentoParametro
      --   ParametroTributacao => epagHistFormulaCalculo
      --   
      -- DeParaRubricaTributacao: DePara do Tipo de Tributação e os Campos com os
      -- Código de Rubricas da Paramentrização do Agrupamento. HARDCODE vParametroTributacao
      DeParaRubricaTributacao AS (
      SELECT tpRubAgrupParametro, tpTributacao FROM JSON_TABLE(vParametroTributacao, '$.ParametroTributacao[*]' COLUMNS (
        tpRubAgrupParametro PATH '$.tpRubAgrupParametro',
        tpTributacao   PATH '$.tpTributacao'
      )) js
      ),
      -- AgrupamentoParametro, tranforma os campos dos Parametros do Agrupamento em uma única columa cdRubricaAgrupamento e identifica o Tipo de Parametro.
      AgrupamentoParametro AS (
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescINSSSobre13' AS tpRubAgrupParametro, cdRubAgrupDescINSSSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRF' AS tpRubAgrupParametro, cdRubAgrupDescIRRF AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobre13' AS tpRubAgrupParametro, cdRubAgrupDescIRRFSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobreFerias' AS tpRubAgrupParametro, cdRubAgrupDescIRRFsobreFerias AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPESCJul2008' AS tpRubAgrupParametro, cdRubricaAgrupDescIPESCjul2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPESCJul200813' AS tpRubAgrupParametro, cdRubAgrupDescIPESCJul200813 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundPrev' AS tpRubAgrupParametro, cdRubAgrupIPREVFundPrev AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet' AS tpRubAgrupParametro, cdRubAgrupBloqRet AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRetExercFind' AS tpRubAgrupParametro, cdRubAgrupBloqRetExercFind AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAdiant13Pensao' AS tpRubAgrupParametro, cdRubricaAdiant13Pensao AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqRet13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqExercFind13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqExercFind13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensao13' AS tpRubAgrupParametro, cdRubAgrupPensao13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescRRA' AS tpRubAgrupParametro, cdRubricaAgrupDescRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensaoAliRRA' AS tpRubAgrupParametro, cdRubAgrupPensaoAliRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun2016' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun2016 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun1613' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun1613 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVAntes2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVAntes2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVDepois2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVDepois2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC662' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC662 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc13' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC66213' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC66213 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescCPSM' AS tpRubAgrupParametro, cdRubricaAgrupDescCPSM AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMSobre13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVLiminar' AS tpRubAgrupParametro, cdRubAgrupDescIPREVLiminar AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
      SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescJudicial' AS tpRubAgrupParametro, cdRubAgrupDescJudicial AS cdRubricaAgrupamento FROM epagAgrupamentoParametro
      ),
      -- ParametroTributacao, vincula cada Campo da Parametrização do Agrupamento ao Tipo de Tributação
      ParametroTributacao AS (
      SELECT a.sgAgrupamento, rub.nuRubrica, parm.cdRubricaAgrupamento,
        JSON_ARRAYAGG(rubTrb.tpTributacao) AS ParametroTributacao
      FROM AgrupamentoParametro parm
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = parm.cdAgrupamento
      LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpRubAgrupParametro = parm.tpRubAgrupParametro
      INNER JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = parm.cdRubricaAgrupamento
      WHERE rubTrb.tpTributacao IS NOT NULL 
        AND a.sgAgrupamento = psgAgrupamento
          AND (rub.nuRubrica = pcdIdentificacao OR pcdIdentificacao IS NULL)
      GROUP BY a.sgAgrupamento, parm.cdRubricaAgrupamento, rub.nuRubrica
      )
      SELECT 
        sgAgrupamento AS sgAgrupamento,
        nuRubrica AS cdIdentificacao,
        ParametroTributacao AS jsConteudo
      FROM ParametroTributacao
      ORDER BY sgAgrupamento, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorParametroTributacao;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações das Rubricas
  FUNCTION fnCursorRubricasAgrupamento(
    psgAgrupamento   IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2
  ) RETURN SYS_REFCURSOR IS
    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Rubricas de um Agrupamento
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
      -- CargoComissionadoLista: lista da Estrutura de Cargos Comissionados
      CargoComissionadoLista as (
      SELECT gp.cdAgrupamento, gp.cdGrupoOcupacional, cco.cdCargoComissionado, 
        a.sgAgrupamento, gp.nmGrupoOcupacional, vigencia.deCargoComissionado
      FROM ecadCargoComissionado cco
      INNER JOIN ecadGrupoOcupacional gp on gp.cdGrupoOcupacional = cco.cdGrupoOcupacional
      INNER JOIN ecadEvolucaoCargoComissionado vigencia on vigencia.cdCargoComissionado = cco.cdCargoComissionado
      INNER JOIN ecadAgrupamento a on a.cdAgrupamento = gp.cdAgrupamento
      UNION ALL
      SELECT gp.cdAgrupamento, gp.cdGrupoOcupacional, NULL AS cdCargoComissionado, 
      a.sgAgrupamento, gp.nmGrupoOcupacional, NULL AS deCargoComissionado
      FROM ecadGrupoOcupacional gp
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = gp.cdAgrupamento
      ORDER BY cdAgrupamento, cdGrupoOcupacional, cdCargoComissionado NULLS FIRST
      ),
      MotivoAfastamentoLista AS (
      SELECT cdMotivoAfastTemporario,
      deMotivoAfastTemporario, nmGrupoMotivoAfastamento, DECODE(flRemunerado, 'S', 'REMUNERADO', 'NAO REMUNERADO') AS flRemunerado
      FROM (
        SELECT grupo.nmGrupoMotivoAfastamento, vigencia.deMotivoAfastTemporario, vigencia.flremunerado,
          afamot.cdMotivoAfastTemporario, vigencia.dtInicioVigencia,
          RANK () OVER(PARTITION By vigencia.cdMotivoAfastTemporario ORDER BY vigencia.dtInicioVigencia DESC) AS ordem
        FROM eafaHistMotivoAfastTemp vigencia
        LEFT JOIN eafaMotivoAfastTemporario afamot ON afamot.cdMotivoAfastTemporario = vigencia.cdMotivoAfastTemporario
        LEFT JOIN eafaGrupoMotivoAfastamento grupo ON grupo.cdGrupoMotivoAfastamento = vigencia.cdGrupoMotivoAfastamento
      ) WHERE ordem = 1
      ),

      --- Informações referente as Prametrizações de Rubricas do Agrupamento
      ParametroTributacao AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, cdIdentificacao AS nuRubrica,
        JSON_SERIALIZE(TO_CLOB(jsConteudo) RETURNING CLOB) AS ParametroTributacao
        FROM TABLE(fnExportarParametroTributacao(psgAgrupamento, pcdIdentificacao))
      ),

      --- Informações referente as Formulas de Calculo
      Formula AS (
        SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, cdIdentificacao AS nuRubrica,
        JSON_SERIALIZE(TO_CLOB(jsConteudo) RETURNING CLOB) AS Formula
        FROM TABLE(PKGMIG_ParametrizacaoFormulasCalculo.fnExportar(psgAgrupamento, pcdIdentificacao))
      ),

      --- Informações referente aos Eventos
      Evento AS (
        SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, cdIdentificacao AS nuRubrica,
        JSON_SERIALIZE(TO_CLOB(jsConteudo) RETURNING CLOB) AS Eventos
        FROM TABLE(PKGMIG_ParametrizacaoEventosPagamento.fnExportar(psgAgrupamento, pcdIdentificacao))
      ),

      --- Informações referente as Consignações da Rubrica
      -- Referente as seguintes Tabelas:
      --   Consignacao => epagConsignacao
      --   VigenciaConsignacao => epagHistConsignacao
      --   Consignataria => epagConsignataria
      --   ConsignatariaSuspensao => epagConsignatariaSuspensao
      --   ConsignatariaTaxaServico => epagConsignatariaTaxaServico
      --   TipoServicoConsigncao => epagTipoServico
      --   VigenciaTipoServicoConsignacao => epagHistTipoServico
      --   ParametroBaseConsignacao => epagParametroBaseConsignacao
      --   ContratoServicoConsignacao => epagContratoServico
      --   
      -- Consignação  
      Consignacao AS (
        SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, cdIdentificacao AS nuRubrica,
        JSON_SERIALIZE(TO_CLOB(jsConteudo) RETURNING CLOB) AS Consignacao
        FROM TABLE(PKGMIG_ParametrizacaoConsignacoes.fnExportar(psgAgrupamento, pcdIdentificacao))
      ),

      --- Informações referente AS Rubricas e Rubricas no Agrupamento
      -- Referente AS seguintes Tabelas:
      --   TiposRubricas => epagRubrica
      --   Rubrica => epagTubrica
      --   TipoRubrica => epagRubrica
      --   GruposRubrica => epagGrupoRubricaPagamento
      --   TipoRubricaVigencia => epagHistRubrica
      --   RubricaAgrupamento => epagRubricaAgrupamento
      --   RubricaAgrupamentoVigencia => epagHistRubricaAgrupamento
      --   RubricaAgrupamentoVigencia.Abrangencias.NaturezaVinculo => epagHistRubricaAgrupNatVinc
      --   RubricaAgrupamentoVigencia.Abrangencias.RegimePrevidenciario => epagHistRubricaAgrupRegPrev
      --   RubricaAgrupamentoVigencia.Abrangencias.RegimeTrabalho => epagHistRubricaAgrupRegTrab
      --   RubricaAgrupamentoVigencia.Abrangencias.RelacaoTrabalho => epagHistRubricaAgrupRelTrab
      --   RubricaAgrupamentoVigencia.Abrangencias.SituacaoPrevidenciaria => epagHistRubricaAgrupSitPrev
      --   
      -- RubricaAgrupamentoVigencia: vigência e inventário dos agrupamentos
      RubricaAgrupamentoVigencia AS (
        SELECT vigencia.cdRubricaAgrupamento,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nuAnoMesInicioVigencia'        VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia, 2, 0),
            'nuAnoMesFimVigencia'           VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia, 2, 0),
            'DadosRubrica' VALUE JSON_OBJECT(
              'deRubricaAgrupamento'        VALUE vigencia.deRubricaAgrupamento,
              'deRubricaAgrupResumida'      VALUE vigencia.deRubricaAgrupResumida,
              'mnRelacaoTrabalho'           VALUE UPPER(relTrabVigencia.nmRelacaoTrabalho), -- cdRelacaoTrabalho
              'flCargaHorariaPadrao'        VALUE NULLIF(vigencia.flCargaHorariaPadrao, 'S'), -- DEFAULT S
              'nuCargaHorariaSemanal'       VALUE vigencia.nuCargaHorariaSemanal,
              'nuOutraRubrica'              VALUE rubOutra.nuRubrica                 -- cdOutraRubrica
            ABSENT ON NULL),
            'Inventario' VALUE JSON_OBJECT(
              'deRubricaAgrupDetalhada'     VALUE vigencia.deRubricaAgrupDetalhada,
              'deFormula'                   VALUE vigencia.deFormula,
              'deModulo'                    VALUE vigencia.deModulo,
              'deComposicao'                VALUE vigencia.deComposicao,
              'deVantagensNaoAcumulaveis'   VALUE vigencia.deVantagensNaoAcumulaveis,
              'deObservacao'                VALUE vigencia.deObservacao
            ABSENT ON NULL),
            'LancamentoFinanceiro' VALUE
            CASE WHEN NULLIF(vigencia.inPossuiValorInformado, '1') IS NULL AND NULLIF(vigencia.inLancPropRelVinc, '2')           IS NULL
              AND NULLIF(vigencia.flBloqLancFinanc, 'N')           IS NULL AND NULLIF(vigencia.flSuspensa, 'N')                  IS NULL
              AND NULLIF(vigencia.flSuspensaRetroativoErario, 'N') IS NULL AND NULLIF(vigencia.flConsolidaRubrica, 'N')          IS NULL 
              AND NULLIF(vigencia.flPermiteAfastAcidente, 'N')     IS NULL AND NULLIF(vigencia.flValidaSufixoPrecedenciaLF, 'N') IS NULL
              THEN NULL
            ELSE JSON_OBJECT(
              'inSePossuirValorInformado'   VALUE DECODE(vigencia.inPossuiValorInformado,
                                                    '1', NULL, -- 'RELACAO VINCULO PRINCIPAL',
                                                    '2', 'PARA CARGO COMISSIONADO',
                                                    '3', 'PARA SUBSTITUICAO DE CARGO COMISSIONADO',
                                                    '4', 'PARA ESPECIALIDADE COMO TITULAR',
                                                    '5', 'PARA SUBSTITUICAO DE ESPECIALIDADE',
                                                    '6', 'PARA APOSENTADORIA',
                                                    '7', 'PARA CARGO EFETIVO',
                                                  NULL),
              'inLancPropRelVinc'           VALUE DECODE(vigencia.inLancPropRelVinc,
                                                    '1', 'PARA PRINCIPAL',
                                                    '2', NULL, --'PARA TODAS',
                                                    '3', 'APENAS CARGO COMISSIONADO',
                                                    '4', 'APENAS FUNCAO DE CHEFIA',
                                                    '5', 'APENAS APOSENTADORIA',
                                                  NULL),
              'flBloqLancFinanc'            VALUE NULLIF(vigencia.flBloqLancFinanc, 'N'),
              'flSuspensa'                  VALUE NULLIF(vigencia.flSuspensa, 'N'),
              'flSuspensaRetroativoErario'  VALUE NULLIF(vigencia.flSuspensaRetroativoErario, 'N'),
              'flConsolidaRubrica'          VALUE NULLIF(vigencia.flConsolidaRubrica, 'N'),
              'flPermiteAfastAcidente'      VALUE NULLIF(vigencia.flPermiteAfastAcidente, 'N'),
              'flValidaSufixoPrecedenciaLF' VALUE NULLIF(vigencia.flValidaSufixoPrecedenciaLF, 'N')
            ABSENT ON NULL) END,
            'GerarRubrica' VALUE
            CASE WHEN NULLIF(vigencia.inGeraRubricaUO, '3')     IS NULL AND NULLIF(vigencia.inGeraRubricaCarreira, '3') IS NULL 
              AND NULLIF(vigencia.inGeraRubricaNivel, '3')      IS NULL AND NULLIF(vigencia.inGeraRubricaCCO, '3') IS NULL 
              AND NULLIF(vigencia.inGeraRubricaFUC, '3')        IS NULL AND NULLIF(vigencia.inGeraRubricaPrograma, '3') IS NULL 
              AND NULLIF(vigencia.inAposentadoriaServidor, '2') IS NULL AND NULLIF(vigencia.inGeraRubricaAfastTemp, '3') IS NULL 
              AND NULLIF(vigencia.inGeraRubricaMotMovi, '3')    IS NULL AND NULLIF(vigencia.flPagaEfetivoOrgao, 'N') IS NULL 
              AND NULLIF(vigencia.flPagAposentadoria, 'N')      IS NULL AND NULLIF(vigencia.flLaudoAcompanhamento, 'N') IS NULL 
              AND NULLIF(vigencia.flGeraRubricaCarreiraIncideApo, 'S') IS NULL
              AND NULLIF(vigencia.flGeraRubricaCarreiraIncideCCO, 'S') IS NULL 
              AND NULLIF(vigencia.flGeraRubricaCCOIncideCEF, 'S') IS NULL
              AND NULLIF(vigencia.flGeraRubricaFUCIncideCEF, 'N') IS NULL 
              AND NULLIF(vigencia.flGeraRubricaHoraExtra, 'N')    IS NULL AND NULLIF(vigencia.flGeraRubricaEscala, 'N') IS NULL 
              AND NULLIF(vigencia.flGeraRubricaServCCO, 'N')      IS NULL 
              THEN NULL
            ELSE JSON_OBJECT(
              'inGeraRubricaUO'             VALUE DECODE(vigencia.inGeraRubricaUO,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inGeraRubricaCarreira'       VALUE DECODE(vigencia.inGeraRubricaCarreira,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inGeraRubricaNivel'          VALUE DECODE(vigencia.inGeraRubricaNivel,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inGeraRubricaCCO'            VALUE DECODE(vigencia.inGeraRubricaCCO,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inGeraRubricaFUC'            VALUE DECODE(vigencia.inGeraRubricaFUC,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inGeraRubricaPrograma'       VALUE DECODE(vigencia.inGeraRubricaPrograma,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
              'inAposentadoriaServidor'     VALUE DECODE(vigencia.inAposentadoriaServidor,
                                                    '1', 'DEVE ESTAR APOSENTADO',
                                                    '2', NULL, --'DEVE TER O DIREITO A APOSENTADORIA',
                                                  NULL),
              'inGeraRubricaAfastTemp'      VALUE DECODE(vigencia.inGeraRubricaAfastTemp,
                                                    '1', 'MOTIVOS IMPEDEM',
                                                    '2', 'MOTIVOS NAO IMPEDEM',
                                                    '3', NULL, -- 'NENHUM IMPEDE'
                                                  NULL),
              'inGeraRubricaMotMovi'        VALUE DECODE(vigencia.inGeraRubricaMotMovi,
                                                    '1', 'MOTIVOS IMPEDEM',
                                                    '2', 'MOTIVOS NAO IMPEDEM',
                                                    '3', NULL, -- 'NENHUM IMPEDE'
                                                  NULL),
              'flPagaEfetivoOrgao'          VALUE NULLIF(vigencia.flPagaEfetivoOrgao, 'N'),
              'flPagAposentadoria'          VALUE NULLIF(vigencia.flPagAposentadoria, 'N'),
              'flLaudoAcompanhamento'       VALUE NULLIF(vigencia.flLaudoAcompanhamento, 'N'),
              'flGeraRubricaCarreiraIncideApo' VALUE NULLIF(vigencia.flGeraRubricaCarreiraIncideApo, 'S'), -- DEFAULT S
              'flGeraRubricaCarreiraIncideCCO' VALUE NULLIF(vigencia.flGeraRubricaCarreiraIncideCCO, 'S'), -- DEFAULT S
              'flGeraRubricaCCOIncideCEF'   VALUE NULLIF(vigencia.flGeraRubricaCCOIncideCEF, 'S'), -- DEFAULT S
              'flGeraRubricaFUCIncideCEF'   VALUE NULLIF(vigencia.flGeraRubricaFUCIncideCEF, 'N'),
              'flGeraRubricaHoraExtra'      VALUE NULLIF(vigencia.flGeraRubricaHoraExtra, 'N'),
              'flGeraRubricaEscala'         VALUE NULLIF(vigencia.flGeraRubricaEscala, 'N'),
              'flGeraRubricaServCCO'        VALUE NULLIF(vigencia.flGeraRubricaServCCO, 'N'),
              'ListaEstruturaCarreira'      VALUE (
                SELECT JSON_ARRAYAGG(cef.nmEstruturaCarreira
                ORDER BY UPPER(cef.nmEstruturaCarreira) ABSENT ON NULL RETURNING CLOB) AS ListaEstruturaCarreira
                FROM epagHistRubricaAgrupCarreira carreiraPermitidas
                INNER JOIN EstruturaCarreiraLista cef ON cef.cdEstruturaCarreira = carreiraPermitidas.cdEstruturaCarreira
                WHERE carreiraPermitidas.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaFuncaoChefia'           VALUE NULL, --(ListaFuncaoChefia ABSENT ON NULL RETURNING CLOB),
              'ListaCargoComissionado'      VALUE (
                SELECT JSON_ARRAYAGG(JSON_OBJECT(
                  'nmGrupoOcupacional'    VALUE cco.nmGrupoOcupacional,
                  'deCargoComissionado'   VALUE cco.deCargoComissionado
                  ABSENT ON NULL) ORDER BY cco.nmGrupoOcupacional, cco.deCargoComissionado
                ABSENT ON NULL RETURNING CLOB) AS ListaCargoComissionado
                FROM epagHistRubricaAgrupCCO ccoPermitidos
                LEFT JOIN CargoComissionadoLista cco ON cco.cdGrupoOcupacional = ccoPermitidos.cdGrupoOcupacional
                                                    AND NVL(cco.cdCargoComissionado,0) = NVL(ccoPermitidos.cdCargoComissionado,0)
                WHERE ccoPermitidos.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaModeloAposentadoria'    VALUE NULL, -- (ListaModeloAposentadoria ABSENT ON NULL RETURNING CLOB),
              'ListaMotivosConvocacao'      VALUE NULL, -- (ListaMotivosConvocacao ABSENT ON NULL RETURNING CLOB),
              'ListaMotivosMovimentacao'    VALUE NULL, -- (ListaMotivosMovimentacao ABSENT ON NULL RETURNING CLOB),
              'ListaPrograma'               VALUE NULL, -- (ListaPrograma ABSENT ON NULL RETURNING CLOB),
              'ListaUnidadeOrganizacional'  VALUE NULL, -- (ListaUnidadeOrganizacional ABSENT ON NULL RETURNING CLOB),
              'ListaNivelReferencia'        VALUE (
                SELECT JSON_ARRAYAGG(JSON_OBJECT(
                  'nuNivel'                 VALUE nivref.nuNivel,
                  'nuReferencia'            VALUE nivref.nuReferencia
                ABSENT ON NULL) ORDER BY nivref.nuNivel, nivref.nuReferencia
                ABSENT ON NULL RETURNING CLOB) AS ListaNivelReferencia
                FROM epagHistRubricaAgrupNivelRef nivref
                WHERE nivref.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento)
            ABSENT ON NULL) END,
            'Proporcionalidade' VALUE
            CASE WHEN tpIndice.deTipoIndice                       IS NULL AND vigencia.nuMesesApuracao                         IS NULL
              AND NULLIF(vigencia.cdRubProporcionalidadeCHO, 1)   IS NULL AND NULLIF(vigencia.flPropMesComercial, 'S')         IS NULL
              AND NULLIF(vigencia.flCargaHorariaLimitada, 'N')    IS NULL AND NULLIF(vigencia.flPropAposParidade, 'N')         IS NULL
              AND NULLIF(vigencia.flIncidParcialContrPrev, 'N')   IS NULL AND NULLIF(vigencia.flPagaMaiorRV, 'N')              IS NULL
              AND NULLIF(vigencia.flPercentLimitado100, 'N')      IS NULL AND NULLIF(vigencia.flPercentReducaoAfastRemun, 'N') IS NULL
              AND NULLIF(vigencia.flPropServRelVinc, 'N')         IS NULL AND NULLIF(vigencia.flPropAfaComissionado, 'N')      IS NULL
              AND NULLIF(vigencia.flPropAfaCCOSubst, 'N')         IS NULL AND NULLIF(vigencia.flPropAfaComOpcPercCEF, 'N')     IS NULL
              AND NULLIF(vigencia.flPropAfaFGFTG, 'N')            IS NULL AND NULLIF(vigencia.flPropAfastTempNaoRemun, 'N')    IS NULL
              AND NULLIF(vigencia.flIgnoraAfastCEFAgPolitico, 'N') IS NULL
              AND NOT EXISTS (SELECT 1 FROM epagRubAgrupMotAfastTempImp WHERE cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento)
              AND NOT EXISTS (SELECT 1 FROM epagRubAgrupMotAfastTempEx  WHERE cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento)
              THEN NULL
            ELSE JSON_OBJECT(
              'deTipoIndice'                VALUE tpIndice.deTipoIndice,       -- cdTipoIndice
              'nmRubProporcionalidadeCHO'   VALUE DECODE(vigencia.cdRubProporcionalidadeCHO,
                                                    '1', NULL, --'NAO APLICAR',
                                                    '2', 'APLICAR',
                                                    '3', 'APLICAR MEDIA',
                                                  NULL),
              'nuMesesApuracao'             VALUE vigencia.nuMesesApuracao,
              'flPropMesComercial'          VALUE NULLIF(vigencia.flPropMesComercial, 'S'), -- DEFAULT S
              'flCargaHorariaLimitada'      VALUE NULLIF(vigencia.flCargaHorariaLimitada, 'N'),
              'flIgnoraAfastCEFAgPolitico'  VALUE NULLIF(vigencia.flIgnoraAfastCEFAgPolitico, 'N'),
              'flIncidParcialContrPrev'     VALUE NULLIF(vigencia.flIncidParcialContrPrev, 'N'),
              'flPagaMaiorRV'               VALUE NULLIF(vigencia.flPagaMaiorRV, 'N'),
              'flPercentLimitado100'        VALUE NULLIF(vigencia.flPercentLimitado100, 'N'),
              'flPercentReducaoAfastRemun'  VALUE NULLIF(vigencia.flPercentReducaoAfastRemun, 'N'),
              'flPropServRelVinc'           VALUE NULLIF(vigencia.flPropServRelVinc, 'N'),
              'flPropAfaComissionado'       VALUE NULLIF(vigencia.flPropAfaComissionado, 'N'),
              'flPropAfaCCOSubst'           VALUE NULLIF(vigencia.flPropAfaCCOSubst, 'N'),
              'flPropAfaComOpcPercCEF'      VALUE NULLIF(vigencia.flPropAfaComOpcPercCEF, 'N'),
              'flPropAfaFGFTG'              VALUE NULLIF(vigencia.flPropAfaFGFTG, 'N'),
              'flPropAfastTempNaoRemun'     VALUE NULLIF(vigencia.flPropAfastTempNaoRemun, 'N'),
              'flPropAposParidade'          VALUE NULLIF(vigencia.flPropAposParidade, 'N'),
              'ListaCargasHorarias'         VALUE NULL, -- (ListaCargasHorarias ABSENT ON NULL RETURNING CLOB),
              'ListaMotivosAfastamentoQueImpedem' VALUE (
                SELECT JSON_ARRAYAGG(motivoTemp.deMotivoAfastTemporario ORDER BY motivoTemp.deMotivoAfastTemporario
                RETURNING CLOB) AS ListaMotivosAfastamentoQueImpedem
                FROM epagRubAgrupMotAfastTempImp afamottempimp
                LEFT JOIN MotivoAfastamentoLista motivoTemp ON motivoTemp.cdMotivoAfastTemporario = afamottempimp.cdMotivoAfastTemporario
                WHERE afamottempimp.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaMotivosAfastamentoExigidos' VALUE (
                SELECT JSON_ARRAYAGG(JSON_OBJECT(
                  'deMotivoAfastTemporario' VALUE motivoTemp.deMotivoAfastTemporario,
                  'nmPeriodoAfastamento'    VALUE UPPER(periodo.nmPeriodoAfastamento),
                  'flAfastamentoVinculado'  VALUE NULLIF(afamottempex.flAfastamentoVinculado,'N'),
                  'nuPeriodo'               VALUE afamottempex.nuPeriodo
                ) ORDER BY motivoTemp.deMotivoAfastTemporario RETURNING CLOB) AS ListaMotivosAfastamentoExigidos
                FROM epagRubAgrupMotAfastTempEx afamottempex
                LEFT JOIN epagPeriodoAfastamento periodo ON periodo.cdPeriodoAfastamento = afamottempex.cdPeriodoAfastamento
                LEFT JOIN MotivoAfastamentoLista motivoTemp ON motivoTemp.cdMotivoAfastTemporario = afamottempex.cdMotivoAfastTemporario
                WHERE afamottempex.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento)
            ABSENT ON NULL) END,
            'PermissoesRubrica' VALUE JSON_OBJECT(
              'inImpedimentoRubrica'        VALUE DECODE(vigencia.inImpedimentoRubrica,
                                                    '1', 'POSSUA TODAS IMPEDIRA',
                                                    '2', 'POSSUA AO MENOS UMA IMPEDIRA',
                                                    '3', NULL, --'NAO SE APLICA',
                                                  NULL),
              'inRubricasExigidas'          VALUE DECODE(vigencia.inRubricasExigidas,
                                                    '1', 'POSSUA TODAS PERMITIRA',
                                                    '2', 'POSSUA AO MENOS UMA PERMITIRA',
                                                    '3', NULL, --'NAO SE APLICA',
                                                  NULL),
              'flAplicaRubricaOrgaos'       VALUE NULLIF(vigencia.flAplicaRubricaOrgaos, 'S'), -- DEFAULT S
              'flGestaoSobreRubrica'        VALUE NULLIF(vigencia.flGestaoSobreRubrica, 'N'),
              'flImpedeIdadeCompulsoria'    VALUE NULLIF(vigencia.flImpedeIdadeCompulsoria, 'N'),
              'flPagaAposEmParidade'        VALUE NULLIF(vigencia.flPagaAposEmParidade, 'N'),
              'flPagaRespondendo'           VALUE NULLIF(vigencia.flPagaRespondendo, 'N'),
              'flPagaSubstituicao'          VALUE NULLIF(vigencia.flPagaSubstituicao, 'N'),
              'flPermiteApoOriginadoCCO'    VALUE NULLIF(vigencia.flPermiteApoOriginadoCCO, 'N'),
              'flPermiteFGFTG'              VALUE NULLIF(vigencia.flPermiteFGFTG, 'N'),
              'flPreservaValorIntegral'     VALUE NULLIF(vigencia.flPreservaValorIntegral, 'N'),
              'ListaOrgaoPermitidos'        VALUE (
                SELECT JSON_ARRAYAGG(JSON_OBJECT(
                  'sgOrgao'                 VALUE o.sgOrgao,
                  'flGestaoRubrica'         VALUE NULLIF(orgPermitidos.flGestaoRubrica, 'N'),
                  'inLotadoExercicio'       VALUE DECODE(orgPermitidos.inLotadoExercicio, '1', NULL, '2', 'EM EXERCICIO', NULL)
                ABSENT ON NULL)  ORDER BY UPPER(o.sgOrgao) ABSENT ON NULL RETURNING CLOB) AS ListaOrgaoPermitidos
                FROM epagHistRubricaAgrupOrgao orgPermitidos
                INNER JOIN OrgaoLista o ON o.cdOrgao = orgPermitidos.cdOrgao
                WHERE orgpermitidos.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaRubricaQueImpedem'      VALUE (
                SELECT JSON_ARRAYAGG(
                  TRIM(rub.nuRubrica || ' ' || rub.deRubrica) ORDER BY UPPER(rub.nuRubrica)) AS ListaRubricaQueImpedem
                FROM epagHistRubricaAgrupImpeditiva rubimp
                INNER JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = rubimp.cdRubricaAgrupamento
                WHERE rubimp.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaRubricaExigidas'        VALUE (
                SELECT JSON_ARRAYAGG(
                  TRIM(rub.nuRubrica || ' ' || rub.deRubrica) ORDER BY UPPER(rub.nuRubrica)) AS ListaRubricaExigidas
                FROM epagHistRubricaAgrupExigida rubexig
                INNER JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = rubexig.cdRubricaAgrupamento
                WHERE rubexig.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'NaturezaVinculo' VALUE (
                SELECT JSON_ARRAYAGG(UPPER(natVinc.nmNaturezaVinculo) ORDER BY UPPER(natVinc.nmNaturezaVinculo)) AS NaturezaVinculo
                FROM epagHistRubricaAgrupNatVinc vigNatVinc
                INNER JOIN ecadNaturezaVinculo natVinc ON natVinc.cdNaturezaVinculo = vigNatVinc.cdNaturezaVinculo
                WHERE vigNatVinc.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'RegimePrevidenciario' VALUE (
                SELECT JSON_ARRAYAGG(UPPER(regPrev.nmRegimePrevidenciario) ORDER BY UPPER(regPrev.nmRegimePrevidenciario)) AS RegimePrevidenciario
                FROM epagHistRubricaAgrupRegPrev vigRegPrev
                INNER JOIN ecadRegimePrevidenciario regPrev ON regPrev.cdRegimePrevidenciario = vigRegPrev.cdRegimePrevidenciario
                WHERE vigRegPrev.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'RegimeTrabalho' VALUE (
                SELECT JSON_ARRAYAGG(UPPER(regTrab.nmRegimeTrabalho) ORDER BY UPPER(regTrab.nmRegimeTrabalho)) AS RegimeTrabalho
                FROM epagHistRubricaAgrupRegTrab vigRegTrab
                INNER JOIN ecadRegimeTrabalho regTrab ON regTrab.cdRegimeTrabalho = vigRegTrab.cdRegimeTrabalho
                WHERE vigRegTrab.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'RelacaoTrabalho' VALUE (
                SELECT JSON_ARRAYAGG(UPPER(relTrab.nmRelacaoTrabalho) ORDER BY UPPER(relTrab.nmRelacaoTrabalho)) AS RelacaoTrabalho
                FROM epagHistRubricaAgrupRelTrab vigRelTrab
                INNER JOIN ecadRelacaoTrabalho relTrab ON relTrab.cdRelacaoTrabalho = vigRelTrab.cdRelacaoTrabalho
                WHERE vigRelTrab.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'SituacaoPrevidenciaria' VALUE (
                SELECT JSON_ARRAYAGG(UPPER(sitPrev.nmSituacaoPrevidenciaria) ORDER BY UPPER(sitPrev.nmSituacaoPrevidenciaria)) AS SituacaoPrevidenciaria
                FROM epagHistRubricaAgrupSitPrev vigSitPrev
                INNER JOIN ecadSituacaoPrevidenciaria sitPrev ON sitPrev.cdSituacaoPrevidenciaria = vigSitPrev.cdSituacaoPrevidenciaria
                WHERE vigSitPrev.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento)
              ABSENT ON NULL RETURNING CLOB) ABSENT ON NULL)
      	ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia, 2, 0) DESC RETURNING CLOB
      	) AS VigenciasAgrupamento
        FROM epagHistRubricaAgrupamento vigencia
        LEFT JOIN ecadRelacaoTrabalho relTrabVigencia ON relTrabVigencia.cdRelacaoTrabalho = vigencia.cdRelacaoTrabalho
        LEFT JOIN RubricaLista rubOutra ON rubOutra.cdRubricaAgrupamento = vigencia.cdOutraRubrica
        LEFT JOIN epagTipoIndice tpIndice ON tpIndice.cdTipoIndice = vigencia.cdTipoIndice
        GROUP BY vigencia.cdRubricaAgrupamento
      ),
      -- RubricaAgrupamento: estrutura completa da Rubrica no Agrupamento
      RubricaAgrupamento AS (
      SELECT rub.nuRubrica, rub.cdAgrupamento, rubagrup.cdRubricaAgrupamento,
        a.sgAgrupamento,
        o.sgOrgao,
        JSON_OBJECT(
          'RubricaPropria'                  VALUE
      	  CASE WHEN NULLIF(rubagrup.flIncorporacao, 'N')   IS NULL AND NULLIF(rubagrup.flPensaoAlimenticia, 'N')    IS NULL
      	    AND NULLIF(rubagrup.flAdiant13Pensao, 'N')     IS NULL AND NULLIF(rubagrup.fl13SalPensao, 'N')          IS NULL
      	    AND NULLIF(rubagrup.flConsignacao, 'N')        IS NULL AND NULLIF(rubagrup.flTributacao, 'N')           IS NULL
      	    AND NULLIF(rubagrup.flSalarioFamilia, 'N')     IS NULL AND NULLIF(rubagrup.flSalarioMaternidade, 'N')   IS NULL
      	    AND NULLIF(rubagrup.flDevTributacaoIPREV, 'N') IS NULL AND NULLIF(rubagrup.flDevCorrecaoMonetaria, 'N') IS NULL
      	    AND NULLIF(rubagrup.flAbonoPermanencia, 'N')   IS NULL AND NULLIF(rubagrup.flApostilamento, 'N')        IS NULL
      	    AND NULLIF(rubagrup.flContribuicaoSindical, 'N') IS NULL AND parm.ParametroTributacao IS NULL
      			THEN NULL
      		ELSE JSON_OBJECT(
            'flIncorporacao'                VALUE NULLIF(rubagrup.flIncorporacao, 'N'),
            'flPensaoAlimenticia'           VALUE NULLIF(rubagrup.flPensaoAlimenticia, 'N'),
            'flAdiant13Pensao'              VALUE NULLIF(rubagrup.flAdiant13Pensao, 'N'),
            'fl13SalPensao'                 VALUE NULLIF(rubagrup.fl13SalPensao, 'N'),
            'flConsignacao'                 VALUE NULLIF(rubagrup.flConsignacao, 'N'),
            'flTributacao'                  VALUE NULLIF(rubagrup.flTributacao, 'N'),
            'flSalarioFamilia'              VALUE NULLIF(rubagrup.flSalarioFamilia, 'N'),
            'flSalarioMaternidade'          VALUE NULLIF(rubagrup.flSalarioMaternidade, 'N'),
            'flDevTributacaoIPREV'          VALUE NULLIF(rubagrup.flDevTributacaoIPREV, 'N'),
            'flDevCorrecaoMonetaria'        VALUE NULLIF(rubagrup.flDevCorrecaoMonetaria, 'N'),
            'flAbonoPermanencia'            VALUE NULLIF(rubagrup.flAbonoPermanencia, 'N'),
            'flApostilamento'               VALUE NULLIF(rubagrup.flApostilamento, 'N'),
            'flContribuicaoSindical'        VALUE NULLIF(rubagrup.flContribuicaoSindical, 'N'),
            'ParametroTributacao'           VALUE parm.ParametroTributacao
          ABSENT ON NULL) END,
          'ParametrosAgrupamento'           VALUE
          CASE WHEN modrub.nmModalidadeRubrica          IS NULL AND baseCalculo.sgBaseCalculo               IS NULL
            AND NULLIF(rubagrup.flVisivelServidor, 'S') IS NULL AND NULLIF(rubagrup.flGeraSuplementar, 'S') IS NULL
            AND NULLIF(rubagrup.flConsad, 'N')          IS NULL AND NULLIF(rubagrup.flCompoe13, 'N')        IS NULL
            AND NULLIF(rubagrup.flPropria13, 'N')       IS NULL AND NULLIF(rubagrup.flEmpenhadaFilial, 'N') IS NULL
            AND rubagrup.nuElemDespesaAtivo             IS NULL AND rubagrup.nuElemDespesaInativo           IS NULL
            AND rubagrup.nuElemDespesaAtivoCLT          IS NULL AND rubagrup.nuOrdemConsad                  IS NULL 
            THEN NULL
          ELSE JSON_OBJECT(
            'nmModalidadeRubrica'           VALUE modrub.nmModalidadeRubrica,
            'sgBaseCalculo'                 VALUE baseCalculo.sgBaseCalculo,
            'flVisivelServidor'             VALUE NULLIF(rubagrup.flVisivelServidor, 'S'),  -- DEFAULT S
            'flGeraSuplementar'             VALUE NULLIF(rubagrup.flGeraSuplementar, 'S'),  -- DEFAULT S
            'flConsad'                      VALUE NULLIF(rubagrup.flConsad, 'N'),
            'flCompoe13'                    VALUE NULLIF(rubagrup.flCompoe13, 'N'),
            'flPropria13'                   VALUE NULLIF(rubagrup.flPropria13, 'N'),
            'flEmpenhadaFilial'             VALUE NULLIF(rubagrup.flEmpenhadaFilial, 'N'),
            'nuElemDespesaAtivo'            VALUE rubagrup.nuElemDespesaAtivo,
            'nuElemDespesaInativo'          VALUE rubagrup.nuElemDespesaInativo,
            'nuElemDespesaAtivoCLT'         VALUE rubagrup.nuElemDespesaAtivoCLT,
            'nuOrdemConsad'                 VALUE rubagrup.nuOrdemConsad
          ABSENT ON NULL) END,
          'VigenciasAgrupamento'            VALUE vigencia.VigenciasAgrupamento,
          'Consignacao'                     VALUE Consignacao.Consignacao,
          'Eventos'                         VALUE evento.Eventos,
          'Formula'                         VALUE formula.Formula
        ABSENT ON NULL RETURNING CLOB) AS RubricaAgrupamento
      FROM epagRubricaAgrupamento rubagrup
      INNER JOIN RubricaLista rub ON rub.cdAgrupamento = rubagrup.cdAgrupamento
                                 AND rub.cdRubrica = rubagrup.cdRubrica
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrup.cdAgrupamento
      LEFT JOIN ecadHistOrgao o ON o.cdOrgao = rubagrup.cdOrgao
      LEFT JOIN epagModalidadeRubrica modrub ON modrub.cdModalidadeRubrica = rubagrup.cdModalidadeRubrica
      LEFT JOIN epagBaseCalculo baseCalculo ON baseCalculo.cdBaseCalculo = rubagrup.cdBaseCalculo
      LEFT JOIN RubricaAgrupamentoVigencia vigencia ON vigencia.cdRubricaAgrupamento = rubagrup.cdRubricaAgrupamento
      LEFT JOIN Consignacao consignacao ON consignacao.nuRubrica = rub.nuRubrica
      LEFT JOIN Evento evento ON evento.nuRubrica = rub.nuRubrica
      LEFT JOIN Formula formula ON formula.nuRubrica = rub.nuRubrica
      LEFT JOIN ParametroTributacao parm ON parm.nuRubrica = rub.nuRubrica
        WHERE a.sgAgrupamento = psgAgrupamento
          AND (rub.nuRubrica = pcdIdentificacao OR pcdIdentificacao IS NULL)
        ORDER BY rub.nuRubrica
      )
      SELECT 
        sgAgrupamento AS sgAgrupamento,
        nuRubrica AS cdIdentificacao,
        RubricaAgrupamento AS jsConteudo
      FROM RubricaAgrupamento
      ORDER BY sgAgrupamento, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorRubricasAgrupamento;

END PKGMIG_ParametrizacaoRubricasAgrupamento;
/
