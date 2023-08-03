select
a.sgagrupamento,
i.deitemcarreira as decarreira,
versao.nuversao,
vigencia.nuanoiniciovigencia || lpad(vigencia.numesiniciovigencia,2,0) as nuanomesiniciovigencia,
vigencia.nuanofimvigencia || lpad(vigencia.numesfimvigencia,2,0) as nuanomesfimvigencia,

case
 when trim(TRANSLATE(nunivelinicial, '0123456789 -,.', ' ')) is not null then faixa.nunivelinicial || lpad(faixa.nureferenciainicial,2,0)
 else lpad(faixa.nunivelinicial,2,0) || faixa.nureferenciainicial
end as nunivelrefinicial,
case
 when trim(TRANSLATE(nunivelinicial, '0123456789 -,.', ' ')) is not null then faixa.nunivelfinal || lpad(faixa.nureferenciafinal,2,0)
 else lpad(faixa.nunivelfinal,2,0) || faixa.nureferenciafinal
end as nunivelreffinal

from epaghistnivelrefcarrcefagrup faixa
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
inner join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrupversao = vigencia.cdnivelrefcefagrupversao
inner join epagnivelrefcefagrup tabvl on tabvl.cdnivelrefcefagrup = versao.cdnivelrefcefagrup

inner join ecadagrupamento a on a.cdagrupamento = tabvl.cdagrupamento
left join ecadestruturacarreira e on e.cdestruturacarreira = tabvl.cdestruturacarreira
left join ecaditemcarreira i on i.cdagrupamento = tabvl.cdagrupamento
                            and i.cdtipoitemcarreira = 1
                            and i.cditemcarreira = e.cditemcarreira
;