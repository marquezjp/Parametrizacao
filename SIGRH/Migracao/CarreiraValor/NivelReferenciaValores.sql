define dataRef = sysdat
define dataRef = TO_DATE('17/03/2015')
define anoMesRef = extract(year from &dataRef) || lpad(extract(month from &dataRef), 2, 0);

select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,

 --- Tabela de Valores --
 tabelavlr.nmtabelavalorgeralcef as tabela_valores,
 tabelavlr.sgtabelavalorgeralcef as sigla_tabela_valores,
 versaotabvlr.nuversao as versao_tabela_valores,
 lpad(histvlr.nuanoiniciovigencia, 4, 0) || lpad(histvlr.numesiniciovigencia, 2, 0) as ano_mes_inicio_vig_tab_valores,
 lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) as ano_mes_fim_vig_tab_valores,

 --- Nivel Referencia e Valores ---
 tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
 valor.vlfixo as valor_referencia
 
from epagvalorespeccefagrup valor
left join epaghistvalorgeralcefagrup histvlr on histvlr.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
left join epagvalorgeralcefagrupversao versaotabvlr on versaotabvlr.cdvalorgeralcefagrupversao = histvlr.cdvalorgeralcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = versaotabvlr.cdvalorgeralcefagrup
left join ecadagrupamento agrup on agrup.cdagrupamento = tabelavlr.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

where tabelavlr.fldesativada = 'N'
  --and lpad(histvlr.nuanoiniciovigencia, 4, 0) || lpad(histvlr.numesiniciovigencia, 2, 0) < &anoMesRef
  --and (   lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) is null
  --     or lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) > &anoMesRef)

order by 
 poder.sgpoder,
 agrup.sgagrupamento,
 tabelavlr.nmtabelavalorgeralcef,
 versaotabvlr.nuversao,
 tabelavlr.sgtabelavalorgeralcef,
 histvlr.nuanoiniciovigencia,
 histvlr.numesiniciovigencia,
 valor.nunivel,
 valor.nureferencia