--- Relatorio Estatistico por Orgão/Folhas
select
 sgorgao,
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha,
 count(*) as Vinculos,
 sum(to_number(replace(trim(nvl(vlproventos,0)),'.',','))) as TotalProventos,
 sum(to_number(replace(trim(nvl(vldescontos,0)),'.',','))) as TotalDescontos
from SIGRHMIG.EMIGCAPAPAGAMENTO
group by
 sgorgao,
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha
order by 
 sgorgao,
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha

--- Relatório Estatistico por Folhas
select
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha,
 count(distinct sgorgao) as Orgaos,
 count(*) as Vinculos,
 sum(to_number(replace(trim(nvl(vlproventos,0)),'.',','))) as TotalProventos,
 sum(to_number(replace(trim(nvl(vldescontos,0)),'.',','))) as TotalDescontos
from SIGRHMIG.EMIGCAPAPAGAMENTO
group by
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha
order by 
 nuanoreferencia,
 numesreferencia,
 nmtipofolha,
 nmtipocalculo,
 nusequencialfolha
 
--- Relatório Estatistico por Órgãos/Anos
select
 sgorgao,
 nuanoreferencia,
 count(distinct nuanoreferencia || lpad(numesreferencia,2,0)) as Meses,
 count(distinct nuanoreferencia || lpad(numesreferencia,2,0) || nmtipofolha || nmtipocalculo || lpad(nusequencialfolha,2,0)) as Folhas,
 sum(to_number(replace(trim(nvl(vlproventos,0)),'.',','))) as TotalProventos,
 sum(to_number(replace(trim(nvl(vldescontos,0)),'.',','))) as TotalDescontos
from SIGRHMIG.EMIGCAPAPAGAMENTO
group by sgorgao, nuanoreferencia
order by sgorgao, nuanoreferencia