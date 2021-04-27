define dataRef = sysdate
define dtfim = TO_DATE('01/04/2021')
define anoMesRef = extract(year from &dataRef) || lpad(extract(month from &dataRef), 2, 0)
;
select *
from (
select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 orgao.sgorgao as sigla_orgao,
 
 --- Valor do Padrao Funcao Chefia ---
 padraoefc.nmpadrao as padrao_tab_valor_fc,
 padraoefc.depadrao as descricao_padrao_tab_valor_fc,
 versaoefc.nuversao as versao_tab_valor_fc,
 lpad(histefc.nuanoiniciovigencia, 4, 0) || lpad(histefc.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tab_valor_fc,
 lpad(histefc.nuanofimvigencia, 4, 0) || lpad(histefc.numesfimvigencia, 2, 0) as anomes_fim_vig_tab_valor_fc,
 valorefc.vlfixo as valor_padrao_tab_valor_fc,
 valorefc.deexpressaocalculo as expressao_calculo_tab_valor_fc

--- Valor do Padrao Funcao Chefia --- 
from epagpadraofucagrup padraoefc
inner join epagvalorreffucagruporgespec valorefc on valorefc.cdpadraofucagrup = padraoefc.cdpadraofucagrup
inner join epaghistvalorreffucagruporg histefc on histefc.cdhistvalorreffucagruporg = valorefc.cdhistvalorreffucagruporg
inner join epagvalorreffucagruporgversao versaoefc on versaoefc.cdvalorreffucagruporgversao = histefc.cdvalorreffucagruporgversao
left join vcadorgao orgao on orgao.cdorgao = versaoefc.cdorgao
inner join ecadagrupamento agrup on agrup.cdagrupamento = versaoefc.cdagrupamento
inner join ecadpoder poder on poder.cdpoder = agrup.cdpoder

order by
 poder.sgpoder,
 agrup.sgagrupamento,
 orgao.sgorgao,
 padraoefc.nmpadrao,
 versaoefc.nuversao,
 histefc.nuanoiniciovigencia,
 histefc.numesiniciovigencia
) tab_valor_fc
where nvl(tab_valor_fc.anomes_inicio_vig_tab_valor_fc,&anoMesRef) <= nvl(extract(year from &dtfim) || lpad(extract(month from &dtfim), 2, 0),&anoMesRef)
  and nvl(tab_valor_fc.anomes_fim_vig_tab_valor_fc,&anoMesRef) >= nvl(extract(year from &dtfim) || lpad(extract(month from &dtfim), 2, 0),&anoMesRef)