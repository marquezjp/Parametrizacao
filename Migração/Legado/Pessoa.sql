select
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
trim(fun.nmFuncionario) as nmPessoa ,
format(fun.DtNascimento, 'dd/MM/yyyy') as DtNascimento,
trim(ec.NmEstadoCivil) as NmEstadoCivil ,
fun.Sexo ,
trim(fun.NmMae) as NmMae ,
trim(fun.NmPai) as NmPai
from TFuncionarios fun
left join TEstadoCivil ec on ec.CdEstadoCivil = fun.CdEstadoCivil 