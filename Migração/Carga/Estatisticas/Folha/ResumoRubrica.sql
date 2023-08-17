--- Resumo Contracheque
select 
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end as Agrupamento,
 lpad(trim(f.nuanoreferencia),4,0) as Ano,
 lpad(trim(f.numesreferencia),2,0) as Mes,
 upper(tfo.nmtipofolhapagamento) as Folha,
 upper(tc.nmtipocalculo) as Tipo,
 lpad(f.nusequencialfolha,2,0) as Seq,
 case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end as GrupoRubrica,
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) as Rubrica,
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
where pag.vlpagamento != 0 and o.cdagrupamento = 1
group by
 case a.sgagrupamento
  when 'ADM-DIR' then 'ADM-DIRETA'
  when 'MILITAR' then 'MILITAR'
  else 'ADM-INDIRETA'
 end,
 f.nuanoreferencia, f.numesreferencia,
 tfo.nmtipofolhapagamento, tc.nmtipocalculo, f.nusequencialfolha,
 (case
  when rub.cdtiporubrica in (1, 2, 4, 10, 12) then '1-PROVENTO'
  when rub.cdtiporubrica in (5, 6, 8, 11, 13) then '5-DESCONTO'
  when rub.cdtiporubrica = 9                  then '9-BASE DE CÁLCULO'
  else ' '
 end),
 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0)
order by 1, 2, 3, 6, 7, 8
