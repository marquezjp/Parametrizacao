-- Corpo do Pacote de Importação das Parametrizações de Consignações
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoConsignacoes AS


  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados Consignações partir do Documento Rubrica JSON
  --   contida na tabela emigParametrizacao, realizando:
  --     - Importação das Consignação não existente tabela epagConsignacao
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino IN VARCHAR2: Sigla do agrupamento de destino para os dados
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
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2 DEFAULT NULL,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao               VARCHAR2(15)          := Null;
    vsgModulo              CONSTANT CHAR(3)      := 'PAG';
    vsgConceito            CONSTANT VARCHAR2(20) := 'RUBRICA';
    vtpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(50)          := Null;

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
      "EPAGCONSIGNACAO",
      "EPAGHISTCONSIGNACAO",
      "EPAGCONTRATOSERVICO",
      "EPAGCONSIGNATARIA",
      "EPAGCONSIGNATARIASUSPENSAO",
      "EPAGCONSIGNATARIATAXASERVICO",
      "EPAGTIPOSERVICO",
      "EPAGHISTTIPOSERVICO",
      "EPAGPARAMETROBASECONSIGNACAO"
    ]';

    -- Cursor que extrai e transforma os dados JSON de Consignação
    CURSOR cDados IS
      WITH
      ConsignacoesExistentes AS (
        SELECT LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica
        FROM epagConsignacao csg
        LEFT JOIN epagRubrica rub ON rub.cdRubrica = csg.cdRubrica
        LEFT JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
      ),
      
      -- Consignações das Parametrizações das Rubricas
      Consignacoes AS (
        SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao,
          parm.cdIdentificacao, js.nuRubrica, js.deRubrica, rubagrp.cdRubricaAgrupamento,
          NVL2(csgexiste.nuRubrica, 'S', 'N') AS flConsignacaoExiste,
          js.nuCodigoConsignataria, js.sgConsignataria,
          NVL2(cgt.nuCodigoConsignataria, 'S', 'N') AS flConsignatariaExiste,
          js.nmTipoServico,
          NVL2(tpserv.nmTipoServico, 'S', 'N') AS flTipoServicoExiste,
          JSON_SERIALIZE(TO_CLOB(js.Consignacao) RETURNING CLOB) AS Consignacao
        FROM emigParametrizacao parm
        CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao' COLUMNS (
          nuRubrica             PATH '$.nuRubrica',
          deRubrica             PATH '$.deRubrica',
          nuCodigoConsignataria PATH '$.Consignataria.nuCodigoConsignataria',
          sgConsignataria       PATH '$.Consignataria.sgConsignataria',
          nmTipoServico         PATH '$.TipoServico.nmTipoServico',
          Consignacao           CLOB FORMAT JSON PATH '$'
        )) js
        INNER JOIN ecadAgrupamento a ON a.sgAgrupamento = psgAgrupamentoDestino
        LEFT JOIN epagTipoRubrica tprub ON tprub.nuTipoRubrica = SUBSTR(parm.cdIdentificacao,1,2)
        LEFT JOIN epagRubrica rub ON rub.cdTipoRubrica = tprub.cdTipoRubrica
                                 AND rub.nuRubrica = SUBSTR(parm.cdIdentificacao,4,4)
        LEFT JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdAgrupamento =  a.cdAgrupamento
                                                AND rubagrp.cdRubrica =  rub.cdRubrica
        LEFT JOIN ConsignacoesExistentes csgexiste ON csgexiste.nuRubrica = js.nuRubrica
        LEFT JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
        LEFT JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        WHERE parm.sgModulo = vsgModulo AND parm.sgConceito = vsgConceito AND parm.flAnulado = 'N'
          AND parm.sgAgrupamento = psgAgrupamentoOrigem AND NVL(parm.sgOrgao, ' ') = NVL(vsgOrgao, ' ')
          AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI')
          AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
        ORDER BY parm.cdIdentificacao
      )
      SELECT * FROM Consignacoes;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = vsgModulo AND sgConceito = vsgConceito
      AND sgAgrupamento = psgAgrupamentoOrigem AND sgOrgao IS NULL;

    IF pcdIdentificacao IS NULL THEN
      vtxMensagem := 'Inicio da Importação das Parametrizações das Consignações ';
    ELSE
      vtxMensagem := 'Inicio da Importação da Parametrização da Consignação "' || pcdIdentificacao || '" ';
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

    vnuInseridos := 0;
    vnuAtualizados := 0;
    vContador      := 0;

    -- Loop principal de processamento para Incluir as Consignações
    FOR r IN cDados LOOP
  
      vsgOrgao := r.sgOrgao;
      vcdIdentificacao := r.cdIdentificacao;

      IF r.cdRubricaAgrupamento IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Rubrica da Consignação Inexistente no Agrupamento ' || vcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'CONSIGNAÇÃO', 'INCONSISTENTE',
          'Rubrica da Consignação Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdIdentificacao != r.nuRubrica THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Rubrica da Consignação diferente da Rubrica do Agrupamento ' || vcdIdentificacao || ' ' || r.nuRubrica,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao || ' ' || r.nuRubrica, 1,
          'CONSIGNAÇÃO', 'INCONSISTENTE',
          'Rubrica da Consignação diferente da Rubrica do Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.flConsignatariaExiste = 'N' THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Consignatária Inexistente ' || vcdIdentificacao || ' ' || r.nuCodigoConsignataria || ' ' || r.sgConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, SUBSTR(vcdIdentificacao || ' ' || r.nuCodigoConsignataria || ' ' || r.sgConsignataria,1,70), 1,
          'CONSIGNAÇÃO', 'INCONSISTENTE',
          'Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.nmTipoServico IS NOT NULL AND r.flTipoServicoExiste = 'N' THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Tipo de Serviço Inexistente ' || vcdIdentificacao || ' ' || r.nmTipoServico,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, SUBSTR(vcdIdentificacao || ' ' || r.nmTipoServico,1,70), 1,
          'CONSIGNAÇÃO', 'INCONSISTENTE',
          'Tipo de Serviço Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.flConsignacaoExiste = 'S' THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Rubrica da Consignação já cadastrada ' || vcdIdentificacao || ' ' || r.nuRubrica,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao || ' ' || r.nuRubrica, 0,
          'CONSIGNAÇÃO', 'INCLUSAO',
          'Rubrica da Consignação já cadastrada',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdRubricaAgrupamento IS NOT NULL AND r.cdIdentificacao = r.nuRubrica AND
         r.flConsignacaoExiste = 'N' AND r.flConsignatariaExiste = 'S' AND
         (r.nmTipoServico IS NULL OR r.flTipoServicoExiste = 'S') THEN

        -- Incluir Consignação
        vContador := vContador + 1;
        vnuInseridos := vnuInseridos + 1;
        pImportarConsignacao(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
          vsgModulo, vsgConceito, vcdIdentificacao, r.cdRubricaAgrupamento, r.Consignacao, pnuNivelAuditoria);

        IF MOD(vContador, vCommitLote) = 0 THEN
          COMMIT;
        END IF;
      END IF;

    END LOOP;

    COMMIT;

    -- Gerar as Estatísticas da Importação das Consignações
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
	    'Total de Parametrizações das Consignações Incluídas: ' || vnuInseridos ||
      ' e Alteradas: ' || vnuAtualizados;

    --PKGMIG_ParametrizacaoLog.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
    --  vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Importação das Consignações
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'CONSIGNACAO', 'RESUMO', 'Importação das Parametrizações das Consignações do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação das Consignações
    --PKGMIG_ParametrizacaoLog.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
    --  vsgModulo, vsgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pAlertar('Termino da Importação das Parametrizações das Consignações do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'CONSIGNACAO',
          'Importação das Consignações (PKGMIG_ParametrizacaoConsignacoes.pImportar)', SQLERRM);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pImportarConsignacao(
  -- ###########################################################################
  -- PROCEDURE: pImportarConsignacao
  -- Objetivo:
  --   Importar dados das Consignações do Documento Versões JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão da Consignação não existente tabela epagConsignacao
  --     - Importação das Vigências da Consignação não existente
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
  --   pConsignacao          IN CLOB: 
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'ESSENCIAL' nível mínimo de mensagens;
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
    pConsignacao          IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao      VARCHAR2(70) := Null;
    vcdConsignacaoNova    NUMBER := 0;
    vcdContratoServicoNovo NUMBER := 0;
    vnuRegistros          NUMBER := 0;

    -- Cursor que extrai as Consignações do Documento Consignacao JSON
    CURSOR cDados IS
      WITH
        ConsignacoesExistentes AS (
        SELECT LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica
        FROM epagConsignacao csg
        LEFT JOIN epagRubrica rub ON rub.cdRubrica = csg.cdRubrica
        LEFT JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
        ),
        Consignacao AS (
        SELECT
        cgt.cdConsignataria AS cdConsignataria, js.nuCodigoConsignataria,
        rubagrp.cdRubrica AS cdRubrica, js.nuRubrica, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubricaAgrupamento,
        tpserv.cdTipoServico AS cdTipoServico, js.nmTipoServico,
        NULL AS cdContratoServico, js.nuContrato,
        CASE WHEN js.dtInicioConcessao IS NULL THEN NULL
          ELSE TO_DATE(js.dtInicioConcessao, 'YYYY-MM-DD') END AS dtInicioConcessao,
        CASE WHEN js.dtFimConcessao IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimConcessao, 'YYYY-MM-DD') END AS dtFimConcessao,
        NVL(js.flGeridaTerceitos, 'N') AS flGeridaSCConsig,
        NVL(js.flRepasse, 'N') AS flRepasse,
        TRUNC(SYSDATE) AS dtInclusao,
        SYSTIMESTAMP AS dtUltAlteracao,
        JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias,
        JSON_SERIALIZE(TO_CLOB(js.ContratoServico) RETURNING CLOB) AS ContratoServico
        
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao
        FROM JSON_TABLE(pConsignacao, '$' COLUMNS (
          nuRubrica             PATH '$.nuRubrica',
          deRubrica             PATH '$.deRubrica',
          dtInicioConcessao     PATH '$.dtInicioConcessao',
          dtFimConcessao        PATH '$.dtFimConcessao',
          flGeridaTerceitos     PATH '$.flGeridaTerceitos',
          flRepasse             PATH '$.flRepasse',
          nuCodigoConsignataria PATH '$.Consignataria.nuCodigoConsignataria',
          sgConsignataria       PATH '$.Consignataria.sgConsignataria',
          nmTipoServico         PATH '$.TipoServico.nmTipoServico',
          nuContrato            PATH '$.ContratoServico.nuContrato',
          Vigencias             CLOB FORMAT JSON PATH '$.Vigencias',
          ContratoServico       CLOB FORMAT JSON PATH '$.ContratoServico'
        )) js
        INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubricaAgrupamento =  pcdRubricaAgrupamento
        INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrp.cdRubrica
        INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
        INNER JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
        LEFT JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        LEFT JOIN ConsignacoesExistentes csgexiste ON csgexiste.nuRubrica = LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
        --WHERE csgexiste.nuRubrica IS NOT NULL
      )
      SELECT * FROM Consignacao;

    BEGIN

      vcdIdentificacao := pcdIdentificacao;
  
      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignação - ' ||
        vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
  	
      -- Loop principal de processamento para Incluir as Consignações não Existentes
      FOR r IN cDados LOOP
  
    	  vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuRubrica,1,70);
    
        -- Importar Contrato de Serviço
        vcdContratoServicoNovo := NULL;
        --IF r.nuContrato IS NOT NULL THEN
        --  pImportarContratoServico(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        --    psgModulo, psgConceito, vcdIdentificacao, r.ContratoServico, vcdContratoServicoNovo, pnuNivelAuditoria);
        --END IF;

    	  -- Inserir na tabela epagConsignacao
    	  SELECT NVL(MAX(cdConsignacao), 0) + 1 INTO vcdConsignacaoNova FROM epagConsignacao;
    
          --INSERT INTO epagConsignacao (
          --  cdConsignacao, cdConsignataria, cdRubrica, cdTipoServico, cdContratoServico,
          --  dtInicioConcessao, dtFimConcessao, dtInclusao, dtUltAlteracao, flGeridaSCConsig, flRepasse
          --) VALUES (
          --  vcdConsignacaoNova, r.cdConsignataria, r.cdRubrica, r.cdTipoServico, vcdContratoServicoNovo,
          --  r.dtInicioConcessao, r.dtFimConcessao, r.dtInclusao, r.dtUltAlteracao, r.flGeridaSCConsig, r.flRepasse
          --);
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCLUSAO',
            'Consignação incluída com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    
          -- Importar Vigencias da Consignação
          pImportarVigenciasConsignacao(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, vcdConsignacaoNova, r.Vigencias, pnuNivelAuditoria);

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'CONSIGNACAO',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarConsignacao)', SQLERRM);
      RAISE;
  END pImportarConsignacao;

  PROCEDURE pImportarVigenciasConsignacao(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigenciasConsignacao
  -- Objetivo:
  --   Importar dados das Vigências da Consignação do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão do Documento de Amparo ao Fato da Vigência da Consignação 
  --       na tabela eatoDocumento
  --     - Inclusão das Vigências da Consignação na tabela epagHistConsignacao
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
  --   pcdConsignacao        IN NUMBER:
  --   pVigenciasConsignacao IN CLOB:
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
    pcdConsignacao        IN NUMBER,
    pVigenciasConsignacao IN CLOB,
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao       VARCHAR2(70) := Null;
    vcdHistConsignacaoNova NUMBER := Null;
    vcdDocumentoNovo       NUMBER := Null;
    vnuRegistros           NUMBER := 0;

    -- Cursor que extrai as Vigências da Consignação do Documento pVigenciasConsignacao JSON
    CURSOR cDados IS
      WITH
      Vigencia AS (
      SELECT
        pcdConsignacao AS cdConsignacao,
      
      	CASE WHEN js.dtInicioVigencia IS NULL THEN NULL
          ELSE TO_DATE(js.dtInicioVigencia, 'YYYY-MM-DD') END AS dtInicioVigencia,
      	CASE WHEN js.dtFimVigencia IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimVigencia, 'YYYY-MM-DD') END AS dtFimVigencia,
      
        NVL(js.nuMaxParcelas, 999) AS nuMaxParcelas,
        js.vlMinConsignado,
        js.vlMinDescontoFolha,
      
        NVL(js.flMaisDeUmaOcorrencia, 'S') AS flMaisDeUmaOcorrencia,
        NVL(js.flLancamentoManual, 'N') AS flLancamentoManual,
        NVL(js.flDescontoEventual, 'N') AS flDescontoEventual,
        NVL(js.flDescontoParcial, 'N') AS flDescontoParcial,
        NVL(js.flFormulaCalculo, 'N') AS flFormulaCalculo,
      
        js.vlRetencao,
        js.vlTaxaRetencao,
        js.vlTaxaIR,
        js.vlTaxaAdministracao,
        js.vlTaxaProlabore,
        js.vlTaxaBescor,
      
        js.Documento,

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
      
      -- Caminho Absoluto no Documento JSON
      -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.Vigencias[*]
      FROM JSON_TABLE(pVigenciasConsignacao, '$[*]' COLUMNS (
        dtInicioVigencia          PATH '$.dtInicioVigencia',
        dtFimVigencia             PATH '$.dtFimVigencia',
      
        nuMaxParcelas             PATH '$.Parametros.nuMaxParcelas',
        vlMinConsignado           PATH '$.Parametros.vlMinConsignado',
        vlMinDescontoFolha        PATH '$.Parametros.vlMinDescontoFolha',
        flMaisDeUmaOcorrencia     PATH '$.Parametros.flMaisDeUmaOcorrencia',
        flLancamentoManual        PATH '$.Parametros.flLancamentoManual',
        flDescontoEventual        PATH '$.Parametros.flDescontoEventual',
        flDescontoParcial         PATH '$.Parametros.flDescontoParcial',
        flFormulaCalculo          PATH '$.Parametros.flFormulaCalculo',
      
        vlRetencao                PATH '$.TaxaRetencao.vlRetencao',
        vlTaxaRetencao            PATH '$.TaxaRetencao.vlTaxaRetencao',
        vlTaxaIR                  PATH '$.TaxaRetencao.vlTaxaIR',
        vlTaxaAdministracao       PATH '$.TaxaRetencao.vlTaxaAdministracao',
        vlTaxaProlabore           PATH '$.TaxaRetencao.vlTaxaProlabore',
        vlTaxaBescor              PATH '$.TaxaRetencao.vlTaxaBescor',
      
        Documento                 PATH '$.Documento',
        
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
      )
      SELECT * FROM Vigencia;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
         TO_CHAR(r.dtInicioVigencia, 'YYYYMMDD'),1,70);
       
      -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
      --pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      --  psgModulo, psgConceito, vcdIdentificacao,
      --  r.Documento, vcdDocumentoNovo,
      --  pnuNivelAuditoria);

      -- Incluir Nova Vigência da Consignação
      SELECT NVL(MAX(cdHistConsignacao), 0) + 1 INTO vcdHistConsignacaoNova FROM epagHistConsignacao;

      --INSERT INTO epagHistConsignacao (
      --  cdHistConsignacao, cdConsignacao, dtInicioVigencia, dtFimVigencia,
      --  vlMinConsignado, flLancamentoManual, flDescontoParcial, flFormulaCalculo, vlMinDescontoFolha,
      --  nuMaxParcelas, flMaisDeUmaOcorrencia, vlTaxaRetencao, vlRetencao, vlTaxaIR, vlTaxaAdministracao,
      --  vlTaxaProlabore, flDescontoEventual,
      --  cdDocumento, cdTipoPublicacao, dtPublicacao, nuPublicacao, nuPagInicial, cdMeioPublicacao, deOutroMeio,
      --  nuCPFCadastrador, dtInclusao, dtUltAlteracao, vlTaxaBescor
      --) VALUES (
      --  vcdHistConsignacaoNova, r.cdConsignacao, r.dtInicioVigencia, r.dtFimVigencia,
      --  r.vlMinConsignado, r.flLancamentoManual, r.flDescontoParcial, r.flFormulaCalculo, r.vlMinDescontoFolha,
      --  r.nuMaxParcelas, r.flMaisDeUmaOcorrencia, r.vlTaxaRetencao, r.vlRetencao, r.vlTaxaIR, r.vlTaxaAdministracao,
      --  r.vlTaxaProlabore, r.flDescontoEventual,
      --  vcdDocumentoNovo, r.cdTipoPublicacao,  r.dtPublicacao, r.nuPublicacao, r.nuPagInicial, r.cdMeioPublicacao, r.deOutroMeio,
      --  r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao, r.vlTaxaBescor
      --);

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'CONSIGNACAO VIGENCIA', 'INCLUSAO',
        'Vigência da Consignação incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'CONSIGNACAO VIGENCIA',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarVigenciasConsignacao)', SQLERRM);
      RAISE;
  END pImportarVigenciasConsignacao;

  PROCEDURE pImportarContratoServico(
  -- ###########################################################################
  -- PROCEDURE: pImportarContratoServico
  -- Objetivo:
  --   Importar dados do Contrato de Serviço da Consignação do Documento
  --     Contrato de Serviço JSON contido na tabela emigParametrizacao, realizando:
  --     - Inclusão do Documento de Amparo ao Fato do Contrato de Serviço da
  --       Consignação na tabela eatoDocumento
  --     - Inclusão do Contrato de Serviço da Consignação na tabela epagContratoServico
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
  --   pcdConsignacao        IN NUMBER:
  --   pContratoServico      IN CLOB:
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
    pContratoServico      IN CLOB,
    pcdContratoServico    OUT NUMBER,
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao       VARCHAR2(70) := Null;
    vcdDocumentoNovo       NUMBER := Null;
    vnuRegistros           NUMBER := 0;

    -- Cursor que extrai o Contrato de Serviço da Consignação do Documento pContratoServico JSON
    CURSOR cDados IS
      WITH
      ContratoServico AS (
      SELECT
        NULL AS cdAgrupamento,
        NULL AS cdOrgao,
        js.nuContrato,
      	CASE WHEN js.dtInicioContrato IS NULL THEN NULL
          ELSE TO_DATE(js.dtInicioContrato, 'YYYY-MM-DD') END AS dtInicioContrato,
      	CASE WHEN js.dtFimContrato IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimContrato, 'YYYY-MM-DD') END AS dtFimContrato,
      	CASE WHEN js.dtFimProrrogacao IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimProrrogacao, 'YYYY-MM-DD') END AS dtFimProrrogacao,
        tpserv.cdTipoServico AS cdTipoServico, js.nmTipoServico,
        cgt.cdConsignataria AS cdConsignataria, js.nuCodigoConsignataria,
        js.deServico,
        js.deObjeto,
        js.deSitePublicacao,
      
        js.nuApolice,
        js.nuRegistroSUSEP,
        js.vlTaxaAngariamento,
      
        js.Documento,

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
      
        SYSTIMESTAMP AS dtUltAlteracao
      
      -- Caminho Absoluto no Documento JSON
      -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.ContratoServico
      FROM JSON_TABLE(pContratoServico, '$[*]' COLUMNS (
      
        nuContrato                PATH '$.nuContrato',
        dtInicioContrato          PATH '$.dtInicioContrato',
        dtFimContrato             PATH '$.dtFimContrato',
        dtFimProrrogacao          PATH '$.dtFimProrrogacao',
        nmTipoServico             PATH '$.nmTipoServico',
        nuCodigoConsignataria     PATH '$.nuCodigoConsignataria',
        deServico                 PATH '$.deServico',
        deObjeto                  PATH '$.deObjeto',
        deSitePublicacao          PATH '$.deSitePublicacao',
      
        nuApolice                 PATH '$.Seguro.nuApolice',
        nuRegistroSUSEP           PATH '$.Seguro.nuRegistroSUSEP',
        vlTaxaAngariamento        PATH '$.Seguro.vlTaxaAngariamento',
      
        Documento                 PATH '$.Documento',
        
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
      INNER JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
      INNER JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      )
      SELECT * FROM ContratoServico;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
      'Contrato de Serviço ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuContrato,1,70);

      -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        r.Documento, vcdDocumentoNovo,
        pnuNivelAuditoria);

      -- Incluir Novo Contrato de Serviço da Consignação
      SELECT NVL(MAX(cdContratoServico), 0) + 1 INTO pcdContratoServico FROM epagContratoServico;

      INSERT INTO epagContratoServico (
        cdContratoServico, cdAgrupamento, cdOrgao, cdConsignataria, nuContrato,
        dtInicioContrato, dtFimContrato, dtFimProrrogacao, cdTipoServico, deServico, deObjeto,
        deSitePublicacao, nuApolice, nuRegistroSUSEP, vlTaxaAngariamento,
        cdDocumento, cdTipoPublicacao, dtPublicacao, nuPublicacao, nuPaginicial, cdMeioPublicacao,
        deOutroMeio, dtUltAlteracao
      ) VALUES (
        pcdContratoServico, r.cdAgrupamento, r.cdOrgao, r.cdConsignataria, r.nuContrato,
        r.dtInicioContrato, r.dtFimContrato, r.dtFimProrrogacao, r.cdTipoServico, r.deServico, r.deObjeto,
        r.deSitePublicacao, r.nuApolice, r.nuRegistroSUSEP, r.vlTaxaAngariamento,
        vcdDocumentoNovo, r.cdTipoPublicacao, r.dtPublicacao, r.nuPublicacao, r.nuPaginicial, r.cdMeioPublicacao,
        r.deOutroMeio, r.dtUltAlteracao
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'CONSIGNACAO CONTRATO', 'INCLUSAO',
        'Contrato de Serviço da Consignação incluídos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'CONSIGNACAO CONTRATO',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarContratoServico)', SQLERRM);
      RAISE;
  END pImportarContratoServico;

  PROCEDURE pImportarConsignatarias(
  -- ###########################################################################
  -- PROCEDURE: pImportarConsignatarias
  -- Objetivo:
  --   Importar dados das Consignataria do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão do Documento de Amparo ao Fato da Consignataria 
  --       na tabela eatoDocumento
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdConsignatariaNova   NUMBER := Null;
    vcdDocumentoNovo       NUMBER := Null;
    vnuRegistros           NUMBER := 0;
    vcdEnderecoRepresentacao NUMBER := Null;
    vcdEnderecoRepresentante NUMBER := Null;

    -- Cursor que extrai as Consignatarias do Documento JSON
    CURSOR cDados IS
      WITH
      BancoAgencia AS (
      SELECT ag.cdAgencia,
        LPAD(bco.nuBanco,3,0) AS nuBanco, ag.nuAgencia, ag.nuDvAgencia,
        bco.sgBanco, bco.nmBanco, ag.nmAgencia
      FROM ecadAgencia ag
      INNER JOIN ecadBanco bco ON bco.cdBanco = ag.cdBanco
      ),
      ConsignatariasNovas AS (
      SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao,
        parm.cdIdentificacao, js.nuRubrica, js.deRubrica,
        js.nuCodigoConsignataria, js.sgConsignataria,
        NVL2(cgt.nuCodigoConsignataria, 'S', 'N') AS flConsignatariaExiste,
        RANK() OVER (PARTITION BY js.nuCodigoConsignataria ORDER BY js.deRubrica, parm.cdParametrizacao) AS nuOrder,
        JSON_SERIALIZE(TO_CLOB(js.Consignataria) RETURNING CLOB) AS Consignataria
      FROM emigParametrizacao parm
      CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao' COLUMNS (
        nuRubrica             PATH '$.nuRubrica',
        deRubrica             PATH '$.deRubrica',
        nuCodigoConsignataria NUMBER PATH '$.Consignataria.nuCodigoConsignataria',
        sgConsignataria       PATH '$.Consignataria.sgConsignataria',
        nmTipoServico         PATH '$.TipoServico.nmTipoServico',
        Consignataria         CLOB FORMAT JSON PATH '$.Consignataria'
      )) js
      LEFT JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
      WHERE parm.sgModulo = psgModulo AND parm.sgConceito = psgConceito AND parm.flAnulado = 'N'
        AND parm.sgAgrupamento = psgAgrupamentoOrigem AND NVL(parm.sgOrgao, ' ') = NVL(psgOrgao, ' ')
        AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(pdtOperacao, 'DD/MM/YYYY HH24:MI')
        AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
        AND cgt.nuCodigoConsignataria IS NOT NULL
      ORDER BY js.nuCodigoConsignataria
      ),
      Consignataria AS (
      SELECT 
      js.nuCodigoConsignataria,
      js.nmConsignataria,
      js.sgConsignataria,
      
      js.deEmailInstitucional,
      js.deInstrucoesContato,
      NVL(js.flMargemConsignavel, 'N') AS flMargemConsignavel,
      NVL(js.flImpedida, 'N') AS flImpedida,
      
      js.nuCNPJConsignataria,
      modcst.cdModalidadeConsignataria AS cdModalidadeConsignataria, js.nmModalidadeConsignataria,
      js.nuProcessoSGPE,
      
      bcoag.cdAgencia AS cdAgencia, js.nuBanco, js.nuAgencia,
      js.nuContaCorrente,
      js.nuDVContaCorrente,
      
      js.EnderecoRepresentacao,
      
      js.nuDDD,
      js.nuTelefone,
      js.nuRamal,
      js.nuDDDFax,
      js.nuFax,
      js.nuRamalfax,
      tpRep.cdTipoRepresentacao, js.nmTipoRepresentacao,
      js.nuCNPJRepresentante,
      js.nmRepresentante,
      js.nuDDDRepresentante,
      js.nuTelefoneRepresentante,
      js.nuRamalRepresentante,
      js.nuDDDFaxRepresentante,
      js.nuFaxRepresentante,
      js.nuRamalFaxRepresentante,

      js.EnderecoRepresentante,
      
      js.Documento,

      js.nuAnoDocumento,
      tpdoc.cdTipoDocumento AS cdTipoDocumento, js.deTipoDocumento,
      CASE WHEN js.dtDocumento IS NULL THEN NULL
        ELSE TO_DATE(js.dtDocumento, 'YYYY-MM-DD') END AS dtDocumento,
      js.nuNumeroAtoLegal,
      js.deObservacao,
      meiopub.cdMeioPublicacao AS cdMeioPublicacao, js.nmMeioPublicacao,
      tppub.cdTipoPublicacao AS cdTipoPublicacao, js.nmTipoPublicacao,
    	CASE WHEN js.dtPublicacao IS NULL THEN NULL
        ELSE TO_DATE(js.dtPublicacao, 'YYYY-MM-DD') END AS dtPublicacao,
      js.nuPublicacao,
      js.nuPagInicial,
      js.deOutroMeio,
      js.nmArquivoDocumento,
      js.deCaminhoArquivoDocumento,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      SYSTIMESTAMP AS dtUltAlteracao
      
      FROM ConsignatariasNovas cst
      CROSS APPLY JSON_TABLE(cst.Consignataria, '$' COLUMNS (
        nuCodigoConsignataria     PATH '$.nuCodigoConsignataria',
        sgConsignataria           PATH '$.sgConsignataria',
        nmConsignataria           PATH '$.nmConsignataria',
      
        deEmailInstitucional      PATH '$.deEmailInstitucional',
        deInstrucoesContato       PATH '$.deInstrucoesContato',
        nuCNPJConsignataria       PATH '$.nuCNPJConsignataria',
        nmModalidadeConsignataria PATH '$.nmModalidadeConsignataria',
        nuProcessoSGPE            PATH '$.nuProcessoSGPE',
        flMargemConsignavel       PATH '$.flMargemConsignavel',
        flImpedida                PATH '$.flImpedida',
        TaxasServicos             PATH '$.TaxasServicos',
      
        sgBanco                   PATH '$.Representacao.sgBanco',
        nmBanco                   PATH '$.Representacao.nmBanco',
        nmAgencia                 PATH '$.Representacao.nmAgencia',
        nuBanco                   PATH '$.Representacao.nuBanco',
        nuAgencia                 PATH '$.Representacao.nuAgencia',
        nuDvAgencia               PATH '$.Representacao.nuDvAgencia',
        nuContaCorrente           PATH '$.Representacao.nuContaCorrente',
        nuDVContaCorrente         PATH '$.Representacao.nuDVContaCorrente',
      
        nuDDD                     PATH '$.TelefonesEndereco.nuDDD',
        nuTelefone                PATH '$.TelefonesEndereco.nuTelefone',
        nuRamal                   PATH '$.TelefonesEndereco.nuRamal',
        nuDDDFax                  PATH '$.TelefonesEndereco.nuDDDFax',
        nuFax                     PATH '$.TelefonesEndereco.nuFax',
        nuRamalfax                PATH '$.TelefonesEndereco.nuRamalfax',
      
        EnderecoRepresentacao     PATH '$.TelefonesEndereco.EnderecoRepresentante',
      
        nmTipoRepresentacao       PATH '$.Representante.nmTipoRepresentacao',
        nuCNPJRepresentante       PATH '$.Representante.nuCNPJRepresentante',
        nmRepresentante           PATH '$.Representante.nmRepresentante',
        nuDDDRepresentante        PATH '$.Representante.nuDDDRepresentante',
        nuTelefoneRepresentante   PATH '$.Representante.nuTelefoneRepresentante',
        nuRamalRepresentante      PATH '$.Representante.nuRamalRepresentante',
        nuDDDFaxRepresentante     PATH '$.Representante.nuDDDFaxRepresentante',
        nuFaxRepresentante        PATH '$.Representante.nuFaxRepresentante',
        nuRamalFaxRepresentante   PATH '$.Representante.nuRamalFaxRepresentante',

        EnderecoRepresentante     PATH '$.Representante.EnderecoRepresentante',
      
        Documento                 PATH '$.Documento',

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
      LEFT JOIN epagModalidadeConsignataria modcst ON modcst.nmModalidadeConsignataria = js.nmModalidadeConsignataria
      LEFT JOIN epagTipoRepresentacao tpRep ON tpRep.nmTipoRepresentacao = js.nmTipoRepresentacao
      LEFT JOIN BancoAgencia bcoag ON bcoag.nuBanco = js.nuBanco AND bcoag.nuAGencia = js.nuAgencia
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      WHERE cst.nuOrder = 1
      ORDER BY LPAD(js.nuCodigoConsignataria,3,0)
      )
      SELECT * FROM Consignataria;

  BEGIN

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatarias - ',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      IF r.cdTipoRepresentacao IS NULL AND r.nmTipoRepresentacao IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          'Tipo de Representação na Consignatária Inexistente ' || LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nmTipoRepresentacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nmTipoRepresentacao, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Tipo de Representação na Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdAgencia IS NULL AND r.nuAgencia IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          'Banco e Agencia da Consignatária Inexistente ' || LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nuBanco || ' ' || r.nuAgencia,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nuBanco || ' ' || r.nuAgencia, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Banco e Agencia da Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdModalidadeConsignataria IS NULL AND r.nmTipoRepresentacao IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          'Modalidade da Consignatária Inexistente ' || LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nmModalidadeConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.nmModalidadeConsignataria, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Modalidade da Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0), r.Documento, vcdDocumentoNovo, pnuNivelAuditoria);

      -- Incluir Endereço da Representação
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0), r.EnderecoRepresentacao, vcdEnderecoRepresentacao, pnuNivelAuditoria);

      -- Incluir Endereço do Representante
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0), r.EnderecoRepresentante, vcdEnderecoRepresentante, pnuNivelAuditoria);

      -- Incluir Nova Consignatária
      SELECT NVL(MAX(cdConsignataria), 0) + 1 INTO vcdConsignatariaNova FROM epagConsignataria;

      INSERT INTO epagConsignataria (
        cdConsignataria, nuCodigoConsignataria, nmConsignataria, sgConsignataria,
        deEmailInstitucional, deInstrucoesContato, flMargemConsignavel, flImpedida,
        cdAgencia, nuContaCorrente, nuDVContaCorrente,
        cdEndereco, nuDDD, nuTelefone, nuRamal, nuDDDFax, nuFax, nuRamalfax,
        cdTipoRepresentacao, nuCNPJRepresentante, nmRepresentante,
        cdEnderecoRepresentante, nuDDDRepresentante, nuTelefoneRepresentante, nuRamalRepresentante,
        nuDDDFaxRepresentante, nuFaxRepresentante, nuRamalFaxRepresentante,
        cdDocumento, cdMeioPublicacao, cdTipoPublicacao, dtPublicacao, nuPublicacao, nuPagInicial, deOutroMeio,
        nuCPFCadastrador, dtInclusao, dtUltAlteracao,
        nuCNPJConsignataria, cdModalidadeConsignataria, nuProcessoSGPE
      ) VALUES (
        vcdConsignatariaNova, r.nuCodigoConsignataria, r.nmConsignataria, r.sgConsignataria,
        r.deEmailInstitucional, r.deInstrucoesContato, r.flMargemConsignavel, r.flImpedida,
        r.cdAgencia, r.nuContaCorrente, r.nuDVContaCorrente, 
        vcdEnderecoRepresentacao, r.nuDDD, r.nuTelefone, r.nuRamal, r.nuDDDFax, r.nuFax, r.nuRamalfax,
        r.cdTipoRepresentacao, r.nuCNPJRepresentante, r.nmRepresentante,
        vcdEnderecoRepresentante, r.nuDDDRepresentante, r.nuTelefoneRepresentante, r.nuRamalRepresentante,
        r.nuDDDFaxRepresentante, r.nuFaxRepresentante, r.nuRamalFaxRepresentante,
        vcdDocumentoNovo, r.cdMeioPublicacao, r.cdTipoPublicacao, r.dtPublicacao, r.nuPublicacao, r.nuPagInicial, r.deOutroMeio,
        r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao,
        r.nuCNPJConsignataria, r.cdModalidadeConsignataria, r.nuProcessoSGPE
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, SUBSTR(LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria,1,70), 1,
        'CONSIGNATARIA', 'INCLUSAO',
        'Consignatária incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'CONSIGNATARIA',
          'Imp. Consignatárias (PKGMIG_ParametrizacaoConsignacoes.pImportarConsignatarias)', SQLERRM);
      RAISE;
  END pImportarConsignatarias;

  PROCEDURE pImportarTipoServicos(
  -- ###########################################################################
  -- PROCEDURE: pImportarTipoServico
  -- Objetivo:
  --   Importar dados dos Tipos de Serviços do Documento Rubrica JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   pcdIdentificacao      IN VARCHAR2:
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pcdIdentificacao      IN VARCHAR2,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdTipoServicoNovo    NUMBER := Null;
    vnuRegistros          NUMBER := 0;

    -- Cursor que extrai os Tipos de Serviços do Documento JSON
    CURSOR cDados IS
      WITH
      TipoServicosNovos AS (
        SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao,
          parm.cdIdentificacao, js.nmTipoServico,
          RANK() OVER (PARTITION BY js.nmTipoServico ORDER BY parm.cdParametrizacao) AS nuOrder,
          JSON_SERIALIZE(TO_CLOB(js.TipoServico) RETURNING CLOB) AS TipoServico,
          JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias
        FROM emigParametrizacao parm
        CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.TipoServico' COLUMNS (
          nmTipoServico PATH '$.nmTipoServico',
          TipoServico   CLOB FORMAT JSON PATH '$',
          Vigencias     CLOB FORMAT JSON PATH '$.Vigencias'
        )) js
        LEFT JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        WHERE parm.sgModulo = psgModulo AND parm.sgConceito = psgConceito AND parm.flAnulado = 'N'
          AND parm.sgAgrupamento = psgAgrupamentoOrigem AND NVL(parm.sgOrgao, ' ') = NVL(psgOrgao, ' ')
          AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(pdtOperacao, 'DD/MM/YYYY HH24:MI')
          AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
          AND tpserv.nmTipoServico IS NOT NULL
        ORDER BY js.nmTipoServico
      ),
      TipoServico AS (
        SELECT
          NULL AS cdTipoServico,
          NULL AS cdAgrupamento,
          tpsrv.nmTipoServico,
          SYSTIMESTAMP AS dtUltAlteracao,
          tpsrv.Vigencias
        FROM TipoServicosNovos tpsrv
        WHERE tpsrv.nuOrder = 1
        ORDER BY tpsrv.nmTipoServico
      )
      SELECT * FROM TipoServico;

  BEGIN

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Tipos de Serviços',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      -- Incluir Novo Tipo de Serviço
      SELECT NVL(MAX(cdTipoServico), 0) + 1 INTO vcdTipoServicoNovo FROM epagTipoServico;

      INSERT INTO epagTipoServico (
        cdTipoServico, cdAgrupamento, nmTipoServico, dtUltAlteracao
      ) VALUES (
        vcdTipoServicoNovo, r.cdAgrupamento, r.nmTipoServico, r.dtUltAlteracao
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, SUBSTR(r.nmTipoServico,1,70), 1,
        'TIPO SERVICO', 'INCLUSAO',
        'Tipo Serviço incluídos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'TIPO SERVICO',
          'Importação os Tipos de Serviços (PKGMIG_ParametrizacaoConsignacoes.pImportarTipoServicos)', SQLERRM);
      RAISE;
  END pImportarTipoServicos;

  PROCEDURE pImportarVigenciasTipoServico(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigenciasTipoServico
  -- Objetivo:
  --   Importar dados das Vigências do Tipo de Serviço do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão do Documento de Amparo ao Fato da Vigência da Consignação 
  --       na tabela eatoDocumento
  --     - Inclusão das Vigências da Consignação na tabela epagHistConsignacao
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
  --   pcdConsignacao        IN NUMBER:
  --   pVigenciasConsignacao IN CLOB:
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
    pcdTipoServico        IN NUMBER,
    pVigenciasTipoServico IN CLOB,
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao       VARCHAR2(70) := Null;
    vcdHistTipoServicoNova NUMBER := Null;
    vcdDocumentoNovo       NUMBER := Null;
    vnuRegistros           NUMBER := 0;

    -- Cursor que extrai as Vigências da Consignação do Documento pVigenciasConsignacao JSON
    CURSOR cDados IS
      WITH
      VigenciasTipoServico AS (
        SELECT
          NULL AS cdHistTipoServico,
          pcdTipoServico AS cdTipoServico,
          
          CASE WHEN js.dtInicioVigencia IS NULL THEN NULL
            ELSE TO_DATE(js.dtInicioVigencia, 'YYYY-DD-MM') END AS dtInicioVigencia,
          CASE WHEN js.dtFimVigencia IS NULL THEN NULL
            ELSE TO_DATE(js.dtFimVigencia, 'YYYY-DD-MM') END AS dtFimVigencia,
          js.nuOrdem,
          NULL AS cdConsigOutroTipo, js.nmConsigOutroTipo,
          
          NVL(UPPER(js.flEmprestimo), 'N') AS flEmprestimo,
          NVL(UPPER(js.flSeguro), 'N') AS flSeguro,
          NVL(UPPER(js.flCartaoCredito), 'N') AS flCartaoCredito,
          NVL(js.nuMaxParcelas, 999) AS nuMaxParcelas,
          js.vlMinConsignado,
          js.vlLimiteTAC,
          js.vlLimitePercentReservado,
          js.vlLimiteReservado,
          
          NVL(UPPER(js.flTacFinanciada), 'N') AS flTacFinanciada,
          NVL(UPPER(js.flVerificaMargemConsig), 'N') AS flVerificaMargemConsig,
          NVL(UPPER(js.flIOFFinanciado), 'N') AS flIOFFinanciado,
          NVL(UPPER(js.flExigeContrato), 'N') AS flExigeContrato,
          NVL(UPPER(js.flExigeValorLiberado), 'N') AS flExigeValorLiberado,
          NVL(UPPER(js.flExigeValorReservado), 'N') AS flExigeValorReservado,
          NVL(UPPER(js.flExigePedido), 'N') AS flExigePedido,
          NVL(UPPER(js.flExigeConsigOutroTipo), 'N') AS flExigeConsigOutroTipo,
          
          js.vlRetencao,
          js.vlTaxaRetencao,
          js.vlTaxaIRRF,
          js.vlTaxaAdministracao,
          js.vlTaxaProlabore,
          js.vlTaxaBescor,
          
          SYSTIMESTAMP AS dtUltAlteracao
          
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.TipoServico.Vigencias[*]
        FROM JSON_TABLE(pVigenciasTipoServico, '$[*]' COLUMNS (
          dtInicioVigencia         PATH '$.dtInicioVigencia',
          dtFimVigencia            PATH '$.dtFimVigencia',
          nuOrdem                  PATH '$.nuOrdem',
          nmConsigOutroTipo        PATH '$.nmConsigOutroTipo',
        
          flEmprestimo             PATH '$.Parametros.flEmprestimo',
          flSeguro                 PATH '$.Parametros.flSeguro',
          flCartaoCredito          PATH '$.Parametros.flCartaoCredito',
          nuMaxParcelas            PATH '$.Parametros.nuMaxParcelas',
          vlMinConsignado          PATH '$.Parametros.vlMinConsignado',
          vlLimiteTAC              PATH '$.Parametros.vlLimiteTAC',
          vlLimitePercentReservado PATH '$.Parametros.vlLimitePercentReservado',
          vlLimiteReservado        PATH '$.Parametros.vlLimiteReservado',
        
          flTacFinanciada          PATH '$.Parametros.flTacFinanciada',
          flVerificaMargemConsig   PATH '$.Parametros.flVerificaMargemConsig',
          flIOFFinanciado          PATH '$.Parametros.flIOFFinanciado',
          flExigeContrato          PATH '$.Parametros.flExigeContrato',
          flExigeValorLiberado     PATH '$.Parametros.flExigeValorLiberado',
          flExigeValorReservado    PATH '$.Parametros.flExigeValorReservado',
          flExigePedido            PATH '$.Parametros.flExigePedido',
          flExigeConsigOutroTipo   PATH '$.Parametros.flExigeConsigOutroTipo',
        
          vlRetencao               PATH '$.TaxaRetencao.vlRetencao',
          vlTaxaRetencao           PATH '$.TaxaRetencao.vlTaxaRetencao',
          vlTaxaIRRF               PATH '$.TaxaRetencao.vlTaxaIR',
          vlTaxaAdministracao      PATH '$.TaxaRetencao.vlTaxaAdministracao',
          vlTaxaProlabore          PATH '$.TaxaRetencao.vlTaxaProlabore',
          vlTaxaBescor             PATH '$.TaxaRetencao.vlTaxaBescor'
        )) js
        ORDER BY js.dtInicioVigencia
      )
      SELECT * FROM VigenciasTipoServico;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Tipo Serviço - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || TO_CHAR(r.dtInicioVigencia, 'YYYYMMDD'),1,70);
       
      -- Incluir Vigência do Tipo Serviço
      SELECT NVL(MAX(cdHistTipoServico), 0) + 1 INTO vcdHistTipoServicoNova FROM epagHistTipoServico;

      INSERT INTO epagHistTipoServico (
        cdHistTipoServico, cdTipoServico, dtInicioVigencia, dtFimVigencia,
        flExigeContrato, flExigeValorLiberado, flExigeValorReservado, flIOFFinanciado, dtUltAlteracao,
        flExigePedido, flExigeConsigOutroTipo, vlLimitePercentReservado, vlLimiteReservado,
        nuMaxParcelas, vlMinConsignado, vlTaxaRetencao, vlRetencao, vlTaxaAdministracao, vlTaxaProlabore,
        vlTaxaIRRF, vlLimiteTAC, flEmprestimo, flSeguro, flCartaoCredito, nuOrdem, cdConsigOutroTipo,
        flTacFinanciada, flVerificaMargemConsig, vlTaxaBescor
      ) VALUES (
        vcdHistTipoServicoNova, pcdTipoServico, r.dtInicioVigencia, r.dtFimVigencia,
        r.flExigeContrato, r.flExigeValorLiberado, r.flExigeValorReservado, r.flIOFFinanciado, r.dtUltAlteracao,
        r.flExigePedido, r.flExigeConsigOutroTipo, r.vlLimitePercentReservado, r.vlLimiteReservado,
        r.nuMaxParcelas, r.vlMinConsignado, r.vlTaxaRetencao, r.vlRetencao, r.vlTaxaAdministracao, r.vlTaxaProlabore,
        r.vlTaxaIRRF, r.vlLimiteTAC, r.flEmprestimo, r.flSeguro, r.flCartaoCredito, r.nuOrdem, r.cdConsigOutroTipo,
        r.flTacFinanciada, r.flVerificaMargemConsig, r.vlTaxaBescor
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'TIPO SERVICO VIGENCIA', 'INCLUSAO',
        'Vigência do Tipo Serviço incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'TIPO SERVICO VIGENCIA',
--          'Importação da Vigências do Tipo de Serviço (PKGMIG_ParametrizacaoConsignacoes.pImportarVigenciasTipoServico)', SQLERRM);
          'Importação do Tp Srv (PKGMIG_ParametrizacaoConsignacoes.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigenciasTipoServico;

  PROCEDURE pIncluirDocumentoAmparoFato(
  -- ###########################################################################
  -- PROCEDURE: pIncluirDocumentoAmparoFato
  -- Objetivo:
  --   Incluir Documento de Amparo ao Fato
  --     - Inclusão do Documento de Amparo ao Fato na tabela eatoDocumento
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
  --   pDocumento            IN CLOB,
  --   pcdDocumento          OUT NUMBER,
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino      IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pDocumento                 IN CLOB,
    pcdDocumento               OUT NUMBER,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  ) IS

    vDocJSON                   JSON_OBJECT_T;
    vDoc                       eatoDocumento%ROWTYPE;

  BEGIN

    pcdDocumento := NULL;

    vDocJSON := JSON_OBJECT_T.PARSE(pDocumento);
    IF vDocJSON IS NOT NULL THEN
      RETURN;
    END IF;

    vDoc.nuAnoDocumento             := vDocJSON.GET_NUMBER('nuAnoDocumento');
    vDoc.dtDocumento                := TO_DATE(vDocJSON.GET_STRING('dtDocumento'), 'YYYY-MM-DD');
    vDoc.deObservacao               := vDocJSON.GET_STRING('deObservacao');
    vDoc.nuNumeroAtoLegal           := vDocJSON.GET_STRING('nuNumeroAtoLegal');
    vDoc.nmArquivoDocumento         := vDocJSON.GET_STRING('nmArquivoDocumento');
    vDoc.deCaminhoArquivoDocumento  := vDocJSON.GET_STRING('deCaminhoArquivoDocumento');

    SELECT MAX(cdTipoDocumento) INTO vDoc.cdTipoDocumento 
    FROM eatoTipoDocumento WHERE deTipoDocumento = vDocJSON.GET_STRING('deTipoDocumento');

    -- Incluir Novo Documento se as informações não forem nulas
    IF vDoc.nuAnoDocumento            IS NOT NULL OR
       vDoc.cdTipoDocumento           IS NOT NULL OR
       vDoc.dtDocumento               IS NOT NULL OR
       vDoc.deObservacao              IS NOT NULL OR
       vDoc.nuNumeroAtoLegal          IS NOT NULL OR
       vDoc.nmArquivoDocumento        IS NOT NULL OR
       vDoc.deCaminhoArquivoDocumento IS NOT NULL THEN

      SELECT NVL(MAX(cdDocumento), 0) + 1 INTO vDoc.cdDocumento FROM eatoDocumento;

      INSERT INTO eatoDocumento VALUES vDoc;

      pcdDocumento := vDoc.cdDocumento;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'DOCUMENTO AMPARO FATO', 'INCLUSAO',
        'Documentos de Amparo ao Fato incluidos com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    END IF;  

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'DOCUMENTO AMPARO FATO',
          'Documento de Amparo ao Fato (PKGMIG_ParametrizacaoConsignacoes.pIncluirDocumentoAmparoFato)', SQLERRM);
      RAISE;
  END pIncluirDocumentoAmparoFato;

  PROCEDURE pIncluirEndereco(
  -- ###########################################################################
  -- PROCEDURE: pIncluirEndereco
  -- Objetivo:
  --   Incluir endereço
  --     - Inclusão do Endereço na tabela ecadEndereco
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
  --   pEndereco             IN CLOB,
  --   pcdEndereco           OUT NUMBER,
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino      IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pEndereco                  IN CLOB,
    pcdEndereco                OUT NUMBER,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  ) IS

    cnuCPFCadastrador          CONSTANT VARCHAR2(11) := '11111111111';
    vdtInclusao                DATE := SYSDATE;
    vEndJSON                   JSON_OBJECT_T;
    vEnd                       ecadEndereco%ROWTYPE;
    vBairro                    ecadBairro%ROWTYPE;
    vLocalidade                ecadLocalidade%ROWTYPE;

  BEGIN

    pcdEndereco := NULL;

    vEndJSON := JSON_OBJECT_T.PARSE(pEndereco);
    IF vEndJSON IS NOT NULL THEN
      RETURN;
    END IF;

    SELECT MAX(cdLocalidade) INTO vEnd.cdLocalidade FROM ecadLocalidade
    WHERE UPPER(sgEstado) = UPPER(vEndJSON.GET_STRING('sgEstado'))
      AND UPPER(nmLocalidade) = UPPER(vEndJSON.GET_STRING('nmLocalidade'))
      AND flInconsistente = 'N';

    IF vEnd.cdLocalidade IS NULL THEN
      vLocalidade.sgEstado         := vEndJSON.GET_STRING('sgEstado');
      vLocalidade.nmLocalidade     := vEndJSON.GET_STRING('nmLocalidade');
      vLocalidade.nuCEP            := vEndJSON.GET_STRING('nuCEP');
      vLocalidade.inTipo           := CASE vEndJSON.GET_STRING('inTipo')
                                        WHEN 'MUNICIPIO' THEN 'M'
                                        WHEN 'DISTRITO'  THEN 'D'
                                        WHEN 'POVOADO'   THEN 'P' 
                                        ELSE'M'
                                      END;
      vLocalidade.flInconsistente  := 'S';
      vLocalidade.flAnulado        := 'N';
      vLocalidade.dtAnulacao       := NULL;
      vLocalidade.nuCPFCadastrador := cnuCPFCadastrador;
      vLocalidade.dtInclusao       := vdtInclusao;
      vLocalidade.dtUltAlteracao   := SYSTIMESTAMP;

      SELECT NVL(MAX(cdLocalidade),0) + 1 INTO vLocalidade.cdLocalidade FROM ecadLocalidade;

      INSERT INTO ecadLocalidade VALUES vLocalidade;

      vEnd.cdLocalidade := vLocalidade.cdLocalidade;
      vEnd.flInconsistente  := 'S';
    END IF;

    SELECT MAX(cdBairro) INTO vEnd.cdBairro FROM ecadBairro
    WHERE cdLocalidade = vEnd.cdLocalidade
      AND nmBairro = vEndJSON.GET_STRING('nmBairro')
      AND flInconsistente = 'N';

    IF vEnd.cdBairro IS NULL THEN
      vBairro.cdLocalidade     := vEnd.cdLocalidade;
      vBairro.nmBairro         := vEndJSON.GET_STRING('nmBairro');
      vBairro.flInconsistente  := 'S';
      vBairro.cdReferencia     := NULL;
      vBairro.flAnulado        := 'N';
      vBairro.dtAnulado       := NULL;
      vBairro.nuCPFCadastrador := cnuCPFCadastrador;
      vBairro.dtInclusao       := vdtInclusao;
      vBairro.dtUltAlteracao   := SYSTIMESTAMP;

      SELECT NVL(MAX(cdBairro),0) + 1 INTO vBairro.cdBairro FROM ecadBairro;

      INSERT INTO ecadBairro VALUES vBairro;

      vEnd.cdBairro := vBairro.cdBairro;
      vEnd.flInconsistente  := 'S';
    END IF;

    SELECT MAX(cdTipoLogradouro) INTO vEnd.cdTipoLogradouro
    FROM ecadTipoLogradouro WHERE nmTipoLogradouro = vEndJSON.GET_STRING('nmTipoLogradouro');

    vEnd.nuCEP               := vEndJSON.GET_STRING('nuCEP');
    vEnd.nmLogradouro        := vEndJSON.GET_STRING('nmLogradouro');
    vEnd.deComplLogradouro   := vEndJSON.GET_STRING('deComplLogradouro');
    vEnd.nuNumero            := vEndJSON.GET_STRING('nuNumero');
    vEnd.deComplemento       := vEndJSON.GET_STRING('deComplemento');
    vEnd.nmUnidade           := vEndJSON.GET_STRING('nmUnidade');
