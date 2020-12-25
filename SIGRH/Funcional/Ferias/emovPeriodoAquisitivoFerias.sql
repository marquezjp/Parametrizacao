select pa.cdperiodoaquisitivoferias as PK_PA,
       pa.dtinicio,
       pa.dtfimprevisto,
       pa.dtfim,
       pa.cdsituacaoperiodoaqferias,
       pa.nudiasferiasconcedido,
       pa.flajustedpro,
       fer.cdferiasprogramacaousufruto as PK_Fer,
       fer.dtinicial,
       fer.dtfinal,
       fer.insituacao,
       fer.flpagabonopecuniario,
       fer.nudias,
       fer.flanulado,
       fer.dtanulado
from emovperiodoaquisitivoferias pa
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
left join emovferiasfruicaousufruto fer on fer.cdperiodoaquisitivoferias = pa.cdperiodoaquisitivoferias
where v.numatricula = 0012381
order by pa.dtinicio