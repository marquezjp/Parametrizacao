select count(*) from (
select cdvinculo, sum(sigrh), sum(legado)
from (select c.cdvinculo, sum(c.vlpagamento) sigrh, 0 legado from vpagcc c
inner join epagrubricaagrupamento ra on ra.cdrubricaagrupamento = c.cdrubricaagrupamento and ra.flconsignacao = 'S'
where c.nuanomesreferencia = 202310 and c.cdtipofolhapagamento = 2 and cdtipocalculo = 1 group by c.cdvinculo

union

select v.cdvinculo, 0, sum(replace(trim(a.vlpagamento),'.',',')) from sigrhmig.emigcontrachequecsv_202310 a
inner join emigmatricula m on m.numatriculalegado = a.numatriculalegado
inner join ecadvinculo v on v.numatricula = m.numatricula and v.nuseqmatricula = m.nuseqmatricula
inner join epagrubrica r on r.nurubrica = a.nurubrica and r.cdtiporubrica = 5
inner join epagrubricaagrupamento ra on ra.cdrubrica = r.cdrubrica and cdagrupamento = 1 and ra.flconsignacao = 'S'
group by v.cdvinculo
)
group by cdvinculo having abs(sum(sigrh) - sum(legado)) > 1
)