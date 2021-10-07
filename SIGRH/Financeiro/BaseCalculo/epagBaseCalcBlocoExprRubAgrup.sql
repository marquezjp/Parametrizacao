--- Lista Rubricas dos Blocos das Bases de Cálculo

select
 f.sgbasecalculo as SgBase,
 v.nuversao as Versao,
 h.nuanoiniciovigencia || lpad(h.numesiniciovigencia,2,0) as AnoMesInicial, 
 h.nuanofimvigencia || lpad(h.numesfimvigencia,2,0) as AnoMesFim,
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
 rub.derubricaagrupamento as DescricaoRubrica,
 bl.sgbloco as Bloco

from epagbasecalcblocoexprrubagrup exprub
left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = exprub.cdrubricaagrupamento
left join epagbasecalculoblocoexpressao exp on exp.cdbasecalculoblocoexpressao = exprub.cdbasecalculoblocoexpressao
left join epagbasecalculobloco bl on bl.cdbasecalculobloco = exp.cdbasecalculobloco
left join epaghistbasecalculo h on h.cdhistbasecalculo = bl.cdhistbasecalculo
left join epagbasecalculoversao v on v.cdversaobasecalculo = h.cdversaobasecalculo
left join epagbasecalculo f on f.cdbasecalculo = v.cdbasecalculo

where h.nuanofimvigencia is null

order by
 f.sgbasecalculo,
 v.nuversao,
 h.nuanoiniciovigencia,
 h.numesiniciovigencia, 
 h.nuanofimvigencia,
 h.numesfimvigencia,
 bl.sgbloco,
 rub.cdtiporubrica,
 rub.nurubrica;

--- Lista um Bloco da Base de Cálculo

select
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
 exprub.cdbasecalculoblocoexpressao,
 exprub.cdrubricaagrupamento

from epagbasecalcblocoexprrubagrup exprub
left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = exprub.cdrubricaagrupamento

where exprub.cdbasecalculoblocoexpressao in (
select exp.cdbasecalculoblocoexpressao
from epagbasecalculoblocoexpressao exp
left join epagbasecalculobloco bl on bl.cdbasecalculobloco = exp.cdbasecalculobloco
left join epaghistbasecalculo h on h.cdhistbasecalculo = bl.cdhistbasecalculo
left join epagbasecalculoversao v on v.cdversaobasecalculo = h.cdversaobasecalculo
left join epagbasecalculo f on f.cdbasecalculo = v.cdbasecalculo
where f.sgbasecalculo = 'IPREV'
  and v.nuversao = 1 and h.nuanoiniciovigencia = 2020 and h.numesiniciovigencia = 11
  and bl.sgbloco = 'C'
)
  and rub.nurubrica in (202, 204)

order by
 rub.cdtiporubrica,
 rub.nurubrica;

--- Inserir uma Lista de Rubricas em um Bloco

insert into epagbasecalcblocoexprrubagrup exprub (exprub.cdbasecalculoblocoexpressao, exprub.cdrubricaagrupamento)
select base.cdbasecalculoblocoexpressao, rub.cdrubricaagrupamento from vpagrubricaagrupamento rub
left join (select exp.cdbasecalculoblocoexpressao, f.sgbasecalculo, v.nuversao, h.nuanoiniciovigencia, h.numesiniciovigencia, bl.sgbloco
  from epagbasecalculoblocoexpressao exp
  left join epagbasecalculobloco bl on bl.cdbasecalculobloco = exp.cdbasecalculobloco
  left join epaghistbasecalculo h on h.cdhistbasecalculo = bl.cdhistbasecalculo
  left join epagbasecalculoversao v on v.cdversaobasecalculo = h.cdversaobasecalculo
  left join epagbasecalculo f on f.cdbasecalculo = v.cdbasecalculo
) base on base.sgbasecalculo = 'IPREV'
      and base.nuversao = 1 and base.nuanoiniciovigencia = 2020 and base.numesiniciovigencia = 11
      and base.sgbloco = 'C'
where rub.cdagrupamento = 1 and rub.cdtiporubrica = 2 and rub.nurubrica in (202, 204);