select
 versao.nuversao,
 padrao.nmpadrao,
 padrao.depadrao,
 lpad(hist.nuanoiniciovigencia, 4, 0) || lpad(hist.numesiniciovigencia, 2, 0) as nuanomesiniciovigencia,
 lpad(hist.nuanofimvigencia, 4, 0) || lpad(hist.numesfimvigencia, 2, 0) as nuanomesfimvigencia,
 valor.vlfixo,
 valor.deexpressaocalculo
 
from epagpadraofucagrup padrao
left join epagvalorreffucagruporgespec valor on valor.cdpadraofucagrup = padrao.cdpadraofucagrup
left join epaghistvalorreffucagruporg hist on hist.cdhistvalorreffucagruporg = valor.cdhistvalorreffucagruporg
left join epagvalorreffucagruporgversao versao on versao.cdvalorreffucagruporgversao = hist.cdvalorreffucagruporgversao

--where lpad(hist.nuanofimvigencia, 4, 0) || lpad(hist.numesfimvigencia, 2, 0) is null

order by
 versao.nuversao,
 padrao.nmpadrao,
 hist.nuanoiniciovigencia,
 hist.numesiniciovigencia,
 hist.nuanofimvigencia,
 hist.numesfimvigencia
