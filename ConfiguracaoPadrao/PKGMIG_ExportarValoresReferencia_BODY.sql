-- Corpo do Pacote de Importação das Parametrizações de Valores de Referencia
CREATE OR REPLACE PACKAGE BODY PKGMIG_ExportarValoresReferencia AS
  PROCEDURE pExportar(
  -- ###########################################################################
  -- PROCEDURE: emigPImportarRubricas
  -- Objetivo:
  --   Exportar dados de Valores de Referencia para a Configuração Padrão JSON
  --   realizando:
  --     - Inclusão do Documento JSON ValoresReferecia na tabela emigConfigracaoPadrao
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   pnuDEBUG              IN NUMBER DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'DEBUG NIVEL 0' omite todas as mensagens;
  --                         - Se informado 'DEBUG NIVEL 1' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DEBUG NIVEL 2' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamento        IN VARCHAR2,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgAgrupamento      VARCHAR2(15) := Null;
    vsgOrgao            VARCHAR2(15) := Null;
    vsgModulo           CHAR(3)      := 'PAG';
    vsgConceito         VARCHAR2(20) := 'VALORREFERENCIA';
    vdtExportacao       TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20) := Null;
    vjsConteudo         CLOB         := Null;
    vnuVersao           CHAR(04)     := '1.00';
    vflAnulado          CHAR(01)     := 'N';
    vdtInclusao         TIMESTAMP    := NULL;

    vtpOperacao         VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP    := LOCALTIMESTAMP;
    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;

    vnuInseridos        NUMBER       := 0;
    vResumoEstatisticas CLOB         := Null;

    -- Cursor que extrai e transforma os dados JSON de Rubricas e Tipos de Rubricas
    vRefCursor SYS_REFCURSOR;

  BEGIN
  
    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Exportações Valores de Referencia do Agrupamento ' || psgAgrupamento);

	-- Defini o Cursos com a Query que Gera o Documento JSON ValoresReferencia
	vRefCursor := fnCursorValoresReferencia(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito,
      vdtOperacao, vnuVersao, vflAnulado);
    
	-- Loop principal de processamento
	LOOP
      FETCH vRefCursor INTO vsgAgrupamento, vsgOrgao, vsgModulo, vsgConceito, vdtExportacao,
        vcdIdentificacao, vjsConteudo, vnuVersao, vflAnulado, vdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação do Valor de Referencia ' || vcdIdentificacao);

      INSERT INTO emigConfiguracaoPadrao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
        cdIdentificacao, jsConteudo, nuVersao, flAnulado
      ) VALUES (
        vsgAgrupamento, vsgOrgao, vsgModulo, vsgConceito, vdtExportacao,
        vcdIdentificacao, vjsConteudo, vnuVersao, vflAnulado
      );

      vnuInseridos := vnuInseridos + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'INCLUSAO', 'Documento JSON ValoresReferencia incluidos com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

    END LOOP;
    CLOSE vRefCursor;


    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
      vsgModulo, vsgConceito, NULL, 1,
      'VALORES REFERENCIA', 'RESUMO', 'Valores de Referencia incluidos: ' || vnuInseridos,
      cDEBUG_DESLIGADO, pnuDEBUG);

    COMMIT;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Resumo da Exportações Valores de Referencia do Agrupamento: ' ||
	  'Valores de Referencia incluidos: ' || vnuInseridos);
	
	PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Exportações Valores de Referencia do Agrupamento ' || psgAgrupamento);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação de Valores de Referencia ' || vcdIdentificacao || ' VALORES REFERENCIA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pExportar;

  FUNCTION fnCursorValoresReferencia(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR
    ) RETURN SYS_REFCURSOR IS

    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito de Valores de Referencia de um Agrupamento
      WITH
      VigenciasValorReferencia AS (
      SELECT vigencia.cdValorReferenciaVersao,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuAnoMesInicioVigencia'  VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0),
          'nuAnoMesFimVigencia'     VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia,2,0),
          'Valor'                   VALUE
            CASE WHEN vigencia.vlReferencia IS NULL AND vigencia.qtValorReferencia IS NULL
                  AND vigencia.nuPercentual IS NULL AND vigencia.inTipoReferencia  IS NULL
                 THEN NULL
            ELSE JSON_OBJECT(
            'vlReferencia'          VALUE vigencia.vlReferencia,
            'qtValorReferencia'     VALUE vigencia.qtValorReferencia,
            'nuPercentual'          VALUE vigencia.nuPercentual,
            'inTipoReferencia'      VALUE DECODE(vigencia.inTipoReferencia, 'V', 'Valor', 'I', 'Índice', NULL)
          ABSENT ON NULL) END,
          'TabelaGeral'             VALUE
            CASE WHEN vigencia.cdValorGeralCEFAgrup IS NULL AND vigencia.nuNivel IS NULL AND vigencia.nuReferencia IS NULL
                 THEN NULL
            ELSE JSON_OBJECT(
            'sgTabelaValorGeralCEF' VALUE tabgeral.sgTabelaValorGeralCEF,
            'nuNivel'               VALUE vigencia.nuNivel,
            'nuReferencia'          VALUE vigencia.nuReferencia
          ABSENT ON NULL) END
        ABSENT ON NULL) ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0) DESC RETURNING CLOB
      ) AS Vigencias
      FROM epagHistValorReferencia vigencia
      INNER JOIN epagValorReferenciaVersao versao ON versao.cdValorReferenciaVersao = vigencia.cdValorReferenciaVersao
      INNER JOIN epagValorReferencia vlref ON vlref.cdValorReferencia = versao.cdValorReferencia
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = vlref.cdAgrupamento
                                               AND tabgeral.cdValorGeralCEFAgrup = vigencia.cdValorGeralCEFAgrup
      GROUP BY vigencia.cdValorReferenciaVersao
      ),
      VersaoValorReferencia AS (
      SELECT versao.cdValorReferencia,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuVersao'                VALUE versao.nuVersao,
          'Vigencias'               VALUE vigencia.Vigencias
        ABSENT ON NULL RETURNING CLOB)
        ORDER BY to_number(versao.nuVersao) RETURNING CLOB) AS Versoes
      FROM epagValorReferenciaVersao versao
      LEFT JOIN VigenciasValorReferencia vigencia ON vigencia.cdValorReferenciaVersao = versao.cdValorReferenciaVersao
      GROUP BY versao.cdValorReferencia
      ),
      ValorReferencia AS (
      SELECT a.sgAgrupamento, vlref.sgValorReferencia,
        JSON_OBJECT(
          'PAG' VALUE JSON_OBJECT(
            'ValorReferencia' VALUE JSON_OBJECT(
              'sgValorReferencia'          VALUE vlref.sgValorReferencia,
              'nmValorReferencia'          VALUE vlref.nmValorReferencia,
              'Parametrizacao'             VALUE
                CASE WHEN NULLIF(vlref.flValeTransporte, 'N')      IS NULL AND NULLIF(vlref.flCorrecaoMonetaria, 'N')      IS NULL
                      AND NULLIF(vlref.flBloqueioRemuneracao, 'N') IS NULL AND NULLIF(vlref.flPermiteValorRetroativo, 'N') IS NULL
                      AND NULLIF(vlref.flTetoAuxilioFuneral, 'N')  IS NULL
                      THEN NULL
                ELSE JSON_OBJECT(
                'flValeTransporte'         VALUE NULLIF(vlref.flValeTransporte, 'N'),
                'flCorrecaoMonetaria'      VALUE NULLIF(vlref.flCorrecaoMonetaria, 'N'),
                'flBloqueioRemuneracao'    VALUE NULLIF(vlref.flBloqueioRemuneracao, 'N'),
                'flPermiteValorRetroativo' VALUE NULLIF(vlref.flPermiteValorRetroativo, 'N'),
                'flTetoAuxilioFuneral'     VALUE NULLIF(vlref.flTetoAuxilioFuneral, 'N')
              ABSENT ON NULL RETURNING CLOB) END,
              'Versoes'                    VALUE versao.Versoes
            ABSENT ON NULL RETURNING CLOB) ABSENT ON NULL RETURNING CLOB)
        ABSENT ON NULL RETURNING CLOB) AS ValorReferencia
      FROM epagValorReferencia vlref
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = vlref.cdAgrupamento
      LEFT JOIN VersaoValorReferencia versao ON versao.cdValorReferencia = vlref.cdValorreferencia
	  WHERE a.sgAgrupamento = psgAgrupamento
      )
      SELECT 
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        sgValorReferencia AS cdIdentificacao,
        ValorReferencia AS jsConteudo,
		pnuVersao AS nuVersao,
		pflAnulado AS flAnulado,
		SYSTIMESTAMP AS dtInclusao
      FROM ValorReferencia
      ORDER BY sgagrupamento, sgorgao, sgModulo, sgConceito, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorValoresReferencia;

END PKGMIG_ExportarValoresReferencia;
/
