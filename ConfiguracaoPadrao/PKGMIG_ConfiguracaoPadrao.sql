--- Pacote de Exportação e Importação das Configurações Padrão

DROP TYPE tpConfiguracaoResumoTabela;
DROP TYPE tpConfiguracaoListarTabela;
DROP TYPE tpConfiguracaoLogResumoTabela;
DROP TYPE tpConfiguracaoLogResumoEntidadesTabela;
DROP TYPE tpConfiguracaoLogListarTabela;
/

CREATE OR REPLACE TYPE tpConfiguracaoResumo AS OBJECT (
-- Tipo Objeto: Resumo da Configuração Padrão
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    TIMESTAMP,
  nuConteudos     NUMBER
);

CREATE OR REPLACE TYPE tpConfiguracaoListar AS OBJECT (
-- Tipo Objeto: Listar Configuração Padrão
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    TIMESTAMP,
  cdIdentificacao VARCHAR2(20), 
  jsConteudo      CLOB
);


CREATE OR REPLACE TYPE tpConfiguracaoLogResumo AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Configuração
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20)
);
 
CREATE OR REPLACE TYPE tpConfiguracaoLogResumoEntidades AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Configuração por Entidades
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  nmEntidade      VARCHAR2(50),
  nuEventos       NUMBER,
  nuRegistros     NUMBER
);
/

CREATE OR REPLACE TYPE tpConfiguracaoLogListar AS OBJECT (
-- Tipo Objeto: Listar o Log da Operação de Exportação ou Importação da Configuração
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  nmEntidade      VARCHAR2(50),
  cdIdentificacao VARCHAR2(50),
  nmEvento        VARCHAR2(50),
  nuRegistros     NUMBER,
  deMensagem      VARCHAR2(4000),
  dtInclusao      TIMESTAMP(6)
 );
/

-- Tipo Tabela: Resumo da Configuração Padrão
CREATE OR REPLACE TYPE tpConfiguracaoResumoTabela AS TABLE OF tpConfiguracaoResumo;
-- Tipo Tabela: Listar Configuração Padrão 
CREATE OR REPLACE TYPE tpConfiguracaoListarTabela AS TABLE OF tpConfiguracaoListar;
-- Tipo Tabela: Resumo do Log das Operações de Exportação e Importação das Configuração
CREATE OR REPLACE TYPE tpConfiguracaoLogResumoTabela AS TABLE OF tpConfiguracaoLogResumo;
-- Tipo Tabela: Resumo do Log das Operações de Exportação e Importação das Configuração por Entidades
CREATE OR REPLACE TYPE tpConfiguracaoLogResumoEntidadesTabela AS TABLE OF tpConfiguracaoLogResumoEntidades;
-- Tipo Tabela: Listar o Log da Operação de Exportação ou Importação da Configuração
CREATE OR REPLACE TYPE tpConfiguracaoLogListarTabela AS TABLE OF tpConfiguracaoLogListar;
/

--- Pacote de Exportação e Importação das Configurações Padrão
CREATE OR REPLACE PACKAGE PKGMIG_ConfiguracaoPadrao AS
  -- Constantes de nível de debug
  cDEBUG_NIVEL_0   CONSTANT PLS_INTEGER := 0;
  cDEBUG_DESLIGADO CONSTANT PLS_INTEGER := 1;
  cDEBUG_NIVEL_1   CONSTANT PLS_INTEGER := 2;
  cDEBUG_NIVEL_2   CONSTANT PLS_INTEGER := 3;
  cDEBUG_NIVEL_3   CONSTANT PLS_INTEGER := 4;
  FUNCTION fnObterNivelDebug(pDEBUG IN VARCHAR2) RETURN PLS_INTEGER;

  PROCEDURE pExportar(psgAgrupamento IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG VARCHAR2 DEFAULT NULL
  );

  PROCEDURE pConsoleLog(pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuDEBUG IN NUMBER DEFAULT NULL
  );

  PROCEDURE pRegistrarLog(psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    ptpOperacao IN VARCHAR2, pdtOperacao IN TIMESTAMP,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pcdIdentificacao IN VARCHAR2, pnuRegistros IN NUMBER,
    pnmEntidade IN VARCHAR2, pnmEvento IN VARCHAR2, pdeMensagem IN VARCHAR2,
    pnuNivelLog IN NUMBER DEFAULT NULL, pnuDEBUG IN NUMBER DEFAULT NULL
  );

  FUNCTION fnResumo (psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL, pdtExportacao IN TIMESTAMP DEFAULT NULL
  ) RETURN tpConfiguracaoResumoTabela PIPELINED;

  FUNCTION fnListar (psgAgrupamento IN VARCHAR2, psgOrgao IN VARCHAR2,
    psgModulo IN CHAR, psgConceito IN VARCHAR2, pdtExportacao IN TIMESTAMP
  ) RETURN tpConfiguracaoListarTabela PIPELINED;

  FUNCTION fnResumoLog(psgAgrupamento IN VARCHAR2 DEFAULT NULL, psgOrgao IN VARCHAR2 DEFAULT NULL,
    psgModulo IN CHAR DEFAULT NULL, psgConceito IN VARCHAR2 DEFAULT NULL,
    ptpOperacao IN VARCHAR2 DEFAULT NULL
  ) RETURN tpConfiguracaoLogResumoTabela PIPELINED;

  FUNCTION fnResumoLogEntidades(ptpOperacao IN VARCHAR2, pdtOperacao IN VARCHAR2
  ) RETURN tpConfiguracaoLogResumoEntidadesTabela PIPELINED;

  FUNCTION fnListarLog(ptpOperacao IN VARCHAR2, pdtOperacao IN VARCHAR2
  ) RETURN tpConfiguracaoLogListarTabela PIPELINED;
    
  PROCEDURE pExcluirLog(ptpOperacao  IN VARCHAR2, pdtOperacao IN VARCHAR2,
    psgAgrupamento IN VARCHAR2, psgModulo  IN CHAR, psgConceito IN VARCHAR2
  );
