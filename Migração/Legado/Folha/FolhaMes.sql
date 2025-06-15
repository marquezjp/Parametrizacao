select
--- Identificação do Vínculo
upper(trim(lot.Sigla)) as sgOrgao,
right('000000000' + trim(pag.CdNomeacao), 9) as nuMatriculaLegado,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
--- Identificação da Folha
substring(capa.Periodo,1,4) as nuAnoReferencia,
substring(capa.Periodo,5,2) as nuMesReferencia,
pag.AnoMesReferencia as nuAnoMesRefDiferenca,
case substring(fol.NmFolha,4,len(fol.NmFolha)-3)
 when 'FOLHA MENSAL' then 'NORMAL'
 when 'GRATIFICACAO NATALINA' then '13º SALARIO'
 when 'GRAT NATALINA ANIVERSARIO' then 'ADIANTAMENTO 13º'
 else substring(fol.NmFolha,4,len(fol.NmFolha)-3)
end nmTipoFolha,
'SIMULACAO' as nmTipoCalculo,
format(capa.cdfolha + 10, '00') as nuSequencialFolha,
--- Informações da Rubrica do Contracheque
case rub.TpEvento
 when 'P' then 'PROVENTOS NORMAL'
 when 'D' then 'DESCONTOS NORMAL'
 when 'B' then 'BASE'
 else rub.TpEvento
end nmTipoRubrica,
format(pag.CdEvento, '0000') as nuRubrica,
rub.nmEvento as nmRubrica,
null as nuSufixoRubrica,
pag.Valor as vlPagamento,
pag.Qtde as vlIndiceRubrica,
null as deTipoIndice,
lan.NumeroParcelas as qtParcelas,
lan.ParcelaAtual as nuParcela,
case
 when dep.CPFDependente is null then format(dep.CPFResponsavel, '000000000') + format(dep.DVResponsavel, '00') 
 else dep.CPFDependente
end as nuCPFBenfPensaoAlimenticia,
null as nuProcessoRetroativo,
null as qtMeses,
-- pag.CdDependente,
-- pag.CdCCusto,
-- pag.Observacao,
-- lan.Observacao as ObservacaoLancamento,
-- pag.Identificador,
-- pag.Sequencial,
-- lan.AnoMesUltimoCalculo,
-- lan.AnoMesNaoCalculado,
-- lan.cdMotivoCancelamento,
-- lan.idContrato,
-- lan.idImportacao,
-- lan.Origem,
-- lan.idImportacaoConsig,
-- lan.idLancamento,
-- lan.cdCCusto
format(nom.DtAdmissao, 'dd/MM/yyyy') as dtAdmissao
from TFolhaMes pag
left join TComplementoFolhaMes capa on capa.CdEmpresa = pag.CdEmpresa
                                   and capa.CdFolha = pag.CdFolha 
                                   and capa.Periodo = pag.Periodo
                                   and capa.CdNomeacao = pag.CdNomeacao
                                   and capa.CdDependente = pag.CdDependente 
left join TEventosFuncionario lan on lan.cdempresa = pag.cdempresa
                                 and capa.CdFolha = pag.CdFolha 
                                 and capa.CdNomeacao = pag.CdNomeacao
                                 and lan.Identificador = pag.Identificador 
left join TEventos rub on rub.CdEmpresa = pag.CdEmpresa
                      and rub.CdEvento = pag.CdEvento
left join TNomeacoes nom on nom.CdEmpresa = pag.CdEmpresa
                        and nom.CdNomeacao = pag.CdNomeacao 
left join TFuncionarios fun on fun.CdEmpresa = pag.CdEmpresa
                           and fun.CdFuncionario = nom.CdFuncionario 
left join TDependentes dep on dep.CdEmpresa = pag.CdEmpresa
                          and dep.CdFuncionario = fun.CdFuncionario
                          and dep.CdDependente = pag.CdDependente 
left join TFolhas fol on fol.CdEmpresa = pag.CdEmpresa
                     and fol.CdFolha = pag.CdFolha 
left join TLotacoes lot on lot.CdEmpresa = capa.CdEmpresa
                       and lot.CdLotacao  = capa.CdLotacao 
left join TCargos c on c.CdEmpresa = capa.CdEmpresa
                       and c.CdCargo  = capa.CdCargo 
left join TFuncoes f on f.CdEmpresa = capa.CdEmpresa
                    and f.CdFuncao = capa.CdFuncao 
where pag.Periodo = 202310
;