
--- Arquivo de Migracao Centro de Custo
with
centrocusto as (
select 'RH_GOV' as DB,
cc.CdCCusto, cc.NmCCusto, isnull(ccdb.Cnpj, ccab.CNPJ) as Cnpj, isnull(ccdb.Nome, ccab.NmEmpresa) as Nome, ccab.CdBancoArqBancario, ccab.CdAgenciaArqBancario,
isnull(ccdb.CCorrente, ccab.CdContaCorrenteArqBancario) as CCorrente,
case when ccdb.CCorrente is not null then ccdb.DgConta else ccab.DvContaCorrenteArqBancario end as DgConta,
isnull(ccdb.Convenio, ccab.CdConvenioArqBancario) as Convenio, 
ccdb.NmConta, ccab.NmContaArqBancario
from RH_GOV.dbo.TCCustos cc
left join RH_GOV.dbo.TCCustosDBancarios ccdb on ccdb.CdEmpresa = cc.CdEmpresa and ccdb.CdDadosBancarios = cc.CdDadosBancarios 
left join RH_GOV.dbo.TContaArqBancario ccab on ccab.cdConta = cc.CdDadosBancariosArq 
union all
select 'RH_PM' as DB,
cc.CdCCusto, cc.NmCCusto, null as Cnpj, null as Nome, null as CdBancoArqBancario, null as CdAgenciaArqBancario,
null as CCorrente, null as DgConta, null as Convenio, null as NmConta, null as NmContaArqBancario
from RH_PM.dbo.TCCustos cc
union all
select 'RH_BM' as DB,
cc.CdCCusto, cc.NmCCusto, null as Cnpj, null as Nome, null as CdBancoArqBancario, null as CdAgenciaArqBancario,
null as CCorrente, null as DgConta, null as Convenio, null as NmConta, null as NmContaArqBancario
from RH_BM.dbo.TCCustos cc
union all
select 'RH_CER' as DB,
cc.CdCCusto, cc.NmCCusto, isnull(ccdb.Cnpj, ccab.CNPJ) as Cnpj, isnull(ccdb.Nome, ccab.NmEmpresa) as Nome, ccab.CdBancoArqBancario, ccab.CdAgenciaArqBancario,
isnull(ccdb.CCorrente, ccab.CdContaCorrenteArqBancario) as CCorrente,
case when ccdb.CCorrente is not null then ccdb.DgConta else ccab.DvContaCorrenteArqBancario end as DgConta,
isnull(ccdb.Convenio, ccab.CdConvenioArqBancario) as Convenio, 
ccdb.NmConta, ccab.NmContaArqBancario
from RH_CER.dbo.TCCustos cc
left join RH_CER.dbo.TCCustosDBancarios ccdb on ccdb.CdEmpresa = cc.CdEmpresa and ccdb.CdDadosBancarios = cc.CdDadosBancarios 
left join RH_CER.dbo.TContaArqBancario ccab on ccab.cdConta = cc.CdDadosBancariosArq 
union all
select 'RH_ITE' as DB,
cc.CdCCusto, cc.NmCCusto, null as Cnpj, null as Nome, null as CdBancoArqBancario, null as CdAgenciaArqBancario,
null as CCorrente, null as DgConta, null as Convenio, null as NmConta, null as NmContaArqBancario
from RH_ITE.dbo.TCCustos cc
union all
select 'RH_RADIO' as DB,
cc.CdCCusto, cc.NmCCusto, isnull(ccdb.Cnpj, ccab.CNPJ) as Cnpj, isnull(ccdb.Nome, ccab.NmEmpresa) as Nome, ccab.CdBancoArqBancario, ccab.CdAgenciaArqBancario,
isnull(ccdb.CCorrente, ccab.CdContaCorrenteArqBancario) as CCorrente,
case when ccdb.CCorrente is not null then ccdb.DgConta else ccab.DvContaCorrenteArqBancario end as DgConta,
isnull(ccdb.Convenio, ccab.CdConvenioArqBancario) as Convenio, 
ccdb.NmConta, ccab.NmContaArqBancario
from RH_RADIO.dbo.TCCustos cc
left join RH_RADIO.dbo.TCCustosDBancarios ccdb on ccdb.CdEmpresa = cc.CdEmpresa and ccdb.CdDadosBancarios = cc.CdDadosBancarios 
left join RH_RADIO.dbo.TContaArqBancario ccab on ccab.cdConta = cc.CdDadosBancariosArq 
)
select
-- Identificacao do Centro de Custo
'PE' as sgPoder,
case DB
  when 'RH_GOV'   then 'ADM-DIR'
  when 'RH_PM'    then 'MILITAR'
  when 'RH_BM'    then 'MILITAR'
  when 'RH_CER'   then 'ADM-INDIR'
  when 'RH_ITE'   then 'ADM-INDIR'
  when 'RH_RADIO' then 'ADM-INDIR'
  else 'ADM-DIR'
end as sgAgrupamento,
null as sgOrgao,
trim(cc.CdCCusto) as sgCentroCusto,
upper(trim(cc.NmCCusto)) as nmCentroCusto,
left(replace(trim(cc.CdCCusto),'.', '') + '00000000',8) as nuCentroCusto, 
-- Informacoes Principais do Centro de Custo
cc.Cnpj as nuCNPJ,
cc.Nome as nmEmpresa,
right('000' + trim(cc.CdBancoArqBancario), 3) as nuBanco,
right('00000' + trim(cc.CdAgenciaArqBancario), 5) as nuAgencia,
cc.CCorrente as nuContaCorrente,
cc.DgConta as nuDvContaCorrente,
cc.Convenio as nuCovenioBancario,
cc.NmConta,
cc.NmContaArqBancario,
case when patindex('%FUNDEB%', cc.NmCCusto) = 0 then 'N' else 'S' end as flPertenceFUNDEB
from centrocusto cc
order by DB, cc.CdCCusto
;
