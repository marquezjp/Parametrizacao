-- Corpo do Pacote de Auditoria da Exportação e Importação das Parametrizações
CREATE OR REPLACE PACKAGE BODY PKGMIG_ParametrizacaoLog AS

  FUNCTION fnObterParametro(
    pjsParametros          IN VARCHAR2 DEFAULT NULL,
    pflParamentrosOpcional IN CHAR DEFAULT 'N'
  ) RETURN tpmigParametroEntrada IS

    vParm tpmigParametroEntrada := NEW tpmigParametroEntrada(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

    vDocJSON          JSON_OBJECT_T;
    vChavesJSON       JSON_KEY_LIST;

    TYPE tabChaves IS TABLE OF VARCHAR2(50);
    vChavesValidasJSON    JSON_KEY_LIST;
    vChavesValidas tabChaves := tabChaves();

    vtxParametroFormato CONSTANT VARCHAR2(4000) := '
      {
        "sgAgrupamento": "Sigla do Agrupamento para Exportação ou Importação das Parametrizações [Obrigatorio]",
        "sgAgrupamentoDestino": "Sigla do Agrupamento de Destino para Importação das Parametrizações [Opcional]",
        "sgOrgao": "Sigla do Órgão para Exportação e Importação das Parametrizações [Opcional]",
        "sgModulo": "Sigla do Modulo para Exportação e Importação das Parametrizações [Opcional]",
        "sgConceito": "Sigla do Conceito para Exportação ou Importação das Parametrizações [Obrigatorio]",
        "sgEntidades": "Lista das Siglas das Entidades para Importação das Parametrizações [Opcional]",
        "cdIdentificacao": "Código da identificação do Conceito para Exportação ou Importação das Parametrizações [Opcional]",
        "tpOperacao": "Tipo da Operação para Indicar se é Exportação ou Importação das Parametrizações [Opcional]",
        "dtOperacao": "Data da Operação de Exportação ou Importação das Parametrizações [Opcional]",
        "nmNivelAuditoria": "Nível da Auditoria [Opcional]"
      }';

    vtxMensagem       VARCHAR2(50);

  BEGIN
    vChavesValidasJSON := JSON_OBJECT_T.PARSE(vtxParametroFormato).GET_KEYS;
    FOR i IN 1 .. vChavesValidasJSON.COUNT LOOP
      vChavesValidas.EXTEND;
      vChavesValidas(vChavesValidas.LAST) := vChavesValidasJSON(i);
    END LOOP;
    
    IF NVL(TRIM(pjsParametros),' ') = ' ' THEN
      IF pflParamentrosOpcional = 'N' THEN
        RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_INVALIDO, 'Parâmetro "pjsParametros" não foi informado ou está vazio. ' ||
          'Deveria ser informado da seguinte forma:' || vtxParametroFormato);
      ELSE
        RETURN vParm;
      END IF;
    END IF;

    vDocJSON := JSON_OBJECT_T.PARSE(pjsParametros);
    vChavesJSON := vDocJSON.GET_KEYS;
    IF vChavesJSON.COUNT = 0 THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_NAO_INFORMADO, 'Parâmetro "pjsParametros" está vazio.');
    END IF;

    FOR i IN 1 .. vChavesJSON.COUNT LOOP
      IF vChavesJSON(i) NOT MEMBER OF vChavesValidas THEN
        RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_INVALIDO, 'Parâmetro "' || vChavesJSON(i) || '" inexistente.' ||
          'Parâmetro validos são: ' || vtxParametroFormato);
      END IF;
    END LOOP;

    vParm.nuNivelAuditoria := fnObterNivelAuditoria(fnObterChave(pjsParametros, 'nmNivelAuditoria'));

    vParm.sgAgrupamento := UPPER(TRIM(fnObterChave(pjsParametros, 'sgAgrupamento')));
    IF pflParamentrosOpcional = 'N' AND vParm.sgAgrupamento IS NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_OBRIGATORIO,
        'Agrupamento não Informado.');
    ELSIF fnValidarAgrupamento(vParm.sgAgrupamento) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Informado não Cadastrado.: "' || vParm.sgAgrupamento || '".');
    END IF;

    vParm.sgAgrupamentoDestino := UPPER(TRIM(fnObterChave(pjsParametros, 'sgAgrupamentoDestino')));
    IF vParm.sgAgrupamentoDestino IS NULL THEN
      IF pflParamentrosOpcional = 'N' THEN
        vParm.sgAgrupamentoDestino := vParm.sgAgrupamento;
      END IF;
    ELSIF fnValidarAgrupamento(vParm.sgAgrupamentoDestino) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_AGRUPAMENTO_INVALIDO,
        'Agrupamento Destino Informado não Cadastrado.: "' || vParm.sgAgrupamentoDestino || '".');
    END IF;

    vParm.sgOrgao := UPPER(TRIM(fnObterChave(pjsParametros, 'sgOrgao')));
    IF vParm.sgOrgao IS NOT NULL AND fnValidarOrgao(vParm.sgOrgao) IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(cERRO_ORGAO_INVALIDO,
        'Orgao Informado não Cadastrado.: "' || vParm.sgOrgao || '".');
    END IF;

    vParm.sgModulo := UPPER(TRIM(fnObterChave(pjsParametros, 'sgModulo')));
    IF vParm.sgModulo IS NULL THEN
      IF pflParamentrosOpcional = 'N' THEN
        vParm.sgModulo := 'PAG';
      END IF;
    ELSIF vParm.sgModulo NOT IN ('PAG') THEN
      RAISE_APPLICATION_ERROR(cERRO_MODULO_INVALIDO,
        'Modulo não suportado: "' || vParm.sgModulo || '", ' ||
        'Modulo suportado: "PAG".');
    END IF;

    vParm.sgConceito := UPPER(TRIM(fnObterChave(pjsParametros, 'sgConceito')));
    IF vParm.sgConceito IS NULL THEN
      IF pflParamentrosOpcional = 'N' THEN
        RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_OBRIGATORIO,
          'Conceito não Informado: "' || vParm.sgConceito || '", ' ||
          'Conceitos suportados: "VALORREFERENCIA"; "BASECALCULO"; e "RUBRICA".');
       END IF;
    ELSIF vParm.sgConceito NOT IN ('VALORREFERENCIA', 'BASECALCULO', 'RUBRICA') THEN
      RAISE_APPLICATION_ERROR(cERRO_CONCEITO_INVALIDO,
        'Conceito não suportado: "' || vParm.sgConceito || '", ' ||
        'Conceitos suportados: "VALORREFERENCIA"; "BASECALCULO"; e "RUBRICA".');
    END IF;

    vParm.cdIdentificacao := UPPER(TRIM(fnObterChave(pjsParametros, 'cdIdentificacao')));

    vParm.tpOperacao := UPPER(TRIM(fnObterChave(pjsParametros, 'tpOperacao')));
    IF vParm.tpOperacao IS NOT NULL AND
       vParm.tpOperacao NOT IN ('EXPORTACAO', 'IMPORTACAO') THEN
      RAISE_APPLICATION_ERROR(cERRO_TIPO_OPERACAO_INVALIDO,
        'Tipo Operação não suportado: "' || vParm.tpOperacao || '", ' ||
        'Operações suportadas: "EXPORTACAO"; "IMPORTACAO".');
    END IF;

    vParm.dtOperacao := UPPER(TRIM(fnObterChave(pjsParametros, 'dtOperacao')));

    RETURN vParm;
  END fnObterParametro;

  FUNCTION fnObterChave(
    pjsParametros     IN VARCHAR2 DEFAULT NULL,
    pnmChave          IN VARCHAR2 DEFAULT NULL,
    ptxPadrao         IN VARCHAR2 DEFAULT NULL,
    ptxFormato        IN VARCHAR2 DEFAULT 'YYYY-MM-DD'
  ) RETURN VARCHAR2 IS

    vDocJSON          JSON_OBJECT_T;
    vChavesJSON       JSON_KEY_LIST;
    vElementoJSON     JSON_ELEMENT_T;
    vObjetoJSON       JSON_OBJECT_T;
    vVetorJSON        JSON_ARRAY_T;

    vnmChave          VARCHAR2(50);
    vtxValor          VARCHAR2(4000);

  BEGIN
    vDocJSON := JSON_OBJECT_T.PARSE(pjsParametros);
    vChavesJSON := vDocJSON.GET_KEYS;
    IF vChavesJSON.COUNT = 0 THEN
      RAISE_APPLICATION_ERROR(cERRO_PARAMETRO_NAO_INFORMADO, 'Parâmetro "pjsParametros" está vazio.');
    END IF;

    CASE UPPER(pnmChave)
      WHEN 'NMNIVELAUDITORIA'     THEN vnmChave := 'nmNivelAuditoria';
      WHEN 'SGAGRUPAMENTO'        THEN vnmChave := 'sgAgrupamento';
      WHEN 'SGAGRUPAMENTODESTINO' THEN vnmChave := 'sgAgrupamentoDestino';
      WHEN 'SGORGAO'              THEN vnmChave := 'sgOrgao';
      WHEN 'SGMODULO'             THEN vnmChave := 'sgModulo';
      WHEN 'SGCONCEITO'           THEN vnmChave := 'sgConceito';
      WHEN 'SGENTIDADES'          THEN vnmChave := 'sgEntidades';
      WHEN 'CDIDENTIFICACAO'      THEN vnmChave := 'cdIdentificacao';
      WHEN 'TPOPERACAO'           THEN vnmChave := 'tpOperacao';
      WHEN 'DTOPERACAO'           THEN vnmChave := 'dtOperacao';
      ELSE vnmChave := NULL;
    END CASE;

    IF vDocJSON IS NULL OR NOT vDocJSON.has(vnmChave) THEN
      RETURN ptxPadrao;
    END IF;
    
    vElementoJSON := vDocJSON.get(vnmChave);

    CASE
      WHEN vElementoJSON.IS_NULL THEN
        vtxValor := ptxPadrao;
      WHEN vElementoJSON.IS_STRING THEN
        vtxValor := vDocJSON.GET_STRING(vnmChave);
      WHEN vElementoJSON.IS_NUMBER THEN
        vtxValor := TO_CHAR(vDocJSON.GET_NUMBER(vnmChave));
      WHEN vElementoJSON.IS_BOOLEAN THEN
        vtxValor := CASE WHEN vDocJSON.GET_BOOLEAN(vnmChave) THEN 'S' ELSE 'N' END;
      WHEN vElementoJSON.IS_DATE THEN
        vtxValor := TO_CHAR(vDocJSON.GET_DATE(vnmChave), ptxFormato);
      WHEN vElementoJSON.Is_Object THEN
        vObjetoJSON := TREAT (vElementoJSON AS JSON_OBJECT_T);
        vtxValor := vObjetoJSON.STRINGIFY;
      WHEN vElementoJSON.Is_Array THEN
        vElementoJSON := TREAT (vElementoJSON as JSON_ARRAY_T);
        vtxValor := vVetorJSON.STRINGIFY;
      ELSE
        vtxValor := ptxPadrao;
    END CASE;

    RETURN vtxValor;

  END fnObterChave;

  FUNCTION fnObterNivelAuditoria(
    pNivelAuditoria   IN VARCHAR2
  ) RETURN PLS_INTEGER IS
    BEGIN
      CASE UPPER(TRIM(NVL(pNivelAuditoria, 'ESSENCIAL')))
        WHEN 'SILENCIADO' THEN RETURN cAUDITORIA_SILENCIADO;
        WHEN 'ESSENCIAL'  THEN RETURN cAUDITORIA_ESSENCIAL;
        WHEN 'DETALHADO'  THEN RETURN cAUDITORIA_DETALHADO;
        WHEN 'COMPLETO'   THEN RETURN cAUDITORIA_COMPLETO;
        ELSE RETURN cAUDITORIA_ESSENCIAL;
      END CASE;
  END;

  FUNCTION fnValidarAgrupamento(
    psgAgrupamento    IN VARCHAR2
  ) RETURN VARCHAR2 IS
    vcdAgrupamento    NUMBER;
    BEGIN
      SELECT cdAgrupamento INTO vcdAgrupamento FROM ecadAgrupamento
        WHERE sgAgrupamento = psgAgrupamento;

      RETURN NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Agrupamento Informado não Cadastrado.';
  END fnValidarAgrupamento;

  FUNCTION fnValidarOrgao(
    psgOrgao          IN VARCHAR2
  ) RETURN VARCHAR2 IS
    vcdOrgao          NUMBER;
    BEGIN
      SELECT cdOrgao INTO vcdOrgao FROM ecadHistOrgao
        WHERE sgOrgao = psgOrgao;

      RETURN NULL;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Orgao Informado não Cadastrado.';
  END fnValidarOrgao;

  PROCEDURE pAlertar(
  -- ###########################################################################
  -- PROCEDURE: pAlertar
  -- Objetivo:
  --   Mostrar os eventos de auditoria na saída padrão, Console.
  --
  -- Parâmetros:
  --   pdeMensagem       IN VARCHAR2: Mensagem detalhada sobre a operação registrada.
  --   pnuNivelLog       IN VARCHAR2 DEFAULT NULL: Defini o nível do evento.
  --   pnuNivelAuditoria IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens
  --                        para acompanhar a execução, sendo:
  --                        - Não informado assume 'ESSENCIAL' nível mínimo de mensagens;
  --                        - Se informado 'SILENCIADO' omite todas as mensagens;
  --                        - Se informado 'ESSENCIAL' inclui as mensagens das
  --                          principais todas entidades, menos as listas;
  --                        - Se informado 'DETALHADO' inclui as mensagens de todas 
  --                          entidades, incluindo as referente as tabelas das listas;
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
  END pAlertar;

  PROCEDURE pRegistrar(
  -- ###########################################################################
  -- PROCEDURE: pRegistrar
  -- Objetivo:
  --   Registrar eventos de auditoria, controle ou estatística no processo de
  --   Exportação e Importação das Parametrizações (rubricas, bases, valores, etc.).
  --   Os registros são inseridos na tabela emigParametrizacaoLog.
  --
  -- Parâmetros:
  --   psgAgrupamento    IN VARCHAR2: Sigla do Agrupamento relacionado ao evento.
  --   psgOrgao          IN VARCHAR2: Sigla do Órgão, se nulo se refere a todos os órgãos.
  --   ptpOperacao       IN VARCHAR2: Se o evento é de EXPORTACAO ou de IMPORTACAO.
  --   pdtOperacao       IN TIMESTAMP: Data e hora do incio da operação relacionada a todos os evento da operação.
  --   psgModulo         IN CHAR: Sigla do Módulo que originou o evento .
  --   psgConceito       IN VARCHAR2: Conceito associado à parametrização.
  --   pcdIdentificacao  IN VARCHAR2: Código Identificador da Entidade Parametrizada afetada pela operação.
  --   nmEntidade        IN VARCHAR2: Entidade dentro do Conceito associado à parametrização, grupo de informações do Conceito.
  --   pnmEvento         IN VARCHAR2: Nome do evento (INCLUSAO, ATUALIZACAO, EXCLUSAO, RESUMO).
  --   pdeMensagem       IN VARCHAR2: Mensagem detalhada sobre a operação registrada.
  --   pnuNivelLog       IN VARCHAR2 DEFAULT NULL: Defini o nível do evento.
  --   pnuNivelAuditoria IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens.
  --                        para acompanhar a execução, sendo:
  --                        - Não informado assume 'ESSENCIAL' nível mínimo de mensagens;
  --                        - Se informado 'SILENCIADO' omite todas as mensagens;
  --                        - Se informado 'ESSENCIAL' inclui as mensagens das
  --                          principais todas entidades, menos as listas;
  --                        - Se informado 'DETALHADO' inclui as mensagens de todas 
  --                          entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pcdIdentificacao  IN VARCHAR2,
    pnuRegistros      IN NUMBER,
    pnmEntidade       IN VARCHAR2,
    pnmEvento         IN VARCHAR2,
    pdeMensagem       IN VARCHAR2,
    pnuNivelLog       IN NUMBER DEFAULT NULL,
    pnuNivelAuditoria IN NUMBER DEFAULT NULL
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
  END pRegistrar;

  PROCEDURE pRegistrarErro(
  -- ###########################################################################
  -- PROCEDURE: pRegistrarErro
  -- Objetivo:
  --   Registrar eventos de erro
  --   Os registros são inseridos na tabela emigParametrizacaoLog.
  --
  -- Parâmetros:
  --   psgAgrupamento    IN VARCHAR2: Sigla do Agrupamento relacionado ao evento.
  --   psgOrgao          IN VARCHAR2: Sigla do Órgão, se nulo se refere a todos os órgãos.
  --   ptpOperacao       IN VARCHAR2: Se o evento é de EXPORTACAO ou de IMPORTACAO.
  --   pdtOperacao       IN TIMESTAMP: Data e hora do incio da operação relacionada a todos os evento da operação.
  --   psgModulo         IN CHAR: Sigla do Módulo que originou o evento .
  --   psgConceito       IN VARCHAR2: Conceito associado à parametrização.
  --   pcdIdentificacao  IN VARCHAR2: Código Identificador da Entidade Parametrizada afetada pela operação.
  --   nmEntidade        IN VARCHAR2: Entidade dentro do Conceito associado à parametrização, grupo de informações do Conceito.
  --   pnmEvento         IN VARCHAR2: Nome do evento (INCLUSAO, ATUALIZACAO, EXCLUSAO, RESUMO).
  --   pdeMensagem       IN VARCHAR2: Mensagem detalhada sobre a operação registrada.
  --   pnuNivelLog       IN VARCHAR2 DEFAULT NULL: Defini o nível do evento.
  --   pnuNivelAuditoria IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens.
  --                        para acompanhar a execução, sendo:
  --                        - Não informado assume 'ESSENCIAL' nível mínimo de mensagens;
  --                        - Se informado 'SILENCIADO' omite todas as mensagens;
  --                        - Se informado 'ESSENCIAL' inclui as mensagens das
  --                          principais todas entidades, menos as listas;
  --                        - Se informado 'DETALHADO' inclui as mensagens de todas 
  --                          entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    psgAgrupamento    IN VARCHAR2,
    psgOrgao          IN VARCHAR2,
    ptpOperacao       IN VARCHAR2,
    pdtOperacao       IN TIMESTAMP,
    psgModulo         IN CHAR,
    psgConceito       IN VARCHAR2,
    pcdIdentificacao  IN VARCHAR2,
    pnmEntidade       IN VARCHAR2,
    pnmObjeto         IN VARCHAR2,
    pcdSQLERRM        IN VARCHAR2
  ) IS

    BEGIN
      -- Registro e Propagação do Erro
      IF NOT gflErroRegistrado THEN
        PKGMIG_ParametrizacaoLog.pAlertar(pnmObjeto || ' ' || pnmEntidade || ' ' || pcdIdentificacao || ' ' ||
          'Erro: ' || pcdSQLERRM, cAUDITORIA_ESSENCIAL, cAUDITORIA_ESSENCIAL);
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 1,
          pnmEntidade, 'ERRO', 'Erro: ' || pcdSQLERRM,
          cAUDITORIA_ESSENCIAL, cAUDITORIA_ESSENCIAL);
          gflErroRegistrado := TRUE;
      ELSE
        PKGMIG_ParametrizacaoLog.pAlertar(pnmObjeto || ' ' || pnmEntidade || ' ' || pcdIdentificacao || ' ' ||
          'Finalizado antecipadamente', cAUDITORIA_ESSENCIAL, cAUDITORIA_ESSENCIAL);
        PKGMIG_ParametrizacaoLog.pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, pcdIdentificacao, 1,
          pnmEntidade, 'ERRO', 'Finalizado antecipadamente',
          cAUDITORIA_ESSENCIAL, cAUDITORIA_ESSENCIAL);
      END IF;
  END pRegistrarErro;

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
  --   pnuNivelAuditoria     IN NUMBER DEFAULT NULL:
  --
  -- ###########################################################################
    psgAgrupamento        IN VARCHAR2,
    psgOrgao              IN VARCHAR2,
    ptpOperacao           IN VARCHAR2,
    pdtOperacao           IN TIMESTAMP,
    psgModulo             IN CHAR,
    psgConceito           IN VARCHAR2,
    pListaTabelas         IN CLOB,
    pnuNivelAuditoria     IN NUMBER DEFAULT NULL
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

      pAlertar('Atualizar as SEQUENCE após Importação das Parametrização ' || psgConceito);

      FOR item IN cDados
        LOOP
          -- Obtendo o Maior Número da Chave Primaria da Tabela
          vtxSQL := 'SELECT NVL(MAX(' || item.column_name || '), 0) + 1 FROM ' || item.table_name;
          EXECUTE IMMEDIATE vtxSQL INTO vnuRegistros;

          pAlertar('SEQUENCE ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' reiniciada em: ' || vnuRegistros,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

          -- Atualizar a SEQUENCE com o Maior Número da Chave Primaria da Tabela
          EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || item.sequence_name || ' RESTART START WITH ' || CASE WHEN vnuRegistros = 0 THEN 1 ELSE vnuRegistros END;
          EXECUTE IMMEDIATE 'ANALYZE TABLE ' || UPPER(item.table_name) || ' COMPUTE STATISTICS';

          pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
            psgModulo, psgConceito, NULL, NULL,
            'SEQUENCE', 'SEQUENCE',
            'RESUMO - ' || item.sequence_name || ' da Tabela ' || item.table_name ||
            ' reiniciada em: ' || vnuRegistros,
            cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'SEQUENCE',
          'Atualizar as SEQUENCE após Importação das Parametrizações (PKGMIG_ParametrizacaoLog.pAtualizarSequence)', SQLERRM);
      ROLLBACK;
      RAISE;
  END pAtualizarSequence;

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
      AND tpOperacao = ptpOperacao AND dtOperacao = pdtOperacao
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
    pRegistrar(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,
      psgModulo, psgConceito, NULL, NULL,
      'RESUMO', 'RESUMO', vResumoEstatisticas,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    pAlertar('Resumo da Importação das Parametrizações do Agrupamento ' || psgAgrupamento,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    pAlertar('Estatísticas: ' || vResumoEstatisticas,
      cAUDITORIA_ESSENCIAL, pnuNivelAuditoria);

    EXCEPTION
      WHEN OTHERS THEN
      -- Registro e Propagação do Erro
        PKGMIG_ParametrizacaoLog.pRegistrarErro(psgAgrupamento, psgOrgao, ptpOperacao, pdtOperacao,  
          psgModulo, psgConceito, NULL, 'RESUMO',
          'Resumo da Importação das Parametrizações (PKGMIG_ParametrizacaoLog.pGerarResumo)', SQLERRM);
      RAISE;
  END pGerarResumo;

-- Resumo do Log das Operações de Exportação e Importação das Parametrizações
  FUNCTION fnResumo(pjsParametros IN VARCHAR2 DEFAULT NULL
  ) RETURN tpmigParametrizacaoLogResumoTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vParm                 tpmigParametroEntrada;

  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros,'S');

    FOR r IN (
      SELECT DISTINCT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        COUNT(*) AS nuEventos, SUM(nuRegistros) AS nuRegistros
      FROM emigParametrizacaoLog
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL)
        AND (tpOperacao LIKE vParm.tpOperacao OR vParm.tpOperacao IS NULL)
        AND nmEvento NOT IN ('RESUMO', 'SEQUENCE', 'JSON')
      GROUP BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito
      ORDER BY tpOperacao, dtOperacao DESC, sgAgrupamento, sgOrgao, sgModulo, sgConceito)
    LOOP
      PIPE ROW (tpmigParametrizacaoLogResumo(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito, r.nuEventos, r.nuRegistros));
    END LOOP;
    RETURN;
  END fnResumo;

