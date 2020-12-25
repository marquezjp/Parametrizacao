select lpad(v.numatricula || '-' || v.nudvmatricula, 9, 0) as Matricula,
       p.nmpessoa,
       a.dtinicio,
       ats.dtprorrogacao,
       a.dtfim,
       a.dtfimprevisto,
       avr.dtretorno,
       ats.qtdiasprorrogacao,
       a.qtddiasafastado,
       h.demotivoafasttemporario,
       avr.dtretorno

from eafaafastamentovinculo a
inner join ecadvinculo v on v.cdvinculo = a.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join eafaafastamentovinculoretorno avr on avr.cdafastamento = a.cdafastamento
left join epagprorrogaperaquistempserv ats on ats.cdafastamento = a.cdafastamento
left join eafamotivoafasttemporario t on t.cdmotivoafasttemporario = a.cdmotivoafasttemporario
left join eafahistmotivoafasttemp h on h.cdmotivoafasttemporario = t.cdmotivoafasttemporario

where v.numatricula = 0945117