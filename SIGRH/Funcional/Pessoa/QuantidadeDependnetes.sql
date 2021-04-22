select
 o.sgorgao,
 lpad(v.numatricula, 7, 0) || '-' || v.nudvmatricula as matricula,
 lpad(p.nucpf, 11, 0) as cpf,
 p.nmpessoa,
 
 nvl(nvl(qtdep.qtdepir, qtdeplegado.qtdepirlegado), 0) as quantidade_dep_ir,
 nvl(nvl(qtdep.qtdepsf, qtdeplegado.qtdepsflegado), 0) as quantidade_dep_sf
 
from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join vcadorgao o on o.cdorgao = v.cdorgao

--- Quantidade de Dependentes ---
left join (
select
 cdvinculo,
 sum(case
  when gp.cdgrauparentesco in (1, 2, 23) then 1                -- Conjuge
  when gp.cdgrauparentesco in (24, 25) then 1                  -- Pais
  when gp.cdgrauparentesco in (3, 4, 5, 6, 10, 13, 17, 22, 41) -- Filhos
   and trunc((sysdate - dep.dtnascimento) / 365) <= 21 then 1
  when gp.cdgrauparentesco in (18, 29) then 1                  -- Filhos com Invalidez
  when gp.cdgrauparentesco in (21, 26, 27, 28)                 -- Agregado
   and trunc((sysdate - dep.dtnascimento) / 365) <= 21 then 1
  when gp.cdgrauparentesco in (35)                             -- Universitario
   and trunc((sysdate - dep.dtnascimento) / 365) <= 24 then 1
  when dep.flinvalidez = 'S' then 1                              -- Invalidez
  else 0
 end) as qtdepir,
 sum(case
  when gp.cdgrauparentesco in (3, 4, 5, 6, 10, 13, 17, 22, 41) -- Filhos
   and trunc((sysdate - dep.dtnascimento) / 365) <= 14 then 1
  else 0
 end) as qtdepsf
from ecaddependentevinculo depvin
left join ecaddependente dep on dep.cddependente = depvin.cddependente
left join ecadpessoadependente pdep on pdep.cddependente = dep.cddependente
left join ecadgrauparentesco gp on gp.cdgrauparentesco = pdep.cdgrauparentesco
group by cdvinculo
) qtdep on qtdep.cdvinculo = v.cdvinculo

--- Quantidade de Dependentes Legado ---
left join (
select
 leg.cdvinculo,
 leg.nuanomesini,
 leg.nuanomesfim,
 leg.qtdepir as qtdepirlegado,
 leg.qtdepsf as qtdepsflegado
from ecadhistlegado leg
) qtdeplegado on qtdeplegado.cdvinculo = v.cdvinculo

--where qtdep.cdvinculo is not null
--  and qtdeplegado.cdvinculo is not null
  --and (qtdep.qtdepir is not null or qtdep.qtdepsf is not null)
  --and (qtdeplegado.qtdepirlegado is not null or qtdeplegado.qtdepsflegado is not null)
  --and ((qtdep.qtdepir != qtdeplegado.qtdepirlegado) or (qtdep.qtdepsf != qtdeplegado.qtdepsflegado))

order by p.nucpf, o.sgorgao, v.numatricula