-- Resumo do Log das Operações de Exportação e Importação das Parametrizações
  FUNCTION fnResumoEntidades(pjsParametros IN VARCHAR2 DEFAULT NULL
  ) RETURN tpmigParametrizacaoLogResumoEntidadesTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vParm                 tpmigParametroEntrada;
    vdtOperacao    TIMESTAMP := Null;

  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros,'S');

    IF vParm.dtOperacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtOperacao
      FROM emigParametrizacao
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL);
    ELSE
      vdtOperacao := vParm.dtOperacao;
    END IF;

    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
	      sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade,
        COUNT(*) as nuEventos, SUM(nuRegistros) as nuRegistros
      FROM emigParametrizacaoLog
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL)
        AND (tpOperacao LIKE vParm.tpOperacao OR vParm.tpOperacao IS NULL)
        AND TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = vdtOperacao
        AND nmevento != 'RESUMO'
      GROUP BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      ORDER BY tpOperacao, dtOperacao DESC, sgAgrupamento, sgModulo, sgConceito, sgOrgao, nmEntidade)
    LOOP
      PIPE ROW (tpmigParametrizacaoLogResumoEntidades(r.tpOperacao, r.dtOperacao,
	    r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
		  r.nmEntidade, r.nuEventos, r.nuRegistros));
    END LOOP;
    RETURN;
  END fnResumoEntidades;

