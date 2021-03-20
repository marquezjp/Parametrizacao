define dataRef = sysdat
define dataRef = TO_DATE('17/03/2015')
define anoMesRef = extract(year from &dataRef) || lpad(extract(month from &dataRef), 2, 0);

select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,

 --- Nivel Referencia Carreira --
 estrutura.carreira,
 estrutura.item_da_carreira,
 estrutura.tipo_do_item_de_carreira,

 --- Versao ---
 versaonivelref.nuversao as versao_nivel_referencia,

 --- Historico Nivel Referencia --
 histref.nuanoiniciovigencia || lpad(histref.numesiniciovigencia, 2, 0) as ano_mes_inicio_vig_nivel_ref,
 histref.nuanofimvigencia || lpad(histref.numesfimvigencia, 2, 0) as ano_mes_fim_vig_nivel_ref,

 --- Tabela de Valores --
 tabelavlr.nmtabelavalorgeralcef as tabela_valores,

 --- Versao da Tabela de Valores ---
 versaotabvlr.nuversao as versao_tabela_valores,

 --- Historico dos Valores ---
 lpad(histvlr.nuanoiniciovigencia, 4, 0) || lpad(histvlr.numesiniciovigencia, 2, 0) as ano_mes_inicio_vig_tab_valores,
 lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) as ano_mes_fim_vig_tab_valores,

 --- Valores ---
 tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
 valor.vlfixo as valor_referencia,
 
 --- Codigo da Estrutura Carreira e Item ---
 estrutura.codigo_estrutura_carreira,
 estrutura.codigo_item_carreira

from epagvalorespeccefagrup valor
left join epaghistvalorgeralcefagrup histvlr on histvlr.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
left join epagvalorgeralcefagrupversao versaotabvlr on versaotabvlr.cdvalorgeralcefagrupversao = histvlr.cdvalorgeralcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = versaotabvlr.cdvalorgeralcefagrup
left join epaghistnivelrefcefagrup histref on histref.cdvalorgeralcefagrup = tabelavlr.cdvalorgeralcefagrup
left join epagnivelrefcefagrupversao versaonivelref on versaonivelref.cdnivelrefcefagrupversao = histref.cdnivelrefcefagrupversao
left join epagnivelrefcefagrup nivelref on nivelref.cdnivelrefcefagrup = versaonivelref.cdnivelrefcefagrup
left join epaghistnivelrefcarrcefagrup histcarreira on histcarreira.cdhistnivelrefcefagrup = histref.cdhistnivelrefcefagrup
left join ecadagrupamento agrup on agrup.cdagrupamento = tabelavlr.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

left join (
 select
  NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
  NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
  NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
  NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira,
  NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '') as item_da_carreira,
  tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,
  estrnv1.cdestruturacarreira as codigo_estrutura_carreira,
  estr.cditemcarreira as codigo_item_carreira
 from ecadestruturacarreira estr
 left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira
 left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
 left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
 left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira
 left join ecadtipoitemcarreira tpitemnv1 on tpitemnv1.cdtipoitemcarreira = itemnv1.cdtipoitemcarreira
 left join ecadestruturacarreira estrnv2 on estrnv2.cdestruturacarreira = estrnv1.cdestruturacarreirapai
 left join ecaditemcarreira itemnv2 on itemnv2.cditemcarreira = estrnv2.cditemcarreira
 left join ecadtipoitemcarreira tpitemnv2 on tpitemnv2.cdtipoitemcarreira = itemnv2.cdtipoitemcarreira
 left join ecadestruturacarreira estrnv3 on estrnv3.cdestruturacarreira = estrnv2.cdestruturacarreirapai
 left join ecaditemcarreira itemnv3 on itemnv3.cditemcarreira = estrnv3.cditemcarreira
 left join ecadtipoitemcarreira tpitemnv3 on tpitemnv3.cdtipoitemcarreira = itemnv3.cdtipoitemcarreira
 left join ecadestruturacarreira estrnv4 on estrnv4.cdestruturacarreira = estrnv3.cdestruturacarreirapai
 left join ecaditemcarreira itemnv4 on itemnv4.cditemcarreira = estrnv4.cditemcarreira
 left join ecadtipoitemcarreira tpitemnv4 on tpitemnv4.cdtipoitemcarreira = itemnv4.cdtipoitemcarreira
) estrutura on estrutura.codigo_estrutura_carreira = nivelref.cdestruturacarreira

where tabelavlr.fldesativada = 'N'
  and lpad(histvlr.nuanoiniciovigencia, 4, 0) || lpad(histvlr.numesiniciovigencia, 2, 0) < &anoMesRef
  and (   lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) is null
       or lpad(histvlr.nuanofimvigencia, 4, 0) || lpad(histvlr.numesfimvigencia, 2, 0) > &anoMesRef)

order by 
 poder.sgpoder,
 agrup.sgagrupamento,
 estrutura.carreira,
 estrutura.item_da_carreira,
 estrutura.tipo_do_item_de_carreira,
 versaonivelref.nuversao,
 tabelavlr.nmtabelavalorgeralcef,
 versaotabvlr.nuversao,
 tabelavlr.sgtabelavalorgeralcef,
 histvlr.nuanoiniciovigencia,
 histvlr.numesiniciovigencia,
 valor.nunivel,
 valor.nureferencia