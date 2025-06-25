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

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;
    vtxResumo           VARCHAR2(4000) := NULL;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas
    vRefCursor SYS_REFCURSOR;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_Parametrizacao.pConsoleLog('Inicio da Exportação das Parametrizações das ' ||
      'Rubricas do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	    'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_Parametrizacao.pConsoleLog('Nível de Auditoria Habilitado ' ||
          CASE pnuNivelAuditoria
            WHEN cAUDITORIA_SILENCIADO THEN 'SILENCIADO'
            WHEN cAUDITORIA_ESSENCIAL  THEN 'ESSENCIAL'
            WHEN cAUDITORIA_DETALHADO  THEN 'DETALHADO'
            WHEN cAUDITORIA_COMPLETO   THEN 'COMPLETO'
            ELSE 'ESSENCIAL'
          END, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

	  -- Defini o Cursos com a Query que Gera o Documento JSON Rubricas
	  vRefCursor := fnCursorRubricas(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito,
      vdtOperacao, vnuVersao, vflAnulado);

	  vnuRegistros := 0;

    -- Loop principal de processamento
	  LOOP
      FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
	      rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado, rdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      PKGMIG_Parametrizacao.pConsoleLog('Exportação da Rubrica ' || rcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      INSERT INTO emigParametrizacao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
		    cdIdentificacao, jsConteudo, dtInclusao, nuVersao, flAnulado
      ) VALUES (
        rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
		    rcdIdentificacao, rjsConteudo, rdtInclusao, rnuVersao, rflAnulado
      );

	    vnuRegistros := vnuRegistros + 1;
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
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
    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'RUBRICA', 'RESUMO', 'Exportação das Parametrizações das Rubricas do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    PKGMIG_Parametrizacao.pConsoleLog('Termino da Exportação das Parametrizações das Rubricas do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Exportação de Rubrica ' || vcdIdentificacao ||
      ' RUBRICA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'RUBRICA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15) := NULL;
    vsgModulo              CONSTANT CHAR(3)      := 'PAG';
    vsgConceito            CONSTANT VARCHAR2(20) := 'RUBRICA';
    vtpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(70) := NULL;
    vcdRubricaNova         NUMBER       := NULL;

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
        ORDER BY cfg.cdIdentificacao
      )
      SELECT * FROM epagRubricaImportar;
      
  BEGIN
    
    vdtOperacao := LOCALTIMESTAMP;

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = vsgModulo AND sgConceito = vsgConceito
      AND sgAgrupamento = psgAgrupamentoOrigem AND sgOrgao IS NULL;

    PKGMIG_Parametrizacao.pConsoleLog('Inicio da Importação das Parametrizações das ' ||
      'Rubricas do Agrupamento ' || psgAgrupamentoOrigem || ' ' ||
      'para o Agrupamento ' || psgAgrupamentoDestino || ', ' || CHR(13) || CHR(10) ||
      'Data da Exportacao ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI:SS') || ', ' || CHR(13) || CHR(10) ||
      'Data da Operação   ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    IF cAUDITORIA_ESSENCIAL != pnuNivelAuditoria THEN
        PKGMIG_Parametrizacao.pConsoleLog('Nível de Auditoria Habilitado ' ||
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
      vcdIdentificacao := r.cdIdentificacao || ' ' || LPAD(r.cdTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0);
  
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - Rubrica ' || vcdIdentificacao,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);


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
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'RUBRICA', 'INCLUSAO', 'Rubrica Incluídas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      ELSE
        -- Atualizar Rubrica Existente
        vcdRubricaNova := r.cdrubrica;

        UPDATE epagRubrica SET
          cdTipoRubrica           = r.cdTipoRubrica,
          nuRubrica               = r.nuRubrica,
          nuElemDespesaAtivo      = r.nuElemDespesaAtivo,
          nuElemDespesaInativo    = r.nuElemDespesaInativo,
          cdConsignataria         = r.cdConsignataria,
          nuOutraConsignataria    = r.nuOutraConsignataria,
          flExtraOrcamentaria     = r.flExtraOrcamentaria,
          nuSubAcao               = r.nuSubAcao,
          nuFonteRecurso          = r.nuFonteRecurso,
          nuCNPJOutroCredor       = r.nuCNPJOutroCredor,
          nuUnidadeOrcamentaria   = r.nuUnidadeOrcamentaria,
          nuElemDespesaAtivoCLT   = r.nuElemDespesaAtivoCLT,
          nuElemDespesaPensaoEsp  = r.nuElemDespesaPensaoEsp,
          nuElemDespesaAtivo13    = r.nuElemDespesaAtivo13,
          nuElemDespesaInativo13  = r.nuElemDespesaInativo13,
          nuElemDespesaAtivoCLT13 = r.nuElemDespesaAtivoCLT13,
          nuElemDespesaPensaoEsp13= r.nuElemDespesaPensaoEsp13,
          nuElemDespesaRegGeral   = r.nuElemDespesaRegGeral,
          nuElemDespesaRegGeral13 = r.nuElemDespesaRegGeral13,
          nuElemDespesaCTISP      = r.nuElemDespesaCTISP,
          nuElemDespesaCTISP13    = r.nuElemDespesaCTISP13,
          inNaturezaTCE           = r.inNaturezaTCE
        WHERE cdRubrica = vcdRubricaNova;

        vnuAtualizados := vnuAtualizados + 1;
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'RUBRICA', 'ATUALIZACAO', 'Rubrica atualizada com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Excluir Grupo de Rubricas, Documentos de Amparo ao Fato e Vigências da Rubrica
      --pExcluirRubrica(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      --  vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, pnuNivelAuditoria);
/*  
      -- Incluir Grupo de Rubricas na Rubrica
	    vnuRegistros := 0;
      FOR grrub IN (
        SELECT d.cdGrupoRubrica
          FROM json_table(r.GruposRubrica, '$[*]' COLUMNS (item VARCHAR2(100) PATH '$')) js
          LEFT JOIN epagGrupoRubrica d ON UPPER(d.nmGrupoRubrica) = UPPER(js.item)
      ) LOOP
		    vnuRegistros := vnuRegistros + 1;
        INSERT INTO epaggruporubricapagamento (cdRubrica, cdGrupoRubrica)
        VALUES (vcdRubricaNova, grrub.cdGrupoRubrica);
      END LOOP;
*/
      --PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
      --  vsgModulo, vsgConceito, vcdIdentificacao, vnuRegistros,
      --  'RUBRICA GRUPO DE RUBRICA', 'INCLUSAO', 'Grupo de Rubrica Incluídas com sucesso',
      --  cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
 
      -- Importar Vigências da Rubrica
      --pImportarVigencias(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      --  vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, r.VigenciasTipo, pnuNivelAuditoria);

      -- Importar Rubricas do Agrupamento
      PKGMIG_ParametrizacaoRubricasAgrupamento.pImportar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, r.Agrupamento, pnuNivelAuditoria);

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
      ' e Alteradas: ' || vnuAtualizados;

    PKGMIG_Parametrizacao.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Importação das Rubricas
    PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, 1,
      NULL, 'RESUMO', 'Importação das Parametrizações das Rubricas do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação dos Valores de Referencia
    PKGMIG_Parametrizacao.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_Parametrizacao.pConsoleLog('Termino da Importação das Parametrizações das Rubricas do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica ' || vcdIdentificacao ||
        ' RUBRICA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1, 'RUBRICA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
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
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - ' ||
        'RUBRICA GRUPO EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
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

--      UPDATE epagHistRubrica Vigencia SET Vigencia.cdDocumento = NULL
--        WHERE Vigencia.cdHistRubrica = d.cdHistRubrica;

--      DELETE FROM eatoDocumento
--        WHERE cdDocumento = d.cdDocumento;

      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - ' ||
        'DOCUMENTO EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
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
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - ' ||
        'RUBRICA VIGENCIA EXCLUSAO ' || vcdIdentificacao, cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA VIGENCIA', 'EXCLUSAO', 'Vigência da Rubrica excluidas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica ' || vcdIdentificacao ||
        ' RUBRICA VIGENCIA EXCLUIR Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA VIGENCIA EXCLUIR', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
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
        TO_DATE(js.dtPublicacao, 'yyyy-mm-dd') AS dtPublicacao,
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
	
	      vcdIdentificacao := pcdIdentificacao || ' ' || LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0);

        PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - ' ||
        'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
