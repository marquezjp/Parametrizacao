select
    lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
    s.dtinclusao,
    s.deprocessofisico,
    mcf.dtevento,
    mcf.dtmovimentacao,
    hnrcef.dtinicio,
    hnrcef.dtfim,
    mcf.flanulado,
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
    hnrcef.nureferenciapagamento,
    s.idreferencia,
    s.nunivelpagto,
    s.nureferenciapagto,
    s.dthomologacao,
    s.fldesomologado

from ecatsimulacaoretroativo s
inner join ecadvinculo v on v.cdvinculo = s.cdvinculo
left join ecatsimretmovimentacao sm on sm.cdsimulacaoretroativo = s.cdsimulacaoretroativo
left join emovmovcargoefetivo mcf on mcf.cdmovcargoefetivo = sm.cdmovcargoefetivo
left join ecadhistnivelrefcef hnrcef on hnrcef.cdmovcargoefetivo = sm.cdmovcargoefetivo
left join emovmotivotransformacaocef mtv on mtv.cdmotivotransformacaocef = mcf.cdmotivotransformacaocef

where v.numatricula = 940520
  --and (mcf.flanulado = 'N' or hnrcef.flanulado = 'N')

order by
    v.numatricula,
    s.dtinclusao,
    s.cdsimulacaoretroativo,
    mcf.dtevento,
    mcf.dtmovimentacao,
    hnrcef.dtinicio;