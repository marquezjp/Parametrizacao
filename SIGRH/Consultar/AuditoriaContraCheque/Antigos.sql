select distinct capa.cdvinculo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join (
select cdorgao, 200908 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMSC' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMGE' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEMEC' union all
select cdorgao, 201701 as nuanomesreferencia from vcadorgao where sgorgao = 'SEDET' union all
select cdorgao, 201906 as nuanomesreferencia from vcadorgao where sgorgao = 'SUDES'
) l on l.cdorgao = f.cdorgao and l.nuanomesreferencia > f.nuanomesreferencia