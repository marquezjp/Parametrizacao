with total_conceitos as (
select
'1-Vinculos' as Grupo, 
'1.01-ecadVinculo' as Conceito, 
case when c.dtdesligamento is not null and c.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadvinculo c
group by
case when c.dtdesligamento is not null and c.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'2-Vinculos Paramentros' as Grupo, 
'2.01-ecadUnidOrgJornadaTrab' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadunidorgjornadatrab c
union
select
'2-Vinculos Paramentros' as Grupo, 
'2.02-ecadMotivoDispensaRelvinc' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadmotivodispensarelvinc c
union
select
'2-Vinculos Paramentros' as Grupo, 
'2.03-ecadRelTrabOpcaoRemuneracao' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadreltrabopcaoremuneracao c
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.01-ecadHistCargoEfetivo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargoefetivo c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.02-ecadHistCargaHoraria' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargahoraria c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.03-ecadHistNivelRefCEF' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistnivelrefcef c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.04-ecadHistSitPrevVinculo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistsitprevvinculo c 
inner join ecadhistcargoefetivo cef on cef.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.05-ecadLocalTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadlocaltrabalho c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.06-ecadHistJornadaTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistjornadatrabalho c 
inner join ecadlocaltrabalho l on l.cdlocaltrabalho = c.cdlocaltrabalho
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = l.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.07-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join ecadhistcargoefetivo cef on cef.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3-Vinculos Efetivos' as Grupo, 
'3.08-ecadHistFinalCargoEfetivo' as Conceito, 
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistfinalcargoefetivo c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 5
group by
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.01-ecadHistCargoEfetivo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargoefetivo c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.02-ecadHistCargaHoraria' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargahoraria c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.03-ecadHistNivelRefCEF' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistnivelrefcef c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.04-ecadHistSitPrevVinculo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistsitprevvinculo c 
inner join ecadhistcargoefetivo cef on cef.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.05-ecadLocalTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadlocaltrabalho c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.06-ecadHistJornadaTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistjornadatrabalho c 
inner join ecadlocaltrabalho l on l.cdlocaltrabalho = c.cdlocaltrabalho
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = l.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.07-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join ecadhistcargoefetivo cef on cef.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'4-Vinculos Contrato Temporario' as Grupo, 
'4.08-ecadHistFinalCargoEfetivo' as Conceito, 
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistfinalcargoefetivo c 
inner join ecadhistcargoefetivo cef on cef.cdhistcargoefetivo = c.cdhistcargoefetivo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
where cef.cdrelacaotrabalho = 3 
group by
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.01-ecadHistCargoCom' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargocom c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.02-ecadHistCargaHoraria' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistcargahoraria c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.03-ecadHistSitPrevVinculo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistsitprevvinculo c 
inner join ecadhistcargocom cco on cco.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.04-ecadLocalTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadlocaltrabalho c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.05-ecadHistJornadaTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistjornadatrabalho c 
inner join ecadlocaltrabalho l on l.cdlocaltrabalho = c.cdlocaltrabalho
inner join ecadhistcargocom cco on cco.cdhistcargocom = l.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.06-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join ecadhistcargocom cco on cco.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.07-ecadHistFinalCargoCom' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistfinalcargocom c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.08-ecadHistRecebimentoCCO' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistrecebimentocco c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5-Vinculos Cargos Comissionados' as Grupo, 
'5.09-ecadHistOpcaoRemuneracaoCCO' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(*) as Qtde 
from ecadhistopcaoremuneracaocco c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
)

select
Grupo,
Conceito,
nvl(vigentes,0) + nvl(FINALIZADOS,0) as Qtde,
nvl(vigentes,0) as Vigentes,
nvl(FINALIZADOS,0) as FINALIZADOS
from total_conceitos
pivot (sum(Qtde) for Vinculo in ('VIGENTES' as VIGENTES, 'FINALIZADOS' as FINALIZADOS))
order by 1, 2