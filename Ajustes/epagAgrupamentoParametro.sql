/*
nuanoiniciovigencia,
numesiniciovigencia,
nuanofimvigencia,
numesfimvigencia,
nuCNPJINSS,                    -- 11111111111
cdTipoTributacaoIRRF,          -- 1
  1 - Regime de caixa
  2 - Regime de competência
  3 - Isolada
nuAproxIRRFPensao,             -- 10
vlPercentAdiant13,             -- 50
vlPercentAdiant13DescPensao,   -- 50
flRecebeAdiantamentos13,       -- S
flGeraINSSFolhaFerias,         -- S
flGeraPensaoFolhaFerias,       -- S
vlPercSobreBaseFGTS,           -- 8
vlPercMultaFGTS,               -- 40
flPagaRecisaoFolhaEspec,       -- N
flTributaRRASeparado,          -- S
flDescAfastSeparado,           -- N
nuIdadeApoCompulsoria,         -- 70
flBloqueiaNaoRecadastrado,     -- S
vlPagoCCONaoPossuiTPIncorp,
vlPercRestituicao,             -- 10
vlLimitePagRetroativo,         -- 3575.37
flObrigaConsignacao,           -- N
flObrigaRestituicao,           -- N
flProcRetroativoObrigatorio,   -- N
*/

