--- Formata Layout do Arquivo de Migracao Pensao Alimenticia
with
depententes as (
select 'RH_GOV' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_GOV.dbo.TDependentes dep
left join RH_GOV.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_GOV.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
union all
select 'RH_PM' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_PM.dbo.TDependentes dep
left join RH_PM.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_PM.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
union all
select 'RH_BM' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_BM.dbo.TDependentes dep
left join RH_BM.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_BM.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
union all
select 'RH_CER' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_CER.dbo.TDependentes dep
left join RH_CER.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_CER.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
union all
select 'RH_ITE' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_ITE.dbo.TDependentes dep
left join RH_ITE.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_ITE.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
union all
select 'RH_RADIO' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.NmDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.PeriodoInicial, dep.PeriodoFinal, dep.CdEvento, dep.Valor, dep.Qtde, dep.CdBanco, dep.CdAgencia, dep.CdConta
from RH_RADIO.dbo.TDependentes dep
left join RH_RADIO.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_RADIO.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is not null
),
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
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 3 and gov.CdFuncionario is null
union all
select 'RH_PM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_PM.dbo.TFuncionarios fun
left join RH_PM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_PM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm3 on pm3.CdEmpresa = 3 and pm3.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 8 and gov.CdFuncionario is null and pm3.CdFuncionario is null
union all
select 'RH_PM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_PM.dbo.TFuncionarios fun
left join RH_PM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_PM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm3 on pm3.CdEmpresa = 3 and pm3.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm8 on pm8.CdEmpresa = 8 and pm8.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 0 and gov.CdFuncionario is null and pm3.CdFuncionario is null and pm8.CdFuncionario is null
union all
select 'RH_BM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_BM.dbo.TFuncionarios fun
left join RH_BM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_BM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 4 and gov.CdFuncionario is null and pm.CdFuncionario is null
union all
select 'RH_BM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_BM.dbo.TFuncionarios fun
left join RH_BM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_BM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm4 on bm4.CdEmpresa = 4 and bm4.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 10 and gov.CdFuncionario is null and pm.CdFuncionario is null and bm4.CdFuncionario is null 
union all
select 'RH_BM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_BM.dbo.TFuncionarios fun
left join RH_BM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_BM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm4 on bm4.CdEmpresa = 4 and bm4.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm10 on bm10.CdEmpresa = 10 and bm10.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 9 and gov.CdFuncionario is null and pm.CdFuncionario is null and bm4.CdFuncionario is null and bm10.CdFuncionario is null
union all
select 'RH_BM' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_BM.dbo.TFuncionarios fun
left join RH_BM.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_BM.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm4 on bm4.CdEmpresa = 4 and bm4.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm10 on bm10.CdEmpresa = 10 and bm10.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm9 on bm9.CdEmpresa = 9 and bm9.CdFuncionario = fun.CdFuncionario
where fun.CdEmpresa = 11 and gov.CdFuncionario is null and pm.CdFuncionario is null and bm4.CdFuncionario is null and bm10.CdFuncionario is null and bm9.CdFuncionario is null
union all
select 'RH_CER' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_CER.dbo.TFuncionarios fun
left join RH_CER.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_CER.dbo.TRacasCores raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm on bm.CdFuncionario = fun.CdFuncionario
where gov.CdFuncionario is null and pm.CdFuncionario is null and bm.CdFuncionario is null
union all
select 'RH_ITE' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_ITE.dbo.TFuncionarios fun
left join RH_ITE.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_ITE.dbo.TRacaCor raca on raca.CdRacaCor = fun.CdRacaCor 
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm on bm.CdFuncionario = fun.CdFuncionario
left join RH_CER.dbo.TFuncionarios cer on cer.CdFuncionario = fun.CdFuncionario
where gov.CdFuncionario is null and pm.CdFuncionario is null and bm.CdFuncionario is null and cer.CdFuncionario is null
union all
select 'RH_RADIO' as DB, fun.CdEmpresa, fun.CdFuncionario, fun.DVFuncionario, fun.nmFuncionario, fun.DtNascimento, fun.Sexo, fun.NmMae, fun.NmPai, ec.NmEstadoCivil, raca.NmRacaCor
from RH_RADIO.dbo.TFuncionarios fun
left join RH_RADIO.dbo.TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil
left join RH_RADIO.dbo.TRacasCores raca on raca.CdRacaCor = fun.CdRacaCor
left join RH_GOV.dbo.TFuncionarios gov on gov.CdFuncionario = fun.CdFuncionario
left join RH_PM.dbo.TFuncionarios pm on pm.CdFuncionario = fun.CdFuncionario
left join RH_BM.dbo.TFuncionarios bm on bm.CdFuncionario = fun.CdFuncionario
left join RH_CER.dbo.TFuncionarios cer on cer.CdFuncionario = fun.CdFuncionario
left join RH_ITE.dbo.TFuncionarios ite on ite.CdFuncionario = fun.CdFuncionario
where gov.CdFuncionario is null and pm.CdFuncionario is null and bm.CdFuncionario is null and cer.CdFuncionario is null and ite.CdFuncionario is null
),
pessoa as (
select DB,
format(CdFuncionario, '000000000') + format(DVFuncionario, '00') as nuCPF,
upper(trim(nmFuncionario)) as nmPessoa,
format(DtNascimento, 'dd/MM/yyyy') as dtNascimento,
upper(trim(Sexo)) as flSexo,
upper(trim(NmMae)) as nmMae,
upper(trim(NmPai)) as nmPai,
upper(trim(NmEstadoCivil)) as nmEstadoCivil,
upper(trim(NmRacaCor)) as nmRaca,
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
),
vinculos as (
select p.nuCPF, upper(trim(v.Sigla)) as sgOrgao, right('000000000' + trim(v.CdNomeacao), 9) as nuMatriculaLegado, p.nmPessoa,
format(v.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(v.DtDemissao, 'dd/MM/yyyy') as dtDesligamento,
format(v.DtAdmissao, 'yyyyMM') as dtInicio,
case
  when v.DtDemissao is null then '999999'
  else format(v.DtDemissao, 'yyyyMM')
end as dtFim
from nomeacoes v
left join pessoa p on p.DB = v.DB and p.cdEmpresa = v.CdEmpresa and p.cdFuncionario = v.CdFuncionario 
)
--- Formata Layout do Arquivo de Migracao Pensao Alimenticia
select
-- Chave do Ssitema Legado
dep.DB,
dep.nuCPFFuncionario,
dep.nuDependente,
-- Identificacao Servidor
v.sgOrgao,
v.nuMatriculaLegado,
v.nuCPF,
-- Dados do Beneficiario da Pensao Alimenticia
case
  when right('00000000000' + trim(dep.CpfDependente), 12) = format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
       then format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
  when dep.CpfDependente is not null
       then right('00000000000' + trim(dep.CpfDependente), 12)
  else format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
end as nuCpfBeneficiario,
case
  when right('00000000000' + trim(dep.CpfDependente), 12) = format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
       then upper(trim(dep.NmResponsavel))
  when dep.CpfDependente is not null
       then upper(trim(dep.NmDependente))
  else upper(trim(dep.NmResponsavel)) 
end as nmBeneficiario,
format(dep.DtNascimento, 'dd/MM/yyyy') as dtNascimentoBeneficiario,
upper(trim(dep.Sexo)) as flSexoBeneficiario,
case dep.NmGrauParentesco
  when 'CONJUGUE' then 'ESPOSO/ESPOSA'
  when 'FILHO(A)' then 'FILHO/FILHA'
  when 'MÃE / PAI' then 'ASCENDENTE - PAI/MAE'
  when 'IRMAO / IRMA' then 'IRMAO/IRMA' 
  when 'Outros' then 'AGREGADOS/OUTROS'
  when 'OUTRO' then 'AGREGADOS/OUTROS'
  else 'AGREGADOS/OUTROS'
end as nmGrauParentescoBeneficiario,
-- Representante Legal
case
  when right('00000000000' + trim(dep.CpfDependente), 12) = format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
       then null
  when dep.CpfDependente is null
       then null
  else format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
end as nuCpfRepresentante,
case
  when right('00000000000' + trim(dep.CpfDependente), 12) = format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
       then null
  when dep.CpfDependente is null
       then null
  else upper(trim(dep.NmResponsavel))
end as nmRepresentante,
null as dtNascimentoRepresentante,
null as flSexoRepresentante,
null as nmMaeRepresentante,
null as nmPaisRepresentante,
null as nmEstadoCivilRepresentante,
null as nmRacaRepresentante,
-- Informacoes da Sentença Judicial de Pensao Alimenticia
case
  when dep.PeriodoInicial < v.dtInicio then format(try_convert(date, v.dtInicio + '01'), 'dd/MM/yyyy')
  else format(try_convert(date, dep.PeriodoInicial + '01'), 'dd/MM/yyyy')
end as dtInicioVigencia,
case
  when v.dtFim = '999999' and dep.PeriodoFinal = '999999' then null
  when dep.PeriodoFinal > v.dtFim then format(eomonth(try_convert(date, v.dtFim + '01')), 'dd/MM/yyyy')
  else format(eomonth(try_convert(date, dep.PeriodoFinal + '01')), 'dd/MM/yyyy')
end as dtFimVigencia,
null as nuAcaoJudicial,
null as nuAcordoJudicial,
case
  when dep.Valor = 0 or dep.Valor is null then 'PENSAO ALIMENTICIA DE VALOR FIXO'
  else 'PENSAO ALIMENTICIA POR PERCENTUAL'
end as nmTipoPensaoAlimenticia,
'S' as flPagamento13,
'S' as flPagamentoAdiant13,
format(dep.CdEvento, '0000') as NuRubrica,
case when dep.Valor = 0 then null else dep.Valor end as vlFixo,
case when dep.Qtde = 0 then null else dep.Qtde end as nuPercentual,
-- Documento de Amparo ao Fato da Pensao Alimenticia
null as nuAnoDocumento,
null as nmTipoPublicacao,
null as nuPublicacao,
null as dtPublicacao,
null as nuPagInicial,
null as nmMeioPublicacao,
-- Dados Bancarios
right('0000' + trim(dep.CdBanco), 4) as NuBancoCredito,
right('00000' + trim(dep.CdAgencia), 5) as NuAgenciaCredito,
left(right('000000000' + trim(dep.CdConta), 13), 12) as NuContaCredito,
right(trim(dep.CdConta), 1) as NuDvContaCredito,
'1' as flTipoContaCredito
from depententes dep
inner join vinculos v on v.nuCPF = dep.nuCPFFuncionario
where dep.PeriodoFinal >= v.dtInicio
  and dep.PeriodoInicial <= v.dtFim
order by dep.nuCPFFuncionario, dep.nuDependente, v.sgOrgao, v.nuMatriculaLegado
;
/
