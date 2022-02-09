select
 f.nuanomesreferencia as AnoMes,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 o.cdorgaosirh as Codigo,
 o.sgorgao as Orgao,
 tfo.nmtipofolhapagamento as Folha,
 upper(tc.nmtipocalculo) as Tipo,
 f.nusequencialfolha as Seq,
 sum(nvl(capa.vlproventos, 0)) as Proventos, 
 sum(nvl(capa.vldescontos, 0)) as Descontos,
 sum(nvl(capa.vlcredito, 0)) as Credito,
 count(*) as Servidores
  
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S' and f.nuanoreferencia < 2022
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao

where capa.vlproventos != 0 or capa.vldescontos !=0
          
group by
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha,
 o.cdorgaosirh,
 o.sgorgao

order by
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.cdorgaosirh,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha
