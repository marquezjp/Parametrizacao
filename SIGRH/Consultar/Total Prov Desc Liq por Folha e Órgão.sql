select 
     f.nuanomesreferencia     AnoMes,
     f.nuanoreferencia        Ano,
     f.numesreferencia        Mes,
     o.cdorgaosirh            Codigo,
     o.sgorgao                Orgao,
     tfo.nmtipofolhapagamento Folha,
     tc.nmtipocalculo         Tipo,
     sum(nvl(capa.vlproventos, 0))   Proventos, -- Having 8 > 0
     sum(nvl(capa.vldescontos, 0))   Descontos,
     sum(nvl(capa.vlproventos, 0) - nvl(capa.vldescontos, 0)) Liquido,
     count(*)                 Servidores
  
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
          
where f.flcalculodefinitivo = 'S'
  --and f.nuanomesreferencia = 202011
  --and f.nuanoreferencia in (2020, 2019, 2018)
  --and f.numesreferencia in (09, 10, 11)
  --and  o.sgorgao = 'SEMGE'
          
group by f.nuanomesreferencia, f.nuanoreferencia, f.numesreferencia, tfo.nmtipofolhapagamento, tc.nmtipocalculo, o.cdorgaosirh, o.sgorgao
having  sum(nvl(capa.vlproventos, 0)) > 0
order by f.nuanomesreferencia, f.nuanoreferencia, f.numesreferencia, o.cdorgaosirh, tfo.nmtipofolhapagamento, tc.nmtipocalculo
