select * from (
select decarreira,
sum(igual) as igual,
sum(diff) as diff
from (
select * from (
select sgorgao, decarreira, nunivel, nureferencia, valor, count(1) as qtde from (
select
o.sgorgao,
lpad(m.numatriculalegado,9,0) as numatriculalegado,
lpad(v.numatricula,7,0) || '-' || lpad(v.nudvmatricula,1,0) || '-' || lpad(v.nuseqmatricula,2,0) as numatricula,
lpad(p.nucpf, 11, 0) as nucpf, p.nmpessoa, to_char(v.dtadmissao, 'DD/MM/YYYY') as dtadmissao, to_char(v.dtdesligamento, 'DD/MM/YYYY') as dtdesligamento,
reltrab.nmrelacaotrabalho,
carreira.deitemcarreira as decarreira, cargo.deitemcarreira as decargo,
capa.nunivelcef as nunivel, capa.nureferenciacef as nureferencia,
pag.vlpagamento as vlfixo,
valor.vlfixo as vlnivref,
case when pag.vlpagamento = valor.vlfixo then 'OK' else 'NOK' end as valor
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join epagtipofolhapagamento tf on tf.cdtipofolhapagamento = f.cdtipofolhapagamento
                                    and f.nuanoreferencia = 2023 and f.numesreferencia = 07
                                    and f.nusequencialfolha = 1
left join epaghistoricorubricavinculo pag on pag.cdfolhapagamento = capa.cdfolhapagamento
                                          and pag.cdvinculo = capa.cdvinculo
                                          and pag.cdrubricaagrupamento in (select cdrubricaagrupamento from vpagrubricaagrupamento
                                                                           where cdagrupamento = 1 and cdtiporubrica = 1
                                                                             and nurubrica in (0001, 0181, 0524))
inner join epagtipocalculo tc on tc.cdtipocalculo = f.cdtipocalculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadvinculo v on v.cdvinculo = capa.cdvinculo
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join emigmatricula m on m.numatricula = v.numatricula and m.nuseqmatricula = v.nuseqmatricula
left join ecadestruturacarreira estcargo on estcargo.cdestruturacarreira = capa.cdestruturacarreira
left join ecaditemcarreira cargo on cargo.cditemcarreira = estcargo.cditemcarreira
left join ecadestruturacarreira estcarreira on estcarreira.cdestruturacarreira = estcargo.cdestruturacarreirapai
left join ecaditemcarreira carreira on carreira.cditemcarreira = estcarreira.cditemcarreira
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = capa.cdrelacaotrabalho

left join epagnivelrefcefagrup tabvl on tabvl.cdagrupamento = estcarreira.cdagrupamento and tabvl.cdestruturacarreira = estcarreira.cdestruturacarreira
left join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrup = tabvl.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup vigencia on vigencia.cdnivelrefcefagrupversao = versao.cdnivelrefcefagrupversao
left join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcefagrup = vigencia.cdhistnivelrefcefagrup
left join epagvalorcarreiracefagrup valor on valor.cdhistnivelrefcarrcefagrup = faixa.cdhistnivelrefcarrcefagrup
                                         and valor.nunivel = capa.nunivelcef and valor.nureferencia = capa.nureferenciacef
--where pag.vlpagamento != valor.vlfixo
where o.cdagrupamento = 1
  and carreira.deitemcarreira is not null
) group by sgorgao, decarreira, nunivel, nureferencia, valor
)
pivot (sum(Qtde) for valor in ('OK' as Igual, 'NOK' as Diff))
) group by decarreira
)
where Diff is not null and Igual is null
order by decarreira