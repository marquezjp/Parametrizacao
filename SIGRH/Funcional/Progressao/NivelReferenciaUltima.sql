select
 o.sgorgao as ORGAO,
 v.numatricula as MATRICULA,
 f.nuanomesreferencia,
 pag.nugruposalarial || pag.nunivelcef || pag.nureferenciacef as NivelReferencia

from epagcapahistrubricavinculo pag
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join (
select
 pag.cdvinculo,
 max(f.nuanomesreferencia) as nuanomesreferencia
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.cdtipofolhapagamento = 2 and f.cdtipocalculo = 1
                               and f.nuanomesreferencia <= '202003'
group by pag.cdvinculo
) ult on ult.cdvinculo = pag.cdvinculo
     and ult.nuanomesreferencia = f.nuanomesreferencia

where pag.cdvinculo = (select cdvinculo from ecadvinculo where numatricula = 0940193)

order by f.nuanomesreferencia