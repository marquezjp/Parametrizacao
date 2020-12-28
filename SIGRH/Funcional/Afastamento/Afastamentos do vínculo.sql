select
 o.sgorgao as Orgao,
 lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
 p.nmpessoa as Nome,
 a.dtinicio,
 ats.dtprorrogacao,
 a.dtfim,
 a.dtfimprevisto,
 avr.dtretorno,
 ats.qtdiasprorrogacao,
 a.qtddiasafastado,
 h.demotivoafasttemporario,
 avr.dtretorno,
 a.dtinclusao

from eafaafastamentovinculo a
inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join eafaafastamentovinculoretorno avr on avr.cdafastamento = a.cdafastamento
left join epagprorrogaperaquistempserv ats on ats.cdafastamento = a.cdafastamento
left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp h on h.cdmotivoafasttemporario = t.cdmotivoafasttemporario

where v.numatricula in (947591, 928817, 934494, 925968, 944662, 947831, 946555, 948176)