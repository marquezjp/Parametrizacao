select fer.cdferiasprogramacaousufruto as PK_Fer,
       fer.dtinicial,
       fer.dtfinal,
       fer.insituacao,
       fer.flpagabonopecuniario,
       fer.nudias,
       fer.flanulado,
       fer.dtanulado
from emovferiasfruicaousufruto fer
inner join emovperiodoaquisitivoferias pa on pa.cdperiodoaquisitivoferias = fer.cdperiodoaquisitivoferias
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
where v.numatricula = 0012381
order by fer.dtinicial