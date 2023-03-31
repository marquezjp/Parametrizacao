with total_vinculos as (
select
 a.sgagrupamento,
 o.sgorgao,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO PURO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   else 'OUTRO'
 end as relacao_vinculo,
 case
   when dtdesligamento is not null and dtdesligamento < trunc(sysdate) then 'DESLIGADOS'
   when ano.cdvinculo is null then 'DESLIGADOS'
   else 'VIGENTES'
 end as situacao,
 count(*) as vinculos
from ecadvinculo v
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
left join (select distinct cdvinculo from epagcapahistrubricavinculo capa
           inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                  and f.nuanoreferencia = 2022 and f.cdtipocalculo not in (2, 3)
           inner join ecadhistorgao o on o.cdorgao = f.cdorgao and o.cdagrupamento = 1
) ano on ano.cdvinculo = v.cdvinculo
where o.cdagrupamento = 1
group by
 a.sgagrupamento,
 o.sgorgao,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO PURO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   else 'OUTRO'
 end,
 case
   when dtdesligamento is not null and dtdesligamento < trunc(sysdate) then 'DESLIGADOS'
   when ano.cdvinculo is null then 'DESLIGADOS'
   else 'VIGENTES'
 end
),

total_orgao as (
select
 sgagrupamento,
 sgorgao,
 null as relacao_vinculo,
 situacao,
 sum(vinculos) as vinculos
from total_vinculos
group by sgagrupamento, sgorgao, situacao
),

total_agrupamento as (
select
 sgagrupamento,
 null as sgorgao,
 null as relacao_vinculo,
 situacao,
 sum(vinculos) as vinculos
from total_orgao
group by sgagrupamento, situacao
),

total_geral as (
select
 null as sgagrupamento,
 null as sgorgao,
 null as relacao_vinculo,
 situacao,
 sum(vinculos) as vinculos
from total_agrupamento
group by situacao
)

select
 nvl(sgagrupamento,'TOTAL GERAL') as agrupamento,
 nvl2(sgagrupamento,nvl(sgorgao,'TOTAL AGRUPAMENTO'),null) as orgao,
 nvl2(sgorgao,nvl(relacao_vinculo,'TOTAL ORGAO'),null) as relacao_vinculo,
 nvl(vigentes,0) + nvl(desligados,0) as vinculos,
 nvl(vigentes,0) as vigentes,
 nvl(desligados,0) as desligados
from (
select * from total_geral       union
select * from total_agrupamento union
select * from total_orgao       union
select * from total_vinculos
)
pivot (sum(vinculos) for situacao in ('VIGENTES' as VIGENTES, 'DESLIGADOS' as DESLIGADOS))
order by
 sgagrupamento nulls first,
 sgorgao nulls first,
 case relacao_vinculo
   when 'EFETIVO'             then 2
   when 'CONTRATO TEMPORARIO' then 3
   when 'COMISSIONADO PURO'   then 4
   when 'OUTRO'               then 9
   else 0
  end nulls first