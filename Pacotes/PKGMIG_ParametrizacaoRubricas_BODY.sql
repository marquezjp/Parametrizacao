-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoRubricas AS

  PROCEDURE pExportar(
  -- ###########################################################################
  -- PROCEDURE: pExportar
  -- Objetivo:
  --   Exportar as Parametrizações de Rubricas, Eventos e Formulas de Calculo
  --     para a Configuração Padrão JSON, realizando:
  --     - Inclusão do Documento JSON ValoresReferecia na tabela emigConfigracaoPadrao
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
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15) := NULL;
    vsgModulo           CONSTANT CHAR(3)      := 'PAG';
    vsgConceito         CONSTANT VARCHAR2(20) := 'RUBRICA';
    vtpOperacao         CONSTANT VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20) := NULL;
    vjsConteudo         CLOB         := NULL;
    vnuVersao           CHAR(3)      := '1.0';
    vflAnulado          CHAR(1)      := 'N';

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

    vtxMensagem         VARCHAR2(100) := NULL;

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;
    vtxResumo           VARCHAR2(4000) := NULL;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas
    vRefCursor SYS_REFCURSOR;

    BEGIN

      vdtOperacao := LOCALTIMESTAMP;

      IF pcdIdentificacao IS NULL THEN
        vtxMensagem := 'Inicio da Exportação das Parametrizações das Rubricas ';
      ELSE
        vtxMensagem := 'Inicio da Exportação da Parametrização da Rubrica "' || pcdIdentificacao || '" ';
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

	    -- Defini o Cursos com a Query que Gera o Documento JSON Rubricas
	    vRefCursor := fnCursorRubricas(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito, pcdIdentificacao,
        vdtOperacao, vnuVersao, vflAnulado);

	    vnuRegistros := 0;

      -- Loop principal de processamento
	    LOOP
        FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
	        rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado, rdtInclusao;
        EXIT WHEN vRefCursor%NOTFOUND;

        PKGMIG_ParametrizacaoLog.pAlertar('Exportação da Rubrica ' || rcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        INSERT INTO emigParametrizacao (
          sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
		      cdIdentificacao, jsConteudo, dtInclusao, nuVersao, flAnulado
        ) VALUES (
          rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
  		    rcdIdentificacao, rjsConteudo, rdtInclusao, rnuVersao, rflAnulado
        );

	      vnuRegistros := vnuRegistros + 1;
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, rcdIdentificacao, 1,
          'RUBRICA', 'INCLUSAO', 'Documento JSON da Rubrica incluído com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      END LOOP;

      CLOSE vRefCursor;

      COMMIT;

      -- Gerar as Estatísticas da Exportação das Rubricas
      vdtTermino := LOCALTIMESTAMP;
      vnuTempoExecucao := vdtTermino - vdtOperacao;
      vtxResumo := 'Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
        'Data e Hora da Inicio da Exportação  ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
        'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	      'Tempo de Execução ' ||
	      LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	      LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	      LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	      'Total de Parametrizações de Rubricas Exportadas: ' || vnuRegistros;

      -- Registro de Resumo da Exportação das Rubricas
      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, NULL, NULL,
        'RUBRICA', 'RESUMO', 'Exportação das Parametrizações das Rubricas do ' || vtxResumo, 
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      PKGMIG_ParametrizacaoLog.pAlertar('Termino da Exportação das Parametrizações das Rubricas do ' ||
        vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'RUBRICA',
          'Exportação de Rubrica (PKGMIG_ParametrizacaoRubricas.pExportar)', SQLERRM);
      ROLLBACK;
      RAISE;
  END pExportar;

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados de rubricas a partir da Configuração Padrão JSON
  --   contida na tabela emigParametrizacao, realizando:
  --     - Inclusão ou atualização de registros na tabela epagRubrica
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino IN VARCHAR2: Sigla do agrupamento de destino para os dados
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
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15) := NULL;
    vsgModulo              CONSTANT CHAR(3)      := 'PAG';
    vsgConceito            CONSTANT VARCHAR2(20) := 'RUBRICA';
    vtpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(70) := NULL;
    vcdRubricaNova         NUMBER       := NULL;

    vtxMensagem            VARCHAR2(100) := NULL;
    vContador              NUMBER       := 0;
    vCommitLote            CONSTANT NUMBER := 1000;
    vdtExportacao          TIMESTAMP    := LOCALTIMESTAMP;
    vdtTermino             TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao       INTERVAL DAY TO SECOND := NULL;
    vnuInseridos           NUMBER       := 0;
    vnuAtualizados         NUMBER       := 0;
    vnuRegistros           NUMBER       := 0;
    vtxResumo              VARCHAR2(4000) := NULL;

    vListaTabelas          CLOB := '[
      "EPAGRUBRICA",
      "EPAGGRUPORUBRICAPAGAMENTO",
      "EPAGHISTRUBRICA",
      "EPAGRUBRICAAGRUPAMENTO",
      "EPAGHISTRUBRICAAGRUPAMENTO",
      "EPAGHISTRUBRICAAGRUPCARREIRA",
      "EPAGHISTRUBRICAAGRUPNIVELREF",
      "EPAGHISTRUBRICAAGRUPCCO",
      "EPAGHISTRUBRICAAGRUPFUC",
      "EPAGHISTRUBRICAAGRUPPROGRAMA",
      "EPAGHISTRUBRICAAGRUPMODELOAPO",
      "EPAGHISTRUBAGRUPLOCCHO",
      "EPAGHISTRUBRICAAGRUPORGAO",
      "EPAGHISTRUBRICAAGRUPUO",
      "EPAGHISTRUBRICAAGRUPNATVINC",
      "EPAGHISTRUBRICAAGRUPRELTRAB",
      "EPAGHISTRUBRICAAGRUPREGTRAB",
      "EPAGHISTRUBRICAAGRUPREGPREV",
      "EPAGHISTRUBRICAAGRUPSITPREV",
      "EPAGRUBAGRUPMOTAFASTTEMPIMP",
      "EPAGRUBAGRUPMOTAFASTTEMPEX",
      "EPAGHISTRUBRICAAGRUPMOTMOVI",
      "EPAGHISTRUBRICAAGRUPMOTCONV",
      "EPAGHISTRUBRICAAGRUPIMPEDITIVA",
      "EPAGHISTRUBRICAAGRUPEXIGIDA",
      "EPAGEVENTOPAGAGRUP",
      "EPAGHISTEVENTOPAGAGRUP",
      "EPAGEVENTOPAGAGRUPORGAO",
      "EPAGHISTEVENTOPAGAGRUPCARREIRA",
      "EPAGFORMULACALCULO",
      "EPAGFORMULAVERSAO",
      "EPAGHISTFORMULACALCULO",
      "EPAGEXPRESSAOFORMCALC",
      "EPAGFORMULACALCULOBLOCO",
      "EPAGFORMULACALCBLOCOEXPRESSAO",
      "EPAGFORMCALCBLOCOEXPRUBAGRUP"
    ]';

    -- Cursor que extrai e transforma os dados JSON de Rubricas e Tipos de Rubricas
    CURSOR cDados IS
      WITH epagRubricaImportar AS (
        SELECT 
          cfg.cdIdentificacao,
          rub.cdRubrica,
          js.nuRubrica,
          tprub.cdTipoRubrica,
          js.inNaturezaTCE,
          js.nuUnidadeOrcamentaria,
          js.nuSubAcao,
          js.nuFonteRecurso,
          js.nuCNPJOutroCredor,
          js.nuElemDespesaAtivo,
          js.nuElemDespesaRegGeral,
          js.nuElemDespesaInativo,
          js.nuElemDespesaAtivoCLT,
          js.nuElemDespesaPensaoEsp,
          js.nuElemDespesaCTISP,
          js.nuElemDespesaAtivo13,
          js.nuElemDespesaRegGeral13,
          js.nuElemDespesaInativo13,
          js.nuElemDespesaAtivoCLT13,
          js.nuElemDespesaPensaoEsp13,
          js.nuElemDespesaCTISP13,
          cgt.cdConsignataria, js.nucodigoconsignataria,
          js.nuOutraConsignataria,
          NVL(js.flExtraOrcamentaria, 'N') AS flExtraOrcamentaria,
          JSON_SERIALIZE(TO_CLOB(js.VigenciasTipo) RETURNING CLOB) AS VigenciasTipo,
          JSON_SERIALIZE(TO_CLOB(js.GruposRubrica) RETURNING CLOB) AS GruposRubrica,
          JSON_SERIALIZE(TO_CLOB(js.Agrupamento) RETURNING CLOB) AS Agrupamento
        FROM emigParametrizacao cfg
        CROSS APPLY JSON_TABLE(cfg.jsConteudo, '$.PAG.Rubrica' COLUMNS (
          nuNaturezaRubrica            PATH '$.nuNaturezaRubrica',
          nuRubrica                    PATH '$.nuRubrica',
          NESTED PATH '$.Tipos[*]' COLUMNS (
            nuTipoRubrica              PATH '$.nuTipoRubrica',

            inNaturezaTCE              PATH '$.Empenho.inNaturezaTCE',
            nuUnidadeOrcamentaria      PATH '$.Empenho.nuUnidadeOrcamentaria',
            nuSubAcao                  PATH '$.Empenho.nuSubAcao',
            nuFonteRecurso             PATH '$.Empenho.nuFonteRecurso',
            nuCNPJOutroCredor          PATH '$.Empenho.nuCNPJOutroCredor',

            nuElemDespesaAtivo         PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaAtivo',
            nuElemDespesaRegGeral      PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaRegGeral',
            nuElemDespesaInativo       PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaInativo',
            nuElemDespesaAtivoCLT      PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaAtivoCLT',
            nuElemDespesaPensaoEsp     PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaPensaoEsp',
            nuElemDespesaCTISP         PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuElemDespesaCTISP',

            nuElemDespesaAtivo13       PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaAtivo13',
            nuElemDespesaRegGeral13    PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaRegGeral13',
            nuElemDespesaInativo13     PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaInativo13',
            nuElemDespesaAtivoCLT13    PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaAtivoCLT13',
            nuElemDespesaPensaoEsp13   PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaPensaoEsp13',
            nuElemDespesaCTISP13       PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuElemDespesaCTISP13',

            nuCodigoConsignataria      PATH '$.Empenho.Consignacao.nuCodigoConsignataria',
            nuOutraConsignataria       PATH '$.Empenho.Consignacao.nuOutraConsignataria',
            flExtraOrcamentaria        PATH '$.Empenho.Consignacao.flExtraOrcamentaria',

            VigenciasTipo              CLOB FORMAT JSON PATH '$.VigenciasTipo',
            GruposRubrica              CLOB FORMAT JSON PATH '$.GruposRubrica',
            Agrupamento                CLOB FORMAT JSON PATH '$.Agrupamento'
          )
        )) js
        LEFT JOIN epagTipoRubrica tprub ON tprub.nuTipoRubrica = js.nuTipoRubrica
        LEFT JOIN epagRubrica rub ON rub.cdTipoRubrica = tprub.cdTipoRubrica AND rub.nuRubrica = js.nuRubrica
        LEFT JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
        WHERE cfg.sgModulo = vsgModulo AND cfg.sgConceito = vsgConceito AND cfg.flAnulado = 'N'
          AND cfg.sgAgrupamento = psgAgrupamentoOrigem AND cfg.sgOrgao IS NULL
          AND cfg.dtExportacao = vdtExportacao
          AND (cfg.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
        ORDER BY cfg.cdIdentificacao
      )
      SELECT * FROM epagRubricaImportar;
      
  BEGIN
    
    vdtOperacao := LOCALTIMESTAMP;

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = vsgModulo AND sgConceito = vsgConceito
      AND sgAgrupamento = psgAgrupamentoOrigem AND sgOrgao IS NULL;

    IF pcdIdentificacao IS NULL THEN
      vtxMensagem := 'Inicio da Importação das Parametrizações das Rubricas ';
    ELSE
      vtxMensagem := 'Inicio da Importação da Parametrização da Rubrica "' || pcdIdentificacao || '" ';
    END IF;

    PKGMIG_ParametrizacaoLog.pAlertar(vtxMensagem ||
      'do Agrupamento ' || psgAgrupamentoOrigem || ' ' ||
      'para o Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data da Exportação ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI:SS') || ', ' || CHR(13) || CHR(10) ||
      'Data da Operação   ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
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

    vnuInseridos   := 0;
    vnuAtualizados := 0;
    vnuRegistros   := 0;
    vContador      := 0;

    -- Loop principal de processamento
    FOR r IN cDados LOOP
  
      vContador := vContador + 1;
      vcdIdentificacao := SUBSTR(r.cdIdentificacao || ' ' ||
        LPAD(r.cdTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0),1,70);
  
      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - Rubrica ' || vcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      vcdRubricaNova := r.cdrubrica;
      IF r.cdrubrica IS NULL THEN
        -- Incluir Nova Rubrica
        SELECT NVL(MAX(cdrubrica), 0) + 1 INTO vcdRubricaNova FROM epagRubrica;

        INSERT INTO epagRubrica (
          cdRubrica, cdTipoRubrica, nuRubrica,
          nuElemDespesaAtivo, nuElemDespesaInativo, cdConsignataria, nuOutraConsignataria, 
          flExtraOrcamentaria, nuSubAcao, nuFonteRecurso, nuCNPJOutroCredor,
          nuUnidadeOrcamentaria, nuElemDespesaAtivoCLT, nuElemDespesaPensaoEsp, 
          nuElemDespesaAtivo13, nuElemDespesaInativo13, nuElemDespesaAtivoCLT13,
          nuElemDespesaPensaoEsp13, nuElemDespesaRegGeral, nuElemDespesaRegGeral13, 
          nuElemDespesaCTISP, nuElemDespesaCTISP13, inNaturezaTCE
        ) VALUES (
          vcdRubricaNova, r.cdTipoRubrica, r.nuRubrica,
          r.nuElemDespesaAtivo, r.nuElemDespesaInativo, r.cdConsignataria, r.nuOutraConsignataria,
          r.flExtraOrcamentaria, r.nuSubAcao, r.nuFonteRecurso, r.nuCNPJOutroCredor,
          r.nuUnidadeOrcamentaria, r.nuElemDespesaAtivoCLT, r.nuElemDespesaPensaoEsp,
          r.nuElemDespesaAtivo13, r.nuElemDespesaInativo13, r.nuElemDespesaAtivoCLT13,
          r.nuElemDespesaPensaoEsp13, r.nuElemDespesaRegGeral, r.nuElemDespesaRegGeral13,
          r.nuElemDespesaCTISP, r.nuElemDespesaCTISP13, r.inNaturezaTCE
        );

        vnuInseridos := vnuInseridos + 1;
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'RUBRICA', 'INCLUSAO', 'Rubrica Incluídas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        -- Incluir Grupo de Rubricas na Rubrica
        vnuRegistros := 0;
        SELECT COUNT(*) INTO vnuRegistros
          FROM json_table(r.GruposRubrica, '$[*]' COLUMNS (item VARCHAR2(100) PATH '$')) js
          INNER JOIN epagGrupoRubrica d ON UPPER(d.nmGrupoRubrica) = UPPER(js.item);
        
        IF vnuRegistros > 0 THEN
          INSERT INTO epagGrupoRubricaPagamento
          SELECT d.cdGrupoRubrica, vcdRubricaNova AS cdRubrica
            FROM json_table(r.GruposRubrica, '$[*]' COLUMNS (item VARCHAR2(100) PATH '$')) js
            INNER JOIN epagGrupoRubrica d ON UPPER(d.nmGrupoRubrica) = UPPER(js.item);

          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
            vsgModulo, vsgConceito, vcdIdentificacao, vnuRegistros,
            'RUBRICA GRUPO DE RUBRICA', 'INCLUSAO', 'Grupo de Rubrica Incluídas com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        -- Importar Vigências da Rubrica
        pImportarVigencias(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, r.VigenciasTipo, pnuNivelAuditoria);
      END IF;

      vnuAtualizados := vnuAtualizados + 1;
      -- Importar Rubricas do Agrupamento
      PKGMIG_ParametrizacaoRubricasAgrupamento.pImportarRubricaAgrupamento(psgAgrupamentoDestino, vsgOrgao,
        vtpOperacao, vdtOperacao, vsgModulo, vsgConceito,
        vcdIdentificacao, vcdRubricaNova, r.Agrupamento, pnuNivelAuditoria);

      IF MOD(vContador, vCommitLote) = 0 THEN
        COMMIT;
      END IF;

    END LOOP;

    COMMIT;
  
    -- Gerar as Estatísticas da Importação das Rubricas
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
	  'Total de Parametrizações das Rubricas Incluídas: ' || vnuInseridos ||
      ' e Atualizadas: ' || vnuAtualizados;

    PKGMIG_ParametrizacaoLog.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Importação das Rubricas
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, 1,
      NULL, 'RESUMO', 'Importação das Parametrizações das Rubricas do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação dos Valores de Referencia
    PKGMIG_ParametrizacaoLog.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pAlertar('Termino da Importação das Parametrizações das Rubricas do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'RUBRICA',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricas.pImportar)', SQLERRM);
      ROLLBACK;
      RAISE;
  END pImportar;

  PROCEDURE pExcluirRubrica(
  -- ###########################################################################
  -- PROCEDURE: pExcluirRubrica
  -- Objetivo:
  --   Excluir as Entidades filhas da Rubrica
  --     - Exclusão dos Grupos de Rubrica
  --     - Exclusão do Documento de Amparo ao Fato
  --     - Exclusão das Vigências da Rubricas
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
    pcdRubrica            IN NUMBER,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

    BEGIN
    
      vnuRegistros := 0;

      -- Excluir Grupo de Rubricas da Rubrica
	    SELECT COUNT(*) INTO vnuRegistros FROM epagGrupoRubricaPagamento WHERE cdRubrica = pcdRubrica;

	    IF vnuRegistros > 0 THEN
/*
	      DELETE FROM epagGrupoRubricaPagamento WHERE cdRubrica = vcdRubricaNova;
*/  
        PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - ' ||
          'RUBRICA GRUPO EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
          'RUBRICA GRUPO', 'EXCLUSAO', 'Grupo de Rubrica excluidas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        -- Excluir os Documentos das Vigências da Rubrica
        vnuRegistros := 0;
        FOR d IN (
          SELECT Vigencia.cdHistRubrica, Vigencia.cdDocumento FROM epagHistRubrica Vigencia
            WHERE Vigencia.cdRubrica = pcdRubrica AND Vigencia.cdDocumento IS NOT NULL
        ) LOOP

--        UPDATE epagHistRubrica Vigencia SET Vigencia.cdDocumento = NULL
--          WHERE Vigencia.cdHistRubrica = d.cdHistRubrica;

--        DELETE FROM eatoDocumento
--          WHERE cdDocumento = d.cdDocumento;

          PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - ' ||
            'DOCUMENTO EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'DOCUMENTO', 'EXCLUSAO', 'Documentos de Amparo ao Fato da Rubrica excluidas com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;      

      -- Excluir Vigencias da Rubrica
	    SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubrica WHERE cdRubrica = pcdRubrica;

	    IF vnuRegistros > 0 THEN
/*
        DELETE FROM epagHistRubrica
          WHERE cdRubrica = pcdRubrica;
*/    
        PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - ' ||
          'RUBRICA VIGENCIA EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
          'RUBRICA VIGENCIA', 'EXCLUSAO', 'Vigência da Rubrica excluidas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'RUBRICA VIGENCIA EXCLUIR',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricas.pExcluirRubrica)', SQLERRM);
      RAISE;
  END pExcluirRubrica;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências das Rubricas do Documento Agrupamento JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Exclusão das Vigências da Rubricas
  --     - Inclusão das Vigências da Rubricas tabela epagHistRubrica
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
  --   pVigenciasTipo        IN CLOB: 
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
    pcdRubrica            IN NUMBER,
    pVigenciasTipo        IN CLOB,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao VARCHAR2(70) := Null;
    vnuRegistros     NUMBER := 0;
    vcdDocumentoNovo NUMBER := 0;
  
    -- Cursor que extrai as Vigências da Rubrica do Documento VigenciasTipo JSON
    CURSOR cDados IS
      WITH
      epagHistRubricaImportar AS (
      SELECT 
        (SELECT NVL(MAX(cdHistRubrica),0) FROM epagHistRubrica) + ROWNUM AS cdHistRubrica,
        pcdRubrica as cdRubrica,
        js.deRubrica,
    
        CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicioVigencia,
        CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicioVigencia,
        CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFimVigencia,
        CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFimVigencia,
        
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
        SYSTIMESTAMP AS dtUltAlteracao

      FROM JSON_TABLE(pVigenciasTipo, '$[*]' COLUMNS (
        nuAnoMesInicioVigencia    PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia       PATH '$.nuAnoMesFimVigencia',
        deRubrica                 PATH '$.deRubrica',
        
        cdDocumento               PATH '$.Documento.cdDocumento',
        nuAnoDocumento            PATH '$.Documento.nuAnoDocumento',
        deTipoDocumento           PATH '$.Documento.deTipoDocumento',
        dtDocumento               PATH '$.Documento.dtDocumento',
        nuNumeroAtoLegal          PATH '$.Documento.nuNumeroAtoLegal',
        deObservacao              PATH '$.Documento.deObservacao',
        nmMeioPublicacao          PATH '$.Documento.nmMeioPublicacao',
        nmTipoPublicacao          PATH '$.Documento.nmTipoPublicacao',
        dtPublicacao              PATH '$.Documento.dtPublicacao',
        nuPublicacao              PATH '$.Documento.nuPublicacao',
        nuPagInicial              PATH '$.Documento.nuPagInicial',
        deOutroMeio               PATH '$.Documento.deOutroMeio',
        nmArquivoDocumento        PATH '$.Documento.nmArquivoDocumento',
        deCaminhoArquivoDocumento PATH '$.Documento.deCaminhoArquivoDocumento'
      )) js
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      ORDER BY cdRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia
      )
      SELECT * FROM epagHistRubricaImportar;

    BEGIN

      vcdIdentificacao := pcdIdentificacao;
      
      -- Loop principal de processamento para Incluir a Vigências da Rubrica
      FOR r IN cDados LOOP
	
	      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
          LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0),1,70);

        PKGMIG_ParametrizacaoLog.pAlertar('Importação da Rubrica - ' ||
        'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

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
            'DOCUMENTO', 'INCLUSAO', 'Documentos de Amparo da Rubrica Incluídas com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
	      END IF;

        -- Inserir na tabela epagHistRubrica
        INSERT INTO epagHistRubrica (
          cdHistRubrica, cdRubrica, deRubrica, nuAnoInicioVigencia, nuMesInicioVigencia,
          nuAnoFimVigencia, nuMesFimVigencia,
          nuCpfCadastrador, dtInclusao, dtUltAlteracao, 
          cdDocumento, cdMeioPublicacao, cdTipoPublicacao,
          dtPublicacao, nuPublicacao, nuPagInicial, deOutroMeio
        ) VALUES (
          r.cdHistRubrica, r.cdRubrica, r.deRubrica, r.nuAnoInicioVigencia, r.nuMesInicioVigencia,
          r.nuAnoFimVigencia, r.nuMesFimVigencia,
          r.nuCpfCadastrador, r.dtInclusao, r.dtUltAlteracao,
          vcdDocumentoNovo, r.cdMeioPublicacao, r.cdTipoPublicacao,
          r.dtPublicacao, r.nuPublicacao, r.nuPagInicial, r.deOutroMeio
        );

        vnuRegistros := vnuRegistros + 1;
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, pcdIdentificacao, 1,
          'RUBRICA VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica Incluídas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'RUBRICA VIGENCIA',
          'Importação de Rubrica (PKGMIG_ParametrizacaoRubricas.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigencias;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações das Rubricas
  FUNCTION fnCursorRubricas(
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
      --- Extrair os Conceito de Rubricas de Eventos de Pagamento com Os Eventos e as suas formulas de Cálculo de um Agrupamento
      WITH
      --- Informações referente AS Rubricas e Rubricas no Agrupamento
      RubricaAgrupamento AS (
        SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, cdIdentificacao AS nuRubrica,
        JSON_SERIALIZE(TO_CLOB(jsConteudo) RETURNING CLOB) AS RubricaAgrupamento
        FROM TABLE(PKGMIG_ParametrizacaoRubricasAgrupamento.fnExportar(psgAgrupamento, pcdIdentificacao))
      ),
      -- TipoRubricaVigencia: vigências associadas ao tipo de rubrica
      TipoRubricaVigencia AS (
        SELECT vigencia.cdRubrica,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nuAnoMesInicioVigencia' VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia, 2, 0),
            'nuAnoMesFimVigencia'    VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia, 2, 0),
            'deRubrica'              VALUE vigencia.deRubrica
          ABSENT ON NULL)
      	ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia, 2, 0) DESC
      	RETURNING CLOB) AS VigenciasTipo
        FROM epagHistRubrica vigencia
        GROUP BY vigencia.cdRubrica
      ),
      -- TipoRubricas: tipo de rubrica
      TipoRubrica AS (
      SELECT
        CASE
          WHEN tp.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
          WHEN tp.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
          WHEN tp.nuTipoRubrica = 9 THEN '09'
        END nuNaturezaRubrica,
        rub.nuRubrica,
        LPAD(tp.nuTipoRubrica, 2, 0) AS nuTipoRubrica,
        rubagrup.sgAgrupamento,
        rubagrup.sgOrgao,
        JSON_OBJECT(
          'nuTipoRubrica'                   VALUE LPAD(tp.nuTipoRubrica, 2, 0),
          'deTipoRubrica'                   VALUE tp.deTipoRubrica,
          'VigenciasTipo'                   VALUE vigencia.VigenciasTipo,
          'GruposRubrica'                   VALUE 
            (SELECT JSON_ARRAYAGG(gp.nmGrupoRubrica ORDER BY gp.nmGrupoRubrica) AS GruposRubrica
             FROM epagGrupoRubricaPagamento gprub
             INNER JOIN epagGrupoRubrica gp ON gp.cdGrupoRubrica = gprub.cdGrupoRubrica
             WHERE gprub.cdRubrica = rub.cdRubrica),
          'Empenho' VALUE
      	  CASE WHEN rub.inNaturezaTCE        IS NULL AND rub.nuUnidadeOrcamentaria   IS NULL
      		  AND rub.nuSubAcao                IS NULL AND rub.nuFonteRecurso          IS NULL
      		  AND rub.nuElemDespesaAtivo       IS NULL AND rub.nuElemDespesaRegGeral   IS NULL
      		  AND rub.nuElemDespesaInativo     IS NULL AND rub.nuElemDespesaAtivoCLT   IS NULL
      		  AND rub.nuElemDespesaPensaoEsp   IS NULL AND rub.nuElemDespesaCTISP      IS NULL
      		  AND rub.nuElemDespesaAtivo13     IS NULL AND rub.nuElemDespesaRegGeral13 IS NULL
      		  AND rub.nuElemDespesaInativo13   IS NULL AND rub.nuElemDespesaAtivoCLT13 IS NULL
      		  AND rub.nuElemDespesaPensaoEsp13 IS NULL AND rub.nuElemDespesaCTISP13    IS NULL
      		  THEN NULL
          ELSE JSON_OBJECT(
            'inNaturezaTCE'                 VALUE rub.inNaturezaTCE,
            'nuUnidadeOrcamentaria'         VALUE rub.nuUnidadeOrcamentaria,
            'nuSubAcao'                     VALUE rub.nuSubAcao,
            'nuFonteRecurso'                VALUE rub.nuFonteRecurso,
            'nuCNPJOutroCredor'             VALUE rub.nuCNPJOutroCredor,
            'ElementosDespesas'             VALUE
      	    CASE WHEN rub.nuElemDespesaAtivo   IS NULL AND rub.nuElemDespesaRegGeral   IS NULL
      		    AND rub.nuElemDespesaInativo     IS NULL AND rub.nuElemDespesaAtivoCLT   IS NULL
      		    AND rub.nuElemDespesaPensaoEsp   IS NULL AND rub.nuElemDespesaCTISP      IS NULL
      		    AND rub.nuElemDespesaAtivo13     IS NULL AND rub.nuElemDespesaRegGeral13 IS NULL
      		    AND rub.nuElemDespesaInativo13   IS NULL AND rub.nuElemDespesaAtivoCLT13 IS NULL
      		    AND rub.nuElemDespesaPensaoEsp13 IS NULL AND rub.nuElemDespesaCTISP13    IS NULL
      		    THEN NULL
            ELSE JSON_OBJECT(
              'FolhaMensal' VALUE JSON_OBJECT(
                'nuElemDespesaAtivo'         VALUE rub.nuElemDespesaAtivo,
                'nuElemDespesaRegGeral'      VALUE rub.nuElemDespesaRegGeral,
                'nuElemDespesaInativo'       VALUE rub.nuElemDespesaInativo,
                'nuElemDespesaAtivoCLT'      VALUE rub.nuElemDespesaAtivoCLT,
                'nuElemDespesaPensaoEsp'     VALUE rub.nuElemDespesaPensaoEsp,
                'nuElemDespesaCTISP'         VALUE rub.nuElemDespesaCTISP
              ABSENT ON NULL),
              'Folha13Salario' VALUE JSON_OBJECT(
                'nuElemDespesaAtivo13'       VALUE rub.nuElemDespesaAtivo13,
                'nuElemDespesaRegGeral13'    VALUE rub.nuElemDespesaRegGeral13,
                'nuElemDespesaInativo13'     VALUE rub.nuElemDespesaInativo13,
                'nuElemDespesaAtivoCLT13'    VALUE rub.nuElemDespesaAtivoCLT13,
                'nuElemDespesaPensaoEsp13'   VALUE rub.nuElemDespesaPensaoEsp13,
                'nuElemDespesaCTISP13'       VALUE rub.nuElemDespesaCTISP13
              ABSENT ON NULL)
            ABSENT ON NULL) END,
            'Consignacao'                    VALUE
      	    CASE WHEN csgt.nuCodigoConsignataria IS NULL AND rub.nuOutraConsignataria IS NULL
      		    AND NULLIF(rub.flExtraOrcamentaria, 'N') IS NULL
              THEN NULL
            ELSE JSON_OBJECT(
                'nuCodigoConsignataria'      VALUE csgt.nuCodigoConsignataria,
                'nuOutraConsignataria'       VALUE rub.nuOutraConsignataria,
                'flExtraOrcamentaria'        VALUE NULLIF(rub.flExtraOrcamentaria, 'N')
             ABSENT ON NULL) END
          ABSENT ON NULL RETURNING CLOB) END,
          'Agrupamento'                      VALUE rubagrup.RubricaAgrupamento
        ABSENT ON NULL RETURNING CLOB) AS Tipo
      FROM epagRubrica rub
      INNER JOIN epagTipoRubrica tp ON tp.cdTipoRubrica = rub.cdTipoRubrica
      INNER JOIN TipoRubricaVigencia vigencia ON vigencia.cdRubrica = rub.cdRubrica
      LEFT JOIN epagConsignataria csgt ON csgt.cdConsignataria = rub.cdConsignataria
      LEFT JOIN RubricaAgrupamento rubagrup ON rubagrup.nuRubrica = LPAD(tp.nuTipoRubrica, 2, 0) || '-' || LPAD(rub.nuRubrica,4,0)
      ),
      -- NaturezaRubrica: natureza da rubrica e as vigências dos tipos de rubricas
      NaturezaRubrica AS (
        SELECT
          rub.cdRubrica,
          CASE
            WHEN tp.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
            WHEN tp.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
            WHEN tp.nuTipoRubrica = 9 THEN '09'
          END nuNaturezaRubrica,
          LPAD(rub.nuRubrica, 4, 0) AS nuRubrica,
          tp.nmTipoRubrica AS nmNaturezaRubrica,
          JSON_VALUE(vigencia.VigenciasTipo, '$[0].deRubrica') AS deRubrica
        FROM epagRubrica rub
        INNER JOIN epagTipoRubrica tp ON tp.cdTipoRubrica = rub.cdTipoRubrica
        LEFT JOIN TipoRubricaVigencia vigencia ON vigencia.cdRubrica = rub.cdRubrica
        WHERE tp.nuTipoRubrica IN (1, 5, 9)
      ),
      -- TiposRubricas: estrutura final por tipo de rubrica
      TiposRubricas AS (
        SELECT tprub.sgAgrupamento, tprub.sgOrgao, rub.nuNaturezaRubrica, rub.nuRubrica,
          JSON_OBJECT(
            'PAG' VALUE JSON_OBJECT(
              'Rubrica' VALUE JSON_OBJECT(
                'nuNaturezaRubrica'         VALUE rub.nuNaturezaRubrica,
                'nuRubrica'                 VALUE rub.nuRubrica,
                'nmNaturezaRubrica'         VALUE rub.nmNaturezaRubrica,
                'deRubrica'                 VALUE rub.deRubrica,
                'Tipos' VALUE JSON_ARRAYAGG(tprub.Tipo
      		  ORDER BY TO_NUMBER(tprub.nuTipoRubrica) RETURNING CLOB)
              ABSENT ON NULL RETURNING CLOB)
            ABSENT ON NULL RETURNING CLOB)
          RETURNING CLOB) AS Rubrica
        FROM TipoRubrica tprub
        INNER JOIN NaturezaRubrica rub ON rub.nuNaturezaRubrica = tprub.nuNaturezaRubrica
               AND rub.nuRubrica = tprub.nuRubrica
        WHERE tprub.sgAgrupamento = psgAgrupamento 
          AND (rub.nuNaturezaRubrica || '-' || rub.nuRubrica LIKE pcdIdentificacao OR pcdIdentificacao IS NULL)
        GROUP BY tprub.sgAgrupamento, tprub.sgOrgao, rub.nuNaturezaRubrica, rub.nuRubrica, rub.nmNaturezaRubrica, rub.deRubrica
      )
      SELECT 
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        nuNaturezaRubrica || '-' || nuRubrica AS cdIdentificacao,
        Rubrica AS jsConteudo,
        pnuVersao AS nuVersao,
        pflAnulado AS flAnulado,
        SYSTIMESTAMP AS dtInclusao
      FROM TiposRubricas
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorRubricas;

END PKGMIG_ParametrizacaoRubricas;
/
