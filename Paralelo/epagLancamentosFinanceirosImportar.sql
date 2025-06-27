/*
 * PROCEDURE: pkgpag_paralelo.PAjustarLancamentos
 * DESCRIÇÃO: Ajusta lançamentos financeiros conforme parâmetros fornecidos, permitindo inclusão,
 *            alteração, exclusão, anulação ou reversão de lançamentos, além de ajuste de valores
 *            e índices conforme necessidade.
 *
 * PARÂMETROS OBRIGATÓRIOS:
 *   - pAcao:          Define a ação a ser executada (default: 'I' - Inclusão)
 *   - pCompetencia:   Competência no formato YYYYMM (default: 202411 - Nov/2025)
 *   - pAgrupamento:   Código do agrupamento (default: 19)
 *
 * PARÂMETROS OPCIONAIS:
 *   - pOrgao:         Código do órgão (opcional)
 *   - pTpRubrica:     Tipo de rubrica (P-Proventos, D-Descontos, ou NULL-Todos)
 *   - pTipoInclusao:  Tipo de inclusão quando ação for 'I' (I-Índice, V-Valor, NULL-Ambos)
 *   - pNuRubrica:     Lista de rubricas a serem ajustadas (coleção vazia para todas)
 *   - pExcetoNuRubrica: Lista de rubricas a serem excluídas do ajuste (coleção vazia para nenhuma)
 *   - pNuSufixoRubrica: Sufixo das rubricas (opcional)
 *   - pNovoIndice:    Novo índice para atualização (opcional)
 *   - pNovoValor:     Novo valor para atualização (opcional)
 *   - pFixarDiferencas: Fixar diferenças (S/N, default 'N')
 *   - pDescricaoLanc: Descrição para os lançamentos (opcional)
 *   - pGerarSaida:    Gerar saída no DBMS Output (S/N, default 'N')
 *   - pRetorno:       Retorno da procedure (OUT)
 *
 * VALORES POSSÍVEIS PARA pAcao:
 *   - 'I': Inclusão de lançamentos conforme folha normal (migrada)
 *   - 'A': Alteração de lançamentos existentes
 *   - 'E': Exclusão de lançamentos
 *   - 'Z': Zerar diferenças entre recálculo e folha migrada
 *   - 'N': Anular lançamentos
 *   - 'R': Reverter lançamentos anulados
 */
DECLARE
  -- Parâmetros obrigatórios com valores default
  pAcao          CHAR         := 'I';          -- Default: Inclusão
  pCompetencia   INTEGER      := 202505;       -- Default: Nov/2025
  pAgrupamento   INTEGER      := 19;           -- Default: Agrupamento 19
  
  -- Parâmetros opcionais inicializados como NULL
  pOrgao         INTEGER      := NULL;
  pTpRubrica     CHAR         := 'P';
  pTipoInclusao  CHAR         := 'I';
  pNuSufixoRubrica INTEGER    := NULL;
  pNovoIndice    VARCHAR2(20) := NULL;
  pNovoValor     VARCHAR2(20) := NULL;
  pFixarDiferencas CHAR       := 'N';          -- Default: Não fixar diferenças
  pDescricaoLanc VARCHAR2(100) := NULL;
  pGerarSaida    CHAR         := 'N';          -- Default: Não gerar saída
  
  -- Coleções vazias para listas de rubricas
  pNuRubrica       tRubricas := tRubricas();
  pExcetoNuRubrica tRubricas := tRubricas();

  -- Variável de retorno
  pRetorno       VARCHAR2(4000);

