--- Resumo de Capa de Pagamentos
select
 a.sgagrupamento as Agrupamento,
 f.nuanomesreferencia as AnoMes,
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
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
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento

where capa.vlproventos != 0 or capa.vldescontos !=0
          
group by
 a.sgagrupamento,
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha,
 o.sgorgao

order by
 a.sgagrupamento,
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.sgorgao,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha