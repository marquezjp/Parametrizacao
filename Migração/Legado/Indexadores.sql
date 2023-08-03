select
'RH_GOV' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_GOV.dbo.TValoresIndexador ti
left join RH_GOV.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

union all

select
'RH_PM' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_PM.dbo.TValoresIndexador ti
left join RH_PM.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

union all

select
'RH_BM' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_BM.dbo.TValoresIndexador ti
left join RH_BM.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

union all
select
'RH_CER' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_CER.dbo.TValoresIndexador ti
left join RH_CER.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

union all
select
'RH_ITE' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_ITE.dbo.TValoresIndexador ti
left join RH_ITE.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

union all
select
'RH_RADIO' as DB,
t.NmIndexador ,
format(ti.DtInicial,'dd/MM/yyyy') as DtInicial,
format(ti.DtFinal,'dd/MM/yyyy') as DtFinal,
--case when ti.DtFinal > '01/08/2023' then null else format(ti.DtFinal,'dd/MM/yyyy') end as DtFinal,
ti.Valor 
from RH_RADIO.dbo.TValoresIndexador ti
left join RH_RADIO.dbo.TIndexadores t on t.CdEmpresa = ti.CdEmpresa and t.CdIndexador = ti.CdIndexador 

order by DB, NmIndexador, DtInicial desc
;