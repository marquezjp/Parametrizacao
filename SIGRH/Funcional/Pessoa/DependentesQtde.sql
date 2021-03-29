select gp.cdgrauparentesco, gp.nmgrauparentesco, count(*)

from ecaddependente d
inner join ecadpessoadependente pd on d.cddependente = pd.cddependente
inner join ecadgrauparentesco gp on gp.cdgrauparentesco = pd.cdgrauparentesco
inner join ecadgrauparentescoprevfin e on e.cdgrauparentescoprevfin = pd.cdgrauparentescoprevfin
inner join ecadpessoa p on p.cdpessoa = pd.cdresponsavel

group by gp.cdgrauparentesco, gp.nmgrauparentesco
order by 3 desc;