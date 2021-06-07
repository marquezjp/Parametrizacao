select cv.*
from ecadpessoacurriculo cv
inner join ecadpessoa p on p.cdpessoa = cv.cdpessoa
where p.nucpf = 99495023491
  and cv.flanulado = 'S'
  order by cv.cdcurriculo

--delete from ecadpessoacurriculo
--where cdcurriculo in (select cv.*
--                        from ecadpessoacurriculo cv
--                        inner join ecadpessoa p on p.cdpessoa = cv.cdpessoa
--                        where p.nucpf = 99495023491 and cv.flanulado = 'S')

select
 cv.cdcurriculo,
 p.nmpessoa,
 p.nucpf,
 c.decurso,
 ac.nmareaconhecimento,
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
 end grauescolaridadesicap,
 cv.dtapresentacaotitulacao
from ecadpessoacurriculo cv
inner join ecadpessoa p on p.cdpessoa = cv.cdpessoa

left join ecadcurso c on c.cdcurso = cv.cdcurso
left join ecadareaconhecimento ac on ac.cdareaconhecimento = c.cdareaconhecimento

left join ecadnivelformgrauesc nfe on nfe.cdnivelformgrauesc = cv.cdnivelformgrauesc
left join ecadnivelformacao nf on nf.cdnivelformacao = nfe.cdnivelformacao
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = nfe.cdgrauescolaridade

where cv.flanulado = 'N'

order by p.nucpf, cv.dtapresentacaotitulacao;