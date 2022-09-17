--update ecadhistcargocom
--set cdregimeprevidenciario = 3
--where cdhistcargocom in (
--update ecadvinculo
--set cdregimeprevidenciario = 3
--where cdvinculo in (
with
efetivos as (
select v.cdpessoa, cef.dtinicio, cef.dtfim
from ecadhistcargoefetivo cef
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
),
comissionados as (
select v.cdpessoa, cco.dtinicio, cco.dtfim, cco.cdhistcargocom
from ecadhistcargocom cco
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
),
mesmo_vinculo as (
select c.cdhistcargocom, e.dtinicio, e.dtfim
from comissionados c
inner join efetivos e on e.cdpessoa = c.cdpessoa
                     and c.dtinicio between e.dtinicio and nvl(e.dtfim,sysdate)
                     and nvl(c.dtfim,sysdate) <= nvl(e.dtfim,sysdate)
)

--select cdhistcargocom from (
select
 o.sgorgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula || '-' || lpad(v.nuseqmatricula,2,0) as matricula,
 p.nmpessoa,
 p.nucpf,
 --v.dtadmissao,
 --v.dtdesligamento,
 cco.dtinicio as dtiniciocco,
 cco.dtfim as dtfimcco,
 mv.dtinicio as dtiniciocef,
 mv.dtfim as dtfimcef,
 v.cdregimeprevidenciario as cdregimeprevidenciariovinculo,
 cco.cdregimeprevidenciario as cdregimeprevidenciariocco
-- cco.cdhistcargocom,
-- v.cdvinculo
from ecadhistcargocom cco
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join mesmo_vinculo mv on mv.cdhistcargocom = cco.cdhistcargocom
--where mv.dtfim is not null
order by
 p.nucpf,
 o.sgorgao,
 v.numatricula,
 v.nuseqmatricula
--)
--)
;