--    vEnd.flInconsistente     := NVL(vEndJSON.GET_STRING('flInconsistente'), 'N');

    vEnd.nuCaixaPostal       := vEndJSON.GET_STRING('nuCaixaPostal');
    vEnd.flTipoLogradouro    := vEndJSON.GET_STRING('flTipoLogradouro');
    vEnd.flEnderecoExterior  := NVL(vEndJSON.GET_STRING('flEnderecoExterior'), 'N');

    vEnd.dtInicio            := vdtInclusao;
    vEnd.nuCPFCadastrador    := cnuCPFCadastrador;
    vEnd.dtInclusao          := vdtInclusao;
    vEnd.dtUltAlteracao      := SYSTIMESTAMP;

    -- Incluir Endereco
    IF vEnd.nuCEP        IS NOT NULL OR
       vEnd.cdLocalidade IS NOT NULL OR
       vEnd.cdBairro     IS NOT NULL THEN

      SELECT NVL(MAX(cdEndereco), 0) + 1 INTO vEnd.cdEndereco FROM ecadEndereco;

      INSERT INTO ecadEndereco VALUES vEnd;

      pcdEndereco := vEnd.cdEndereco;

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'ENDERECO', 'INCLUSAO',
        'Endereco incluidos com sucesso',
        cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    END IF;  

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'ENDERECO',
          'Endereço (PKGMIG_ParametrizacaoConsignacoes.pIncluirEndereco)', SQLERRM);
      RAISE;
  END pIncluirEndereco;

END PKGMIG_ParametrizacaoConsignacoes;
/
