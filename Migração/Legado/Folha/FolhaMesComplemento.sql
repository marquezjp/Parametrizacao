select --count(1) -- 242933
--- Identificação do Vínculo
upper(trim(lot.Sigla)) as sgOrgao,
right('000000000' + trim(capa.CdNomeacao), 9) as nuMatriculaLegado,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
case when upper(trim(c.TpCargo)) = 'E' and upper(trim(nom.Opcao13Salario)) = 'S' then 'S' else 'N' end as flOpcao13Salario,
--- Identificação da Folha
substring(capa.Periodo,1,4) as nuAnoReferencia,
substring(capa.Periodo,5,2) as nuMesReferencia,
case substring(fol.NmFolha,4,len(fol.NmFolha)-3)
 when 'FOLHA MENSAL' then 'NORMAL'
 when 'GRATIFICACAO NATALINA' then '13º SALARIO'
 when 'GRAT NATALINA ANIVERSARIO' then 'ADIANTAMENTO 13º'
 else substring(fol.NmFolha,4,len(fol.NmFolha)-3)
end nmTipoFolha,
'SIMULACAO' as nmTipoCalculo,
format(capa.cdfolha + 10, '00') as nuSequencialFolha,
--- informação do Contracheque
format(capa.dtOperacao, 'dd/MM/yyyy') as dtCalculo,
'27/09/2023' as dtCredito,
res.vlProventos as vlProventos,
res.vlDescontos as vlDescontos,
'1' as inSistemaOrigem,
--- Dados Pessoais Básicos
trim(fun.nmFuncionario) as nmPessoa,
format(fun.DtNascimento, 'dd/MM/yyyy') as dtNascimento,
upper(trim(isnull(fun.Sexo, 'M'))) as flSexo,
upper(trim(isnull(fun.NmMae, 'NAO INFORMADO'))) as nmMae,
'NAO INFORMADO' as nmPais,
upper(trim(isnull(ec.NmEstadoCivil, 'NAO INFORMADO'))) as nmEstadoCivil,
upper(trim(isnull(raca.NmRacaCor, 'NAO INFORMADO'))) as nmRaca,
-- Informações do Vínculo
format(isnull(capa.DtAdmissao,nom.DtAdmissao), 'dd/MM/yyyy') as dtAdmissao,
--nom.DtAdmissao,
null as dtFimPrevisto,
case upper(trim(c.TpCargo))
 when 'E' then 'EFETIVO'
 when 'T' then 'ACT-ADMITIDO EM CARACTER TEMPORARIO'
 when 'C' then 'COMISSIONADO'
 when 'I' then 'PENSAO NAO PREVIDENCIARIA'
 else upper(trim(c.TpCargo))
