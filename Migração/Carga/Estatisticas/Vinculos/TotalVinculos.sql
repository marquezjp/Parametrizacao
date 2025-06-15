with total_vinculos as (
select
 a.sgagrupamento,
 o.sgorgao,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   when penesp.cdvinculobeneficiario is not null then 'PENSAO NAO PREV'
--   else 'PENSAO NAO PREV'
   else 'OUTRO'
 end as relacao_vinculo,
 case
   when dtdesligamento is not null and dtdesligamento < trunc(sysdate) then 'DESLIGADOS'
   else 'VIGENTES'
 end as situacao,
 count(*) as vinculos
from ecadvinculo v
inner join ecadhistorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
left join epvdhistpensaonaoprev penesp on penesp.cdvinculobeneficiario = v.cdvinculo 
where o.cdagrupamento not in (1, 19)
group by
 a.sgagrupamento,
 o.sgorgao,
 case
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is null then 'EFETIVO'
   when cef.cdrelacaotrabalho = 5 and cef.cdvinculo is not null and cco.cdvinculo is not null then 'COMISSIONADO NO MESMO VINCULO EFETIVO'
   when cco.cdvinculo is not null and cef.cdvinculo is null then 'COMISSIONADO'
   when cef.cdrelacaotrabalho = 3 then 'CONTRATO TEMPORARIO'
   when penesp.cdvinculobeneficiario is not null then 'PENSAO NAO PREV'
--   else 'PENSAO NAO PREV'
   else 'OUTRO'
 end,
 case
   when dtdesligamento is not null and dtdesligamento < trunc(sysdate) then 'DESLIGADOS'
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
),

resumo as (
select
 nvl(sgagrupamento,'TOTAL GERAL') as agrupamento,
 nvl2(sgagrupamento,nvl(sgorgao,''),null) as orgao,
 nvl2(sgorgao,nvl(relacao_vinculo,''),null) as relacao_vinculo,
 nvl(vigentes,0) + nvl(desligados,0) as vinculos,
 nvl(vigentes,0) as vigentes,
 nvl(desligados,0) as desligados,
 case relacao_vinculo
   when ''                    then 0
   when 'EFETIVO'             then 2
   when 'MILITAR'             then 3
   when 'CONTRATO TEMPORARIO' then 4
   when 'COMISSIONADO'        then 5
   when 'ESTAGIARIO'          then 6
   when 'CEDIDO'              then 7
   when 'RECEBIDO'            then 8
   when 'PENSAO NAO PREV'     then 9
  end as ordem_relacao_vinculo
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
 ordem_relacao_vinculo nulls first
)

select agrupamento, orgao, relacao_vinculo, vinculos, vigentes, desligados from resumo
/*
select 'VINCULO' as tipo, agrupamento as grupo, '202305' as anomes, orgao,
json_arrayagg(json_object(nvl(relacao_vinculo, 'TOTAL') value resumo_relacao_vinculo)) as resumo_orgao
from (select agrupamento, orgao, relacao_vinculo, json_object(vinculos, vigentes, desligados) as resumo_relacao_vinculo from resumo)
group by agrupamento, orgao
order by case when agrupamento = 'TOTAL GERAL' then null else agrupamento end nulls first, orgao nulls first
*/
;