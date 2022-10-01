with
folhamigrada as (
select cdfolhapagamento from epagfolhapagamento
 where nuanomesreferencia = 202205
   and cdtipocalculo = 1 and cdtipofolhapagamento = 2 and flcalculodefinitivo = 'S'
),

folharecalculo as (
select cdfolhapagamento from epagfolhapagamento
 where nuanomesreferencia = 202205
  and cdtipocalculo = 3 and cdtipofolhapagamento = 2 and nusequencialfolha = 12
),

migrado as (
select v.cdpessoa, sum(pag.vlpagamento) as vlpagmigrado
from folhamigrada fmig
inner join epaghistoricorubricavinculo pag on pag.cdfolhapagamento = fmig.cdfolhapagamento
inner join vpagrubricaagrupamento ra on ra.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and ra.cdtiporubrica = 5 and ra.nurubrica = 4
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
group by v.cdpessoa
),

recalculo as (
select v.cdpessoa, sum(pag.vlpagamento) as vlpagrecalculo
from folharecalculo frec
inner join epaghistoricorubricavinculo pag on pag.cdfolhapagamento = frec.cdfolhapagamento
inner join vpagrubricaagrupamento ra on ra.cdrubricaagrupamento = pag.cdrubricaagrupamento
                                    and ra.cdtiporubrica = 5 and ra.nurubrica = 4
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
group by v.cdpessoa
)

select p.nucpf, p.nmpessoa, migrado.vlpagmigrado, recalculo.vlpagrecalculo
from migrado
inner join ecadpessoa p on p.cdpessoa = migrado.cdpessoa
left join recalculo on recalculo.cdpessoa = migrado.cdpessoa
where abs(migrado.vlpagmigrado - recalculo.vlpagrecalculo) >= 0.02
