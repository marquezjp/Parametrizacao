select
 Modulo,
 SubModulo,
 Funcionalidade,
 Operacao,
 count(*)

from (
select 
 m.nmmodulo as Modulo,
 sm.nmsubmodulo as SubModulo,
 fa.nmfuncionalidade as Funcionalidade,
 case log.cdoperacao
  when 1 then 'Inclusão'
  when 2 then 'Alteração'
  when 3 then 'Exclusão'
  when 4 then 'Consulta'
  when 5 then 'Listagem' -- Não Esta Gerando
  when 6 then 'Anulação' -- Detalhe é sempre null
  when 7 then 'Impressão' -- Não Esta Gerando
  when 8 then 'Repasse' -- Não Esta Gerando
  else null
 end as Operacao,
 to_char(dtlog) as Data

from eseglog log
left join esegautorizacaoacesso aa on aa.cdautorizacaoacesso = log.cdautorizacaoacesso
left join esegusuario u on u.cdusuario = aa.cdusuario
left join esegfuncionalidade f on f.cdfuncionalidade = log.cdfuncionalidade
left join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = sm.cdmodulo
left join esegfuncionalidadeagrupamento fa on fa.cdfuncagrupamento = log.cdfuncagrupamento
where dtlog > '09/07/2020'

union

select
 m.nmmodulo as Modulo,
 sm.nmsubmodulo as SubModulo,
 fa.nmfuncionalidade as Funcionalidade,
 'Consulta' as Operacao,
 to_char(h.dtultalteracao, 'DD/MM/YY') as Data
 
from esegusuariohistorico h
left join esegfuncionalidadeagrupamento fa on fa.cdfuncionalidade = h.cdfuncionalidade and fa.cdagrupamento = 1
left join esegfuncionalidade f on f.cdfuncionalidade = h.cdfuncionalidade
left join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = sm.cdmodulo

where h.dtultalteracao > to_date('09/07/2020')
)
group by 
 Modulo,
 SubModulo,
 Funcionalidade,
 Operacao

order by count(*) desc;