END PKGMIG_ConfiguracaoPadrao;
/

-- Corpo do pacote
CREATE OR REPLACE PACKAGE BODY PKGMIG_ConfiguracaoPadrao AS

  FUNCTION fnObterNivelDebug(pDEBUG IN VARCHAR2) RETURN PLS_INTEGER IS
  BEGIN
  CASE UPPER(TRIM(NVL(pDEBUG, 'DESLIGADO')))
    WHEN 'DEBUG NIVEL 0' THEN RETURN cDEBUG_NIVEL_0;
    WHEN 'DEBUG NIVEL 1' THEN RETURN cDEBUG_NIVEL_1;
    WHEN 'DEBUG NIVEL 2' THEN RETURN cDEBUG_NIVEL_2;
    WHEN 'DESLIGADO'     THEN RETURN cDEBUG_DESLIGADO;
    ELSE RETURN cDEBUG_DESLIGADO;
  END CASE;
  END;

  PROCEDURE pExportar(pSgAgrupamento IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG IN VARCHAR2 DEFAULT NULL) IS
    vnuDEBUG NUMBER := fnObterNivelDebug(pDEBUG);
  BEGIN
--    CASE UPPER(psgConceito)
--      WHEN 'VALORREFERENCIA' THEN
--        PKGMIG_ExportarValoresReferencia.pExportar(psgAgrupamento, vnuDEBUG);
--      WHEN 'BASE' THEN
--        PKGMIG_ExportarBasesCalculo.pExportar(psgAgrupamento, vnuDEBUG);
--      WHEN 'RUBRICA' THEN
--        PKGMIG_ExportarRubricas.pExportar(psgAgrupamento);
--      ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Conceito não suportado: ' || psgConceito);
--    END CASE;
  END pExportar;

  PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
    psgConceito IN VARCHAR2, pDEBUG IN VARCHAR2 DEFAULT NULL) IS
    vnuDEBUG NUMBER := fnObterNivelDebug(pDEBUG);
  BEGIN
    CASE UPPER(psgConceito)
