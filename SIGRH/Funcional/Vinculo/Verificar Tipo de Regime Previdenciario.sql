select *
from ECADVINCULO
where dtdesligamento is null
and cdregimeprevidenciario = 2
and cdtiporegimeproprioprev is null;

select cdregimeprevidenciario, cdtiporegimeproprioprev, count(cdvinculo)
from ECADVINCULO
where dtdesligamento is null
-- and cdregimeprevidenciario = 2
group by cdregimeprevidenciario, cdtiporegimeproprioprev
order by cdregimeprevidenciario, cdtiporegimeproprioprev;

select *
from ecadtiporegimeproprioprev;