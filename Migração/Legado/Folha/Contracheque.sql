with
OrgaoDePara as (
select * from openjson ('[
{"de":"CASACIVIL",  "para":"CASA CIVIL"},
{"de":"CERIM",      "para":"CASA CIVIL"},
{"de":"CSAMILITAR", "para":"CASA MILITAR"},
{"de":"BM",         "para":"CBM-RR"},
{"de":"COGERR",     "para":"COGER"},
{"de":"DEFPUB",     "para":"DPE-RR"},
{"de":"IDEFER",     "para":"IDEFER-RR"},
{"de":"IPEM",       "para":"IPEM-RR"},
{"de":"CONJUCERR",  "para":"JUCERR"},
{"de":"OGERR",      "para":"OGE-RR"},
{"de":"POLCIVIL",   "para":"PC-RR"},
{"de":"PROGE",      "para":"PGE-RR"},
{"de":"PM",         "para":"PM-RR"},
{"de":"CONCULT",    "para":"SECULT"},
{"de":"CONEDUC",    "para":"SEED"},
{"de":"PRODEB",     "para":"SEED"},
{"de":"CONREFIS",   "para":"SEFAZ"},
{"de":"PENSIONIST", "para":"SEGAD"},
{"de":"CONRODE",    "para":"SEINF"},
{"de":"CONANTD",    "para":"SEJUC"},
{"de":"CONPEN",     "para":"SEJUC"},
{"de":"SEEPE",      "para":"SEPE"},
{"de":"PLANTONIST", "para":"SESAU"},
{"de":"SEURB",      "para":"SEURB-RR"},
{"de":"UNIVIR",     "para":"UNIVIRR"},
{"de":"VICE GOV",   "para":"VICE-GOV"}
]') with (de varchar(20) '$.de', para varchar(20) '$.para')
)
select
--- Identificação do Vínculo
upper(trim(isnull(odepara.para,lot.Sigla))) as sgOrgao,
right('000000000' + trim(pag.CdNomeacao), 9) as nuMatriculaLegado,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
--- Identificação da Folha
substring(capa.Periodo,1,4) as nuAnoReferencia,
substring(capa.Periodo,5,2) as nuMesReferencia,
pag.AnoMesReferencia as nuAnoMesRefDiferenca,
case capa.cdfolha
 when 1 then 'NORMAL'
 when 2	then 'NORMAL'
 when 3	then 'NORMAL'
 when 4	then 'NORMAL'
 when 5	then 'NORMAL'
 when 7	then 'ADIANTAMENTO 13º'
 when 8	then '13º SALARIO'
 when 9	then 'ADIANTAMENTO 13º'
 when 11 then 'NORMAL'
 when 12 then 'NORMAL'
 when 13 then 'NORMAL'
 when 14 then 'NORMAL'
 when 15 then 'NORMAL'
 when 16 then 'NORMAL'
 when 17 then 'ADIANTAMENTO 13º'
 when 18 then 'NORMAL'
 when 19 then 'NORMAL'
 when 20 then 'NORMAL'
end as nmTipoFolha,
case capa.cdfolha
 when 1 then 'SUPLEMENTAR'
 when 2	then 'SUPLEMENTAR'
 when 3	then 'NORMAL'
 when 4	then 'SUPLEMENTAR'
 when 5	then 'SUPLEMENTAR'
 when 7	then 'NORMAL'
 when 8	then 'NORMAL'
 when 9	then 'SUPLEMENTAR'
 when 11 then 'SUPLEMENTAR'
 when 12 then 'SUPLEMENTAR'
 when 13 then 'SUPLEMENTAR'
 when 14 then 'SUPLEMENTAR'
 when 15 then 'SUPLEMENTAR'
 when 16 then 'SUPLEMENTAR'
 when 17 then 'SUPLEMENTAR'
 when 18 then 'SUPLEMENTAR'
 when 19 then 'SUPLEMENTAR'
 when 20 then 'SUPLEMENTAR'
end as nmTipoCalculo,
case
 when capa.cdfolha in (1, 2) then format(capa.cdfolha + 20, '00')
 else format(capa.cdfolha, '00')
end as nuSequencialFolha,
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
from TFFinanceira pag
left join TComplementoFFinanceira capa on capa.CdEmpresa = pag.CdEmpresa
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
left join OrgaoDePara odepara on odepara.de = upper(trim(lot.Sigla))
left join TCargos c on c.CdEmpresa = capa.CdEmpresa
                       and c.CdCargo  = capa.CdCargo 
left join TFuncoes f on f.CdEmpresa = capa.CdEmpresa
                    and f.CdFuncao = capa.CdFuncao 
where pag.Periodo = 202309
;