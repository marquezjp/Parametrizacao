select
 cdcurso,
 decurso,
 nmareaconhecimento
from ecadcurso c
inner join ecadareaconhecimento ac on ac.cdareaconhecimento = c.cdareaconhecimento
order by nmareaconhecimento, decurso;

select count(*) from ecadcurso;