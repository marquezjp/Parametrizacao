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
