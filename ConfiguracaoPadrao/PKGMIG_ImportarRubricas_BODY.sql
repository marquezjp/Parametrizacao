-- Corpo do Pacote de Importação das Parametrizações de Rubricas
CREATE OR REPLACE PACKAGE BODY PKGMIG_ImportarRubricas AS

  PROCEDURE pImportar(
  -- ###########################################################################
  -- PROCEDURE: pImportar
  -- Objetivo:
  --   Importar dados de rubricas a partir da Configuração Padrão JSON
  --   contida na tabela emigConfiguracaoPadrao, realizando:
  --     - Inclusão ou atualização de registros na tabela epagRubrica
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica e Rubricas do Agrupamentos
  --     - Registro de Logs de Auditoria por evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem  IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino IN VARCHAR2: Sigla do agrupamento de destino para os dados
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
    psgAgrupamentoOrigem  IN VARCHAR2,
    psgAgrupamentoDestino IN VARCHAR2,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vsgOrgao            VARCHAR2(15) := NULL;
    vsgModulo           CHAR(3)      := 'PAG';
    vsgConceito         VARCHAR2(20) := 'RUBRICA';

    vtpOperacao         VARCHAR2(15) := 'IMPORTACAO';
    vdtOperacao         TIMESTAMP    := LOCALTIMESTAMP;
    vdtTermino          TIMESTAMP    := LOCALTIMESTAMP;
    vnuTempoExecucao    INTERVAL DAY TO SECOND := NULL;

    vcdIdentificacao    VARCHAR2(50) := NULL;
    vcdRubricaNova      NUMBER       := NULL;

    vnuRegistros        NUMBER       := 0;
    
    -- Cursor que extrai e transforma os dados JSON de Rubricas e Tipos de Rubricas
    CURSOR cDados IS
      WITH epagRubricaImportar AS (
        SELECT 
          cfg.cdIdentificacao,
          rub.cdrubrica,
          js.nurubrica,
          tprub.cdtiporubrica,
          js.innaturezatce,
          js.nuunidadeorcamentaria,
          js.nusubacao,
          js.nufonterecurso,
          js.nucnpjoutrocredor,
          js.nuelemdespesaativo,
          js.nuelemdespesareggeral,
          js.nuelemdespesainativo,
          js.nuelemdespesaativoclt,
          js.nuelemdespesapensaoesp,
          js.nuelemdespesactisp,
          js.nuelemdespesaativo13,
          js.nuelemdespesareggeral13,
          js.nuelemdespesainativo13,
          js.nuelemdespesaativoclt13,
          js.nuelemdespesapensaoesp13,
          js.nuelemdespesactisp13,
          cgt.cdconsignataria,
          js.nuoutraconsignataria,
          NVL(js.flextraorcamentaria, 'N') AS flextraorcamentaria,
          js.VigenciasTipo,
          js.GruposRubrica,
          js.Agrupamento
        FROM emigConfiguracaoPadrao cfg
        CROSS APPLY JSON_TABLE(cfg.jsConteudo, '$.PAG.Rubrica' COLUMNS (
          nunaturezarubrica            PATH '$.nunaturezarubrica',
          nurubrica                    PATH '$.nurubrica',
          NESTED PATH '$.Tipos[*]' COLUMNS (
            nutiporubrica              PATH '$.nutiporubrica',
            innaturezatce              PATH '$.Empenho.innaturezatce',
            nuunidadeorcamentaria      PATH '$.Empenho.nuunidadeorcamentaria',
            nusubacao                  PATH '$.Empenho.nusubacao',
            nufonterecurso             PATH '$.Empenho.nufonterecurso',
            nucnpjoutrocredor          PATH '$.Empenho.nucnpjoutrocredor',
            nuelemdespesaativo         PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesaativo',
            nuelemdespesareggeral      PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesareggeral',
            nuelemdespesainativo       PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesainativo',
            nuelemdespesaativoclt      PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesaativoclt',
            nuelemdespesapensaoesp     PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesapensaoesp',
            nuelemdespesactisp         PATH '$.Empenho.ElementosDespesas.FolhaMensal.nuelemdespesactisp',
            nuelemdespesaativo13       PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesaativo13',
            nuelemdespesareggeral13    PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesareggeral13',
            nuelemdespesainativo13     PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesainativo13',
            nuelemdespesaativoclt13    PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesaativoclt13',
            nuelemdespesapensaoesp13   PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesapensaoesp13',
            nuelemdespesactisp13       PATH '$.Empenho.ElementosDespesas.Folha13Salario.nuelemdespesactisp13',
            nucodigoconsignataria      PATH '$.Empenho.Consignacao.nucodigoconsignataria',
            nuoutraconsignataria       PATH '$.Empenho.Consignacao.nuoutraconsignataria',
            flextraorcamentaria        PATH '$.Empenho.Consignacao.flextraorcamentaria',
            VigenciasTipo              CLOB FORMAT JSON PATH '$.VigenciasTipo',
            GruposRubrica              CLOB FORMAT JSON PATH '$.GruposRubrica',
            Agrupamento                CLOB FORMAT JSON PATH '$.Agrupamento'
          )
        )) js
        LEFT JOIN epagTipoRubrica tprub ON tprub.nutiporubrica = js.nutiporubrica
        LEFT JOIN epagRubrica rub ON rub.cdtiporubrica = tprub.cdtiporubrica AND rub.nurubrica = js.nurubrica
        LEFT JOIN epagConsignataria cgt ON cgt.nucodigoconsignataria = js.nucodigoconsignataria
        WHERE cfg.sgModulo = vsgModulo AND cfg.sgConceito = vsgConceito AND cfg.flAnulado = 'N'
          AND cfg.sgAgrupamento = pSgAgrupamentoOrigem AND cfg.sgOrgao IS NULL
      )
      SELECT * FROM epagRubricaImportar;
      
  BEGIN
    
    vdtOperacao := LOCALTIMESTAMP;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Inicio da Importação das Configurações do Agrupamento ' || psgAgrupamentoOrigem ||
      ' para o Agrupamento ' || psgAgrupamentoDestino || ', Data da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI'));

    -- Loop principal de processamento
    FOR r IN cDados LOOP
  
      vcdIdentificacao := r.cdIdentificacao || ' ' || LPAD(r.cdTipoRubrica,2,0) || '-' || LPAD(r.nuRubrica,4,0);
  
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Rubrica ' || vcdIdentificacao);

      IF r.cdrubrica IS NULL THEN
        -- Incluir Nova Rubrica
        SELECT NVL(MAX(cdrubrica), 0) + 1 INTO vcdRubricaNova FROM epagRubrica;
/*  
        INSERT INTO epagRubrica (
          cdrubrica, cdtiporubrica, nurubrica,
          nuelemdespesaativo, nuelemdespesainativo, cdconsignataria, nuoutraconsignataria, 
          flextraorcamentaria, nusubacao, nufonterecurso, nucnpjoutrocredor,
          nuunidadeorcamentaria, nuelemdespesaativoclt, nuelemdespesapensaoesp, 
          nuelemdespesaativo13, nuelemdespesainativo13, nuelemdespesaativoclt13,
          nuelemdespesapensaoesp13, nuelemdespesareggeral, nuelemdespesareggeral13, 
          nuelemdespesactisp, nuelemdespesactisp13, innaturezatce
        ) VALUES (
          vcdRubricaNova, r.cdtiporubrica, r.nurubrica,
          r.nuelemdespesaativo, r.nuelemdespesainativo, r.cdconsignataria, 
          r.nuoutraconsignataria, r.flextraorcamentaria, r.nusubacao, 
          r.nufonterecurso, r.nucnpjoutrocredor, r.nuunidadeorcamentaria, 
          r.nuelemdespesaativoclt, r.nuelemdespesapensaoesp, r.nuelemdespesaativo13, 
          r.nuelemdespesainativo13, r.nuelemdespesaativoclt13, r.nuelemdespesapensaoesp13, 
          r.nuelemdespesareggeral, r.nuelemdespesareggeral13, r.nuelemdespesactisp, 
          r.nuelemdespesactisp13, r.innaturezatce
        );
*/
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'RUBRICA', 'INCLUSAO', 'Rubrica incluidas com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      ELSE
        -- Atualizar Rubrica Existente
        vcdRubricaNova := r.cdrubrica;
