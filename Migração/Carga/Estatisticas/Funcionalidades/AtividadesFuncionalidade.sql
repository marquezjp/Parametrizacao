with
mapa as (
select Modulo, Submodulo, Funcionalidade, Funcao, Ord
from json_table('{"mapa":[
{"Modulo":"CADASTRO","Submodulo":"PESSOA","Funcionalidade":"MANTER PESSOAS","Funcao":"Cadastrar Pessoas","Ord":"1"},
{"Modulo":"CADASTRO","Submodulo":"DEPENDENTE","Funcionalidade":"MANTER DEPENDENTES","Funcao":"Cadastrar Dependentes","Ord":"2"},
{"Modulo":"PROCESSO SELETIVO","Submodulo":"INGRESSO","Funcionalidade":"MANTER VINCULO PERMANENTE","Funcao":"Nomear Cargo Efetivo","Ord":"3"},
{"Modulo":"CADASTRO","Submodulo":"CARGO EFETIVO","Funcionalidade":"MANTER TRANSFORMACAO DE CARGO/REENQUADRAMENTO","Funcao":"Transformar Cargo/Enquadramento","Ord":"4"},
{"Modulo":"CADASTRO","Submodulo":"CONTRATO TEMPORARIO","Funcionalidade":"MANTER ADMITIDO EM CONTRATO TEMPORARIO","Funcao":"Admitir Contrato Temporário","Ord":"5"},
{"Modulo":"CADASTRO","Submodulo":"CARGO EM COMISSAO","Funcionalidade":"EMPOSSAR COMISSIONADO EM UM NOVO VINCULO","Funcao":"Empossar Cargo Comissionado","Ord":"6"},
{"Modulo":"CADASTRO","Submodulo":"CARGO EM COMISSAO","Funcionalidade":"EXONERAR/DISPENSAR CARGO EM COMISSAO","Funcao":"Exonerar Cargo Comissionado","Ord":"7"},
{"Modulo":"PREVIDENCIA","Submodulo":"PENSAO NAO PREVIDENCIARIA","Funcionalidade":"MANTER PENSAO NAO PREVIDENCIARIA","Funcao":"Manter Pensão Não Previdenciária","Ord":"8"},
{"Modulo":"CADASTRO","Submodulo":"VINCULO","Funcionalidade":"MANTER DADOS BANCARIOS","Funcao":"Alterar Dados Bancários do Servidor","Ord":"9"},
{"Modulo":"CADASTRO","Submodulo":"VINCULO","Funcionalidade":"MANTER CENTRO DE CUSTO DO SERVIDOR","Funcao":"Alterar Centro de Custo do Servidor","Ord":"10"},
{"Modulo":"AFASTAMENTOS","Submodulo":"AFASTAMENTOS GERAIS","Funcionalidade":"AFASTAR SERVIDORES","Funcao":"Afastar Servidor","Ord":"11"},
{"Modulo":"AFASTAMENTOS","Submodulo":"OBITO","Funcionalidade":"REGISTRAR OBITO DE PESSOAS","Funcao":"Registrar Óbito de Pessoa","Ord":"12"},
{"Modulo":"MOVIMENTACAO","Submodulo":"DISPOSICAO FORA DO AGRUPAMENTO","Funcionalidade":"RECEBER SERVIDOR A DISPOSICAO","Funcao":"Receber Servidor a Disposição","Ord":"13"},
{"Modulo":"MOVIMENTACAO","Submodulo":"MOVIMENTACAO NO AGRUPAMENTO","Funcionalidade":"GERAR MOVIMENTACOES","Funcao":"Movimentar Servidor","Ord":"14"},
{"Modulo":"PAGAMENTOS","Submodulo":"PENSAO ALIMENTICIA","Funcionalidade":"MANTER SENTENCA JUDICIAL DE PENSAO ALIMENTICIA","Funcao":"Cadastrar Sentença Judicial de Pensão Alimentícia","Ord":"15"},
{"Modulo":"PAGAMENTOS","Submodulo":"PENSAO ALIMENTICIA","Funcionalidade":"MANTER RECEBEDOR DE PENSAO ALIMENTICIA","Funcao":"Alterar Representante de Pensão Alimentícia","Ord":"16"},
{"Modulo":"PAGAMENTOS","Submodulo":"LANCAMENTO FINANCEIRO","Funcionalidade":"MANTER LANCAMENTOS FINANCEIROS","Funcao":"Cadastrar Lançamentos Financeiros","Ord":"17"},
{"Modulo":"PAGAMENTOS","Submodulo":"CONSIGNACOES","Funcionalidade":"REGISTRAR LANCAMENTO DE CONSIGNACOES","Funcao":"Cadastrar Lançamento de Consignações","Ord":"18"},
{"Modulo":"PAGAMENTOS","Submodulo":"TRIBUTACAO","Funcionalidade":"MANTER REGISTRO DE RECOLHIMENTO AVULSO DO INSS","Funcao":"Cadastrar Registro de Recolhimento Avulso do INSS","Ord":"19"}
]}', '$.mapa[*]'
columns (Modulo, Submodulo, Funcionalidade, Funcao, Ord)
))

select Funcao, nvl(Set23,0) as Set23, nvl(Out23,0) as Out23, nvl(Nov23,0) as Nov23 from (
select
 to_char(log.dtlog, 'YYYYMM') as AnoMes,
 mapa.funcao as Funcao,
 to_number(mapa.ord) as Ord,
 count(1) as Qtde
from eseglog log
left join esegautorizacaoacesso aa on aa.cdautorizacaoacesso = log.cdautorizacaoacesso
left join esegfuncionalidade f on f.cdfuncionalidade = log.cdfuncionalidade
left join esegsubmodulo sm on sm.cdsubmodulo = f.cdsubmodulo
left join esegmodulo m on m.cdmodulo = sm.cdmodulo
left join esegfuncionalidadeagrupamento fa on fa.cdfuncagrupamento = log.cdfuncagrupamento
left join mapa on mapa.Modulo = m.nmmodulo
      and mapa.Submodulo = sm.nmsubmodulo
      and mapa.Funcionalidade = fa.nmfuncionalidade
where log.dtlog >= '11/09/2023' and mapa.funcao is not null
group by to_char(log.dtlog, 'YYYYMM'), mapa.funcao, to_number(mapa.ord)
)
pivot (sum (Qtde) for AnoMes in ('202309' as Set23, '202310' as Out23, '202311' as Nov23))
order by Ord