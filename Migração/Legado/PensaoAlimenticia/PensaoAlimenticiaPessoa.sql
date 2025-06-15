--- Formata Layout do Arquivo de Migracao Pensao Alimenticia
select
-- Chave do Sitema Legado
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPFFuncionario,
upper(trim(nmFuncionario)) as nmPessoa,
format(dep.CdDependente, '00') as nuDependente,
-- Identificacao Servidor
null as sgOrgao,
null as nuMatriculaLegado,
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
case gp.NmGrauParentesco
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
format(try_convert(date, dep.PeriodoInicial + '01'), 'dd/MM/yyyy') as dtInicioVigencia,
format(eomonth(try_convert(date, dep.PeriodoFinal + '01')), 'dd/MM/yyyy') as dtFimVigencia,
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
'1' as flTipoContaCredito,
dep.CdNomeacoes as deNomeacoes
from RH_GOV.dbo.TDependentes dep
inner join RH_GOV.dbo.TFuncionarios fun on fun.CdEmpresa = dep.CdEmpresa and dep.CdFuncionario = fun.CdFuncionario
left join RH_GOV.dbo.TGrauParentesco gp on gp.CdGrauParentesco = dep.CdGrauParentesco
where dep.CdEvento is not null
order by dep.CdFuncionario, dep.CdDependente
;
/
