select
 lpad(numatricula,7,0) || '-' || nudvmatricula as Matricula,
 p.nmpessoa as Nome,
 af.cdmotivoafastdefinitivo as MotivoDefinitivo,
 af.cdmotivoafasttemporario as MotivoTemporario

from epagnaocalcular n
inner join ecadvinculo v on v.cdvinculo = n.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join eafaafastamentovinculo af on v.cdvinculo = af.cdvinculo and flremunerado = 'N';