--DROP TABLE emigParametrizacao;
--DROP TABLE emigParametrizacaoLog;
DROP TABLE emigParametrizacaoLogTemporario;

DROP TYPE tpParametroEntrada;
DROP TYPE tpRetorno;

DROP TYPE tpParametrizacaoResumoTabela;
DROP TYPE tpParametrizacaoListarTabela;
DROP TYPE tpParametrizacaoLogResumoTabela;
DROP TYPE tpParametrizacaoLogResumoEntidadesTabela; 
DROP TYPE tpParametrizacaoLogListarTabela; 

DROP TYPE tpParametrizacaoResumo;
DROP TYPE tpParametrizacaoListar;
DROP TYPE tpParametrizacaoLogResumo;
DROP TYPE tpParametrizacaoLogResumoEntidades;
DROP TYPE tpParametrizacaoLogListar;

DROP TYPE tpmigParametrizacaoResumoTabela;
DROP TYPE tpmigParametrizacaoListarTabela;
DROP TYPE tpmigParametrizacaoLogResumoTabela;
DROP TYPE tpmigParametrizacaoLogResumoEntidadesTabela; 
DROP TYPE tpmigParametrizacaoLogListarTabela; 

DROP TYPE tpmigParametrizacaoResumo;
DROP TYPE tpmigParametrizacaoListar;
DROP TYPE tpmigParametrizacaoLogResumo;
DROP TYPE tpmigParametrizacaoLogResumoEntidades;
DROP TYPE tpmigParametrizacaoLogListar;

DROP TYPE tpmigParametroEntrada;
DROP TYPE tpmigRetorno;

DROP PACKAGE PKGMIG_Parametrizacao;
DROP PACKAGE PKGMIG_ParametrizacaoLog;
DROP PACKAGE PKGMIG_ParemetrizacaoValoresReferencia;
DROP PACKAGE PKGMIG_ParametrizacaoBasesCalculo;
DROP PACKAGE PKGMIG_ParametrizacaoRubricas;
DROP PACKAGE PKGMIG_ParametrizacaoRubricasAgrupamento;
DROP PACKAGE PKGMIG_ParametrizacaoEventosPagamento;
DROP PACKAGE PKGMIG_ParametrizacaoFormulasCalculo;
