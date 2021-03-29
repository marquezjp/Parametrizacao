select
 p.cdpessoa,
 p.nmpessoa,
 p.nucpf,
 d.nmdependente,
 d.dtnascimento,
 gp.nmgrauparentesco,
 --e.degrauparentescoprevfin,
 
 trunc((sysdate - d.dtnascimento) / 365) as idade,
 ge.nmgrauescolaridade,
 nf.nmnivelformacao,
 d.flinvalidez,
 
 case
  when gp.cdgrauparentesco in (1, 2, 24) then 1
  when gp.cdgrauparentesco in (3, 4, 13, 21, 26, 28)
   and trunc((sysdate - d.dtnascimento) / 365) <= 21 then 1
  when gp.cdgrauparentesco in (35)
   and trunc((sysdate - d.dtnascimento) / 365) <= 24 then 1
  when d.flinvalidez = 'S' then 1
  else 0
 end as qtdepir
 
from ecaddependente d
inner join ecadpessoadependente pd on d.cddependente = pd.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdresponsavel


left join ecadgrauparentesco gp on gp.cdgrauparentesco = pd.cdgrauparentesco
left join ecadgrauparentescoprevfin e on e.cdgrauparentescoprevfin = pd.cdgrauparentescoprevfin
left join ecadgrauescolaridade ge on ge.cdgrauescolaridade = d.cdgrauescolaridade
left join ecadnivelformacao nf on nf.cdnivelformacao = d.cdnivelformacao

--where gp.cdgrauparentesco not in (1, 2, 24)
--   and (gp.cdgrauparentesco not in (3, 4, 13, 21, 26, 28) or trunc((sysdate - d.dtnascimento) / 365) > 21)
--   and (gp.cdgrauparentesco not in (35) or trunc((sysdate - d.dtnascimento) / 365) > 24)
--   and d.flinvalidez != 'S'

order by 1, 4
;