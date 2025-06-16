-- ===========================================================================
--- Como executar o Pacote de exportação das configurações de rubricas
SET SERVEROUTPUT ON;
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('ADM-DIR', 'VALORREFERENCIA');

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumo(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListar('ADM-DIR', NULL, 'PAG', 'VALORREFERENCIA', '15/06/2025 13:47:01'));

select * from table(PKGMIG_ConfiguracaoPadrao.fnResumoLog(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_ConfiguracaoPadrao.fnListarLog('EXPORTACAO', '20250615134701'));

EXEC PKGMIG_ConfiguracaoPadrao.PExcluirLog('EXPORTACAO', '20250615132310', 'ADM-DIR', 'PAG', 'VALORREFERENCIA');

select * from emigConfiguracaoPadrao
--delete from emigConfiguracaoPadrao
where TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

EXEC PKGMIG_ConfiguracaoPadrao.PExportar('INDIR-FEMARH', 'BASE');
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('INDIR-IPEM/RR', 'BASE');
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('MILITAR', 'BASE');
EXEC PKGMIG_ConfiguracaoPadrao.PExportar('ADM-DIR', 'BASE');
/

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
