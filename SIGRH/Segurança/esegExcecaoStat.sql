select
 m.nmmodulo,
 s.nmsubmodulo,
 fa.nmfuncionalidade,
 e.cdfuncagrupamento,
 count(*)
from esegexcecao e
left join esegfuncionalidadeagrupamento fa on fa.cdfuncagrupamento = e.cdfuncagrupamento and fa.cdagrupamento = 1
left join esegfuncionalidade f on f.cdfuncionalidade = fa.cdfuncionalidade
left join esegsubmodulo s on s.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = s.cdmodulo
--where cdusuario in (2938, 17609, 5775, 28172)
where demensagem not like 'Erro 1:Arquivo inexistente.%'
  and demensagem not like 'Erro 1:File does not exist.%'
  and e.cdfuncagrupamento not in (31366, 31364)
  and e.dtexcecao > '01/01/2021'
group by
 m.nmmodulo,
 s.nmsubmodulo,
 fa.nmfuncionalidade,
 e.cdfuncagrupamento

order by count(*) desc;