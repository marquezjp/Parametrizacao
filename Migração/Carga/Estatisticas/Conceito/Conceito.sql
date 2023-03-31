-- Cargos
select Grupo, Conceito, Qtde, null as Vigentes, null as Finalizados from (
select '1.1-QLP'                        as Grupo, '1.1.1-emovDescricaoQLP'               as Conceito, count(*) as Qtde from emovDescricaoQLP               union
select '1.2-EstuturaCarreira'           as Grupo, '1.2.1-ecadItemCarreira'               as Conceito, count(*) as Qtde from ecadItemCarreira               union
select '1.2-EstuturaCarreira'           as Grupo, '1.2.2-ecadEstruturaCarreira'          as Conceito, count(*) as Qtde from ecadEstruturaCarreira          union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.1-ecadEvolucaoEstruturaCarreira'  as Conceito, count(*) as Qtde from ecadEvolucaoEstruturaCarreira  union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.2-ecadEvolucaoCEFCargaHoraria'    as Conceito, count(*) as Qtde from ecadEvolucaoCEFCargaHoraria    union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.3-ecadEvolucaoCEFNatVinc'         as Conceito, count(*) as Qtde from ecadEvolucaoCEFNatVinc         union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.4-ecadevolucaocefreltrab'         as Conceito, count(*) as Qtde from ecadevolucaocefreltrab         union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.5-ecadevolucaocefregtrab'         as Conceito, count(*) as Qtde from ecadevolucaocefregtrab         union
select '1.3-ParametrosEstuturaCarreira' as Grupo, '1.3.6-ecadevolucaocefregprev'         as Conceito, count(*) as Qtde from ecadevolucaocefregprev         union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.1-ecadGrupoOcupacional'           as Conceito, count(*) as Qtde from ecadGrupoOcupacional           union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.2-ecadCargoComissionado'          as Conceito, count(*) as Qtde from ecadCargoComissionado          union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.3-ecadEvolucaoCCOCargaHoraria'    as Conceito, count(*) as Qtde from ecadEvolucaoCCOCargaHoraria    union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.4-ecadEvolucaoCCONatVinc'         as Conceito, count(*) as Qtde from ecadEvolucaoCCONatVinc         union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.5-ecadEvolucaoCCORelTrab'         as Conceito, count(*) as Qtde from ecadEvolucaoCCORelTrab         union
select '1.4-Cargo Comissionado'         as Grupo, '1.4.6-ecadEvolucaoCCOValorRef'        as Conceito, count(*) as Qtde from ecadEvolucaoCCOValorRef        union
select '1.5-Valores Cargo Comissionado' as Grupo, '1.5.1-epagValorRefCCOAgrupOrgVersao'  as Conceito, count(*) as Qtde from epagValorRefCCOAgrupOrgVersao  union
select '1.5-Valores Cargo Comissionado' as Grupo, '1.5.2-epagHistValorRefCCOAgrupOrgVer' as Conceito, count(*) as Qtde from epagHistValorRefCCOAgrupOrgVer union
select '1.5-Valores Cargo Comissionado' as Grupo, '1.5.3-epagValorRefCCOAgrupOrgEspec'   as Conceito, count(*) as Qtde from epagValorRefCCOAgrupOrgEspec   union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.1-ecadOrgaoCarreira'              as Conceito, count(*) as Qtde from ecadOrgaoCarreira              union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.2-ecadOrgaoCargoCom'              as Conceito, count(*) as Qtde from ecadOrgaoCargoCom              union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.3-ecadOrgaoRegTrabalho'           as Conceito, count(*) as Qtde from ecadOrgaoRegTrabalho           union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.4-ecadOrgaoRegPrev'               as Conceito, count(*) as Qtde from ecadOrgaoRegPrev               union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.5-ecadOrgaorRelTrabalho'          as Conceito, count(*) as Qtde from ecadOrgaoRelTrabalho           union
select '1.6-ParametrosOrgao'            as Grupo, '1.6.6-ecadOrgaoNatVinculo'            as Conceito, count(*) as Qtde from ecadOrgaoNatVinculo
)
union
-- Pessoa
select Grupo, Conceito, Qtde, null as Vigentes, null as Finalizados from (
select '2.1-Pessoa'                     as Grupo, '2.1.01-ecadPessoa'                    as Conceito, count(*) as Qtde from ecadpessoa                     union
select '2.1-Pessoa'                     as Grupo, '2.1.02-ecadPessoaCTPS'                as Conceito, count(*) as Qtde from ecadpessoactps                 union
select '2.1-Pessoa'                     as Grupo, '2.1.03-ecadEndereco'                  as Conceito, count(*) as Qtde from (
select distinct e.cdendereco from ecadendereco e inner join ecadpessoa p on p.cdendereco = e.cdendereco)                                                   union

select '2.1-Pessoa'                     as Grupo, '2.1.04-ecadBairro'                    as Conceito, count(*) as Qtde
from ( select distinct e.cdbairro from ecadendereco e inner join ecadpessoa p on p.cdendereco = e.cdendereco)                                              union

select '2.2-Dependente'                 as Grupo, '2.2.01-ecadPessoaDependente'          as Conceito, count(*) as Qtde
from ecadpessoadependente c
inner join ecadpessoa p on p.cdpessoa = c.cdpessoadependente                                                                                               union

select '2.2-Dependente'                 as Grupo, '2.2.02-ecadDependente'                as Conceito, count(*) as Qtde from ecaddependente c
inner join ecadpessoadependente pd on pd.cddependente = c.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente                                                                                              union

select '2.2-Dependente'                 as Grupo, '2.2.03-ecadEndereco'                  as Conceito, count(*) as Qtde
from (select distinct d.cdendereco from ecaddependente d
inner join ecadpessoadependente pd on pd.cddependente = d.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente)                                                                                             union

select '2.2-Dependente'                 as Grupo, '2.2.04-ecadBairro'                    as Conceito, count(*) as Qtde
from (select distinct e.cdbairro from ecadendereco e
inner join ecaddependente d on d.cdendereco = e.cdendereco
inner join ecadpessoadependente pd on pd.cddependente = d.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente)
)
union
-- Vinculos
select Grupo, Conceito, Qtde, Vigentes, Finalizados from (
with total_conceitos as (
select
'3.1-Vinculos' as Grupo, 
'3.1.01-ecadVinculo' as Conceito, 
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
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.01-ecadUnidOrgJornadaTrab' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadunidorgjornadatrab c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.02-ecadMotivoDispensaRelvinc' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadmotivodispensarelvinc c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.03-ecadRelTrabOpcaoRemuneracao' as Conceito, 
'VIGENTES' as Vinculo,
count(*) as Qtde 
from ecadreltrabopcaoremuneracao c
union
select
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.01-ecadHistCargoEfetivo' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.02-ecadHistCargaHoraria' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.03-ecadHistNivelRefCEF' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.04-ecadHistSitPrevVinculo' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.05-ecadLocalTrabalho' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.06-ecadHistJornadaTrabalho' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.07-ecadHistDadosBancariosVinculo' as Conceito, 
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
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.08-ecadHistFinalCargoEfetivo' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.01-ecadHistCargoEfetivo' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.02-ecadHistCargaHoraria' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.03-ecadHistNivelRefCEF' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.04-ecadHistSitPrevVinculo' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.05-ecadLocalTrabalho' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.06-ecadHistJornadaTrabalho' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.07-ecadHistDadosBancariosVinculo' as Conceito, 
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
'3.4-Vinculos Contrato Temporario' as Grupo, 
'3.4.08-ecadHistFinalCargoEfetivo' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.01-ecadHistCargoCom' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.02-ecadHistCargaHoraria' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.03-ecadHistSitPrevVinculo' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.04-ecadLocalTrabalho' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.05-ecadHistJornadaTrabalho' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.06-ecadHistDadosBancariosVinculo' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.07-ecadHistFinalCargoCom' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.08-ecadHistRecebimentoCCO' as Conceito, 
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
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.09-ecadHistOpcaoRemuneracaoCCO' as Conceito, 
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
)
order by 1, 2
;
/


