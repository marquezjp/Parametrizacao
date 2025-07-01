-- Valores de Referencia
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.sgValorReferencia, js.nmValorReferencia,
JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.ValorReferencia' COLUMNS (
  sgValorReferencia PATH '$.sgValorReferencia',
  nmValorReferencia PATH '$.nmValorReferencia',
  Versoes           CLOB FORMAT JSON PATH '$.Versoes'
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'VALORREFERENCIA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 20:09'
  --AND parm.cdIdentificacao like 'SL MIN REF%'
ORDER BY parm.cdIdentificacao
;
/

-- Bases de Cálculo
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.sgBaseCalculo, js.nmBaseCalculo,
JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.BaseCalulo' COLUMNS (
  sgBaseCalculo PATH '$.sgBaseCalculo',
  nmBaseCalculo PATH '$.nmBaseCalculo',
  Versoes       CLOB FORMAT JSON PATH '$.Versoes'
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'BASECALCULO' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 21:45'
  --AND parm.cdIdentificacao like 'BCPSM%'
ORDER BY parm.cdIdentificacao
;
/

-- Rubricas do Agrupamento
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.nuNaturezaRubrica, js.nuRubrica, js.nuTipoRubrica,
JSON_SERIALIZE(TO_CLOB(js.VigenciasTipo) RETURNING CLOB) AS VigenciasTipo,
JSON_SERIALIZE(TO_CLOB(js.GruposRubrica) RETURNING CLOB) AS GruposRubrica,
JSON_SERIALIZE(TO_CLOB(js.Agrupamento) RETURNING CLOB) AS Agrupamento,
JSON_SERIALIZE(TO_CLOB(parm.jsConteudo) RETURNING CLOB) AS jsConteudo
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica' COLUMNS (
  nuNaturezaRubrica PATH '$.nuNaturezaRubrica',
  nuRubrica         PATH '$.nuRubrica',
  NESTED PATH '$.Tipos[*]' COLUMNS (
    nuTipoRubrica   PATH '$.nuTipoRubrica',
    VigenciasTipo   CLOB FORMAT JSON PATH '$.VigenciasTipo',
    GruposRubrica   CLOB FORMAT JSON PATH '$.GruposRubrica',
    Agrupamento     CLOB FORMAT JSON PATH '$.Agrupamento'
  )
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 21:52'
  AND parm.cdIdentificacao like '01-0524%'
ORDER BY parm.cdIdentificacao
;
/

-- Consignações
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.nuRubrica, js.deRubrica, js.sgConsignataria,
JSON_SERIALIZE(TO_CLOB(js.Vigencias) RETURNING CLOB) AS Vigencias,
JSON_SERIALIZE(TO_CLOB(js.Consignataria) RETURNING CLOB) AS Consignataria,
JSON_SERIALIZE(TO_CLOB(js.TipoServico) RETURNING CLOB) AS TipoServico,
JSON_SERIALIZE(TO_CLOB(js.ContratoServico) RETURNING CLOB) AS ContratoServico
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Consignacao' COLUMNS (
  nuRubrica       PATH '$.nuRubrica',
  deRubrica       PATH '$.deRubrica',
  sgConsignataria PATH '$.Consignataria.sgConsignataria',
  Vigencias       CLOB FORMAT JSON PATH '$.Vigencias',
  Consignataria   CLOB FORMAT JSON PATH '$.Consignataria',
  TipoServico     CLOB FORMAT JSON PATH '$.TipoServico',
  ContratoServico CLOB FORMAT JSON PATH '$.ContratoServico'
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 21:52'
  --AND parm.cdIdentificacao like '05-0036%'
ORDER BY parm.cdIdentificacao
;
/

-- Eventos de Pagamento
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.nmTipoEventoPagamento, js.deEvento AS deEvento, js.nuRubrica AS nuRubrica,
JSON_SERIALIZE(TO_CLOB(js.VigenciasEvento) RETURNING CLOB) AS VigenciasEvento
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Eventos[*]' COLUMNS (
  nmTipoEventoPagamento PATH '$.nmTipoEventoPagamento',
  deEvento              PATH '$.deEvento',
  nuRubrica             PATH '$.nuRubrica',
  VigenciasEvento       CLOB FORMAT JSON PATH '$.Vigencias'
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 21:52'
  AND parm.cdIdentificacao like '01-0524%'
ORDER BY parm.cdIdentificacao
;
/

-- Formula de Calculo
SELECT parm.sgAgrupamento, parm.sgOrgao, parm.sgModulo, parm.sgConceito, parm.dtExportacao, parm.cdIdentificacao, --parm.jsConteudo
js.sgFormulaCalculo,
js.deFormulaCalculo,
JSON_SERIALIZE(TO_CLOB(js.Versoes) RETURNING CLOB) AS Versoes
FROM emigParametrizacao parm
CROSS APPLY JSON_TABLE(parm.jsConteudo, '$.PAG.Rubrica.Tipos[*].Agrupamento.Formula' COLUMNS (
  sgFormulaCalculo  PATH '$.sgFormulaCalculo',
  deFormulaCalculo  PATH '$.deFormulaCalculo',
  Versoes           CLOB FORMAT JSON PATH '$.Versoes'
)) js
WHERE parm.sgModulo = 'PAG' AND parm.sgConceito = 'RUBRICA' AND parm.flAnulado = 'N'
  AND parm.sgAgrupamento = 'MILITAR' AND parm.sgOrgao IS NULL
  AND to_char(parm.dtExportacao, 'DD/MM/YYYY HH24:MI') = '29/06/2025 21:52'
  AND parm.cdIdentificacao like '01-0029%'
