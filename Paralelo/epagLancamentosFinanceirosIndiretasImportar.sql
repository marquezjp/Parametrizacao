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

/*
 AGRUPAMENTOS
2, 11, 12, 13
'IATER', 'ADERR', 'IERR', 'IPEM-RR'

29	ADERR	AGENCIA DE DEFESA AGROPECUARIA DO ESTADO DE RORAIMA
38	IATER	INSTITUTO DE ASSISTENCIA TECNICA E EXTENCAO RURAL DO ESTADO DE RORAIMA
39	IERR	INSTITUTO DE EDUCACAO DO ESTADO DE RORAIMA
40	IPEM-RR	INSTITUTO DE PESOS E MEDIDAS DO ESTADO DE RORAIMA

VENCIMENTO
0524, 0002, 0181

PROVENTOS com FÓRMULA DE CÁLCULO
0056, 0118, 0175, 0382, 0567, 0606, 0616, 0648, 0865, 0870, 0920, 0965, 1779

TRIBUTOS
0004, 0182, 0003

CONSIGNACAO
0810, 0272, 1827, 0538, 0250, 0262, 0950, 1833, 1102 

DESCONTOS com FÓRMULA DE CÁLCULO
0008, 0538, 0612, 9950, 9970, 9972

*/

DECLARE
  -- Parâmetros obrigatórios com valores default
  pAcao          CHAR         := 'I';          -- Default: Inclusão
  pCompetencia   INTEGER      := 202411;       -- Default: Nov/2025
  pAgrupamento   INTEGER      := 2;           -- Default: Agrupamento 19
  
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

  pCompetencia := 202411; -- Nov/2024
  pAgrupamento := 13;      -- Indiretas
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
    --'0001', '0002', '0036', '0062', '0181', '0524', '2040', '4199',
     -- Proventos Calculadas
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

  -- Descontos sem Tributos
  pAcao := 'I';           -- Inclusão
  pTpRubrica := 'D';      -- Descontos
  pTipoInclusao := Null;  -- Indices e Valores
  pNuRubrica := tRubricas();
  pExcetoNuRubrica := tRubricas(
     -- Tributos
    '0003', '0004', '0182', '0199', '0227',
     -- Consignações
    '0810', '0272', '1827', '0538', '0250', '0262', '0950', '1833', '1102'
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

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    RAISE;
END;
/