select
 nfe.cdnivelformgrauesc,
 nf.nmnivelformacao,
 ge.nmgrauescolaridade,
 case nfe.cdgrauescolaridadesicap
 when 1 then 'FUNDAMENTAL COMPLETO'
 when 2 then 'FUNDAMENTAL INCOMPLETO'
 when 3 then 'MÉDIO COMPLETO'
 when 4 then 'MÉDIO INCOMPLETO'
 when 5 then 'SUPERIOR COMPLETO'
 when 6 then 'SUPERIOR INCOMPLETO'
 when 7 then 'OUTROS'
 else to_char(nfe.cdgrauescolaridadesicap)
end grauescolaridadesicap
from ecadnivelformgrauesc nfe
left join ecadnivelformacao nf on nf.cdnivelformacao = nfe.cdnivelformacao
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = nfe.cdgrauescolaridade;