select
 o.sgorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula as Matricula,
 lpad(rub.nurubrica,4,'0') as Rubrica,
 rub.derubricaagrupamento as DeRubrica,
 bc.nuanoreferenciainicial || lpad(bc.numesreferenciainicial,2,0) as ReferenciaInicial,
 bc.nuanoreferenciafinal || lpad(bc.numesreferenciafinal,2,0) as ReferenciaFinal,
 cons.flgeridascconsig as GeriadaConsig,
 case when consup.nuanoinicio is null then 'N' else 'S' end as ConsignacaoSuspensa,
 consup.nuanoinicio || lpad(consup.numesinicio,2,0) as SuspencaoInicio,
 consup.nuanofim || lpad(consup.numesfim,2,0) as SuspencaoFim
 
from epagbaseconsignacao bc
left join ecadvinculo v on v.cdvinculo = bc.cdvinculo
left join vcadorgao o on o.cdorgao = v.cdorgao

left join epagconsignacao cons on cons.cdconsignacao = bc.cdconsignacao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = cons.cdrubrica

left join epaghistbaseconsigsuspensao consup on consup.cdbaseconsignacao = bc.cdbaseconsignacao and consup.nuanofim is null

where bc.nuanoreferenciafinal is null and bc.numesreferenciafinal is null
  and cons.flgeridascconsig = 'S'
  --and o.sgorgao = 'SEMGE'

order by o.sgorgao, v.numatricula, rub.nurubrica