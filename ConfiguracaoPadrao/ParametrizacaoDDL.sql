-- ===========================================================================
--- Como executar o Pacote de exportação das configurações de rubricas
SET SERVEROUTPUT ON;
SET SERVEROUTPUT ON SIZE UNLIMITED;
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PImportar('ADM-DIR', 'INDIR-IPEM/RR', 'VALORREFERENCIA', 'DETALHADO');

EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'BASE');
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'RUBRICA');

--- Parametrizações
select * from table(PKGMIG_Parametrizacao.fnResumo(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_Parametrizacao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'VALORREFERENCIA',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'VALORREFERENCIA'))
);

select * from table(PKGMIG_Parametrizacao.fnResumo(psgConceito => 'BASE'));
select * from table(PKGMIG_Parametrizacao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'BASE',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'BASE'))
);

select * from table(PKGMIG_Parametrizacao.fnResumo(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_Parametrizacao.fnListar(
  'ADM-DIR', NULL, 'PAG', 'RUBRICA',
  (select TO_CHAR(max(dtexportacao), 'DD/MM/YYYY HH24:MI:SS') as dtexportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'))
);

SELECT DISTINCT sgAgrupamento, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') AS dtExportacao FROM emigParametrizacao
--DELETE FROM emigParametrizacao
WHERE sgAgrupamento = 'ADM-DIR' AND sgConceito = 'RUBRICA'
--  AND TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

--- Log das Operações
select * from table(PKGMIG_Parametrizacao.fnResumoLog(psgConceito => 'VALORREFERENCIA'));
select * from table(PKGMIG_Parametrizacao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtExportacao), 'YYYYMMDDHH24MISS') as dtExportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'VALORREFERENCIA'))
);

select * from table(PKGMIG_Parametrizacao.fnListarLog('IMPORTACAO', 
  (select TO_CHAR(max(dtOperacao), 'YYYYMMDDHH24MISS') as dtOperacao
   from emigParametrizacaoLog where sgAgrupamento = 'INDIR-IPEM/RR' and sgConceito = 'VALORREFERENCIA' and tpOperacao = 'IMPORTACAO'))
);

select * from table(PKGMIG_Parametrizacao.fnResumoLog(psgConceito => 'BASE'));
select * from table(PKGMIG_Parametrizacao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtexportacao), 'YYYYMMDDHH24MISS') as dtexportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'BASE'))
);

select * from table(PKGMIG_Parametrizacao.fnResumoLog(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_Parametrizacao.fnListarLog('EXPORTACAO', 
  (select TO_CHAR(max(dtexportacao), 'YYYYMMDDHH24MISS') as dtexportacao
   from emigParametrizacao where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'))
);


SELECT TO_CHAR(max(dtOperacao), 'YYYYMMDDHH24MISS') AS dtOperacao FROM emigParametrizacaoLog
--DELETE FROM emigParametrizacaoLog
WHERE tpOperacao = 'EXPORTACAO' AND sgAgrupamento = 'ADM-DIR' AND sgConceito = 'RUBRICA'
;

EXEC PKGMIG_Parametrizacao.PExcluirLog('IMPORTACAO', '20250616121013', 'INDIR-IPEM/RR', 'PAG', 'VALORREFERENCIA');

select * from emigParametrizacao
where TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

--- Como executar o Pacote de importação das configurações de rubricas
EXEC PKGMIG_Parametrizacao.PImportar('INDIR-FEMARH', 'INDIR-IPEM/RR', 'RUBRICA');
/

EXEC PKGMIG_Parametrizacao.PExcluirLog('IMPORTACAO', '20250614121945', 'INDIR-IPEM/RR', 'PAG', 'RUBRICA');
/

DROP PACKAGE PKGMIG_Parametrizacao;
/
--- Como executar o Pacote de exportação das configurações de rubricas
DECLARE
  psgAgrupamento VARCHAR2(30) := 'INDIR-FEMARH';
  psgConceito    VARCHAR2(20) := 'RUBRICA';
BEGIN
  pkgemigParametrizacao.emigPExportar(
    psgAgrupamento => psgAgrupamento,
    psgConceito => psgConceito
  );
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    RAISE;
END;
/

select * from table(PKGMIG_Parametrizacao.fnResumo(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_Parametrizacao.fnResumo(psgModulo => 'PAG'));
select * from table(PKGMIG_Parametrizacao.fnListar(
'INDIR-FEMARH', NULL, 'PAG', 'RUBRICA', NULL));

select * from table(PKGMIG_Parametrizacao.fnResumoLog());
select * from table(PKGMIG_Parametrizacao.fnResumoLog(psgConceito => 'RUBRICA'));
select * from table(PKGMIG_Parametrizacao.fnListarLog('IMPORTACAO', '20250614121945'));


select tpOperacao, TO_CHAR(dtOperacao, 'DD/MM/YYYY HH24:MI') as dtOperacao, sgAgrupamento, sgModulo,
sgConceito, nmEntidade, deMensagem, dtInclusao
from emigParametrizacaoLog
where sgModulo = 'PAG' and sgConceito = 'RUBRICA' and nmEvento = 'RESUMO' and sgAgrupamento = 'INDIR-IPEM/RR'
order by sgAgrupamento, sgOrgao, sgModulo, sgConceito
;
/

select a.sgAgrupamento, 'FORMULA' as Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) as nuRubrica, f.deFormulaCalculo as Sigla
from epagFormulaCalculo f
inner join epagRubricaAgrupamento ra on ra.cdRubricaAgrupamento = f.cdRubricaAgrupamento
inner join epagRubrica r on r.cdRubrica = ra.cdRubrica
inner join ecadAgrupamento a on a.cdAgrupamento = ra.cdAgrupamento
where f.cdAgrupamento = 1
union all
select a.sgAgrupamento, 'EVENTO' as Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) as nuRubrica, e.deEvento as Sigla
from epagEventoPagAgrup e
inner join epagRubricaAgrupamento ra on ra.cdRubricaAgrupamento = e.cdRubricaAgrupamento
inner join epagRubrica r on r.cdRubrica = ra.cdRubrica
inner join ecadAgrupamento a on a.cdAgrupamento = ra.cdAgrupamento
where ra.cdAgrupamento = 1
union all
select a.sgAgrupamento, 'MODALIDADE' as Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) as nuRubrica, modrub.nmModalidadeRubrica as Sigla
from epagRubricaAgrupamento ra
inner join epagRubrica r on r.cdRubrica = ra.cdRubrica
inner join epagModalidadeRubrica modrub on modrub.cdModalidadeRubrica = ra.cdModalidadeRubrica
inner join ecadAgrupamento a on a.cdAgrupamento = ra.cdAgrupamento
where ra.cdAgrupamento = 1 and ra.cdModalidadeRubrica is not null
union all
select a.sgAgrupamento, 'BASE' as Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) as nuRubrica, base.nmBaseCalculo as Sigla
from epagRubricaAgrupamento ra
inner join epagRubrica r on r.cdRubrica = ra.cdRubrica
inner join epagBaseCalculo base on base.cdBaseCalculo = ra.cdBaseCalculo
inner join ecadAgrupamento a on a.cdAgrupamento = ra.cdAgrupamento
where ra.cdAgrupamento = 1 and ra.cdBaseCalculo is not null
order by sgAgrupamento, nuRubrica, Tipo, Sigla
;
