select 
    lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
    v.dtadmissao,
    mcf.dtevento,
    mcf.dtmovimentacao,
    hnrcef.dtinicio,
    hnrcef.dtfim,
    --mcf.flanulado,
    --hnrcef.flanulado,
    --mcf.dtanulado,
    --hnrcef.dtanulado,
    mtv.demotivotransformacaocef,
    hnrcef.nugruposalarial,
    mcf.nunivelorigem,
    mcf.nureferenciaorigem,
    mcf.nuniveldestino,
    mcf.nureferenciadestino,
    hnrcef.nunivelenquadramento,
    hnrcef.nureferenciaenquadramento,
    hnrcef.nunivelpagamento,
    hnrcef.nureferenciapagamento
    
from emovmovcargoefetivo mcf
inner join ecadvinculo v on v.cdvinculo = mcf.cdvinculo
left join ecadhistnivelrefcef hnrcef on hnrcef.cdmovcargoefetivo = mcf.cdmovcargoefetivo
left join emovmotivotransformacaocef mtv on mtv.cdmotivotransformacaocef = mcf.cdmotivotransformacaocef

where v.numatricula = 940520
  and (mcf.flanulado = 'N' or hnrcef.flanulado = 'N')
  
order by
    v.numatricula,
    v.dtadmissao,
    mcf.dtevento,
    mcf.dtmovimentacao,
    hnrcef.dtinicio;