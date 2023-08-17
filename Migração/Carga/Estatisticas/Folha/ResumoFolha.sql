--- Resumo de Capa de Pagamentos
with
totais as (
select
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
 case
   when upper(tfo.nmtipofolhapagamento) = 'FOLHA NORMAL' and upper(tc.nmtipocalculo) = 'SUPLEMENTAR' then upper(upper(trim(nmtipocalculo)))
   else upper(tfo.nmtipofolhapagamento)
 end as TipoFolha,
 sum(nvl(capa.vlproventos, 0)) as Proventos, 
 sum(nvl(capa.vldescontos, 0)) as Descontos,
 sum(nvl(capa.vlcredito, 0)) as Credito,
 count(capa.cdvinculo) as Pagamentos,
 count(distinct lpad(trim(f.nusequencialfolha),2,0) || o.sgorgao) as Folhas
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento

where (capa.vlproventos != 0 or capa.vldescontos !=0)
  and o.cdagrupamento = 1
          
group by
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 f.nuanoreferencia,
 f.numesreferencia,
 case
   when upper(tfo.nmtipofolhapagamento) = 'FOLHA NORMAL' and upper(tc.nmtipocalculo) = 'SUPLEMENTAR' then upper(upper(trim(nmtipocalculo)))
   else upper(tfo.nmtipofolhapagamento)
 end
),

totais_folha as (
select Agrupamento, Ano, Mes,
 Proventos, Descontos, Credito, Pagamentos,
 nvl(FOLHAS_NORMAL,0) as FOLHAS_MENSAIS,
 nvl(FOLHAS_SUPLEMENTARES,0) as FOLHAS_SUPLEMENTARES,
 nvl(FOLHAS_13_SALARIO,0) as FOLHAS_13_SALARIO,
 nvl(FOLHAS_ADIANT_13_SALARIO,0) as FOLHAS_ADIANT_13_SALARIO
from totais
pivot (sum(Folhas) for TipoFolha in (
 'FOLHA NORMAL' as FOLHAS_NORMAL,
 'SUPLEMENTAR' as FOLHAS_SUPLEMENTARES,
 '13º SALARIO' as FOLHAS_13_SALARIO,
 'ADIANTAMENTO 13º' as FOLHAS_ADIANT_13_SALARIO
)))

select Agrupamento, Ano || lpad(Mes,2,0) as AnoMes, Ano, Mes, --Orgao,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Credito) as Credito,
 sum(Pagamentos) as Pagamentos,
 sum(FOLHAS_MENSAIS) as FOLHAS_MENSAIS,
 sum(FOLHAS_SUPLEMENTARES) as FOLHAS_SUPLEMENTARES,
 sum(FOLHAS_13_SALARIO) as FOLHAS_13_SALARIO,
 sum(FOLHAS_ADIANT_13_SALARIO) as FOLHAS_ADIANT_13_SALARIO
from totais_folha
group by Ano || lpad(Mes,2,0), Agrupamento, Ano, Mes
order by Ano || lpad(Mes,2,0) desc, Agrupamento, Ano, Mes
;