/*
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
            'DOCUMENTO', 'INCLUSAO', 'Documentos de Amparo da Rubrica Incluídas com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
	      END IF;
*/
/*    
        -- Inserir na tabela epagHistRubrica
        INSERT INTO epagHistRubrica (
          cdHistRubrica, cdRubrica, deRubrica, nuAnoInicioVigencia, nuMesInicioVigencia,
          nuAnoFimVigencia, nuMesFimVigencia,
          nuCpfCadastrador, dtInclusao, dtUltAlteracao, 
          cdDocumento, cdMeioPublicacao, cdTipoPublicacao,
          dtPublicacao, nuPublicacao, nuPaginaInicial, deOutroMeio
        ) VALUES (
          r.cdHistRubrica, r.cdRubrica, r.deRubrica, r.nuAnoInicioVigencia, r.nuMesInicioVigencia,
          r.nuAnoFimVigencia, r.nuMesFimVigencia,
          r.nuCpfCadastrador, r.dtInclusao, r.dtUltAlteracao,
          r.cdDocumento, r.cdMeioPublicacao, r.cdTipoPublicacao,
          r.dtPublicacao, r.nuPublicacao, r.nuPaginaInicial, r.deOutroMeio
        );
*/
        vnuRegistros := vnuRegistros + 1;
        PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, pcdIdentificacao, 1,
          'RUBRICA VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica Incluídas com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_Parametrizacao.pConsoleLog('Importação da Rubrica - Vigências ' || vcdIdentificacao ||
      ' RUBRICA VIGENCIA Erro: ' || SQLERRM, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      PKGMIG_Parametrizacao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações das Rubricas
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR) RETURN SYS_REFCURSOR IS
    vRefCursor SYS_REFCURSOR;
  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Rubricas de Eventos de Pagamento com Os Eventos e as suas formulas de Cálculo de um Agrupamento
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

      --- Informações referente as Formulas de Calculo
      -- Referente as seguintes Tabelas:
      --   Formula => epagFormulaCalculo
      --   VersoesFormula => epagFormulaVersao
      --   VigenciasFormula => epagHistFormulaCalculo
      --   ExpressaoFormula => epagExpressaoFormCalc
      --   BlocosFormula => epagFormulaCalculoBloco
      --   BlocoExpressao => epagFormulaCalcBlocoExpressao
      --   BlocoExpressaoRubricas= > epagFormCalcBlocoExpRubAgrup
      --   
      -- BlocoExpressaoRubricas: expressões agrupadas por rubrica
      BlocoExpressaoRubricas AS (
        SELECT gprub.cdFormulaCalcBlocoExpressao,
          JSON_ARRAYAGG(TRIM(nuRubrica || ' ' || deRubrica) ORDER BY nuRubrica RETURNING CLOB) AS GrupoRubricas
        FROM epagFormCalcBlocoExpRubAgrup gprub
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = gprub.cdRubricaAgrupamento
        GROUP BY gprub.cdFormulaCalcBlocoExpressao
      ),
      -- BlocoExpressao: expressões individuais por tipo e ordem
      BlocoExpressao AS (
        SELECT blexp.cdFormulaCalcBlocoExpressao, blexp.cdFormulaCalculoBloco, tipoMneumonico.sgTipoMneumonico,
          JSON_OBJECT(
            'sgTipoMneumonico'        VALUE tipoMneumonico.sgTipoMneumonico,
            'deOperacao'              VALUE blexp.deOperacao,
            'inTipoRubrica'           VALUE DECODE(blexp.inTipoRubrica,
                                              'I', 'VALOR INTEGRAL',
                                              'P', 'VALOR PAGO',
                                              'R', 'VALOR REAL',
                                             NULL),
            'inRelacaoRubrica'        VALUE DECODE(blexp.inRelacaoRubrica,
                                              'R', 'RELACAO DE TRABALHO',
                                              'S', 'SOMATORIO',
                                            NULL),
            'inMes'                   VALUE DECODE(blexp.inMes,
                                              'AT', 'VALOR REFERENTE AO MES ATUAL',
                                              'AN', 'VALOR REFERENTE AO MES ANTERIOR',
                                            NULL),
            'nuMeses'                 VALUE blexp.nuMeses,
            'nuValor'                 VALUE blexp.nuValor,
            'flValorHoraMinuto'       VALUE NULLIF(blexp.flValorHoraMinuto, 'N'),
            'nuRubrica'               VALUE TRIM(rub.nuRubrica || ' ' || rub.deRubrica),
            'nuMesRubrica'            VALUE blexp.nuMesRubrica,
            'nuAnoRubrica'            VALUE blexp.nuAnoRubrica,
            'nmValorReferencia'       VALUE valorReferencia.nmValorReferencia,
            'sgBaseCalculo'           VALUE baseCalculo.sgBaseCalculo,
            'sgTabelaValorGeralCef'   VALUE valorGeral.sgTabelaValorGeralCef,
            'nmEstruturaCarreira'     VALUE cef.nmEstruturaCarreira,
            'cdFuncaoChefia'          VALUE blexp.cdFuncaoChefia,
            'deNivel'                 VALUE blexp.deNivel,
            'deReferencia'            VALUE blexp.deReferencia,
            'deCodigoCco'             VALUE blexp.deCodigoCco,
            'cdTipoAdicionalTempServ' VALUE blexp.cdTipoAdicionalTempServ,
            'GrupoRubricas'           VALUE grupoRub.GrupoRubricas
--              CASE WHEN JSON_EXISTS(grupoRub.GrupoRubricas, '$.*') THEN NULL
--              ELSE grupoRub.GrupoRubricas END
            ABSENT ON NULL RETURNING CLOB) AS Expressao
        FROM epagFormulaCalcBlocoExpressao blexp
        INNER JOIN epagFormulaCalculoBloco bloco ON bloco.cdFormulaCalculoBloco = blexp.cdFormulaCalculoBloco
        INNER JOIN epagExpressaoFormCalc expFormula ON expFormula.cdExpressaoFormCalc = bloco.cdExpressaoFormCalc
        INNER JOIN epagHistFormulaCalculo vigencia ON vigencia.cdHistFormulaCalculo = expFormula.cdHistFormulaCalculo
        INNER JOIN epagFormulaVersao versao ON versao.cdFormulaVersao = vigencia.cdFormulaVersao
        INNER JOIN epagFormulaCalculo formula ON formula.cdFormulaCalculo = versao.cdFormulaCalculo
        LEFT JOIN epagTipoMneumonico tipoMneumonico ON tipoMneumonico.cdTipoMneumonico = blexp.cdTipoMneumonico
        LEFT JOIN BlocoExpressaoRubricas grupoRub ON grupoRub.cdFormulaCalcBlocoExpressao = blexp.cdFormulaCalcBlocoExpressao
        LEFT JOIN epagValorReferencia valorReferencia ON valorReferencia.cdAgrupamento = formula.cdAgrupamento
              AND valorReferencia.cdValorReferencia = blexp.cdValorReferencia
        LEFT JOIN epagBaseCalculo baseCalculo ON baseCalculo.cdAgrupamento = formula.cdAgrupamento
              AND baseCalculo.cdBaseCalculo = blexp.cdBaseCalculo
        LEFT JOIN epagValorGeralCefAgrup valorGeral ON valorGeral.cdAgrupamento = formula.cdAgrupamento
              AND valorGeral.cdValorGeralCefAgrup = blexp.cdValorGeralCefAgrup
        LEFT JOIN EstruturaCarreiraLista cef ON cef.cdEstruturaCarreira = blexp.cdEstruturaCarreira
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = blexp.cdRubricaAgrupamento
      ),
      -- BlocosFormula: blocos de cálculo compostos por expressões
      BlocosFormula AS (
        SELECT bloco.cdExpressaoFormCalc,
          JSON_ARRAYAGG(JSON_OBJECT(
            'sgBloco'   VALUE bloco.sgBloco,
            'Expressao' VALUE blexp.Expressao
            RETURNING CLOB) ORDER BY bloco.sgBloco RETURNING CLOB) AS Blocos
        FROM epagFormulaCalculoBloco bloco
        LEFT JOIN BlocoExpressao blexp ON blexp.cdFormulaCalculoBloco = bloco.cdFormulaCalculoBloco
        GROUP BY bloco.cdExpressaoFormCalc
      ),
      -- ExpressaoFormula: expressões utilizadas nas fórmulas
      ExpressaoFormula AS (
        SELECT expressao.cdHistFormulaCalculo,
          JSON_OBJECT(
            'deFormulaExpressao'        VALUE expressao.deFormulaExpressao,
            'deExpressao'               VALUE expressao.deExpressao,
            'deIndiceExpressao'         VALUE expressao.deIndiceExpressao,
            'flExpGeral'                VALUE NULLIF(expressao.flExpGeral, 'N'),
            'flDesprezaPropChoRubrica'  VALUE NULLIF(expressao.flDesprezaPropChoRubrica, 'N'),
            'flExigeIndice'             VALUE NULLIF(expressao.flExigeIndice, 'N'),
            'flValorHoraMinuto'         VALUE NULLIF(expressao.flValorHoraMinuto, 'N'),
            'nmEstruturaCarreira'       VALUE cef.nmEstruturaCarreira,
            'nmUnidadeOrganizacional'   VALUE expressao.cdUnidadeOrganizacional,
            'nmCargoComissionado'       VALUE expressao.cdCargoComissionado,
            'Blocos'                    VALUE blocos.Blocos,
            'FormulaEspecifica'         VALUE
              CASE WHEN expressao.cdFormulaEspecifica IS NULL AND expressao.deFormulaEspecifica IS NULL 
                    AND expressao.nuFormulaEspecifica IS NULL
                    THEN NULL
              ELSE JSON_OBJECT(
                'sgFormulaEspecifica'   VALUE expressao.cdFormulaEspecifica,
                'deFormulaEspecifica'   VALUE expressao.deFormulaEspecifica,
                'nuFormulaEspecifica'   VALUE expressao.nuFormulaEspecifica
              ABSENT ON NULL) END,
            'Limites'                   VALUE
              CASE WHEN expressao.cdValorRefLimInfParcial      IS NULL AND expressao.cdValorRefLimSupParcial   IS NULL 
                    AND expressao.cdValorRefLimInfFinal        IS NULL AND expressao.cdValorRefLimSupFinal     IS NULL
                    AND expressao.nuQtdeLimInfParcial          IS NULL AND expressao.nuQtdeLimiteSupParcial    IS NULL 
                    AND expressao.nuQtdeLimiteInfFinal         IS NULL AND expressao.nuQtdeLimiteSupFinal      IS NULL 
                    AND expressao.vlIndiceLimInferiorMensal    IS NULL AND expressao.vlIndiceLimSuperiorMensal IS NULL 
                    AND expressao.vlIndiceLimSuperiorSemestral IS NULL AND expressao.vlIndiceLimSuperiorAnual  IS NULL
                    THEN NULL
              ELSE JSON_OBJECT(
                'nmValorRefLimInfParcial'      VALUE vlrefLimInfParcial.nmValorReferencia,
                'nmValorRefLimSupParcial'      VALUE vlrefLimSupParcial.nmValorReferencia,
                'nmValorRefLimInfFinal'        VALUE vlrefLimInfFinal.nmValorReferencia,
                'nmValorRefLimSupFinal'        VALUE vlrefLimSupFinal.nmValorReferencia,
                'nuQtdeLimInfParcial'          VALUE expressao.nuQtdeLimInfParcial,
                'nuQtdeLimiteSupParcial'       VALUE expressao.nuQtdeLimiteSupParcial,
                'nuQtdeLimiteInfFinal'         VALUE expressao.nuQtdeLimiteInfFinal,
                'nuQtdeLimiteSupFinal'         VALUE expressao.nuQtdeLimiteSupFinal,
                'vlIndiceLimInferiorMensal'    VALUE expressao.vlIndiceLimInferiorMensal,
                'vlIndiceLimSuperiorMensal'    VALUE expressao.vlIndiceLimSuperiorMensal,
                'vlIndiceLimSuperiorSemestral' VALUE expressao.vlIndiceLimSuperiorSemestral,
                'vlIndiceLimSuperiorAnual'     VALUE expressao.vlIndiceLimSuperiorAnual
              ABSENT ON NULL) END
          ABSENT ON NULL RETURNING CLOB) AS Expressao
        FROM epagExpressaoFormCalc expressao
        INNER JOIN epagHistFormulaCalculo vigencia ON vigencia.cdHistFormulaCalculo = expressao.cdHistFormulaCalculo
        INNER JOIN epagFormulaVersao versao ON versao.cdFormulaVersao = vigencia.cdFormulaVersao
        INNER JOIN epagFormulaCalculo formula ON formula.cdFormulaCalculo = versao.cdFormulaCalculo
        LEFT JOIN BlocosFormula blocos ON blocos.cdExpressaoFormCalc = expressao.cdExpressaoFormCalc
        LEFT JOIN EstruturaCarreiraLista cef ON cef.cdEstruturaCarreira = expressao.cdEstruturaCarreira
        LEFT JOIN epagValorReferencia vlrefLimInfParcial ON vlrefLimInfParcial.cdAgrupamento = formula.cdAgrupamento
              AND vlrefLimInfParcial.cdValorReferencia = expressao.cdValorRefLimInfParcial
        LEFT JOIN epagValorReferencia vlrefLimSupParcial ON vlrefLimSupParcial.cdAgrupamento = formula.cdAgrupamento
              AND vlrefLimSupParcial.cdValorReferencia = expressao.cdValorRefLimSupParcial
        LEFT JOIN epagValorReferencia vlrefLimInfFinal ON vlrefLimInfFinal.cdAgrupamento = formula.cdAgrupamento
              AND vlrefLimInfFinal.cdValorReferencia = expressao.cdValorRefLimInfFinal
        LEFT JOIN epagValorReferencia vlrefLimSupFinal ON vlrefLimSupFinal.cdAgrupamento = formula.cdAgrupamento
              AND vlrefLimSupFinal.cdValorReferencia = expressao.cdValorRefLimSupFinal
      ),
      -- VigenciasFormula: vigências (períodos de validade) das fórmulas
      VigenciasFormula AS (
        SELECT vigencia.cdFormulaVersao,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nuAnoMesInicioVigencia' VALUE vigencia.nuAnoInicio || LPAD(vigencia.nuMesInicio, 2, '0'),
            'nuAnoMesFimVigencia'    VALUE vigencia.nuAnoFim || LPAD(vigencia.nuMesFim, 2, '0'),
            'Expressao'              VALUE expressao.Expressao
            ABSENT ON NULL RETURNING CLOB)
          ORDER BY vigencia.nuAnoInicio || LPAD(vigencia.nuMesInicio, 2, '0') DESC RETURNING CLOB) AS Vigencias
        FROM epagHistFormulaCalculo vigencia
        LEFT JOIN ExpressaoFormula expressao ON expressao.cdHistFormulaCalculo = vigencia.cdHistFormulaCalculo
        GROUP BY vigencia.cdFormulaVersao
      ),
      -- VersoesFormula: versões agrupadas das fórmulas
      VersoesFormula AS (
        SELECT versao.cdFormulaCalculo,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nuFormulaVersao' VALUE LPAD(versao.nuFormulaVersao, 2, '0'),
            'Vigencias'        VALUE vigencias.Vigencias
            ABSENT ON NULL RETURNING CLOB)
          ORDER BY versao.nuFormulaVersao RETURNING CLOB) AS Versoes
        FROM epagFormulaVersao versao
        LEFT JOIN VigenciasFormula vigencias ON vigencias.cdFormulaVersao = versao.cdFormulaVersao
        GROUP BY versao.cdFormulaCalculo
      ),
      -- Formula: definição da fórmula com versões embutidas
      Formula AS (
        SELECT formula.cdRubricaAgrupamento,
          JSON_OBJECT(
            'sgFormulaCalculo' VALUE formula.sgFormulaCalculo,
            'deFormulaCalculo' VALUE formula.deFormulaCalculo,
            'Versoes'          VALUE versoes.Versoes
          ABSENT ON NULL RETURNING CLOB) AS Formula
        FROM epagFormulaCalculo formula
        LEFT JOIN VersoesFormula versoes ON versoes.cdFormulaCalculo = formula.cdFormulaCalculo
      ),

      --- Informações referente aos Eventos
      -- Referente AS seguintes Tabelas:
      --   Evento => epagEventoPagAgrup
      --   VigenciaEvento => epagHistEventoPagAgrup
      --   GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
      --   GrupoOrgaoEvento => epagEventoPagAgrupOrgao
      --   
      -- GrupoCarreiraEvento: carreiras associadas a eventos
      GrupoCarreiraEvento AS (
        SELECT grupoCarreira.cdHistEventoPagAgrup,
          JSON_ARRAYAGG(cef.nmEstruturaCarreira ORDER BY cef.nmEstruturaCarreira RETURNING CLOB) AS EstruturaCarreira
        FROM epagHistEventoPagAgrupCarreira grupoCarreira
        INNER JOIN EstruturaCarreiraLista cef ON cef.cdEstruturaCarreira = grupoCarreira.cdEstruturaCarreira
        GROUP BY grupoCarreira.cdHistEventoPagAgrup
      ),
      -- GrupoOrgaoEvento: órgãos associados a eventos
      GrupoOrgaoEvento AS (
        SELECT grupoOrgao.cdHistEventoPagAgrup,
          JSON_ARRAYAGG(orgao.sgOrgao ORDER BY orgao.sgOrgao RETURNING CLOB) AS Orgaos
        FROM epagEventoPagAgrupOrgao grupoOrgao
        INNER JOIN OrgaoLista orgao ON orgao.cdOrgao = grupoOrgao.cdOrgao
        GROUP BY grupoOrgao.cdHistEventoPagAgrup
      ),
      -- VigenciaEvento: regras e condições de cálculo por vigência
      VigenciaEvento AS (
        SELECT vigencia.cdEventoPagAgrup, vigencia.cdRubricaAgrupamento,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nuAnoMesInicioVigencia'        VALUE vigencia.nuAnoRefInicial || LPAD(vigencia.nuMesRefInicial, 2, '0'),
            'nuAnoMesFimVigencia'           VALUE vigencia.nuAnoRefFinal || LPAD(vigencia.nuMesRefFinal, 2, '0'),
            'deDesconto'                    VALUE vigencia.deDesconto,
            'nuRubrica'                     VALUE TRIM(rub.nuRubrica || ' ' || rub.deRubrica),
            'MesPagamento'                  VALUE
      		  CASE WHEN vigencia.nuMesPagamento    IS NULL AND vigencia.nuMesPagamentoInicio IS NULL
      		        AND vigencia.nuMesPagamentoFim IS NULL
      		        THEN NULL
              ELSE JSON_OBJECT(
                'nuMesPagamento'            VALUE vigencia.nuMesPagamento,
                'nuMesPagamentoInicio'      VALUE vigencia.nuMesPagamentoInicio,
                'nuMesPagamentoFim'         VALUE vigencia.nuMesPagamentoFim
              ABSENT ON NULL) END,
            'nmRelacaoTrabalho'             VALUE UPPER(relTrab.nmRelacaoTrabalho),
            'Orgaos'                        VALUE
      		CASE WHEN NULLIF(vigencia.flAbrangeTodosOrgaos, 'N') IS NULL AND orgao.Orgaos IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'flAbrangeTodosOrgaos'      VALUE NULLIF(vigencia.flAbrangeTodosOrgaos, 'N'),
                'Orgaos'                    VALUE orgao.Orgaos
              ABSENT ON NULL) END,
            'Carreiras'                     VALUE
      		CASE WHEN DECODE(vigencia.inAcaoCarreira, '3', NULL, vigencia.inAcaoCarreira) IS NULL
                  AND grupoCarreira.cdHistEventoPagAgrup IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'inAcaoCarreira'            VALUE DECODE(vigencia.inAcaoCarreira,
                                                    '1', 'ALGUMAS IMPEDEM',
                                                    '2', 'ALGUMAS EXIGEM',
                                                    '3', NULL, --'TODAS PERMITEM',
                                                    '4', 'NENHUMA PERMITE',
                                                  NULL),
                'EstruturaCarreira'         VALUE grupoCarreira.EstruturaCarreira
              ABSENT ON NULL) END,
            'FormulaCalculo'                VALUE
      		CASE WHEN NULLIF(vigencia.flUtilizaFormulaCalculo, 'N') IS NULL AND vigencia.nuFormulaEspecifica IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'flUtilizaFormulaCalculo'   VALUE NULLIF(vigencia.flUtilizaFormulaCalculo, 'N'),
                'nuFormulaEspecifica'       VALUE vigencia.nuFormulaEspecifica
              ABSENT ON NULL) END,
            'ConquistaPeriodoAquisitivo'             VALUE
      		CASE WHEN vigencia.dtInicioConquistaPerAquis IS NULL AND vigencia.dtFimConquistaPerAquis IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'dtInicioConquistaPerAquis' VALUE vigencia.dtInicioConquistaPerAquis,
                'dtFimConquistaPerAquis'    VALUE vigencia.dtFimConquistaPerAquis
              ABSENT ON NULL) END,
            'Abrangencia'                   VALUE
      		    CASE WHEN vigencia.cdTipoComConselhoGrupo   IS NULL AND vigencia.cdTipoPensaoNaoPrev     IS NULL 
      		          AND vigencia.cdTipoTempoServico       IS NULL AND vigencia.cdTipoFuncaoChefia      IS NULL
      		          AND vigencia.cdTipoGratAtivFazendaria IS NULL AND vigencia.cdTipoRisco             IS NULL
      		          AND vigencia.cdTipoFalta              IS NULL AND vigencia.cdTipoFaltaParcialAgrup IS NULL 
      		          THEN NULL
      		    ELSE JSON_OBJECT(
                'cdTipoComConselhoGrupo'    VALUE vigencia.cdTipoComConselhoGrupo,
                'cdTipoPensaoNaoPrev'       VALUE vigencia.cdTipoPensaoNaoPrev,
                'cdTipoTempoServico'        VALUE vigencia.cdTipoTempoServico,
                'cdTipoFuncaoChefia'        VALUE vigencia.cdTipoFuncaoChefia,
                'cdTipoGratAtivFazendaria'  VALUE vigencia.cdTipoGratAtivFazendaria,
                'cdTipoRisco'               VALUE vigencia.cdTipoRisco,
                'cdTipoFalta'               VALUE vigencia.cdTipoFalta,
                'cdTipoFaltaParcialAgrup'   VALUE vigencia.cdTipoFaltaParcialAgrup
              ABSENT ON NULL) END
            ABSENT ON NULL RETURNING CLOB)
          ORDER BY vigencia.nuAnoRefInicial || LPAD(vigencia.nuMesRefInicial, 2, '0') DESC RETURNING CLOB) AS Vigencias
        FROM epagHistEventoPagAgrup vigencia
        LEFT JOIN GrupoCarreiraEvento grupoCarreira ON grupoCarreira.cdHistEventoPagAgrup = vigencia.cdHistEventoPagAgrup
        LEFT JOIN GrupoOrgaoEvento orgao ON orgao.cdHistEventoPagAgrup = vigencia.cdHistEventoPagAgrup
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = vigencia.cdRubricaAgrupamento
        LEFT JOIN ecadRelacaoTrabalho relTrab ON relTrab.cdRelacaoTrabalho = vigencia.cdRelacaoTrabalho
        GROUP BY vigencia.cdEventoPagAgrup, vigencia.cdRubricaAgrupamento
      ),
      -- Evento: eventos de pagamento vinculados à rubrica
      Evento AS (
        SELECT evento.cdAgrupamento, evento.cdRubricaAgrupamento,
          JSON_ARRAYAGG(JSON_OBJECT(
            'nmTipoEventoPagamento'         VALUE UPPER(tpEvento.nmTipoEventoPagamento),
            'deEvento'                      VALUE evento.deEvento,
            'nuRubrica'                     VALUE TRIM(rub.nuRubrica || ' ' || rub.deRubrica),
            'nuRubAgrupOpRecebCCO'          VALUE TRIM(rubCCO.nuRubrica || ' ' || rubCCO.deRubrica),
            'nuRubricaAgrupAlternativa2'    VALUE TRIM(rubAlt2.nuRubrica || ' ' || rubAlt2.deRubrica),
            'nuRubricaAgrupAlternativa3'    VALUE TRIM(rubAlt3.nuRubrica || ' ' || rubAlt3.deRubrica),
            'Vigencias'                     VALUE vigencia.Vigencias
          ABSENT ON NULL RETURNING CLOB)
          ORDER BY UPPER(tpEvento.nmTipoEventoPagamento), evento.deEvento RETURNING CLOB) AS Eventos
        FROM epagEventoPagAgrup evento
        INNER JOIN epagTipoEventoPagamento tpEvento ON tpEvento.cdTipoEventoPagamento = evento.cdTipoEventoPagamento
        LEFT JOIN VigenciaEvento vigencia ON vigencia.cdEventoPagAgrup = evento.cdEventoPagAgrup
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = evento.cdRubricaAgrupamento
        LEFT JOIN RubricaLista rubCCO ON rubCCO.cdRubricaAgrupamento = evento.cdRubAgrupOpRecebCCO
        LEFT JOIN RubricaLista rubAlt2 ON rubAlt2.cdRubricaAgrupamento = evento.cdRubricaAgrupAlternativa2
        LEFT JOIN RubricaLista rubAlt3 ON rubAlt3.cdRubricaAgrupamento = evento.cdRubricaAgrupAlternativa3
        GROUP BY evento.cdAgrupamento, evento.cdRubricaAgrupamento
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
              'mnRelacaoTrabalho'           VALUE relTrabVigencia.nmRelacaoTrabalho, -- cdRelacaoTrabalho
              'flCargaHorariaPadrao'        VALUE NULLIF(vigencia.flCargaHorariaPadrao, 'N'), -- DEFAULT S
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
            'LancamentoFinanceiro' VALUE JSON_OBJECT(
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
            ABSENT ON NULL),
            'GerarRubrica' VALUE JSON_OBJECT(
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
              'flGeraRubricaCarreiraIncideApo' VALUE NULLIF(vigencia.flGeraRubricaCarreiraIncideApo, 'N'), -- DEFAULT S
              'flGeraRubricaCarreiraIncideCCO' VALUE NULLIF(vigencia.flGeraRubricaCarreiraIncideCCO, 'N'), -- DEFAULT S
              'flGeraRubricaCCOIncideCEF'   VALUE NULLIF(vigencia.flGeraRubricaCCOIncideCEF, 'N'), -- DEFAULT S
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
            ABSENT ON NULL),
            'Proporcionalidade' VALUE JSON_OBJECT(
              'deTipoIndice'                VALUE tpIndice.deTipoIndice,       -- cdTipoIndice
              'nmRubProporcionalidadeCHO'   VALUE DECODE(vigencia.cdRubProporcionalidadeCHO,
                                                    '1', NULL, --'NAO APLICAR',
                                                    '2', 'APLICAR',
                                                    '3', 'APLICAR MEDIA',
                                                  NULL),
              'nuMesesApuracao'             VALUE vigencia.nuMesesApuracao,
              'flPropMesComercial'          VALUE NULLIF(vigencia.flPropMesComercial, 'N'), -- DEFAULT S
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
                FROM epagRubAgrupMotAfastTempImp afamottemp
                LEFT JOIN MotivoAfastamentoLista motivoTemp ON motivoTemp.cdMotivoAfastTemporario = afamottemp.cdMotivoAfastTemporario
                WHERE afamottemp.cdHistRubricaAgrupamento = vigencia.cdHistRubricaAgrupamento),
              'ListaMotivosAfastamentoExigidos' VALUE NULL -- (ListaMotivosAfastamentoExigidos ABSENT ON NULL RETURNING CLOB)
            ABSENT ON NULL),
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
              'flAplicaRubricaOrgaos'       VALUE NULLIF(vigencia.flAplicaRubricaOrgaos, 'N'), -- DEFAULT S
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
      SELECT rubagrup.cdRubrica, rubagrup.cdRubricaAgrupamento,
        a.sgAgrupamento,
        o.sgOrgao,
        JSON_OBJECT(
          'RubricaPropria'                  VALUE
      	  CASE WHEN rubagrup.flIncorporacao != 'S'   AND rubagrup.flPensaoAlimenticia != 'S'
      	    AND rubagrup.flAdiant13Pensao != 'S'     AND rubagrup.fl13SalPensao != 'S'
      			AND rubagrup.flConsignacao != 'S'        AND rubagrup.flTributacao != 'S'
      			AND rubagrup.flSalarioFamilia != 'S'     AND rubagrup.flSalarioMaternidade != 'S'
      			AND rubagrup.flDevTributacaoIPREV != 'S' AND rubagrup.flDevCorrecaoMonetaria != 'S'
      			AND rubagrup.flAbonoPermanencia != 'S'   AND rubagrup.flApostilamento != 'S'
      			AND rubagrup.flContribuicaoSindical != 'S'
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
            'flContribuicaoSindical'        VALUE NULLIF(rubagrup.flContribuicaoSindical, 'N')
          ABSENT ON NULL) END,
          'ParametrosAgrupamento'           VALUE JSON_OBJECT(
            'nmModalidadeRubrica'           VALUE modrub.nmModalidadeRubrica,
            'sgBaseCalculo'                 VALUE basecalc.sgBaseCalculo,
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
          ABSENT ON NULL),
          'VigenciasAgrupamento'            VALUE vigencia.VigenciasAgrupamento,
          'Eventos'                         VALUE evento.Eventos,
          'Formula'                         VALUE formula.Formula
        ABSENT ON NULL RETURNING CLOB) AS Agrupamento
      FROM epagRubricaAgrupamento rubagrup
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrup.cdAgrupamento
      LEFT JOIN ecadHistOrgao o ON o.cdOrgao = rubagrup.cdOrgao
      LEFT JOIN epagModalidadeRubrica modrub ON modrub.cdModalidadeRubrica = rubagrup.cdModalidadeRubrica
      LEFT JOIN epagBaseCalculo basecalc ON basecalc.cdAgrupamento = rubagrup.cdAgrupamento
                                        AND NVL(basecalc.cdOrgao, 0) = NVL(rubagrup.cdOrgao, 0)
                                        AND basecalc.cdBaseCalculo = rubagrup.cdBaseCalculo
      LEFT JOIN RubricaAgrupamentoVigencia vigencia ON vigencia.cdRubricaAgrupamento = rubagrup.cdRubricaAgrupamento
      LEFT JOIN Evento evento ON evento.cdRubricaAgrupamento = rubagrup.cdRubricaAgrupamento
      LEFT JOIN Formula formula ON formula.cdRubricaAgrupamento = rubagrup.cdRubricaAgrupamento
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
          'Empenho' VALUE JSON_OBJECT(
            'inNaturezaTCE'                 VALUE rub.inNaturezaTCE,
            'nuUnidadeOrcamentaria'         VALUE rub.nuUnidadeOrcamentaria,
            'nuSubAcao'                     VALUE rub.nuSubAcao,
            'nuFonteRecurso'                VALUE rub.nuFonteRecurso,
            'nuCNPJOutroCredor'             VALUE rub.nuCNPJOutroCredor,
            'ElementosDespesas'             VALUE
      	    CASE WHEN rub.nuElemDespesaAtivo     IS NULL AND rub.nuElemDespesaRegGeral   IS NULL
      		      AND rub.nuElemDespesaInativo     IS NULL AND rub.nuElemDespesaAtivoCLT   IS NULL
      		      AND rub.nuElemDespesaPensaoEsp   IS NULL AND rub.nuElemDespesaCTISP      IS NULL
      		      AND rub.nuElemDespesaAtivo13     IS NULL AND rub.nuElemDespesaRegGeral13 IS NULL
      		      AND rub.nuElemDespesaInativo13   IS NULL AND rub.nuElemDespesaAtivoCLT13 IS NULL
      		      AND rub.nuElemDespesaPensaoEsp13 IS NULL AND rub.nuElemDespesaCTISP13    IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'FolhaMensal' VALUE JSON_OBJECT(
                  'nuElemDespesaAtivo'       VALUE rub.nuElemDespesaAtivo,
                  'nuElemDespesaRegGeral'    VALUE rub.nuElemDespesaRegGeral,
                  'nuElemDespesaInativo'     VALUE rub.nuElemDespesaInativo,
                  'nuElemDespesaAtivoCLT'    VALUE rub.nuElemDespesaAtivoCLT,
                  'nuElemDespesaPensaoEsp'   VALUE rub.nuElemDespesaPensaoEsp,
                  'nuElemDespesaCTISP'       VALUE rub.nuElemDespesaCTISP
                ABSENT ON NULL),
                'Folha13Salario' VALUE JSON_OBJECT(
                  'nuElemDespesaAtivo13'     VALUE rub.nuElemDespesaAtivo13,
                  'nuElemDespesaRegGeral13'  VALUE rub.nuElemDespesaRegGeral13,
                  'nuElemDespesaInativo13'   VALUE rub.nuElemDespesaInativo13,
                  'nuElemDespesaAtivoCLT13'  VALUE rub.nuElemDespesaAtivoCLT13,
                  'nuElemDespesaPensaoEsp13' VALUE rub.nuElemDespesaPensaoEsp13,
                  'nuElemDespesaCTISP13'     VALUE rub.nuElemDespesaCTISP13
                ABSENT ON NULL)
              ABSENT ON NULL) END,
            'Consignacao'                    VALUE
      	    CASE WHEN csgt.nuCodigoConsignataria IS NULL AND rub.nuOutraConsignataria IS NULL
      		      AND rub.flExtraOrcamentaria != 'S'
                    THEN NULL
              ELSE JSON_OBJECT(
                'nuCodigoConsignataria'      VALUE csgt.nuCodigoConsignataria,
                'nuOutraConsignataria'       VALUE rub.nuOutraConsignataria,
                'flExtraOrcamentaria'        VALUE NULLIF(rub.flExtraOrcamentaria, 'N')
             ABSENT ON NULL) END
          ABSENT ON NULL RETURNING CLOB),
          rubagrup.Agrupamento
        ABSENT ON NULL RETURNING CLOB) AS Tipo
      FROM epagRubrica rub
      INNER JOIN epagTipoRubrica tp ON tp.cdTipoRubrica = rub.cdTipoRubrica
      INNER JOIN TipoRubricaVigencia vigencia ON vigencia.cdRubrica = rub.cdRubrica
      LEFT JOIN epagConsignataria csgt ON csgt.cdConsignataria = rub.cdConsignataria
      LEFT JOIN RubricaAgrupamento rubagrup ON rubagrup.cdRubrica = rub.cdRubrica
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
        GROUP BY tprub.sgAgrupamento, tprub.sgOrgao, rub.nuNaturezaRubrica, rub.nuRubrica, rub.nmNaturezaRubrica, rub.deRubrica
      )
      SELECT 
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        nunaturezarubrica || '-' || nurubrica AS cdIdentificacao,
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
