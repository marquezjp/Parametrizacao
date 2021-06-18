select
 p.nucpf as CPF,
 p.nmpessoa as Nome,
 o.sgorgao as Orgao,
 lpad(v.numatricula,7,0) || '-' || v.nudvmatricula as Matricula,
 v.dtadmissao as DataAdmissao
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao

where v.dtdesligamento is null
  and v.flanulado = 'N'
  and v.cdvinculo in (

select v.cdvinculo from ecadvinculo v
inner join (
select dup.cdpessoa, dup.cdorgao, count(*)
from ecadvinculo dup
where dup.flanulado = 'N' and dup.dtdesligamento is null
  and dup.cdvinculo not in (

select v.cdvinculo from ecadvinculo v
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo and cco.flanulado = 'N'
                              and cco.dtinicio = v.dtadmissao
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and cef.flanulado = 'N'
                                  and cef.cdrelacaotrabalho = 5 and cef.dtinicio  = v.dtadmissao
where v.dtdesligamento is null and cco.dtfim is not null and cef.cdvinculo is null

)

group by dup.cdpessoa, dup.cdorgao
having count(*) > 1
) d on d.cdpessoa = v.cdpessoa and d.cdorgao = v.cdorgao

)
order by p.nucpf, o.sgorgao, v.numatricula
