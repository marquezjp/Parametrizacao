select
a.sgagrupamento,
o.sgorgao,
versao.nuversao,
vigencia.nuanoiniciovigencia || lpad(vigencia.numesiniciovigencia,2,0) as nuanomesiniciovigencia,
vigencia.nuanofimvigencia || lpad(vigencia.numesfimvigencia,2,0) as nuanomesfimvigencia,
valor.nucodigo,
valor.nunivel,
upper(reltrab.nmrelacaotrabalho) as nmrelacaotrabalho,
valor.decodigonivel,
valor.vlfixo

from epagvalorrefccoagruporgespec valor
inner join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = valor.cdrelacaotrabalho
inner join epaghistvalorrefccoagruporgver vigencia on vigencia.cdhistvalorrefccoagruporgver = valor.cdhistvalorrefccoagruporgver
inner join epagvalorrefccoagruporgversao versao on versao.cdvalorrefccoagruporgversao = vigencia.cdvalorrefccoagruporgversao
inner join ecadagrupamento a on a.cdagrupamento = versao.cdagrupamento
left join vcadorgao o on o.cdorgao = versao.cdorgao
;

