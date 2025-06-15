--- Listar os Valores das Tabelas Geral
select versao.cdvalorgeralcefagrupversao, vigencia.cdhistvalorgeralcefagrup, valor.cdvalorespeccefagrup,
versao.nuversao, vigencia.nuanoiniciovigencia, vigencia.numesiniciovigencia, vigencia.nuanofimvigencia, vigencia.numesfimvigencia,
vigencia.nunivelinicial, vigencia.nureferenciainicial, vigencia.nunivelfinal, vigencia.nureferenciafinal,
valor.nunivel, valor.nureferencia, valor.vlfixo, valor.deexpressao
from epagvalorespeccefagrup valor
inner join epaghistvalorgeralcefagrup vigencia on vigencia.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
inner join epagvalorgeralcefagrupversao versao on versao.cdvalorgeralcefagrupversao = vigencia.cdvalorgeralcefagrupversao
;
/