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
      (SELECT NVL(MAX(cdFormulaCalculo),0) + 1 FROM epagFormulaCalculo) AS cdFormulaCalculo,
      js.nuRubrica,
      js.deRubrica,
      js.dtInicioConcessao,
      js.dtFimConcessao,
      js.flGeridaTerceitos,
      js.flRepasse,
      js.nuCodigoConsignataria,
      js.sgConsignataria,
      js.nmTipoServico,
      js.nuContrato,

      SYSTIMESTAMP AS dtUltAlteracao,

      JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias,
      JSON_SERIALIZE(TO_CLOB(js.ContratoServico) RETURNING CLOB) AS ContratoServico

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
      LEFT JOIN ConsignacoesExistentes existe ON existe.nuRubrica = js.nuRubrica
      WHERE existe.nuRubrica IS NULL
      )
      SELECT * FROM Consignacao;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação da Consignação - ' ||
      vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);
	
    -- Loop principal de processamento para Incluir as Consignações não Existentes
    FOR r IN cDados LOOP

	  vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' || r.sgFormulaCalculo,1,70);

	  -- Inserir na tabela epagFormulaCalculo
	  SELECT NVL(MAX(cdFormulaCalculo), 0) + 1 INTO vcdFormulaCalculoNova FROM epagFormulaCalculo;

      INSERT INTO epagFormulaCalculo (
	      cdFormulaCalculo, cdRubricaAgrupamento, sgFormulaCalculo, deFormulaCalculo, dtUltAlteracao, cdAgrupamento, cdOrgao
      ) VALUES (
		    vcdFormulaCalculoNova, pcdRubricaAgrupamento, r.sgFormulaCalculo, r.deFormulaCalculo, r.dtUltAlteracao, r.cdAgrupamento, r.cdOrgao
      );

      PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'CONSIGNACAO', 'INCLUSAO',
        'Comnsignação incluída com sucesso',
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

      -- Importar Vigencias da Comnsignação
      pImportarVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
        psgModulo, psgConceito, vcdIdentificacao, vcdFormulaCalculoNova, r.Vigencias, pnuNivelAuditoria);
  
    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'CONSIGNACAO',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportar)', SQLERRM);
      RAISE;
  END pImportar;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências da Consignação do Documento Vigências JSON
  --     contido na tabela emigParametrizacao, realizando:
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
    vcdIdentificacao           VARCHAR2(70) := Null;
    vcdHistConsignacao         NUMBER := Null;
    vnuRegistros               NUMBER := 0;

    -- Cursor que extrai as Vigências da Consignação do Documento pVigenciasConsignacao JSON
    CURSOR cDados IS
      WITH
      VigenciasFormula as (
      SELECT
      (SELECT NVL(MAX(cdHistFormulaCalculo),0) + 1 FROM epagHistFormulaCalculo) AS cdHistFormulaCalculo,
      pcdFormulaVersao as cdFormulaVersao,
      
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,1,4)) END AS nuAnoInicio,
      CASE WHEN js.nuAnoMesInicioVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesInicioVigencia,5,2)) END AS nuMesInicio,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,1,4)) END AS nuAnoFim,
      CASE WHEN js.nuAnoMesFimVigencia IS NULL THEN NULL
        ELSE TO_NUMBER(SUBSTR(js.nuAnoMesFimVigencia,5,2)) END AS nuMesFim,
      
      NULL as cdDocumento,
      --JSON_OBJECT(
        js.nuAnoDocumento,
        tpdoc.cdTipoDocumento,
        CASE WHEN js.dtDocumento IS NULL THEN NULL
          ELSE TO_DATE(js.dtDocumento, 'YYYY-MM-DD') END AS dtDocumento,
        js.deObservacao,
        js.nuNumeroAtoLegal,
        js.nmArquivoDocumento,
        js.deCaminhoArquivoDocumento,
      --) AS cdDocumento,
      meiopub.cdMeioPublicacao,
      tppub.cdTipoPublicacao,
      CASE WHEN js.dtPublicacao IS NULL THEN NULL
        ELSE TO_DATE(js.dtPublicacao, 'YYYY-MM-DD') END AS dtPublicacao,
      js.nuPublicacao,
      js.nuPagInicial,
      js.deOutroMeio,
      
      '11111111111' AS nuCPFCadastrador,
      TRUNC(SYSDATE) AS dtInclusao,
      systimestamp AS dtUltAlteracao,
      
      JSON_SERIALIZE(TO_CLOB(js.ExpressaoFormula) RETURNING CLOB) AS ExpressaoFormula

      FROM JSON_TABLE(pVigenciasFormula, '$[*]' COLUMNS (
        nuAnoMesInicioVigencia      PATH '$.nuAnoMesInicioVigencia',
        nuAnoMesFimVigencia         PATH '$.nuAnoMesFimVigencia',
      
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
      
        ExpressaoFormula            CLOB FORMAT JSON PATH '$.Expressao'
      )) js
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.deTipoDocumento = js.deTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.nmMeioPublicacao = js.nmMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.nmTipoPublicacao = js.nmTipoPublicacao
      )
      SELECT * FROM VigenciasFormula;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ParametrizacaoLog.pAlertar('Importação da Consignação - ' ||
      'Vigências ' || vcdIdentificacao, cAUDITORIA_DETALHADO, pnuNivelAuditoria);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

       vcdIdentificacao := SUBSTR(pcdIdentificacao || ' ' ||
         lpad(r.nuAnoInicio,4,0) || lpad(r.nuMesInicio,2,0),1,70);
       
      -- Incluir Nova Vigência da Consignação
      SELECT NVL(MAX(cdHistFormulaCalculo), 0) + 1 INTO vcdHistFormulaCalculoNova FROM epagHistFormulaCalculo;

      INSERT INTO epagHistFormulaCalculo (
	    cdHistFormulaCalculo, cdFormulaVersao,
	    nuAnoInicio, nuMesInicio, nuCPFCadastrador, dtUltAlteracao, dtInclusao, nuAnoFim, nuMesFim,
	    cdDocumento, cdTipoPublicacao, nuPublicacao, dtPublicacao, nuPagInicial, cdMeioPublicacao, deObservacao
      ) VALUES (
        vcdHistFormulaCalculoNova, pcdFormulaVersao,
		r.nuAnoInicio, r.nuMesInicio, r.nuCPFCadastrador, r.dtUltAlteracao, r.dtInclusao, r.nuAnoFim, r.nuMesFim,
	    r.cdDocumento, r.cdTipoPublicacao, r.nuPublicacao, r.dtPublicacao, r.nuPagInicial, r.cdMeioPublicacao, r.deObservacao
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
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, 'CONSIGNACAO VIGENCIA',
          'Importação da Consignação (PKGMIG_ParametrizacaoConsignacoes.pImportarVigencias)', SQLERRM);
      RAISE;
  END pImportarVigencias;

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
