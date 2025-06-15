select Orgao, Arquivo, IndicadorAprovado, count(1) as qtde from (
select
inoperacao as Operacao,
o.sgorgao as Orgao,
arq.nuanoreferencia || lpad(arq.numesreferencia,2,0) as AnoMes,
lpad(numatricula,7,0) || '-' || nudvmatricula || '-' || lpad(nuseqmatricula,2,0) as Matricula,
lpad(nurubricatipo,2,0) || '-' || lpad(nurubricaidentificador,4,0) || '-' || lpad(nurubricasufixo,2,0) as Rubrica,
imp.dtiniciodireito as DataInicio,
imp.dtfimdireito as DataFim,
imp.nuparcelas as Parcelas,
imp.vlindice as Indice,
imp.vllancamentoparcela as Valor,
imp.flaprovado as IndicadorAprovado,
imp.demotivorejeicao as MotivoRejeicao,
arq.dtimportacao as DataImportacao,
arq.dearquivoimportado as Arquivo
from epaglancamentoimp imp
inner join epagimparqlancamento arq on arq.cdimparqlancamento = imp.cdimparqlancamento
inner join ecadhistorgao o on o.cdorgao = arq.cdorgao
where imp.flaprovado = 'N'
--where o.sgorgao = 'SESAU'
) group by Orgao, Arquivo, IndicadorAprovado order by Orgao, Arquivo, IndicadorAprovado
;