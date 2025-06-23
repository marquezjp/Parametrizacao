-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoRubricasAgrupamento AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
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

      modRub.cdModalidadeRubrica AS cdModalidadeRubrica, js.nmmodalidaderubrica,
      baseCalc.cdBaseCalculo AS cdBaseCalculo, js.sgbasecalculo,

      NVL(js.flVisivelServidor, 'N') AS flVisivelServidor,
      NVL(js.flGeraSuplementar, 'N') AS flGeraSuplementar,
      NVL(js.flConsad, 'N') AS flConsad,
      NVL(js.flCompoe13, 'N') AS flCompoe13,
      NVL(js.flPropria13, 'N') AS flPropria13,
      NVL(js.flEmpenhadaFilial, 'N') AS flEmpenhadaFilial,

      js.nuElemDespesaAtivo AS nuElemDespesaAtivo,
      js.nuElemDespesaInativo AS nuElemDespesaInativo,
      js.nuElemDespesaAtivoCLT AS nuElemDespesaAtivoCLT,
      js.nuOrdemConsad AS nuOrdemConsad,

      VigenciasAgrupamento,
      EventosPagamento,
      FormulaCalculo,

      SYSTIMESTAMP AS dtUltAlteracao
      
      FROM JSON_TABLE(JSON_QUERY(pAgrupamento, '$'), '$[*]' COLUMNS (
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
        EventosPagamento       CLOB FORMAT JSON PATH '$.Eventos',
        FormulaCalculo         CLOB FORMAT JSON PATH '$.Formula'
      )) js
      INNER JOIN OrgaoLista o ON o.sgAgrupamento = psgAgrupamentoDestino AND NVL(o.sgOrgao, ' ') = NVL(psgOrgao, ' ')
      LEFT JOIN epagRubricaAgrupamento rubAgp ON rubAgp.cdAgrupamento = o.cdAgrupamento AND rubAgp.cdRubrica = pcdRubrica
      LEFT JOIN epagModalidadeRubrica modRub ON modRub.nmModalidadeRubrica = js.nmModalidadeRubrica
      LEFT JOIN epagBaseCalculo baseCalc ON baseCalc.cdAgrupamento = o.cdAgrupamento AND baseCalc.cdOrgao = o.cdOrgao
                                         AND baseCalc.sgBaseCalculo = js.sgBaseCalculo
      )
      SELECT * FROM epagRubricaAgrupamentoImportar;

    BEGIN
  
      vcdIdentificacao := pcdIdentificacao;
  
      -- Loop principal de processamento
      FOR r IN cDados LOOP
  
        vcdIdentificacao := pcdIdentificacao;
         
        PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica - Rubrica Agrupamento ' || vcdIdentificacao,
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
  
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
  
          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
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
  
          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
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
  
        -- Importar Eventos de Pagamento da Rubrica do Agrupamento
        PKGMIG_ParametrizacaoEventosPagamento.pImportar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.EventosPagamento, pnuNivelAuditoria);
  
        -- Importar Formulas de Calculo da Rubrica do Agrupamento
        PKGMIG_ParametrizacaoFormulasCalculo.pImportar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.FormulaCalculo, pnuNivelAuditoria);
  
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica - Rubrica Agrupamento ' || vcdIdentificacao ||
        ' RUBRICA AGRUPAMENTO Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'RUBRICA AGRUPAMENTO', 'ERRO', 'Erro: ' || SQLERRM,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      ROLLBACK;
      RAISE;
  END pImportar;

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

    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
      psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
      'RUBRICA AGRUPAMENTO VIGENCIA ', 'EXCLUSAO',
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA CARREIRAS', 'EXCLUSAO',
        'Carreiras na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NIVREF', 'EXCLUSAO',
        'Níveis e Referencias na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA COMISSIONADOS', 'EXCLUSAO',
        'Cargos Comissiondos na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA UNID. ORG.', 'EXCLUSAO',
        'Unidades Organizacionais na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA AFAST. IMPEDEM', 'EXCLUSAO',
        'Motivos Afastamento que Impedem na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA AFAST. EXIGIDOS', 'EXCLUSAO',
        'Motivos Afastamento Exigidos na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA MOT. MOVIMENTACAO', 'EXCLUSAO',
        'Motivos Movimentação na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA CONVOCACAO', 'EXCLUSAO',
        'Motivos Convocação na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA ORGAOS', 'EXCLUSAO',
        'Órgãos Permitidas na Vigência da Rubrica do Agrupamento excluidos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUB. IMPEDEM', 'EXCLUSAO',
        'Rubricas que Impedem na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUG. EXIGIDAS', 'EXCLUSAO',
        'Rubricas Exigidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'EXCLUSAO',
        'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGPREV', 'EXCLUSAO',
        'Regimes Previdenciários Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGTRAB', 'EXCLUSAO',
        'Regimes de Trabalho Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RELTRAB', 'EXCLUSAO',
        'Relações de Trabalho Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA SITPREV', 'EXCLUSAO',
        'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

     -- Excluir as Vigências existentes da Rubrica do Agrupamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupamento
    WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupamento WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'EXCLUSAO',
        'Vigências existentes da Rubrica do Agrupamento excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica - Rubrica Agrupamento' || vcdIdentificacao ||
        ' RUBRICA AGRUPAMENTO VIGENCIA EXCLUIR Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA EXCLUIR', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
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
        NVL(UPPER(js.flCargaHorariaPadrao), 'N') AS flCargaHorariaPadrao,
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
        NVL(UPPER(js.flGeraRubricaCarreiraIncideApo), 'N') AS flGeraRubricaCarreiraIncideApo,
        NVL(UPPER(js.flGeraRubricaCarreiraIncideCCO), 'N') AS flGeraRubricaCarreiraIncideCCO,
        NVL(UPPER(js.flGeraRubricaCCOIncideCEF), 'N') AS flGeraRubricaCCOIncideCEF,
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
        NVL(UPPER(js.flPropMesComercial), 'N') AS flPropMesComercial,
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
        
        NVL(UPPER(js.flAplicaRubricaOrgaos), 'N') AS flAplicaRubricaOrgaos,
        NVL(UPPER(js.flGestaoSobreRubrica), 'N') AS flGestaoSobreRubrica,
        NVL(UPPER(js.flImpedeIdadeCompulsoria), 'N') AS flImpedeIdadeCompulsoria,
        NVL(UPPER(js.flPagaAposEmParidade), 'N') AS flPagaAposEmParidade,
        NVL(UPPER(js.flPagaRespondendo), 'N') AS flPagaRespondendo,
        NVL(UPPER(js.flPagaSubstituicao), 'N') AS flPagaSubstituicao,
        NVL(UPPER(js.flPermiteApoOriginadoCCO), 'N') AS flPermiteApoOriginadoCCO,
        NVL(UPPER(js.flPermiteFGFTG), 'N') AS flPermiteFGFTG,
        NVL(UPPER(js.flPreservaValorIntegral), 'N') AS flPreservaValorIntegral,

        js.ListaEstruturaCarreira,
        js.ListaFuncaoChefia,
        js.ListaCargoComissionado,
        js.ListaModeloAposentadoria,
        js.ListaMotivosConvocacao,
        js.ListaMotivosMovimentacao,
        js.ListaPrograma,
        js.ListaUnidadeOrganizacional,
        js.ListaNivelReferencia,
        js.ListaCargasHorarias,
        js.ListaMotivosAfastamentoQueImpedem,
        js.ListaMotivosAfastamentoExigidos,
        JSON_OBJECT('ListasVigenciasAgrupamento' VALUE JSON_OBJECT(
          'ListaFuncaoChefia'                 VALUE js.ListaFuncaoChefia,
          'ListaModeloAposentadoria'          VALUE js.ListaModeloAposentadoria,
          'ListaMotivosConvocacao'            VALUE js.ListaMotivosConvocacao,
          'ListaMotivosMovimentacao'          VALUE js.ListaMotivosMovimentacao,
          'ListaPrograma'                     VALUE js.ListaPrograma,
          'ListaUnidadeOrganizacional'        VALUE js.ListaUnidadeOrganizacional,
          'ListaCargasHorarias'               VALUE js.ListaCargasHorarias,
          'ListaMotivosAfastamentoQueImpedem' VALUE (
            SELECT JSON_ARRAYAGG(JSON_OBJECT(
              'deMotivoAfastTemporario'       VALUE lst.deMotivoAfastTemporario,
              'cdMotivoAfastTemporario'       VALUE afaLst.cdMotivoAfastTemporario
            ABSENT ON NULL RETURNING CLOB) RETURNING CLOB)
            FROM JSON_TABLE(js.ListaMotivosAfastamentoQueImpedem, '$[*]' COLUMNS (deMotivoAfastTemporario PATH '$')) lst
            LEFT JOIN MotivoAfastamentoLista afaLst ON afaLst.deMotivoAfastTemporario = lst.deMotivoAfastTemporario),
          'ListaMotivoAfastamentoExigidos'    VALUE (
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
          'ListaNivelReferencia'              VALUE ListaNivelReferencia,

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

          'NaturezaVinculo'                   VALUE js.NaturezaVinculo,
          'RegimePrevidenciario'              VALUE js.RegimePrevidenciario,
          'RegimePrevidenciario'              VALUE js.RegimeTrabalho,
          'RelacaoTrabalho'                   VALUE js.RelacaoTrabalho,
          'SituacaoPrevidenciaria'            VALUE js.SituacaoPrevidenciaria
        RETURNING CLOB) RETURNING CLOB) AS ListasVigenciasAgrupamento,

        '11111111111' AS nuCPFCadastrador,
        TRUNC(SYSDATE) AS dtInclusao,
        systimestamp AS dtUltAlteracao

      FROM JSON_TABLE(JSON_QUERY(pVigenciasAgrupamento, '$'), '$[*]' COLUMNS (
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

    -- Loop principal de processamento para Incluir a Vigências da Rubrica do Agrupamento
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0);

      PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica do Agrupamento - Vigências ' || vcdIdentificacao,
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      SELECT NVL(MAX(cdhistrubricaagrupamento), 0) + 1 INTO vcdHistRubricaAgrupamentoNova FROM epagHistRubricaAgrupamento;

        IF r.cdRelacaoTrabalho IS NULL AND r.nmRelacaoTrabalho IS NOT NULL THEN
          PKGMIG_Parametrizacao.PConsoleLog('da Rubrica do Agrupamento - ' ||
            'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.nmRelacaoTrabalho,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmRelacaoTrabalho, 1,
            'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
            'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdOutraRubrica IS NULL AND r.nuOutraRubrica IS NOT NULL THEN
          PKGMIG_Parametrizacao.PConsoleLog('da Rubrica do Agrupamento - ' ||
            'Outra Rubrica da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.nuOutraRubrica,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nuOutraRubrica, 1,
            'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
            'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdTipoIndice IS NULL AND r.deTipoIndice IS NOT NULL THEN
          PKGMIG_Parametrizacao.PConsoleLog('da Rubrica do Agrupamento - ' ||
            'Tipo de Índice da Vigência da Rubrica do Agrupamento Inexistente ' || vcdIdentificacao || ' ' || r.deTipoIndice,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.deTipoIndice, 1,
            'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
            'Tipo de Índice da Vigência da Rubrica do Agrupamento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdRubProporcionalidadeCHO IS NULL AND r.nmRubProporcionalidadeCHO IS NOT NULL THEN
          PKGMIG_Parametrizacao.PConsoleLog('da Rubrica do Agrupamento - ' ||
            'Rubrica Proporcionlidade de Carga Horária da Vigência da Rubrica do Agrupamento Inexistente ' ||
            vcdIdentificacao || ' ' || r.nmRubProporcionalidadeCHO,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmRubProporcionalidadeCHO, 1,
            'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
            'Relação de Trabalho da Vigência da Rubrica do Agrupamento Inexistente',
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA LISTAS', 'JSON', r.ListasVigenciasAgrupamento,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Incluir Listas da Vigencia da Rubrica do Agrupamento
      pImportarListasRubricaAgrupamento(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, pcdIdentificacao, vcdHistRubricaAgrupamentoNova, r.ListasVigenciasAgrupamento, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica - Rubrica Agrupamento Vigência ' || vcdIdentificacao ||
        ' RUBRICA AGRUPAMENTO VIGENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;

  PROCEDURE pImportarListasRubricaAgrupamento(
  -- ###########################################################################
  -- PROCEDURE: pIncluirPermissoesRubricaAgrupamento
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
    pcdHistRubricaAgrupamento IN NUMBER,
    pListasVigenciasAgrupamento IN CLOB,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN
    
    vnuRegistros := 0;

    -- Incluir ListaUnidadesOrganizacionais
    -- Incluir ListaMotivosAfastamentoQueImpedem
    -- Incluir ListaMotivosAfastamentoExigidos
    -- Incluir ListaMotivosMovimentação
    -- Incluir ListaMotivosConvocação

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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
		    'Motivos de Afastamento que Impedem na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.deMotivoAfastTemporario, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
		    'Motivos de Afastamento que Impedem da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Estruturas de Carreiras na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmEstruturaCarreira, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Níveis e Referencia Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nuNivel || ' ' || i.nuReferencia, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE',
        'Níveis e Referencia Permitido da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

    -- Incluir Cargos Comissionados Permitidas na Vigência da Rubrica do Agrupamento
    vnuRegistros := 0;
    SELECT COUNT(*) INTO vnuRegistros
    FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
      cdGrupoOcupacional PATH '$.cdGrupoOcupacional'
    )) js
    WHERE js.cdGrupoOcupacional IS NOT NULL;
    
    IF vnuRegistros > 0 THEN
      INSERT INTO epagHistRubricaAgrupCCO (cdGrupoOcupacional, cdHistRubricaAgrupamento, cdCargoComissionado)
      SELECT js.cdGrupoOcupacional, pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, js.cdCargoComissionado
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
        cdGrupoOcupacional  PATH '$.cdGrupoOcupacional',
        cdCargoComissionado PATH '$.cdCargoComissionado'
      )) js
      WHERE js.cdGrupoOcupacional IS NOT NULL;
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Cargos Comissionados na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.nmGrupoOcupacional, js.deCargoComissionado, js.cdGrupoOcupacional
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.ListaCargoComissionado[*]' COLUMNS (
        nmGrupoOcupacional   PATH '$.nmGrupoOcupacional',
        deCargoComissionado PATH '$.deCargoComissionado',
        cdGrupoOcupacional  PATH '$.cdGrupoOcupacional'
      )) js
      WHERE js.cdGrupoOcupacional IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || SUBSTR(i.nmGrupoOcupacional || ' ' || i.deCargoComissionado,1,30), 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Órgãos Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.sgOrgao, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RUBRICAS EXIGIDAS', 'INCLUSAO',
        'Rubricas que Impedem na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nuRubrica, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO',
        'Rubricas Exigidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nuRubrica, 1,
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
      
    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
      psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
      'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO', 
      'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmNaturezaVinculo
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.NaturezaVinculo[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadNaturezaVinculo d ON UPPER(d.nmNaturezaVinculo) = UPPER(js.item)
      WHERE d.cdNaturezaVinculo IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmNaturezaVinculo, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO',
        'Regime Previdenciários Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRegimepreVidenciario
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimePrevidenciario[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRegimePrevidenciario d ON UPPER(d.nmRegimepreVidenciario) = UPPER(js.item)
      WHERE d.cdRegimePrevidenciario IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmRegimepreVidenciario, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO',
        'Regimes de Trabalho Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRegimeTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RegimeTrabalho[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRegimeTrabalho d ON UPPER(d.nmRegimeTrabalho) = UPPER(js.item)
      WHERE d.cdRegimeTrabalho IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmRegimeTrabalho, 1,
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
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO',
        'Relaçao de Trabalho Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmRelacaoTrabalho
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.RelacaoTrabalho[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadRelacaoTrabalho d ON UPPER(d.nmRelacaoTrabalho) = UPPER(js.item)
      WHERE d.cdRelacaoTrabalho IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmRelacaoTrabalho, 1,
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
      INSERT INTO ecadSituacaoPrevidenciaria
      SELECT pcdHistRubricaAgrupamento as cdHistRubricaAgrupamento, d.cdSituacaoPrevidenciaria
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.SituacaoPrevidenciaria[*]' COLUMNS (item PATH '$')) js
      INNER JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmSituacaoPrevidenciaria) = UPPER(js.item);
      
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO',
        'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento Incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;
      
    FOR i IN (
      SELECT js.item AS nmSituacaoPrevidenciaria
      FROM JSON_TABLE(pListasVigenciasAgrupamento, '$.SituacaoPrevidenciaria[*]' COLUMNS (item PATH '$')) js
      LEFT JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmSituacaoPrevidenciaria) = UPPER(js.item)
      WHERE d.cdSituacaoPrevidenciaria IS NULL
    )
    LOOP
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao || ' ' || i.nmSituacaoPrevidenciaria, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCONSISTENTE', 'Situação Previdenciária da Vigência da Rubrica do Agrupamento Inexistente',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.PConsoleLog('Importação da Rubrica - Rubrica Agrupamento Vigência' || vcdIdentificacao ||
        ' RUBRICA AGRUPAMENTO VIGENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarListasRubricaAgrupamento;

END PKGMIG_ParametrizacaoRubricasAgrupamento;
/
