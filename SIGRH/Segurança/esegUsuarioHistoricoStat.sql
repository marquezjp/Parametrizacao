select
 m.nmmodulo,
 s.nmsubmodulo,
 fa.nmfuncionalidade,
 h.cdfuncionalidade,
 count(*)
 
from esegusuariohistorico h
left join esegfuncionalidadeagrupamento fa on fa.cdfuncionalidade = h.cdfuncionalidade and fa.cdagrupamento = 1
left join esegfuncionalidade f on f.cdfuncionalidade = h.cdfuncionalidade
left join esegsubmodulo s on s.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = s.cdmodulo

where h.dtultalteracao > to_date('01/01/2021')

group by
 m.nmmodulo,
 s.nmsubmodulo,
 fa.nmfuncionalidade,
 h.cdfuncionalidade

order by count(*) desc;