with
capa as (
select 'RH_GOV' as DB, capa.Periodo, capa.CdFolha, capa.CdLotacao, capa.CdNomeacao, nom.CdFuncionario,
isnull(capa.DtAdmissao,nom.DtAdmissao) as DtAdmissao,
isnull(capa.DtDemissao,nom.DtDemissao) as DtDemissao,
c.TpCargo,
case when c.TpCargo = 'C' then capa.CdCargo else nom.CdCargo end as CdCargo,
case when c.TpCargo = 'C' then capa.CdFuncao else nom.CdFuncao end as CdFuncao,
capa.CdNivel,
capa.CdEmpresa
from RH_GOV.dbo.TComplementoFFinanceira capa 
left join RH_GOV.dbo.TNomeacoes nom on nom.CdEmpresa = capa.CdEmpresa and nom.CdNomeacao  = capa.CdNomeacao 
left join RH_GOV.dbo.TCargos c on c.CdEmpresa = nom.CdEmpresa and c.CdCargo  = nom.CdCargo 
where capa.CdDependente = 0
  and capa.Periodo > '202200'
),
capaformatada as (
select
right('000000000' + trim(capa.CdNomeacao), 9) as NuMatriculaLegado,
format(capa.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao,
case upper(trim(capa.TpCargo))
 when 'E' then 'EFETIVO'
 when 'T' then 'CONTRATO TEMPORARIO'
 when 'C' then 'COMISSIONADO'
 when 'I' then 'INATIVO'
 else upper(trim(capa.TpCargo))
end as NmRelacaoTrabalho,
upper(trim(c.NmCargo)) as DeCarreira,
upper(trim(f.NmFuncao)) as DeCargo,
capa.Periodo as NuAnoMes
from capa
left join RH_GOV.dbo.TFolhas fol on fol.CdEmpresa = capa.CdEmpresa and fol.CdFolha = capa.CdFolha 
left join RH_GOV.dbo.TLotacoes lot on lot.CdEmpresa = capa.CdEmpresa and lot.CdLotacao  = capa.CdLotacao 
left join RH_GOV.dbo.TCargos c on c.CdEmpresa = capa.CdEmpresa and c.CdCargo  = capa.CdCargo 
left join RH_GOV.dbo.TFuncoes f on f.CdEmpresa = capa.CdEmpresa and f.CdFuncao = capa.CdFuncao 
),
resumocargo as (
select
NuMatriculaLegado,
DtAdmissao,
NmRelacaoTrabalho,
DeCarreira,
DeCargo,
min(NuAnoMes) as NuAnoMesInicio,
max(NuAnoMes) as NuAnoMesFim 
from capaformatada
group by NuMatriculaLegado, DtAdmissao, NmRelacaoTrabalho, DeCarreira, DeCargo
),
dup as (
select NuMatriculaLegado, DtAdmissao
from resumocargo
group by NuMatriculaLegado, DtAdmissao
having count(1) > 1
)
select
res.NuMatriculaLegado,
res.DtAdmissao,
res.NmRelacaoTrabalho,
res.DeCarreira,
res.DeCargo,
res.NuAnoMesInicio,
res.NuAnoMesFim 
from resumocargo res
inner join dup on dup.NuMatriculaLegado = res.NuMatriculaLegado and dup.DtAdmissao = res.DtAdmissao 
order by res.NuMatriculaLegado, res.DtAdmissao