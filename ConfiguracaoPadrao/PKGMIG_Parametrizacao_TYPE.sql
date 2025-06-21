--- Pacote de Exportação e Importação das Parametrizações

DROP TYPE tpParametrizacaoResumoTabela;
DROP TYPE tpParametrizacaoListarTabela;
DROP TYPE tpParametrizacaoLogResumoTabela;
DROP TYPE tpParametrizacaoLogResumoEntidadesTabela;
DROP TYPE tpParametrizacaoLogListarTabela;
/

CREATE OR REPLACE TYPE tpParametrizacaoResumo AS OBJECT (
-- Tipo Objeto: Resumo das Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  nuConteudos     NUMBER
);

CREATE OR REPLACE TYPE tpParametrizacaoListar AS OBJECT (
-- Tipo Objeto: Listar Parametrizações
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
  cdIdentificacao VARCHAR2(20), 
  jsConteudo      CLOB
);


CREATE OR REPLACE TYPE tpParametrizacaoLogResumo AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Parametrizações
  tpOperacao      VARCHAR2(15),
  dtOperacao      VARCHAR2(25),
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20)
);
 
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoEntidades AS OBJECT (
-- Tipo Objeto: Resumo do Log das Operações de Exportação e Importação das Parametrizações por Entidades
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

CREATE OR REPLACE TYPE tpParametrizacaoLogListar AS OBJECT (
-- Tipo Objeto: Listar o Log da Operação de Exportação ou Importação das Parametrizações
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

-- Tipo Tabela: Resumo das Parametrizações
CREATE OR REPLACE TYPE tpParametrizacaoResumoTabela AS TABLE OF tpParametrizacaoResumo;
-- Tipo Tabela: Listar Parametrizações
CREATE OR REPLACE TYPE tpParametrizacaoListarTabela AS TABLE OF tpParametrizacaoListar;
-- Tipo Tabela: Resumo do Log das Operações de Exportação e Importação das Parametrizações
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoTabela AS TABLE OF tpParametrizacaoLogResumo;
-- Tipo Tabela: Resumo do Log das Operações de Exportação e Importação das Parametrizações por Entidades
CREATE OR REPLACE TYPE tpParametrizacaoLogResumoEntidadesTabela AS TABLE OF tpParametrizacaoLogResumoEntidades;
-- Tipo Tabela: Listar o Log da Operação de Exportação ou Importação das Parametrizações
CREATE OR REPLACE TYPE tpParametrizacaoLogListarTabela AS TABLE OF tpParametrizacaoLogListar;
/