/*  
        UPDATE epagRubrica SET
          cdtiporubrica = r.cdtiporubrica,
          nurubrica = r.nurubrica,
          nuelemdespesaativo = r.nuelemdespesaativo,
          nuelemdespesainativo = r.nuelemdespesainativo,
          cdconsignataria = r.cdconsignataria,
          nuoutraconsignataria = r.nuoutraconsignataria,
          flextraorcamentaria = r.flextraorcamentaria,
          nusubacao = r.nusubacao,
          nufonterecurso = r.nufonterecurso,
          nucnpjoutrocredor = r.nucnpjoutrocredor,
          nuunidadeorcamentaria = r.nuunidadeorcamentaria,
          nuelemdespesaativoclt = r.nuelemdespesaativoclt,
          nuelemdespesapensaoesp = r.nuelemdespesapensaoesp,
          nuelemdespesaativo13 = r.nuelemdespesaativo13,
          nuelemdespesainativo13 = r.nuelemdespesainativo13,
          nuelemdespesaativoclt13 = r.nuelemdespesaativoclt13,
          nuelemdespesapensaoesp13 = r.nuelemdespesapensaoesp13,
          nuelemdespesareggeral = r.nuelemdespesareggeral,
          nuelemdespesareggeral13 = r.nuelemdespesareggeral13,
          nuelemdespesactisp = r.nuelemdespesactisp,
          nuelemdespesactisp13 = r.nuelemdespesactisp13,
          innaturezatce = r.innaturezatce      
        WHERE cdrubrica = vcdRubricaNova;
*/
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao, 
          vsgModulo, vsgConceito, vcdIdentificacao, 1,
          'RUBRICA', 'ATUALIZACAO', 'Rubrica atualizada com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      END IF;

      -- Excluir Grupo de Rubricas da Rubrica
	  SELECT COUNT(*) INTO vnuRegistros FROM epagGrupoRubricaPagamento WHERE cdRubrica = vcdRubricaNova;

	  IF vnuRegistros > 0 THEN
/*
	    DELETE FROM epagGrupoRubricaPagamento WHERE epagGrupoRubricaPagamento = vcdRubricaNova;
*/  
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
          vsgModulo, vsgConceito, vcdIdentificacao, vnuRegistros,
          'RUBRICA GRUPO DE RUBRICA', 'EXCLUSAO', 'Grupo de Rubrica excluidas com sucesso',
          cDEBUG_NIVEL_2, pnuDEBUG);
      END IF;

/*  
      -- Incluir Grupo de Rubricas na Rubrica
	  vnuRegistros := 0;
      FOR grrub IN (
        SELECT d.cdgruporubrica
          FROM json_table(r.GruposRubrica, '$[*]' COLUMNS (item VARCHAR2(100) PATH '$')) js
          LEFT JOIN epaggruporubrica d ON UPPER(d.nmgruporubrica) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaggruporubricapagamento (cdrubrica, cdgruporubrica)
        VALUES (vcdRubricaNova, grrub.cdgruporubrica);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;
*/
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, vnuRegistros,
        'RUBRICA GRUPO DE RUBRICA', 'INCLUSAO', 'Grupo de Rubrica incluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
  
      -- Importar Vigências da Rubrica
--      pImportarVigencias(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
--        vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, r.VigenciasTipo, pnuDEBUG);
  
      -- Importar Rubricas do Agrupamento
      pImportarAgrupamento(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
        vsgModulo, vsgConceito, vcdIdentificacao, vcdRubricaNova, r.Agrupamento, pnuDEBUG);
  
    END LOOP;
    
    -- Atualizar a SEQUENCE das Tabela Envolvidas na importação das Rubricas
    PAtuializarSequence(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito);

    -- Gerar as Estatísticas da Importação das Rubricas
    vdtTermino := LOCALTIMESTAMP;
    vnuTempoExecucao := vdtTermino - vdtOperacao;

    pImportarResumo(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,
      vsgModulo, vsgConceito, vdtTermino, vnuTempoExecucao);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Termino da Importação das Configurações do ' ||
      'Agrupamento ' || psgAgrupamentoOrigem || ' para o ' ||
      'Agrupamento ' || psgAgrupamentoDestino || ', ' ||
      'Data e Hora da Inicio da Operação ' || TO_CHAR(vdtOperacao, 'DD/MM/YYYY HH24:MI')  || ', ' ||
      'Data e Hora da Termino da Operação ' || TO_CHAR(vdtTermino, 'DD/MM/YYYY HH24:MI')  || ', ' ||
	  'Tempo de Execução ' ||
	    LPAD(EXTRACT(HOUR FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(MINUTE FROM vnuTempoExecucao), 2, '0') || ':' ||
	    LPAD(EXTRACT(SECOND FROM vnuTempoExecucao), 2, '0') || '.'
    );

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Rubrica ' || vcdIdentificacao || ' RUBRICA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, vsgOrgao, vtpOperacao, vdtOperacao,  
        vsgModulo, vsgConceito, vcdIdentificacao, 1,
        'RUBRICA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportar;

  PROCEDURE pImportarVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarVigencias
  -- Objetivo:
  --   Importar dados das Vigências das Rubricas do Documento Agrupamento JSON
  --     contido na tabela emigConfiguracaoPadrao, realizando:
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
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
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
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao VARCHAR2(50) := Null;
    vnuRegistros     NUMBER := 0;
  
    -- Cursor que extrai as Vigências da Rubrica do Documento VigenciasTipo JSON
    CURSOR cDados IS
      WITH
      epagHistRubricaImportar AS (
      SELECT 
        (SELECT NVL(MAX(cdhistrubrica),0) FROM epaghistrubrica) + ROWNUM AS cdhistrubrica,
        pcdRubrica as cdrubrica,
        js.derubrica,
    
        CASE WHEN js.nuanomesiniciovigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesiniciovigencia,1,4)) END AS nuanoiniciovigencia, -- <= js.nuanomesiniciovigencia
        CASE WHEN js.nuanomesiniciovigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesiniciovigencia,5,2)) END AS numesiniciovigencia, -- <= js.nuanomesiniciovigencia
        CASE WHEN js.nuanomesfimvigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesfimvigencia,1,4)) END AS nuanofimvigencia, -- <= js.nuanomesfimvigencia
        CASE WHEN js.nuanomesfimvigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesfimvigencia,5,2)) END AS numesfimvigencia, -- <= js.nuanomesfimvigencia
        
        '11111111111' AS nucpfcadastrador,
        TRUNC(SYSDATE) AS dtinclusao,
        systimestamp AS dtultalteracao,
      
        NULL AS cddocumento,
        json_object(
          js.nuanodocumento,
          tpdoc.cdtipodocumento,
          js.dtdocumento,
          js.deobservacao,
          js.nunumeroatolegal,
          js.nmarquivodocumento,
          js.decaminhoarquivodocumento
        ) AS Documento,
        meiopub.cdmeiopublicacao,
        tppub.cdtipopublicacao,
        TO_DATE(js.dtpublicacao, 'yyyy-mm-dd') AS dtpublicacao,
        js.nupublicacao,
        js.nupaginicial,
        js.deoutromeio
      
      FROM JSON_TABLE(JSON_QUERY(pVigenciasTipo, '$'), '$[*]' COLUMNS (
        nuanomesiniciovigencia    PATH '$.nuanomesiniciovigencia',
        nuanomesfimvigencia       PATH '$.nuanomesfimvigencia',
        derubrica                 PATH '$.derubrica',
        
        cddocumento               PATH '$.Documento.cddocumento',
        nuanodocumento            PATH '$.Documento.nuanodocumento',
        detipodocumento           PATH '$.Documento.detipodocumento',
        dtdocumento               PATH '$.Documento.dtdocumento',
        nunumeroatolegal          PATH '$.Documento.nunumeroatolegal',
        deobservacao              PATH '$.Documento.deobservacao',
        nmmeiopublicacao          PATH '$.Documento.nmmeiopublicacao',
        nmtipopublicacao          PATH '$.Documento.nmtipopublicacao',
        dtpublicacao              PATH '$.Documento.dtpublicacao',
        nupublicacao              PATH '$.Documento.nupublicacao',
        nupaginicial              PATH '$.Documento.nupaginicial',
        deoutromeio               PATH '$.Documento.deoutromeio',
        nmarquivodocumento        PATH '$.Documento.nmarquivodocumento',
        decaminhoarquivodocumento PATH '$.Documento.decaminhoarquivodocumento'
      )) js
      LEFT JOIN eatotipodocumento tpdoc ON tpdoc.detipodocumento = js.detipodocumento
      LEFT JOIN ecadmeiopublicacao meiopub ON meiopub.nmmeiopublicacao = js.nmmeiopublicacao
      LEFT JOIN ecadtipopublicacao tppub ON tppub.nmtipopublicacao = js.nmtipopublicacao
      ORDER BY cdrubrica, nuanomesiniciovigencia, nuanomesfimvigencia
      )
      SELECT * FROM epagHistRubricaImportar;

  BEGIN

      vcdIdentificacao := pcdIdentificacao;
      
      --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Vigências da Rubrica ' || pcdIdentificacao);

      -- Excluir Grupo de Rubricas da Rubrica
	  SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubrica WHERE cdRubrica = pcdRubrica;

	  IF vnuRegistros > 0 THEN
/*
        DELETE FROM epagHistRubrica
          WHERE cdRubrica = pcdRubrica;
*/    
        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
          'RUBRICA VIGENCIA', 'EXCLUSAO', 'Vigência da Rubrica excluidas com sucesso',
          cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;
  
    -- Loop principal de processamento para Incluir a Vigências da Rubrica
    FOR r IN cDados LOOP
	
	  vcdIdentificacao := pcdIdentificacao || ' ' || LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0);
/*    
      -- Inserir na tabela epagHistRubrica
      INSERT INTO epaghistrubrica (
        cdhistrubrica, cdrubrica, derubrica, nuanoiniciovigencia, numesiniciovigencia, nuanofimvigencia, numesfimvigencia,
        nucpfcadastrador, dtinclusao, dtultalteracao, 
        cddocumento, cdmeiopublicacao, cdtipopublicacao, dtpublicacao, nupublicacao, nupaginicial, deoutromeio
      ) VALUES (
        r.cdhistrubrica, r.cdrubrica, r.derubrica, r.nuanoiniciovigencia, r.numesiniciovigencia, r.nuanofimvigencia, r.numesfimvigencia,
        r.nucpfcadastrador, r.dtinclusao, r.dtultalteracao,
        r.cddocumento, r.cdmeiopublicacao, r.cdtipopublicacao, r.dtpublicacao, r.nupublicacao, r.nupaginicial, r.deoutromeio
      );
*/  
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica incluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Vigência da Rubrica ' || vcdIdentificacao || ' RUBRICA VIGENCIA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarVigencias;

  PROCEDURE pImportarAgrupamento(
  -- ###########################################################################
  -- PROCEDURE: pImportarAgrupamento
  -- Objetivo:
  --   Importar dados das Rubricas do Agrupamento Origem para o Agrupamento Destino
  --     do Documento Agrupamento JSON contido na tabela emigConfiguracaoPadrao,
  --     realizando:
  --     - Inclusão ou atualização de Rubricas do Agrupamento na
  --       tabela epagRubricaAgrupamento
  --     - Atualização de Grupos de Rubricas (epagGrupoRubricaPagamento)
  --     - Importação das Vigências da Rubrica
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
  --   pAgrupamento          IN CLOB: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
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
    pAgrupamento          IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao          VARCHAR2(50) := Null;
    vcdRubricaAgrupamentoNova NUMBER := Null;
    vnuRegistros              NUMBER := 0;

    -- Cursor que extrai do as Rubricas do Agrupamento Origem para o Agrupamento Destino do Documento pAgrupamento JSON
    CURSOR cDados IS
      WITH
      Orgao AS (
      SELECT g.sggrupoagrupamento, UPPER(p.nmpoder) AS nmpoder, a.sgagrupamento, vgcorg.sgorgao,
      vgcorg.dtiniciovigencia, vgcorg.dtfimvigencia,
      UPPER(tporgao.nmtipoorgao) AS nmtipoorgao,
      o.cdagrupamento, o.cdorgao, vgcorg.cdhistorgao, vgcorg.cdtipoorgao
      FROM ecadagrupamento a
      INNER JOIN ecadpoder p ON p.cdpoder = a.cdpoder
      INNER JOIN ecadgrupoagrupamento g ON g.cdgrupoagrupamento = a.cdgrupoagrupamento
      INNER JOIN ecadorgao o ON o.cdagrupamento = a.cdagrupamento
      INNER JOIN (
        SELECT sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao FROM (
          SELECT sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao, 
          RANK() OVER (PARTITION BY cdorgao ORDER BY dtiniciovigencia DESC, dtfimvigencia DESC nulls FIRST) AS nuorder
          FROM ecadhistorgao WHERE flanulado = 'N'
        ) WHERE nuorder = 1
      ) vgcorg ON vgcorg.cdorgao = o.cdorgao
      LEFT JOIN ecadtipoorgao tporgao ON tporgao.cdtipoorgao = vgcorg.cdtipoorgao
      UNION
      SELECT g.sggrupoagrupamento, UPPER(p.nmpoder) AS nmpoder, a.sgagrupamento, NULL AS sgorgao,
      NULL AS dtiniciovigencia, NULL AS dtfimvigencia, NULL AS nmtipoorgao,
      a.cdagrupamento, NULL AS cdorgao, NULL AS cdhistorgao, NULL AS cdtipoorgao
      FROM ecadagrupamento a
      INNER JOIN ecadpoder p ON p.cdpoder = a.cdpoder
      INNER JOIN ecadgrupoagrupamento g ON g.cdgrupoagrupamento = a.cdgrupoagrupamento
      ),
      epagRubricaAgrupamentoImportar AS (
      SELECT
      rubagp.cdrubricaagrupamento,
      NULL AS cdrubricaagrupamentoorigem,
      o.cdagrupamento,
      o.cdorgao,
      pcdRubrica as cdrubrica,
      
      NVL(js.flincorporacao, 'N') AS flincorporacao,
      NVL(js.flpensaoalimenticia, 'N') AS flpensaoalimenticia,
      NVL(js.fladiant13pensao, 'N') AS fladiant13pensao,
      NVL(js.fl13salpensao, 'N') AS fl13salpensao,
      NVL(js.flconsignacao, 'N') AS flconsignacao,
      NVL(js.fltributacao, 'N') AS fltributacao,
      NVL(js.flsalariofamilia, 'N') AS flsalariofamilia,
      NVL(js.flsalariomaternidade, 'N') AS flsalariomaternidade,
      NVL(js.fldevtributacaoiprev, 'N') AS fldevtributacaoiprev,
      NVL(js.fldevcorrecaomonetaria, 'N') AS fldevcorrecaomonetaria,
      NVL(js.flabonopermanencia, 'N') AS flabonopermanencia,
      NVL(js.flapostilamento, 'N') AS flapostilamento,
      NVL(js.flcontribuicaosindical, 'N') AS flcontribuicaosindical,
      
      modrub.cdmodalidaderubrica,
      basecalc.cdbasecalculo,
      NVL(js.flvisivelservidor, 'N') AS flvisivelservidor,
      NVL(js.flgerasuplementar, 'N') AS flgerasuplementar,
      NVL(js.flconsad, 'N') AS flconsad,
      NVL(js.flcompoe13, 'N') AS flcompoe13,
      NVL(js.flpropria13, 'N') AS flpropria13,
      NVL(js.flempenhadafilial, 'N') AS flempenhadafilial,
      js.nuelemdespesaativo,
      js.nuelemdespesainativo,
      js.nuelemdespesaativoclt,
      js.nuordemconsad,
      
      systimestamp AS dtultalteracao,
      
      VigenciasAgrupamento,
      FormulaCalculo
      
      FROM JSON_TABLE(JSON_QUERY(pAgrupamento, '$'), '$[*]' COLUMNS (
        flincorporacao         PATH '$.RubricaPropria.flincorporacao',
        flpensaoalimenticia    PATH '$.RubricaPropria.flpensaoalimenticia',
        fladiant13pensao       PATH '$.RubricaPropria.fladiant13pensao',
        fl13salpensao          PATH '$.RubricaPropria.fl13salpensao',
        flconsignacao          PATH '$.RubricaPropria.flconsignacao',
        fltributacao           PATH '$.RubricaPropria.fltributacao',
        flsalariofamilia       PATH '$.RubricaPropria.flsalariofamilia',
        flsalariomaternidade   PATH '$.RubricaPropria.flsalariomaternidade',
        fldevtributacaoiprev   PATH '$.RubricaPropria.fldevtributacaoiprev',
        fldevcorrecaomonetaria PATH '$.RubricaPropria.fldevcorrecaomonetaria',
        flabonopermanencia     PATH '$.RubricaPropria.flabonopermanencia',
        flapostilamento        PATH '$.RubricaPropria.flapostilamento',
        flcontribuicaosindical PATH '$.RubricaPropria.flcontribuicaosindical',
        nmmodalidaderubrica    PATH '$.ParametrosAgrupamento.nmmodalidaderubrica',
        sgbasecalculo          PATH '$.ParametrosAgrupamento.sgbasecalculo',
        flvisivelservidor      PATH '$.ParametrosAgrupamento.flvisivelservidor',
        flgerasuplementar      PATH '$.ParametrosAgrupamento.flgerasuplementar',
        flconsad               PATH '$.ParametrosAgrupamento.flconsad',
        flcompoe13             PATH '$.ParametrosAgrupamento.flcompoe13',
        flpropria13            PATH '$.ParametrosAgrupamento.flpropria13',
        flempenhadafilial      PATH '$.ParametrosAgrupamento.flempenhadafilial',
        nuelemdespesaativo     PATH '$.ParametrosAgrupamento.nuelemdespesaativo',
        nuelemdespesainativo   PATH '$.ParametrosAgrupamento.nuelemdespesainativo',
        nuelemdespesaativoclt  PATH '$.ParametrosAgrupamento.nuelemdespesaativoclt',
        nuordemconsad          PATH '$.ParametrosAgrupamento.nuordemconsad',
      
        VigenciasAgrupamento   CLOB FORMAT JSON PATH '$.VigenciasAgrupamento',
        FormulaCalculo         CLOB FORMAT JSON PATH '$.Formula'
      )) js
      INNER JOIN Orgao o ON o.sgagrupamento = psgAgrupamentoDestino AND NVL(o.sgorgao,' ') = NVL(psgOrgao,' ')
      LEFT JOIN epagrubricaagrupamento rubagp ON rubagp.cdagrupamento = o.cdagrupamento AND rubagp.cdrubrica = pcdRubrica
      LEFT JOIN epagmodalidaderubrica modrub ON modrub.nmmodalidaderubrica = js.nmmodalidaderubrica
      LEFT JOIN epagbasecalculo basecalc ON basecalc.cdagrupamento = o.cdagrupamento AND basecalc.cdorgao = o.cdorgao
                                        AND basecalc.sgbasecalculo = js.sgbasecalculo
      )
      SELECT * FROM epagRubricaAgrupamentoImportar;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Rubricas no Agrupamento ' || vcdIdentificacao);

    -- Loop principal de processamento
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao;

      IF r.cdrubricaagrupamento IS NULL THEN
        -- Incluir Nova Rubrica de Agrupamento
        SELECT NVL(MAX(cdrubricaagrupamento), 0) + 1 INTO vcdRubricaAgrupamentoNova FROM epagRubricaAgrupamento;

        INSERT INTO epagRubricaAgrupamento (
          cdrubricaagrupamento, cdrubrica, cdrubricaagrupamentoorigem, cdagrupamento, cdorgao, cdmodalidaderubrica, cdbasecalculo,
          flempenhadafilial, flincorporacao, flpensaoalimenticia, fltributacao, flconsignacao, dtultalteracao, flsalariofamilia,
          flsalariomaternidade, fldevtributacaoiprev, fldevcorrecaomonetaria, nuelemdespesaativo, nuelemdespesainativo, flvisivelservidor,
          nuelemdespesaativoclt, flgerasuplementar, fladiant13pensao, fl13salpensao, flconsad, nuordemconsad, flcompoe13, flabonopermanencia,
          flcontribuicaosindical, flapostilamento, flpropria13
        ) VALUES (
          vcdRubricaAgrupamentoNova, r.cdrubrica, r.cdrubricaagrupamentoorigem, r.cdagrupamento, r.cdorgao,
          r.cdmodalidaderubrica, r.cdbasecalculo, r.flempenhadafilial, r.flincorporacao, r.flpensaoalimenticia, r.fltributacao,
          r.flconsignacao, r.dtultalteracao, r.flsalariofamilia, r.flsalariomaternidade, r.fldevtributacaoiprev, r.fldevcorrecaomonetaria,
          r.nuelemdespesaativo, r.nuelemdespesainativo, r.flvisivelservidor, r.nuelemdespesaativoclt, r.flgerasuplementar, r.fladiant13pensao,
          r.fl13salpensao, r.flconsad, r.nuordemconsad, r.flcompoe13, r.flabonopermanencia, r.flcontribuicaosindical, r.flapostilamento,
          r.flpropria13 
        );

        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'RUBRICA AGRUPAMENTO', 'INCLUSAO', 'Rubrica do Agrupamento incluidas com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
      ELSE
        -- Atualizar Rubrica do Agrupamento Existente
        vcdRubricaAgrupamentoNova := r.cdrubricaagrupamento;

        UPDATE epagRubricaAgrupamento SET
          cdrubricaagrupamentoorigem = r.cdrubricaagrupamentoorigem,
          cdagrupamento = r.cdagrupamento,
          cdorgao = r.cdorgao,
          cdrubrica = r.cdrubrica,
          cdmodalidaderubrica = r.cdmodalidaderubrica,
          cdbasecalculo = r.cdbasecalculo,
          flempenhadafilial = r.flempenhadafilial,
          flincorporacao = r.flincorporacao,
          flpensaoalimenticia = r.flpensaoalimenticia,
          fltributacao = r.fltributacao,
          flconsignacao = r.flconsignacao,
          dtultalteracao = r.dtultalteracao,
          flsalariofamilia = r.flsalariofamilia,
          flsalariomaternidade = r.flsalariomaternidade,
          fldevtributacaoiprev = r.fldevtributacaoiprev,
          fldevcorrecaomonetaria = r.fldevcorrecaomonetaria,
          nuelemdespesaativo = r.nuelemdespesaativo,
          nuelemdespesainativo = r.nuelemdespesainativo,
          flvisivelservidor = r.flvisivelservidor,
          nuelemdespesaativoclt = r.nuelemdespesaativoclt,
          flgerasuplementar = r.flgerasuplementar,
          fladiant13pensao = r.fladiant13pensao,
          fl13salpensao = r.fl13salpensao,
          flconsad = r.flconsad,
          nuordemconsad = r.nuordemconsad,
          flcompoe13 = r.flcompoe13,
          flabonopermanencia = r.flabonopermanencia,
          flcontribuicaosindical = r.flcontribuicaosindical,
          flapostilamento = r.flapostilamento,
          flpropria13 = r.flpropria13
        WHERE cdrubricaagrupamento = vcdRubricaAgrupamentoNova;

        PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
          psgModulo, psgConceito, vcdIdentificacao, 1,
          'RUBRICA AGRUPAMENTO', 'ATUALIZACAO', 'Rubrica do Agrupamento atualizada com sucesso',
          cDEBUG_DESLIGADO, pnuDEBUG);
    END IF;

    -- Importar Vigências da Rubrica do Agrupamento
    pImportarAgrupamentoVigencias(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.VigenciasAgrupamento, pnuDEBUG);

    -- Importar Formulas de Calculo da Rubrica do Agrupamento
    PKGMIG_ImportarFormulasCalculo.pImportarFormulaCalculo(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, pcdIdentificacao, vcdRubricaAgrupamentoNova, r.FormulaCalculo, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Rubrica do Agrupamento ' || vcdIdentificacao || ' RUBRICA AGRUPAMENTO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarAgrupamento;
    
  PROCEDURE pImportarAgrupamentoVigencias(
  -- ###########################################################################
  -- PROCEDURE: pImportarAgrupamentoVigencias
  -- Objetivo:
  --   Importar as Vigências das Rubricas do Agrupamento
  --   contida no Documento VigenciasAgrupamento JSON na tabela emigConfiguracaoPadrao, realizando:
  --     - Exclusão das Naturezas de Vínculos, Regimes Previdenciários, Regimes de Trabalho,
  --       Relações de Trabalho e Situações Previdenciárias permitidas para cada
  --       Vigência das Rubricas do Agrupamento
  --     - Inclusão das Vigência das Rubricas do Agrupamento
  --     - Inclusão das Naturezas de Vínculos, Regimes Previdenciários, Regimes de Trabalho,
  --       Relações de Trabalho e Situações Previdenciárias permitidas para cada
  --       Vigência das Rubricas do Agrupamento
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
  --   pVigenciasAgrupamento IN CLOB: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
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
    pVigenciasAgrupamento IN CLOB,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vcdIdentificacao              VARCHAR2(50) := Null;
    vcdHistRubricaAgrupamentoNova NUMBER   := Null;
    vnuRegistros                  NUMBER   := 0;

    -- Cursor que extrai as Vigências da Rubrica do Agrupamento do Documento pVigenciasAgrupamento JSON
    CURSOR cDados IS
      WITH
      Orgao AS (
      SELECT g.sggrupoagrupamento, UPPER(p.nmpoder) AS nmpoder, a.sgagrupamento, vgcorg.sgorgao,
      vgcorg.dtiniciovigencia, vgcorg.dtfimvigencia,
      UPPER(tporgao.nmtipoorgao) AS nmtipoorgao,
      o.cdagrupamento, o.cdorgao, vgcorg.cdhistorgao, vgcorg.cdtipoorgao
      FROM ecadagrupamento a
      INNER JOIN ecadpoder p ON p.cdpoder = a.cdpoder
      INNER JOIN ecadgrupoagrupamento g ON g.cdgrupoagrupamento = a.cdgrupoagrupamento
      INNER JOIN ecadorgao o ON o.cdagrupamento = a.cdagrupamento
      INNER JOIN (
        SELECT sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao FROM (
          SELECT sgorgao, dtiniciovigencia, dtfimvigencia, cdorgao, cdhistorgao, cdtipoorgao, 
          RANK() OVER (PARTITION BY cdorgao ORDER BY dtiniciovigencia DESC, dtfimvigencia DESC nulls FIRST) AS nuorder
          FROM ecadhistorgao WHERE flanulado = 'N'
        ) WHERE nuorder = 1
      ) vgcorg ON vgcorg.cdorgao = o.cdorgao
      LEFT JOIN ecadtipoorgao tporgao ON tporgao.cdtipoorgao = vgcorg.cdtipoorgao
      UNION
      SELECT g.sggrupoagrupamento, UPPER(p.nmpoder) AS nmpoder, a.sgagrupamento, NULL AS sgorgao,
      NULL AS dtiniciovigencia, NULL AS dtfimvigencia, NULL AS nmtipoorgao,
      a.cdagrupamento, NULL AS cdorgao, NULL AS cdhistorgao, NULL AS cdtipoorgao
      FROM ecadagrupamento a
      INNER JOIN ecadpoder p ON p.cdpoder = a.cdpoder
      INNER JOIN ecadgrupoagrupamento g ON g.cdgrupoagrupamento = a.cdgrupoagrupamento
      ),
      epagHistRubricaAgrupamentoImportar AS (
      SELECT
        (SELECT NVL(MAX(cdhistrubricaagrupamento),0) FROM epaghistrubricaagrupamento) + ROWNUM AS cdhistrubricaagrupamento,
        pcdRubricaAgrupamento as cdrubricaagrupamento,
      
        CASE WHEN js.nuanomesiniciovigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesiniciovigencia,1,4)) END AS nuanoiniciovigencia,
        CASE WHEN js.nuanomesiniciovigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesiniciovigencia,5,2)) END AS numesiniciovigencia,
        CASE WHEN js.nuanomesfimvigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesfimvigencia,1,4)) END AS nuanofimvigencia,
        CASE WHEN js.nuanomesfimvigencia IS NULL THEN NULL
          ELSE TO_NUMBER(SUBSTR(js.nuanomesfimvigencia,5,2)) END AS numesfimvigencia,
      
        js.derubricaagrupamento,
        js.derubricaagrupresumida,
        js.derubricaagrupdetalhada,
        js.deformula,
        js.demodulo,
        js.decomposicao,
        js.devantagensnaoacumulaveis,
        js.deobservacao,
        js.cdrelacaotrabalho,
        js.cdrubproporcionalidadecho,
        js.cdoutrarubrica,
        js.nucargahorariasemanal,
        js.numesesapuracao,
        js.inlancproprelvinc,
        js.ingerarubricacarreira,
        js.ingerarubricanivel,
        js.ingerarubricauo,
        js.ingerarubricacco,
        js.ingerarubricafuc,
      
        js.inaposentadoriaservidor,
        js.ingerarubricaafasttemp,
        js.inimpedimentorubrica,
        js.inrubricasexigidas,

        NVL(js.flpropmescomercial, 'N') AS flpropmescomercial,
        NVL(js.flpropaposparidade, 'N') AS flpropaposparidade,
        NVL(js.flpropservrelvinc, 'N') AS flpropservrelvinc,
        NVL(js.inpossuivalorinformado, 'N') AS inpossuivalorinformado,
        NVL(js.flpermiteafastacidente, 'N') AS flpermiteafastacidente,
        NVL(js.flbloqlancfinanc, 'N') AS flbloqlancfinanc,
        NVL(js.flcargahorariapadrao, 'N') AS flcargahorariapadrao,
        NVL(js.flaplicarubricaorgaos, 'N') AS flaplicarubricaorgaos,
        NVL(js.flgestaosobrerubrica, 'N') AS flgestaosobrerubrica,
        NVL(js.flgerarubricaescala, 'N') AS flgerarubricaescala,
        NVL(js.flgerarubricahoraextra, 'N') AS flgerarubricahoraextra,
        NVL(js.flgerarubricaservcco, 'N') AS flgerarubricaservcco,
        NVL(js.fllaudoacompanhamento, 'N') AS fllaudoacompanhamento,
        NVL(js.flpermitefgftg, 'N') AS flpermitefgftg,
        NVL(js.flpermiteapooriginadocco, 'N') AS flpermiteapooriginadocco,
        NVL(js.flpagasubstituicao, 'N') AS flpagasubstituicao,
        NVL(js.flpagarespondendo, 'N') AS flpagarespondendo,
        NVL(js.flconsolidarubrica, 'N') AS flconsolidarubrica,
        NVL(js.flpropafasttempnaoremun, 'N') AS flpropafasttempnaoremun,
        NVL(js.flpropafafgftg, 'N') AS flpropafafgftg,
        NVL(js.flcargahorarialimitada, 'N') AS flcargahorarialimitada,
        NVL(js.flincidparcialcontrprev, 'N') AS flincidparcialcontrprev,
        NVL(js.flpropafacomissionado, 'N') AS flpropafacomissionado,
        NVL(js.flpropafacomopcperccef, 'N') AS flpropafacomopcperccef,
        NVL(js.flpreservavalorintegral, 'N') AS flpreservavalorintegral,
      
        js.cdtipoindice,
        js.ingerarubricamotmovi,
        NVL(js.flpagaaposemparidade, 'N') AS flpagaaposemparidade,
        NVL(js.flpercentlimitado100, 'N') AS flpercentlimitado100,
        js.ingerarubricaprograma,
        NVL(js.flpropafaccosubst, 'N') AS flpropafaccosubst,
        NVL(js.flimpedeidadecompulsoria, 'N') AS flimpedeidadecompulsoria,
        NVL(js.flgerarubricacarreiraincidecco, 'N') AS flgerarubricacarreiraincidecco,
        NVL(js.flgerarubricacarreiraincideapo, 'N') AS flgerarubricacarreiraincideapo,
        NVL(js.flgerarubricaccoincidecef, 'N') AS flgerarubricaccoincidecef,
        NVL(js.flsuspensa, 'N') AS flsuspensa,
        NVL(js.flpercentreducaoafastremun, 'N') AS flpercentreducaoafastremun,
        NVL(js.flpagamaiorrv, 'N') AS flpagamaiorrv,
        NVL(js.flgerarubricafucincidecef, 'N') AS flgerarubricafucincidecef,
        NVL(js.flvalidasufixoprecedencialf, 'N') AS flvalidasufixoprecedencialf,
        NVL(js.flsuspensaretroativoerario, 'N') AS flsuspensaretroativoerario,
        NVL(js.flpagaefetivoorgao, 'N') AS flpagaefetivoorgao,
        NVL(js.flignoraafastcefagpolitico, 'N') AS flignoraafastcefagpolitico,
        NVL(js.flpagaposentadoria, 'N') AS flpagaposentadoria,
      
        '11111111111' AS nucpfcadastrador,
        TRUNC(SYSDATE) AS dtinclusao,
        systimestamp AS dtultalteracao,
        
        js.NaturezaVinculo,
        js.RegimePrevidenciario,
        js.RegimeTrabalho,
        js.RelacaoTrabalho,
        js.SituacaoPrevidenciaria
      
      FROM JSON_TABLE(JSON_QUERY(pVigenciasAgrupamento, '$'), '$[*]' COLUMNS (
        nuanomesiniciovigencia         PATH '$.nuanomesiniciovigencia',
        nuanomesfimvigencia            PATH '$.nuanomesfimvigencia',
        derubricaagrupamento           PATH '$.Inventario.derubricaagrupamento',
        derubricaagrupresumida         PATH '$.Inventario.derubricaagrupresumida',
        derubricaagrupdetalhada        PATH '$.Inventario.derubricaagrupdetalhada',
        deformula                      PATH '$.Inventario.deformula',
        demodulo                       PATH '$.Inventario.demodulo',
        decomposicao                   PATH '$.Inventario.decomposicao',
        devantagensnaoacumulaveis      PATH '$.Inventario.devantagensnaoacumulaveis',
        deobservacao                   PATH '$.Inventario.deobservacao',
        cdrelacaotrabalho              PATH '$.ParametrosVigencia.cdrelacaotrabalho',
        cdtipoindice                   PATH '$.ParametrosVigencia.cdtipoindice',
        cdrubproporcionalidadecho      PATH '$.ParametrosVigencia.cdrubproporcionalidadecho',
        cdoutrarubrica                 PATH '$.ParametrosVigencia.cdoutrarubrica',
        nucargahorariasemanal          PATH '$.ParametrosVigencia.nucargahorariasemanal',
        numesesapuracao                PATH '$.ParametrosVigencia.numesesapuracao',
        inlancproprelvinc              PATH '$.ParametrosVigencia.inlancproprelvinc',
        ingerarubricacarreira          PATH '$.ParametrosVigencia.ingerarubricacarreira',
        ingerarubricanivel             PATH '$.ParametrosVigencia.ingerarubricanivel',
        ingerarubricauo                PATH '$.ParametrosVigencia.ingerarubricauo',
        ingerarubricacco               PATH '$.ParametrosVigencia.ingerarubricacco',
        ingerarubricafuc               PATH '$.ParametrosVigencia.ingerarubricafuc',
        ingerarubricamotmovi           PATH '$.ParametrosVigencia.ingerarubricamotmovi',
      
        inaposentadoriaservidor        PATH '$.ParametrosVigencia.inaposentadoriaservidor',
        ingerarubricaafasttemp         PATH '$.ParametrosVigencia.ingerarubricaafasttemp',
        inimpedimentorubrica           PATH '$.ParametrosVigencia.inimpedimentorubrica',
        inrubricasexigidas             PATH '$.ParametrosVigencia.inrubricasexigidas',
        flpropmescomercial             PATH '$.ParametrosVigencia.flpropmescomercial',
        flpropaposparidade             PATH '$.ParametrosVigencia.flpropaposparidade',
        flpropservrelvinc              PATH '$.ParametrosVigencia.flpropservrelvinc',
        inpossuivalorinformado         PATH '$.ParametrosVigencia.inpossuivalorinformado',
        flpermiteafastacidente         PATH '$.ParametrosVigencia.flpermiteafastacidente',
        flbloqlancfinanc               PATH '$.ParametrosVigencia.flbloqlancfinanc',
        flcargahorariapadrao           PATH '$.ParametrosVigencia.flcargahorariapadrao',
        flaplicarubricaorgaos          PATH '$.ParametrosVigencia.flaplicarubricaorgaos',
        flgestaosobrerubrica           PATH '$.ParametrosVigencia.flgestaosobrerubrica',
        flgerarubricaescala            PATH '$.ParametrosVigencia.flgerarubricaescala',
        flgerarubricahoraextra         PATH '$.ParametrosVigencia.flgerarubricahoraextra',
        flgerarubricaservcco           PATH '$.ParametrosVigencia.flgerarubricaservcco',
        fllaudoacompanhamento          PATH '$.ParametrosVigencia.fllaudoacompanhamento',
        flpermitefgftg                 PATH '$.ParametrosVigencia.flpermitefgftg',
        flpermiteapooriginadocco       PATH '$.ParametrosVigencia.flpermiteapooriginadocco',
        flpagasubstituicao             PATH '$.ParametrosVigencia.flpagasubstituicao',
        flpagarespondendo              PATH '$.ParametrosVigencia.flpagarespondendo',
        flconsolidarubrica             PATH '$.ParametrosVigencia.flconsolidarubrica',
        flpropafasttempnaoremun        PATH '$.ParametrosVigencia.flpropafasttempnaoremun',
        flpropafafgftg                 PATH '$.ParametrosVigencia.flpropafafgftg',
        flcargahorarialimitada         PATH '$.ParametrosVigencia.flcargahorarialimitada',
        flincidparcialcontrprev        PATH '$.ParametrosVigencia.flincidparcialcontrprev',
        flpropafacomissionado          PATH '$.ParametrosVigencia.flpropafacomissionado',
        flpropafacomopcperccef         PATH '$.ParametrosVigencia.flpropafacomopcperccef',
        flpreservavalorintegral        PATH '$.ParametrosVigencia.flpreservavalorintegral',
        flpagaaposemparidade           PATH '$.ParametrosVigencia.flpagaaposemparidade',
        flpercentlimitado100           PATH '$.ParametrosVigencia.flpercentlimitado100',
        ingerarubricaprograma          PATH '$.ParametrosVigencia.ingerarubricaprograma',
        flpropafaccosubst              PATH '$.ParametrosVigencia.flpropafaccosubst',
        flimpedeidadecompulsoria       PATH '$.ParametrosVigencia.flimpedeidadecompulsoria',
        flgerarubricacarreiraincidecco PATH '$.ParametrosVigencia.flgerarubricacarreiraincidecco',
        flgerarubricacarreiraincideapo PATH '$.ParametrosVigencia.flgerarubricacarreiraincideapo',
        flgerarubricaccoincidecef      PATH '$.ParametrosVigencia.flgerarubricaccoincidecef',
        flsuspensa                     PATH '$.ParametrosVigencia.flsuspensa',
        flpercentreducaoafastremun     PATH '$.ParametrosVigencia.flpercentreducaoafastremun',
        flpagamaiorrv                  PATH '$.ParametrosVigencia.flpagamaiorrv',
        flgerarubricafucincidecef      PATH '$.ParametrosVigencia.flgerarubricafucincidecef',
        flvalidasufixoprecedencialf    PATH '$.ParametrosVigencia.flvalidasufixoprecedencialf',
        flsuspensaretroativoerario     PATH '$.ParametrosVigencia.flsuspensaretroativoerario',
        flpagaefetivoorgao             PATH '$.ParametrosVigencia.flpagaefetivoorgao',
        flignoraafastcefagpolitico     PATH '$.ParametrosVigencia.flignoraafastcefagpolitico',
        flpagaposentadoria             PATH '$.ParametrosVigencia.flpagaposentadoria',
            
        NaturezaVinculo                CLOB FORMAT JSON PATH '$.Abrangencias.NaturezaVinculo',
        RegimePrevidenciario           CLOB FORMAT JSON PATH '$.Abrangencias.RegimePrevidenciario',
        RegimeTrabalho                 CLOB FORMAT JSON PATH '$.Abrangencias.RegimeTrabalho',
        RelacaoTrabalho                CLOB FORMAT JSON PATH '$.Abrangencias.RelacaoTrabalho',
        SituacaoPrevidenciaria         CLOB FORMAT JSON PATH '$.Abrangencias.SituacaoPrevidenciaria'
      )) js
      )
      
      SELECT * FROM epagHistRubricaAgrupamentoImportar;

  BEGIN

    vcdIdentificacao := pcdIdentificacao;

    --PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação das Vigências da Rubrica no Agrupamento ' || vcdIdentificacao);

    -- Excluir as Naturezas de Vinculo Permitidas Vigência da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epagHistRubricaAgrupNatVinc
    WHERE cdHistRubricaAgrupamento IN (
      SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
      WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epagHistRubricaAgrupNatVinc
      WHERE cdHistRubricaAgrupamento IN (
        SELECT cdHistRubricaAgrupamento FROM epagHistRubricaAgrupamento
        WHERE cdRubricaAgrupamento = pcdRubricaAgrupamento
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'EXCLUSAO', 'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;

    -- Excluir os Regimes Previdenciários Permitidas Vigência da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupregprev
    WHERE cdhistrubricaagrupamento IN (
      SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
      WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupregprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento
       );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGPREV', 'EXCLUSAO', 'Regimes Previdenciários Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;

    -- Excluir os Regimes de Trabalho Permitidas Vigência da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupregtrab
    WHERE cdhistrubricaagrupamento IN (
      SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
      WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupregtrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento
       );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGTRAB', 'EXCLUSAO', 'Regimes de Trabalho Permitidos na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;

    -- Excluir as Relações de Trabalho Permitidas Vigência da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupreltrab
    WHERE cdhistrubricaagrupamento IN (
      SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
      WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupreltrab
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento
       );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RELTRAB', 'EXCLUSAO', 'Relações de Trabalho Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;

    -- Excluir as Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupsitprev
    WHERE cdhistrubricaagrupamento IN (
      SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
      WHERE cdrubricaagrupamento = pcdRubricaAgrupamento);

	IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupsitprev
      WHERE cdhistrubricaagrupamento IN (
        SELECT cdhistrubricaagrupamento FROM epaghistrubricaagrupamento
        WHERE cdrubricaagrupamento = pcdRubricaAgrupamento
       );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA SITPREV', 'EXCLUSAO', 'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);
    END IF;

     -- Excluir as Vigências existentes da Rubrica do Agrupamento
	SELECT COUNT(*) INTO vnuRegistros FROM epaghistrubricaagrupamento
	WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

	IF vnuRegistros > 0 THEN
      DELETE FROM epaghistrubricaagrupamento WHERE cdrubricaagrupamento = pcdRubricaAgrupamento;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'EXCLUSAO', 'Vigências existentes da Rubrica do Agrupamento excluidas com sucesso',
        cDEBUG_NIVEL_1, pnuDEBUG);
    END IF;

    -- Loop principal de processamento para Incluir a Vigências da Rubrica do Agrupamento
    FOR r IN cDados LOOP

	  vcdIdentificacao := pcdIdentificacao || ' ' || LPAD(r.nuanoiniciovigencia,4,0) || LPAD(r.numesiniciovigencia,2,0);

      SELECT NVL(MAX(cdhistrubricaagrupamento), 0) + 1 INTO vcdHistRubricaAgrupamentoNova FROM epagHistRubricaAgrupamento;

      INSERT INTO epaghistrubricaagrupamento (
        cdhistrubricaagrupamento, cdrubricaagrupamento,
        derubricaagrupamento, derubricaagrupresumida, derubricaagrupdetalhada,
        nuanoiniciovigencia, numesiniciovigencia, nuanofimvigencia, numesfimvigencia,
        flpermiteafastacidente, flbloqlancfinanc, inlancproprelvinc, cdrelacaotrabalho, flcargahorariapadrao, nucargahorariasemanal,
        numesesapuracao, flaplicarubricaorgaos, nucpfcadastrador, dtinclusao, dtultalteracao, flgestaosobrerubrica, flgerarubricaescala,
        flgerarubricahoraextra, flgerarubricaservcco, ingerarubricacarreira, ingerarubricanivel, ingerarubricauo, ingerarubricacco,
        ingerarubricafuc, fllaudoacompanhamento, inaposentadoriaservidor, ingerarubricaafasttemp, inimpedimentorubrica, inrubricasexigidas,
        cdrubproporcionalidadecho, flpropmescomercial, flpropaposparidade, flpropservrelvinc, cdoutrarubrica, inpossuivalorinformado,
        flpermitefgftg, flpermiteapooriginadocco, flpagasubstituicao, flpagarespondendo, flconsolidarubrica, flpropafasttempnaoremun,
        flpropafafgftg, flcargahorarialimitada, flincidparcialcontrprev, flpropafacomissionado, flpropafacomopcperccef,
        flpreservavalorintegral, ingerarubricamotmovi, flpagaaposemparidade, flpercentlimitado100, ingerarubricaprograma,
        flpropafaccosubst, flimpedeidadecompulsoria, flgerarubricacarreiraincidecco, flgerarubricacarreiraincideapo,
        flgerarubricaccoincidecef, flsuspensa, flpercentreducaoafastremun, flpagamaiorrv, cdtipoindice, flgerarubricafucincidecef,
        flvalidasufixoprecedencialf, deformula, demodulo, decomposicao, devantagensnaoacumulaveis, deobservacao,
        flsuspensaretroativoerario, flpagaefetivoorgao, flignoraafastcefagpolitico, flpagaposentadoria
      ) VALUES (
        vcdHistRubricaAgrupamentoNova, r.cdrubricaagrupamento,
        r.derubricaagrupamento, r.derubricaagrupresumida, r.derubricaagrupdetalhada,
        r.nuanoiniciovigencia, r.numesiniciovigencia, r.nuanofimvigencia, r.numesfimvigencia,
        r.flpermiteafastacidente, r.flbloqlancfinanc, r.inlancproprelvinc, r.cdrelacaotrabalho, r.flcargahorariapadrao, r.nucargahorariasemanal,
        r.numesesapuracao, r.flaplicarubricaorgaos, r.nucpfcadastrador, r.dtinclusao, r.dtultalteracao, r.flgestaosobrerubrica, r.flgerarubricaescala,
        r.flgerarubricahoraextra, r.flgerarubricaservcco, r.ingerarubricacarreira, r.ingerarubricanivel, r.ingerarubricauo, r.ingerarubricacco,
        r.ingerarubricafuc, r.fllaudoacompanhamento, r.inaposentadoriaservidor, r.ingerarubricaafasttemp, r.inimpedimentorubrica, r.inrubricasexigidas,
        r.cdrubproporcionalidadecho, r.flpropmescomercial, r.flpropaposparidade, r.flpropservrelvinc, r.cdoutrarubrica, r.inpossuivalorinformado,
        r.flpermitefgftg, r.flpermiteapooriginadocco, r.flpagasubstituicao, r.flpagarespondendo, r.flconsolidarubrica, r.flpropafasttempnaoremun,
        r.flpropafafgftg, r.flcargahorarialimitada, r.flincidparcialcontrprev, r.flpropafacomissionado, r.flpropafacomopcperccef,
        r.flpreservavalorintegral, r.ingerarubricamotmovi, r.flpagaaposemparidade, r.flpercentlimitado100, r.ingerarubricaprograma,
        r.flpropafaccosubst, r.flimpedeidadecompulsoria, r.flgerarubricacarreiraincidecco, r.flgerarubricacarreiraincideapo,
        r.flgerarubricaccoincidecef, r.flsuspensa, r.flpercentreducaoafastremun, r.flpagamaiorrv, r.cdtipoindice, r.flgerarubricafucincidecef,
        r.flvalidasufixoprecedencialf, r.deformula, r.demodulo, r.decomposicao, r.devantagensnaoacumulaveis, r.deobservacao,
        r.flsuspensaretroativoerario, r.flpagaefetivoorgao, r.flignoraafastcefagpolitico, r.flpagaposentadoria
      );

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'INCLUSAO', 'Vigencia da Rubrica do Agrupamento incluidas com sucesso',
        cDEBUG_NIVEL_1, pnuDEBUG);

      -- Incluir Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      FOR i IN (
        SELECT d.cdnaturezavinculo
          FROM json_table(r.NaturezaVinculo, '$[*]' COLUMNS (item PATH '$')) js
          LEFT JOIN ecadNaturezaVinculo d ON UPPER(d.nmnaturezavinculo) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaghistrubricaagrupnatvinc VALUES (vcdHistRubricaAgrupamentoNova, i.cdnaturezavinculo);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA NATVINC', 'INCLUSAO', 'Naturezas de Vinculo Permitidas na Vigência da Rubrica do Agrupamento incluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Incluir Regimes Previdenciários Permitidas Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      FOR i IN (
        SELECT d.cdregimeprevidenciario
          FROM json_table(r.RegimePrevidenciario, '$[*]' COLUMNS (item PATH '$')) js
          LEFT JOIN ecadRegimePrevidenciario d ON UPPER(d.nmregimeprevidenciario) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaghistrubricaagrupregprev VALUES (vcdHistRubricaAgrupamentoNova, i.cdregimeprevidenciario);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGPREV', 'INCLUSAO', 'Regimes Previdenciários Permitidos na Vigência da Rubrica do Agrupamento incluidos com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Incluir Regimes de Trabalho Permitidas Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      FOR i IN (
        SELECT d.cdregimetrabalho
          FROM json_table(r.RegimeTrabalho, '$[*]' COLUMNS (item PATH '$')) js
          LEFT JOIN ecadRegimeTrabalho d ON UPPER(d.nmregimetrabalho) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaghistrubricaagrupregtrab  VALUES (vcdHistRubricaAgrupamentoNova, i.cdregimetrabalho);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA REGTRAB', 'INCLUSAO', 'Regimes de Trabalho Permitidos na Vigência da Rubrica do Agrupamento incluidos com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Incluir Relações de Trabalho Permitidas Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      FOR i IN (
        SELECT d.cdrelacaotrabalho
          FROM json_table(r.RelacaoTrabalho, '$[*]' COLUMNS (item PATH '$')) js
          LEFT JOIN ecadRelacaoTrabalho d ON UPPER(d.nmrelacaotrabalho) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaghistrubricaagrupreltrab VALUES (vcdHistRubricaAgrupamentoNova, i.cdrelacaotrabalho);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA RELTRAB', 'INCLUSAO', 'Relações de Trabalho Permitidas na Vigência da Rubrica do Agrupamento incluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

      -- Incluir Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento
      vnuRegistros := 0;
      FOR i IN (
        SELECT d.cdsituacaoprevidenciaria
          FROM json_table(r.SituacaoPrevidenciaria, '$[*]' COLUMNS (item PATH '$')) js
          LEFT JOIN ecadSituacaoPrevidenciaria d ON UPPER(d.nmsituacaoprevidenciaria) = UPPER(js.item)
      ) LOOP
        INSERT INTO epaghistrubricaagrupsitprev VALUES (vcdHistRubricaAgrupamentoNova, i.cdsituacaoprevidenciaria);
		vnuRegistros := vnuRegistros + 1;
      END LOOP;

      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, pcdIdentificacao, vnuRegistros,
        'RUBRICA AGRUPAMENTO VIGENCIA SITPREV', 'INCLUSAO', 'Situações Previdenciárias Permitidas na Vigência da Rubrica do Agrupamento incluidas com sucesso',
        cDEBUG_NIVEL_2, pnuDEBUG);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Importação da Vigência da Rubrica do Agrupamento ' || vcdIdentificacao || ' RUBRICA AGRUPAMENTO VIGENCIA Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, vcdIdentificacao, 1,
        'RUBRICA AGRUPAMENTO VIGENCIA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarAgrupamentoVigencias;
  
  PROCEDURE PAtuializarSequence(
  -- ###########################################################################
  -- PROCEDURE: PAtuializarSequence
  -- Objetivo:
  --   Atualizar a SEQUENCE com o Maior Número da Chave Primaria
  --     das tabelas envolvidas na importação das Rubricas do Agrupamento
  --
  -- Parâmetros:
  --   psgAgrupamentoDestino IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR: 
  --   psgConceito           IN VARCHAR2: 
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
      vtxSQL VARCHAR2(1000);
      vnuRegistros NUMBER;

    -- Cursor que extrai as Vigências da Rubrica do Agrupamento do Documento pVigenciasAgrupamento JSON
    CURSOR cDados IS
      SELECT tab.table_name, col.column_name, seq.sequence_name, seq.last_number, tab.num_rows
      FROM user_tables tab
      LEFT JOIN user_sequences seq ON SUBSTR(seq.sequence_name,2) = SUBSTR(tab.table_name,2)
      LEFT JOIN all_tab_columns col ON col.table_name = tab.table_name AND col.column_id = 1
      WHERE seq.sequence_name IS NOT NULL
       AND tab.table_name in (
        'EPAGRUBRICA', 'EPAGGRUPORUBRICAPAGAMENTO', 'EPAGHISTRUBRICA',
        'EPAGRUBRICAAGRUPAMENTO', 'EPAGHISTRUBRICAAGRUPAMENTO', 'EPAGHISTRUBRICAAGRUPNATVINC',
        'EPAGHISTRUBRICAAGRUPREGPREV', 'EPAGHISTRUBRICAAGRUPREGTRAB', 'EPAGHISTRUBRICAAGRUPRELTRAB', 'EPAGHISTRUBRICAAGRUPSITPREV',
        'EPAGEVENTOPAGAGRUP', 'EPAGHISTEVENTOPAGAGRUP', 'EPAGEVENTOPAGAGRUPORGAO', 'EPAGHISTEVENTOPAGAGRUPCARREIRA',
        'EPAGFORMULACALCULO', 'EPAGFORMULAVERSAO', 'EPAGHISTFORMULACALCULO', 'EPAGEXPRESSAOFORMCALC',
        'EPAGFORMULACALCULOBLOCO', 'EPAGFORMULACALCBLOCOEXPRESSAO', 'EPAGFORMCALCBLOCOEXPRUBAGRUP'
      );

    BEGIN
      FOR item IN cDados
        LOOP
          -- Obtendo o Maior Número da Chave Primaria da Tabela
          vtxSQL := 'SELECT NVL(MAX(' || item.column_name || '), 0) + 1 FROM ' || item.table_name;
          EXECUTE IMMEDIATE vtxSQL INTO vnuRegistros;

          PKGMIG_ConfiguracaoPadrao.PConsoleLog('Atualizar a SEQUENCE ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' reiniciar com ' || vnuRegistros );

          -- Atualizar a SEQUENCE com o Maior Número da Chave Primaria da Tabela
          execute immediate 'alter sequence ' || item.sequence_name || ' restart start with ' || case when vnuRegistros = 0 then 1 else vnuRegistros end;
          execute immediate 'analyze table ' || upper(item.table_name) || ' compute statistics';

          PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
            psgModulo, psgConceito, NULL, NULL, 'RUBRICA SEQUENCE', NULL,
            'Atualizar a SEQUENCE ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' para reiniciar em: ' || vnuRegistros,
            cDEBUG_DESLIGADO, pnuDEBUG);
      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Atualizar as SEQUENCE da Importação das Rubrica RUBRICA SEQUENCE Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, NULL, NULL,
        'RUBRICA SEQUENCE', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END PAtuializarSequence;

  PROCEDURE pImportarResumo(
  -- ###########################################################################
  -- PROCEDURE: pImportarRsumo
  -- Objetivo:
  --   Apura as informações estatísticas do processo de Importar rubricas
  --   contida na tabela emigConfiguracaoPadraoLog, realizando:
  --     - Consolida e Contabiliza os Registros Excluídos, Atualizados, Incluídos
  --       e Inconsistências encontradas.
  --     - Gerar Registro de Logs com resumo dos evento
  --
  -- Parâmetros:
  --   psgAgrupamentoOrigem   IN VARCHAR2: Sigla do agrupamento de origem da configuração
  --   psgAgrupamentoDestino  IN VARCHAR2: Sigla do agrupamento de destino para os dados
  --   pnuDEBUG              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamentoDestino IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pdtTermino            IN TIMESTAMP,
    pnuTempoExcusao       IN INTERVAL DAY TO SECOND,
	pnuDEBUG              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vResumoEstatisticas      CLOB := Null;

    -- Cursor que extrai as estatísticas do Log
    CURSOR cLog IS
      WITH
      LOG AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao, nmEntidade, nmEvento, 1 as nuRegistros,
        CASE nmEvento WHEN 'INCLUSAO' THEN 1 WHEN 'ATUALIZACAO' THEN 2 WHEN 'EXCLUSAO' THEN 3 ELSE 9 END AS cdEvento,
        CASE WHEN nmEvento != 'EXCLUSAO' THEN dtInclusao ELSE TO_TIMESTAMP('99991231 235959', 'YYYYMMDD HH24MISS')
          END AS dtInclusaoAjustada
      FROM emigConfiguracaoPadraolog
      WHERE sgModulo = psgModulo AND sgConceito = psgConceito AND nmEvento != 'RESUMO'
        AND tpOperacao = ptpOperacao AND dtOperacao = pdtOperacao
        AND sgAgrupamento = psgAgrupamentoDestino
      ),
      OrdemEntidade AS (
      SELECT nmEntidade, RANK() OVER(ORDER BY dtInclusaoAjustada) AS cdEntidade FROM (
        SELECT nmEntidade, MIN(dtInclusaoAjustada) as dtInclusaoAjustada FROM Log GROUP BY nmEntidade
      ) ORDER BY dtInclusaoAjustada
      ),
      Estatisticas AS (
      SELECT log.sgAgrupamento, log.sgOrgao, log.sgModulo, log.sgConceito, log.tpOperacao,
        log.dtOperacao, ordem.cdEntidade, log.nmEntidade, log.cdEvento, SUM(nuRegistros) AS nuRegistros
      FROM LOG log
      INNER JOIN OrdemEntidade ordem ON ordem.nmEntidade = log.nmEntidade
      GROUP BY log.sgAgrupamento, log.sgOrgao, log.sgModulo, log.sgConceito,
      log.tpOperacao, log.dtOperacao, ordem.cdEntidade, log.nmEntidade, log.cdEvento
      ),
      Resumo AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
      cdEntidade, nmEntidade, Incluidos, Atualizados, Excluidos, Outros
      FROM Estatisticas
      PIVOT (SUM(nuRegistros) FOR cdEvento IN (1 AS Incluidos, 2 As Atualizados, 3 AS Excluidos, 9 AS Outros))
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      )
      SELECT JSON_SERIALIZE (TO_CLOB(JSON_OBJECT(
        sgModulo VALUE JSON_OBJECT(
          sgConceito VALUE JSON_OBJECT(
            tpOperacao,
            sgAgrupamento,
            'sgOrgao' value NVL(sgOrgao,'TODOS'),
            'dtOperacaoInicio' VALUE TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI'),
            'dtOperacaoTermino' VALUE TO_CHAR(pdtTermino, 'DD/MM/YYYY HH24:MI'),
            'TempoExceusao' VALUE
			  LPAD(EXTRACT(HOUR FROM pnuTempoExcusao), 2, '0') || ':' ||
			  LPAD(EXTRACT(MINUTE FROM pnuTempoExcusao), 2, '0') || ':' ||
			  LPAD(EXTRACT(SECOND FROM pnuTempoExcusao), 2, '0'),
            'Registros' VALUE JSON_ARRAYAGG(JSON_OBJECT(
              nmEntidade VALUE JSON_OBJECT(
                'Excluídos' VALUE Excluidos,
                'Atualizados' VALUE Atualizados,
                'Incluídos' VALUE Incluidos,
                'Outros' VALUE Outros
              ABSENT ON NULL)
            ) ORDER By cdEntidade)
          RETURNING CLOB)
        RETURNING CLOB)
      RETURNING CLOB)) RETURNING CLOB PRETTY) AS ResumoEstatisticas
      FROM Resumo
      GROUP BY sgAgrupamento, sgOrgao, dtOperacao, tpOperacao, sgModulo, sgConceito;

  BEGIN

    -- Consolida as Informações de Estatísticas da Importação das Rubricas
    OPEN cLog;
    FETCH cLog INTO vResumoEstatisticas;
    CLOSE cLog;

    -- Registro de Resumo da Importação das Rubricas
    PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, NULL, NULL,
      'RUBRICA', 'RESUMO', vResumoEstatisticas,
      cDEBUG_DESLIGADO, pnuDEBUG);

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Resumo da Importação das Configurações do Agrupamento ';

    PKGMIG_ConfiguracaoPadrao.PConsoleLog('Estatísticas: ' || vResumoEstatisticas);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PKGMIG_ConfiguracaoPadrao.PConsoleLog('Resumo da Importação das Rubrica RUBRICA RESUMO Erro: ' || SQLERRM);
      PKGMIG_ConfiguracaoPadrao.pRegistrarLog(psgAgrupamentoDestino, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, NULL, NULL,
        'RUBRICA', 'ERRO', 'Erro: ' || SQLERRM,
        cDEBUG_DESLIGADO, pnuDEBUG);
    ROLLBACK;
    RAISE;
  END pImportarResumo;

END PKGMIG_ImportarRubricas;
/
