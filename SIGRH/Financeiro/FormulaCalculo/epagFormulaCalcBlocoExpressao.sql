
select
 --ag.sgagrupamento as Agrupamento,
 --nvl2(fcalc.cdorgao, o.sgorgao, 'AGRUPAMENTO') as Orgao,
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
 vfcalc.nuformulaversao as Versao,
 hfcalc.nuanoinicio || lpad(hfcalc.numesinicio,2,0) as AnoMesInicio,
 hfcalc.nuanofim || lpad(hfcalc.numesfim,2,0) as AnoMesFim,
 rub.derubricaagrupamento as DescricaoRubrica,
 --fcalc.sgformulacalculo as SiglaFormulaCalculo,
 --fcalc.deformulacalculo as DescricaoFormulaCalculo,

 bl.sgbloco as Bloco,
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as RubricaBloco,
 rub.derubricaagrupamento as DescricaoRubricaBloco,

 case exp.cdtipomneumonico
  when   1 then '[' || tpmn.sgtipomneumonico || ';' || vr.sgvalorreferencia || ']' -- REF
  when   2 then '[' || tpmn.sgtipomneumonico || ';' || f.sgbasecalculo || ']' -- BAS
  when   4 then '[' || tpmn.sgtipomneumonico || ';' || exp.intiporubrica || ';GR-' || bl.sgbloco || ';' || exp.inrelacaorubrica || ';' || exp.inmes || ';' || exp.insufixorub || ']' -- RUB
  else '[' || tpmn.sgtipomneumonico || ';' || exp.cdtipomneumonico || ']'
 end as Expressao,
 
 exp.deoperacao,
 --exp.cdtipoadicionaltempserv,
 --exp.cdvalorgeralcefagrup,
 exp.denivel,
 exp.dereferencia,
 --exp.decodigocco,
 --exp.cdestruturacarreira,
 --exp.cdfuncaochefia,
 exp.numeses,
 exp.nuvalor,
 exp.flvalorhoraminuto,

 exp.cdformulacalcblocoexpressao
 
from epagformulacalcblocoexpressao exp
left join epagformcalcblocoexprubagrup exprub on exprub.cdformulacalcblocoexpressao = exp.cdformulacalcblocoexpressao
left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = exprub.cdrubricaagrupamento
left join epagformulacalculobloco bl on bl.cdformulacalculobloco = exp.cdformulacalculobloco

left join epagexpressaoformcalc expfcalc on expfcalc.cdexpressaoformcalc = bl.cdexpressaoformcalc
left join epaghistformulacalculo hfcalc on hfcalc.cdhistformulacalculo = expfcalc.cdhistformulacalculo
left join epagformulaversao vfcalc on vfcalc.cdformulaversao = hfcalc.cdformulaversao
left join epagformulacalculo fcalc on fcalc.cdformulacalculo = vfcalc.cdformulacalculo
left join ecadagrupamento ag on ag.cdagrupamento = fcalc.cdagrupamento
left join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = fcalc.cdrubricaagrupamento
left join vcadorgao o on o.cdorgao = fcalc.cdorgao

--- Dominio ---
left join epagtipomneumonico tpmn on tpmn.cdtipomneumonico = exp.cdtipomneumonico
left join epagvalorreferencia vr on vr.cdvalorreferencia = exp.cdvalorreferencia
left join epagbasecalculo f on f.cdbasecalculo = exp.cdbasecalculo
