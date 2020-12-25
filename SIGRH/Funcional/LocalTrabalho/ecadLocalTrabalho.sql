select lt.*
from ecadlocaltrabalho lt
inner join ecadvinculo v on v.cdvinculo = lt.cdvinculo
where v.numatricula = 0944408