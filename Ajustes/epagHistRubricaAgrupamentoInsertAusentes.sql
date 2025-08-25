--INSERT INTO epagHistRubricaAgrupamento
WITH
NaturezaRubrica AS (
SELECT rub.nuRubrica, rub.cdTipoRubrica AS nuNaturezaRubrica, rub.cdRubrica
FROM epagRubrica rub
WHERE rub.cdTipoRubrica IN (1, 5)
),
TipoRubrica AS (
SELECT 
CASE
  WHEN nuTipoRubrica IN (1, 2, 8, 10, 12) THEN 1
  WHEN nuTipoRubrica IN (5, 6, 4) THEN 5
  WHEN nuTipoRubrica = 9 THEN 9
  ELSE NULL
END AS nuNaturezaRubrica,
nuTipoRubrica, cdTipoRubrica
FROM epagTipoRubrica
),
RubricaAgrupamento As (
SELECT a.sgAgrupamento, rub.nuRubrica, rub.nuNaturezaRubrica, rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento
FROM NaturezaRubrica rub
INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubrica = rub.cdRubrica
INNER JOIN ecadAgrupamento a ON a.cdAgrupamento = rubagrp.cdAgrupamento
),
RubricaAgrupamentoAusentes AS (
SELECT natrubagrp.sgAgrupamento, rubagrp.cdAgrupamento, natrubagrp.nuNaturezaRubrica, rub.nuRubrica, tprub.nuTipoRubrica, rubagrp.cdRubricaAgrupamento
FROM RubricaAgrupamento natrubagrp
INNER JOIN epagRubrica rub ON rub.nuRubrica = natrubagrp.nuRubrica
INNER JOIN TipoRubrica tprub ON tprub.nuNaturezaRubrica = natrubagrp.nuNaturezaRubrica AND tprub.cdTipoRubrica = rub.cdTipoRubrica
LEFT JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubrica = rub.cdRubrica AND rubagrp.cdAgrupamento = natrubagrp.cdAgrupamento
WHERE rubagrp.cdRubrica IS NULL
),
RubricaAgrupamentoVigencia AS (
SELECT rubagrp.nuRubrica, rubagrp.nuNaturezaRubrica, rubagrp.cdAgrupamento, rubagrp.cdRubricaAgrupamento,
vigencia.derubricaagrupamento,
vigencia.derubricaagrupresumida,
vigencia.derubricaagrupdetalhada,
vigencia.nuanoiniciovigencia,
vigencia.numesiniciovigencia,
vigencia.nuanofimvigencia,
vigencia.numesfimvigencia,
vigencia.flpermiteafastacidente,
vigencia.flbloqlancfinanc,
vigencia.inlancproprelvinc,
vigencia.cdrelacaotrabalho,
vigencia.flcargahorariapadrao,
vigencia.nucargahorariasemanal,
vigencia.numesesapuracao,
vigencia.flaplicarubricaorgaos,
vigencia.nucpfcadastrador,
vigencia.dtinclusao,
vigencia.dtultalteracao,
vigencia.flgestaosobrerubrica,
vigencia.flgerarubricaescala,
vigencia.flgerarubricahoraextra,
vigencia.flgerarubricaservcco,
vigencia.ingerarubricacarreira,
vigencia.ingerarubricanivel,
vigencia.ingerarubricauo,
vigencia.ingerarubricacco,
vigencia.ingerarubricafuc,
vigencia.fllaudoacompanhamento,
vigencia.inaposentadoriaservidor,
vigencia.ingerarubricaafasttemp,
vigencia.inimpedimentorubrica,
vigencia.inrubricasexigidas,
vigencia.cdrubproporcionalidadecho,
vigencia.flpropmescomercial,
vigencia.flpropaposparidade,
vigencia.flpropservrelvinc,
vigencia.cdoutrarubrica,
vigencia.inpossuivalorinformado,
vigencia.flpermitefgftg,
vigencia.flpermiteapooriginadocco,
vigencia.flpagasubstituicao,
vigencia.flpagarespondendo,
vigencia.flconsolidarubrica,
vigencia.flpropafasttempnaoremun,
vigencia.flpropafafgftg,
vigencia.flcargahorarialimitada,
vigencia.flincidparcialcontrprev,
vigencia.flpropafacomissionado,
vigencia.flpropafacomopcperccef,
vigencia.flpreservavalorintegral,
vigencia.ingerarubricamotmovi,
vigencia.flpagaaposemparidade,
vigencia.flpercentlimitado100,
vigencia.ingerarubricaprograma,
vigencia.flpropafaccosubst,
vigencia.flimpedeidadecompulsoria,
vigencia.flgerarubricacarreiraincidecco,
vigencia.flgerarubricacarreiraincideapo,
vigencia.flgerarubricaccoincidecef,
vigencia.flsuspensa,
vigencia.flpercentreducaoafastremun,
vigencia.flpagamaiorrv,
vigencia.cdtipoindice,
vigencia.flgerarubricafucincidecef,
vigencia.flvalidasufixoprecedencialf,
vigencia.deformula,
vigencia.demodulo,
vigencia.decomposicao,
vigencia.devantagensnaoacumulaveis,
vigencia.deobservacao,
vigencia.flsuspensaretroativoerario,
vigencia.flpagaefetivoorgao,
vigencia.flignoraafastcefagpolitico,
vigencia.flpagaposentadoria

FROM RubricaAgrupamento rubagrp
INNER JOIN epagHistRubricaAgrupamento vigencia ON vigencia.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
),
VigenciasAusentes AS (
SELECT natrubagrp.sgAgrupamento, rubagrp.cdAgrupamento, natrubagrp.nuNaturezaRubrica, rub.nuRubrica, tprub.nuTipoRubrica, rubagrp.cdRubricaAgrupamento
FROM RubricaAgrupamento natrubagrp
INNER JOIN epagRubrica rub ON rub.nuRubrica = natrubagrp.nuRubrica
INNER JOIN TipoRubrica tprub ON tprub.nuNaturezaRubrica = natrubagrp.nuNaturezaRubrica AND tprub.cdTipoRubrica = rub.cdTipoRubrica
INNER JOIN epagRubricaAgrupamento rubagrp ON rubagrp.cdRubrica = rub.cdRubrica AND rubagrp.cdAgrupamento = natrubagrp.cdAgrupamento
LEFT JOIN epagHistRubricaAgrupamento vigencia ON vigencia.cdRubricaAgrupamento = rubagrp.cdRubricaAgrupamento
WHERE vigencia.cdRubricaAgrupamento IS NULL
)

