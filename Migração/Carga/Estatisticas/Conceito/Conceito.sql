-- Orgaos
select Grupo, Conceito, Qtde, null as Vigentes, null as Finalizados from (
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.1-ecadAgrupamento'                as Conceito, count(1) as Qtde from ecadagrupamento         union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.2-ecadOrgao'                      as Conceito, count(1) as Qtde from ecadorgao               union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.3-ecadHistOrgao'                  as Conceito, count(1) as Qtde from ecadhistorgao           union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.4-ecadUnidadeOrganizacional'      as Conceito, count(1) as Qtde from ecadunidadeorganizacional union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.5-ecadHistuUnidadeOrganizacional'  as Conceito, count(1) as Qtde from ecadhistunidadeorganizacional union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.6-ecadCentroCusto'                as Conceito, count(1) as Qtde from ecadcentrocusto         union
select '1.1-Estrutura Organizacional'     as Grupo, '1.1.7-ecadOrgaoEmissor'               as Conceito, count(1) as Qtde from ecadorgaoemissor
)
union
-- Cargos
select Grupo, Conceito, Qtde, null as Vigentes, null as Finalizados from (
select '1.2-Quadro de Lotacao'            as Grupo, '1.2.1-emovDescricaoQLP'               as Conceito, count(1) as Qtde from emovDescricaoQLP               union
select '1.3-Estutura Carreira'            as Grupo, '1.3.1-ecadItemCarreira'               as Conceito, count(1) as Qtde from ecadItemCarreira               union
select '1.3-Estutura Carreira'            as Grupo, '1.3.2-ecadEstruturaCarreira'          as Conceito, count(1) as Qtde from ecadEstruturaCarreira          union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.1-ecadEvolucaoEstruturaCarreira'  as Conceito, count(1) as Qtde from ecadEvolucaoEstruturaCarreira  union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.2-ecadEvolucaoCEFCargaHoraria'    as Conceito, count(1) as Qtde from ecadEvolucaoCEFCargaHoraria    union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.3-ecadEvolucaoCEFNatVinc'         as Conceito, count(1) as Qtde from ecadEvolucaoCEFNatVinc         union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.4-ecadEvolucaoCEFRelTrab'         as Conceito, count(1) as Qtde from ecadevolucaocefreltrab         union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.5-ecadEvolucaoCEFRegTrab'         as Conceito, count(1) as Qtde from ecadevolucaocefregtrab         union
select '1.4-Parametros Estutura Carreira' as Grupo, '1.4.6-ecadEvolucaoCEFRegPrev'         as Conceito, count(1) as Qtde from ecadevolucaocefregprev         union
select '1.5-Valores Cargo Efetivo'        as Grupo, '1.5.1-epagNivelRefCEFAgrup'           as Conceito, count(1) as Qtde from epagnivelrefcefagrup           union
select '1.5-Valores Cargo Efetivo'        as Grupo, '1.5.2-epagNivelRefCEFAgrupVersao'     as Conceito, count(1) as Qtde from epagnivelrefcefagrupversao     union
select '1.5-Valores Cargo Efetivo'        as Grupo, '1.5.3-epagHistNivelRefCEFAgrup'       as Conceito, count(1) as Qtde from epaghistnivelrefcefagrup       union
select '1.5-Valores Cargo Efetivo'        as Grupo, '1.5.4-epagHistNivelRefCarrCEFAgrup'   as Conceito, count(1) as Qtde from epaghistnivelrefcarrcefagrup   union
select '1.5-Valores Cargo Efetivo'        as Grupo, '1.5.5-epagValorCarreiraCEFAgrup'      as Conceito, count(1) as Qtde from epagvalorcarreiracefagrup      union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.1-ecadGrupoOcupacional'           as Conceito, count(1) as Qtde from ecadGrupoOcupacional           union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.2-ecadCargoComissionado'          as Conceito, count(1) as Qtde from ecadCargoComissionado          union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.3-ecadEvolucaoCCOCargaHoraria'    as Conceito, count(1) as Qtde from ecadEvolucaoCCOCargaHoraria    union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.4-ecadEvolucaoCCONatVinc'         as Conceito, count(1) as Qtde from ecadEvolucaoCCONatVinc         union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.5-ecadEvolucaoCCORelTrab'         as Conceito, count(1) as Qtde from ecadEvolucaoCCORelTrab         union
select '1.6-Cargo Comissionado'           as Grupo, '1.6.6-ecadEvolucaoCCOValorRef'        as Conceito, count(1) as Qtde from ecadEvolucaoCCOValorRef        union
select '1.7-Valores Cargo Comissionado'   as Grupo, '1.7.1-epagValorRefCCOAgrupOrgVersao'  as Conceito, count(1) as Qtde from epagValorRefCCOAgrupOrgVersao  union
select '1.7-Valores Cargo Comissionado'   as Grupo, '1.7.2-epagHistValorRefCCOAgrupOrgVer' as Conceito, count(1) as Qtde from epagHistValorRefCCOAgrupOrgVer union
select '1.7-Valores Cargo Comissionado'   as Grupo, '1.7.3-epagValorRefCCOAgrupOrgEspec'   as Conceito, count(1) as Qtde from epagValorRefCCOAgrupOrgEspec   union
select '1.8-Parametros Orgao'             as Grupo, '1.8.1-ecadOrgaoCarreira'              as Conceito, count(1) as Qtde from ecadOrgaoCarreira              union
select '1.8-Parametros Orgao'             as Grupo, '1.8.2-ecadOrgaoCargoCom'              as Conceito, count(1) as Qtde from ecadOrgaoCargoCom              union
select '1.8-Parametros Orgao'             as Grupo, '1.8.3-ecadOrgaoRegTrabalho'           as Conceito, count(1) as Qtde from ecadOrgaoRegTrabalho           union
select '1.8-Parametros Orgao'             as Grupo, '1.8.4-ecadOrgaoRegPrev'               as Conceito, count(1) as Qtde from ecadOrgaoRegPrev               union
select '1.8-Parametros Orgao'             as Grupo, '1.8.5-ecadOrgaorRelTrabalho'          as Conceito, count(1) as Qtde from ecadOrgaoRelTrabalho           union
select '1.8-Parametros Orgao'             as Grupo, '1.8.6-ecadOrgaoNatVinculo'            as Conceito, count(1) as Qtde from ecadOrgaoNatVinculo
)
union
-- Pessoa
select Grupo, Conceito, Qtde, null as Vigentes, null as Finalizados from (
select '2.1-Pessoa'                       as Grupo, '2.1.01-ecadPessoa'                    as Conceito, count(1) as Qtde from ecadpessoa                     union
select '2.1-Pessoa'                       as Grupo, '2.1.02-ecadPessoaCTPS'                as Conceito, count(1) as Qtde from ecadpessoactps                 union
select '2.1-Pessoa'                       as Grupo, '2.1.03-ecadEndereco'                  as Conceito, count(1) as Qtde from (
select distinct e.cdendereco from ecadendereco e inner join ecadpessoa p on p.cdendereco = e.cdendereco)
union
select '2.1-Pessoa'                       as Grupo, '2.1.04-ecadBairro'                    as Conceito, count(1) as Qtde
from ( select distinct e.cdbairro from ecadendereco e inner join ecadpessoa p on p.cdendereco = e.cdendereco)
union
select '2.2-Dependente'                   as Grupo, '2.2.01-ecadPessoaDependente'          as Conceito, count(1) as Qtde
from ecadpessoadependente c
inner join ecadpessoa p on p.cdpessoa = c.cdpessoadependente
union
select '2.2-Dependente'                   as Grupo, '2.2.02-ecadDependente'                as Conceito, count(1) as Qtde from ecaddependente c
inner join ecadpessoadependente pd on pd.cddependente = c.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente
union
select '2.2-Dependente'                   as Grupo, '2.2.03-ecadEndereco'                  as Conceito, count(1) as Qtde
from (select distinct d.cdendereco from ecaddependente d
inner join ecadpessoadependente pd on pd.cddependente = d.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente)
union
select '2.2-Dependente'                   as Grupo, '2.2.04-ecadBairro'                    as Conceito, count(1) as Qtde
from (select distinct e.cdendereco from ecadendereco e
inner join ecaddependente d on d.cdendereco = e.cdendereco
inner join ecadpessoadependente pd on pd.cddependente = d.cddependente
inner join ecadpessoa p on p.cdpessoa = pd.cdpessoadependente)
union
-- Afastamento de Pessoa e Dependente
select '5.5-Registro Obito de Pessoa'     as Grupo, '5.5.01-eafaregistroobito'             as Conceito, count(1) as Qtde 
from eafaregistroobito c
inner join ecadpessoa p on p.cdpessoa = c.cdpessoa
union
select '5.5-Registro Obito de Pessoa'     as Grupo, '5.5.02-ecadCartorio'                  as Conceito, count(distinct c.cdcartorio) as Qtde 
from ecadcartorio c
inner join eafaregistroobito rgo on rgo.cdcartorio = c.cdcartorio
inner join ecadpessoa p on p.cdpessoa = rgo.cdpessoa
union 
select '5.6-Registro Obito de Dependente' as Grupo, '5.6.01-eafaregistroobito'             as Conceito, count(1) as Qtde 
from eafaregistroobito c
inner join ecaddependente d on d.cddependente = c.cddependente
union
select '5.6-Registro Obito de Dependente' as Grupo, '5.6.02-ecadCartorio'                  as Conceito, count(distinct c.cdcartorio) as Qtde 
from ecadcartorio c
inner join eafaregistroobito rgo on rgo.cdcartorio = c.cdcartorio
inner join ecaddependente d on d.cddependente = rgo.cddependente
)
union
select Grupo, Conceito, Qtde, Vigentes, Finalizados from (
with total_conceitos as (
-- Vinculos
select
'3.1-Vinculos' as Grupo, 
'3.1.01-ecadVinculo' as Conceito, 
case when c.dtdesligamento is not null and c.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
count(1) as Qtde 
from ecadunidorgjornadatrab c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.02-ecadBanco' as Conceito, 
'VIGENTES' as Vinculo,
count(1) as Qtde 
from ecadbanco c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.03-ecadAgencia' as Conceito, 
'VIGENTES' as Vinculo,
count(1) as Qtde 
from ecadagencia c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.04-ecadMotivoDispensaRelvinc' as Conceito, 
'VIGENTES' as Vinculo,
count(1) as Qtde 
from ecadmotivodispensarelvinc c
union
select
'3.2-Vinculos Paramentros' as Grupo, 
'3.2.05-ecadRelTrabOpcaoRemuneracao' as Conceito, 
'VIGENTES' as Vinculo,
count(1) as Qtde 
from ecadreltrabopcaoremuneracao c
union
select
'3.3-Vinculos Efetivos' as Grupo, 
'3.3.01-ecadHistCargoEfetivo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
'3.3.08-ecadHistCentroCustoVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistcentrocustovinculo c 
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
'3.3.09-ecadHistFinalCargoEfetivo' as Conceito, 
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
'3.4.08-ecadHistCentroCustoVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistcentrocustovinculo c 
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
'3.4.09-ecadHistFinalCargoEfetivo' as Conceito, 
case when c.dtfinalizacao is not null and c.dtfinalizacao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
count(1) as Qtde 
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
count(1) as Qtde 
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
'3.5.03-ecadHistRecebimentoCCO' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
'3.5.04-ecadHistOpcaoRemuneracaoCCO' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistopcaoremuneracaocco c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.05-ecadHistSitPrevVinculo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
'3.5.06-ecadLocalTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
'3.5.07-ecadHistJornadaTrabalho' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
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
'3.5.08-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join ecadhistcargocom cco on cco.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.5-Vinculos Cargos Comissionados'  as Grupo, 
'3.5.09-ecadHistCentroCustoVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistcentrocustovinculo c 
inner join ecadhistcargocom cco on cco.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.5-Vinculos Cargos Comissionados' as Grupo, 
'3.5.10-ecadHistFinalCargoCom' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistfinalcargocom c 
inner join ecadhistcargocom cco on cco.cdhistcargocom = c.cdhistcargocom
inner join ecadvinculo v on v.cdvinculo = cco.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.6-Vinculos Recebidos a Disposicao' as Grupo, 
'3.6.01-emovServidorRecebido' as Conceito, 
case when c.dtfimdisposicao is not null and c.dtfimdisposicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from emovservidorrecebido c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.dtfimdisposicao is not null and c.dtfimdisposicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.7-Vinculos Cedidos a Disposicao' as Grupo, 
'3.7.01-emovDisposicaoServidor' as Conceito, 
case when c.dtfimdisposicao is not null and c.dtfimdisposicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from emovdisposicaoservidor c
inner join ecadhistcargoefetivo cef on cef.cdvinculo = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = cef.cdvinculo
group by
case when c.dtfimdisposicao is not null and c.dtfimdisposicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.8-Vinculos Bolsista e Estagiarios' as Grupo, 
'3.8.01-ecadHistEstagio' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistestagio c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculoestagio
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.8-Vinculos Bolsista e Estagiarios' as Grupo, 
'3.8.02-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join ecadhistestagio b on b.cdvinculoestagio = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = b.cdvinculoestagio
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.9-Vinculos Pensao Não Previdenciaria' as Grupo, 
'3.9.01-epvdHistPensaoNaoPrev' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epvdhistpensaonaoprev c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculobeneficiario
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.9-Vinculos Pensao Não Previdenciaria'  as Grupo, 
'3.9.02-epvdValorPensaoNaoPrev' as Conceito, 
case when c.nuanofimreferencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epvdvalorpensaonaoprev c 
inner join epvdhistpensaonaoprev pnp on pnp.cdhistpensaonaoprev = c.cdpensaonaoprevidenciaria
inner join ecadvinculo v on v.cdvinculo = pnp.cdvinculobeneficiario
group by
case when c.nuanofimreferencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.9-Vinculos Pensao Não Previdenciaria'  as Grupo, 
'3.9.03-epvdRepresentanteLegal' as Conceito, 
case when c.dtfinal is not null and c.dtfinal < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epvdrepresentantelegal c 
inner join epvdhistpensaonaoprev pnp on pnp.cdrepresentantelegal = c.cdrepresentantelegal
                                    and pnp.cdvinculobeneficiario = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = pnp.cdvinculobeneficiario
group by
case when c.dtfinal is not null and c.dtfinal < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'3.9-Vinculos Pensao Não Previdenciaria'  as Grupo, 
'3.9.04-ecadHistDadosBancariosVinculo' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from ecadhistdadosbancariosvinculo c 
inner join epvdhistpensaonaoprev pnp on pnp.cdvinculobeneficiario = c.cdvinculo
inner join ecadvinculo v on v.cdvinculo = pnp.cdvinculobeneficiario
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
-- Afastamentos
select
'5.1-Ferias' as Grupo, 
'5.1.01-emovPeriodoAquisitivoFerias' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from emovperiodoaquisitivoferias c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.1-Ferias' as Grupo, 
'5.1.02-emovFeriasFruicaoUsufruto' as Conceito, 
case when c.dtfinal is not null and c.dtfinal < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from emovferiasfruicaousufruto c 
inner join emovperiodoaquisitivoferias pa on pa.cdperiodoaquisitivoferias = c.cdperiodoaquisitivoferias
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when c.dtfinal is not null and c.dtfinal < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.1-Ferias' as Grupo, 
'5.1.03-emovFeriasFruicaoPagamento' as Conceito, 
'FINALIZADOS' as Vinculo,
count(1) as Qtde 
from emovferiasfruicaopagamento c 
inner join emovperiodoaquisitivoferias pa on pa.cdperiodoaquisitivoferias = c.cdperiodoaquisitivoferias
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
union
select
'5.2-Licenca Premio' as Grupo, 
'5.2.01-eafaPeriodoAquisitivoLP' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from eafaperiodoaquisitivolp c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.2-Licenca Premio' as Grupo, 
'5.2.02-eafaLicencaPremio' as Conceito, 
case when c.dtfimfruicao is not null and c.dtfimfruicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from eafalicencapremio c 
inner join eafaperiodoaquisitivolp pa on pa.cdperiodoaquisitivo = c.cdperiodoaquisitivo
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when c.dtfimfruicao is not null and c.dtfimfruicao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.3-Afastamento' as Grupo, 
'5.3.01-eafaAfastamentoVinculo' as Conceito, 
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from eafaafastamentovinculo c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.dtfim is not null and c.dtfim < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.4-Comunicado Acidente' as Grupo, 
'5.4.01-esauComunicadoAcidente' as Conceito, 
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from esaucomunicadoacidente c 
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'5.4-Comunicado Acidente' as Grupo,
'5.4.02-ecadEndereco' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(distinct e.cdendereco) as Qtde 
from ecadendereco e
inner join esaucomunicadoacidente c on c.cdendereco = e.cdendereco
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
-- Financeiro
select
'6.1-Isenção Tributária' as Grupo, 
'6.1.01-etrbIsencaoIRRF' as Conceito, 
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from etrbisencaoirrf c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.1-Isenção Tributária' as Grupo, 
'6.1.02-etrbHistIsencaoIRRF' as Conceito, 
case when c.nuanofimvigencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from etrbhistisencaoirrf c
inner join etrbisencaoirrf iserf on iserf.cdisencaoirrf = c.cdisencaoirrf
inner join ecadvinculo v on v.cdvinculo = iserf.cdvinculo
group by
case when c.nuanofimvigencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.1-Isenção Tributária' as Grupo, 
'6.1.03-etrbIsencaoRubrica' as Conceito, 
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from etrbisencaorubrica c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.1-Isenção Tributária' as Grupo, 
'6.1.04-etrbHistIsencaoRubrica' as Conceito, 
case when c.nuanofimvigencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from etrbhistisencaorubrica c
inner join etrbisencaorubrica iserub on iserub.cdisencaorubrica = c.cdisencaorubrica
inner join ecadvinculo v on v.cdvinculo = iserub.cdvinculo
group by
case when c.nuanofimvigencia is not null then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.2-Pensao Alimenticia' as Grupo, 
'6.2.01-epenSentencaJudicial' as Conceito, 
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epensentencajudicial c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.2-Pensao Alimenticia' as Grupo, 
'6.2.02-epenHistDadosBancarios' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epenhistdadosbancarios c
inner join epensentencajudicial pa on pa.cdsentencajudicial = c.cdsentencajudicial
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.2-Pensao Alimenticia' as Grupo, 
'6.2.03-epenHistSentencaJudicial' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epenhistsentencajudicial c
inner join epensentencajudicial pa on pa.cdsentencajudicial = c.cdsentencajudicial
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.2-Pensao Alimenticia' as Grupo, 
'6.2.04-epenBeneficiario' as Conceito, 
case when hpa.dtfimvigencia is not null and hpa.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epenbeneficiario c
inner join epenhistsentencajudicial hpa on hpa.cdhistsentencajudicial = c.cdhistsentencajudicial
inner join epensentencajudicial pa on pa.cdsentencajudicial = hpa.cdsentencajudicial
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when hpa.dtfimvigencia is not null and hpa.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.2-Pensao Alimenticia' as Grupo, 
'6.2.05-epenSentencaRubrica' as Conceito, 
case when hpa.dtfimvigencia is not null and hpa.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epensentencarubrica c
inner join epenhistsentencajudicial hpa on hpa.cdhistsentencajudicial = c.cdhistsentencajudicial
inner join epensentencajudicial pa on pa.cdsentencajudicial = hpa.cdsentencajudicial
inner join ecadvinculo v on v.cdvinculo = pa.cdvinculo
group by
case when hpa.dtfimvigencia is not null and hpa.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.3-Consignacoes' as Grupo, 
'6.3.01-epagConsignataria' as Conceito, 
'VIGENTES' as Vinculo,
count(1) as Qtde 
from epagconsignataria c
union
select
'6.3-Consignacoes' as Grupo, 
'6.3.02-epagContratoServico' as Conceito, 
case when c.dtfimcontrato is not null and c.dtfimcontrato < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagcontratoservico c
inner join epagconsignataria cta on cta.cdconsignataria = c.cdconsignataria
group by
case when c.dtfimcontrato is not null and c.dtfimcontrato < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.3-Consignacoes' as Grupo, 
'6.3.03-epagConsignacao' as Conceito, 
case when c.dtfimconcessao is not null and c.dtfimconcessao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagconsignacao c
group by
case when c.dtfimconcessao is not null and c.dtfimconcessao < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.3-Consignacoes' as Grupo, 
'6.3.04-epagHistConsignacao' as Conceito, 
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epaghistconsignacao c
inner join epagconsignacao csg on csg.cdconsignacao = c.cdconsignacao
group by
case when c.dtfimvigencia is not null and c.dtfimvigencia < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.3-Consignacoes'as Grupo, 
'6.3.05-epagBaseConsignacao' as Conceito, 
case when c.nuanoreferenciafinal is not null then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagbaseconsignacao c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.nuanoreferenciafinal is not null then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.4-Lancamento Financeiro' as Grupo, 
'6.4.01-epagLancamentoFinanceiro' as Conceito, 
case when c.dtfimdireito is not null and c.dtfimdireito < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epaglancamentofinanceiro c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when c.dtfimdireito is not null and c.dtfimdireito < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'6.4-Lancamento Financeiro' as Grupo, 
'6.4.02-epagPagamentoLancamento' as Conceito, 
case when fin.dtfimdireito is not null and fin.dtfimdireito < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagpagamentolancamento c
inner join epaglancamentofinanceiro fin on fin.cdlancamentofinanceiro = c.cdlancamentofinanceiro
inner join ecadvinculo v on v.cdvinculo = fin.cdvinculo
group by
case when fin.dtfimdireito is not null and fin.dtfimdireito < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
-- Pagamentos
select
'7.1-Folha Pagamento' as Grupo,
'7.1.01-epagFolhaPagamento' as Conceito,
case when flcalculodefinitivo = 'S' then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagfolhapagamento c
group by
case when flcalculodefinitivo = 'S' then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'7.2-Capa Pagamento'  as Grupo,
'7.2.01-epagCapaHistRubricaVinculo  Folhas' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(distinct c.cdfolhapagamento) as Qtde 
from epagcapahistrubricavinculo c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'7.2-Capa Pagamento'  as Grupo,
'7.2.02-epagCapaHistRubricaVinculo  Capas' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epagcapahistrubricavinculo c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'7.3-Detalhe Contracheque'  as Grupo,
'7.3.01-epagHistoricoRubricaVinculo Folhas' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(distinct c.cdfolhapagamento) as Qtde 
from epaghistoricorubricavinculo c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'7.3-Detalhe Contracheque'  as Grupo,
'7.3.02-epagHistoricoRubricaVinculo Capas' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(distinct c.cdfolhapagamento || c.cdvinculo) as Qtde 
from epaghistoricorubricavinculo c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end
union
select
'7.3-Detalhe Contracheque'  as Grupo,
'7.3.03-epagHistoricoRubricaVinculo Detalhes' as Conceito,
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
     else 'VIGENTES'
end as Vinculo,
count(1) as Qtde 
from epaghistoricorubricavinculo c
inner join ecadvinculo v on v.cdvinculo = c.cdvinculo
group by
case when v.dtdesligamento is not null and v.dtdesligamento < trunc(sysdate) then 'FINALIZADOS'
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
