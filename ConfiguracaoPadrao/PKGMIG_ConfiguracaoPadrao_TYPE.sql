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
  dtExportacao    VARCHAR2(25),
  nuConteudos     NUMBER
);

CREATE OR REPLACE TYPE tpConfiguracaoListar AS OBJECT (
-- Tipo Objeto: Listar Configuração Padrão
  sgAgrupamento   VARCHAR2(15),
  sgOrgao         VARCHAR2(15),
  sgModulo        VARCHAR2(3),
  sgConceito      VARCHAR2(20),
  dtExportacao    VARCHAR2(25),
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
