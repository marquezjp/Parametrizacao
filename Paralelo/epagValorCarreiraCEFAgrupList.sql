with
carreira as (
select i.deitemcarreira, i.cdagrupamento, i.cdtipoitemcarreira, e.cdestruturacarreira
from ecadestruturacarreira e
inner join ecaditemcarreira i on i.cditemcarreira = e.cditemcarreira
),
salariofixo as (
select a.nmagrupamento,
versao.nuversao, vigencia.nuanoiniciovigencia, vigencia.numesiniciovigencia, vigencia.nuanofimvigencia, vigencia.numesfimvigencia,
c.deitemcarreira as  carreira,
case when carreira.cdestruturacarreira !=  tabela.cdestruturacarreira then cargotab.deitemcarreira else null end as cargo,
valor.nunivel, valor.nureferencia, valor.vlfixo, valor.deexpressao,
tabela.nunivelinicial, tabela.nureferenciainicial, tabela.nunivelfinal, tabela.nureferenciafinal,
tabela.flnivelnumerico, tabela.flreferencianumerica, --vigencia.flreferencianumerica,
tabela.nucargahorariapadrao, tabela.cdvalorgeralcefagrup
--carreira.cdagrupamento, carreira.cdnivelrefcefagrup, versao.cdNivelRefCEFAgrupVersao, vigencia.cdHistNivelRefCEFAgrup, tabela.cdHistNivelRefCarrCEFAgrup, valor.cdValorCarreiraCEFAgrup, carreira.cdestruturacarreira, tabela.cdestruturacarreira as cdestruturacarreiratabela
from epagValorCarreiraCEFAgrup valor
inner join epagHistNivelRefCarrCEFAgrup tabela on tabela.cdHistNivelRefCarrCEFAgrup = valor.cdHistNivelRefCarrCEFAgrup
inner join epagHistNivelRefCEFAgrup vigencia on vigencia.cdHistNivelRefCEFAgrup = tabela.cdHistNivelRefCEFAgrup
inner join epagNivelRefCEFAgrupVersao versao on versao.cdNivelRefCEFAgrupVersao = vigencia.cdNivelRefCEFAgrupVersao
inner join epagNivelRefCEFAgrup carreira on carreira.cdnivelrefcefagrup = versao.cdnivelrefcefagrup
inner join ecadagrupamento a on a.cdagrupamento = carreira.cdagrupamento
left join carreira c on c.cdestruturacarreira = carreira.cdestruturacarreira
left join carreira cargotab on cargotab.cdestruturacarreira = tabela.cdestruturacarreira
where carreira.cdagrupamento != 1
)

select * from salariofixo
order by nmagrupamento, nuversao, nuanoiniciovigencia, numesiniciovigencia, carreira, cargo, nunivel, nureferencia
--cdagrupamento, cdnivelrefcefagrup, cdNivelRefCEFAgrupVersao, cdHistNivelRefCEFAgrup, cdHistNivelRefCarrCEFAgrup, nunivel, nureferencia
;
