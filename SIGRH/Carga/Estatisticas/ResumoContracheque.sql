select *
from (
select 
 a.sgagrupamento as Agrupamento,
 f.nuanomesreferencia as AnoMes,
 lpad(f.nuanoreferencia,4,0) as Ano,
 lpad(f.numesreferencia,2,0) as Mes,
 o.sgorgao as Orgao,
 tfo.nmtipofolhapagamento as Folha,
 upper(tc.nmtipocalculo) as Tipo,
 f.nusequencialfolha as Seq,
 case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 --count(*) as Qtde,
 sum(nvl(pag.vlpagamento, 0)) as Valor

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join epagrubricaagrupamento arub on arub.cdrubricaagrupamento = pag.cdrubricaagrupamento
inner join epagrubrica rub on rub.cdrubrica = arub.cdrubrica and rub.cdtiporubrica != 9

where pag.vlpagamento != 0

group by
 a.sgagrupamento,
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.sgorgao,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end)
 
order by
 a.sgagrupamento,
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.sgorgao,
 tfo.nmtipofolhapagamento,
 tc.nmtipocalculo,
 f.nusequencialfolha,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end)
)
pivot 
(
 sum(Valor)
 for GrupoRubrica in ('1-PROVENTO' as PROVENTOS, '5-DESCONTO' as DESCONTOS)
)

order by
 Agrupamento,
 AnoMes,
 Ano,
 Mes,
 Orgao,
 Folha,
 Tipo,
 Seq