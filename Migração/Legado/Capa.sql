select
lot.Sigla ,
pag.Periodo ,
fol.NmFolha ,
pag.CdNomeacao ,
pag.CdDependente ,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
trim(fun.nmFuncionario) as nmPessoa ,
format(fun.DtNascimento, 'dd/MM/yyyy') as DtNascimento,
trim(ec.NmEstadoCivil) as NmEstadoCivil ,
fun.Sexo ,
trim(fun.NmMae) as NmMae ,
trim(fun.NmPai) as NmPai ,
capa.DtAdmissao ,
capa.DtDemissao ,
c.NmCargo ,
c.TpCargo ,
f.NmFuncao ,
capa.CdNivel ,
format(nom.DtAdmissao, 'dd/MM/yyyy') as DtAdmissao,
format(nom.DtDemissao, 'dd/MM/yyyy') as DtDemissao,
nom.CdCargo ,
nom.cdFuncao ,
nom.CdNivel ,
nom.CargaHoraria ,
nom.Situacao ,
nom.CdLotacao
from TFFinanceira pag
left join TComplementoFFinanceira capa on capa.CdEmpresa = pag.CdEmpresa
                                      and capa.CdFolha = pag.CdFolha 
                                      and capa.Periodo = pag.Periodo
                                      and capa.CdNomeacao = pag.CdNomeacao
                                      and capa.CdDependente = pag.CdDependente 
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
left join TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil 
where pag.CdDependente != 0
;
