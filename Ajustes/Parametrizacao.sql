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

/* INDIR-FEMARH */
SET SERVEROUTPUT ON SIZE UNLIMITED;
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "MILITAR", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "INDIR-FEMARH", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "INDIR-ADERR", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "INDIR-IATER", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "INDIR-IERR", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "INDIR-IPEM/RR", "sgConceito": "VALORREFERENCIA"}');
EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "ADM-DIR", "sgConceito": "VALORREFERENCIA"}');

EXEC PKGMIG_Parametrizacao.pExportar('{"sgAgrupamento": "MILITAR", "sgConceito": "VALORREFERENCIA", "cdIdentificacao": "S01"}');


SELECT * FROM TABLE(PKGMIG_Parametrizacao.fnResumo());

SELECT * FROM TABLE(PKGMIG_Parametrizacao.fnListar('{"sgAgrupamento": "MILITAR", "sgConceito": "RUBRICA"}'));

SELECT * FROM TABLE(PKGMIG_Parametrizacao.fnResumoLog());

SELECT * FROM TABLE(PKGMIG_Parametrizacao.fnResumoLogEntidades('{"sgAgrupamento": "MILITAR", "sgConceito": "VALORREFERENCIA", "tpOperacao": "EXPORTACAO"}'));

SELECT * FROM TABLE(PKGMIG_Parametrizacao.fnListarLog('{"sgAgrupamento": "MILITAR", "sgConceito": "VALORREFERENCIA", "tpOperacao": "EXPORTACAO"}'));

--- Log das Operações
SELECT tpOperacao, TO_CHAR(dtOperacao, 'YYYY/MM/DD HH24:MI') as dtOperacao, --sgConceito, 
nmEntidade, cdIdentificacao, nmEvento, nuRegistros, deMensagem, dtInclusao from emigParametrizacaoLog
WHERE tpOperacao = 'IMPORTACAO' AND sgAgrupamento = 'INDIR-IPEM/RR' AND sgConceito = 'BASECALCULO'
  --AND nmEntidade LIKE 'BASE CALCULO%'
  --AND cdIdentificacao LIKE 'B1000%'
  --AND nmEvento = 'RESUMO'
  --AND nmEvento = 'JSON'
ORDER BY dtInclusao
;

--SELECT DISTINCT sgAgrupamento, sgConceito, TO_CHAR(dtOperacao, 'YYYY/MM/DD HH24:MI') AS dtOperacao FROM emigParametrizacaoLog
DELETE FROM emigParametrizacaoLog
WHERE tpOperacao = 'IMPORTACAO' AND sgAgrupamento = 'INDIR-IPEM/RR' AND sgConceito = 'BASECALCULO'
--  AND TO_CHAR(dtOperacao, 'YYYY/MM/DD HH24:MI') = '15/06/2025 13:23'
;

Select sgAgrupamento, sgConceito, tpOperacao, TO_CHAR(MAX(dtOperacao), 'YYYY/MM/DD HH24:MI') as dtOperacao
FROM emigParametrizacaoLog
WHERE tpOperacao = 'IMPORTACAO' AND sgAgrupamento = 'INDIR-IPEM/RR' AND sgConceito = 'BASECALCULO'
GROUP BY sgAgrupamento, sgConceito, tpOperacao
ORDER BY sgAgrupamento, sgConceito, tpOperacao
;

--- Parametrizações
SELECT sgConceito, sgAgrupamento, cdIdentificacao, jsConteudo
FROM emigParametrizacao
WHERE sgAgrupamento = 'INDIR-FEMARH' AND sgConceito = 'BASECALCULO'
  --AND nmEntidade LIKE 'BASE CALCULO%'
  --AND cdIdentificacao LIKE 'B1000%'
  --AND nmEvento = 'RESUMO'
ORDER BY sgConceito, sgAgrupamento, cdIdentificacao
;

SELECT sgConceito, sgAgrupamento, TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI') AS dtExportacao,
COUNT(*) AS nuRegistros FROM emigParametrizacao
GROUP BY sgConceito, sgAgrupamento, TO_CHAR(dtExportacao, 'YYYY/MM/DD HH24:MI')
ORDER BY sgConceito, sgAgrupamento, dtExportacao
;

SELECT DISTINCT sgAgrupamento, sgConceito, TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') AS dtExportacao FROM emigParametrizacao
--DELETE FROM emigParametrizacao
WHERE sgAgrupamento = 'ADM-DIR' AND sgConceito = 'RUBRICA'
--  AND TO_CHAR(dtExportacao, 'DD/MM/YYYY HH24:MI:SS') = '15/06/2025 13:23:10'
;

-- ===========================================================================
EXEC PKGMIG_ParametrizacaoLog.pGerarResumo(
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

-- ===========================================================================
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
