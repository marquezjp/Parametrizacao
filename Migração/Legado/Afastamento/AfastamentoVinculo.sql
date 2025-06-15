select
--- Identificação do Vínculo
--a.CdEmpresa , a.CdNomeacao ,
upper(trim(lot.Sigla)) as sgOrgao,
right('000000000' + trim(a.CdNomeacao), 9) as nuMatriculaLegado,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
format(a.DtInicial, 'yyyyMMdd') as DtAfastamento,
format(a.DtInicial, 'dd/MM/yyyy') as DtInicial,
format(a.DtFinal, 'dd/MM/yyyy') as DtFinal,
--a.CdSituacao ,
tp.NmSituacao,
tp.FolhaIntegral ,
tp.TpSituacao ,
format(a.DtPeriodoAqInicial, 'dd/MM/yyyy') as DtPeriodoAqInicial,
format(a.DtPeriodoAqFinal, 'dd/MM/yyyy') as DtPeriodoAqFinal,
format(a.DtPublicacao, 'dd/MM/yyyy') as DtPublicacao,
a.CdProcesso ,
a.CdPortaria ,
a.Observacao 
from TSituacoesFuncionario a 
inner join TNomeacoes nom on nom.cdEmpresa = a.cdEmpresa
                        and nom.cdNomeacao = a.cdNomeacao 
left join TFuncionarios fun on fun.cdEmpresa = nom.cdEmpresa
                           and fun.cdFuncionario = nom.cdFuncionario 
left join TLotacoes lot on lot.cdEmpresa = nom.cdEmpresa
                       and lot.cdLotacao  = nom.cdLotacao 
left join TSituacoes tp on tp.CdEmpresa = a.CdEmpresa and tp.CdSituacao = a.CdSituacao
where a.cdNomeacao is not null
  and tp.CdSituacao in (
14, 12, 17, 15, 18, 49, 41, 47, 48, 31, 16, 32, 53, 19 ,34, 38, 33, 39, -- Licença
--40, -- Ferias
52, 51, 29, 28, 27, -- Aposentadoria
43, 45, 7, 6, 1, 2, 8, 25 -- Desligamento
--44 -- Movimentação
)
union all
select
--- Identificação do Vínculo
--a.CdEmpresa , a.CdNomeacao ,
upper(trim(lot.Sigla)) as sgOrgao,
right('000000000' + trim(a.CdNomeacao), 9) as nuMatriculaLegado,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
format(a.DtFinal, 'yyyyMMdd') as DtAfastamento,
format(a.DtFinal, 'dd/MM/yyyy') as DtInicial,
null as DtFinal,
--a.CdSituacao1 ,
tp.NmSituacao,
tp.FolhaIntegral ,
tp.TpSituacao ,
format(a.DtPeriodoAqInicial, 'dd/MM/yyyy') as DtPeriodoAqInicial,
format(a.DtPeriodoAqFinal, 'dd/MM/yyyy') as DtPeriodoAqFinal,
format(a.DtPublicacao, 'dd/MM/yyyy') as DtPublicacao,
a.CdProcesso ,
a.CdPortaria ,
a.Observacao 
from TSituacoesFuncionario a 
inner join TNomeacoes nom on nom.cdEmpresa = a.cdEmpresa
                        and nom.cdNomeacao = a.cdNomeacao 
left join TFuncionarios fun on fun.cdEmpresa = nom.cdEmpresa
                           and fun.cdFuncionario = nom.cdFuncionario 
left join TLotacoes lot on lot.cdEmpresa = nom.cdEmpresa
                       and lot.cdLotacao  = nom.cdLotacao 
left join TSituacoes tp on tp.CdEmpresa = a.CdEmpresa and tp.CdSituacao = a.CdSituacao1 
where a.cdNomeacao is not null and a.CdSituacao1 is not null
  and tp.CdSituacao in (
14, 12, 17, 15, 18, 49, 41, 47, 48, 31, 16, 32, 53, 19 ,34, 38, 33, 39, -- Licença
--40, -- Ferias
52, 51, 29, 28, 27, -- Aposentadoria
43, 45, 7, 6, 1, 2, 8, 25 -- Desligamento
--44 -- Movimentação
)
order by 3, 2, 1, 4 desc, 7
;

