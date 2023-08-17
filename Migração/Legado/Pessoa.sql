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
) 
select
format(CdFuncionario, '000000000') + format(DVFuncionario, '00') as nuCPF,
upper(trim(nmFuncionario)) as nmPessoa,
format(DtNascimento, 'dd/MM/yyyy') as DtNascimento,
upper(trim(Sexo)) as FlSexo,
upper(trim(NmMae)) as NmMae,
upper(trim(NmPai)) as NmPai,
upper(trim(NmEstadoCivil)) as NmEstadoCivil,
upper(trim(NmRacaCor)) as NmRaca,
DB,
CdEmpresa,
CdFuncionario
from funcionarios pessoa
order by CdFuncionario
