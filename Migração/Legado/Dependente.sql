--- Arquivo de Migracao Depententes
with
depententes as (
select 'RH_GOV' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_GOV.dbo.TDependentes dep
left join RH_GOV.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_GOV.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
union all
select 'RH_PM' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_PM.dbo.TDependentes dep
left join RH_PM.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_PM.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
union all
select 'RH_BM' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_BM.dbo.TDependentes dep
left join RH_BM.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_BM.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
union all
select 'RH_CER' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_CER.dbo.TDependentes dep
left join RH_CER.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_CER.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
union all
select 'RH_ITE' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_ITE.dbo.TDependentes dep
left join RH_ITE.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_ITE.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
union all
select 'RH_RADIO' as DB,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
format(dep.CdDependente, '00') as nuDependente,
dep.CpfDependente, dep.CpfResponsavel, dep.DVResponsavel, dep.NmResponsavel, dep.NmDependente, dep.DtNascimento, dep.Sexo, gp.NmGrauParentesco, dep.Deficiente
from RH_RADIO.dbo.TDependentes dep
left join RH_RADIO.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
inner join RH_RADIO.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
where dep.CdEvento is null
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
select 'RH_GOV' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_GOV.dbo.TNomeacoes nom
left join RH_GOV.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_GOV.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_GOV.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_PM' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_PM.dbo.TNomeacoes nom
left join RH_PM.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_PM.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_PM.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao 
union all
select 'RH_BM' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_BM.dbo.TNomeacoes nom
left join RH_BM.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_BM.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_BM.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao
union all
select 'RH_CER' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_CER.dbo.TNomeacoes nom
left join RH_CER.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_CER.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_CER.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao
union all
select 'RH_ITE' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_ITE.dbo.TNomeacoes nom
left join RH_ITE.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_ITE.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_ITE.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao
union all
select 'RH_RADIO' as DB, lot.Sigla, nom.CdEmpresa, nom.CdNomeacao, nom.CdFuncionario, format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao, format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao, c.TpCargo, c.NmCargo, f.NmFuncao, nom.CdNivel
from RH_RADIO.dbo.TNomeacoes nom
left join RH_RADIO.dbo.TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa and lot.CdLotacao  = nom.CdLotacao 
left join RH_RADIO.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
left join RH_RADIO.dbo.TFuncoes f on f.CdEmpresa = nom.CdEmpresa and f.CdFuncao = nom.CdFuncao
),
vinculos as (
select p.nuCPF, upper(trim(v.Sigla)) as sgOrgao, right('000000000' + trim(v.CdNomeacao), 9) as nuMatriculaLegado, p.nmPessoa
from nomeacoes v
left join pessoa p on p.DB = v.DB and p.cdEmpresa = v.CdEmpresa and p.cdFuncionario = v.CdFuncionario 
)
--- Formata Layout do Arquivo de Migracao Depententes
select --count(1)
--/*
-- Chave do Ssitema Legado
dep.DB,
dep.nuCPFFuncionario,
dep.nuDependente,
-- Identificacao do Dependente
right('00000000000' + trim(dep.CpfDependente), 12) as nuCpf,
-- Responsavel
case
  when dep.CpfResponsavel is null then v.nuCPF
  else format(dep.CpfResponsavel, '000000000') + format(dep.DVResponsavel, '00')
end as nuCpfResponsavel,
case
  when dep.CpfResponsavel is null then v.nmPessoa
  else upper(trim(dep.NmResponsavel))
end as nmPessoaResponsavel,
null as nuCpfResponsavel_2,
null as nmPessoaResponsavel_2,
-- Informacoes Principais
upper(trim(dep.NmDependente)) as nmDependente,
format(dep.DtNascimento, 'dd/MM/yyyy') as dtNascimento,
'NAO INFORMADO' as nmMae,
null as nmPai,
'NAO INFORMADO' as nmEstadoCivil,
'NAO INFORMADO' as nmPais,
null as sgEstado,
null as nmLocalidadeNasc,
upper(trim(dep.Sexo)) as flSexo,
'NAO INFORMADO' as nmRaca,
null as nmTipoSanguineo,
null as nmFatorRH,
null as dtNaturalizado,
upper(trim(dep.NmGrauParentesco)) as deGrauParentescoPrevFin,
-- Comprovante da Dependencia
null as nmTipoDocumentoDependente,
null as nmCartorio,
null as nuRegistro,
null as nuLivro,
null as nuFolha,
-- Documento de Carteira de Identidade
null as nuCarteiraIdentidade,
null as nmOrgaoEmissor,
null as sgEstadoCI,
null as dtExpedicao,
-- Emancipacao
null as flEmancipado,
null as dtEmancipacao,
null as deMotivoEmancipacao,
-- Dados de Imigracao
null as nmPaisOrigem,
null as dtEntradaPais,
null as dtLimitePerm,
-- Tipo de Dependencia
v.sgOrgao,
v.nuMatriculaLegado,
null as dtInicioBeneficioIRRF,
null as dtInicioPensaoPrev,
null as dtInicioPlanoSaude,
upper(trim(dep.Deficiente)) as flInvalidez,
null as flInvalidoPrevidenciario,
null as flInvalidoSalarioFamilia,
null as flInvalidoPlanoSaude,
null as nuIdadeMental
-- Relaciona Dependentes da Pessoa com Todos os Vinculos da Pessoa
--*/
from depententes dep
inner join vinculos v on v.nuCPF = dep.nuCPFFuncionario
order by dep.nuCPFFuncionario, dep.nuDependente, v.sgOrgao, v.nuMatriculaLegado
;
/
