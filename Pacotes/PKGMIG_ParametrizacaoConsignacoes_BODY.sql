-- Corpo do Pacote de Importação das Parametrizações de Consignações
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoConsignacoes AS

  FUNCTION fnExportar(
  -- ###########################################################################
  -- FUNCTION: pExportar
  -- Objetivo:
  --   Exportar as Parametrizações das Consignações para a Configuração Padrão JSON,
  --     realizando:
  --     - Gera o Documento JSON Consignacao 
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
  ) RETURN tpemigParametrizacaoTabela PIPELINED IS
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

--    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
--    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
--    vnuRegistros        NUMBER       := 0;
--    vtxResumo           VARCHAR2(4000) := NULL;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas
    vRefCursor SYS_REFCURSOR;

    BEGIN

      vdtOperacao := LOCALTIMESTAMP;

      IF psgAgrupamento IS NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
          'Agrupamento não Informado.');
      ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamento) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
          'Agrupamento Informado não Cadastrado.: "' || SUBSTR(psgAgrupamento,1,15) || '".');
      END IF;

      IF pcdIdentificacao IS NULL THEN
        vtxMensagem := 'Inicio da Exportação das Parametrizações das Consginações ';
      ELSE
        vtxMensagem := 'Inicio da Exportação da Parametrização da Consignação "' || pcdIdentificacao || '" ';
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
	    vRefCursor := fnCursorConsignacao(psgAgrupamento, pcdIdentificacao);

      -- Loop principal de processamento
	    LOOP
        FETCH vRefCursor INTO rsgAgrupamento, rcdIdentificacao, rjsConteudo;
        EXIT WHEN vRefCursor%NOTFOUND;

        PKGMIG_ParametrizacaoLog.pAlertar('Exportação da Consignação ' || rcdIdentificacao,
          cAUDITORIA_DETALHADO, pnuNivelAuditoria);

        PIPE ROW (tpemigParametrizacao(
          rsgAgrupamento, vsgOrgao, csgModulo, csgConceito, rcdIdentificacao, rjsConteudo
        ));
      END LOOP;
      RETURN;

      CLOSE vRefCursor;

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, ctpOperacao, vdtOperacao,  
          csgModulo, csgConceito, vcdIdentificacao, 'CONSIGNACOES',
          'Exportação de Consignação (PKGMIG_ParametrizacaoConsignacoes.pExportar)', SQLERRM);
      ROLLBACK;
      RAISE;
  END fnExportar;

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
    csgModulo              CONSTANT CHAR(3)      := 'PAG';
    csgConceito            CONSTANT VARCHAR2(20) := 'RUBRICA';
    ctpOperacao            CONSTANT VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao            TIMESTAMP             := LOCALTIMESTAMP;
    vcdIdentificacao       VARCHAR2(50)          := Null;

    vtxMensagem            VARCHAR2(100) := NULL;
    vContador              NUMBER       := 0;
    cCommitLote            CONSTANT NUMBER := 1000;
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
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao
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
        WHERE parm.sgModulo = csgModulo AND parm.sgConceito = csgConceito AND parm.flAnulado = 'N'
          AND parm.sgAgrupamento = psgAgrupamentoOrigem AND NVL(parm.sgOrgao, ' ') = NVL(vsgOrgao, ' ')
          AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI')
          AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
        ORDER BY parm.cdIdentificacao
      )
      SELECT * FROM Consignacoes;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;

    IF psgAgrupamentoOrigem IS NULL THEN
      RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
        'Agrupamento Orgiem não Informado.');
    ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamentoOrigem) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Origem Informado não Cadastrado.: "' || SUBSTR(psgAgrupamentoOrigem,1,50) || '".');
    END IF;

    IF psgAgrupamentoDestino IS NULL THEN
      RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
        'Agrupamento Destino não Informado.');
    ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamentoDestino) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Destino Informado não Cadastrado.: "' || SUBSTR(psgAgrupamentoDestino,1,50) || '".');
    END IF;

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = csgModulo AND sgConceito = csgConceito
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

    -- Incluir Consignatárias
    pImportarConsignatarias(psgAgrupamentoOrigem, psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
      csgModulo, csgConceito, pcdIdentificacao, pnuNivelAuditoria);

    -- Incluir Tipos de Serviços
    pImportarTipoServicos(psgAgrupamentoOrigem, psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
      csgModulo, csgConceito, pcdIdentificacao, pnuNivelAuditoria);

    vnuInseridos   := 0;
    vnuAtualizados := 0;
    vContador      := 0;

    -- Loop principal de processamento para Incluir as Consignações
    FOR r IN cDados LOOP
  
      vsgOrgao := r.sgOrgao;
      vcdIdentificacao := r.cdIdentificacao;

      IF r.cdRubricaAgrupamento IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Consignação - ' || vcdIdentificacao ||
          'Rubrica da Consignação Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao, 
          csgModulo, csgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO', 'INCONSISTENTE',
          'Rubrica da Consignação Inexistente no Agrupamento',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.flConsignacaoExiste = 'S' THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
          'Consignação - ' || vcdIdentificacao || ' ' ||
          'Rubrica da Consignação já cadastrada',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao, 
          csgModulo, csgConceito, vcdIdentificacao, 0,
          'CONSIGNACAO', 'INCLUSAO',
          'Rubrica da Consignação já cadastrada ' || r.nuRubrica,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdRubricaAgrupamento IS NOT NULL AND r.cdIdentificacao = r.nuRubrica AND
         r.flConsignacaoExiste = 'N' THEN

        -- Incluir Consignação
        vContador := vContador + 1;
        vnuInseridos := vnuInseridos + 1;
        pImportarConsignacao(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
          csgModulo, csgConceito, vcdIdentificacao, r.cdRubricaAgrupamento, r.Consignacao, pnuNivelAuditoria);

        IF MOD(vContador, cCommitLote) = 0 THEN
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

    PKGMIG_ParametrizacaoLog.pGerarResumo(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
      csgModulo, csgConceito, vdtTermino, vnuTempoExecucao, pnuNivelAuditoria);

    -- Registro de Resumo da Importação das Consignações
    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
      csgModulo, csgConceito, NULL, NULL,
      'CONSIGNACAO', 'RESUMO', 'Importação das Parametrizações das Consignações do ' || vtxResumo, 
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação das Consignações
    PKGMIG_ParametrizacaoLog.pAtualizarSequence(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,
      csgModulo, csgConceito, vListaTabelas, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pAlertar('Termino da Importação das Parametrizações das Consignações do ' ||
      vtxResumo, cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, vsgOrgao, ctpOperacao, vdtOperacao,  
          csgModulo, csgConceito, vcdIdentificacao, 'CONSIGNACAO',
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
        cgt.cdConsignataria AS cdConsignataria, js.nuCodigoConsignataria, js.sgConsignataria,
        rubagrp.cdRubrica AS cdRubrica, js.nuRubrica, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubricaAgrupamento,
        tpserv.cdTipoServico AS cdTipoServico, js.nmTipoServico,
        NULL AS cdContratoServico, js.nuContrato,
        CASE WHEN js.dtInicioConcessao IS NULL THEN NULL
          ELSE TO_DATE(js.dtInicioConcessao, 'YYYY-MM-DD') END AS dtInicioConcessao,
        CASE WHEN js.dtFimConcessao IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimConcessao, 'YYYY-MM-DD') END AS dtFimConcessao,
        NVL(js.flGeridaTerceitos, 'S') AS flGeridaSCConsig, -- DEFAULT S
        NVL(js.flRepasse, 'S') AS flRepasse, -- DEFAULT S
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
        LEFT JOIN epagConsignataria cgt ON cgt.nuCodigoConsignataria = js.nuCodigoConsignataria
        LEFT JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        LEFT JOIN ConsignacoesExistentes csgexiste ON csgexiste.nuRubrica = LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
        --WHERE csgexiste.nuRubrica IS NOT NULL
      )
      SELECT * FROM Consignacao;

    BEGIN

      vcdIdentificacao := pcdIdentificacao;
  
      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignação - ' ||
        vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
  	
      IF psgAgrupamentoDestino IS NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_PARAMETRO_OBRIGATORIO,
          'Agrupamento não Informado.');
      ELSIF PKGMIG_ParametrizacaoLog.fnValidarAgrupamento(psgAgrupamentoDestino) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(PKGMIG_ParametrizacaoLog.cERRO_AGRUPAMENTO_INVALIDO,
          'Agrupamento Informado não Cadastrado.: "' || SUBSTR(psgAgrupamentoDestino,1,50) || '".');
      END IF;

      -- Loop principal de processamento para Incluir as Consignações não Existentes
      FOR r IN cDados LOOP
  
        IF vcdIdentificacao != r.nuRubrica THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
            'Consignação - ' || vcdIdentificacao || ' ' ||
            'Rubrica da Consignação diferente da Rubrica do Agrupamento ' || r.nuRubrica,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCONSISTENTE',
            'Rubrica da Consignação diferente da Rubrica do Agrupamento ' || r.nuRubrica,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdConsignataria IS NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
            'Consignação - ' || vcdIdentificacao || ' ' ||
            'Consignatária Inexistente ' || r.nuCodigoConsignataria || ' ' || r.sgConsignataria,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCONSISTENTE',
            'Consignatária Inexistente ' || r.nuCodigoConsignataria || ' ' || r.sgConsignataria,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF r.cdTipoServico IS NULL AND r.nmTipoServico IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
            'Consignação - ' || vcdIdentificacao || ' ' ||
            'Tipo de Serviço Inexistente ' || r.nmTipoServico,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCONSISTENTE',
            'Tipo de Serviço Inexistente ' || r.nmTipoServico,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;

        IF vcdIdentificacao = r.nuRubrica AND r.cdConsignataria IS NOT NULL AND
           (r.cdTipoServico IS NOT NULL OR r.nmTipoServico IS NULL) THEN

          -- Importar Contrato de Serviço
          vcdContratoServicoNovo := NULL;
          IF r.nuContrato IS NOT NULL THEN
            pImportarContratoServico(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
              psgModulo, psgConceito, vcdIdentificacao, r.ContratoServico, vcdContratoServicoNovo, pnuNivelAuditoria);
          END IF;
  
      	  -- Inserir na tabela epagConsignacao
      	  SELECT NVL(MAX(cdConsignacao), 0) + 1 INTO vcdConsignacaoNova FROM epagConsignacao;

          INSERT INTO epagConsignacao (
            cdConsignacao, cdConsignataria, cdRubrica, cdTipoServico, cdContratoServico,
            dtInicioConcessao, dtFimConcessao, dtInclusao, dtUltAlteracao, flGeridaSCConsig, flRepasse
          ) VALUES (
            vcdConsignacaoNova, r.cdConsignataria, r.cdRubrica, r.cdTipoServico, vcdContratoServicoNovo,
            r.dtInicioConcessao, r.dtFimConcessao, r.dtInclusao, r.dtUltAlteracao, r.flGeridaSCConsig, r.flRepasse
          );

          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCLUSAO',
            'Consignação incluída com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      
          -- Importar Vigencias da Consignação
          pImportarVigenciasConsignacao(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, vcdConsignacaoNova, r.Vigencias, pnuNivelAuditoria);

        END IF;

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
    vnuRegistros           NUMBER := 0;

    vcdDocumento           NUMBER := Null;
    vcdTipoPublicacao      NUMBER := Null;
    vdtPublicacao          DATE   := Null;
    vnuPublicacao          NUMBER := Null;
    vnuPaginicial          NUMBER := Null;
    vcdMeioPublicacao      NUMBER := Null;
    vdeOutroMeio           VARCHAR2(40) := Null;

    -- Cursor que extrai as Vigências da Consignação do Documento pVigenciasConsignacao JSON
    CURSOR cDados IS
      WITH
      Vigencia AS (
      SELECT
        pcdConsignacao AS cdConsignacao,
      
      	CASE WHEN js.dtInicioVigencia IS NULL THEN NULL
          ELSE TO_DATE(js.dtInicioVigencia, 'YYYY-DD-MM') END AS dtInicioVigencia,
      	CASE WHEN js.dtFimVigencia IS NULL THEN NULL
          ELSE TO_DATE(js.dtFimVigencia, 'YYYY-DD-MM') END AS dtFimVigencia,
      
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

        '11111111111' AS nuCPFCadastrador,
        TRUNC(SYSDATE) AS dtInclusao,
        SYSTIMESTAMP AS dtUltAlteracao,
      
        JSON_SERIALIZE(TO_CLOB(js.Documento) RETURNING CLOB) AS Documento

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
      
        Documento                 CLOB FORMAT JSON PATH '$.Documento'
      )) js
      )
      SELECT * FROM Vigencia;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, vcdIdentificacao, 1,
      'CONSIGNACAO VIGENCIA', 'JSON',
      SUBSTR(pVigenciasConsignacao,1,4000),
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
        TO_CHAR(r.dtInicioVigencia, 'YYYYMMDD'),1,70);
       
      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignação - ' ||
        'Vigência ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, 'CONSIGNACAO VIGENCIA', vcdIdentificacao,
        r.Documento, vcdDocumento, vcdTipoPublicacao,
        vdtPublicacao, vnuPublicacao, vnuPaginicial,
        vcdMeioPublicacao, vdeOutroMeio,
        pnuNivelAuditoria);

      -- Incluir Nova Vigência da Consignação
      SELECT NVL(MAX(cdHistConsignacao), 0) + 1 INTO vcdHistConsignacaoNova FROM epagHistConsignacao;

      INSERT INTO epagHistConsignacao (
        cdHistConsignacao, cdConsignacao, dtInicioVigencia, dtFimVigencia,
        vlMinConsignado, flLancamentoManual, flDescontoParcial, flFormulaCalculo, vlMinDescontoFolha,
        nuMaxParcelas, flMaisDeUmaOcorrencia, vlTaxaRetencao, vlRetencao, vlTaxaIR, vlTaxaAdministracao,
        vlTaxaProlabore, flDescontoEventual,
        cdDocumento, cdTipoPublicacao, dtPublicacao, nuPublicacao, nuPagInicial, cdMeioPublicacao, deOutroMeio,
        nuCPFCadastrador, dtInclusao, dtUltAlteracao, vlTaxaBescor
      ) VALUES (
        vcdHistConsignacaoNova, r.cdConsignacao, r.dtInicioVigencia, r.dtFimVigencia,
        r.vlMinConsignado, r.flLancamentoManual, r.flDescontoParcial, r.flFormulaCalculo, r.vlMinDescontoFolha,
        r.nuMaxParcelas, r.flMaisDeUmaOcorrencia, r.vlTaxaRetencao, r.vlRetencao, r.vlTaxaIR, r.vlTaxaAdministracao,
        r.vlTaxaProlabore, r.flDescontoEventual,
        vcdDocumento, vcdTipoPublicacao,  vdtPublicacao, vnuPublicacao, vnuPagInicial, vcdMeioPublicacao, vdeOutroMeio,
        r.nuCPFCadastrador, r.dtInclusao, r.dtUltAlteracao, r.vlTaxaBescor
      );

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
    vnuRegistros           NUMBER := 0;

    vContratoServicoJSON   JSON_OBJECT_T;
    vContratoServico       epagContratoServico%ROWTYPE;
    vnmTipoServico         VARCHAR2(70) := Null;
    vnuCodigoConsignataria VARCHAR2(70) := Null;
    vDocumento             CLOB;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
      'Contrato de Serviço ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, vcdIdentificacao, 1,
      'CONSIGNACAO CONTRATO', 'JSON',
      pContratoServico,
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    pcdContratoServico := NULL;

    vContratoServicoJSON := JSON_OBJECT_T.PARSE(pContratoServico);
    IF vContratoServicoJSON IS NOT NULL THEN

      vContratoServico.nuContrato       := vContratoServicoJSON.GET_NUMBER('nuContrato');
      vContratoServico.dtInicioContrato := TO_DATE(vContratoServicoJSON.GET_STRING('dtInicioContrato'), 'YYYY-MM-DD');
  
      vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || vContratoServico.nuContrato,1,70);
  
      vnuCodigoConsignataria := vContratoServicoJSON.GET_STRING('nuCodigoConsignataria');
      SELECT MAX(cdConsignataria) INTO vContratoServico.cdConsignataria
      FROM epagConsignataria cgt WHERE cgt.nuCodigoConsignataria = vnuCodigoConsignataria;

      IF vContratoServico.cdConsignataria IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Código da Consignatária do Contrato de Serviço na Consignação Inexistente ' || vcdIdentificacao || ' ' || vnuCodigoConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || vnuCodigoConsignataria, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Código da Consignatária do Contrato de Serviço na Consignação Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      vnmTipoServico := vContratoServicoJSON.GET_STRING('nmTipoServico');
      SELECT MAX(cdTipoServico) INTO vContratoServico.cdTipoServico  
      FROM epagTipoServico tpserv WHERE tpserv.nmTipoServico = vnmTipoServico;

      IF vContratoServico.cdTipoServico IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Tipo do Serviço do Contrato de Serviço na Consignação Inexistente ' || vcdIdentificacao || ' ' || vnmTipoServico,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || vnmTipoServico, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Tipo do Serviço do Contrato de Serviço na Consignação Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      vContratoServico.dtFimContrato      := TO_DATE(vContratoServicoJSON.GET_STRING('dtFimContrato'), 'YYYY-MM-DD');
      vContratoServico.dtFimProrrogacao   := TO_DATE(vContratoServicoJSON.GET_STRING('dtFimProrrogacao'), 'YYYY-MM-DD');
      vContratoServico.deServico          := vContratoServicoJSON.GET_STRING('deServico');
      vContratoServico.deObjeto           := vContratoServicoJSON.GET_STRING('deObjeto');
      vContratoServico.deSitePublicacao   := vContratoServicoJSON.GET_STRING('deSitePublicacao');
      vContratoServico.nuApolice          := vContratoServicoJSON.GET_OBJECT('Seguro').GET_STRING('nuApolice');
      vContratoServico.nuRegistroSUSEP    := vContratoServicoJSON.GET_OBJECT('Seguro').GET_STRING('nuRegistroSUSEP');
      vContratoServico.vlTaxaAngariamento := vContratoServicoJSON.GET_OBJECT('Seguro').GET_NUMBER('vlTaxaAngariamento');

      vContratoServico.cdAgrupamento := NULL;
      SELECT MAX(cdAgrupamento) INTO vContratoServico.cdAgrupamento
      FROM ecadAgrupamento WHERE sgAgrupamento = psgAgrupamentoDestino;

      IF vContratoServico.cdAgrupamento IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Agrupamento do Contrato de Serviço na Consignação Inexistente ' || vcdIdentificacao || ' ' || psgAgrupamentoDestino,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || psgAgrupamentoDestino, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Agrupamento do Contrato de Serviço na Consignação Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      SELECT MAX(cdOrgao) INTO vContratoServico.cdOrgao
      FROM ecadHistOrgao WHERE sgOrgao = psgOrgao;

      IF vContratoServico.cdOrgao IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Órgão do Contrato de Serviço na Consignação Inexistente ' || vcdIdentificacao || ' ' || psgOrgao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || psgOrgao, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Órgão do Contrato de Serviço na Consignação Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF vContratoServico.nuContrato IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Número do Contrato de Serviço na Consignação é obrigatório ' || vcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Número do Contrato de Serviço na Consignação é obrigatório',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF vContratoServico.deServico IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Descrição do Serviço no Contrato de Serviço na Consignação é obrigatório ' || vcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Número do Contrato de Serviço na Consignação é obrigatório',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF vContratoServico.dtInicioContrato IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Data de Início do Contrato de Serviço na Consignação é obrigatório ' || vcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Data de Início do Contrato de Serviço na Consignação é obrigatório',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF vContratoServico.dtFimContrato IS NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Contrato de Serviço - ' ||
          'Data de Fim do Contrato de Serviço na Consignação é obrigatório ' || vcdIdentificacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO CONTRATO', 'INCONSISTENTE',
          'Data de Fim do Contrato de Serviço na Consignação é obrigatório',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Incluir Contrato de Serviço se as informações não forem nulas
      IF vContratoServico.nuContrato       IS NOT NULL AND
         vContratoServico.cdConsignataria  IS NOT NULL AND
         vContratoServico.cdTipoServico    IS NOT NULL AND
         vContratoServico.deServico        IS NOT NULL AND
         vContratoServico.cdAgrupamento    IS NOT NULL AND
         vContratoServico.cdOrgao          IS NOT NULL AND
         vContratoServico.dtInicioContrato IS NOT NULL AND
         vContratoServico.dtFimContrato    IS NOT NULL THEN

        -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
        vDocumento := vContratoServicoJSON.GET_OBJECT('Documento').STRINGIFY;
  
        pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, 'CONSIGNACAO CONTRATO', vcdIdentificacao,
          vDocumento, vContratoServico.cdDocumento, vContratoServico.cdTipoPublicacao,
          vContratoServico.dtPublicacao, vContratoServico.nuPublicacao, vContratoServico.nuPaginicial,
          vContratoServico.cdMeioPublicacao, vContratoServico.deOutroMeio,
          pnuNivelAuditoria);

        SELECT NVL(MAX(cdContratoServico), 0) + 1 INTO vContratoServico.cdContratoServico FROM epagContratoServico;

        vContratoServico.dtUltAlteracao := SYSTIMESTAMP;

        INSERT INTO epagContratoServico VALUES vContratoServico;
  
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'CONSIGNACAO CONTRATO', 'INCLUSAO',
          'Contrato de Serviço da Consignação incluídos com sucesso',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;
    END IF;

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
    vnuRegistros           NUMBER := 0;
    vdtExportacao          TIMESTAMP := LOCALTIMESTAMP;

    vcdDocumento           NUMBER := Null;
    vcdTipoPublicacao      NUMBER := Null;
    vdtPublicacao          DATE   := Null;
    vnuPublicacao          NUMBER := Null;
    vnuPaginicial          NUMBER := Null;
    vcdMeioPublicacao      NUMBER := Null;
    vdeOutroMeio           VARCHAR2(40) := Null;

    vcdEnderecoRepresentacao NUMBER := Null;
    vcdEnderecoRepresentante NUMBER := Null;

    cnuCPFCadastrador      CONSTANT VARCHAR2(11) := '11111111111';
    vdtInclusao            DATE := TRUNC(SYSDATE);
    vdtUltAlteracao        TIMESTAMP := SYSTIMESTAMP;

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
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao
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
        AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI')
        AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
        AND cgt.nuCodigoConsignataria IS NULL
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
      
      JSON_SERIALIZE(TO_CLOB(js.Documento) RETURNING CLOB) AS Documento
      
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.Consignataria
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
      
        Documento                 CLOB FORMAT JSON PATH '$.Documento'
      )) js
      LEFT JOIN epagModalidadeConsignataria modcst ON modcst.nmModalidadeConsignataria = js.nmModalidadeConsignataria
      LEFT JOIN epagTipoRepresentacao tpRep ON tpRep.nmTipoRepresentacao = js.nmTipoRepresentacao
      LEFT JOIN BancoAgencia bcoag ON bcoag.nuBanco = js.nuBanco AND bcoag.nuAGencia = js.nuAgencia
      WHERE cst.nuOrder = 1
      ORDER BY LPAD(js.nuCodigoConsignataria,3,0)
      )
      SELECT * FROM Consignataria;

  BEGIN

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatarias',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = psgModulo AND sgConceito = psgConceito
      AND sgAgrupamento = psgAgrupamentoOrigem AND sgOrgao IS NULL
      AND (cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
        'Consignataria - ' || LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria,
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      IF r.cdTipoRepresentacao IS NULL AND r.nmTipoRepresentacao IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria || ' ' ||
          'Tipo de Representação na Consignatária Inexistente ' || r.nmTipoRepresentacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Tipo de Representação na Consignatária Inexistente ' || r.nmTipoRepresentacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdAgencia IS NULL AND r.nuAgencia IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria || ' ' ||
          'Banco e Agencia da Consignatária Inexistente ' || r.nuBanco || ' ' || r.nuAgencia,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Banco e Agencia da Consignatária Inexistente ' || r.nuBanco || ' ' || r.nuAgencia,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdModalidadeConsignataria IS NULL AND r.nmModalidadeConsignataria IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Consignatária - ' ||
          LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria || ' ' ||
          'Modalidade da Consignatária Inexistente ' || r.nmModalidadeConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, LPAD(r.nuCodigoConsignataria,3,0) || ' ' || r.sgConsignataria, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Modalidade da Consignatária Inexistente ' || r.nmModalidadeConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Incluir Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, 'CONSIGNATARIA', LPAD(r.nuCodigoConsignataria,3,0),
        r.Documento, vcdDocumento, vcdTipoPublicacao,
        vdtPublicacao, vnuPublicacao, vnuPaginicial,
        vcdMeioPublicacao, vdeOutroMeio,
        pnuNivelAuditoria);

      -- Incluir Endereço da Representação
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, 'CONSIGNATARIA', LPAD(r.nuCodigoConsignataria,3,0),
        r.EnderecoRepresentacao, vcdEnderecoRepresentacao, pnuNivelAuditoria);

      -- Incluir Endereço do Representante
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, 'CONSIGNATARIA', LPAD(r.nuCodigoConsignataria,3,0),
        r.EnderecoRepresentante, vcdEnderecoRepresentante, pnuNivelAuditoria);

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
        vcdDocumento, vcdMeioPublicacao, vcdTipoPublicacao, vdtPublicacao, vnuPublicacao, vnuPagInicial, vdeOutroMeio,
        cnuCPFCadastrador, vdtInclusao, vdtUltAlteracao,
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
          psgModulo, psgConceito, pcdIdentificacao, 'CONSIGNATARIA',
          'Imp. Consignatárias (PKGMIG_ParametrizacaoConsignacoes.pImportarConsignatarias)', SQLERRM);
      RAISE;
  END pImportarConsignatarias;

  PROCEDURE pImportarTipoServicos(
  -- ###########################################################################
  -- PROCEDURE: pImportarTipoServicos
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
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;
    vdtExportacao         TIMESTAMP := LOCALTIMESTAMP;
    vcdAgrupamento        NUMBER := 0;

    vcdTipoServico        NUMBER := Null;
    vdtUltAlteracao       TIMESTAMP := SYSTIMESTAMP;

    -- Cursor que extrai os Tipos de Serviços do Documento JSON
    CURSOR cDados IS
      WITH
      TipoServicosNovos AS (
        SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao,
          parm.cdIdentificacao, js.nmTipoServico,
          RANK() OVER (PARTITION BY js.nmTipoServico ORDER BY parm.cdParametrizacao) AS nuOrder,
          JSON_SERIALIZE(TO_CLOB(js.TipoServico) RETURNING CLOB) AS TipoServico,
          JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias
        -- Caminho Absoluto no Documento JSON
        -- $.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.TipoServico
        FROM emigParametrizacao parm
        CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.TipoServico' COLUMNS (
          nmTipoServico PATH '$.nmTipoServico',
          TipoServico   CLOB FORMAT JSON PATH '$',
          Vigencias     CLOB FORMAT JSON PATH '$.Vigencias'
        )) js
        LEFT JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        WHERE parm.sgModulo = psgModulo AND parm.sgConceito = psgConceito AND parm.flAnulado = 'N'
          AND parm.sgAgrupamento = psgAgrupamentoOrigem AND NVL(parm.sgOrgao, ' ') = NVL(psgOrgao, ' ')
          AND TO_CHAR(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI')
          AND (parm.cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL)
          AND tpserv.nmTipoServico IS NULL
        ORDER BY js.nmTipoServico
      ),
      TipoServico AS (
        SELECT
          tpsrv.nmTipoServico,
          tpsrv.Vigencias
        FROM TipoServicosNovos tpsrv
        WHERE tpsrv.nuOrder = 1
        ORDER BY tpsrv.nmTipoServico
      )
      SELECT * FROM TipoServico;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Tipos de Serviços',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    SELECT MAX(dtExportacao) INTO vdtExportacao FROM emigParametrizacao
    WHERE sgModulo = psgModulo AND sgConceito = psgConceito
      AND sgAgrupamento = psgAgrupamentoOrigem AND sgOrgao IS NULL
      AND (cdIdentificacao = pcdIdentificacao OR pcdIdentificacao IS NULL);

    vcdAgrupamento := NULL;
    SELECT MAX(cdAgrupamento) INTO vcdAgrupamento
    FROM ecadAgrupamento WHERE sgAgrupamento = psgAgrupamentoDestino;

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nmTipoServico,1,70);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - ' ||
        'Tipo de Serviço - ' || r.nmTipoServico,
        cAUDITORIA_COMPLETO, pnuNivelAuditoria);

      -- Incluir Novo Tipo de Serviço
      SELECT NVL(MAX(cdTipoServico), 0) + 1 INTO vcdTipoServico FROM epagTipoServico;

      INSERT INTO epagTipoServico (
        cdTipoServico, cdAgrupamento, nmTipoServico, dtUltAlteracao
      ) VALUES (
        vcdTipoServico, vcdAgrupamento, r.nmTipoServico, vdtUltAlteracao
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, SUBSTR(r.nmTipoServico,1,70), 1,
        'TIPO SERVICO', 'INCLUSAO',
        'Tipo de Serviço incluídos com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      pImportarVigenciasTipoServico(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, SUBSTR(r.nmTipoServico,1,70), vcdTipoServico, r.Vigencias, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'TIPO SERVICO',
          'Importação dos Tipos de Serviços (PKGMIG_ParametrizacaoConsignacoes.pImportarTipoServicos)', SQLERRM);
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
    vcdIdentificacao      VARCHAR2(70) := Null;
    vnuRegistros          NUMBER := 0;

    vcdHistTipoServico    NUMBER := Null;
    vdtUltAlteracao       TIMESTAMP := SYSTIMESTAMP;

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
          js.vlTaxaBescor
          
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

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || TO_CHAR(r.dtInicioVigencia, 'YYYYMMDD'),1,70);

      PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignações - Tipo de Serviço - ' ||
        'Vigência ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

      -- Incluir Vigência do Tipo Serviço
      SELECT NVL(MAX(cdHistTipoServico), 0) + 1 INTO vcdHistTipoServico FROM epagHistTipoServico;

      INSERT INTO epagHistTipoServico (
        cdHistTipoServico, cdTipoServico, dtInicioVigencia, dtFimVigencia,
        flExigeContrato, flExigeValorLiberado, flExigeValorReservado, flIOFFinanciado, dtUltAlteracao,
        flExigePedido, flExigeConsigOutroTipo, vlLimitePercentReservado, vlLimiteReservado,
        nuMaxParcelas, vlMinConsignado, vlTaxaRetencao, vlRetencao, vlTaxaAdministracao, vlTaxaProlabore,
        vlTaxaIRRF, vlLimiteTAC, flEmprestimo, flSeguro, flCartaoCredito, nuOrdem, cdConsigOutroTipo,
        flTacFinanciada, flVerificaMargemConsig, vlTaxaBescor
      ) VALUES (
        vcdHistTipoServico, pcdTipoServico, r.dtInicioVigencia, r.dtFimVigencia,
        r.flExigeContrato, r.flExigeValorLiberado, r.flExigeValorReservado, r.flIOFFinanciado, vdtUltAlteracao,
        r.flExigePedido, r.flExigeConsigOutroTipo, r.vlLimitePercentReservado, r.vlLimiteReservado,
        r.nuMaxParcelas, r.vlMinConsignado, r.vlTaxaRetencao, r.vlRetencao, r.vlTaxaAdministracao, r.vlTaxaProlabore,
        r.vlTaxaIRRF, r.vlLimiteTAC, r.flEmprestimo, r.flSeguro, r.flCartaoCredito, r.nuOrdem, r.cdConsigOutroTipo,
        r.flTacFinanciada, r.flVerificaMargemConsig, r.vlTaxaBescor
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'TIPO SERVICO VIGENCIA', 'INCLUSAO',
        'Vigência do Tipo de Serviço incluídas com sucesso',
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
  --   psgAgrupamento        IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   nmEntidade            IN VARCHAR2,
  --   pcdIdentificacao      IN VARCHAR2:
  --   pDocumento            IN CLOB,
  --   pcdDocumento          OUT NUMBER,
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamento             IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    nmEntidade                 IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pDocumento                 IN CLOB,
    pcdDocumento               OUT NUMBER,
    pcdTipoPublicacao          OUT NUMBER,
    pdtPublicacao              OUT DATE,
    pnuPublicacao              OUT VARCHAR2,
    pnuPagInicial              OUT VARCHAR2,
    pcdMeioPublicacao          OUT NUMBER,
    pdeOutroMeio               OUT VARCHAR2,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  ) IS

    vChavesJSON                JSON_KEY_LIST;
    vDocJSON                   JSON_OBJECT_T;
    vDoc                       eatoDocumento%ROWTYPE;

    vnmTipoPublicacao          VARCHAR2(30)  := Null;
    vnmMeioPublicacao          VARCHAR2(90)  := Null;
    vdeTipoDocumento           VARCHAR2(200) := Null;

  BEGIN

    pcdDocumento      := NULL;
    pdtPublicacao     := NULL;
    pnuPublicacao     := NULL;
    pnuPagInicial     := NULL;
    pdeOutroMeio      := NULL;
    pcdTipoPublicacao := NULL;
    pcdMeioPublicacao := NULL;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 1,
      nmEntidade || ' DOCUMENTO AMPARO FATO', 'JSON',
      pDocumento,
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    IF pDocumento IS NOT NULL THEN
      vDocJSON := JSON_OBJECT_T.PARSE(pDocumento);
      vChavesJSON := vDocJSON.GET_KEYS;
      IF vChavesJSON.COUNT != 0 THEN

        pdtPublicacao                   := TO_DATE(vDocJSON.GET_STRING('dtPublicacao'), 'YYYY-MM-DD');
        pnuPublicacao                   := vDocJSON.GET_STRING('nuPublicacao');
        pnuPagInicial                   := vDocJSON.GET_STRING('nuPagInicial');
        pdeOutroMeio                    := vDocJSON.GET_STRING('deOutroMeio');
    
        vnmTipoPublicacao               := vDocJSON.GET_STRING('nmTipoPublicacao');
        SELECT MAX(cdTipoPublicacao) INTO pcdTipoPublicacao
        FROM ecadTipoPublicacao WHERE nmTipoPublicacao = vnmTipoPublicacao;
  
        IF pcdTipoPublicacao IS NULL AND vnmTipoPublicacao IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar(nmEntidade || ' Documentos de Amparo ao Fato - ' ||
            'Tipo da Publicação Inexistente ' || vnmTipoPublicacao,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vnmTipoPublicacao, 1,
            nmEntidade || ' DOCUMENTO AMPARO FATO', 'INCONSISTENTE',
            'Tipo da Publicação Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;
  
        vnmMeioPublicacao               := vDocJSON.GET_STRING('nmMeioPublicacao');
        SELECT MAX(cdMeioPublicacao) INTO pcdMeioPublicacao
        FROM ecadMeioPublicacao WHERE nmMeioPublicacao = vnmMeioPublicacao;
    
        IF pcdMeioPublicacao IS NULL AND vnmMeioPublicacao IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar(nmEntidade || ' Documentos de Amparo ao Fato - ' ||
            nmEntidade || ' Meio de Publicação Inexistente ' || vnmMeioPublicacao,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vnmMeioPublicacao, 1,
            nmEntidade || ' DOCUMENTO AMPARO FATO', 'INCONSISTENTE',
            'Meio de Publicação Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;
  
        vDoc.nuAnoDocumento             := vDocJSON.GET_NUMBER('nuAnoDocumento');
        vDoc.dtDocumento                := TO_DATE(vDocJSON.GET_STRING('dtDocumento'), 'YYYY-MM-DD');
        vDoc.deObservacao               := vDocJSON.GET_STRING('deObservacao');
        vDoc.nuNumeroAtoLegal           := vDocJSON.GET_STRING('nuNumeroAtoLegal');
        vDoc.nmArquivoDocumento         := vDocJSON.GET_STRING('nmArquivoDocumento');
        vDoc.deCaminhoArquivoDocumento  := vDocJSON.GET_STRING('deCaminhoArquivoDocumento');
  
        vdeTipoDocumento               := vDocJSON.GET_STRING('deTipoDocumento');
        SELECT MAX(cdTipoDocumento) INTO vDoc.cdTipoDocumento 
        FROM eatoTipoDocumento WHERE deTipoDocumento = vdeTipoDocumento;
  
        IF vDoc.cdTipoDocumento IS NULL AND vdeTipoDocumento IS NOT NULL THEN
          PKGMIG_ParametrizacaoLog.pAlertar(nmEntidade || ' Documentos de Amparo ao Fato - ' ||
            'Tipo de Documento Inexistente ' || vdeTipoDocumento,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
  
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao, 
            psgModulo, psgConceito, vdeTipoDocumento, 1,
            nmEntidade || ' DOCUMENTO AMPARO FATO', 'INCONSISTENTE',
            'Tipo de Documento Inexistente',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
        END IF;
  
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
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, pcdIdentificacao, 1,
            nmEntidade || ' DOCUMENTO AMPARO FATO', 'INCLUSAO',
            'Documentos de Amparo ao Fato incluidos com sucesso',
            cAUDITORIA_DETALHADO, pnuNivelAuditoria);
        END IF;  
      END IF;  
    END IF;  

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, nmEntidade || ' DOCUMENTO AMPARO FATO',
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
  --   psgAgrupamento        IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR:
  --   psgConceito           IN VARCHAR2:
  --   nmEntidade            IN VARCHAR2,
  --   pcdIdentificacao      IN VARCHAR2:
  --   pEndereco             IN CLOB,
  --   pcdEndereco           OUT NUMBER,
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamento             IN VARCHAR2,
    psgOrgao                   IN VARCHAR2,
    ptpOperacao                IN VARCHAR2,
    pdtOperacao                IN TIMESTAMP,
    psgModulo                  IN CHAR,
    psgConceito                IN VARCHAR2,
    nmEntidade                 IN VARCHAR2,
    pcdIdentificacao           IN VARCHAR2,
    pEndereco                  IN CLOB,
    pcdEndereco                OUT NUMBER,
	  pnuNivelAuditoria          IN NUMBER DEFAULT NULL
  ) IS

    vChavesJSON                JSON_KEY_LIST;
    vEndJSON                   JSON_OBJECT_T;

    vnuCEP                     VARCHAR2(08) := NULL;
    vsgEstado                  CHAR(02) := NULL;
    vnmLocalidade              VARCHAR2(90) := NULL;
    vnmBairro                  VARCHAR2(90) := NULL;
    vnmTipoLogradouro          VARCHAR2(100) := NULL;

    vEnd                       ecadEndereco%ROWTYPE;
    vBairro                    ecadBairro%ROWTYPE;
    vLocalidade                ecadLocalidade%ROWTYPE;

    cnuCPFCadastrador          CONSTANT VARCHAR2(11) := '11111111111';
    vdtInclusao                DATE := SYSDATE;

  BEGIN

    pcdEndereco := NULL;

    PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, 1,
      nmEntidade || ' ENDERECO', 'JSON',
      pEndereco,
      cAUDITORIA_COMPLETO, pnuNivelAuditoria);

    IF pEndereco IS NOT NULL THEN
      vEndJSON := JSON_OBJECT_T.PARSE(pEndereco);
      vChavesJSON := vEndJSON.GET_KEYS;
      IF vChavesJSON.COUNT != 0 THEN

        vEnd.flInconsistente  := 'N';
    
        vnuCEP        := vEndJSON.GET_STRING('nuCEP');
        vsgEstado     := UPPER(vEndJSON.GET_STRING('sgEstado'));
        vnmLocalidade := UPPER(vEndJSON.GET_STRING('nmLocalidade'));
        SELECT MAX(cdLocalidade) INTO vEnd.cdLocalidade FROM ecadLocalidade
        WHERE UPPER(sgEstado) = vsgEstado
          AND UPPER(nmLocalidade) = vnmLocalidade
          AND flInconsistente = 'N';
    
        IF vEnd.cdLocalidade IS NULL AND vnmLocalidade IS NOT NULL THEN
          vLocalidade.sgEstado         := vsgEstado;
          vLocalidade.nmLocalidade     := vnmLocalidade;
          vLocalidade.nuCEP            := vnuCEP;
          vLocalidade.inTipo           := 'M';
          vLocalidade.cdIBGE           := 0;
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
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, pcdIdentificacao, 1,
            nmEntidade || ' ENDERECO', 'INCLUSAO',
            'Localidade ' || vnmLocalidade || ' incluida com sucesso',
            cAUDITORIA_DETALHADO, pnuNivelAuditoria);
        END IF;
    
        vnmBairro := vEndJSON.GET_STRING('nmBairro');
        SELECT MAX(cdBairro) INTO vEnd.cdBairro FROM ecadBairro
        WHERE cdLocalidade = vEnd.cdLocalidade
          AND nmBairro = vnmBairro
          AND flInconsistente = 'N';
    
        IF vEnd.cdBairro IS NULL AND vnmBairro IS NOT NULL THEN
          vBairro.cdLocalidade     := vEnd.cdLocalidade;
          vBairro.nmBairro         := vnmBairro;
          vBairro.flInconsistente  := 'S';
          vBairro.cdReferencia     := NULL;
          vBairro.flAnulado        := 'N';
          vBairro.dtAnulado        := NULL;
          vBairro.nuCPFCadastrador := cnuCPFCadastrador;
          vBairro.dtInclusao       := vdtInclusao;
          vBairro.dtUltAlteracao   := SYSTIMESTAMP;
    
          SELECT NVL(MAX(cdBairro),0) + 1 INTO vBairro.cdBairro FROM ecadBairro;
    
          INSERT INTO ecadBairro VALUES vBairro;
    
          vEnd.cdBairro := vBairro.cdBairro;
          vEnd.flInconsistente  := 'S';
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, pcdIdentificacao, 1,
            nmEntidade || ' ENDERECO', 'INCLUSAO',
            'Bairro ' || vnmBairro || ' incluido com sucesso',
            cAUDITORIA_DETALHADO, pnuNivelAuditoria);
        END IF;
    
        vnmTipoLogradouro := vEndJSON.GET_STRING('nmTipoLogradouro');
        SELECT MAX(cdTipoLogradouro) INTO vEnd.cdTipoLogradouro
        FROM ecadTipoLogradouro WHERE nmTipoLogradouro = vnmTipoLogradouro;
    
        vEnd.nmLogradouro        := vEndJSON.GET_STRING('nmLogradouro');
        vEnd.dtInicio            := TO_DATE(vEndJSON.GET_STRING('dtInicio'), 'YYYY-MM-DD');
    
        -- Incluir Endereco
        IF vEnd.dtInicio IS NOT NULL AND vEnd.nmLogradouro IS NOT NULL THEN
          vEnd.nuCEP               := vnuCEP;
          vEnd.deComplLogradouro   := vEndJSON.GET_STRING('deComplLogradouro');
          vEnd.nuNumero            := vEndJSON.GET_STRING('nuNumero');
          vEnd.deComplemento       := vEndJSON.GET_STRING('deComplemento');
          vEnd.nmUnidade           := vEndJSON.GET_STRING('nmUnidade');
          vEnd.nuCaixaPostal       := vEndJSON.GET_STRING('nuCaixaPostal');
          vEnd.flTipoLogradouro    := NVL(vEndJSON.GET_STRING('flTipoLogradouro'), 'N');
          vEnd.flEnderecoExterior  := NVL(vEndJSON.GET_STRING('flEnderecoExterior'), 'N');
    
          vEnd.nuCPFCadastrador    := cnuCPFCadastrador;
          vEnd.dtInclusao          := vdtInclusao;
          vEnd.dtUltAlteracao      := SYSTIMESTAMP;
    
          SELECT NVL(MAX(cdEndereco), 0) + 1 INTO vEnd.cdEndereco FROM ecadEndereco;
    
          INSERT INTO ecadEndereco VALUES vEnd;
    
          pcdEndereco := vEnd.cdEndereco;
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, pcdIdentificacao, 1,
            nmEntidade || ' ENDERECO', 'INCLUSAO',
            'Endereco incluido com sucesso',
            cAUDITORIA_DETALHADO, pnuNivelAuditoria);
        END IF;  
      END IF;  
    END IF;  

    EXCEPTION
      WHEN OTHERS THEN
        -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, nmEntidade || ' ENDERECO',
          'Endereço (PKGMIG_ParametrizacaoConsignacoes.pIncluirEndereco)', SQLERRM);
      RAISE;
  END pIncluirEndereco;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações das Consignações
  FUNCTION fnCursorConsignacao(
    psgAgrupamento   IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2
  ) RETURN SYS_REFCURSOR IS
    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Comnsignação das Rubricas de um Agrupamento
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
      BancoAgencia AS (
      SELECT ag.cdAgencia,
        LPAD(bco.nuBanco,3,0) AS nuBanco, ag.nuAgencia, ag.nuDvAgencia,
        bco.sgBanco, bco.nmBanco, ag.nmAgencia
      FROM ecadAgencia ag
      INNER JOIN ecadBanco bco ON bco.cdBanco = ag.cdBanco
      ),
      Endereco AS (
      SELECT ed.cdEndereco,
      JSON_OBJECT(
        'nuCEP'                           VALUE NVL(ed.nuCEP,
                                                NVL(locbairro.nuCEP,loc.nuCEP)),
        'dtInicio'                        VALUE TO_CHAR(ed.dtInicio, 'YYYY-MM-DD'),
        'nmTipoLogradouro'                VALUE tpLog.nmTipoLogradouro,
        'nmLogradouro'                    VALUE ed.nmLogradouro,
        'deComplLogradouro'               VALUE ed.deComplLogradouro,
        'nuNumero'                        VALUE ed.nuNumero,
        'deComplemento'                   VALUE ed.deComplemento,
        'nmBairro'                        VALUE bairro.nmBairro,
        'nmUnidade'                       VALUE ed.nmUnidade,
        'nmLocalidade'                    VALUE NVL(locbairro.nmLocalidade,loc.nmLocalidade),
        'sgEstado'                        VALUE NVL(locbairro.sgEstado,loc.sgEstado),
        'nuCaixaPostal'                   VALUE ed.nuCaixaPostal,
        'flTipoLogradouro'                VALUE NULLIF(ed.flTipoLogradouro,'N'),
        'flEnderecoExterior'              VALUE NULLIF(ed.flEnderecoExterior,'N')
      ABSENT ON NULL) AS Endereco
      FROM ecadEndereco ed
      LEFT JOIN ecadBairro bairro ON bairro.cdBairro = ed.cdBairro
      LEFT JOIN ecadLocalidade locbairro ON locbairro.cdLocalidade = bairro.cdLocalidade
      LEFT JOIN ecadLocalidade loc ON loc.cdLocalidade = ed.cdLocalidade
      LEFT JOIN ecadTipoLogradouro tpLog ON tpLog.cdTipoLogradouro = ed.cdTipoLogradouro
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
      -- Parametros da Base de Consignaçao
      ParametroBaseConsignacao AS (
      SELECT cdParametroBaseConsignacao,
      JSON_OBJECT(
        'nuOrdemDesconto'                 VALUE parm.cdOrdemDesconto,
        'vlMinParcela'                    VALUE parm.vlMinParcela,
        'nuMaxParcelas'                   VALUE parm.nuMaxParcelas,
        'nuPrazoMaxCarencia'              VALUE parm.nuPrazoMaxCarencia,
        'nuPrazoReservaAverb'             VALUE parm.nuPrazoReservaAverb,
        'vlTaxaIOF'                       VALUE parm.vlTaxaIOF,
        'vlPercentVariacao'               VALUE NULLIF(parm.vlPercentVariacao, 999.9999),
        'nuDiaCorte'                      VALUE parm.nuDiaCorte,
        'nmDiaSemana'                     VALUE UPPER(dia.nmDiaSemana),
        'nuPrazoDefereConcessao'          VALUE NULLIF(parm.nuPrazoDefereConcessao, 999),
        'nuPrazoDefereAlteracao'          VALUE NULLIF(parm.nuPrazoDefereAlteracao, 999),
        'nuPrazoDeferereNegociacao'       VALUE NULLIF(parm.nuPrazoDeferereNegociacao, 999),
        'nuPrazoDefereLiquidacao'         VALUE NULLIF(parm.nuPrazoDefereLiquidacao, 999),
        'nuPrazoDefereEmprestimo'         VALUE NULLIF(parm.nuPrazoDefereEmprestimo, 999),
        'blManualConsig'                  VALUE parm.blManualConsig,
        'blManualServid'                  VALUE parm.blManualServid
      ABSENT ON NULL) AS ParametroBaseConsignacao
      FROM epagParametroBaseConsignacao parm
      LEFT JOIN ecadDiaSemana dia ON dia.cdDiaSemana = parm.cdDiaSemana
      ),
      -- Contrato Servico
      ContratoServicoConsignacao AS (
      SELECT ctr.cdcontratoservico, ctr.cdagrupamento, ctr.cdorgao, ctr.cdconsignataria,
      JSON_OBJECT(
        'nuContrato'                      VALUE ctr.nuContrato,
        'dtInicioContrato'                VALUE CASE WHEN ctr.dtInicioContrato IS NULL THEN NULL
                                                ELSE TO_CHAR(ctr.dtInicioContrato, 'YYYY-DD-MM') END,
        'dtFimContrato'                   VALUE CASE WHEN ctr.dtFimContrato IS NULL THEN NULL
                                                ELSE TO_CHAR(ctr.dtFimContrato, 'YYYY-DD-MM') END,
        'dtFimProrrogacao'                VALUE CASE WHEN ctr.dtFimProrrogacao IS NULL THEN NULL
                                                ELSE TO_CHAR(ctr.dtFimProrrogacao, 'YYYY-DD-MM') END,
        'nmTipoServico'                   VALUE tpserv.nmTipoServico,
        'nuCodigoConsignataria'           VALUE cst.nuCodigoConsignataria,
        'deServico'                       VALUE ctr.deServico,
        'deObjeto'                        VALUE ctr.deObjeto,
        'deSitePublicacao'                VALUE ctr.deSitePublicacao,
        'Seguro' VALUE
            CASE WHEN ctr.nuApolice IS NULL AND ctr.nuRegistroSUSEP IS NULL AND ctr.vlTaxaAngariamento IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'nuApolice'                   VALUE ctr.nuApolice,
            'nuRegistroSUSEP'             VALUE ctr.nuRegistroSUSEP,
            'vlTaxaAngariamento'          VALUE ctr.vlTaxaAngariamento
          ABSENT ON NULL) END,
          'Documento' VALUE
            CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
              doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
              meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
              ctr.dtPublicacao IS NULL AND ctr.nuPublicacao IS NULL AND ctr.nuPagInicial IS NULL AND
              ctr.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
            'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
            'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                                ELSE TO_CHAR(doc.dtDocumento, 'YYYY-DD-MM') END,
            'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
            'deObservacao'                VALUE doc.deObservacao,
            'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
            'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
            'dtPublicacao'                VALUE CASE WHEN ctr.dtPublicacao IS NULL THEN NULL
                                                ELSE TO_CHAR(ctr.dtPublicacao, 'YYYY-DD-MM') END,
            'nuPublicacao'                VALUE ctr.nuPublicacao,
            'nuPagInicial'                VALUE ctr.nuPagInicial,
            'deOutroMeio'                 VALUE ctr.deOutroMeio,
            'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
            'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
          ABSENT ON NULL) END
        ABSENT ON NULL) AS ContratoServico
      FROM epagContratoServico ctr
      LEFT JOIN epagTipoServico tpserv On tpserv.cdTipoServico = ctr.cdTipoServico
      LEFT JOIN epagConsignataria cst ON cst.cdConsignataria = ctr.cdConsignataria
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = ctr.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = ctr.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = ctr.cdTipoPublicacao
      ),
      -- Vigência do Tipo Servico 
      VigenciaTipoServicoConsignacao AS (
      SELECT vgtpserv.cdtiposervico,
      JSON_ARRAYAGG(JSON_OBJECT(
          'dtInicioVigencia'              VALUE CASE WHEN vgtpserv.dtInicioVigencia IS NULL THEN NULL
                                                ELSE TO_CHAR(vgtpserv.dtInicioVigencia, 'YYYY-DD-MM') END,
          'dtFimVigencia'                 VALUE CASE WHEN vgtpserv.dtFimVigencia IS NULL THEN NULL
                                                ELSE TO_CHAR(vgtpserv.dtFimVigencia, 'YYYY-DD-MM') END,
          'nuOrdem'                       VALUE vgtpserv.nuOrdem,
          'nmConsigOutroTipo'             VALUE vgtpserv.cdConsigOutroTipo,
          'Parametros' VALUE
            CASE WHEN NULLIF(vgtpserv.flEmprestimo, 'N') IS NULL AND NULLIF(vgtpserv.flSeguro, 'N') IS NULL AND 
              NULLIF(vgtpserv.flCartaoCredito, 'N') IS NULL AND NULLIF(vgtpserv.nuMaxParcelas, 999) IS NULL AND 
              vgtpserv.vlMinConsignado IS NULL AND vgtpserv.vlLimiteTAC IS NULL AND vgtpserv.vlLimitePercentReservado IS NULL AND 
              vgtpserv.vlLimiteReservado IS NULL AND NULLIF(vgtpserv.flTacFinanciada, 'N') IS NULL AND 
              NULLIF(vgtpserv.flVerificaMargemConsig, 'N') IS NULL AND NULLIF(vgtpserv.flIOFFinanciado, 'N') IS NULL AND 
              NULLIF(vgtpserv.flExigeContrato, 'N') IS NULL AND NULLIF(vgtpserv.flExigeValorLiberado, 'N') IS NULL AND 
              NULLIF(vgtpserv.flExigeValorReservado, 'N') IS NULL AND NULLIF(vgtpserv.flExigePedido, 'N') IS NULL AND 
              NULLIF(vgtpserv.flExigeConsigOutroTipo, 'N') IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'flEmprestimo'                VALUE NULLIF(vgtpserv.flEmprestimo, 'N'),
            'flSeguro'                    VALUE NULLIF(vgtpserv.flSeguro, 'N'),
            'flCartaoCredito'             VALUE NULLIF(vgtpserv.flCartaoCredito, 'N'),
            'nuMaxParcelas'               VALUE NULLIF(vgtpserv.nuMaxParcelas, 999),
            'vlMinConsignado'             VALUE vgtpserv.vlMinConsignado,
            'vlLimiteTAC'                 VALUE vgtpserv.vlLimiteTAC,
            'vlLimitePercentReservado'    VALUE vgtpserv.vlLimitePercentReservado,
            'vlLimiteReservado'           VALUE vgtpserv.vlLimiteReservado,
            'flTacFinanciada'             VALUE NULLIF(vgtpserv.flTacFinanciada, 'N'),
            'flVerificaMargemConsig'      VALUE NULLIF(vgtpserv.flVerificaMargemConsig, 'N'),
            'flIOFFinanciado'             VALUE NULLIF(vgtpserv.flIOFFinanciado, 'N'),
            'flExigeContrato'             VALUE NULLIF(vgtpserv.flExigeContrato, 'N'),
            'flExigeValorLiberado'        VALUE NULLIF(vgtpserv.flExigeValorLiberado, 'N'),
            'flExigeValorReservado'       VALUE NULLIF(vgtpserv.flExigeValorReservado, 'N'),
            'flExigePedido'               VALUE NULLIF(vgtpserv.flExigePedido, 'N'),
            'flExigeConsigOutroTipo'      VALUE NULLIF(vgtpserv.flExigeConsigOutroTipo, 'N')
          ABSENT ON NULL) END,
          'TaxaRetencao' VALUE
            CASE WHEN vgtpserv.vlRetencao IS NULL AND vgtpserv.vlTaxaRetencao IS NULL AND vgtpserv.vlTaxaIRRF IS NULL AND
              vgtpserv.vlTaxaAdministracao IS NULL AND vgtpserv.vlTaxaProlabore IS NULL AND vgtpserv.vlTaxaBescor IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'vlRetencao'                  VALUE vgtpserv.vlRetencao,
            'vlTaxaRetencao'              VALUE vgtpserv.vlTaxaRetencao,
            'vlTaxaIR'                    VALUE vgtpserv.vlTaxaIRRF,
            'vlTaxaAdministracao'         VALUE vgtpserv.vlTaxaAdministracao,
            'vlTaxaProlabore'             VALUE vgtpserv.vlTaxaProlabore,
            'vlTaxaBescor'                VALUE vgtpserv.vlTaxaBescor
          ABSENT ON NULL) END
      ABSENT ON NULL) ORDER BY vgtpserv.dtInicioVigencia DESC RETURNING CLOB) AS Vigencias
      FROM epagHistTipoServico vgtpserv
      GROUP BY vgtpserv.cdtiposervico
      ),
      -- Tipo de Servico de Consignção
      TipoServicoConsigncao AS (
      SELECT tiposervico.cdTipoServico, tiposervico.cdAgrupamento,
      JSON_OBJECT(
        'nmTipoServico'                   VALUE tiposervico.nmTipoServico,
        'ParametrosPadrao'                VALUE parm.ParametroBaseConsignacao,
        'Vigencias'                       VALUE vigencia.Vigencias
      ABSENT ON NULL RETURNING CLOB) AS TipoServico
      FROM epagTipoServico tiposervico
      LEFT JOIN VigenciaTipoServicoConsignacao vigencia on vigencia.cdtiposervico = tiposervico.cdtiposervico
      LEFT JOIN ParametroBaseConsignacao parm on parm.cdParametroBaseConsignacao = 1
      ),
      -- Consignataria Suspensao
      ConsignatariaSuspensao AS (
      SELECT cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico,
      JSON_ARRAYAGG(JSON_OBJECT(
      cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico,
        'nuCodigoConsignataria'         VALUE cst.nuCodigoConsignataria,
      --  'nuRubrica'                     VALUE rub.nuRubrica || ' ' || rub.deRubrica,
        'nmTipoServico'                 VALUE tiposervico.nmTipoServico,
        'dtInicioSuspensao'             VALUE CASE WHEN cstsup.dtInicioSuspensao IS NULL THEN NULL
                                              ELSE TO_CHAR(cstsup.dtInicioSuspensao, 'YYYY-DD-MM') END,
        'nuHoraInicioSuspensao'         VALUE cstsup.nuHoraInicioSuspensao,
        'dtFimSuspensao'                VALUE CASE WHEN cstsup.dtFimSuspensao IS NULL THEN NULL
                                               ELSE TO_CHAR(cstsup.dtFimSuspensao, 'YYYY-DD-MM') END,
        'nuHoraFimSuspensao'            VALUE cstsup.nuHoraFimSuspensao,
        'deMotivoSuspensao'             VALUE cstsup.deMotivoSuspensao,
        'Documento' VALUE
          CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
            doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
            meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
            cst.dtPublicacao IS NULL AND cstsup.nuPublicacao IS NULL AND cstsup.nuPagInicial IS NULL AND
            cstsup.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
          THEN NULL
          ELSE JSON_OBJECT(
          'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
          'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
          'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                              ELSE TO_CHAR(doc.dtDocumento, 'YYYY-DD-MM') END,
          'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
          'deObservacao'                VALUE doc.deObservacao,
          'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
          'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
          'dtPublicacao'                VALUE CASE WHEN cst.dtPublicacao IS NULL THEN NULL
                                              ELSE TO_CHAR(cst.dtPublicacao, 'YYYY-DD-MM') END,
          'nuPublicacao'                VALUE cstsup.nuPublicacao,
          'nuPagInicial'                VALUE cstsup.nuPagInicial,
          'deOutroMeio'                 VALUE cstsup.deOutroMeio,
          'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
          'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
        ABSENT ON NULL) END
      ABSENT ON NULL) ORDER BY cstsup.dtInicioSuspensao DESC RETURNING CLOB) AS Suspensao
      FROM epagConsignatariaSuspensao cstsup
      LEFT JOIN epagConsignataria cst on cst.cdConsignataria = cstsup.cdConsignataria
      LEFT JOIN epagConsignacao csg on csg.cdConsignacao = cstsup.cdConsignacao
      LEFT JOIN RubricaLista rub ON rub.cdRubrica = csg.cdRubrica
      LEFT JOIN epagTipoServico tiposervico on tiposervico.cdTipoServico = cstsup.cdTipoServico
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = cstsup.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = cst.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = cst.cdTipoPublicacao
      GROUP BY cstsup.cdconsignataria, cstsup.cdconsignacao, cstsup.cdtiposervico
      ),
      -- Consignataria Taxa Servico
      ConsignatariaTaxaServico AS (
      SELECT csttaxa.cdconsignataria,
      JSON_ARRAYAGG(tiposervico.nmTipoServico
      ORDER BY csttaxa.cdTipoServico DESC ABSENT ON NULL RETURNING CLOB) AS TaxasServicos
      FROM epagConsignatariaTaxaServico csttaxa
      LEFT JOIN epagTipoServico tiposervico ON tiposervico.cdTipoServico = csttaxa.cdTipoServico
      GROUP BY csttaxa.cdconsignataria
      ),
      -- Consignataria
      Consignataria AS (
      SELECT cst.cdConsignataria,
      JSON_OBJECT(
        'nuCodigoConsignataria'           VALUE cst.nuCodigoConsignataria,
        'sgConsignataria'                 VALUE cst.sgConsignataria,
        'nmConsignataria'                 VALUE cst.nmConsignataria,
        'deEmailInstitucional'            VALUE cst.deEmailInstitucional,
        'deInstrucoesContato'             VALUE cst.deInstrucoesContato,
        'nuCNPJConsignataria'             VALUE cst.nuCNPJConsignataria,
        'nmModalidadeConsignataria'       VALUE modcst.nmModalidadeConsignataria,
        'nuProcessoSGPE'                  VALUE cst.nuProcessoSGPE,
        'flMargemConsignavel'             VALUE NULLIF(cst.flMargemConsignavel,'N'),
        'flImpedida'                      VALUE NULLIF(cst.flImpedida,'N'),
        'TaxasServicos'                   VALUE taxa.TaxasServicos,
        'Representacao' VALUE
          CASE WHEN cst.cdagencia IS NULL AND cst.nucontacorrente IS NULL AND cst.nudvcontacorrente IS NULL
          THEN NULL
          ELSE JSON_OBJECT(
          'sgBanco'                       VALUE bcoag.sgBanco,
          'nmBanco'                       VALUE bcoag.nmBanco,
          'nmAgencia'                     VALUE bcoag.nmAgencia,
          'nuBanco'                       VALUE bcoag.nuBanco,
          'nuAgencia'                     VALUE bcoag.nuAgencia,
          'nuDvAgencia'                   VALUE bcoag.nuDvAgencia,
          'nuContaCorrente'               VALUE cst.nuContaCorrente,
          'nuDVContaCorrente'             VALUE cst.nuDVContaCorrente
        ABSENT ON NULL) END,
        'TelefonesEndereco' VALUE
          CASE WHEN cst.cdEndereco IS NULL AND cst.nuDDD IS NULL AND cst.nuTelefone IS NULL AND 
            cst.nuRamal IS NULL AND cst.nuDDDFax IS NULL AND cst.nuFax IS NULL AND cst.nuRamalfax IS NULL
          THEN NULL
          ELSE JSON_OBJECT(
          'nuDDD'                         VALUE cst.nuDDD,
          'nuTelefone'                    VALUE cst.nuTelefone,
          'nuRamal'                       VALUE cst.nuRamal,
          'nuDDDFax'                      VALUE cst.nuDDDFax,
          'nuFax'                         VALUE cst.nuFax,
          'nuRamalfax'                    VALUE cst.nuRamalfax,
          'EnderecoRepresentante'         VALUE ed.Endereco
        ABSENT ON NULL) END,
        'Representante' VALUE
          CASE WHEN tpRep.cdTipoRepresentacao IS NULL AND cst.nuCNPJRepresentante IS NULL AND 
            cst.nmRepresentante IS NULL AND cst.cdEnderecoRepresentante IS NULL AND cst.nuDDDRepresentante IS NULL AND 
            cst.nuTelefoneRepresentante IS NULL AND cst.nuRamalRepresentante IS NULL AND cst.nuDDDFaxRepresentante IS NULL AND 
            cst.nuFaxRepresentante IS NULL AND cst.nuRamalFaxRepresentante IS NULL
          THEN NULL
          ELSE JSON_OBJECT(
          'nmTipoRepresentacao'           VALUE tpRep.nmTipoRepresentacao,
          'nuCNPJRepresentante'           VALUE cst.nuCNPJRepresentante,
          'nmRepresentante'               VALUE cst.nmRepresentante,
          'nuDDDRepresentante'            VALUE cst.nuDDDRepresentante,
          'nuTelefoneRepresentante'       VALUE cst.nuTelefoneRepresentante,
          'nuRamalRepresentante'          VALUE cst.nuRamalRepresentante,
          'nuDDDFaxRepresentante'         VALUE cst.nuDDDFaxRepresentante,
          'nuFaxRepresentante'            VALUE cst.nuFaxRepresentante,
          'nuRamalFaxRepresentante'       VALUE cst.nuRamalFaxRepresentante,
          'EnderecoRepresentante'         VALUE edrpt.Endereco
        ABSENT ON NULL) END,
        'Documento' VALUE
          CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
            doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
            meiopub.nmMeioPublicacao IS NULL AND tppub.nmTipoPublicacao IS NULL AND
            cst.dtPublicacao IS NULL AND cst.nuPublicacao IS NULL AND cst.nuPagInicial IS NULL AND
            cst.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
          THEN NULL
          ELSE JSON_OBJECT(
          'nuAnoDocumento'                VALUE doc.nuAnoDocumento,
          'deTipoDocumento'               VALUE tpdoc.deTipoDocumento,
          'dtDocumento'                   VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                                ELSE TO_CHAR(doc.dtDocumento, 'YYYY-DD-MM') END,
          'nuNumeroAtoLegal'              VALUE doc.nuNumeroAtoLegal,
          'deObservacao'                  VALUE doc.deObservacao,
          'nmMeioPublicacao'              VALUE meiopub.nmMeioPublicacao,
          'nmTipoPublicacao'              VALUE tppub.nmTipoPublicacao,
          'dtPublicacao'                  VALUE CASE WHEN cst.dtPublicacao IS NULL THEN NULL
                                                ELSE TO_CHAR(cst.dtPublicacao, 'YYYY-DD-MM') END,
          'nuPublicacao'                  VALUE cst.nuPublicacao,
          'nuPagInicial'                  VALUE cst.nuPagInicial,
          'deOutroMeio'                   VALUE cst.deOutroMeio,
          'nmArquivoDocumento'            VALUE doc.nmArquivoDocumento,
          'deCaminhoArquivoDocumento'     VALUE doc.deCaminhoArquivoDocumento
        ABSENT ON NULL) END
      ABSENT ON NULL RETURNING CLOB) AS Consignataria
      FROM epagConsignataria cst
      LEFT JOIN epagTipoRepresentacao tpRep ON tpRep.cdTipoRepresentacao = cst.cdTipoRepresentacao
      LEFT JOIN epagModalidadeConsignataria modcst ON modcst.cdModalidadeConsignataria = cst.cdModalidadeConsignataria
      LEFT JOIN ConsignatariaTaxaServico taxa ON taxa.cdConsignataria = cst.cdConsignataria
      LEFT JOIN ConsignatariaSuspensao sup ON sup.cdConsignataria = cst.cdConsignataria
      LEFT JOIN BancoAgencia bcoag ON bcoag.cdAGencia = cst.cdAgencia
      LEFT JOIN Endereco ed ON ed.cdEndereco = cst.cdEndereco
      LEFT JOIN Endereco edrpt ON edrpt.cdEndereco = cst.cdEnderecoRepresentante
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = cst.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = cst.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = cst.cdTipoPublicacao
      ),
      -- Vigência da Consignação
      VigenciaConsignacao AS (
      SELECT vigencia.cdConsignacao,
      JSON_ARRAYAGG(JSON_OBJECT(
          'dtInicioVigencia' VALUE CASE WHEN vigencia.dtInicioVigencia IS NULL THEN NULL
            ELSE TO_CHAR(vigencia.dtInicioVigencia, 'YYYY-DD-MM') END,
          'dtFimVigencia'    VALUE CASE WHEN vigencia.dtFimVigencia IS NULL THEN NULL
            ELSE TO_CHAR(vigencia.dtFimVigencia, 'YYYY-DD-MM') END,
          'Parametros' VALUE
            CASE WHEN NULLIF(vigencia.nuMaxParcelas, 999) IS NULL AND vigencia.vlMinConsignado IS NULL AND
              vigencia.vlMinDescontoFolha IS NULL AND NULLIF(vigencia.flMaisDeUmaOcorrencia, 'S') IS NULL AND
              NULLIF(vigencia.flLancamentoManual, 'N') IS NULL AND NULLIF(vigencia.flDescontoEventual, 'N') IS NULL AND
              NULLIF(vigencia.flDescontoParcial, 'N') IS NULL AND NULLIF(vigencia.flFormulaCalculo, 'N') IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'nuMaxParcelas'               VALUE NULLIF(vigencia.nuMaxParcelas, 999),
            'vlMinConsignado'             VALUE vigencia.vlMinConsignado,
            'vlMinDescontoFolha'          VALUE vigencia.vlMinDescontoFolha,
            'flMaisDeUmaOcorrencia'       VALUE NULLIF(vigencia.flMaisDeUmaOcorrencia, 'S'),
            'flLancamentoManual'          VALUE NULLIF(vigencia.flLancamentoManual, 'N'),
            'flDescontoEventual'          VALUE NULLIF(vigencia.flDescontoEventual, 'N'),
            'flDescontoParcial'           VALUE NULLIF(vigencia.flDescontoParcial, 'N'),
            'flFormulaCalculo'            VALUE NULLIF(vigencia.flFormulaCalculo, 'N')
          ABSENT ON NULL) END,
          'TaxaRetencao' VALUE
            CASE WHEN vigencia.vlRetencao IS NULL AND vigencia.vlTaxaRetencao IS NULL AND vigencia.vlTaxaIR IS NULL AND
              vigencia.vlTaxaAdministracao IS NULL AND vigencia.vlTaxaProlabore IS NULL AND vigencia.vlTaxaBescor IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'vlRetencao'                  VALUE vigencia.vlRetencao,
            'vlTaxaRetencao'              VALUE vigencia.vlTaxaRetencao,
            'vlTaxaIR'                    VALUE vigencia.vlTaxaIR,
            'vlTaxaAdministracao'         VALUE vigencia.vlTaxaAdministracao,
            'vlTaxaProlabore'             VALUE vigencia.vlTaxaProlabore,
            'vlTaxaBescor'                VALUE vigencia.vlTaxaBescor
          ABSENT ON NULL) END,
          'Documento' VALUE
            CASE WHEN doc.nuAnoDocumento IS NULL AND tpdoc.deTipoDocumento IS NULL AND
              doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
              vigencia.cdMeioPublicacao IS NULL AND meiopub.nmMeioPublicacao IS NULL AND
              tppub.nmTipoPublicacao IS NULL AND vigencia.dtPublicacao IS NULL AND
              vigencia.nuPublicacao IS NULL AND vigencia.nuPagInicial IS NULL AND vigencia.deOutroMeio IS NULL AND
              doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
            THEN NULL
            ELSE JSON_OBJECT(
            'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
            'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
            'dtDocumento'                 VALUE CASE WHEN doc.dtDocumento IS NULL THEN NULL
                                                ELSE TO_CHAR(doc.dtDocumento, 'YYYY-DD-MM') END,
            'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
            'deObservacao'                VALUE doc.deObservacao,
            'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
            'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
            'dtPublicacao'                VALUE CASE WHEN vigencia.dtPublicacao IS NULL THEN NULL
                                                ELSE TO_CHAR(vigencia.dtPublicacao, 'YYYY-DD-MM') END,
            'nuPublicacao'                VALUE vigencia.nuPublicacao,
            'nuPagInicial'                VALUE vigencia.nuPagInicial,
            'deOutroMeio'                 VALUE vigencia.deOutroMeio,
            'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
            'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
          ABSENT ON NULL) END
      ABSENT ON NULL) ORDER BY vigencia.dtInicioVigencia DESC RETURNING CLOB) AS Vigencias
      FROM epagHistConsignacao vigencia
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = vigencia.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = vigencia.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = vigencia.cdTipoPublicacao
      GROUP BY vigencia.cdConsignacao
      ),
      Consignacao AS (
      -- Consignação  
      SELECT rub.nuRubrica, rub.cdAgrupamento, rub.cdRubricaAgrupamento,
      JSON_OBJECT(
        'nuRubrica'               VALUE rub.nuRubrica,
        'deRubrica'               VALUE rub.deRubrica,
        'dtInicioConcessao'       VALUE CASE WHEN csg.dtInicioConcessao IS NULL THEN NULL
                                        ELSE TO_CHAR(csg.dtInicioConcessao, 'YYYY-DD-MM') END,
        'dtFimConcessao'          VALUE CASE WHEN csg.dtFimConcessao IS NULL THEN NULL
                                        ELSE TO_CHAR(csg.dtFimConcessao, 'YYYY-DD-MM') END,
        'flGeridaTerceitos'       VALUE NULLIF(csg.flGeridaSCConsig,'S'), -- DEFAULT S
        'flRepasse'               VALUE NULLIF(csg.flRepasse,'S'), -- DEFAULT S
        'Vigencias'               VALUE vigencia.Vigencias,
        'Consignataria'           VALUE cst.Consignataria,
        'TipoServico'             VALUE tpServico.TipoServico,
        'ContratoServico'         VALUE contrato.ContratoServico
      ABSENT ON NULL RETURNING CLOB) AS Consignacao
      FROM epagConsignacao csg
      INNER JOIN RubricaLista rub ON rub.cdRubrica = csg.cdRubrica
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rub.cdAgrupamento
      LEFT JOIN VigenciaConsignacao vigencia ON vigencia.cdConsignacao = csg.cdConsignacao
      LEFT JOIN Consignataria cst ON cst.cdConsignataria = csg.cdConsignataria
      LEFT JOIN TipoServicoConsigncao tpServico ON (tpServico.cdAgrupamento = rub.cdAgrupamento OR tpServico.cdAgrupamento IS NULL)
                                               AND tpServico.cdTipoServico = csg.cdTipoServico
      LEFT JOIN ContratoServicoConsignacao contrato ON contrato.cdAgrupamento = rub.cdAgrupamento
                                                   AND contrato.cdConsignataria = csg.cdConsignataria
                                                   AND contrato.cdContratoServico = csg.cdContratoServico
        WHERE a.sgAgrupamento = psgAgrupamento
          AND (rub.nuRubrica = pcdIdentificacao OR pcdIdentificacao IS NULL)
        ORDER BY rub.nuRubrica
      )
      SELECT 
        psgAgrupamento AS sgAgrupamento,
        nuRubrica AS cdIdentificacao,
        Consignacao AS jsConteudo
      FROM Consignacao
      ORDER BY sgAgrupamento, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorConsignacao;

END PKGMIG_ParametrizacaoConsignacoes;
/
