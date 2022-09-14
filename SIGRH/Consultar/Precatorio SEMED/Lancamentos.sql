with lista as (
select pag.cdvinculo
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.nuanoreferencia in (2021, 2022) and f.flcalculodefinitivo = 'S'
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento
where rub.nurubrica = 801
group by pag.cdvinculo
having count(*) > 1
order by pag.cdvinculo
)

select

 o.sgorgao as Orgao,
 f.nuanoreferencia as Ano,
 f.numesreferencia as Mes,
 tf.nmtipofolhapagamento as Folha,
 case f.cdtipocalculo
  when 1 then 'NORMAL'
  when 5 then 'SUPLEMENTAR'
  else to_char(f.cdtipocalculo)
 end as Calculo,
 lpad(f.nusequencialfolha,2,'0') as SeqFolha,
 case f.flcalculodefinitivo when 'N' then 'NÃO' when 'S' then 'SIM' else '' end as Definitivo,

 lpad(v.numatricula, 7, 0)||'-'||v.nudvmatricula as Matricula,
 lpad(p.nucpf, 11, 0) as CPF,
 p.nmpessoa as Nome,

 lpad(rub.cdtiporubrica,2,0) || '-' || lpad(rub.nurubrica,4,0) || '-' || lpad(pag.nusufixorubrica,2,'0') as Rubrica,
 rub.derubricaagrupamento as DeRubrica,
 to_char(pag.vlpagamento, '999G999D99', 'NLS_NUMERIC_CHARACTERS=,.') as Valor

from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.nuanoreferencia in (2021, 2022) and f.flcalculodefinitivo = 'S'
left join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join lista l on l.cdvinculo = pag.cdvinculo

--inner join epagcapahistrubricavinculo capa on capa.cdvinculo = pag.cdvinculo and capa.cdfolhapagamento = pag.cdfolhapagamento
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vpagrubricaagrupamento rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento

where rub.nurubrica = 801