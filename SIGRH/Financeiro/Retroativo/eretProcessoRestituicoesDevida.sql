select cdrubricaagrupamento, count(*)
from eretprocessorestituicoesdevida
where cdprocessopagretroativo in (select cdprocessopagretroativo
                                 from eretprocessopagretroativo ret
                                 inner join ecadvinculo v on v.cdvinculo = ret.cdvinculo
                                 where v.numatricula = 4348)
group by cdrubricaagrupamento