--      WHEN 'BASE' THEN
--        PKGMIG_ImportarBasesCalculo.pImportar(psgAgrupamentoOrigem, psgAgrupamentoDestino, vnuDEBUG);
      WHEN 'RUBRICA' THEN
        PKGMIG_ImportarRubricas.pImportar(psgAgrupamentoOrigem, psgAgrupamentoDestino, vnuDEBUG);
      ELSE
        RAISE_APPLICATION_ERROR(-20002, 'Importação não suportada para o conceito: ' || psgConceito);
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
  --   pDEBUG           IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'DEBUG NIVEL 0' omite todas as mensagens;
  --                         - Se informado 'DEBUG NIVEL 1' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DEBUG NIVEL 2' inclui as mensagens de todas 
  --                           entidades, incluindo as referente as tabelas das listas;
  --
  -- ###########################################################################
    pdeMensagem      IN VARCHAR2,
    pnuNivelLog      IN NUMBER DEFAULT NULL,
    pnuDEBUG         IN NUMBER DEFAULT NULL
    ) IS
    BEGIN
      -- Incluir Log de Auditoria da Importação das Configurações Padrão
      IF NVL(pnuDEBUG, cDEBUG_DESLIGADO) >= NVL(pnuNivelLog, cDEBUG_DESLIGADO) THEN
	    DBMS_OUTPUT.PUT_LINE(pdeMensagem);
      END IF;
  END pConsoleLog;

  PROCEDURE pRegistrarLog(
  -- ###########################################################################
  -- PROCEDURE: pRegistrarLog
  -- Objetivo:
  --   Registrar eventos de auditoria, controle ou estatística no processo de
  --   importação de configurações padrão (rubricas, bases, valores, etc.).
  --   Os registros são inseridos na tabela emigConfiguracaoPadraoLog.
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
  --   pDEBUG           IN VARCHAR2 DEFAULT NULL: Defini o nível das mensagens
  --                         para acompanhar a execução, sendo:
  --                         - Não informado assume 'Desligado' nível mínimo de mensagens;
  --                         - Se informado 'DEBUG NIVEL 0' omite todas as mensagens;
  --                         - Se informado 'DEBUG NIVEL 1' inclui as mensagens das
  --                           principais todas entidades, menos as listas;
  --                         - Se informado 'DEBUG NIVEL 2' inclui as mensagens de todas 
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
    pnuDEBUG         IN NUMBER DEFAULT NULL
    ) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
      -- Incluir Log de Auditoria da Importação das Configurações Padrão
      IF NVL(pnuDEBUG, cDEBUG_DESLIGADO) >= NVL(pnuNivelLog, cDEBUG_DESLIGADO) THEN
        INSERT INTO emigConfiguracaoPadraoLog (
          sgAgrupamento, sgOrgao, sgModulo, sgConceito, tpOperacao, dtOperacao,
          nmEntidade, cdIdentificacao, nmEvento, nuRegistros, deMensagem
        ) VALUES (
          psgAgrupamento, psgOrgao, psgModulo, psgConceito, ptpOperacao, pdtOperacao,
          pnmEntidade, pcdIdentificacao, pnmEvento, pnuRegistros, pdeMensagem
        );
        COMMIT;
      END IF;
  END pRegistrarLog;

-- Resumo das Operações de Exportação das Configurações
  FUNCTION fnResumo(
    psgAgrupamento   IN VARCHAR2  DEFAULT NULL,
    psgOrgao         IN VARCHAR2  DEFAULT NULL,
    psgModulo        IN CHAR      DEFAULT NULL,
    psgConceito      IN VARCHAR2  DEFAULT NULL,
    pdtExportacao    IN TIMESTAMP DEFAULT NULL
  ) RETURN tpConfiguracaoResumoTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, NULL AS dtExportacao, COUNT(*) AS Conteudos
      FROM emigConfiguracaoPadrao
      WHERE (sgAgrupamento LIKE psgAgrupamento OR psgAgrupamento IS NULL)
        AND (sgOrgao LIKE psgOrgao OR psgOrgao IS NULL)
        AND (sgModulo LIKE psgModulo OR psgModulo IS NULL)
        AND (sgConceito LIKE psgConceito OR psgConceito IS NULL)
--        AND (dtExportacao LIKE pdtExportacao OR pdtExportacao IS NULL)
      GROUP BY sgAgrupamento, sgOrgao, sgModulo, sgConceito
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito)
    LOOP
      PIPE ROW (tpConfiguracaoResumo(r.sgAgrupamento, r.sgOrgao,
        r.sgModulo, r.sgConceito, r.dtExportacao,
        r.Conteudos));
    END LOOP;
    RETURN;
  END fnResumo;

-- Listar a Exportação das Configurações
  FUNCTION fnListar(
    psgAgrupamento   IN VARCHAR2,
    psgOrgao         IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2,
    pdtExportacao    IN TIMESTAMP
  ) RETURN tpConfiguracaoListarTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT sgAgrupamento, sgOrgao, sgModulo, sgConceito, NULL AS dtExportacao, cdIdentificacao,
        JSON_SERIALIZE(TO_CLOB(jsconteudo) RETURNING CLOB PRETTY) AS jsConteudo
      FROM emigConfiguracaoPadrao
      WHERE (sgAgrupamento = psgAgrupamento)
        AND (NVL(sgOrgao, ' ') = NVL(psgOrgao, ' '))
        AND (sgModulo = psgModulo)
        AND (sgConceito = psgConceito)
--        AND (dtExportacao LIKE pdtExportacao OR pdtExportacao IS NULL)
      ORDER BY sgAgrupamento, sgOrgao, sgModulo, sgConceito)
    LOOP
      PIPE ROW (tpConfiguracaoListar(r.sgAgrupamento, r.sgOrgao,
          r.sgModulo, r.sgConceito, r.dtExportacao,
          r.cdIdentificacao, r.jsConteudo));
    END LOOP;
    RETURN;
  END fnListar;

