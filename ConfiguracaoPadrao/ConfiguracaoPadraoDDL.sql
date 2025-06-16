-- ===========================================================================
--- Como executar o Pacote de exportação das configurações de rubricas
SET SERVEROUTPUT ON;
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('ADM-DIR', 'VALORREFERENCIA');
EXEC PKGMIG_ConfiguracaoPadrao.PImportar('ADM-DIR', 'INDIR-IPEM/RR', 'VALORREFERENCIA', 'DEBUG NIVEL 2');

EXEC PKGMIG_ConfiguracaoPadrao.PExportar('ADM-DIR', 'BASE');
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('ADM-DIR', 'RUBRICA');

--- Parametrizações
select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'VALORREFERENCIA',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'VALORREFERENCIA'))
);

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgConceito => 'BASE'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'BASE',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'BASE'))
);

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'RUBRICA',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'))
);

--- Log das Operações
select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtExportacao), 'YYYYMMDDHH24MISS') as dtExportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'VALORREFERENCIA'))
);

select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('IMPORTACAO', 
  (select TO_CHAR(max(dtOperacao), 'YYYYMMDDHH24MISS') as dtOperacao
   from emigConfiguracaoPadraoLog where sgAgrupamento = 'INDIR-IPEM/RR' and sgConceito = 'VALORREFERENCIA' and tpOperacao = 'IMPORTACAO'))
);

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog(psgConceito => 'BASE'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtexportacao), 'YYYYMMDDHH24MISS') as dtexportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'BASE'))
);

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtexportacao), 'YYYYMMDDHH24MISS') as dtexportacao
   from emigConfiguracaoPadrao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'))
);


SELECT TO_CHAR(max(dtOperacao), 'YYYYMMDDHH24MISS') AS dtOperacao
FROM emigConfiguracaoPadraoLog
WHERE tpOperacao = 'IMPORTACAO'
  AND sgAgrupamento = 'INDIR-IPEM/RR'
  AND sgConceito = 'VALORREFERENCIA'
;

EXEC PKGMIG_ConfiguracaoPadrao.PExcluirLog('IMPORTACAO', '20250616121013', 'INDIR-IPEM/RR', 'PAG', 'VALORREFERENCIA');


select * from emigConfiguracaoPadrao
where TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

--- Como executar o Pacote de importação das configurações de rubricas
EXEC PKGMIG_ConfiguracaoPadrao.PImportar('INDIR-FEMARH', 'INDIR-IPEM/RR', 'RUBRICA');
/

EXEC PKGMIG_ConfiguracaoPadrao.PExcluirLog('IMPORTACAO', '20250614121945', 'INDIR-IPEM/RR', 'PAG', 'RUBRICA');
/

DROP PACKAGE PKGMIG_ConfiguracaoPadrao;
/
--- Como executar o Pacote de exportação das configurações de rubricas
DECLARE
  psgAgrupamento VARCHAR2(30) := 'INDIR-FEMARH';
  psgConceito    VARCHAR2(20) := 'RUBRICA';
BEGIN
  pkgemigConfiguracaoPadrao.emigPExportar(
    psgAgrupamento => psgAgrupamento,
    psgConceito => psgConceito
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    RAISE;
END;
/

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgModulo => 'PAG'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListar(
'INDIR-FEMARH', NULL, 'PAG', 'RUBRICA', NULL));

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog());
select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('IMPORTACAO', '20250614121945'));


select tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') as dtOperacao, sgAgrupamento, sgModulo,
sgConceito, nmEntidade, deMensagem, dtInclusao
from emigConfiguracaoPadraoLog
where sgModulo = 'PAG' and sgConceito = 'RUBRICA' and nmEvento = 'RESUMO' and sgAgrupamento = 'INDIR-IPEM/RR'
order by sgAgrupamento, sgOrgao, sgModulo, sgConceito
;
/