end as NmRelacaoTrabalho,
case when upper(trim(c.TpCargo)) = 'E' or upper(trim(c.TpCargo)) = 'C' then 'ESTATUTARIO' else 'ADMINISTRATIVO ESPECIAL' end as nmRegimeTrabalho,
case when upper(trim(c.TpCargo)) = 'E' then 'CARGO PERMANENTE' else 'CARGO TEMPORARIO' end as nmNaturezaVinculo,
case when upper(trim(c.TpCargo)) = 'E' then 'REGIME PROPRIO' else 'REGIME GERAL' end as nmRegimePrevidenciario,
case when upper(trim(c.TpCargo)) = 'I' then 'PENSIONISTA NAO PREVIDENCIARIA' else 'ATIVO' end as nmSituacaoPrevidenciaria,
case when format(isnull(capa.DtAdmissao,nom.DtAdmissao), 'yyyyMMdddd') > '20040401' then 'FUNDO PREVIDENCIARIO' else 'FUNDO FINANCEIRO' end as nmTipoRegimeProprioPrev,
'N' as flPrevidenciaComp,
'S' as flAtivo,
'SEMANAL' as nmTipoCargaHoraria,
nom.CargaHoraria as nuCargaHoraria,
nom.CargaHoraria as nuCargaHorariaRelacao,
upper(trim(lot.Sigla)) as sgUnidadeOrganizacional,
'JORNADA PADRAO' as nmJornadaTrabalho,
upper(trim(cc.NmCCusto)) as deCentroCusto,
capa.DependenteIR as nuDependentes,
--- Informações do Último Afastamento
null as dtInicioAfastamento,
null as dtFimAfastamento,
null as dtFimPrevistoAfastamento,
null as flTipoAfastamento,
null as flRemunerado,
null as flRemuneracaoIntegral,
null as deMotivoAfastamento,
null as nmGrupoMotivoAfastamento,
null as flAcidenteTrabalho,
null as deObservacaoAfastamento,
--- Dados Bancários
capa.cdBanco as nuBancoCredito,
capa.cdAgencia as nuAgenciaCredito,
left(trim(replace(capa.cdConta,' ','')),len(trim(replace(capa.cdConta,' ',''))) - 1) as nuContaCredito,
right(trim(replace(capa.cdConta,' ','')),1) as nuDVContaCredito,
'C' as flTipoContaCredito,
--- Informação do Cargo Efetivo ou Temporário Básico
case when upper(trim(c.TpCargo)) != 'C' then c.NmCargo else null end as deCarreira,
null as deGrupoOcupacional,
case when upper(trim(c.TpCargo)) != 'C' then f.NmFuncao else null end as deCargo,
null as deClasse,
null as deCompetencia,
null as deEspecialidade,
case when upper(trim(c.TpCargo)) != 'C' then capa.CdNivel else null end as nuNivelCEF,
null as nuReferenciaCEF,
case when upper(trim(c.TpCargo)) != 'C' then 'D' else null end as flTipoOcupacao,
--case when upper(trim(c.TpCargo)) = 'E' and upper(trim(nom.Opcao13Salario)) = 'S' then 'S' else 'N' end as flOpcao13Salario,
--- Informações do Cargo Comissionado Básicos
case when upper(trim(c.TpCargo)) = 'C' then c.NmCargo else null end as deGrupoComissionado,
case when upper(trim(c.TpCargo)) = 'C' then f.NmFuncao else null end as deCargoComissionado,
case when upper(trim(c.TpCargo)) = 'C' then c.NmCargo else null end as nuNivelCCO,
case when upper(trim(c.TpCargo)) = 'C' then capa.CdNivel else null end as nuReferenciaCCO,
case when upper(trim(c.TpCargo)) = 'C' then 'S' else null end as flPrincipal,
case when upper(trim(c.TpCargo)) = 'C' then 'N' else null end as flTipoProvimento,
case when upper(trim(c.TpCargo)) = 'C' then 'PELO CARGO COMISSIONADO' else null end as nmOpcaoRemuneracao,
case when upper(trim(c.TpCargo)) = 'C' then 'N' else null end as flPagaSubsidio,
--- Informações da Pensão Previdenciária
null as nuMatInstituidorLegado,
null as nuPercentCota
from TComplementoFolhaMes capa
left join TNomeacoes nom on nom.cdEmpresa = capa.cdEmpresa
                        and nom.cdNomeacao = capa.cdNomeacao 
left join TFuncionarios fun on fun.cdEmpresa = capa.cdEmpresa
                           and fun.cdFuncionario = nom.cdFuncionario 
left join TFolhas fol on fol.cdEmpresa = capa.cdEmpresa
                     and fol.cdFolha = capa.cdFolha 
left join TLotacoes lot on lot.cdEmpresa = capa.cdEmpresa
                       and lot.cdLotacao  = capa.cdLotacao 
left join TCargos c on c.cdEmpresa = capa.cdEmpresa
                       and c.cdCargo  = capa.cdCargo 
left join TFuncoes f on f.cdEmpresa = capa.cdEmpresa
                    and f.cdFuncao = capa.cdFuncao 
left join TCCustos cc on cc.cdEmpresa = capa.cdEmpresa
                     and cc.cdCCusto = capa.cdCCusto
left join TEstadoCivil ec on ec.cdEstadoCivil = fun.cdEstadoCivil 
left join TRacasCores raca on raca.cdRacaCor = fun.cdRacaCor 
left join (
select CdEmpresa, cdFolha, Periodo, CdNomeacao, isnull([P],0) as vlProventos, isnull([D],0) as vlDescontos
from (
select pag.CdEmpresa, pag.cdFolha, pag.Periodo, pag.CdNomeacao, rub.TpEvento, sum(pag.Valor) as vlPagamento
from TFolhaMes pag
left join TEventos rub on rub.CdEmpresa = pag.CdEmpresa and rub.CdEvento = pag.CdEvento
where pag.Periodo = 202310 and rub.TpEvento != 'B'
group by pag.CdEmpresa, pag.cdFolha, pag.Periodo, pag.CdNomeacao, rub.TpEvento
) as pag
pivot ( sum(vlPagamento) for TpEvento in ([P], [D])) pvt
) res on res.CdEmpresa = capa.CdEmpresa
     and res.cdFolha = capa.cdFolha
     and res.Periodo = capa.Periodo
     and res.CdNomeacao = capa.CdNomeacao
where capa.CdDependente = 0 and capa.Periodo = 202310
;