ORDER BY parm.cdIdentificacao
;

-- ===========================================================================
WITH
DeParaRubricaTributacao AS (
SELECT tpRubAgrupParametro, tpTributacao FROM JSON_TABLE('{"ParmTrb":[
{"tpParm":"cdRubAgrupDescINSS","tpTrb":"INSS"},
{"tpParm":"cdRubAgrupDescINSSSobre13","tpTrb":"INSS Gratificação Natalina"},
{"tpParm":"cdRubAgrupDescIRRF","tpTrb":"IRRF"},
{"tpParm":"cdRubAgrupDescIRRFSobre13","tpTrb":"IRRF Gratificação Natalina"},
{"tpParm":"cdRubAgrupDescIRRFSobreFerias","tpTrb":"IRRF ferias"},
{"tpParm":"cdRubAgrupIPREVFundFinanc","tpTrb":"IPER Fundo Financeiro [RRA]"},
{"tpParm":"cdRubAgrupIPREVFundFinanc13","tpTrb":"IPER Fundo Financeiro Gratificação Natalina [RRA]"},
{"tpParm":"cdRubAgrupIPREVFundLC662","tpTrb":"IPER Fundo LC 662 [RRA]"},
{"tpParm":"cdRubAgrupIPREVFundLC66213","tpTrb":"IPER Fundo LC 662 Gratificação Natalina [RRA]"},
{"tpParm":"cdRubAgrupIPREVFundPrev","tpTrb":"IPER Fundo Previdenciário [RRA]"},
{"tpParm":"cdRubAgrupDescIPREVLiminar","tpTrb":"IPER Liminar [RRA]"},
{"tpParm":"cdRubricaAgrupDescIPREVJun1613","tpTrb":"IPER Jun 1613 [RRA]"},
{"tpParm":"cdRubricaAgrupDescIPREVJun2016","tpTrb":"IPER Jun 2016 [RRA]"},
{"tpParm":"cdRubAgrupDescIPREVDepois2008","tpTrb":"IPER Fundo Previdenciário Depois 2008"},
{"tpParm":"cdRubAgrupDescIPREVAntes2008","tpTrb":"IPER Fundo Previdenciário Antes 2008"},
{"tpParm":"cdRubricaAgrupDescIPESC","tpTrb":"IPESC"},
{"tpParm":"cdRubAgrupDescIPESCSobre13","tpTrb":"IPESC Gratificação Natalina"},
{"tpParm":"cdRubricaAgrupDescIPESCJul2008","tpTrb":"IPESC Jul 2008"},
{"tpParm":"cdRubAgrupDescIPESCJul200813","tpTrb":"IPESC Jul 2008 Gratificação Natalina"},
{"tpParm":"cdRubricaAgrupDescCPSM","tpTrb":"CPSM"},
{"tpParm":"cdRubAgrupDescCPSMSobre13","tpTrb":"CPSM Gratificação Natalina"},
{"tpParm":"cdRubAgrupDescCPSMRetera","tpTrb":"CPSM [RRA]"},
{"tpParm":"cdRubAgrupDescCPSMRetera13","tpTrb":"CPSM Gratificação Natalina [RRA]"},
{"tpParm":"cdRubAgrupPensao13","tpTrb":"Pensão Alimentícia Gratificação Natalina"},
{"tpParm":"cdRubricaAdiant13Pensao","tpTrb":"Pensão Alimentícia Adiantamento Gratificação Natalina"},
{"tpParm":"cdRubAgrupPensaoAliRRA","tpTrb":"Pensão Alimentícia [RRA]"},
{"tpParm":"cdRubAgrupDescJudicial","tpTrb":"Desconto Judicial"},
{"tpParm":"cdRubricaAgrupDescRRA","tpTrb":"Desconto Judicial [RRA]"},
{"tpParm":"cdRubAgrupBloqRet","tpTrb":"Abate Teto"},
{"tpParm":"cdRubAgrupBloqRet13Sal","tpTrb":"Abate Teto Gratificação Natalina"},
{"tpParm":"cdRubAgrupBloqRetExercFind","tpTrb":"Abate Teto [RRA]"},
{"tpParm":"cdRubAgrupBloqExercFind13Sal","tpTrb":"Abate Teto Gratificação Natalina [RRA]"}
]}', '$.ParmTrb[*]' COLUMNS ( tpRubAgrupParametro PATH '$.tpParm', tpTributacao   PATH '$.tpTrb')) js
),
AgrupamentoParametro AS (
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescINSSSobre13' AS tpRubAgrupParametro, cdRubAgrupDescINSSSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRF' AS tpRubAgrupParametro, cdRubAgrupDescIRRF AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobre13' AS tpRubAgrupParametro, cdRubAgrupDescIRRFSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobreFerias' AS tpRubAgrupParametro, cdRubAgrupDescIRRFsobreFerias AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPESCJul2008' AS tpRubAgrupParametro, cdRubricaAgrupDescIPESCjul2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPESCJul200813' AS tpRubAgrupParametro, cdRubAgrupDescIPESCJul200813 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundPrev' AS tpRubAgrupParametro, cdRubAgrupIPREVFundPrev AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet' AS tpRubAgrupParametro, cdRubAgrupBloqRet AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRetExercFind' AS tpRubAgrupParametro, cdRubAgrupBloqRetExercFind AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAdiant13Pensao' AS tpRubAgrupParametro, cdRubricaAdiant13Pensao AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqRet13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqExercFind13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqExercFind13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensao13' AS tpRubAgrupParametro, cdRubAgrupPensao13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescRRA' AS tpRubAgrupParametro, cdRubricaAgrupDescRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensaoAliRRA' AS tpRubAgrupParametro, cdRubAgrupPensaoAliRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun2016' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun2016 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun1613' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun1613 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVAntes2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVAntes2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVDepois2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVDepois2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC662' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC662 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc13' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC66213' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC66213 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescCPSM' AS tpRubAgrupParametro, cdRubricaAgrupDescCPSM AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMSobre13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVLiminar' AS tpRubAgrupParametro, cdRubAgrupDescIPREVLiminar AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescJudicial' AS tpRubAgrupParametro, cdRubAgrupDescJudicial AS cdRubricaAgrupamento FROM epagAgrupamentoParametro
),
ParametroTributacao AS (
SELECT parm.cdAgrupamento, a.sgAgrupamento, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
  JSON_ARRAYAGG(rubTrb.tpTributacao) AS ParametroTributacao
FROM AgrupamentoParametro parm
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = parm.cdAgrupamento
LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpRubAgrupParametro = parm.tpRubAgrupParametro
LEFT JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubricaAgrupamento = parm.cdRubricaAgrupamento
INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrp.cdRubrica
INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
WHERE parm.cdRubricaAgrupamento IS NOT NULL
GROUP BY parm.cdAgrupamento, a.sgAgrupamento, parm.cdRubricaAgrupamento, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
)
SELECT sgAgrupamento, 'PARAMETRO' AS Tipo, nuRubrica, ParametroTributacao AS Sigla FROM ParametroTributacao
WHERE cdAgrupamento = 19
UNION ALL
SELECT a.sgAgrupamento, 'FORMULA' AS Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) AS nuRubrica, f.deFormulaCalculo AS Sigla
FROM epagFormulaCalculo f
INNER JOIN epagRubricaAgrupamento ra ON ra.cdRubricaAgrupamento = f.cdRubricaAgrupamento
INNER JOIN epagRubrica r ON r.cdRubrica = ra.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ra.cdAgrupamento
WHERE f.cdAgrupamento = 19
UNION ALL
SELECT a.sgAgrupamento, 'EVENTO' AS Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) AS nuRubrica, e.deEvento AS Sigla
FROM epagEventoPagAgrup e
INNER JOIN epagRubricaAgrupamento ra ON ra.cdRubricaAgrupamento = e.cdRubricaAgrupamento
INNER JOIN epagRubrica r ON r.cdRubrica = ra.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ra.cdAgrupamento
WHERE ra.cdAgrupamento = 19
UNION ALL
SELECT a.sgAgrupamento, 'BASE' AS Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) AS nuRubrica, base.nmBaseCalculo AS Sigla
FROM epagRubricaAgrupamento ra
INNER JOIN epagRubrica r ON r.cdRubrica = ra.cdRubrica
INNER JOIN epagBaseCalculo base ON base.cdBaseCalculo = ra.cdBaseCalculo
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ra.cdAgrupamento
WHERE ra.cdAgrupamento = 19 and ra.cdBaseCalculo is not null
UNION ALL
SELECT a.sgAgrupamento, 'CONSIGNCAO' AS Tipo, lpad(r.cdTipoRubrica,2,0) || '-' || lpad(r.nuRubrica,4,0) AS nuRubrica,
TRIM(tpsrv.nmTipoServico || ' ' || cst.sgConsignataria) AS Sigla
FROM epagConsignacao csg
INNER JOIN epagConsignataria cst ON cst.cdConsignataria = csg.cdConsignataria
LEFT JOIN epagTipoServico tpsrv ON tpsrv.cdTipoServico = csg.cdTipoServico
INNER JOIN epagRubrica r ON r.cdRubrica = csg.cdRubrica
INNER JOIN epagRubricaAgrupamento ra ON ra.cdRubrica = r.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = ra.cdAgrupamento
WHERE ra.cdAgrupamento = 19
ORDER BY sgAgrupamento, nuRubrica, Tipo, Sigla
;
