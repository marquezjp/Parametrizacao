--- Identificar os Vinculos de Pagamento de Suplementar para os Aposentados

select capa.*
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.nuanomesreferencia = 202112 and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 5 and f.nusequencialfolha = 10
where vlproventos != 0
  and flativo = 'N';

--- Identificar os Orgãos dos Vinculos de Pagamento de Suplementar para os Aposentados

with lista as (
select cdvinculo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.nuanomesreferencia = 202112 and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 5 and f.nusequencialfolha = 10
where flativo = 'N' and vlproventos != 0
)

select
 capa.cdvinculo,
 f.cdorgao,
 max(f.nuanomesreferencia) as nuanomesreferencia

from epagcapahistrubricavinculo capa
inner join lista l on l.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento and f.flcalculodefinitivo = 'S'
                               and f.nuanomesreferencia != 202112
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1 and f.nusequencialfolha = 1

where flativo = 'S'

group by 
 capa.cdvinculo,
 f.cdorgao

order by
 capa.cdvinculo;

--- Alterar a Capa para Ativo e para o Orgão de Origem
update epagcapahistrubricavinculo
set flativo = 'S',
    cdrelacaotrabalho = 5,
    cdnaturezavinculo = 1,
    cdsituacaoprevidenciaria = 1,
    cdcentrocusto = 2

where cdvinculo in (29030, 30157, 31922, 36588, 36777, 37080)
  and cdfolhapagamento = 59630;