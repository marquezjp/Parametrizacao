select *
from eretprocessopagretroativo
where cdvinculo = (select cdvinculo from ecadvinculo where numatricula = 4348)