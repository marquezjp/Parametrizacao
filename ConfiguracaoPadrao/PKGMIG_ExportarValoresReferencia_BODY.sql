-- Corpo do Pacote de Exportação das Parametrizações de Valores de Referencia
CREATE OR REPLACE PACKAGE BODY PKGMIG_ExportarValoresReferencia AS
  PROCEDURE pExportar(
  -- ###########################################################################
  -- PROCEDURE: pExportar
  -- Objetivo:
  --   Exportar as Parametrizações de Valores de Referencia para a Configuração Padrão JSON
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
    vsgOrgao            VARCHAR2(15) := NULL;
    vsgModulo           CHAR(3)      := 'PAG';
    vsgConceito         VARCHAR2(20) := 'VALORREFERENCIA';
    vtpOperacao         VARCHAR2(15) := 'EXPORTACAO';
    vdtOperacao         TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao    VARCHAR2(20) := NULL;
    vnuVersao           CHAR(04)     := '1.00';
    vflAnulado          CHAR(01)     := 'N';

    rsgAgrupamento      VARCHAR2(15) := NULL;
    rsgOrgao            VARCHAR2(15) := NULL;
    rsgModulo           CHAR(3)      := NULL;
    rsgConceito         VARCHAR2(20) := NULL;
    rdtExportacao       TIMESTAMP(6) := NULL;
    rcdIdentificacao    VARCHAR2(20) := NULL;
    rjsConteudo         CLOB         := NULL;
    rnuVersao           CHAR(04)     := NULL;
    rflAnulado          CHAR(01)     := NULL;
    rdtInclusao         TIMESTAMP(6) := NULL;

    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;
    vnuRegistros        NUMBER       := 0;
    vtxResumo           VARCHAR2(4000) := NULL;

    -- Cursor que extrai e transforma os dados JSON de Valores de Referencia
    vRefCursor SYS_REFCURSOR;

  BEGIN
  
    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Exportações das Parametrizações dos ' ||
      'Valores de Referencia do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	    'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
      cDEBUG_DESLIGADO, pnuDEBUG);

    IF cDEBUG_DESLIGADO != pnuDEBUG THEN
        PKGMIG_ConfiguracaoPadrao.PConsoleLog('Nível de Debug Habilitado ' ||
          CASE pnuDEBUG
            WHEN cDEBUG_NIVEL_0    THEN 'DEBUG NIVEL 0'
            WHEN cDEBUG_NIVEL_1    THEN 'DEBUG NIVEL 1'
            WHEN cDEBUG_NIVEL_2    THEN 'DEBUG NIVEL 2'
            WHEN cDEBUG_NIVEL_3    THEN 'DEBUG NIVEL 3'
            WHEN cDEBUG_DESLIGADO  THEN 'DESLIGADO'
            ELSE 'DESLIGADO'
          END, cDEBUG_DESLIGADO, pnuDEBUG);
    END IF;

	  -- Defini o Cursos com a Query que Gera o Documento JSON ValoresReferencia
	  vRefCursor := fnCursorValoresReferencia(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito,
      vdtOperacao, vnuVersao, vflAnulado);

	  vnuRegistros := 0;

	  -- Loop principal de processamento
	LOOP
      FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
	    rcdIdentificacao, rjsConteudo,
        rnuVersao,
        rflAnulado, rdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      vcdIdentificacao := rcdIdentificacao;
      
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação do Valor de Referencia ' || vcdIdentificacao,
        cDEBUG_DESLIGADO, pnuDEBUG);

      INSERT INTO emigConfiguracaoPadrao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao,
        cdIdentificacao, jsConteudo, nuVersao, flAnulado
      ) VALUES (
        rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
		rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado
      );

      vnuRegistros := vnuRegistros + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao, 
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'INCLUSAO', 'Documento JSON ValoresReferencia incluído com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

    END LOOP;

    CLOSE vRefCursor;

    COMMIT;

    -- Gerar as Estatísticas da Exportação dos Valores de Referencia
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 'Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	    'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	    'Total de Parametrizações dos Valores de Referencia Exportadas: ' || vnuRegistros;

    -- Registro de Resumo da Exportação dos Valores de Referencia
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'VALORES REFERENCIA', 'RESUMO', 'Exportação das Parametrizações dos Valores de Referencia do ' || vtxResumo, 
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Exportação das Parametrizações dos Valores de Referencia do ' ||
      vtxResumo, cDEBUG_DESLIGADO, pnuDEBUG);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação de Valores de Referencia ' || vcdIdentificacao ||
      ' VALORES REFERENCIA Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'VALORES REFERENCIA', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pExportar;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as Parametrizações dos Valores de Referencia
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
            'inTipoReferencia'      VALUE DECODE(vigencia.inTipoReferencia,
                                            'V', 'Valor', 'I', 'Índice', 
                                            vigencia.inTipoReferencia)
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
        vlref.ValorReferencia AS jsConteudo,
		pnuVersao AS nuVersao,
		pflAnulado AS flAnulado,
		SYSTIMESTAMP AS dtInclusao
      FROM ValorReferencia vlref
      ORDER BY sgagrupamento, sgorgao, sgModulo, sgConceito, cdIdentificacao;

    RETURN vRefCursor;
  END fnCursorValoresReferencia;

END PKGMIG_ExportarValoresReferencia;
/
