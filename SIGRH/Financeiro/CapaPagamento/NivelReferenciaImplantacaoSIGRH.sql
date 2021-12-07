select
 o.sgorgao as ORGAO,
 v.numatricula as MATRICULA,
 f.nuanomesreferencia,
 capa.nugruposalarial || capa.nunivelcef || capa.nureferenciacef as NivelReferencia

from epagcapahistrubricavinculo capa
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join (
select
 capa.cdvinculo,
 max(f.nuanomesreferencia) as nuanomesreferencia
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
                               and f.nuanomesreferencia <= '202003'

where capa.nugruposalarial is not null
  and capa.nunivelcef is not null
  and capa.nureferenciacef is not null

group by capa.cdvinculo