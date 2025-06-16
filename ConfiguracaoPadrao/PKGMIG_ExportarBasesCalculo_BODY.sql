CREATE OR REPLACE PACKAGE BODY PKGMIG_ExportarBasesCalculo AS
  PROCEDURE PExportar(
  -- ###########################################################################
  -- PROCEDURE: PExportar
  -- Objetivo:
  --   Exportar dados das Bases para a Configuração Padrão JSON
  --   realizando:
  --     - Inclusão do Documento JSON Base na tabela emigConfigracaoPadrao
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamento   IN VARCHAR2: Sigla do agrupamento de origem da configuração
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
    vsgConceito         VARCHAR2(20) := 'BASE';
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
    vtxResumo           VARCHAR2(4000) := NULL;

    vnuInseridos        NUMBER       := 0;
    vResumoEstatisticas CLOB         := Null;

    -- Cursor que extrai e transforma os dados JSON de Bases de Calculo
    vRefCursor SYS_REFCURSOR;

  BEGIN

    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Exportação das Parametrizações das ' ||
      'Bases de Calculo do Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
	  'Data da Exportação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI:SS'));

    -- Defini o Cursos com a Query que Gera o Documento JSON ValoresReferencia
    vRefCursor := fnCursorBases(psgAgrupamento, vsgOrgao, vsgModulo, vsgConceito,
      vdtOperacao, vnuVersao, vflAnulado);
    
    vnuInseridos := 0;
    
    -- Loop principal de processamento
    LOOP
      FETCH vRefCursor INTO vsgAgrupamento, vsgOrgao, vsgModulo, vsgConceito, vdtExportacao,
        vcdIdentificacao, vjsConteudo, vnuVersao, vflAnulado, vdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação da Base ' || vcdIdentificacao,
        cDEBUG_DESLIGADO, pnuDEBUG);

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
        'BASE', 'INCLUSAO', 'Documento JSON Bases incluído com sucesso',
		    cDEBUG_DESLIGADO, pnuDEBUG);

    END LOOP;
    CLOSE vRefCursor;

    COMMIT;

    -- Gerar as Estatísticas da Exportação das Bases de Calculo
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;
    vtxResumo := 'Agrupamento ' || psgAgrupamento || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Inicio da Exportação ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' || CHR(13) || CHR(10) ||
	    'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(TRUNC(EXTRACT(SECOND FROM vnuTempoExecucao)), 2, '0') || ', ' || CHR(13) || CHR(10) ||
	    'Total de Parametrizações de Bases de Calculo Exportadas: ' || vnuInseridos;

    -- Registro de Resumo da Exportação das Bases de Calculo
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(vsgAgrupamento, vsgOrgao, vtpOperacao, vdtExportacao,
      vsgModulo, vsgConceito, NULL, NULL,
      'BASE', 'RESUMO', 'Exportação das Parametrizações das Bases de Calculo do ' || vtxResumo, 
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Exportação das Parametrizações Bases de Calculo do ' ||
      vtxResumo, cDEBUG_DESLIGADO, pnuDEBUG);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação de Bases de Calculo ' || vcdIdentificacao ||
      ' BASE Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamento, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'BASE', 'ERRO', 'Erro: ' || SQLERRM, cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END PExportar;

  FUNCTION fnCursorBases(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP,
    pnuVersao IN CHAR, pflAnulado IN CHAR
    ) RETURN SYS_REFCURSOR IS

    vRefCursor SYS_REFCURSOR;

  BEGIN
    OPEN vRefCursor FOR
      --- Extrair os Conceito das Bases de um Agrupamento
      WITH
      EstruturaCarreira AS (
      SELECT e.cdAgrupamento, e.cdEstruturaCarreira,
        NVL2(nivel4.cdEstruturaCarreira, item4.deItemCarreira || '#', '') ||
        NVL2(nivel3.cdEstruturaCarreira, item3.deItemCarreira || '#', '') ||
        NVL2(nivel2.cdEstruturaCarreira, item2.deItemCarreira || '#', '') ||
        NVL2(nivel1.cdEstruturaCarreira, item1.deItemCarreira, item.deItemCarreira) ||
        CASE WHEN e.cdEstruturaCarreira IS NOT NULL THEN '#' || item.deItemCarreira ELSE '' END CarreiraCargo
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
      BlocoExpressaoRubricas AS (
      SELECT rubrica.cdBaseCalculoBlocoExpressao,
        JSON_ARRAYAGG(
          LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
      ORDER BY LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
        RETURNING CLOB) AS GrupoRubricas
      FROM epagBaseCalcBlocoExprRubAgrup rubrica
      INNER JOIN epagRubricaAgrupamento rubagrup ON rubagrup.cdRubricaAgrupamento = rubrica.cdRubricaAgrupamento
      INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrup.cdRubrica
      INNER JOIN epagTipoRubrica tprub ON tprub.cdTiporubrica = rub.cdTipoRubrica
      GROUP BY rubrica.cdBaseCalculoBlocoExpressao
      ),
      BlocoExpressao AS (
      SELECT blexp.cdBaseCalculoBlocoExpressao, blexp.cdBaseCalculoBloco, mneu.sgTipoMneumonico,
        JSON_OBJECT(
          'sgTipoMneumonico'      VALUE mneu.sgTipoMneumonico,
          'deOperacao'            VALUE blexp.deOperacao,
          'inTipoRubrica'         VALUE DECODE(blexp.inTipoRubrica,
                                          'I', 'Valor Integral',
                                          'P', 'Valor Pago',
                                          'R', 'Valor Real',
                                          blexp.inTipoRubrica),
          'inRelacaoRubrica'      VALUE DECODE(blexp.inRelacaoRubrica,
                                          'R', 'Relação de Trabalho',
                                          'S', 'Somatório',
                                          blexp.inRelacaoRubrica),
          'inMes'                 VALUE DECODE(blexp.inMes,
                                          'AT', 'Valor Referente ao Mês Atual',
                                          'AN', 'Valor Referente ao Mês Anterior',
                                          blexp.inMes),
          'nuMeses'               VALUE blexp.nuMeses,
          'nuValor'               VALUE blexp.nuValor,
          'inTipoRetorno'         VALUE blexp.inTipoRetorno,
          'inValorHoraMinuto'     VALUE blexp.inValorHoraMinuto,
          'nuRubrica'             VALUE
            CASE WHEN rub.nuRubrica IS NULL THEN NULL
            ELSE LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) END,
          'nuMesRubrica'          VALUE blexp.nuMesRubrica,
          'nuAnoRubrica'          VALUE blexp.nuAnoRubrica,
          'nmValorReferencia'     VALUE vlref.nmValorReferencia,
          'sgBaseCalculo'         VALUE baseexp.sgBaseCalculo,
          'sgTabelaValorGeralCEF' VALUE tabgeral.sgTabelaValorGeralCEF,
          'CarreiraCargo'         VALUE EstruturaCarreira.CarreiraCargo, 
          -- 'cdFuncaoChefia'     VALUE cdFuncaoChefia,
          'deNivel'               VALUE blexp.deNivel,
          'deReferencia'          VALUE blexp.deReferencia,
          'deCodigoCCO'           VALUE blexp.deCodigoCCO,
          -- 'cdtipoadicionaltempserv' VALUE cdtipoadicionaltempserv,
          'GrupoRubricas'         VALUE gruporub.GrupoRubricas
            --CASE WHEN JSON_EXISTS(gruporub.GrupoRubricas, '$.*') THEN NULL
            --ELSE gruporub.GrupoRubricas END
        ABSENT ON NULL RETURNING CLOB) AS expressao
      FROM epagBaseCalculoBlocoExpressao blexp
      INNER JOIN epagBaseCalculoBloco bloco ON bloco.cdBaseCalculoBloco = blexp.cdBaseCalculoBloco
      INNER JOIN epagHistBaseCalculo vigencia ON vigencia.cdHistBaseCalculo = bloco.cdHistBaseCalculo
      INNER JOIN epagBaseCalculoVersao versao ON  versao.cdVersaoBaseCalculo = vigencia.cdVersaoBaseCalculo
      INNER JOIN epagBaseCalculo base ON base.cdBaseCalculo = versao.cdBaseCalculo
      LEFT JOIN epagTipoMneumonico mneu ON mneu.cdTipoMneumonico = blexp.cdTipoMneumonico
      LEFT JOIN BlocoExpressaoRubricas gruporub ON gruporub.cdBaseCalculoBlocoExpressao = blexp.cdBaseCalculoBlocoExpressao
      LEFT JOIN epagValorReferencia vlref ON vlref.cdAgrupamento = base.cdAgrupamento AND vlref.cdValorReferencia = blexp.cdValorReferencia
      LEFT JOIN epagBaseCalculo baseexp ON baseexp.cdAgrupamento = base.cdAgrupamento AND baseexp.cdBaseCalculo = blexp.cdBaseCalculo
      LEFT JOIN epagValorGeralCEFAgrup tabgeral ON tabgeral.cdAgrupamento = base.cdAgrupamento AND tabgeral.cdValorGeralCEFAgrup = blexp.cdValorGeralCEFAgrup
      LEFT JOIN EstruturaCarreira ON EstruturaCarreira.cdAgrupamento = base.cdAgrupamento AND EstruturaCarreira.cdEstruturaCarreira = blexp.cdEstruturaCarreira
      LEFT JOIN epagRubricaAgrupamento rubagrup ON rubagrup.cdRubricaAgrupamento = blexp.cdRubricaAgrupamento
      LEFT JOIN epagRubrica rub ON rub.cdRubrica = rubagrup.cdRubrica
      LEFT JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
      ),
      Blocos AS (
      SELECT bl.cdHistBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'sgBloco'               VALUE bl.sgBloco,
          'Expressao'             VALUE blexp.Expressao
        RETURNING CLOB) ORDER BY bl.sgBloco RETURNING CLOB) AS Blocos
      FROM epagBaseCalculoBloco bl
      LEFT JOIN BlocoExpressao blexp ON blexp.cdBaseCalculoBloco = bl.cdBaseCalculoBloco
      GROUP BY bl.cdHistBaseCalculo
      ),
      Vigencias AS (
      SELECT vigencia.cdVersaoBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'Vigencia' VALUE JSON_OBJECT(
            'nuAnoMesInicioVigencia' VALUE vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0),
            'nuAnoMesFimVigencia'    VALUE vigencia.nuAnoFimVigencia || LPAD(vigencia.nuMesFimVigencia,2,0),
            'Expressao' VALUE JSON_OBJECT(
              'deFormula'            VALUE vigencia.deFormula,
              'deExpressaoCalculo'   VALUE vigencia.deExpressaoCalculo,
              'Blocos'               VALUE bl.Blocos,
              'Limites' VALUE
                CASE WHEN 
                  vigencia.deLimiteInferior IS NULL AND vigencia.deLimiteSuperior IS NULL AND
                  vigencia.cdValorReferenciaInferior IS NULL AND vigencia.nuQtdeValReferenciaInferior IS NULL AND
                  vigencia.cdValorReferenciaSuperior IS NULL AND vigencia.nuQtdeValReferenciaSuperior IS NULL
                  THEN NULL
                ELSE JSON_OBJECT(
                  'deLimiteInferior'            VALUE vigencia.deLimiteInferior,
                  'deLimiteSuperior'            VALUE vigencia.deLimiteSuperior,
                  'sgValorReferenciaInferior'   VALUE vlrefinf.sgValorReferencia,
                  'nuQtdeValReferenciaInferior' VALUE vigencia.nuQtdeValReferenciaInferior,
                  'sgValorReferenciaSuperior'   VALUE vlrefsup.sgValorReferencia,
                  'nuQtdeValReferenciaSuperior' VALUE vigencia.nuQtdeValReferenciaSuperior
              ABSENT ON NULL) END,
              'Documento' VALUE
                CASE WHEN doc.nuAnoDocumento IS NULL AND vigencia.cdTipoPublicacao IS NULL AND
                  doc.dtDocumento IS NULL AND doc.nuNumeroAtoLegal IS NULL AND doc.deObservacao IS NULL AND
                  vigencia.cdMeioPublicacao IS NULL AND vigencia.cdTipoPublicacao IS NULL AND
                  vigencia.dtPublicacao IS NULL AND vigencia.nuPublicacao IS NULL AND vigencia.nuPagInicial IS NULL AND
                  vigencia.deOutroMeio IS NULL AND doc.nmArquivoDocumento IS NULL AND doc.deCaminhoArquivoDocumento IS NULL
                  THEN NULL
                ELSE JSON_OBJECT(
                  'nuAnoDocumento'              VALUE doc.nuAnoDocumento,
                  'deTipoDocumento'             VALUE tpdoc.deTipoDocumento,
                  'dtDocumento'                 VALUE doc.dtDocumento,
                  'nuNumeroAtoLegal'            VALUE doc.nuNumeroAtoLegal,
                  'deObservacao'                VALUE doc.deObservacao,
                  'nmMeioPublicacao'            VALUE meiopub.nmMeioPublicacao,
                  'nmTipoPublicacao'            VALUE tppub.nmTipoPublicacao,
                  'dtPublicacao'                VALUE vigencia.dtPublicacao,
                  'nuPublicacao'                VALUE vigencia.nuPublicacao,
                  'nuPagInicial'                VALUE vigencia.nuPagInicial,
                  'deOutroMeio'                 VALUE vigencia.deOutroMeio,
                  'nmArquivoDocumento'          VALUE doc.nmArquivoDocumento,
                  'deCaminhoArquivoDocumento'   VALUE doc.deCaminhoArquivoDocumento
                  ABSENT ON NULL) END
            ABSENT ON NULL RETURNING CLOB) 
          ABSENT ON NULL RETURNING CLOB)
        ABSENT ON NULL RETURNING CLOB)
        ORDER BY vigencia.nuAnoInicioVigencia || LPAD(vigencia.nuMesInicioVigencia,2,0) desc RETURNING CLOB) AS Vigencias
      FROM epagHistBaseCalculo vigencia
      INNER JOIN epagBaseCalculoVersao versao ON  versao.cdVersaoBaseCalculo = vigencia.cdVersaoBaseCalculo
      INNER JOIN epagBaseCalculo base ON base.cdBaseCalculo = versao.cdBaseCalculo
      LEFT JOIN epagValorReferencia vlrefinf ON vlrefinf.cdAgrupamento = base.cdAgrupamento AND vlrefinf.cdValorReferencia = vigencia.cdValorReferenciaInferior
      LEFT JOIN epagValorReferencia vlrefsup ON vlrefsup.cdAgrupamento = base.cdAgrupamento AND vlrefsup.cdValorReferencia = vigencia.cdValorReferenciaSuperior
      LEFT JOIN Blocos bl ON bl.cdHistBaseCalculo = vigencia.cdHistBaseCalculo
      LEFT JOIN eatoDocumento doc ON doc.cdDocumento = vigencia.cdDocumento
      LEFT JOIN eatoTipoDocumento tpdoc ON tpdoc.cdTipoDocumento = doc.cdTipoDocumento
      LEFT JOIN ecadMeioPublicacao meiopub ON meiopub.cdMeioPublicacao = vigencia.cdMeioPublicacao
      LEFT JOIN ecadTipoPublicacao tppub ON tppub.cdTipoPublicacao = vigencia.cdTipoPublicacao
      GROUP BY vigencia.cdVersaoBaseCalculo
      ),
      Versoes AS (
      SELECT versao.cdBaseCalculo,
        JSON_ARRAYAGG(JSON_OBJECT(
          'nuVersao' VALUE LPAD(versao.nuVersao,2,0),
          'Vigencias' VALUE Vigencias.Vigencias
        ABSENT ON NULL RETURNING CLOB)
      ORDER BY versao.nuVersao RETURNING CLOB) AS Versoes
      FROM epagBaseCalculoVersao versao
      LEFT JOIN Vigencias ON Vigencias.cdVersaoBaseCalculo = versao.cdVersaoBaseCalculo
      GROUP BY versao.cdBaseCalculo
      ),
      Bases AS (
      SELECT a.sgAgrupamento, o.sgOrgao, base.sgBaseCalculo,
      JSON_OBJECT(
        'PAG' value JSON_OBJECT(
          'Base' value JSON_OBJECT(
            'sgBaseCalculo' VALUE base.sgBaseCalculo,
            'nmBaseCalculo' VALUE base.nmBaseCalculo,
            'Versoes' VALUE Versoes.Versoes
          ABSENT ON NULL RETURNING CLOB)
        RETURNING CLOB) RETURNING CLOB) AS Base
      FROM epagBaseCalculo base
      LEFT JOIN Versoes ON Versoes.cdBaseCalculo = base.cdBaseCalculo
      INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = base.cdAgrupamento
      LEFT JOIN ecadHistOrgao o ON o.cdOrgao = base.cdOrgao
      WHERE a.sgAgrupamento = psgAgrupamento
      )
      SELECT
        sgAgrupamento,
        psgOrgao AS sgOrgao,
        psgModulo AS sgModulo,
        psgConceito AS sgConceito,
        pdtExportacao AS dtExportacao,
        sgBaseCalculo AS cdIdentificacao,
        Base AS jsConteudo,
        pnuVersao AS nuVersao,
    	pflAnulado AS flAnulado,
    	SYSTIMESTAMP AS dtInclusao
      FROM Bases
      ORDER BY sgagrupamento, sgorgao, sgModulo, sgConceito, cdIdentificacao;
    
      RETURN vRefCursor;
  END fnCursorBases;

END PKGMIG_ExportarBasesCalculo;
/
