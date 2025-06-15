--- Pacote de Exportação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ExportarRubricas AS
  -- ###########################################################################
  -- PACOTE: PKGMIG_ExportarRubricas
  --   Importar dados das Formulas de Calculo a partir da Configuração Padrão JSON
  -- 
  -- Rubrica => epagRubrica
  --  └── TiposRubricas => epagRubrica
  --          └── RubricaAgrupamento => epagRubricaAgrupamento
  --               └── Evento => epagEventoPagAgrup
  --                    └── VigenciaEvento => epagHistEventoPagAgrup
  --                         └── GrupoCarreiraEvento => epagHistEventoPagAgrupCarreira
  --                         └── GrupoOrgaoEvento => epagEventoPagAgrupOrgao
  --
  -- PROCEDURE:
  --   PExportar
  --   fnCursorBases
  --
  -- ###########################################################################
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE PExportar(psgAgrupamento IN VARCHAR2);
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2) RETURN SYS_REFCURSOR;
END PKGMIG_ExportarRubricas;
/

-- Corpo do pacote
CREATE OR REPLACE PACKAGE BODY PKGMIG_ExportarRubricas AS
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;

  PROCEDURE PExportar(psgAgrupamento IN VARCHAR2) IS
    -- Variáveis de controle e contexto
    vsgAgrupamento   VARCHAR2(15);
    vsgOrgao         VARCHAR2(15);
    vsgModulo        CHAR(3)      := 'PAG';
    vsgConceito      VARCHAR2(20) := 'RUBRICA';
    vdtExportacao    TIMESTAMP    := LOCALTIMESTAMP;
    vcdIdentificacao VARCHAR2(20);
    vjsConteudo      CLOB;
	vnuVersao        CHAR(3) := '1.0';
	vflAnulado       CHAR(1) := 'N';
    vdtInclusao      TIMESTAMP(6);

    rsgAgrupamento   VARCHAR2(15) := NULL;
    rsgOrgao         VARCHAR2(15) := NULL;
    rsgModulo        CHAR(3)      := NULL;
    rsgConceito      VARCHAR2(20) := NULL;
    rdtExportacao    TIMESTAMP    := NULL;
    rcdIdentificacao VARCHAR2(20) := NULL;
    rjsConteudo      CLOB         := NULL;
	rnuVersao        CHAR(3)      := NULL;
	rflAnulado       CHAR(1)      := NULL;
    rdtInclusao      TIMESTAMP(6) := NULL;

    vtpOperacao      VARCHAR2(15) := 'EXPORTACAO';
    vdtTermino       TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExcusao  INTERVAL DAY TO SECOND := NULL;
    vnuRegistros     NUMBER       := 0;

    -- Referencia para o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas
    vRefCursor SYS_REFCURSOR;

  BEGIN

    vdtExportacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Exportação das Configurações das Rubricas do Agrupamento ' || psgAgrupamento ||
	', Data da Exportação ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI'));

	vnuRegistros := 0;
    vRefCursor := fnCursorRubricas(psgAgrupamento);

    -- Loop principal de processamento
	LOOP
      FETCH vRefCursor INTO rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, rdtExportacao,
	  rcdIdentificacao, rjsConteudo, rnuVersao, rflAnulado, rdtInclusao;
      EXIT WHEN vRefCursor%NOTFOUND;

      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Rubrica ' || vcdIdentificacao);

      INSERT INTO emigConfiguracaoPadrao (
        sgAgrupamento, sgOrgao, sgModulo, sgConceito, --dtExportacao,
		cdIdentificacao, jsConteudo, dtInclusao, nuVersao, flAnulado
      ) VALUES (
        rsgAgrupamento, rsgOrgao, rsgModulo, rsgConceito, --rdtExportacao,
		rcdIdentificacao, rjsConteudo, rdtInclusao, rnuVersao, rflAnulado
      );

	  vnuRegistros := vnuRegistros + 1;
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(vsgAgrupamento, vsgOrgao, vtpOperacao, vdtExportacao, 
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'RUBRICA', 'INCLUSAO', 'Configurações da Rubrica incluidas com sucesso',
        cDEBUG_DESLIGADO, pnuDEBUG);

    END LOOP;

    CLOSE vRefCursor;

    -- Gerar as Estatísticas da Importação das Rubricas
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExcusao := vdtTermino - vdtExportacao;

    -- Registro de Resumo da Exportação das Rubricas
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(vsgAgrupamento, vsgOrgao, vtpOperacao, vdtExportacao,
      psgModulo, psgConceito, NULL, NULL,
      'RUBRICA', 'RESUMO', 
	  'Exportação das Configurações das Rubricas do ' ||
      'Agrupamento ' || psgAgrupamento ||
      'Data e Hora da Inicio da Exportação ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' ||
	  'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(SECOND FROM vnuTempoExecucao), 2, '0') || ', ' ||
	  'Total de Configurações de Rubricas Exportadas: ' || vnuRegistros,
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Exportação das Configurações das Rubricas do ' ||
      'Agrupamento ' || psgAgrupamento ||
      'Data e Hora da Inicio da Exportação ' || TO_CHAR(vdtExportacao, 'DD/MM/YYYY HH24:MI:SS')  || ', ' ||
      'Data e Hora da Termino da Exportação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI:SS')  || ', ' ||
	  'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(SECOND FROM vnuTempoExecucao), 2, '0') || ', ' ||
	  'Total de Configurações de Rubricas Exportadas: ' || vnuRegistros,
      cDEBUG_DESLIGADO, pnuDEBUG);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Exportação da Rubrica ' || vcdIdentificacao || ' RUBRICA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'RUBRICA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END PExportar;

  -- Função que cria o Cursor que Estrutura o Documento JSON com as parametrizações das Rubricas
  FUNCTION fnCursorRubricas(psgAgrupamento IN VARCHAR2) RETURN SYS_REFCURSOR IS
    vRefCursor SYS_REFCURSOR;
  BEGIN
    OPEN vRefCursor FOR
    
      --- Extrair os Conceito de Rubricas de Eventos de Pagamento com Os Eventos e AS suas formulas de Cálculo de um Agrupamento
      WITH
      --- Informações referente as lista de Órgãos, Rubricas e Carreiras e Cargos
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
      SELECT LPAD(tpr.nuTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0) AS nuRubrica,
        tpr.deTipoRubrica || ' ' || vg.deRubricaAgrupResumida as deRubrica,
        ra.cdAgrupamento, ra.cdRubricaAgrupamento
      FROM epagRubrica r
      INNER JOIN epagTipoRubrica tpr ON tpr.cdtiporubrica = r.cdtiporubrica
      INNER JOIN epagRubricaAgrupamento ra ON ra.cdrubrica = r.cdrubrica
      INNER JOIN (
        SELECT deRubricaAgrupResumida, nuAnoMesInicioVigencia, nuAnoMesFimVigencia, cdRubricaAgrupamento, cdHistRubricaAgrupamento
        FROM (SELECT deRubricaAgrupResumida,
          LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
          CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
          ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
          cdRubricaAgrupamento, cdHistRubricaAgrupamento,
          RANK() OVER (PARTITION BY cdRubricaAgrupamento
                       ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
                           CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
                           ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
                           END DESC nulls FIRST) AS nuOrder
          FROM epagHistRubricaAgrupamento
        ) WHERE nuOrder = 1
      ) vg ON vg.cdRubricaAgrupamento = ra.cdRubricaAgrupamento
      ),
      -- EstruturaCarreiraLista: lista da Estrutura de Carreira e Cargos
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
          JSON_ARRAYAGG(nuRubrica || ' - ' || deRubrica ORDER BY nuRubrica RETURNING CLOB) AS GrupoRubricas
        FROM epagFormCalcBlocoExpRubAgrup gprub
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = vigencia.cdRubricaAgrupamento
        GROUP BY gprub.cdFormulaCalcBlocoExpressao
      ),
      -- BlocoExpressao: expressões individuais por tipo e ordem
      BlocoExpressao AS (
        SELECT blexp.cdFormulaCalcBlocoExpressao, blexp.cdFormulaCalculoBloco, tipoMneumonico.sgTipoMneumonico,
          JSON_OBJECT(
            'sgTipoMneumonico'        VALUE tipoMneumonico.sgTipoMneumonico,
            'deOperacao'              VALUE blexp.deOperacao,
            'inTipoRubrica'           VALUE blexp.inTipoRubrica,
            'inRelacaoRubrica'        VALUE blexp.inRelacaoRubrica,
            'inMes'                   VALUE blexp.inMes,
            'nuMeses'                 VALUE blexp.nuMeses,
            'nuValor'                 VALUE blexp.nuValor,
            'flValorHoraMinuto'       VALUE NULLIF(blexp.flValorHoraMinuto, 'N'),
            'nuRubrica'               VALUE rub.nuRubrica,
            'nuMesRubrica'            VALUE blexp.nuMesRubrica,
            'nuAnoRubrica'            VALUE blexp.nuAnoRubrica,
            'nmValorReferencia'       VALUE vlRef.nmValorReferencia,
            'sgBaseCalculo'           VALUE base.sgBaseCalculo,
            'sgTabelaValorGeralCef'   VALUE tabGeral.sgTabelaValorGeralCef,
            'carreiraCargo'           VALUE carreiraLst.CarreiraCargo,
            'cdFuncaoChefia'          VALUE blexp.cdFuncaoChefia,
            'deNivel'                 VALUE blexp.deNivel,
            'deReferencia'            VALUE blexp.deReferencia,
            'deCodigoCco'             VALUE blexp.deCodigoCco,
            'cdTipoAdicionalTempServ' VALUE blexp.cdTipoAdicionalTempServ,
            'GrupoRubricas'           VALUE CASE WHEN JSON_EXISTS(grupoRub.GrupoRubricas, '$.*') THEN NULL
                                            ELSE grupoRub.GrupoRubricas END
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
        LEFT JOIN EstruturaCarreiraLista cef ON cef.cdAgrupamento = formula.cdAgrupamento
              AND carreiraLst.cdEstruturaCarreira = blexp.cdEstruturaCarreira
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
            'cdEstruturaCarreira'       VALUE expressao.cdEstruturaCarreira,
            'cdUnidadeOrganizacional'   VALUE expressao.cdUnidadeOrganizacional,
            'cdCargoComissionado'       VALUE expressao.cdCargoComissionado,
            'Blocos'                    VALUE blocos.Blocos,
            'FormulaEspecifica'         VALUE
              CASE WHEN expressao.cdFormulaEspecifica IS NULL AND expressao.deFormulaEspecifica IS NULL 
                    AND expressao.nuFormulaEspecifica IS NULL
                    THEN NULL
              ELSE JSON_OBJECT(
                'cdFormulaEspecifica'   VALUE expressao.cdFormulaEspecifica,
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
                'cdValorRefLimInfParcial'      VALUE expressao.cdValorRefLimInfParcial,
                'cdValorRefLimSupParcial'      VALUE expressao.cdValorRefLimSupParcial,
                'cdValorRefLimInfFinal'        VALUE expressao.cdValorRefLimInfFinal,
                'cdValorRefLimSupFinal'        VALUE expressao.cdValorRefLimSupFinal,
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
        LEFT JOIN BlocosFormula blocos ON blocos.cdExpressaoFormCalc = expressao.cdExpressaoFormCalc
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
      
      -- 📌 Formula: definição da fórmula com versões embutidas
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
          JSON_ARRAYAGG(carreira.CarreiraCargo ORDER BY carreira.CarreiraCargo RETURNING CLOB) AS Carreiras
        FROM epagHistEventoPagAgrupCarreira grupoCarreira
        INNER JOIN EstruturaCarreiraLista carreira ON carreira.cdEstruturaCarreira = grupoCarreira.cdEstruturaCarreira
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
          JS_ARRAYAGG(JSON_OBJECT(
            'nuAnoMesInicioVigencia'        VALUE vigencia.nuAnoRefInicial || LPAD(vigencia.nuMesRefInicial, 2, '0'),
            'nuAnoMesFimVigencia'           VALUE vigencia.nuAnoRefFinal || LPAD(vigencia.nuMesRefFinal, 2, '0'),
            'deDesconto'                    VALUE vigencia.deDesconto,
            'nuRubrica'                     VALUE rub.nuRubrica,
            'MesPagamento'                  VALUE
      		CASE WHEN vigencia.nuMesPagamento    IS NULL AND vigencia.nuMesPagamentoInicio IS NULL
      		      AND vigencia.nuMesPagamentoFim IS NULL
      		THEN NULL
              ELSE JSON_OBJECT(
                'nuMesPagamento'            VALUE vigencia.nuMesPagamento,
                'nuMesPagamentoInicio'      VALUE vigencia.nuMesPagamentoInicio,
                'nuMesPagamentoFim'         VALUE vigencia.nuMesPagamentoFim
              ABSENT ON NULL) END,
            'cdRelacaoTrabalho'             VALUE vigencia.cdRelacaoTrabalho,
            'Orgaos'                        VALUE
      		CASE WHEN NULLIF(vigencia.flAbrangeTodosOrgaos, 'N') IS NULL AND orgao.Orgaos IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'flAbrangeTodosOrgaos'      VALUE NULLIF(vigencia.flAbrangeTodosOrgaos, 'N'),
                'orgaos'                    VALUE orgao.Orgaos
              ABSENT ON NULL) END,
            'Carreiras'                     VALUE
      		CASE WHEN vigencia.inAcaoCarreira IS NULL AND carreira.Carreiras IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'inAcaoCarreira'            VALUE vigencia.inAcaoCarreira,
                'carreiras'                 VALUE carreira.Carreiras
              ABSENT ON NULL) END,
            'FormulaCalculo'                VALUE
      		CASE WHEN NULLIF(vigencia.flUtilizaFormulaCalculo, 'N') IS NULL AND vigencia.nuFormulaEspecifica IS NULL
      		      THEN NULL
              ELSE JSON_OBJECT(
                'flUtilizaFormulaCalculo'   VALUE NULLIF(vigencia.flUtilizaFormulaCalculo, 'N'),
                'nuFormulaEspecifica'       VALUE vigencia.nuFormulaEspecifica
              ABSENT ON NULL) END,
            'ConquistaPerAquis'             VALUE
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
        LEFT JOIN GrupoCarreiraEvento carreira ON carreira.cdHistEventoPagAgrup = vigencia.cdHistEventoPagAgrup
        LEFT JOIN GrupoOrgaoEvento orgao ON orgao.cdHistEventoPagAgrup = vigencia.cdHistEventoPagAgrup
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = vigencia.cdRubricaAgrupamento
        GROUP BY vigencia.cdEventoPagAgrup, vigencia.cdRubricaAgrupamento
      ),
      -- Evento: eventos de pagamento vinculados à rubrica
      Evento AS (
        SELECT evento.cdAgrupamento, evento.cdRubricaAgrupamento,
          JSON_OBJECT(
            'nmTipoEventoPagamento'         VALUE UPPER(tpEvento.nmTipoEventoPagamento),
            'deEvento'                      VALUE evento.deEvento,
            'nuRubrica'                     VALUE rub.nuRubrica,
            'cdRubAgrupOpRecebCCO'          VALUE rubCCO.nuRubrica,
            'cdRubricaAgrupAlternativa2'    VALUE rubAlt2.nuRubrica,
            'cdRubricaAgrupAlternativa3'    VALUE rubAlt3.nuRubrica,
            'Vigencias'                     VALUE vigencia.Vigencias
          ABSENT ON NULL RETURNING CLOB) AS Evento
        FROM epagEventoPagAgrup evento
        INNER JOIN epagTipoEventoPagamento tpEvento ON tpEvento.cdTipoEventoPagamento = evento.cdTipoEventoPagamento
        LEFT JOIN VigenciaEvento vigencia ON vigencia.cdEventoPagAgrup = evento.cdEventoPagAgrup
        LEFT JOIN RubricaLista rub ON rub.cdRubricaAgrupamento = evento.cdRubricaAgrupamento
        LEFT JOIN RubricaLista rubCCO ON rubCCO.cdRubricaAgrupamento = evento.cdRubAgrupOpRecebCCO
        LEFT JOIN RubricaLista rubAlt2 ON rubAlt2.cdRubricaAgrupamento = evento.cdRubricaAgrupAlternativa2
        LEFT JOIN RubricaLista rubAlt3 ON rubAlt3.cdRubricaAgrupamento = evento.cdRubricaAgrupAlternativa3
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
            'Inventario' VALUE JSON_OBJECT(
              'deRubricaAgrupamento'        VALUE vigencia.deRubricaAgrupamento,
              'deRubricaAgrupResumida'      VALUE vigencia.deRubricaAgrupResumida,
              'deRubricaAgrupDetalhada'     VALUE vigencia.deRubricaAgrupDetalhada,
              'deFormula'                   VALUE vigencia.deFormula,
              'deModulo'                    VALUE vigencia.deModulo,
              'deComposicao'                VALUE vigencia.deComposicao,
              'deVantagensNaoAcumulaveis'   VALUE vigencia.deVantagensNaoAcumulaveis,
              'deObservacao'                VALUE vigencia.deObservacao
            ABSENT ON NULL),
            'ParametrosVigencia' VALUE JSON_OBJECT(
              'cdRelacaoTrabalho'           VALUE vigencia.cdRelacaoTrabalho,
              'cdRubProporcionalidadeCHO'   VALUE vigencia.cdRubProporcionalidadeCHO,
              'cdOutraRubrica'              VALUE vigencia.cdOutraRubrica,
              'nuCargaHorariaSemanal'       VALUE vigencia.nuCargaHorariaSemanal,
              'nuMesesApuracao'             VALUE vigencia.nuMesesApuracao,
              'inLancPropRelVinc'           VALUE vigencia.inLancPropRelVinc,
              'inGeraRubricaCarreira'       VALUE vigencia.inGeraRubricaCarreira,
              'inGeraRubricaNivel'          VALUE vigencia.inGeraRubricaNivel,
              'inGeraRubricaUO'             VALUE vigencia.inGeraRubricaUO,
              'inGeraRubricaCCO'            VALUE vigencia.inGeraRubricaCCO,
              'inGeraRubricaFUC'            VALUE vigencia.inGeraRubricaFUC,
              'inAposentadoriaServidor'     VALUE vigencia.inAposentadoriaServidor,
              'inGeraRubricaAfastTemp'      VALUE vigencia.inGeraRubricaAfastTemp,
              'inImpedimentoRubrica'        VALUE vigencia.inImpedimentoRubrica,
              'inRubricasExigidas'          VALUE vigencia.inRubricasExigidas,
              'flPropMesComercial'          VALUE NULLIF(vigencia.flPropMesComercial, 'N'),
              'flPropAposParidade'          VALUE NULLIF(vigencia.flPropAposParidade, 'N'),
              'flPropServRelVinc'           VALUE NULLIF(vigencia.flPropServRelVinc, 'N'),
              'inPossuiValorInformado'      VALUE NULLIF(vigencia.inPossuiValorInformado, 'N'),
              'flPermiteAfastAcidente'      VALUE NULLIF(vigencia.flPermiteAfastAcidente, 'N'),
              'flBloqLancFinanc'            VALUE NULLIF(vigencia.flBloqLancFinanc, 'N'),
              'flCargaHorariaPadrao'        VALUE NULLIF(vigencia.flCargaHorariaPadrao, 'N'),
              'flAplicaRubricaOrgaos'       VALUE NULLIF(vigencia.flAplicaRubricaOrgaos, 'N'),
              'flGestaoSobreRubrica'        VALUE NULLIF(vigencia.flGestaoSobreRubrica, 'N'),
              'flGeraRubricaEscala'         VALUE NULLIF(vigencia.flGeraRubricaEscala, 'N'),
              'flGeraRubricaHoraExtra'      VALUE NULLIF(vigencia.flGeraRubricaHoraExtra, 'N'),
              'flGeraRubricaServCCO'        VALUE NULLIF(vigencia.flGeraRubricaServCCO, 'N'),
              'flLaudoAcompanhamento'       VALUE NULLIF(vigencia.flLaudoAcompanhamento, 'N'),
              'flPermiteFGFTG'              VALUE NULLIF(vigencia.flPermiteFGFTG, 'N'),
              'flPermiteApoOriginadoCCO'    VALUE NULLIF(vigencia.flPermiteApoOriginadoCCO, 'N'),
              'flPagaSubstituicao'          VALUE NULLIF(vigencia.flPagaSubstituicao, 'N'),
              'flPagaRespondendo'           VALUE NULLIF(vigencia.flPagaRespondendo, 'N'),
              'flConsolidaRubrica'          VALUE NULLIF(vigencia.flConsolidaRubrica, 'N'),
              'flPropAfastTempNaoRemun'     VALUE NULLIF(vigencia.flPropAfastTempNaoRemun, 'N'),
              'flPropAfAFGFTG'              VALUE NULLIF(vigencia.flPropAfAFGFTG, 'N'),
              'flCargaHorariaLimitada'      VALUE NULLIF(vigencia.flCargaHorariaLimitada, 'N'),
              'flIncidParcialContrPrev'     VALUE NULLIF(vigencia.flIncidParcialContrPrev, 'N'),
              'flPropAfComissionado'        VALUE NULLIF(vigencia.flPropAfComissionado, 'N'),
              'flPropAfComOpcPercCEF'       VALUE NULLIF(vigencia.flPropAfComOpcPercCEF, 'N'),
              'flPreservaValorIntegral'     VALUE NULLIF(vigencia.flPreservaValorIntegral, 'N')
            ABSENT ON NULL),
            'Abrangencias' VALUE JSON_OBJECT(
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
        GROUP BY vigencia.cdRubricaAgrupamento
      ),
      -- RubricaAgrupamento: estrutura completa da Rubrica no Agrupamento
      RubricaAgrupamento AS (
      SELECT rubagrup.cdRubrica, rubagrup.cdRubricaAgrupamento,
        a.sgAgrupamento,
        o.sgOrgao,
        JSON_OBJECT(
          'RubricaPropria'                  VALUE
      	  CASE WHEN rubagrup.flIncorporacao != 'S'       AND rubagrup.flPensaoAlimenticia != 'S'
      	        AND rubagrup.flAdiant13Pensao != 'S'     AND rubagrup.fl13SalPensao != 'S'
      			AND rubagrup.flConsignacao != 'S'        AND rubagrup.flTributacao != 'S'
      			AND rubagrup.flSalarioFamilia != 'S'     AND rubagrup.flSalarioMaternidade != 'S'
      			AND rubagrup.flDevTributacaoIprev != 'S' AND rubagrup.flDevCorrecaoMonetaria != 'S'
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
            'flDevTributacaoIprev'          VALUE NULLIF(rubagrup.flDevTributacaoIprev, 'N'),
            'flDevCorrecaoMonetaria'        VALUE NULLIF(rubagrup.flDevCorrecaoMonetaria, 'N'),
            'flAbonoPermanencia'            VALUE NULLIF(rubagrup.flAbonoPermanencia, 'N'),
            'flApostilamento'               VALUE NULLIF(rubagrup.flApostilamento, 'N'),
            'flContribuicaoSindical'        VALUE NULLIF(rubagrup.flContribuicaoSindical, 'N')
          ABSENT ON NULL) END,
          'ParametrosAgrupamento'           VALUE JSON_OBJECT(
            'nmModalidadeRubrica'           VALUE modrub.nmModalidadeRubrica,
            'sgBaseCalculo'                 VALUE basecalc.sgBaseCalculo,
            'flVisivelServidor'             VALUE NULLIF(rubagrup.flVisivelServidor, 'N'),
            'flGeraSuplementar'             VALUE NULLIF(rubagrup.flGeraSuplementar, 'N'),
            'flConsAd'                      VALUE NULLIF(rubagrup.flConsAd, 'N'),
            'flCompoe13'                    VALUE NULLIF(rubagrup.flCompoe13, 'N'),
            'flPropria13'                   VALUE NULLIF(rubagrup.flPropria13, 'N'),
            'flEmpenhadaFilial'             VALUE NULLIF(rubagrup.flEmpenhadaFilial, 'N'),
            'nuElemDespesaAtivo'            VALUE rubagrup.nuElemDespesaAtivo,
            'nuElemDespesaInativo'          VALUE rubagrup.nuElemDespesaInativo,
            'nuElemDespesaAtivoClt'         VALUE rubagrup.nuElemDespesaAtivoClt,
            'nuOrdemConsAd'                 VALUE rubagrup.nuOrdemConsAd
          ABSENT ON NULL),
          'VigenciasAgrupamento'            VALUE vigencia.VigenciasAgrupamento,
          'Evento'                          VALUE evento.Evento,
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
      	    CASE WHEN rub.nuElemDespesaAtivo       IS NULL AND rub.nuElemDespesaRegGeral   IS NULL
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
          JSON_VALUE(vigencia.VigenciasTipo, '$[0].derubrica') AS deRubrica
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
        WHERE tprub.sgAgrupamento = pSgAgrupamento
        GROUP BY tprub.sgAgrupamento, tprub.sgOrgao, rub.nuNaturezaRubrica, rub.nuRubrica, rub.nmNaturezaRubrica, rub.deRubrica
      )
      SELECT 
        sgAgrupamento,
        sgOrgao,
        vsgModulo AS sgModulo,
        vsgConceito AS sgConceito,
        vdtExportacao AS dtExportacao,
        nunaturezarubrica || '-' || nurubrica AS cdIdentificacao,
        Rubrica AS jsConteudo,
		vnuVersao AS nuVersao,
		vflAnulado AS flAnulado,
		SYSTIMESTAMP AS dtInclusao
      FROM TiposRubricas
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao, cdIdentificacao;

    RETURN vRefCursor;
  END emigfnCursorRubricas;

END pkgemigExportarRubricas;
/