WITH
DeParaRubricaTributacao AS (
SELECT tpRubAgrupParametro, tpTributacao FROM JSON_TABLE('
{"ParametroTributacao":[
{"tpRubAgrupParametro": "cdRubAgrupDescINSS",              "tpTributacao": "INSS"},
{"tpRubAgrupParametro": "cdRubAgrupDescINSSSobre13",       "tpTributacao": "INSS Gratificacao Natalina"},

{"tpRubAgrupParametro": "cdRubAgrupDescIRRF",              "tpTributacao": "IRRF"},
{"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobre13",       "tpTributacao": "IRRF Gratificacao Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobreFerias",   "tpTributacao": "IRRF ferias"},

{"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc",       "tpTributacao": "IPER Fundo Financeiro [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc13",     "tpTributacao": "IPER Fundo Financeiro Gratificação Natalina [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC662",        "tpTributacao": "IPER Fundo LC 662 [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC66213",      "tpTributacao": "IPER Fundo LC 662 Gratificação Natalina [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundPrev",         "tpTributacao": "IPER Fundo Previdenciário [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPREVLiminar",      "tpTributacao": "IPER Liminar [RRA]"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun1613",  "tpTributacao": "IPER Jun 1613 [RRA]"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun2016",  "tpTributacao": "IPER Jun 2016 [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPREVDepois2008",   "tpTributacao": "IPER Fundo Previdenciário Depois 2008"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPREVAntes2008",    "tpTributacao": "IPER Fundo Previdenciário Antes 2008"},

{"tpRubAgrupParametro": "cdRubricaAgrupDescIPESC",         "tpTributacao": "IPESC"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPESCSobre13",      "tpTributacao": "IPESC Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescIPESCJul2008",  "tpTributacao": "IPESC Jul 2008"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPESCJul200813",    "tpTributacao": "IPESC Jul 2008 Gratificação Natalina"},

{"tpRubAgrupParametro": "cdRubricaAgrupDescCPSM",          "tpTributacao": "CPSM"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMSobre13",       "tpTributacao": "CPSM Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera",        "tpTributacao": "CPSM [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera13",      "tpTributacao": "CPSM Gratificação Natalina [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupPensao13",              "tpTributacao": "Pensão Alimentícia Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubricaAdiant13Pensao",         "tpTributacao": "Pensão Alimentícia Adiantamento Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupPensaoAliRRA",          "tpTributacao": "Pensão Alimentícia [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupDescJudicial",          "tpTributacao": "Desconto Judicial"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescRRA",           "tpTributacao": "Desconto Judicial [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupBloqRet",               "tpTributacao": "ABATE TETO"},
{"tpRubAgrupParametro": "cdRubAgrupBloqRet13Sal",          "tpTributacao": "ABATE TETO GRATIFICACAO NATALINA"},
{"tpRubAgrupParametro": "cdRubAgrupBloqRetExercFind",      "tpTributacao": "ABATE TETO [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupBloqExercFind13Sal",    "tpTributacao": "ABATE TETO GRATIFICACAO NATALINA [RRA]"}
]}', '$.ParametroTributacao[*]' COLUMNS (
  tpRubAgrupParametro PATH '$.tpRubAgrupParametro',
  tpTributacao   PATH '$.tpTributacao'
)) js
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
SELECT a.sgAgrupamento, parm.cdRubricaAgrupamento,
  LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
  JSON_ARRAYAGG(rubTrb.tpTributacao) AS ParametroTributacao
FROM AgrupamentoParametro parm
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = parm.cdAgrupamento
LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpRubAgrupParametro = parm.tpRubAgrupParametro
LEFT JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubricaAgrupamento = parm.cdRubricaAgrupamento
INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrp.cdRubrica
INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
WHERE parm.cdRubricaAgrupamento IS NOT NULL
GROUP BY a.sgAgrupamento, parm.cdRubricaAgrupamento, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
),


/*

Importação

*/


RubParm AS (
SELECT parm.sgAgrupamento, parm.cdRubricaAgrupamento,
  JSON_ARRAYAGG(JSON_OBJECT(rubTrb.tpRubAgrupParametro VALUE parm.cdRubricaAgrupamento)) AS RubParm
FROM ParametroTributacao parm
CROSS APPLY JSON_TABLE(parm.ParametroTributacao, '$[*]' COLUMNS (
tpTributacao PATH '$'
)) js
LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpTributacao = js.tpTributacao
GROUP BY parm.sgAgrupamento, parm.cdRubricaAgrupamento
)
SELECT RubParm.sgAgrupamento, RubParm.cdRubricaAgrupamento,
js.cdRubAgrupDescINSSSobre13,
js.cdRubAgrupDescIRRF,
js.cdRubAgrupDescIRRFSobre13,
js.cdRubAgrupDescIRRFSobreFerias,
js.cdRubricaAgrupDescIPESCJul2008,
js.cdRubAgrupDescIPESCJul200813,
js.cdRubAgrupIPREVFundFinanc,
js.cdRubAgrupIPREVFundPrev,
js.cdRubAgrupBloqRet,
js.cdRubAgrupBloqRetExercFind,
js.cdRubricaAdiant13Pensao,
js.cdRubAgrupBloqRet13Sal,
js.cdRubAgrupBloqExercFind13Sal,
js.cdRubAgrupPensao13,
js.cdRubricaAgrupDescRRA,
js.cdRubAgrupPensaoAliRRA,
js.cdRubricaAgrupDescIPREVJun2016,
js.cdRubricaAgrupDescIPREVJun1613,
js.cdRubAgrupDescIPREVAntes2008,
js.cdRubAgrupDescIPREVDepois2008,
js.cdRubAgrupIPREVFundLC662,
js.cdRubAgrupIPREVFundFinanc13,
js.cdRubAgrupIPREVFundLC66213,
js.cdRubricaAgrupDescCPSM,
js.cdRubAgrupDescCPSMSobre13,
js.cdRubAgrupDescCPSMRetera,
js.cdRubAgrupDescCPSMRetera13,
js.cdRubAgrupDescIPREVLiminar,
js.cdRubAgrupDescJudicial
FROM RubParm
CROSS APPLY JSON_TABLE(RubParm.RubParm, '$' COLUMNS (
cdRubAgrupDescINSSSobre13      PATH '$.cdRubAgrupDescINSSSobre13',
cdRubAgrupDescIRRF             PATH '$.cdRubAgrupDescIRRF',
cdRubAgrupDescIRRFSobre13      PATH '$.cdRubAgrupDescIRRFSobre13',
cdRubAgrupDescIRRFSobreFerias  PATH '$.cdRubAgrupDescIRRFSobreFerias',
cdRubricaAgrupDescIPESCJul2008 PATH '$.cdRubricaAgrupDescIPESCJul2008',
cdRubAgrupDescIPESCJul200813   PATH '$.cdRubAgrupDescIPESCJul200813',
cdRubAgrupIPREVFundFinanc      PATH '$.cdRubAgrupIPREVFundFinanc',
cdRubAgrupIPREVFundPrev        PATH '$.cdRubAgrupIPREVFundPrev',
cdRubAgrupBloqRet              PATH '$.cdRubAgrupBloqRet',
cdRubAgrupBloqRetExercFind     PATH '$.cdRubAgrupBloqRetExercFind',
cdRubricaAdiant13Pensao        PATH '$.cdRubricaAdiant13Pensao',
cdRubAgrupBloqRet13Sal         PATH '$.cdRubAgrupBloqRet13Sal',
cdRubAgrupBloqExercFind13Sal   PATH '$.cdRubAgrupBloqExercFind13Sal',
cdRubAgrupPensao13             PATH '$.cdRubAgrupPensao13',
cdRubricaAgrupDescRRA          PATH '$.cdRubricaAgrupDescRRA',
cdRubAgrupPensaoAliRRA         PATH '$.cdRubAgrupPensaoAliRRA',
cdRubricaAgrupDescIPREVJun2016 PATH '$.cdRubricaAgrupDescIPREVJun2016',
cdRubricaAgrupDescIPREVJun1613 PATH '$.cdRubricaAgrupDescIPREVJun1613',
cdRubAgrupDescIPREVAntes2008   PATH '$.cdRubAgrupDescIPREVAntes2008',
cdRubAgrupDescIPREVDepois2008  PATH '$.cdRubAgrupDescIPREVDepois2008',
cdRubAgrupIPREVFundLC662       PATH '$.cdRubAgrupIPREVFundLC662',
cdRubAgrupIPREVFundFinanc13    PATH '$.cdRubAgrupIPREVFundFinanc13',
cdRubAgrupIPREVFundLC66213     PATH '$.cdRubAgrupIPREVFundLC66213',
cdRubricaAgrupDescCPSM         PATH '$.cdRubricaAgrupDescCPSM',
cdRubAgrupDescCPSMSobre13      PATH '$.cdRubAgrupDescCPSMSobre13',
cdRubAgrupDescCPSMRetera       PATH '$.cdRubAgrupDescCPSMRetera',
cdRubAgrupDescCPSMRetera13     PATH '$.cdRubAgrupDescCPSMRetera13',
cdRubAgrupDescIPREVLiminar     PATH '$.cdRubAgrupDescIPREVLiminar',
cdRubAgrupDescJudicial         PATH '$.cdRubAgrupDescJudicial'
)) js

=============================================================================================================
/*
INSERT INTO epagAgrupamentoParametro (
cdAgrupamentoParametro, cdAgrupamento, nuAnoInicioVigencia, nuMesInicioVigencia, nuAnoFimVigencia, nuMesFimVigencia,
flPagaRecisaoFolhaEspec, flGeraINSSFolhaFerias, flGeraPensaoFolhaFerias, flBloqueiaNaoRecadastrado, flTributaRRASeparado,
flRecebeAdiantamentos13, flObrigaConsignacao, flObrigaRestituicao, flProcRetroativoObrigatorio, flDescAfastSeparado, cdMotivoAfastTemporario,
vlPercentAdiant13, vlPercentAdiant13DescPensao, vlPagoCCONaoPossuiTPIncorp, vlPagoCCOCarreira, vlTetoAuxilioAlimVinc,
vlPercRestituicao, vlLimitePagRetroativo, vlPercRestituicaoBolsista, nuHoraInicialRetera, nuHoraFinalRetera,
nuAnoIniVerifSalario, nuMesIniVerifSalario, qtMaxPessoas, nuIdadeApoCompulsoria,
cdTipoTributacaoIRRF, nuAproxIRRFPensao, nuCNPJINSS,
vlPercSobreBaseFGTS, vlPercMultaFGTS,
cdRespoDIRF, nuDDDrespoDIRF, nuTelefoneRespoDIRF, cdGrupoDespesaMedicaDIRF, vlLimiteDIRFSemVinculo, vlLimiteDIRFComVinculo,
cdOrgaoResponsavelRAIS, cdResponsavelRAIS, nuDDDResponsavelRAIS, nuTelefoneResponsavelRAIS,
cdRubAgrupDescIRRF, cdRubAgrupDescIRRFSobre13, cdRubAgrupDescIRRFSobreFerias,
cdRubAgrupIPREVFundFinanc, cdRubAgrupIPREVFundFinanc13, cdRubAgrupIPREVFundLC662, cdRubAgrupIPREVFundLC66213,
cdRubAgrupDescIPREVAntes2008, cdRubAgrupDescIPREVDepois2008, cdRubAgrupIPREVFundPrev,
cdRubricaAgrupDescIPREVJun1613, cdRubricaAgrupDescIPREVJun2016, cdRubAgrupDescIPREVLiminar,
cdRubricaAgrupDescIPESC, cdRubAgrupDescIPESCSobre13, cdRubricaAgrupDescIPESCJul2008, cdRubAgrupDescIPESCJul200813,
cdRubricaAgrupDescCPSM, cdRubAgrupDescCPSMSobre13, cdRubAgrupDescCPSMRetera, cdRubAgrupDescCPSMRetera13,
cdRubAgrupDescINSS, cdRubAgrupDescINSSSobre13,
cdRubAgrupPensao13, cdRubricaAdiant13Pensao, cdRubAgrupPensaoAliRRA,
cdRubAgrupDescJudicial, cdRubricaAgrupDescRRA,
cdRubAgrupBloqRet, cdRubAgrupBloqRet13Sal, cdRubAgrupBloqRetExercFind, cdRubAgrupBloqExercFind13Sal,
nuCPFCadastrador, dtInclusao, dtUltAlteracao
)
*/
WITH
-- RubricaLista: lista Rubricas
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
DeParaRubricaTributacao AS (
SELECT tpRubAgrupParametro, tpTributacao FROM JSON_TABLE('
{"ParametroTributacao":[
{"tpRubAgrupParametro": "cdRubAgrupDescIRRF",              "tpTributacao": "IRRF"},
{"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobre13",       "tpTributacao": "IRRF Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupDescIRRFSobreFerias",   "tpTributacao": "IRRF Ferias"},

{"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc",       "tpTributacao": "IPER Fundo Financeiro [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundFinanc13",     "tpTributacao": "IPER Fundo Financeiro Gratificação Natalina [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC662",        "tpTributacao": "IPER Fundo LC 662 [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundLC66213",      "tpTributacao": "IPER Fundo LC 662 Gratificação Natalina [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupDescIPREVAntes2008",    "tpTributacao": "IPER Fundo Previdenciário Antes 2008"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPREVDepois2008",   "tpTributacao": "IPER Fundo Previdenciário Depois 2008"},
{"tpRubAgrupParametro": "cdRubAgrupIPREVFundPrev",         "tpTributacao": "IPER Fundo Previdenciário [RRA]"},

{"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun1613",  "tpTributacao": "IPER Jun 1613 [RRA]"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescIPREVJun2016",  "tpTributacao": "IPER Jun 2016 [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPREVLiminar",      "tpTributacao": "IPER Liminar [RRA]"},

{"tpRubAgrupParametro": "cdRubricaAgrupDescIPESC",         "tpTributacao": "IPESC"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPESCSobre13",      "tpTributacao": "IPESC Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescIPESCJul2008",  "tpTributacao": "IPESC Jul 2008"},
{"tpRubAgrupParametro": "cdRubAgrupDescIPESCJul200813",    "tpTributacao": "IPESC Jul 2008 Gratificação Natalina"},

{"tpRubAgrupParametro": "cdRubricaAgrupDescCPSM",          "tpTributacao": "CPSM"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMSobre13",       "tpTributacao": "CPSM Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera",        "tpTributacao": "CPSM [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupDescCPSMRetera13",      "tpTributacao": "CPSM Gratificação Natalina [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupDescINSS",              "tpTributacao": "INSS"},
{"tpRubAgrupParametro": "cdRubAgrupDescINSSSobre13",       "tpTributacao": "INSS Gratificação Natalina"},

{"tpRubAgrupParametro": "cdRubAgrupPensao13",              "tpTributacao": "Pensão Alimentícia Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubricaAdiant13Pensao",         "tpTributacao": "Pensão Alimentícia Adiantamento Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupPensaoAliRRA",          "tpTributacao": "Pensão Alimentícia [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupDescJudicial",          "tpTributacao": "Desconto Judicial"},
{"tpRubAgrupParametro": "cdRubricaAgrupDescRRA",           "tpTributacao": "Desconto Judicial [RRA]"},

{"tpRubAgrupParametro": "cdRubAgrupBloqRet",               "tpTributacao": "Abate Teto"},
{"tpRubAgrupParametro": "cdRubAgrupBloqRet13Sal",          "tpTributacao": "Abate Teto Gratificação Natalina"},
{"tpRubAgrupParametro": "cdRubAgrupBloqRetExercFind",      "tpTributacao": "Abate Teto [RRA]"},
{"tpRubAgrupParametro": "cdRubAgrupBloqExercFind13Sal",    "tpTributacao": "Abate Teto Gratificação Natalina [RRA]"}
]}', '$.ParametroTributacao[*]' COLUMNS (
  tpRubAgrupParametro PATH '$.tpRubAgrupParametro',
  tpTributacao   PATH '$.tpTributacao'
)) js
),
AgrupamentoParametro AS (
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRF' AS tpRubAgrupParametro, cdRubAgrupDescIRRF AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobre13' AS tpRubAgrupParametro, cdRubAgrupDescIRRFSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIRRFSobreFerias' AS tpRubAgrupParametro, cdRubAgrupDescIRRFsobreFerias AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundFinanc13' AS tpRubAgrupParametro, cdRubAgrupIPREVFundFinanc13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC662' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC662 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundLC66213' AS tpRubAgrupParametro, cdRubAgrupIPREVFundLC66213 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVAntes2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVAntes2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVDepois2008' AS tpRubAgrupParametro, cdRubAgrupDescIPREVDepois2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupIPREVFundPrev' AS tpRubAgrupParametro, cdRubAgrupIPREVFundPrev AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun1613' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun1613 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPREVJun2016' AS tpRubAgrupParametro, cdRubricaAgrupDescIPREVJun2016 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPREVLiminar' AS tpRubAgrupParametro, cdRubAgrupDescIPREVLiminar AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPESC' AS tpRubAgrupParametro, cdRubricaAgrupDescIPESC AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPESCSobre13' AS tpRubAgrupParametro, cdRubAgrupDescIPESCSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescIPESCJul2008' AS tpRubAgrupParametro, cdRubricaAgrupDescIPESCjul2008 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescIPESCJul200813' AS tpRubAgrupParametro, cdRubAgrupDescIPESCJul200813 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescCPSM' AS tpRubAgrupParametro, cdRubricaAgrupDescCPSM AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMSobre13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescCPSMRetera13' AS tpRubAgrupParametro, cdRubAgrupDescCPSMRetera13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescINSS' AS tpRubAgrupParametro, cdRubAgrupDescINSS AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescINSSSobre13' AS tpRubAgrupParametro, cdRubAgrupDescINSSSobre13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensao13' AS tpRubAgrupParametro, cdRubAgrupPensao13 AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAdiant13Pensao' AS tpRubAgrupParametro, cdRubricaAdiant13Pensao AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupPensaoAliRRA' AS tpRubAgrupParametro, cdRubAgrupPensaoAliRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupDescJudicial' AS tpRubAgrupParametro, cdRubAgrupDescJudicial AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubricaAgrupDescRRA' AS tpRubAgrupParametro, cdRubricaAgrupDescRRA AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL

SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet' AS tpRubAgrupParametro, cdRubAgrupBloqRet AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRet13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqRet13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqRetExercFind' AS tpRubAgrupParametro, cdRubAgrupBloqRetExercFind AS cdRubricaAgrupamento FROM epagAgrupamentoParametro UNION ALL
SELECT cdAgrupamentoParametro, cdAgrupamento, 'cdRubAgrupBloqExercFind13Sal' AS tpRubAgrupParametro, cdRubAgrupBloqExercFind13Sal AS cdRubricaAgrupamento FROM epagAgrupamentoParametro
),
ParametroTributacao AS (
SELECT a.sgAgrupamento, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0) AS nuRubrica,
  JSON_ARRAYAGG(rubTrb.tpTributacao RETURNING CLOB) AS ParametroTributacao
FROM AgrupamentoParametro parm
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = parm.cdAgrupamento
LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpRubAgrupParametro = parm.tpRubAgrupParametro
INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubricaAgrupamento = parm.cdRubricaAgrupamento
INNER JOIN epagRubrica rub ON rub.cdRubrica = rubagrp.cdRubrica
INNER JOIN epagTipoRubrica tprub ON tprub.cdTipoRubrica = rub.cdTipoRubrica
WHERE parm.cdRubricaAgrupamento IS NOT NULL
  AND a.sgAgrupamento = 'INDIR-FEMARH'
GROUP BY a.sgAgrupamento, LPAD(tprub.nuTipoRubrica,2,0) || '-' || LPAD(rub.nuRubrica,4,0)
),
RubParm AS (
SELECT DISTINCT parm.sgAgrupamento, a.cdAgrupamento,
JSON_ARRAYAGG(JSON_OBJECT(
  rubTrb.tpRubAgrupParametro VALUE 
    CASE WHEN rub.cdRubricaAgrupamento IS NULL THEN NULL
    ELSE TO_NUMBER(NVL(rub.cdRubricaAgrupamento,0)) END
) RETURNING CLOB) AS RubParm
FROM ParametroTributacao parm
CROSS APPLY JSON_TABLE(parm.ParametroTributacao, '$[*]' COLUMNS (tpTributacao PATH '$')) js
LEFT JOIN DeParaRubricaTributacao rubTrb ON rubTrb.tpTributacao = js.tpTributacao
LEFT JOIN ecadAgrupamento a ON a.sgAgrupamento = 'INDIR-ITERAIMA'
LEFT JOIN RubricaLista rub ON rub.cdAgrupamento = a.cdAgrupamento
                          AND rub.nuRubrica = parm.nuRubrica
GROUP BY parm.sgAgrupamento, a.cdAgrupamento
ORDER BY parm.sgAgrupamento
)

SELECT
9 AS cdAgrupamentoParametro,
RubParm.cdAgrupamento AS cdAgrupamento,
1901 AS nuAnoInicioVigencia,
01 AS nuMesInicioVigencia,
NULL AS nuAnoFimVigencia,
NULL AS nuMesFimVigencia,

'N' AS flPagaRecisaoFolhaEspec,
'S' AS flGeraINSSFolhaFerias,
'S' AS flGeraPensaoFolhaFerias,
'S' AS flBloqueiaNaoRecadastrado,
'S' AS flTributaRRASeparado,
'S' AS flRecebeAdiantamentos13,
'N' AS flObrigaConsignacao,
'N' AS flObrigaRestituicao,
'N' AS flProcRetroativoObrigatorio,
'N' AS flDescAfastSeparado,
NULL AS cdMotivoAfastTemporario,

50 AS vlPercentAdiant13,
50 AS vlPercentAdiant13DescPensao,
0 AS vlPagoCCONaoPossuiTPIncorp,
NULL AS vlPagoCCOCarreira,
NULL AS vlTetoAuxilioAlimVinc,
10 AS vlPercRestituicao,
3575.37 AS vlLimitePagRetroativo,
NULL AS vlPercRestituicaoBolsista,
NULL AS nuHoraInicialRetera,
NULL AS nuHoraFinalRetera,

NULL AS nuAnoIniVerifSalario,
NULL AS nuMesIniVerifSalario,
NULL AS qtMaxPessoas,
70 AS nuIdadeApoCompulsoria,

1 AS cdTipoTributacaoIRRF,
10 AS nuAproxIRRFPensao,
'11111111111' AS nuCNPJINSS,
8 AS vlPercSobreBaseFGTS,
40 AS vlPercMultaFGTS,

NULL AS cdRespoDIRF,
NULL AS nuDDDrespoDIRF,
NULL AS nuTelefoneRespoDIRF,
NULL AS cdGrupoDespesaMedicaDIRF,
NULL AS vlLimiteDIRFSemVinculo,
NULL AS vlLimiteDIRFComVinculo,
NULL AS cdOrgaoResponsavelRAIS,
NULL AS cdResponsavelRAIS,
NULL AS nuDDDResponsavelRAIS,
NULL AS nuTelefoneResponsavelRAIS,

cdRubAgrupDescIRRF, cdRubAgrupDescIRRFSobre13, cdRubAgrupDescIRRFSobreFerias,
cdRubAgrupIPREVFundFinanc, cdRubAgrupIPREVFundFinanc13, cdRubAgrupIPREVFundLC662, cdRubAgrupIPREVFundLC66213,
cdRubAgrupDescIPREVAntes2008, cdRubAgrupDescIPREVDepois2008, cdRubAgrupIPREVFundPrev,
cdRubricaAgrupDescIPREVJun1613, cdRubricaAgrupDescIPREVJun2016, cdRubAgrupDescIPREVLiminar,
cdRubricaAgrupDescIPESC, cdRubAgrupDescIPESCSobre13, cdRubricaAgrupDescIPESCJul2008, cdRubAgrupDescIPESCJul200813,
cdRubricaAgrupDescCPSM, cdRubAgrupDescCPSMSobre13, cdRubAgrupDescCPSMRetera, cdRubAgrupDescCPSMRetera13,
cdRubAgrupDescINSS, cdRubAgrupDescINSSSobre13,
cdRubAgrupPensao13, cdRubricaAdiant13Pensao, cdRubAgrupPensaoAliRRA,
cdRubAgrupDescJudicial, cdRubricaAgrupDescRRA,
cdRubAgrupBloqRet, cdRubAgrupBloqRet13Sal, cdRubAgrupBloqRetExercFind, cdRubAgrupBloqExercFind13Sal,

'11111111111' AS nuCPFCadastrador,
TRUNC(SYSDATE) AS dtInclusao,
SYSTIMESTAMP AS dtUltAlteracao

FROM RubParm
CROSS APPLY JSON_TABLE(RubParm.RubParm, '$' COLUMNS (
cdRubAgrupDescIRRF             NUMBER PATH '$.cdRubAgrupDescIRRF',
cdRubAgrupDescIRRFSobre13      NUMBER PATH '$.cdRubAgrupDescIRRFSobre13',
cdRubAgrupDescIRRFSobreFerias  NUMBER PATH '$.cdRubAgrupDescIRRFSobreFerias',

cdRubAgrupIPREVFundFinanc      NUMBER PATH '$.cdRubAgrupIPREVFundFinanc',
cdRubAgrupIPREVFundFinanc13    NUMBER PATH '$.cdRubAgrupIPREVFundFinanc13',
cdRubAgrupIPREVFundLC662       NUMBER PATH '$.cdRubAgrupIPREVFundLC662',
cdRubAgrupIPREVFundLC66213     NUMBER PATH '$.cdRubAgrupIPREVFundLC66213',

cdRubAgrupDescIPREVAntes2008   NUMBER PATH '$.cdRubAgrupDescIPREVAntes2008',
cdRubAgrupDescIPREVDepois2008  NUMBER PATH '$.cdRubAgrupDescIPREVDepois2008',
cdRubAgrupIPREVFundPrev        NUMBER PATH '$.cdRubAgrupIPREVFundPrev',

cdRubricaAgrupDescIPREVJun2016 NUMBER PATH '$.cdRubricaAgrupDescIPREVJun2016',
cdRubricaAgrupDescIPREVJun1613 NUMBER PATH '$.cdRubricaAgrupDescIPREVJun1613',
cdRubAgrupDescIPREVLiminar     NUMBER PATH '$.cdRubAgrupDescIPREVLiminar',

cdRubricaAgrupDescIPESC        NUMBER PATH '$.cdRubricaAgrupDescIPESC',
cdRubAgrupDescIPESCSobre13     NUMBER PATH '$.cdRubAgrupDescIPESCSobre13',
cdRubricaAgrupDescIPESCJul2008 NUMBER PATH '$.cdRubricaAgrupDescIPESCJul2008',
cdRubAgrupDescIPESCJul200813   NUMBER PATH '$.cdRubAgrupDescIPESCJul200813',

cdRubricaAgrupDescCPSM         NUMBER PATH '$.cdRubricaAgrupDescCPSM',
cdRubAgrupDescCPSMSobre13      NUMBER PATH '$.cdRubAgrupDescCPSMSobre13',
cdRubAgrupDescCPSMRetera       NUMBER PATH '$.cdRubAgrupDescCPSMRetera',
cdRubAgrupDescCPSMRetera13     NUMBER PATH '$.cdRubAgrupDescCPSMRetera13',

cdRubAgrupDescINSS             NUMBER PATH '$.cdRubAgrupDescINSS',
cdRubAgrupDescINSSSobre13      NUMBER PATH '$.cdRubAgrupDescINSSSobre13',

cdRubAgrupPensao13             NUMBER PATH '$.cdRubAgrupPensao13',
cdRubricaAdiant13Pensao        NUMBER PATH '$.cdRubricaAdiant13Pensao',
cdRubAgrupPensaoAliRRA         NUMBER PATH '$.cdRubAgrupPensaoAliRRA',

cdRubricaAgrupDescRRA          NUMBER PATH '$.cdRubricaAgrupDescRRA',
cdRubAgrupDescJudicial         NUMBER PATH '$.cdRubAgrupDescJudicial',

cdRubAgrupBloqRet              NUMBER PATH '$.cdRubAgrupBloqRet',
cdRubAgrupBloqRet13Sal         NUMBER PATH '$.cdRubAgrupBloqRet13Sal',
cdRubAgrupBloqRetExercFind     NUMBER PATH '$.cdRubAgrupBloqRetExercFind',
cdRubAgrupBloqExercFind13Sal   NUMBER PATH '$.cdRubAgrupBloqExercFind13Sal'
)) js
;
