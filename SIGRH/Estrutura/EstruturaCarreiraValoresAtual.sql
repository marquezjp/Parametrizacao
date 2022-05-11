select
 tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
 valor.vlfixo as valor_referencia
 
from epagvalorespeccefagrup valor
left join epaghistvalorgeralcefagrup histvlr on histvlr.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
left join epagvalorgeralcefagrupversao versaotabvlr on versaotabvlr.cdvalorgeralcefagrupversao = histvlr.cdvalorgeralcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = versaotabvlr.cdvalorgeralcefagrup

where tabelavlr.fldesativada = 'N'
  and tabelavlr.cdagrupamento = 1
  and versaotabvlr.nuversao = 1
  and histvlr.nuanofimvigencia is null

order by tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0)
