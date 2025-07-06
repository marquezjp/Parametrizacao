-- Corpo do Pacote de Importação das Parametrizações de Eventos de Pagamento
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoEventosPagamento AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados do Evento de Pagamento do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Exclusão do Evento de Pagamento e as Entidades Filhas
  --     - Inclusão do Evento de Pagamento na tabela epagEventoPagAgrup
  --     - Importação das Vigências do Evento de Pagamento
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
  --   pEventoPagamento      IN CLOB: 
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
    pEventoPagamento      IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vcdEventoPagAgrupNova NUMBER := 0;
    vnuRegistros          NUMBER := 0;

    -- Cursor que extrai os Eventos de Pagamento do Documento Versões JSON
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
      EventoPagamento AS (
      SELECT       
      o.cdAgrupamento, 
      tpEvento.cdTipoEventoPagamento as cdTipoEventoPagamento, js.nmTipoEventoPagamento,
      js.deEvento as deEvento,
      rub.cdRubricaAgrupamento as cdRubricaAgrupamento, js.nuRubrica,
      rubCCO.cdRubricaAgrupamento as cdRubAgrupOpRecebCCO, js.nuRubAgrupOpRecebCCO,
      rubAlt2.cdRubricaAgrupamento as cdRubricaagrupAlternativa2, js.nuRubricaAgrupAlternativa2,
      rubAlt3.cdRubricaAgrupamento as cdRubricaAgrupAlternativa3, js.nuRubricaAgrupAlternativa3,
      
      SYSTIMESTAMP AS dtUltAlteracao,
      
      JSON_SERIALIZE(TO_CLOB(js.VigenciasEvento) RETURNING CLOB) AS VigenciasEvento

      FROM JSON_TABLE(pEventoPagamento, '$[*]' COLUMNS (
          nmTipoEventoPagamento         PATH '$.nmTipoEventoPagamento',
          deEvento                      PATH '$.deEvento',
          nuRubrica                     PATH '$.nuRubrica',
          nuRubAgrupOpRecebCCO          PATH '$.nuRubAgrupOpRecebCCO',
          nuRubricaAgrupAlternativa2    PATH '$.nuRubricaAgrupAlternativa2',
          nuRubricaAgrupAlternativa3    PATH '$.nuRubricaAgrupAlternativa3',
          VigenciasEvento               CLOB FORMAT JSON PATH '$.Vigencias'
      )) js
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN epagTipoEventoPagamento tpEvento ON UPPER(tpEvento.nmTipoEventoPagamento) = js.nmTipoEventoPagamento
      LEFT JOIN RubricaLista rub ON rub.nuRubrica = SUBSTR(js.nuRubrica,1,7)
                                AND rub.cdAgrupamento = o.cdAgrupamento
      LEFT JOIN RubricaLista rubCCO ON rubCCO.nuRubrica = SUBSTR(js.nuRubAgrupOpRecebCCO,1,7)
                                   AND rubCCO.cdAgrupamento = o.cdAgrupamento
      LEFT JOIN RubricaLista rubAlt2 ON rubAlt2.nuRubrica = SUBSTR(js.nuRubricaAgrupAlternativa2,1,7)
                                    AND rubAlt2.cdAgrupamento = o.cdAgrupamento
      LEFT JOIN RubricaLista rubAlt3 ON rubAlt3.nuRubrica = SUBSTR(js.nuRubricaAgrupAlternativa3,1,7)
                                    AND rubAlt3.cdAgrupamento = o.cdAgrupamento
      )
      SELECT * FROM EventoPagamento;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
      'Evento de Pagamento ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
	
    -- Excluir o Evento de Pagamento e as Entidades Filhas
    pExcluirEventos(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, vcdIdentificacao, pcdRubricaAgrupamento, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir o Evento Pagamento
    FOR r IN cDados LOOP
  
  	  vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || SUBSTR(TRIM(r.deEvento),1,30),1,70);  
	    
	    -- Inserir na tabela epagFormulaCalculo  
	    SELECT NVL(MAX(cdEventoPagAgrup), 0) + 1 INTO vcdEventoPagAgrupNova FROM epagEventoPagAgrup;

      INSERT INTO epagEventoPagAgrup (  
	      cdEventoPagAgrup, cdAgrupamento, cdTipoEventoPagamento, cdRubricaAgrupamento, dtUltAlteracao,  
	      deEvento, cdRubAgrupOpRecebCCO, cdRubricaagrupAlternativa2, cdRubricaAgrupAlternativa3
      ) VALUES (  
	      vcdEventoPagAgrupNova, r.cdAgrupamento, r.cdTipoEventoPagamento, r.cdRubricaAgrupamento, r.dtUltAlteracao,  
	      r.deEvento, r.cdRubAgrupOpRecebCCO, r.cdRubricaagrupAlternativa2, r.cdRubricaAgrupAlternativa3
      );  

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'EVENTO PAGAMENTO', 'INCLUSAO', 'Evento Pagamento incluida com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);  

      -- Importar Vigencias do Evento de Pagamento
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdEventoPagAgrupNova, r.VigenciasEvento, pnuNivelAuditoria);
  
    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'EVENTO PAGAMENTO',
          'Importação dos Eventos de Pagamento (PKGMIG_ParametrizacaoEventosPagamento.pImportar)', SQLERRM);
      RAISE;
  END pImportar;

  PROCEDURE pExcluirEventos(
  -- ###########################################################################
  -- PROCEDURE: pExcluirEventos
  -- Objetivo:
  --   Importar dados dos Eventos de Pagamento do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Exclusão dos Grupos de Orgãos do Evento de Pagamento
  --       tabela epagEventoPagAgrupOrgao
  --     - Exclusão dos Grupos de Carreiras do Evento de Pagamento
  --       tabela epagHistEventoPagAgrupCarreira
  --     - Exclusão das Vigências do Evento de Pagamento tabela epagHistFormulaCalculo
  --     - Exclusão das Versões do Evento de Pagamento tabela epagHistEventoPagAgrup
  --     - Exclusão do Evento de Pagamento tabela epagEventoPagAgrup
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
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    -- Excluir os Órgãos do Grupo de Órgãos do Evento de Pagamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagEventoPagAgrupOrgao GrupoOrgaos
      WHERE GrupoOrgaos.cdHistEventoPagAgrup IN (
        SELECT Vigencias.cdHistEventoPagAgrup FROM epagHistEventoPagAgrup Vigencias
        INNER JOIN epagEventoPagAgrup Evento ON Evento.cdEventoPagAgrup = Vigencias.cdEventoPagAgrup
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagEventoPagAgrupOrgao GrupoOrgaos
      WHERE GrupoOrgaos.cdHistEventoPagAgrup IN (
        SELECT Vigencias.cdHistEventoPagAgrup FROM epagHistEventoPagAgrup Vigencias
        INNER JOIN epagEventoPagAgrup Evento ON Evento.cdEventoPagAgrup = Vigencias.cdEventoPagAgrup
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'EVENTO PAGAMENTO GRUPO ORGAO', 'EXCLUSAO', 'Grupo de Orgao do Evento de Pagamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Carreiras do Grupo de Carreiras do Evento de Pagamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistEventoPagAgrupCarreira GrupoCarreiras
      WHERE GrupoCarreiras.cdHistEventoPagAgrup IN (
        SELECT Vigencias.cdHistEventoPagAgrup FROM epagHistEventoPagAgrup Vigencias
        INNER JOIN epagEventoPagAgrup Evento ON Evento.cdEventoPagAgrup = Vigencias.cdEventoPagAgrup
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistEventoPagAgrupCarreira GrupoCarreiras
      WHERE GrupoCarreiras.cdHistEventoPagAgrup IN (
        SELECT Vigencias.cdHistEventoPagAgrup FROM epagHistEventoPagAgrup Vigencias
        INNER JOIN epagEventoPagAgrup Evento ON Evento.cdEventoPagAgrup = Vigencias.cdEventoPagAgrup
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'EVENTO PAGAMENTO GRUPO CARREIRA', 'EXCLUSAO', 'Grupo de Carreiras do Evento de Pagamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir as Vigências do Evento de Pagamento
    SELECT COUNT(*) INTO vnuRegistros FROM epagHistEventoPagAgrup Vigencias
      WHERE Vigencias.cdEventoPagAgrup IN (
        SELECT Evento.cdEventoPagAgrup FROM epagEventoPagAgrup Evento
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

    IF vnuRegistros > 0 THEN
      DELETE FROM epagHistEventoPagAgrup Vigencias
      WHERE Vigencias.cdEventoPagAgrup IN (
        SELECT Evento.cdEventoPagAgrup FROM epagEventoPagAgrup Evento
          WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'EVENTO PAGAMENTO VIGENCIA', 'EXCLUSAO', 'Vigências do Evento de Pagamento excluidas com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    -- Excluir a Formula de Cálculo
    SELECT COUNT(*) INTO vnuRegistros FROM epagEventoPagAgrup Evento
      WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento;

    IF vnuRegistros > 0 THEN
      DELETE FROM epagEventoPagAgrup Evento
        WHERE Evento.cdRubricaAgrupamento = pcdRubricaAgrupamento;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
        'EVENTO PAGAMENTO', 'EXCLUSAO', 'Evento de Pagamento excluidos com sucesso',
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 'EVENTO PAGAMENTO EXCLUIR',
          'Importação dos Eventos de Pagamento (PKGMIG_ParametrizacaoEventosPagamento.pExcluirEventos)', SQLERRM);
      RAISE;
  END pExcluirEventos;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigencias do Evento de Pagamento do Documento Vigencias JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão das VVigencias do Evento de Pagamento tabela epagHistEventoPagAgrup
  --     - Importação os Grupos de Órgãos do Evento de Pagamento
  --     - Importação os Grupos de Cargos do Evento de Pagamento
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
  --   pcdEventoPagAgrup     IN NUMBER: 
  --   pVVigenciasEvento     IN CLOB: 
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
    pcdEventoPagAgrup     IN NUMBER,
    pVigenciasEvento      IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao          VARCHAR2(70) := Null;
    vcdHistEventoPagAgrupNova NUMBER := 0;
    vnuRegistros              NUMBER := 0;

    -- Cursor que extrai as Versões das Bases do Documento Versões JSON
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
      VigenciaEvento AS (
      SELECT
      --NULL as cdHistEventoPagAgrup, NULL as cdEventoPagAgrup,
      
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoRefInicial,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesRefInicial,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoRefFinal,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesRefFinal,
      
      js.deDesconto,
      rub.cdRubricaAgrupamento, js.nuRubrica,
      
      js.nuMesPagamento,
      js.nuMesPagamentoInicio,
      js.nuMesPagamentoFim,
      
      relTrab.cdRelacaoTrabalho, UPPER(js.nmRelacaoTrabalho) AS nmRelacaoTrabalho,
      
      NVL(js.flAbrangeTodosOrgaos, 'N') AS flAbrangeTodosOrgaos,
      DECODE(js.inAcaoCarreira,
        'ALGUMAS IMPEDEM', '1', 
        'ALGUMAS EXIGEM',  '2',
        'TODAS PERMITEM',  '3', -- NULL'
        'NENHUMA PERMITE', '4', 
      3) AS inAcaoCarreira,
      NVL(js.flUtilizaFormulaCalculo, 'N') AS flUtilizaFormulaCalculo,
      js.nuFormulaEspecifica,
      
      CASE WHEN js.dtInicioConquistaPerAquis IS NULL THEN NULL
        ELSE TO_DATE(js.dtInicioConquistaPerAquis, 'YYYY-MM-DD') END AS dtInicioConquistaPerAquis,
      CASE WHEN js.dtFimConquistaPerAquis IS NULL THEN NULL
        ELSE TO_DATE(js.dtFimConquistaPerAquis, 'YYYY-MM-DD') END AS dtFimConquistaPerAquis,
      
      js.cdTipoComConselhoGrupo,
      js.cdTipoPensaoNaoPrev,
      js.cdTipoTempoServico,
      js.cdTipoFuncaoChefia,
      js.cdTipoGratAtivFazendaria,
      js.cdTipoRisco,
      js.cdTipoFalta,
      js.cdTipoFaltaParcialAgrup,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      SYSTIMESTAMP AS dtUltAlteracao,
      
      (SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'sgOrgao' VALUE orgao.sgOrgao,
        'cdOrgao' VALUE o.cdOrgao
      RETURNING CLOB) RETURNING CLOB) AS GrupoOrgaos
      FROM JSON_TABLE(js.Orgaos, '$[*]' COLUMNS (sgOrgao PATH '$')) orgao
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = 'ADM-DIR' and nvl(o.sgOrgao,' ') = nvl(orgao.sgOrgao,' ')
      ) As GrupoOrgaos,
      
      (SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'nmEstruturaCarreira' VALUE carreira.nmEstruturaCarreira,
        'cdEstruturaCarreira' VALUE cef.cdEstruturaCarreira
      RETURNING CLOB) RETURNING CLOB) AS GrupoCarreira
      FROM JSON_TABLE(js.Carreiras, '$[*]' COLUMNS (nmEstruturaCarreira PATH '$')) carreira
      INNER JOIN EstruturaCarreiraLista cef ON cef.nmEstruturaCarreira = carreira.nmEstruturaCarreira
      ) As GrupoCarreiras
      
      FROM JSON_TABLE(pVigenciasEvento, '$[*]' COLUMNS (
        nuAnoMesInicioVigencia    PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia       PATH '$.nuAnoMesFimVigencia',
        deDesconto                PATH '$.deDesconto',
        nuRubrica                 PATH '$.nuRubrica',
        nuMesPagamento            PATH '$.MesPagamento.nuMesPagamento',
        nuMesPagamentoInicio      PATH '$.MesPagamento.nuMesPagamentoInicio',
        nuMesPagamentoFim         PATH '$.MesPagamento.nuMesPagamentoFim',
        nmRelacaoTrabalho         PATH '$.nmRelacaoTrabalho',
        flAbrangeTodosOrgaos      PATH '$.Orgaos.flAbrangeTodosOrgaos',
        inAcaoCarreira            PATH '$.Carreiras.inAcaoCarreira',
        flUtilizaFormulaCalculo   PATH '$.FormulaCalculo.flUtilizaFormulaCalculo',
        nuFormulaEspecifica       PATH '$.FormulaCalculo.nuFormulaEspecifica',
        dtInicioConquistaPerAquis PATH '$.ConquistaPerAquis.dtInicioConquistaPerAquis',
        dtFimConquistaPerAquis    PATH '$.ConquistaPerAquis.dtFimConquistaPerAquis',
        cdTipoComConselhoGrupo    PATH '$.Abrangencia.cdTipoComConselhoGrupo',
        cdTipoPensaoNaoPrev       PATH '$.Abrangencia.cdTipoPensaoNaoPrev',
        cdTipoTempoServico        PATH '$.Abrangencia.cdTipoTempoServico',
        cdTipoFuncaoChefia        PATH '$.Abrangencia.cdTipoFuncaoChefia',
        cdTipoGratAtivFazendaria  PATH '$.Abrangencia.cdTipoGratAtivFazendaria',
        cdTipoRisco               PATH '$.Abrangencia.cdTipoRisco',
        cdTipoFalta               PATH '$.Abrangencia.cdTipoFalta',
        cdTipoFaltaParcialAgrup   PATH '$.Abrangencia.cdTipoFaltaParcialAgrup',
        Orgaos                    CLOB FORMAT JSON PATH '$.Orgaos',
        Carreiras                 CLOB FORMAT JSON PATH '$.Carreiras'
      )) js
      LEFT JOIN OrgaoLista o on o.sgAgrupamento = psgAgrupamentoDestino and nvl(o.sgOrgao,' ') = nvl(psgOrgao,' ')
      LEFT JOIN RubricaLista rub ON rub.nuRubrica = js.nuRubrica
                                AND rub.cdAgrupamento = o.cdAgrupamento
      LEFT JOIN ecadRelacaoTrabalho relTrab ON UPPER(relTrab.nmRelacaoTrabalho) = UPPER(js.nmRelacaoTrabalho)
      )
      SELECT * FROM VigenciaEvento;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento para Incluir as Vigências do Evento de Pagamento
    FOR r IN cDados LOOP

	    vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
        lpad(r.nuAnoRefInicial,4,0) || lpad(r.nuMesRefInicial,2,0),1,70);

      IF r.cdRelacaoTrabalho IS NULL AND r.nmRelacaoTrabalho IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
          'Relação de Trabalho da Vigência do Evento de Pagamento Inexistente ' ||
          vcdIdentificacao || ' ' || r.nmRelacaoTrabalho,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmRelacaoTrabalho, 1,
          'EVENTO PAGAMENTO VIGENCIA', 'INCONSISTENTE',
          'Relação de Trabalho da Vigência do Evento de Pagamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdRubricaAgrupamento IS NULL AND r.nuRubrica IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
          'Código da Rubrica da Vigência do Evento de Pagamento Inexistente ' ||
          vcdIdentificacao || ' ' || r.nuRubrica,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || r.nuRubrica,1,70), 1,
          'EVENTO PAGAMENTO VIGENCIA', 'INCONSISTENTE',
          'Código da Rubrica da Vigência do Evento de Pagamento Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

	    -- Inserir na tabela cdHistEventoPagAgrup
	    SELECT NVL(MAX(cdHistEventoPagAgrup), 0) + 1 INTO vcdHistEventoPagAgrupNova FROM epagHistEventoPagAgrup;

      INSERT INTO epagHistEventoPagAgrup (
	      cdHistEventoPagAgrup, cdEventoPagAgrup,
	      cdtipoTempoServico, cdTipoFuncaoChefia, cdTipoGratAtivFazendaria, cdTipoRisco,
	      nuAnoRefInicial, nuMesRefInicial, nuAnoRefFinal, nuMesRefFinal, nuMesPagamento,
	      flAbrangeTodosOrgaos, nuCPFCadastrador, dtInclusao, dtUltAlteracao,
	      cdRelacaoTrabalho, dtInicioConquistaPerAquis, dtFimConquistaPerAquis, nuFormulaEspecifica,
	      cdTipoComconselhoGrupo, deDesconto, inAcaoCarreira, flUtilizaFormulaCalculo,
	      cdRubricaAgrupamento, cdTipoFaltaParcialAgrup, cdTipoFalta,
	      nuMesPagamentoInicio, nuMesPagamentoFim, cdTipoPensaoNaoPrev
      ) VALUES (
	      vcdHistEventoPagAgrupNova, pcdEventoPagAgrup,
	      r.cdtipoTempoServico, r.cdTipoFuncaoChefia, r.cdTipoGratAtivFazendaria, r.cdTipoRisco,
	      r.nuAnoRefInicial, r.nuMesRefInicial, r.nuAnoRefFinal, r.nuMesRefFinal, r.nuMesPagamento,
	      r.flAbrangeTodosOrgaos, r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao,
	      r.cdRelacaoTrabalho, r.dtInicioConquistaPerAquis, r.dtFimConquistaPerAquis, r.nuFormulaEspecifica,
	      r.cdTipoComconselhoGrupo, r.deDesconto, r.inAcaoCarreira, r.flUtilizaFormulaCalculo,
	      r.cdRubricaAgrupamento, r.cdTipoFaltaParcialAgrup, r.cdTipoFalta,
	      r.nuMesPagamentoInicio, r.nuMesPagamentoFim, r.cdTipoPensaoNaoPrev
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'EVENTO PAGAMENTO VIGENCIA', 'INCLUSAO', 'Vigência do Evento de Pagamento incluida com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Incluir Órgãos Permitidas na Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      SELECT COUNT(*) INTO vnuRegistros
      FROM JSON_TABLE(r.GrupoOrgaos, '$[*]' COLUMNS (
        cdOrgao           PATH '$.cdOrgao'
      )) js
      WHERE js.cdOrgao IS NOT NULL;
      
      IF vnuRegistros > 0 THEN
        INSERT INTO epagEventoPagAgrupOrgao
        SELECT vcdHistEventoPagAgrupNova as cdHistRubricaAgrupamento, js.cdOrgao
        FROM JSON_TABLE(r.GrupoOrgaos, '$[*]' COLUMNS (
          cdOrgao           PATH '$.cdOrgao'
        )) js
        WHERE js.cdOrgao IS NOT NULL;
        
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
          'EVENTO PAGAMENTO VIGENCIA GRUPO ORGAO', 'INCLUSAO',
          'Órgão do Grupo de Órgãos do Evento de Pagamento incluidos com sucesso',
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
      END IF;

      FOR i IN (
        SELECT js.sgOrgao, js.cdOrgao
        FROM JSON_TABLE(r.GrupoOrgaos, '$[*]' COLUMNS (
          sgOrgao           PATH '$.sgOrgao',
          cdOrgao           PATH '$.cdOrgao'
        )) js
        WHERE js.cdOrgao IS NULL
      )
      LOOP
        PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
          'Órgão do Grupo de Órgãos do Evento de Pagamento Inexistente no Agrupamento ' ||
          vcdIdentificacao || ' ' || i.sgOrgao, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || i.sgOrgao,1,70), 1,
          'EVENTO PAGAMENTO VIGENCIA GRUPO ORGAO', 'INCONSISTENTE',
          'Órgão do Grupo de Órgãos do Evento de Pagamento Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;

      -- Incluir Estrutura de Carreiras Permitidas na Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      SELECT COUNT(*) INTO vnuRegistros
      FROM JSON_TABLE(r.GrupoCarreiras, '$[*]' COLUMNS (
        cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
      )) js
      WHERE js.cdEstruturaCarreira IS NOT NULL;
      
      IF vnuRegistros > 0 THEN
        INSERT INTO epagHistEventoPagAgrupCarreira
        SELECT vcdHistEventoPagAgrupNova as cdHistRubricaAgrupamento, js.cdEstruturaCarreira
        FROM JSON_TABLE(r.GrupoCarreiras, '$[*]' COLUMNS (
          cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
        )) js
        WHERE js.cdEstruturaCarreira IS NOT NULL;
        
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, vnuRegistros,
          'GRUPO CARREIRA', 'INCLUSAO', 'Carreira do Grupo de Carreiras do Evento de Pagamento incluidas com sucesso',
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);
      END IF;
        
      FOR i IN (
        SELECT js.nmEstruturaCarreira, js.cdEstruturaCarreira
        FROM JSON_TABLE(r.GrupoCarreiras, '$[*]' COLUMNS (
          nmEstruturaCarreira PATH '$.nmEstruturaCarreira',
          cdEstruturaCarreira PATH '$.cdEstruturaCarreira'
        )) js
        WHERE js.cdEstruturaCarreira IS NULL
      )
      LOOP
        PKGMIG_ParametrizacaoLog.pAlertar('Importação do Evento de Pagamento - ' ||
          'Carreira do Grupo de Carreiras do Evento de Pagamento Inexistente no Agrupamento ' ||
          vcdIdentificacao || ' ' || TRIM(SUBSTR(i.nmEstruturaCarreira,1,30)),
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, SUBSTR(vcdIdentificacao || ' ' || TRIM(SUBSTR(i.nmEstruturaCarreira,1,30)),1,70), 1,
          'GRUPO CARREIRA', 'INCONSISTENTE', 'Carreira do Grupo de Carreiras do Evento de Pagamento Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 'EVENTO PAGAMENTO VIGENCIA',
          'Importação dos Eventos de Pagamento (PKGMIG_ParametrizacaoEventosPagamento.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigencias;

END PKGMIG_ParametrizacaoEventosPagamento;
/