BEGIN
  -- Validação básica dos parâmetros obrigatórios
  IF pAcao NOT IN ('I', 'A', 'E', 'Z', 'N', 'R') THEN
    RAISE_APPLICATION_ERROR(-20001, 'Ação inválida. Valores permitidos: I, A, E, Z, N, R');
  END IF;
  
  IF pCompetencia IS NULL OR LENGTH(TO_CHAR(pCompetencia)) != 6 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Competência inválida. Deve estar no formato YYYYMM');
  END IF;
  
  IF pAgrupamento IS NULL THEN
    RAISE_APPLICATION_ERROR(-20003, 'Agrupamento não pode ser nulo');
  END IF;

  pCompetencia := 202505; -- Nov/2024
  pAgrupamento := 19;     -- Militares
  pAcao := 'E';           -- Exclusão
  pTpRubrica := Null;     -- Todos
  pTipoInclusao := Null;  -- Indices e Valores
  pNuRubrica := tRubricas();
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Proventos Valor Informados
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'P';      -- Proventos
  pTipoInclusao := Null;  -- Indices e Valores
  pNuRubrica := tRubricas();
  pExcetoNuRubrica := tRubricas(
     -- Proventos Oriundas do Cadastro Funcional
    '0001', '0002', '0036', '0062', '0181', '0524', '2040', '4199',
     -- Proventos Calculadas
    '0060', '1307', '6801', '7990',
    '0029', '0236', '0237', '0238', '0815', '1300', '1505', 
    '4066', '4200', '4853', '4859', '4909', '4910'
  );
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Proventos Calculados Com Indices
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'P';      -- Proventos
  pTipoInclusao := 'I';   -- Somente Indices
  pNuRubrica := tRubricas(
    -- Proventos Calculadas
    '0029', '0236', '0237', '0238', '0815', '1300', '1505', 
    '4066', '4200', '4853', '4859', '4909', '4910'
  );
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Proventos Calculados sem Indices
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'P';      -- Proventos
  pTipoInclusao := 'I';   -- Somente Indices
  pNovoIndice := Null;    -- Sem Indices
  pNuRubrica := tRubricas(
    -- Proventos Calculadas
    '0060', '1307', '6801', '7990'
  );
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Descontos sem Tributos
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'D';      -- Descontos
  pTipoInclusao := Null;  -- Indices e Valores
  pNuRubrica := tRubricas();
  pExcetoNuRubrica := tRubricas(
     -- Tributos
    '0003', '0004', '0182', '0199', '0227',
     -- Consignações
    '0012', '0036', '0111', '0112', '0113', '0114', '0115', '0116', '0130', '0132', '0146', '0147',
    '0150', '0152', '0160', '0161', '0162', '0167', '0169', '0173', '0194',
    '0226', '0246', '0247', '0249', '0250', '0251', '0254', '0262', '0267', '0272',
    '0537', '0538', '0550', '0551', '0556', '0559', '0561', '0564', '0574', '0576', '0579', '0589', '0590', '0591',
    '0631', '0651', '0661', '0683', '0747', '0748', '0750', '0765', '0768', '0790', '0791',
    '0810', '0811', '0813', '0850', '0900', '0901', '0902', '0903', '0950', '0974',
    '1101', '1102', '1103', '1104', '1528', '1533', '1534', '1601', '1603', '1637', '1816', '1821', '1822', '1823', '1827', '1833', '1834', '4120', '4278'
  );
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Descontos Diferenças de Tributos (IPER e INSS)
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'D';      -- Descontos
  pTipoInclusao := 'V';   -- Somente Valores
  pNuRubrica := tRubricas('0003', '0182');
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);

  -- Descontos Excluir Tributos Sufixo 01 (IPER e INSS)
  pAcao := 'E';           -- Inclusão
  pTpRubrica := 'D';      -- Proventos
  pTipoInclusao := null;  -- Indices e Valores
  pNuSufixoRubrica := 01;
  pNuRubrica := tRubricas('0003', '0182');
  pExcetoNuRubrica := tRubricas();
  pkgpag_paralelo.PAjustarLancamentos(
    pAcao => pAcao,
    pCompetencia => pCompetencia,
    pAgrupamento => pAgrupamento,
    pOrgao => pOrgao,
    pTpRubrica => pTpRubrica,
    pTipoInclusao => pTipoInclusao,
    pNuRubrica => pNuRubrica,
    pExcetoNuRubrica => pExcetoNuRubrica,
    pNuSufixoRubrica => pNuSufixoRubrica,
    pNovoIndice => pNovoIndice,
    pNovoValor => pNovoValor,
    pFixarDiferencas => pFixarDiferencas,
    pDescricaoLanc => pDescricaoLanc,
    pGerarSaida => pGerarSaida,
    pRetorno => pRetorno
  );
  -- Exibe o retorno da procedure
  DBMS_OUTPUT.PUT_LINE('Resultado: ' || pRetorno);


EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    RAISE;
END;
/