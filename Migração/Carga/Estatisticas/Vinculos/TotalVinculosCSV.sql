with
depara as (
select de, para
from json_table('{"depara":[
{"de":"CASACIVIL", "para":"CASA CIVIL"},
{"de":"CERIM", "para":"CASA CIVIL"},
{"de":"CSAMILITAR", "para":"CASA MILITAR"},
{"de":"BM", "para":"CBM-RR"},
{"de":"COGERR", "para":"COGER"},
{"de":"DEFPUB", "para":"DPE-RR"},
{"de":"IDEFER", "para":"IDEFER-RR"},
{"de":"IPEM", "para":"IPEM-RR"},
{"de":"CONJUCERR", "para":"JUCERR"},
{"de":"OGERR", "para":"OGE-RR"},
{"de":"POLCIVIL", "para":"PC-RR"},
{"de":"PROGE", "para":"PGE-RR"},
{"de":"PM", "para":"PM-RR"},
{"de":"CONCULT", "para":"SECULT"},
{"de":"CONEDUC", "para":"SEED"},
{"de":"PRODEB", "para":"SEED"},
{"de":"CONREFIS", "para":"SEFAZ"},
{"de":"PENSIONIST", "para":"SEGAD"},
{"de":"CONRODE", "para":"SEINF"},
{"de":"CONANTD", "para":"SEJUC"},
{"de":"CONPEN", "para":"SEJUC"},
{"de":"SEEPE", "para":"SEPE"},
{"de":"PLANTONIST", "para":"SESAU"},
{"de":"SEURB", "para":"SEURB-RR"},
{"de":"UNIVIR", "para":"UNIVIRR"},
{"de":"VICE GOV", "para":"VICE-GOV"},
]}', '$.depara[*]'
columns (de, para)
)),
orgaos as (
select upper(trim(sgagrupamento)) as sgagrupamento, upper(trim(sgorgao)) as sgorgao
from emigorgaocsv
),
vinculoscsv as (
select sgorgao, nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculoefetivocsv

union all
select sgorgao, nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculocomissionadocsv

union all
select sgorgao, 'ESTAGIARIO' as nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculobolsistacsv

union all
select sgorgao, nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculorecebidocsv

union all
select sgorgao, nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculocedidocsv

union all
select sgorgao, 'PENSAO NAO PREV' as nmrelacaotrabalho,
case when replace(dtdesligamento, 'NULL', '') is not null and to_date(dtdesligamento,'DD/MM/YYYY') < trunc(sysdate) then 'DESLIGADOS' else 'VIGENTES' end as situacao
from emigvinculopensaonaoprevcsv
),
total_vinculos as (
select
--o.sgagrupamento,
case o.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
end as sgagrupamento,
o.sgorgao,
case when v.nmrelacaotrabalho = 'ACT - ADMITIDO EM CARÁTER TEMPORÁRIO' then 'CONTRATO TEMPORARIO' else v.nmrelacaotrabalho end as nmrelacaotrabalho,
v.situacao,
count(*) as vinculos
from vinculoscsv v
left join depara on upper(trim(depara.de)) = upper(trim(v.sgorgao))
left join orgaos o on upper(trim(o.sgorgao)) = nvl(upper(trim(depara.para)),upper(trim(v.sgorgao)))
group by o.sgagrupamento, o.sgorgao, case when v.nmrelacaotrabalho = 'ACT - ADMITIDO EM CARÁTER TEMPORÁRIO' then 'CONTRATO TEMPORARIO' else v.nmrelacaotrabalho end, v.situacao
order by o.sgagrupamento, o.sgorgao, case when v.nmrelacaotrabalho = 'ACT - ADMITIDO EM CARÁTER TEMPORÁRIO' then 'CONTRATO TEMPORARIO' else v.nmrelacaotrabalho end, v.situacao
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