-- Listar o Log da Operação de Exportação ou Importação das Parametrizações
  FUNCTION fnListar(pjsParametros IN VARCHAR2 DEFAULT NULL
  ) RETURN tpmigParametrizacaoLogListarTabela PIPELINED IS
    -- Variáveis de controle e contexto
    vParm                 tpmigParametroEntrada;
    vdtOperacao    TIMESTAMP := Null;

  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros,'S');

    IF vParm.dtOperacao IS NULL THEN
      SELECT TO_CHAR(MAX(dtExportacao), 'DD/MM/YYYY HH24:MI') INTO vdtOperacao
      FROM emigParametrizacao
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL);
    ELSE
      vdtOperacao := vParm.dtOperacao;
    END IF;

    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') AS dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        nmEntidade, cdidentificacao, nmEvento, nuRegistros, deMensagem, dtInclusao
      FROM emigParametrizacaoLog
      WHERE (sgAgrupamento LIKE vParm.sgAgrupamento OR vParm.sgAgrupamento IS NULL)
        AND (sgModulo LIKE vParm.sgModulo OR vParm.sgModulo IS NULL)
        AND (sgConceito LIKE vParm.sgConceito OR vParm.sgConceito IS NULL)
        AND (tpOperacao LIKE vParm.tpOperacao OR vParm.tpOperacao IS NULL)
        AND (TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = vdtOperacao)
      ORDER BY dtInclusao, tpOperacao, dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        cdIdentificacao NULLS FIRST, nmEvento, deMensagem)
    LOOP
      PIPE ROW (tpmigParametrizacaoLogListar(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
        r.nmEntidade, r.cdidentificacao, r.nmEvento, r.nuRegistros, r.deMensagem, r.dtInclusao));
    END LOOP;
    RETURN;
  END fnListar;

  PROCEDURE pExcluir(pjsParametros IN VARCHAR2 DEFAULT NULL) IS
    -- Variáveis de controle e contexto
    vParm                 tpmigParametroEntrada;
  BEGIN
    vParm := PKGMIG_ParametrizacaoLog.fnObterParametro(pjsParametros);

    DELETE FROM emigParametrizacaoLog
      WHERE tpOperacao = vParm.tpOperacao
        AND TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') = vParm.dtOperacao
        AND sgAgrupamento = vParm.sgAgrupamento
        AND sgModulo = vParm.sgModulo AND sgConceito = vParm.sgConceito;
    COMMIT;
  END PExcluir;

END PKGMIG_ParametrizacaoLog;
/
