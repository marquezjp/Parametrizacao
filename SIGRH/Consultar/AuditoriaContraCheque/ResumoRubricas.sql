select *
from (
select 
 f.nuanomesreferencia as AnoMes,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 o.cdorgaosirh as Codigo,
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
                               and f.flcalculodefinitivo = 'S' and f.nuanoreferencia < 2022
inner join epagtipofolhapagamento tfo on tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                     and rub.cdtiporubrica != 9

where pag.vlpagamento != 0

group by
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.cdorgaosirh,
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
 f.nuanomesreferencia,
 f.nuanoreferencia,
 f.numesreferencia,
 o.cdorgaosirh,
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
 AnoMes,
 Ano,
 Mes,
 Codigo,
 Orgao,
 Folha,
 Tipo,
 Seq