--SELECT cdrubricaagrupamento, nuanoiniciovigencia, numesiniciovigencia, COUNT(*) qtd FROM (
SELECT --ausente.sgAgrupamento, ausente.nuNaturezaRubrica, ausente.nuRubrica, ausente.nuTipoRubrica, ausente.cdAgrupamento,
(SELECT NVL(MAX(cdhistrubricaagrupamento),0) FROM epagHistRubricaAgrupamento) + ROWNUM AS cdhistrubricaagrupamento,
ausente.cdRubricaAgrupamento,
vigencia.derubricaagrupamento,
vigencia.derubricaagrupresumida,
vigencia.derubricaagrupdetalhada,
vigencia.nuanoiniciovigencia,
vigencia.numesiniciovigencia,
vigencia.nuanofimvigencia,
vigencia.numesfimvigencia,
vigencia.flpermiteafastacidente,
vigencia.flbloqlancfinanc,
vigencia.inlancproprelvinc,
vigencia.cdrelacaotrabalho,
vigencia.flcargahorariapadrao,
vigencia.nucargahorariasemanal,
vigencia.numesesapuracao,
vigencia.flaplicarubricaorgaos,
vigencia.nucpfcadastrador,
vigencia.dtinclusao,
vigencia.dtultalteracao,
vigencia.flgestaosobrerubrica,
vigencia.flgerarubricaescala,
vigencia.flgerarubricahoraextra,
vigencia.flgerarubricaservcco,
vigencia.ingerarubricacarreira,
vigencia.ingerarubricanivel,
vigencia.ingerarubricauo,
vigencia.ingerarubricacco,
vigencia.ingerarubricafuc,
vigencia.fllaudoacompanhamento,
vigencia.inaposentadoriaservidor,
vigencia.ingerarubricaafasttemp,
vigencia.inimpedimentorubrica,
vigencia.inrubricasexigidas,
vigencia.cdrubproporcionalidadecho,
vigencia.flpropmescomercial,
vigencia.flpropaposparidade,
vigencia.flpropservrelvinc,
vigencia.cdoutrarubrica,
vigencia.inpossuivalorinformado,
vigencia.flpermitefgftg,
vigencia.flpermiteapooriginadocco,
vigencia.flpagasubstituicao,
vigencia.flpagarespondendo,
vigencia.flconsolidarubrica,
vigencia.flpropafasttempnaoremun,
vigencia.flpropafafgftg,
vigencia.flcargahorarialimitada,
vigencia.flincidparcialcontrprev,
vigencia.flpropafacomissionado,
vigencia.flpropafacomopcperccef,
vigencia.flpreservavalorintegral,
vigencia.ingerarubricamotmovi,
vigencia.flpagaaposemparidade,
vigencia.flpercentlimitado100,
vigencia.ingerarubricaprograma,
vigencia.flpropafaccosubst,
vigencia.flimpedeidadecompulsoria,
vigencia.flgerarubricacarreiraincidecco,
vigencia.flgerarubricacarreiraincideapo,
vigencia.flgerarubricaccoincidecef,
vigencia.flsuspensa,
vigencia.flpercentreducaoafastremun,
vigencia.flpagamaiorrv,
vigencia.cdtipoindice,
vigencia.flgerarubricafucincidecef,
vigencia.flvalidasufixoprecedencialf,
vigencia.deformula,
vigencia.demodulo,
vigencia.decomposicao,
vigencia.devantagensnaoacumulaveis,
vigencia.deobservacao,
vigencia.flsuspensaretroativoerario,
vigencia.flpagaefetivoorgao,
vigencia.flignoraafastcefagpolitico,
vigencia.flpagaposentadoria

FROM VigenciasAusentes ausente
INNER JOIN RubricaAgrupamentoVigencia vigencia ON vigencia.cdAgrupamento = ausente.cdAgrupamento
                                              AND vigencia.nuRubrica = ausente.nuRubrica
                                              AND vigencia.nuNaturezaRubrica = ausente.nuNaturezaRubrica
ORDER BY ausente.sgAgrupamento, ausente.nuNaturezaRubrica, ausente.nuRubrica, ausente.nuTipoRubrica
--) GROUP BY cdrubricaagrupamento, nuanoiniciovigencia, numesiniciovigencia HAVING COUNT(*) > 1
;
/

