--- Resumo Contracheque
with
TotalGrupoRubrica as (
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
 lpad(f.nusequencialfolha,2,0) as Seq,
 pag.cdvinculo as Vinculo,
 case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 sum(nvl(pag.vlpagamento, 0)) as Valor,
 count(1) as Lancamentos
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join ecadhistorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica != 9
where pag.vlpagamento != 0 and o.cdagrupamento not in (1, 19)
group by
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 f.nuanomesreferencia, f.nuanoreferencia, f.numesreferencia, o.sgorgao,
 tfo.nmtipofolhapagamento, tc.nmtipocalculo, f.nusequencialfolha,
 pag.cdvinculo,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end)
),
TotalVinculos as (
select Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq, Vinculo,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Lancamentos) as Lancamentos
from TotalGrupoRubrica
pivot (sum(Valor) for GrupoRubrica in ('1-PROVENTO' as Proventos, '5-DESCONTO' as Descontos))
group by Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq, Vinculo
)

select Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq,
 sum(Proventos) as Proventos,
 sum(Descontos) as Descontos,
 sum(Lancamentos) as Lancamentos,
 count(1) as Servidores
from TotalVinculos
group by Agrupamento, AnoMes, Ano, Mes, Orgao, Folha, Tipo, Seq
order by Agrupamento, AnoMes desc, Orgao, Folha, Tipo, Seq
;