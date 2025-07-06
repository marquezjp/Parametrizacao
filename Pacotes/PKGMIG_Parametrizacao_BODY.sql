-- Corpo do pacote
CREATE OR REPLACE PACKAGE BODY PKGMIG_Parametrizacao AS
/*
  FUNCTION fnObterNivelAuditoria(pNivelAuditoria IN VARCHAR2) RETURN PLS_INTEGER IS
  BEGIN
  CASE UPPER(TRIM(NVL(pNivelAuditoria, 'ESSENCIAL')))
    WHEN 'SILENCIADO' THEN RETURN cAUDITORIA_SILENCIADO;
    WHEN 'ESSENCIAL'  THEN RETURN cAUDITORIA_ESSENCIAL;
    WHEN 'DETALHADO'  THEN RETURN cAUDITORIA_DETALHADO;
    WHEN 'COMPLETO'   THEN RETURN cAUDITORIA_COMPLETO;
    ELSE RETURN cAUDITORIA_ESSENCIAL;
  END CASE;
  END;
*/
  PROCEDURE pExportar(pjsParametros IN VARCHAR2 DEFAULT NULL) IS
--    vnuNivelAuditoria NUMBER := fnObterNivelAuditoria(pNivelAuditoria);
    vParm                 tpParametroEntrada;

  BEGIN

    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    CASE UPPER(vParm.sgConceito)
      WHEN 'VALORREFERENCIA' THEN
        PKGMIG_ParemetrizacaoValoresReferencia.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'BASECALCULO' THEN
        PKGMIG_ParametrizacaoBasesCalculo.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'RUBRICA' THEN
        PKGMIG_ParametrizacaoRubricas.pExportar(vParm.sgAgrupamento, vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Conceito não suportado: ' || vParm.sgConceito);
    END CASE;
  END pExportar;

  PROCEDURE pImportar(pjsParametros IN VARCHAR2 DEFAULT NULL) IS
--    vnuNivelAuditoria NUMBER := fnObterNivelAuditoria(pNivelAuditoria);
    vParm                 tpParametroEntrada;

  BEGIN

    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    CASE UPPER(vParm.sgConceito)
      WHEN 'VALORREFERENCIA' THEN
        PKGMIG_ParemetrizacaoValoresReferencia.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'BASECALCULO' THEN
        PKGMIG_ParametrizacaoBasesCalculo.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      WHEN 'RUBRICA' THEN
        PKGMIG_ParametrizacaoRubricas.pImportar(vParm.sgAgrupamento, vParm.sgAgrupamentoDestino,
          vParm.cdIdentificacao, vParm.nuNivelAuditoria);
      ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Importação não suportada para o conceito: ' || vParm.sgConceito);
    END CASE;
  END pImportar;

  PROCEDURE pConsoleLog(
  -- ###########################################################################
  -- PROCEDURE: pConsoleLog
  -- Objetivo:
  --   Mostrar os eventos de auditoria na saída padrão, Console.
  --
  -- Parâmetros:
  --   pdeMensagem      IN VARCHAR2:  'Mensagem detalhada sobre a operação registrada.'
  --   pNivelAuditoria  IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'SILENCIADO' omite todas as mensagens;
  --                         - Se informado 'ESSENCIAL' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DETALHADO' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    pdeMensagem       IN VARCHAR2,
    pnuNivelLog       IN NUMBER DEFAULT NULL,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
    ) IS
    BEGIN
      -- Incluir Log de Auditoria da Importação das Parametrizações
      IF NVL(pnuNivelAuditoria, cAUDITORIA_ESSENCIAL) >= NVL(pnuNivelLog, cAUDITORIA_ESSENCIAL) THEN
	    DBMS_OUTPUT.PUT_LINE(pdeMensagem);
      END IF;
  END pConsoleLog;

  PROCEDURE pRegistrarLog(
  -- ###########################################################################
  -- PROCEDURE: pRegistrarLog
  -- Objetivo:
  --   Registrar eventos de auditoria, controle ou estatística no processo de
  --   Exportação e Importação das Parametrizações (rubricas, bases, valores, etc.).
  --   Os registros são inseridos na tabela emigParametrizacaoLog.
  --
  -- Parâmetros:
  --   psgAgrupamento   IN VARCHAR2:  'Sigla do Agrupamento relacionado ao evento.'
  --   psgOrgao         IN VARCHAR2:  'Sigla do Órgão, se nulo se refere a todos os órgãos.'
  --   ptpOperacao      IN VARCHAR2:  'Se o evento é de EXPORTACAO ou de IMPORTACAO.'
  --   pdtOperacao      IN TIMESTAMP: 'Data e hora do incio da operação relacionada a todos os evento da operação.'
  --   psgModulo        IN CHAR:      'Sigla do Módulo que originou o evento .'
  --   psgConceito      IN VARCHAR2:  'Conceito associado à parametrização.'
  --   pcdIdentificacao IN VARCHAR2:  'Código Identificador da Entidade Parametrizada afetada pela operação.'
  --   nmEntidade       IN VARCHAR2:  'Entidade dentro do Conceito associado à parametrização, grupo de informações do Conceito.'
  --   pnmEvento        IN VARCHAR2:  'Nome do evento (INCLUSAO, ATUALIZACAO, EXCLUSAO, RESUMO).'
  --   pdeMensagem      IN VARCHAR2:  'Mensagem detalhada sobre a operação registrada.'
  --   pNivelAuditoria           IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'SILENCIADO' omite todas as mensagens;
  --                         - Se informado 'ESSENCIAL' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DETALHADO' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamento   IN VARCHAR2,
    psgOrgao         IN VARCHAR2,
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN TIMESTAMP,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    pcdIdentificacao IN VARCHAR2,
    pnuRegistros     IN NUMBER,
    pnmEntidade      IN VARCHAR2,
    pnmEvento        IN VARCHAR2,
    pdeMensagem      IN VARCHAR2,
    pnuNivelLog      IN NUMBER DEFAULT NULL,
    pnuNivelAuditoria         IN NUMBER DEFAULT NULL
    ) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      -- Incluir Log de Auditoria da Importação das Parametrizações na Tabela Temporária
      IF NVL(pnuNivelAuditoria, cAUDITORIA_ESSENCIAL) >= NVL(pnuNivelLog, cAUDITORIA_ESSENCIAL) THEN
        INSERT INTO emigParametrizacaoLog (
          sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
          nmEntidade, cdIdentificacao, nmEvento, nuRegistros, deMensagem
        ) VALUES (
          psgAgrupamento, psgOrgao, psgModulo, psgConceito, ptpOperacao, pdtOperacao,
          pnmEntidade, pcdIdentificacao, pnmEvento, pnuRegistros, pdeMensagem
        );
        COMMIT;
      END IF;
  END pRegistrarLog;

  PROCEDURE pAtualizarSequence(
  -- ###########################################################################
  -- PROCEDURE: pAtualizarSequence
  -- Objetivo:
  --   Atualizar a SEQUENCE com o Maior Número da Chave Primaria
  --     das tabelas envolvidas na importação das Parametrizações
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2:
  --   ptpOperacao           IN VARCHAR2:
  --   pdtOperacao           IN TIMESTAMP:
  --   psgModulo             IN CHAR: 
  --   psgConceito           IN VARCHAR2: 
  --   pnuNivelAuditoria              IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamento        IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pListaTabelas         IN CLOB,
    pnuNivelAuditoria              IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
      vtxSQL VARCHAR2(1000);
      vnuRegistros NUMBER;

    -- Cursor que lista as SEQUENCE da Tabelas envolvida na Importação das Parametrizações
    CURSOR cDados IS
      SELECT tab.table_name, col.column_name, seq.sequence_name, seq.last_number, tab.num_rows
      FROM user_tables tab
      LEFT JOIN user_sequences seq ON SUBSTR(seq.sequence_name,2) = SUBSTR(tab.table_name,2)
      LEFT JOIN all_tab_columns col ON col.table_name = tab.table_name AND col.column_id = 1
      WHERE seq.sequence_name IS NOT NULL
        AND tab.table_name IN (SELECT table_name FROM JSON_TABLE(pListaTabelas, '$[*]' COLUMNS (table_name PATH '$')));

    BEGIN

      PConsoleLog('Atualizar as SEQUENCE após Importação das Parametrização ' || psgConceito);

      FOR item IN cDados
        LOOP
          -- Obtendo o Maior Número da Chave Primaria da Tabela
          vtxSQL := 'SELECT NVL(MAX(' || item.column_name || '), 0) + 1 FROM ' || item.table_name;
          EXECUTE IMMEDIATE vtxSQL INTO vnuRegistros;

          PConsoleLog('SEQUENCE ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' reiniciada em: ' || vnuRegistros,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          -- Atualizar a SEQUENCE com o Maior Número da Chave Primaria da Tabela
          EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || item.sequence_name || ' RESTART START WITH ' || CASE WHEN vnuRegistros = 0 THEN 1 ELSE vnuRegistros END;
          EXECUTE IMMEDIATE 'ANALYZE TABLE ' || UPPER(item.table_name) || ' COMPUTE STATISTICS';

          pRegistrarLog(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
            psgModulo, psgConceito, NULL, NULL,
            'SEQUENCE', 'SEQUENCE',
            'RESUMO - ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' reiniciada em: ' || vnuRegistros,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PConsoleLog('Atualizar as SEQUENCE após Importação das Parametrizações SEQUENCE Erro: ' || SQLERRM);
      pRegistrarLog(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao, 
        psgModulo, psgConceito, NULL, NULL,
        'SEQUENCE', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END PAtualizarSequence;

  PROCEDURE pGerarResumo(
  -- ###########################################################################
  -- PROCEDURE: pGerarResumo
  -- Objetivo:
  --   Apura as informações estatísticas do processo de Importar
  --   contida na tabela emigParametrizacaoLog, realizando:
  --     - Consolida e Contabiliza os Registros Excluídos, Atualizados, Incluídos
  --       e Inconsistências encontradas.
  --     - Gerar Registro de Logs com resumo dos evento
  --
  -- Parâmetros:
  --   psgAgrupamento        IN VARCHAR2:
  --   psgOrgao              IN VARCHAR2,
  --   ptpOperacao           IN VARCHAR2,
  --   pdtOperacao           IN TIMESTAMP,
  --   psgModulo             IN CHAR,
  --   psgConceito           IN VARCHAR2,
  --   pdtTermino            IN TIMESTAMP,
  --   pnuTempoExcusao       IN INTERVAL DAY TO SECOND,
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamento        IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pdtTermino            IN TIMESTAMP,
    pnuTempoExcusao       IN INTERVAL DAY TO SECOND,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
  ) IS
    -- Variáveis de controle e contexto
    vResumoEstatisticas      CLOB := Null;

    -- Cursor que extrai as estatísticas do Log
    CURSOR cLog IS
      WITH
      LOG AS (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao, nmEntidade, nmEvento, nuRegistros,
      CASE nmEvento WHEN 'INCLUSAO' THEN 1 WHEN 'ATUALIZACAO' THEN 2 WHEN 'EXCLUSAO' THEN 3 WHEN 'INCONSISTENTE' THEN 4 ELSE 9 END AS cdEvento,
      CASE WHEN nmEvento != 'EXCLUSAO' THEN dtInclusao ELSE TO_TIMESTAMP('99991231 235959', 'YYYYMMDD HH24MISS')
        END AS dtInclusaoAjustada
      FROM emigParametrizacaoLog
      WHERE sgModulo = psgModulo AND sgConceito = psgConceito AND nmEvento != 'RESUMO'
      AND tpOperacao = ptpOperacao --AND dtOperacao = pdtOperacao
      AND sgAgrupamento = psgAgrupamento
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
      cdEntidade, nmEntidade, Incluidos, Atualizados, Excluidos, Inconsistentes, Outros
      FROM Estatisticas
      PIVOT (SUM(nuRegistros) FOR cdEvento IN (1 AS Incluidos, 2 As Atualizados, 3 AS Excluidos, 4 AS Inconsistentes, 9 AS Outros))
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      )
      SELECT JSON_SERIALIZE (TO_CLOB(JSON_OBJECT(
      sgModulo VALUE JSON_OBJECT(
        sgConceito VALUE JSON_OBJECT(
          tpOperacao,
          sgAgrupamento,
          'sgOrgao' value NVL(sgOrgao,'TODOS'),
          'dtOperacaoInicio' VALUE TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI:SS'),
          'dtOperacaoTermino' VALUE TO_CHAR(pdtTermino, 'DD/MM/YYYY HH24:MI:SS'),
          'TempoExceusao' VALUE
            LPAD(EXTRACT(HOUR FROM pnuTempoExcusao), 2, '0') || ':' ||
            LPAD(EXTRACT(MINUTE FROM pnuTempoExcusao), 2, '0') || ':' ||
            LPAD(TRUNC(EXTRACT(SECOND FROM pnuTempoExcusao)), 2, '0'),
          'Registros' VALUE JSON_ARRAYAGG(JSON_OBJECT(
            nmEntidade VALUE JSON_OBJECT(
              'Inconsistentes' VALUE Inconsistentes,
              'Excluídos'      VALUE Excluidos,
              'Atualizados'    VALUE Atualizados,
              'Incluídos'      VALUE Incluidos,
              'Outros'         VALUE Outros
            ABSENT ON NULL)
          ) ORDER By cdEntidade)
        RETURNING CLOB)
      RETURNING CLOB)
      RETURNING CLOB)) RETURNING CLOB PRETTY) AS ResumoEstatisticas
      FROM Resumo
      GROUP BY sgAgrupamento, sgOrgao, dtOperacao, tpOperacao, sgModulo, sgConceito
      ORDER BY sgAgrupamento, sgModulo, sgConceito, sgOrgao, tpOperacao, dtOperacao DESC;
  BEGIN

    -- Consolida as Informações de Estatísticas da Importação das Parametrizações
    OPEN cLog;
    FETCH cLog INTO vResumoEstatisticas;
    CLOSE cLog;

    -- Registro de Resumo da Importação das Parametrizações
    pRegistrarLog(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, NULL, NULL,
      'RESUMO', 'RESUMO', vResumoEstatisticas,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    PConsoleLog('Resumo da Importação das Parametrizações do Agrupamento ' || psgAgrupamento,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    PConsoleLog('Estatísticas: ' || vResumoEstatisticas,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

  EXCEPTION
    WHEN OTHERS THEN
      -- Registro e Propagação do Erro
      PConsoleLog('Resumo da Importação das Parametrizações PARAMETRIZACOES RESUMO Erro: ' || SQLERRM);
      pRegistrarLog(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
        psgModulo, psgConceito, NULL, NULL,
        'PARAMETRIZACOES', 'ERRO', 'Erro: ' || SQLERRM,
        cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
    ROLLBACK;
    RAISE;
  END pGerarResumo;
/*
-- Resumo das Operações de Exportação das Parametrizações
  FUNCTION fnResumo(
    psgAgrupamento   IN VARCHAR2 DEFAULT NULL,
    psgModulo        IN CHAR     DEFAULT NULL,
    psgConceito      IN VARCHAR2 DEFAULT NULL,
    pdtExportacao    IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoResumoTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') AS dtExportacao, COUNT(*) AS Conteudos
      FROM emigParametrizacao
      WHERE (sgAgrupamento LIKE psgAgrupamento OR psgAgrupamento IS NULL)
        AND (sgModulo LIKE psgModulo OR psgModulo IS NULL)
        AND (sgConceito LIKE psgConceito OR psgConceito IS NULL)
        AND (TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') LIKE pdtExportacao OR pdtExportacao IS NULL)
      GROUP BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtExportacao desc)
    LOOP
      PIPE ROW (tpParametrizacaoResumo(r.sgAgrupamento, r.sgOrgao,
        r.sgModulo, r.sgConceito, r.dtExportacao,
        r.Conteudos));
    END LOOP;
    RETURN;
  END fnResumo;

-- Listar a Exportação das Parametrizações
  FUNCTION fnListar(
    psgAgrupamento   IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    pdtExportacao    IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoListarTabela PIPELINED
  IS
    -- Variáveis de controle e contexto
    vdtExportacao    TIMESTAMP := Null;

  BEGIN

    IF pdtExportacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtExportacao
      FROM emigParametrizacao
      WHERE sgModulo = psgModulo AND psgConceito = psgConceito
        AND sgAgrupamento = psgAgrupamento AND sgOrgao IS NULL;
    ELSE
      vdtExportacao := pdtExportacao;
    END IF;

    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') AS dtExportacao,
        cdIdentificacao,
        JSON_SERIALIZE(TO_CLOB(jsconteudo) RETURNING CLOB PRETTY) AS jsConteudo
      FROM emigParametrizacao
      WHERE (sgAgrupamento = psgAgrupamento)
        AND (sgModulo = psgModulo)
        AND (sgConceito = psgConceito)
        AND (TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI') = vdtExportacao)
      ORDER BY sgAgrupamento, sgModulo, sgConceito, sgOrgao, dtExportacao DESC, cdIdentificacao)
    LOOP
      PIPE ROW (tpParametrizacaoListar(r.sgAgrupamento, r.sgOrgao,
          r.sgModulo, r.sgConceito, r.dtExportacao, 
          r.cdIdentificacao, r.jsConteudo));
    END LOOP;
    RETURN;
  END fnListar;

-- Resumo do Log das Operações de Exportação e Importação das Parametrizações
  FUNCTION fnResumoLog(
    psgAgrupamento   IN VARCHAR2  DEFAULT NULL,
    psgModulo        IN CHAR      DEFAULT NULL,
    psgConceito      IN VARCHAR2  DEFAULT NULL,
    ptpOperacao      IN VARCHAR2  DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT DISTINCT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        COUNT(*) AS nuEventos, SUM(nuRegistros) AS nuRegistros
      FROM emigParametrizacaoLog
      WHERE (tpOperacao LIKE ptpOperacao OR ptpOperacao IS NULL)
        AND (sgAgrupamento LIKE psgAgrupamento OR psgAgrupamento IS NULL)
        AND (sgModulo LIKE psgModulo OR psgModulo IS NULL)
        AND (sgConceito LIKE psgConceito OR psgConceito IS NULL)
        AND nmEvento NOT IN ('RESUMO', 'SEQUENCE', 'JSON')
      GROUP BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito
      ORDER BY tpOperacao, dtOperacao DESC, sgAgrupamento, sgOrgao, sgModulo, sgConceito)
    LOOP
      PIPE ROW (tpParametrizacaoLogResumo(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito, r.nuEventos, r.nuRegistros));
    END LOOP;
    RETURN;
  END fnResumoLog;

-- Resumo do Log das Operações de Exportação e Importação das Parametrizações
  FUNCTION fnResumoLogEntidades(
    psgAgrupamento   IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogResumoEntidadesTabela PIPELINED
  IS
    -- Variáveis de controle e contexto
    vdtOperacao    TIMESTAMP := Null;

  BEGIN

    IF pdtOperacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtOperacao
      FROM emigParametrizacao
      WHERE sgModulo = psgModulo AND psgConceito = psgConceito
        AND sgAgrupamento = psgAgrupamento;
    ELSE
      vdtOperacao := pdtOperacao;
    END IF;

    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
	      sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade,
        COUNT(*) as nuEventos, SUM(nuRegistros) as nuRegistros
      FROM emigParametrizacaoLog
      WHERE tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = vdtOperacao
        AND nmevento != 'RESUMO'
      GROUP BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      ORDER BY tpOperacao, dtOperacao DESC, sgAgrupamento, sgModulo, sgConceito, sgOrgao, nmEntidade)
    LOOP
      PIPE ROW (tpParametrizacaoLogResumoEntidades(r.tpOperacao, r.dtOperacao,
	    r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
		  r.nmEntidade, r.nuEventos, r.nuRegistros));
    END LOOP;
    RETURN;
  END fnResumoLogEntidades;

-- Listar o Log da Operação de Exportação ou Importação das Parametrizações
  FUNCTION fnListarLog(
    psgAgrupamento   IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN VARCHAR2 DEFAULT NULL
  ) RETURN tpParametrizacaoLogListarTabela PIPELINED
  IS
    -- Variáveis de controle e contexto
    vdtOperacao    TIMESTAMP := Null;

  BEGIN

    IF pdtOperacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtOperacao
      FROM emigParametrizacao
      WHERE sgModulo = psgModulo AND psgConceito = psgConceito
        AND sgAgrupamento = psgAgrupamento;
    ELSE
      vdtOperacao := pdtOperacao;
    END IF;

    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        nmEntidade, cdidentificacao, nmEvento, nuRegistros, deMensagem, dtInclusao
      FROM emigParametrizacaoLog
      WHERE tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = vdtOperacao
      ORDER BY dtInclusao, tpOperacao, dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        cdIdentificacao NULLS FIRST, nmEvento, deMensagem)
    LOOP
      PIPE ROW (tpParametrizacaoLogListar(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
        r.nmEntidade, r.cdidentificacao, r.nmEvento, r.nuRegistros, r.deMensagem, r.dtInclusao));
    END LOOP;
    RETURN;
  END fnListarLog;

  PROCEDURE pExcluirLog(
    psgAgrupamento    IN VARCHAR2,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN VARCHAR2
  ) IS
  BEGIN
    DELETE FROM emigParametrizacaoLog
      WHERE tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = pdtOperacao
        AND sgAgrupamento = psgAgrupamento
        AND sgModulo = psgModulo AND sgConceito = psgConceito;
    COMMIT;
  END PExcluirLog;
*/
END PKGMIG_Parametrizacao;
/

