select *
from ecadhistjornadatrabalho hjt
inner join ecadlocaltrabalho lt on lt.cdlocaltrabalho = hjt.cdlocaltrabalho
inner join ecadvinculo v on v.cdvinculo = lt.cdvinculo
where v.numatricula = 0944408