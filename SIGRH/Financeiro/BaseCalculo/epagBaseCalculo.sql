---- Lista os Blocos de uma Base de Cálculo
select
 f.sgbasecalculo as sgBase,
 f.nmbasecalculo as nmBase,
 --f.sgbasecalculo||'-'||f.nmbasecalculo as sgBase,
 v.nuversao as Versao,
 h.nuanoiniciovigencia || lpad(h.numesiniciovigencia,2,0) as AnoMesInicio,
 h.nuanofimvigencia || lpad(h.numesfimvigencia,2,0) as AnoMesFim,
 --h.deexpressaocalculo as DescricaoExpressaoCalculo,
 h.deformula as Formula,
 
 bl.sgbloco as Bloco,
 case exp.cdtipomneumonico
  when   4 then '[' || tpmn.sgtipomneumonico || ';' || exp.intiporubrica || ';GR-' || bl.sgbloco || ';' || exp.inrelacaorubrica || ';' || exp.inmes || ';' || exp.insufixorub || ']' -- RUB
  when   1 then '[' || tpmn.sgtipomneumonico || ';' || vrexp.sgvalorreferencia || ']' -- REF
  --when  47 then '[' || tpmn.sgtipomneumonico || ']' -- QtDiasRelVinc
  --when  54 then '[' || tpmn.sgtipomneumonico || ']' -- QtDiasFeriasNoMes
  --when  64 then '[' || tpmn.sgtipomneumonico || ']' -- BaseIprev13
  --when  65 then '[' || tpmn.sgtipomneumonico || ']' -- SomaAno13
  --when  76 then '[' || tpmn.sgtipomneumonico || ']' -- Soma12Meses
  --when 107 then '[' || tpmn.sgtipomneumonico || ']' -- VlAdiantFerias
  --when 108 then '[' || tpmn.sgtipomneumonico || ']' -- VlTercoFerias
  --when 109 then '[' || tpmn.sgtipomneumonico || ']' -- Media13COMARHP
  else '[' || tpmn.sgtipomneumonico || ';' || exp.cdtipomneumonico || ']'
 end as Expressao

 --h.delimiteinferior as LimiteInferior,
 --h.delimitesuperior as LimiteSuperior,
 --h.nuqtdevalreferenciainferior as QtdeValorReferenciaInferior,
 --h.nuqtdevalreferenciasuperior as QtdeValorReferenciaSuperior,
 --vrinf.sgvalorreferencia as ValorReferenciaInferior,
 --vrsup.sgvalorreferencia as ValorReferenciaSuperior,

 --h.cdhistbasecalculo as cdBaseCalculo,
 --bl.cdbasecalculobloco as cdBaseCalculoBloco,
 --exp.cdbasecalculoblocoexpressao as cdBaseCalculoBlocoExpressao

from epagbasecalculo f
left join epagbasecalculoversao v on v.cdbasecalculo = f.cdbasecalculo
left join epaghistbasecalculo h on h.cdversaobasecalculo = v.cdversaobasecalculo --and h.numesfimvigencia is null

left join epagvalorreferencia vrinf on vrinf.cdvalorreferencia = h.cdvalorreferenciainferior
left join epagvalorreferencia vrsup on vrsup.cdvalorreferencia = h.cdvalorreferenciasuperior
left join epagbasecalculobloco bl on bl.cdhistbasecalculo = h.cdhistbasecalculo
left join epagbasecalculoblocoexpressao exp on exp.cdbasecalculobloco = bl.cdbasecalculobloco
left join epagtipomneumonico tpmn on tpmn.cdtipomneumonico = exp.cdtipomneumonico
left join epagvalorreferencia vrexp on vrexp.cdvalorreferencia = exp.cdvalorreferencia

where h.nuanofimvigencia is null
--where f.sgbasecalculo = 'IPREV'
  --and v.nuversao = 1
  --and h.nuanoiniciovigencia = 2020
  --and h.numesiniciovigencia = 11
  --and bl.sgbloco = 'C'

order by
 f.sgbasecalculo,
 v.nuversao,
 h.nuanoiniciovigencia,
 h.numesiniciovigencia,
 h.nuanofimvigencia,
 h.numesfimvigencia,
 bl.sgbloco