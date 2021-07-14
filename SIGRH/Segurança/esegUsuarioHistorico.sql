select
 u.nucpf,
 u.nmapelido,
 u.nmpessoa,
 m.nmmodulo,
 s.nmsubmodulo,
 fa.nmfuncionalidade,
 h.dtultalteracao
 
from esegusuariohistorico h
left join esegusuario u on u.cdusuario = h.cdusuario
left join esegfuncionalidadeagrupamento fa on fa.cdfuncionalidade = h.cdfuncionalidade and fa.cdagrupamento = 1
left join esegfuncionalidade f on f.cdfuncionalidade = h.cdfuncionalidade
left join esegsubmodulo s on s.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = s.cdmodulo
where h.dtultalteracao > to_date('01/07/2021')
  --and h.cdusuario = (select cdusuario from esegusuario where nucpf = '12900804450')
  and h.cdfuncionalidade in (select cdfuncionalidade from esegfuncionalidadeagrupamento where nmfuncionalidade like upper('%02.CONSULTA CONTRA-CHEQUE%'))

order by h.dtultalteracao desc;