-- Resumo do Log das Operações de Exportação e Importação das Configurações
  FUNCTION fnResumoLog(
    psgAgrupamento   IN VARCHAR2  DEFAULT NULL,
    psgOrgao         IN VARCHAR2  DEFAULT NULL,
    psgModulo        IN CHAR      DEFAULT NULL,
    psgConceito      IN VARCHAR2  DEFAULT NULL,
    ptpOperacao      IN VARCHAR2  DEFAULT NULL
  ) RETURN tpConfiguracaoLogResumoTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT DISTINCT tpOperacao, TO_CHAR(dtOperacao, 'YYYYMMDDHH24MISS') as dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito
      FROM emigConfiguracaoPadraoLog
      WHERE (tpOperacao LIKE ptpOperacao OR ptpOperacao IS NULL)
        AND (sgAgrupamento LIKE psgAgrupamento OR psgAgrupamento IS NULL)
        AND (sgOrgao LIKE psgOrgao OR psgOrgao IS NULL)
        AND (sgModulo LIKE psgModulo OR psgModulo IS NULL)
        AND (sgConceito LIKE psgConceito OR psgConceito IS NULL)
      ORDER BY tpOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito, dtOperacao)
    LOOP
      PIPE ROW (tpConfiguracaoLogResumo(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito));
    END LOOP;
    RETURN;
  END fnResumoLog;

-- Resumo do Log das Operações de Exportação e Importação das Configurações
  FUNCTION fnResumoLogEntidades(
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN VARCHAR2
  ) RETURN tpConfiguracaoLogResumoEntidadesTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI:SS') AS dtOperacao,
	    sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade, COUNT(*) as nuEventos, SUM(nuRegistros) as nuRegistros
      FROM emigConfiguracaoPadraoLog
      WHERE nmevento != 'RESUMO'
        AND tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'YYYYMMDDHH24MISS') = pdtOperacao
      GROUP BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade
      ORDER BY tpOperacao, dtOperacao, sgAgrupamento, sgOrgao, sgModulo, sgConceito, nmEntidade)
    LOOP
      PIPE ROW (tpConfiguracaoLogResumoEntidades(r.tpOperacao, r.dtOperacao,
	    r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
		r.nmEntidade, r.nuEventos, r.nuRegistros));
    END LOOP;
    RETURN;
  END fnResumoLogEntidades;

-- Listar o Log da Operação de Exportação ou Importação das Configurações
  FUNCTION fnListarLog(
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN VARCHAR2
  ) RETURN tpConfiguracaoLogListarTabela PIPELINED
  IS
  BEGIN
    FOR r IN (
      SELECT tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI:SS') as dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        nmEntidade, cdidentificacao, nmEvento, nuRegistros, deMensagem, dtInclusao
      FROM emigConfiguracaoPadraoLog
      WHERE tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'YYYYMMDDHH24MISS') = pdtOperacao
      ORDER BY dtInclusao, tpOperacao, dtOperacao,
        sgAgrupamento, sgOrgao, sgModulo, sgConceito,
        cdIdentificacao NULLS FIRST, nmEvento, deMensagem)
    LOOP
      PIPE ROW (tpConfiguracaoLogListar(r.tpOperacao, r.dtOperacao,
        r.sgAgrupamento, r.sgOrgao, r.sgModulo, r.sgConceito,
        r.nmEntidade, r.cdidentificacao, r.nmEvento, r.nuRegistros, r.deMensagem, r.dtInclusao));
    END LOOP;
    RETURN;
  END fnListarLog;

-- Excluir o Log da Operação de Exportação ou Importação das Configurações
  PROCEDURE PExcluirLog(
    ptpOperacao      IN VARCHAR2,
    pdtOperacao      IN VARCHAR2,
    psgAgrupamento   IN VARCHAR2,
    psgModulo        IN CHAR,
    psgConceito      IN VARCHAR2
  ) IS
  BEGIN
    DELETE FROM emigConfiguracaoPadraoLog
      WHERE tpOperacao = ptpOperacao
        AND TO_CHAR(dtOperacao, 'YYYYMMDDHH24MISS') = pdtOperacao
        AND sgAgrupamento = psgAgrupamento
        AND sgModulo = psgModulo AND sgConceito = psgConceito;
    COMMIT;
  END PExcluirLog;

END PKGMIG_ConfiguracaoPadrao;
/

