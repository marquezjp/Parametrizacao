select
--lan.CdNomeacao,
upper(trim(lot.Sigla)) as sgOrgao,
right('000000000' + trim(nom.CdNomeacao), 9) as nuMatriculaLegado,
format(nom.DtAdmissao, 'dd/MM/yyyy') as dtAdmissao,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
trim(fun.nmFuncionario) as nmPessoa,
format(fun.DtNascimento, 'dd/MM/yyyy') as DtNascimento,
rub.TpEvento as nmTipoRubrica,
format(lan.CdEvento, '0000') as nuRubrica,
rub.nmEvento,
null as nuSufixoRubrica,
lan.PeriodoInicial as nuAnoMesVigenciaInicial,
lan.PeriodoFinal1 as nuAnoMesVigenciaFinal,
lan.ParcelaAtual as nuParcela,
lan.NumeroParcelas as qtParcelas,
lan.Quantidade as vlIndiceRubrica,
lan.Valor as vlPagamento,
lan.AnoMesReferencia as nuAnoMesRefDiferenca,
lan.AnoMesUltimoCalculo,
lan.AnoMesNaoCalculado,
lan.cdFolha,
--lan.cdMotivoCancelamento,
replace(replace(lan.Observacao, char(13), ' '), char(10), ' ') as Observacao,
lan.dtInclusao,
lan.idContrato,
lan.IdImportacao,
lan.Origem,
lan.idImportacaoConsig,
lan.idLancamento,
--lan.cdCCusto,
lan.Identificador
from TEventosFuncionario lan
left join TEventos rub on rub.CdEmpresa = lan.CdEmpresa
                      and rub.CdEvento = lan.CdEvento
left join TNomeacoes nom on nom.CdEmpresa = lan.CdEmpresa
                        and nom.CdNomeacao = lan.CdNomeacao 
left join TFuncionarios fun on fun.CdEmpresa = nom.CdEmpresa
                           and fun.CdFuncionario = nom.CdFuncionario 
left join TLotacoes lot on lot.CdEmpresa = nom.CdEmpresa
                       and lot.CdLotacao  = nom.CdLotacao 
where periodoinicial >= 20310 and (periodofinal1 is null or periodofinal1 >=202310)
  and nom.CdEmpresa is not null
  and lan.CdMotivoCancelamento is null
  and lan.DtInclusao >= convert(datetime, '25/09/2023', 103)
;