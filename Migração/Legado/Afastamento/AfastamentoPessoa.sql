select
--a.CdEmpresa ,
--a.CdFuncionario ,
format(fun.CdFuncionario, '000000000') + format(fun.DVFuncionario, '00') as nuCPF,
format(a.DtAnotacao, 'dd/MM/yyyy') as DtAnotacao ,
format(a.DtResolucao, 'dd/MM/yyyy') as DtResolucao ,
-- a.CdTpAnotacao ,
tpa.NmTpAnotacao ,
trim(fun.nmFuncionario) as nmPessoa,
format(fun.DtNascimento, 'dd/MM/yyyy') as dtNascimento,
a.Anotacao ,
a.IdLancamento
from TAnotacoes a
left join TFuncionarios fun on fun.cdEmpresa = a.cdEmpresa
                           and fun.cdFuncionario = a.cdFuncionario 
left join TTpAnotacoes tpa on tpa.CdEmpresa = a.CdEmpresa and tpa.CdTpAnotacao = a.CdTpAnotacao 
where a.CdTpAnotacao in (
159, 55, 155, 30, 11, 13, 8, -- Desligamento
36, -- Falecimento
64, 46, 28, 48, 27, 2, 57, 45, -- Licença 
203, 204, -- Suspnsão de Pagamento
62, 58, 47, -- Ferias e Lecença Premio
59, 10, 18, -- Tranformação de Cargo
1, 65, 3, 17 -- Movimentação
)
order by fun.CdFuncionario, a.DtAnotacao, a.CdTpAnotacao
;