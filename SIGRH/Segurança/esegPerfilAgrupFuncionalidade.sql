select * from esegperfilagrupamento;

select * from esegperfilagrupmodulo;

select * from esegperfilagrupsubmodulo;

select * from esegperfilagrupsubmodulo;

select * from esegperfilagrupfuncionalidade;

select * from esegperfilagrupfuncconsolidada;

select
f.cdperfilagrupfuncionalidade,

p.cdperfilagrupamento,
p.nmperfilagrupamento,
p.cdagrupamento,
p.cdautorizacaoacesso,

f.cdfuncagrupamento,

f.flinclusao,
f.flalteracao,
f.flexclusao,
f.flconsulta,
f.fllistagem,
f.flanulacao,
f.flimpressao,
f.flnaopermiteacesso

from  esegperfilagrupfuncionalidade f
inner join esegperfilagrupamento p on p.cdperfilagrupamento = f.cdperfilagrupamento
where p.cdperfilagrupamento = 1
;