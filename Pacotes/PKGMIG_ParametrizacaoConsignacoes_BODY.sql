-- Corpo do Pacote de Importação das Parametrizações de Consignações
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoConsignacoes AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
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
        NVL(js.flGeridaTerceitos, 'N') AS flGeridaTerceitos,
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
        INNER JOIN epagTipoServico tpserv ON tpserv.nmTipoServico = js.nmTipoServico
        LEFT JOIN ConsignacoesExistentes existe ON existe.nuRubrica = LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
        WHERE existe.nuRubrica IS NULL
      )
      SELECT * FROM Consignacao;

    BEGIN

      vcdIdentificacao := pcdIdentificacao;
  
      PKGMIG_ParametrizacaoLog.pAlertar('Importação da Consignação - ' ||
        vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
  	
      -- Loop principal de processamento para Incluir as Consignações não Existentes
      FOR r IN cDados LOOP
  
    	  vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuRubrica,1,70);
    
        -- Importar Contrato de Serviço
        IF js.nuContrato IS NOT NULL THEN
          pImportarContratoServico(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, vcdConsignacaoNova, r.ContratoServico, pnuNivelAuditoria);
          r.cdContratoServico := NULL;
        END IF;

    	  -- Inserir na tabela epagConsignacao
    	  SELECT NVL(MAX(cdConsignacao), 0) + 1 INTO vcdConsignacaoNova FROM epagConsignacao;
    
          INSERT INTO epagConsignacao (
            cdConsignacao, cdConsignataria, cdRubrica, cdTipoServico, cdContratoServico,
            dtInicioConcessao, dtFimConcessao, dtInclusao, dtUltAlteracao, flGeridaSCConsig, flRepasse
          ) VALUES (
            vcdConsignacaoNova, r.cdConsignataria, r.cdRubrica, r.cdTipoServico, r.cdContratoServico,
            r.dtInicioConcessao, r.dtFimConcessao, r.dtInclusao, r.dtUltAlteracao, r.flGeridaSCConsig, r.flRepasse
          );
    
          PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, 1,
            'CONSIGNACAO', 'INCLUSAO',
            'Comnsignação incluída com sucesso',
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    
          -- Importar Vigencias da Consignação
          pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
            psgModulo, psgConceito, vcdIdentificacao, vcdConsignacaoNova, r.Vigencias, pnuNivelAuditoria);

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'CONSIGNACAO',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportar)', SQLERRM);
      RAISE;
  END pImportar;

  PROCEDURE pImportarContrato(
  -- ###########################################################################
  -- PROCEDURE: pImportarContrato
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
    pcdConsignacao        IN NUMBER,
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

    PKGMIG_ParametrizacaoLog.pAlertar('Importação da Consignação - ' ||
      'Contrato de Serviço ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.nuContrato,1,70);

      -- Incluir Novo Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        r.nuAnoDocumento, r.cdTipoDocumento, r.dtDocumento, r.deObservacao, r.nuNumeroAtoLegal,
        r.nmArquivoDocumento, r.deCaminhoArquivoDocumento, vcdDocumentoNovo,
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
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'CONSIGNACAO CONTRATO',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarContrato)', SQLERRM);
      RAISE;
  END pImportarContrato;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
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
      FROM JSON_TABLE('[{"dtInicioVigencia":"1901-01-01"}]', '$[*]' COLUMNS (
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

    PKGMIG_ParametrizacaoLog.pAlertar('Importação da Consignação - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
         TO_CHAT(js.dtInicioVigencia, 'YYYYMMDD'),1,70);
       
      -- Incluir Novo Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao,
        r.nuAnoDocumento, r.cdTipoDocumento, r.dtDocumento, r.deObservacao, r.nuNumeroAtoLegal,
        r.nmArquivoDocumento, r.deCaminhoArquivoDocumento, vcdDocumentoNovo,
        pnuNivelAuditoria);

      -- Incluir Nova Vigência da Consignação
      SELECT NVL(MAX(cdHistConsignacao), 0) + 1 INTO vcdHistConsignacaoNova FROM epagHistConsignacao;

      INSERT INTO epagHistConsignacao (
        cdHistConsignacao, cdConsignacao, dtInicioVigencia, dtFimVigencia,
        vlMinConsignado, flLancamentoManual, flDescontoParcial, flFormulaCalculo, vlMinDescontoFolha,
        nuMaxParcelas, flMaisDeUmaOcorrencia, vlTaxaRetencao, vlRetencao, vlTaxaIR, vlTaxaAdministracao,
        vlTaxaProlabore, flDescontoEventual,
        cdDocumento, cdTipoPublicacao, dtPublicacao, nuPublicacao, nuPagInicial, cdMeioPublicacao, deOutroMeio,
        nuCPFCadastrador, dtInclusao, dtuUltAlteracao, vlTaxaBescor
      ) VALUES (
        vcdHistConsignacaoNova, r.cdConsignacao, r.dtInicioVigencia, r.dtFimVigencia,
        r.vlMinConsignado, r.flLancamentoManual, r.flDescontoParcial, r.flFormulaCalculo, r.vlMinDescontoFolha,
        r.nuMaxParcelas, r.flMaisDeUmaOcorrencia, r.vlTaxaRetencao, r.vlRetencao, r.vlTaxaIR, r.vlTaxaAdministracao,
        r.vlTaxaProlabore, r.flDescontoEventual,
        vcdDocumentoNovo, r.cdTipoPublicacao,  r.dtPublicacao, r.nuPublicacao, r.nuPagInicial, r.cdMeioPublicacao, r.deOutroMeio,
        r.nuCPFCadastrador, r.dtInclusao, r.dtuUltAlteracao, r.vlTaxaBescor
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
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, vcdIdentificacao, 'CONSIGNACAO VIGENCIA',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigencias;

  PROCEDURE pImportarConsignataria(
  -- ###########################################################################
  -- PROCEDURE: pImportarConsignataria
  -- Objetivo:
  --   Importar dados das Consignataria do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
  --     - Inclusão do Documento de Amparo ao Fato da Consignataria 
  --       na tabela eatoDocumento
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2:
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
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
	  pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdConsignatariaNovo   NUMBER := Null;
    vcdDocumentoNovo       NUMBER := Null;
    vnuRegistros           NUMBER := 0;

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
      ConsignatariaExistentes AS (SELECT nuCodigoConsignataria FROM epagConsignataria),
      NovasConsignatarias AS (
      SELECT js.nuCodigoConsignataria, parm.jsConteudo,
      RANK() OVER (PARTITION BY js.nuCodigoConsignataria ORDER BY parm.cdIdentificacao) AS nuOrder
      FROM emigParametrizacao parm
      CROSS APPLY JSON_TABLE(parm.jsConteudo,
        '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.Consignataria'
        COLUMNS (nuCodigoConsignataria)
      ) js
      LEFT JOIN ConsignatariaExistentes existe ON existe.nuCodigoConsignataria = js.nuCodigoConsignataria
      WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
        AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
        AND existe.nuCodigoConsignataria IS NOT NULL
      ORDER BY LPAD(js.nuCodigoConsignataria,3,0)
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
      js.EnderecoRepresentante,
      js.nuDDDRepresentante,
      js.nuTelefoneRepresentante,
      js.nuRamalRepresentante,
      js.nuDDDFaxRepresentante,
      js.nuFaxRepresentante,
      js.nuRamalFaxRepresentante,
      
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
      
      FROM NovasConsignatarias novacst
      CROSS APPLY JSON_TABLE(novacst.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.Consignataria' COLUMNS (
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
      ORDER BY LPAD(js.nuCodigoConsignataria,3,0)
      )
      SELECT * FROM Consignataria;

  BEGIN

    PKGMIG_ParametrizacaoLog.pAlertar('Importação das Consignatarias - ',
      cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

      IF r.cdTipoRepresentacao IS NULL AND r.nmTipoRepresentacao IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Consignatária - ' ||
          'Tipo de Representação na Consignatária Inexistente ' || vcdIdentificacao || ' ' || r.nmTipoRepresentacao,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmTipoRepresentacao, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Tipo de Representação na Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdAgencia IS NULL AND r.nuAgencia IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Consignatária - ' ||
          'Banco e Agencia da Consignatária Inexistente ' || vcdIdentificacao || ' ' || r.nuBanco || ' ' || r.nuAgencia,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nuBanco || ' ' || r.nuAgencia, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Banco e Agencia da Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      IF r.cdModalidadeConsignataria IS NULL AND r.nmTipoRepresentacao IS NOT NULL THEN
        PKGMIG_ParametrizacaoLog.pAlertar('Consignatária - ' ||
          'Modalidade da Consignatária Inexistente ' || vcdIdentificacao || ' ' || r.nmModalidadeConsignataria,
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao || ' ' || r.nmModalidadeConsignataria, 1,
          'CONSIGNATARIA', 'INCONSISTENTE',
          'Modalidade da Consignatária Inexistente',
          cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END IF;

      -- Incluir Novo Documento se as informações não forem nulas e Retorna Novo cdDocumento
      pIncluirDocumentoAmparoFato(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, NULL, r.Documento, vcdDocumentoNovo, pnuNivelAuditoria);

      -- Incluir Endereço da Representação
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, NULL, r.EnderecoRepresentacao, vcdEnderecoRepresentacao, pnuNivelAuditoria);

      -- Incluir Endereço do Representante
      pIncluirEndereco(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, NULL, r.EnderecoRepresentante, vcdEnderecoRepresentante, pnuNivelAuditoria);

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
        psgModulo, psgConceito, NULL, 1,
        'CONSIGNATARIA', 'INCLUSAO',
        'Consignatária incluídas com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'CONSIGNATARIA',
          'Importação das Consignatárias (PKGMIG_ParametrizacaoConsignacoes.pImportarConsignataria)', SQLERRM);
      RAISE;
  END pImportarConsignataria;

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

    vDoc.nuAnoDocumento             := vDocJSON.get_number_or_null('nuAnoDocumento');
    vDoc.dtDocumento                := TO_DATE(vDocJSON.get_string_or_null('dtDocumento'), 'YYYY-MM-DD');
    vDoc.deObservacao               := vDocJSON.get_string_or_null('deObservacao');
    vDoc.nuNumeroAtoLegal           := vDocJSON.get_string_or_null('nuNumeroAtoLegal');
    vDoc.nmArquivoDocumento         := vDocJSON.get_string_or_null('nmArquivoDocumento');
    vDoc.deCaminhoArquivoDocumento  := vDocJSON.get_string_or_null('deCaminhoArquivoDocumento');

    SELECT MAX(cdTipoDocumento) INTO vatoDoc.cdTipoDocumento 
    FROM ecadTipoDocumento WHERE nmTipoDocumento = vDocJSON.get_string_or_null('deTipoDocumento');

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
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
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
    WHERE UPPER(sgEstado) = UPPER(vEndJSON.get_string_or_null('sgEstado'))
      AND UPPER(nmLocalidade) = UPPER(vEndJSON.get_string_or_null('nmLocalidade'))
      AND flInconsistente = 'N';

    IF vEnd.cdLocalidade IS NULL THEN
      vLocalidade.sgEstado         := vEndJSON.get_string_or_null('sgEstado');
      vLocalidade.nmLocalidade     := vEndJSON.get_string_or_null('nmLocalidade');
      vLocalidade.nuCEP            := vEndJSON.get_string_or_null('nuCEP');
      vLocalidade.inTipo           := DECODE(vEndJSON.get_string_or_null('inTipo'),
                                        'MUNICIPIO','M', 
                                        'DISTRITO', 'D', 
                                        'POVOADO',  'P', 
                                        'M');
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
      AND nmBairro = vEndJSON.get_string_or_null('nmBairro');
      AND flInconsistente = 'N';

    IF vEnd.cdBairro IS NULL THEN
      vBairro.nmLocalidade     := vEnd.cdLocalidade;
      vBairro.nuCEP            := vEndJSON.get_string_or_null('nmBairro');
      vBairro.flInconsistente  := 'S';
      vBairro.flAnulado        := 'N';
      vBairro.dtAnulacao       := NULL;
      vBairro.nuCPFCadastrador := cnuCPFCadastrador;
      vBairro.dtInclusao       := vdtInclusao;
      vBairro.dtUltAlteracao   := SYSTIMESTAMP;

      SELECT NVL(MAX(cdBairro),0) + 1 INTO vBairro.cdBairro FROM ecadBairro;

      INSERT INTO ecadBairro VALUES vBairro;

      vEnd.cdBairro := vBairro.cdBairro;
      vEnd.flInconsistente  := 'S';
    END IF;

    SELECT MAX(cdTipoLogradouro) INTO vEnd.cdTipoLogradouro
    FROM ecadTipoLogradouro WHERE nmTipoLogradouro = vEndJSON.get_string_or_null('nmTipoLogradouro');

    vEnd.nuCEP               := vEndJSON.get_string_or_null('nuCEP');
    vEnd.nmLogradouro        := vEndJSON.get_string_or_null('nmLogradouro');
    vEnd.deComplLogradouro   := vEndJSON.get_string_or_null('deComplLogradouro');
    vEnd.nuNumero            := vEndJSON.get_string_or_null('nuNumero');
    vEnd.deComplemento       := vEndJSON.get_string_or_null('deComplemento');
    vEnd.nmUnidade           := vEndJSON.get_string_or_null('nmUnidade');
--    vEnd.flInconsistente     := NVL(vEndJSON.get_string_or_null('flInconsistente'), 'N');

    vEnd.nuCaixaPostal       := vEndJSON.get_string_or_null('nuCaixaPostal');
    vEnd.flTipoLogradouro    := vEndJSON.get_string_or_null('flTipoLogradouro');
    vEnd.flEnderecoExterior  := NVL(vEndJSON.get_string_or_null('flEnderecoExterior'), 'N');

    vEnd.dtInicio            := vdtInclusao;
    vEnd.nuCPFCadastrador    := cnuCPFCadastrador;
    vEnd.dtInclusao          := vdtInclusao;
    vEnd.dtUltAlteracao      := SYSTIMESTAMP;

    -- Incluir Endereco
    IF vEnd.nuCEP                     IS NOT NULL OR
       vEnd.cdLocalidade              IS NOT NULL OR
       vEnd.dtDocumento               IS NOT NULL OR
       vEnd.deObservacao              IS NOT NULL OR
       vEnd.nuNumeroAtoLegal          IS NOT NULL OR
       vEnd.nmArquivoDocumento        IS NOT NULL OR
       vEnd.deCaminhoArquivoDocumento IS NOT NULL THEN

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
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 'DOCUMENTO AMPARO FATO',
          'Documento de Amparo ao Fato (PKGMIG_ParametrizacaoConsignacoes.pIncluirDocumentoAmparoFato)', SQLERRM);
      RAISE;
  END pIncluirEndereco;

END PKGMIG_ParametrizacaoConsignacoes;
/
/*
WITH
ConsignatariaExistentes AS (
SELECT nuCodigoConsignataria FROM epagConsignataria
),
Consignataria AS (
SELECT DISTINCT
LPAD(js.nuCodigoConsignataria,3,0) AS nuCodigoConsignataria,
js.sgConsignataria
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.Consignataria' COLUMNS (
  nuCodigoConsignataria PATH '$.nuCodigoConsignataria',
  sgConsignataria       PATH '$.sgConsignataria'
)) js
LEFT JOIN ConsignatariaExistentes existe ON existe.nuCodigoConsignataria = js.nuCodigoConsignataria
WHERE existe.nuCodigoConsignataria IS NOT NULL
  AND parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '05/07/2025 19:06'
ORDER BY LPAD(js.nuCodigoConsignataria,3,0)
)
SELECT * FROM Consignataria
;
/

WITH
TipoServicoExistentes AS (
SELECT nmTipoServico FROM epagTipoServico
),
TipoServico AS (
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, parm.jsConteudo,
js.nmTipoServico
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao.TipoServico' COLUMNS (
  nmTipoServico PATH '$.nmTipoServico'
)) js
LEFT JOIN TipoServicoExistentes existe ON existe.nmTipoServico = js.nmTipoServico
WHERE existe.nmTipoServico IS NOT NULL
  AND parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '05/07/2025 19:06'
ORDER BY js.nmTipoServico
)
SELECT * FROM TipoServico
;
/
*/
