update epagvalorrefccoagruporgespec
 set vlfixo = vlfixo * 1.03
where cdhistvalorrefccoagruporgver = (select hvlrefcco.cdhistvalorrefccoagruporgver from epaghistvalorrefccoagruporgver hvlrefcco
                                      left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao
                                      where vervlrefcco.nuversao = 2
                                        and hvlrefcco.nuanoiniciovigencia = '2021'
                                        and hvlrefcco.numesiniciovigencia = '08'
                                        and hvlrefcco.nuanofimvigencia is null
                                        and hvlrefcco.numesfimvigencia is null)
  and nucodigo in ('CC01', 'CC04', 'CMCC');

select
 cdvalorrefccoagruporgespec,
 decodigonivel,
 nucodigo,
 nunivel,
 cdrelacaotrabalho,
 vlfixo
 
from epagvalorrefccoagruporgespec
where cdhistvalorrefccoagruporgver = (select hvlrefcco.cdhistvalorrefccoagruporgver from epaghistvalorrefccoagruporgver hvlrefcco
                                      left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao
                                      where vervlrefcco.nuversao = 2
                                        and hvlrefcco.nuanoiniciovigencia = '2021'
                                        and hvlrefcco.numesiniciovigencia = '08'
                                        and hvlrefcco.nuanofimvigencia is null
                                        and hvlrefcco.numesfimvigencia is null)
  and nucodigo in ('CC01', 'CC04', 'CMCC');