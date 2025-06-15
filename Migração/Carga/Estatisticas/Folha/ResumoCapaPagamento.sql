--- Resumo Capa de Pagamentos
select
-- a.sgagrupamento as Agrupamento,
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(f.nuanoreferencia),4,0) || lpad(trim(f.numesreferencia),2,0) as AnoMes,
 lpad(trim(f.nuanoreferencia),4,0) as Ano,
 lpad(trim(f.numesreferencia),2,0) as Mes,
 o.sgorgao as Orgao,
 upper(tfo.nmtipofolhapagamento) as Folha,
 upper(tc.nmtipocalculo) as Tipo,
 lpad(trim(f.nusequencialfolha),2,0) as Seq,

 sum(nvl(capa.vlproventos, 0)) as Proventos,
 sum(nvl(capa.vldescontos, 0)) as Descontos,
 sum(nvl(vlproventos, 0) - nvl(vldescontos, 0)) as Credito,
 count(capa.cdvinculo) as Servidores

from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (   to_number(replace(trim(nvl(vlproventos, 0)), '.', ',')) != 0
       or to_number(replace(trim(nvl(vldescontos, 0)), '.', ',')) != 0)
  and o.cdagrupamento not in (1, 19)

group by
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 lpad(trim(f.nuanoreferencia),4,0) || lpad(trim(f.numesreferencia),2,0),
 lpad(trim(f.nuanoreferencia),4,0),
 lpad(trim(f.numesreferencia),2,0),
 o.sgorgao,
 upper(tfo.nmtipofolhapagamento),
 upper(tc.nmtipocalculo),
 lpad(trim(nusequencialfolha),2,0)

order by
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 lpad(trim(f.nuanoreferencia),4,0) || lpad(trim(f.numesreferencia),2,0) desc,
 o.sgorgao,
 upper(tfo.nmtipofolhapagamento),
 upper(tc.nmtipocalculo),
 lpad(trim(nusequencialfolha),2,0)
;