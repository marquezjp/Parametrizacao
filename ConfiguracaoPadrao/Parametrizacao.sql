-- ===========================================================================
--- Como executar o Pacote de exportação das configurações de rubricas
/*
MILITAR
INDIR-FEMARH
INDIR-ADERR
INDIR-IATER
INDIR-IERR
INDIR-IPEM/RR
ADM-DIR
*/

SET SERVEROUTPUT ON SIZE UNLIMITED;
EXEC PKGMIG_Parametrizacao.PExportar('MILITAR', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-FEMARH', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-ADERR', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IATER', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IERR', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IPEM/RR', 'VALORREFERENCIA');
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'VALORREFERENCIA');

EXEC PKGMIG_Parametrizacao.PExportar('MILITAR', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-FEMARH', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-ADERR', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IATER', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IERR', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IPEM/RR', 'BASECALCULO');
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'BASECALCULO');

EXEC PKGMIG_Parametrizacao.PExportar('MILITAR', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-FEMARH', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-ADERR', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IATER', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IERR', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('INDIR-IPEM/RR', 'RUBRICA');
EXEC PKGMIG_Parametrizacao.PExportar('ADM-DIR', 'RUBRICA');

SELECT sgConceito, sgAgrupamento, TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI:SS') AS dtExportacao,
COUNT(*) AS nuRegistros FROM emigParametrizacao
GROUP BY sgConceito, sgAgrupamento, TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI:SS')
ORDER BY sgConceito, sgAgrupamento, dtExportacao
;

EXEC PKGMIG_Parametrizacao.PImportar('ADM-DIR', 'INDIR-IPEM/RR', 'RUBRICA', 'DETALHADO');

PROCEDURE pExportar(psgAgrupamento IN VARCHAR2,
  psgConceito IN VARCHAR2, pNivelAuditoria VARCHAR2 DEFAULT NULL
);

PROCEDURE pImportar(psgAgrupamentoOrigem IN VARCHAR2, psgAgrupamentoDestino IN VARCHAR2,
  psgConceito IN VARCHAR2, pNivelAuditoria VARCHAR2 DEFAULT NULL
);

--- Parametrizações
select sgAgrupamento, sgConceito, TO_CHAR(max(dtExportacao), 'YYYY/MM/DD HH24:MI:SS') as dtExportacao from emigParametrizacao
where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'
group by sgAgrupamento, sgConceito;

select TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI:SS') as dtExportacao, sgConceito, cdIdentificacao, jsConteudo
from emigParametrizacao
where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA'
 and TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI:SS') = '2025/06/21 18:31:01'
order by dtExportacao desc, cdIdentificacao
;

--- Log das Operações
select sgAgrupamento, sgConceito, tpOperacao,
TO_CHAR(min(dtOperacao), 'YYYY/MM/DD HH24:MI:SS') as dtOperacaoMin,
TO_CHAR(max(dtOperacao), 'YYYY/MM/DD HH24:MI:SS') as dtOperacaoMax
from emigParametrizacaoLog
group by sgAgrupamento, sgConceito, tpOperacao
order by sgAgrupamento, sgConceito, tpOperacao desc
;

select nmEntidade, cdIdentificacao, nmEvento, deMensagem, dtInclusao from emigParametrizacaoLog
where sgAgrupamento = 'ADM-DIR' and sgConceito = 'RUBRICA' and tpOperacao = 'EXPORTACAO'
order by dtInclusao desc
;


SELECT DISTINCT sgAgrupamento, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') AS dtExportacao FROM emigParametrizacao
--DELETE FROM emigParametrizacao
WHERE sgAgrupamento = 'ADM-DIR' AND sgConceito = 'RUBRICA'
--  AND TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

--- Log das Operações
SELECT TO_CHAR(max(dtOperacao), 'YYYYMMDDHH24MISS') AS dtOperacao FROM emigParametrizacaoLog
--DELETE FROM emigParametrizacaoLog
WHERE tpOperacao = 'EXPORTACAO' AND sgAgrupamento = 'ADM-DIR' AND sgConceito = 'RUBRICA'
;

select * from emigParametrizacao
where TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

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
select a.sgAgrupamento, 'BASE' as Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) as nuRubrica, base.nmBaseCalculo as Sigla
from epagRubricaAgrupamento ra
inner join epagRubrica r on r.cdRubrica = ra.cdRubrica
inner join epagBaseCalculo base on base.cdBaseCalculo = ra.cdBaseCalculo
inner join ecadAgrupamento a on a.cdAgrupamento = ra.cdAgrupamento
where ra.cdAgrupamento = 1 and ra.cdBaseCalculo is not null
order by sgAgrupamento, nuRubrica, Tipo, Sigla
;

EXEC PKGMIG_Parametrizacao.pGerarResumo(
psgAgrupamento => 'INDIR-IPEM/RR',
psgOrgao => NULL,
ptpOperacao => 'IMPORTACAO',
pdtOperacao => to_date('22/06/2025 06:12:32', 'DD/MM/YYYY HH24:MI:SS'),
psgModulo => 'PAG',
psgConceito => 'RUBRICA',
pdtTermino => to_date('22/06/2025 06:31:53', 'DD/MM/YYYY HH24:MI:SS'),
pnuTempoExecucao => to_number(substr('00:19:20',1,2)*3600 + substr('00:19:20',4,2)*60 + substr('00:19:20',7,2)),
pnuNivelAuditoria => 1
);

PKGMIG_Parametrizacao.pGerarResumo(
psgAgrupamentoDestino,
vsgOrgao,
vtpOperacao,
vdtOperacao,
vsgModulo,
vsgConceito,
vdtTermino,
vnuTempoExecucao,
pnuNivelAuditoria
);
      
SELECT
'INDIR-IPEM/RR' as sgAgrupamento,
NULL as sgOrgao,
'IMPORTACAO' as tpOperacao,
to_date('22/06/2025 06:12:32', 'DD/MM/YYYY HH24:MI:SS') as dtOperacao,
'PAG' as sgModulo,
'RUBRICA' as sgConceito,
to_date('22/06/2025 06:31:53', 'DD/MM/YYYY HH24:MI:SS') as dtTermino,
to_number(substr('00:19:20',1,2)*3600 + substr('00:19:20',4,2)*60 + substr('00:19:20',7,2)) as nuTempoExecucao,
'1' as pnuNivelAuditoria
FROM DUAL
;

select 'IMPORTACAO' AS tpOperacao, nmEntidade, cdIdentificacao, nmEvento, nuRegistros, deMensagem, dtInclusao from emigParametrizacaoLog
where sgAgrupamento = 'INDIR-IPEM/RR' and sgConceito = 'RUBRICA' and tpOperacao = 'IMPORTACAO'
  --and nmEvento = 'JSON' and deMensagem is not null
  and cdIdentificacao like '01-0002%'
order by dtInclusao
;

WITH
RubricaLista AS (
SELECT rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento, rub.cdRubrica,
LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
CASE WHEN tprub.nuTipoRubrica IN (1, 5, 9) THEN NULL ELSE tprub.deTipoRubrica || ' ' END ||
  NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.deRubrica,
    NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.deRubrica,NULL)) as deRubrica,
NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesInicioVigencia,
  NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesInicioVigencia,NULL)) as nuAnoMesInicioVigencia,
NVL2(UltVigenciaAgrupamento.cdRubricaAgrupamento,UltVigenciaAgrupamento.nuAnoMesFimVigencia,
  NVL2(UltVigenciaRub.nuRubrica,UltVigenciaRub.nuAnoMesFimVigencia,NULL)) as nuAnoMesFimVigencia
FROM epagRubrica rub
INNER JOIN epagTipoRubrica tprub ON tprub.cdtiporubrica = rub.cdtiporubrica
INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdrubrica = rub.cdrubrica
LEFT JOIN (SELECT cdRubricaAgrupamento, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
SELECT cdRubricaAgrupamento, deRubricaAgrupamento as deRubrica,
  LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) AS nuAnoMesInicioVigencia,
  CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
  ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
  RANK() OVER (PARTITION BY cdRubricaAgrupamento
    ORDER BY LPAD(nuAnoInicioVigencia,4,0) || LPAD(nuMesInicioVigencia,2,0) DESC,
      CASE WHEN nuAnoFimVigencia IS NULL OR nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(nuAnoFimVigencia,4,0) || LPAD(nuMesFimVigencia,2,0)
      END DESC nulls FIRST) AS nuOrder
FROM epagHistRubricaAgrupamento) WHERE nuOrder = 1
) UltVigenciaAgrupamento ON UltVigenciaAgrupamento.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
LEFT JOIN (SELECT nuRubrica, deRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia FROM (
SELECT rub.cdRubrica, vigenciarub.deRubrica,
  LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) as nuRubrica,
  NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0), '190101') AS nuAnoMesInicioVigencia,
  CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
  ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0) END AS nuAnoMesFimVigencia,
  RANK() OVER (PARTITION BY rub.cdRubrica
    ORDER BY NVL(LPAD(vigenciarub.nuAnoInicioVigencia,4,0) || LPAD(vigenciarub.nuMesInicioVigencia,2,0),'190101') DESC,
      CASE WHEN vigenciarub.nuAnoFimVigencia IS NULL OR vigenciarub.nuMesFimVigencia IS NULL THEN NULL
      ELSE LPAD(vigenciarub.nuAnoFimVigencia,4,0) || LPAD(vigenciarub.nuMesFimVigencia,2,0)
      END DESC nulls FIRST) AS nuOrder
FROM epagRubrica rub
INNER JOIN epagTipoRubrica tprub on tprub.cdTipoRubrica = rub.cdTipoRubrica
LEFT JOIN epagHistRubrica vigenciarub on vigenciarub.cdRubrica = rub.cdRubrica
WHERE tprub.nuTipoRubrica IN (1, 5, 9)) WHERE nuOrder = 1
) UltVigenciaRub ON UltVigenciaRub.nuRubrica =
  CASE WHEN tprub.nuTipoRubrica IN (1, 2, 3, 8, 10, 12) THEN '01'
       WHEN tprub.nuTipoRubrica IN (5, 6, 7, 4, 11, 13) THEN '05'
       WHEN tprub.nuTipoRubrica = 9 THEN '09'
  END || '-' || LPAD(rub.nuRubrica,4,0)
),
Listas AS (
SELECT 'OrgaosPermitidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupOrgao UNION ALL
SELECT 'UnidadesOrganizacionais' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupUO UNION ALL
SELECT 'Carreiras' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupCarreira UNION ALL
SELECT 'NiveisReferencias' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupNivelRef UNION ALL
SELECT 'CargosComissionados' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupCCO UNION ALL
SELECT 'FuncoesChefia' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupFUC UNION ALL
SELECT 'Programas' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupPrograma UNION ALL
SELECT 'ModelosAposentadoriaExigidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupModeloApo UNION ALL
SELECT 'CargasHorarias' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubAgrupLocCHO UNION ALL
SELECT 'NaturezasVinculoPermitidas' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupNatVinc UNION ALL
SELECT 'RelacoesTrabalhoPermitidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupRelTrab UNION ALL
SELECT 'RegimesTrabalhoPermitidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupRegTrab UNION ALL
SELECT 'RegimesPrevidenciariosPermitidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupRegPrev UNION ALL
SELECT 'SituacoesPrevidenciariasPermitidos' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupSitPrev UNION ALL
SELECT 'MotivosAfastamentoImpedem' AS Lista, cdHistRubricaAgrupamento FROM epagRubAgrupMotAfastTempImp UNION ALL
SELECT 'MotivosAfastamentoExigidos' AS Lista, cdHistRubricaAgrupamento FROM epagRubAgrupMotAfastTempEx UNION ALL
SELECT 'MotivosMovimentacao' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupMotMovi UNION ALL
SELECT 'MotivosConvocacao' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupMotConv UNION ALL
SELECT 'RubricasImpedem' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupImpeditiva UNION ALL
SELECT 'RubricasExigidas' AS Lista, cdHistRubricaAgrupamento FROM epagHistRubricaAgrupExigida
)

SELECT a.sgAgrupamento, rub.nuRubrica, rub.deRubrica, Lista, COUNT(*) AS Regs
FROM Listas
LEFT JOIN epagHistRubricaAgrupamento vigencia on vigencia.cdHistRubricaAgrupamento = listas.cdHistRubricaAgrupamento
LEFT JOIN RubricaLista rub on rub.cdRubricaAgrupamento = vigencia.cdRubricaAgrupamento
LEFT JOIN ecadAgrupamento a on a.cdAgrupamento = rub.cdAgrupamento
WHERE UPPER(Lista) LIKE UPPER('orga%')
GROUP BY a.sgAgrupamento, rub.nuRubrica, rub.deRubrica, Lista
ORDER BY a.sgAgrupamento, rub.nuRubrica, rub.deRubrica, Lista
;
/
