with
funcionarios as (
select 'RH_GOV' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_GOV.dbo.TFuncionarios fun
left join RH_GOV.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_GOV.dbo.TRacasCores raca on raca.CdRacaCor = fun.CdRacaCor 
union all
select 'RH_PM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_PM.dbo.TFuncionarios fun
left join RH_PM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_PM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
union all
select 'RH_BM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_BM.dbo.TFuncionarios fun
left join RH_BM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_BM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
union all
select 'RH_CER' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_CER.dbo.TFuncionarios fun
left join RH_CER.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_CER.dbo.TRacasCores raca on raca.CdRacaCor = fun.CdRacaCor 
union all
select 'RH_ITE' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_ITE.dbo.TFuncionarios fun
left join RH_ITE.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_ITE.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
union all
select 'RH_RADIO' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_RADIO.dbo.TFuncionarios fun
left join RH_RADIO.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_RADIO.dbo.TRacasCores raca on raca.CdRacaCor = fun.CdRacaCor
),
pessoa as (
select DB,
format(CdFuncionario, '000000000') + format(DVFuncionario, '00') as nuCPF,
upper(trim(nmFuncionario)) as nmPessoa,
format(DtNascimento, 'dd/MM/yyyy') as DtNascimento,
upper(trim(Sexo)) as FlSexo,
upper(trim(NmMae)) as NmMae,
upper(trim(NmPai)) as NmPai,
upper(trim(NmEstadoCivil)) as NmEstadoCivil,
upper(trim(NmRacaCor)) as NmRaca,
CdEmpresa,
CdFuncionario
from funcionarios pessoa
),
nomeacoes as (
select 'RH_GOV' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_GOV.dbo.TNomeacoes nom
left join RH_GOV.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_GOV.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_GOV.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_PM' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_PM.dbo.TNomeacoes nom
left join RH_PM.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_PM.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_PM.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_BM' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_BM.dbo.TNomeacoes nom
left join RH_BM.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_BM.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_BM.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_CER' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_CER.dbo.TNomeacoes nom
left join RH_CER.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_CER.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_CER.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao
union all
select 'RH_ITE' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_ITE.dbo.TNomeacoes nom
left join RH_ITE.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_ITE.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_ITE.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_RADIO' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, nom.DtAdmissao, nom.DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_RADIO.dbo.TNomeacoes nom
left join RH_RADIO.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_RADIO.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_RADIO.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
)
select v.DB,
p.nuCPF,
upper(trim(v.Sigla)) as SgOrgao,
right('000000000' + trim(v.CdNomeacao), 9) as NuMatriculaLegado,
format(v.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao,
p.nmPessoa, p.DtNascimento, p.FlSexo, p.NmMae, p.NmPai, p.NmEstadoCivil, p.NmRaca,
format(v.DtDemissao, 'dd/MM/yyyy') as DtDesligamento,
case upper(trim(v.TpCargo))
 when 'E' then 'EFETIVO'
 when 'T' then 'CONTRATO TEMPORARIO'
 when 'C' then 'COMISSIONADO'
 when 'I' then 'INATIVO'
 else upper(trim(v.TpCargo))
end as NmRelacaoTrabalho,
upper(trim(v.NmCargo)) as DeCarreira,
upper(trim(v.NmFuncao)) as DeCargo,
trim(v.CdNivel) as NuNivel
from nomeacoes v
left join pessoa p on p.DB = v.DB and p.cdEmpresa = v.CdEmpresa and p.cdFuncionario = v.CdFuncionario 
