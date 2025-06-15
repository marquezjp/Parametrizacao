with
rubvigencia as (
select 
case
 when r.cdtiporubrica in (1, 2, 8, 10, 12) then '01'
 when r.cdtiporubrica in (5, 6, 4) then '05'
 when r.cdtiporubrica = 9 then '09'
end as tpEvento,
lpad(r.cdtiporubrica,2,0) as nuTipoRubrica, lpad(r.nurubrica,4,0) as nuRubrica,
hra.derubricaagrupamento as deRubrica,
hra.derubricaagrupresumida as deRubricaResumida,
hra.derubricaagrupdetalhada as deRubricaDetalha,
tpi.sgtipoindice, upper(tpi.detipoindice) as deTipoIndice,
nvl(hra.nuanoiniciovigencia,to_char(sysdate, 'YYYY')) || lpad(nvl(hra.numesiniciovigencia,to_char(sysdate, 'MM')),2,0) as nuAnoMesInicioVigencia,
nvl(hra.nuanofimvigencia,to_char(sysdate, 'YYYY')) || lpad(nvl(hra.numesfimvigencia,to_char(sysdate, 'MM')),2,0) as nuAnoMesFimVigencia,
ra.fltributacao, ra.flpensaoalimenticia, ra.flconsignacao, ra.flincorporacao, ra.flsalariofamilia, ra.flsalariomaternidade, ra.flabonopermanencia,
ra.fldevtributacaoiprev, ra.fldevcorrecaomonetaria, ra.flpropria13, ra.fl13salpensao, ra.fladiant13pensao,
basecalc.nmbasecalculo, basecalc.sgbasecalculo, ra.cdbasecalculo,
ra.cdagrupamento, r.cdrubrica, ra.cdrubricaagrupamento, hra.cdhistrubricaagrupamento, r.cdtiporubrica, hra.cdtipoindice
from epagrubrica r
inner join epagrubricaagrupamento ra on ra.cdrubrica = r.cdrubrica
inner join epaghistrubricaagrupamento hra on hra.cdrubricaagrupamento = ra.cdrubricaagrupamento
left join epagtipoindice tpi on tpi.cdtipoindice = hra.cdtipoindice
left join epagbasecalculo basecalc on basecalc.cdagrupamento = ra.cdagrupamento and basecalc.cdbasecalculo = ra.cdbasecalculo
),
rubultimavigencia as (
select cdagrupamento, cdrubricaagrupamento, max(nuanomesfimvigencia) as nuanomesfimvigencia
from rubvigencia group by cdagrupamento, cdrubricaagrupamento
),
rub as (
select v.* from rubvigencia v
inner join rubultimavigencia u on u.cdagrupamento = v.cdagrupamento and u.cdrubricaagrupamento = v.cdrubricaagrupamento and u.nuanomesfimvigencia = v.nuanomesfimvigencia
)

select * from rub
order by cdagrupamento, tpEvento, nuRubrica, nuTipoRubrica, nuAnoMesInicioVigencia, nuAnoMesFimVigencia;
