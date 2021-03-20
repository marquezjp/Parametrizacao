select --- Agrupamento ---
    poder.sgpoder as sigla_do_poder,
    poder.nmpoder as poder,
    agrup.sgagrupamento as sigla_agrupamento_de_orgao,
    agrup.nmagrupamento as agrupamento_de_orgao,
    --- Tabela de Valores --
    tabela.nmtabelavalorgeralcef as tabela_referencia,
    --- Versao da Tabela de Valores ---
    versao.nuversao as versao_tabela_referencia,
    --- Historico dos Valores ---
    lpad(hist.nuanoiniciovigencia, 4, 0) || lpad(hist.numesiniciovigencia, 2, 0) as ano_mes_inicio_vigencia,
    lpad(hist.nuanofimvigencia, 4, 0) || lpad(hist.numesfimvigencia, 2, 0) as ano_mes_fim_vigencia,
    --- Valores ---
    tabela.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
    valor.vlfixo as valor_referencia
from epagvalorespeccefagrup valor
    left join epaghistvalorgeralcefagrup hist on hist.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
    left join epagvalorgeralcefagrupversao versao on versao.cdvalorgeralcefagrupversao = hist.cdvalorgeralcefagrupversao
    left join epagvalorgeralcefagrup tabela on tabela.cdvalorgeralcefagrup = versao.cdvalorgeralcefagrup
    left join ecadagrupamento agrup on agrup.cdagrupamento = tabela.cdagrupamento
    left join ecadpoder poder on poder.cdpoder = agrup.cdpoder
where tabela.fldesativada = 'N'
    and (
        lpad(hist.nuanofimvigencia, 4, 0) || lpad(hist.numesfimvigencia, 2, 0) is null
        or lpad(hist.nuanofimvigencia, 4, 0) || lpad(hist.numesfimvigencia, 2, 0) > '202103'
    )
order by poder.sgpoder,
    agrup.sgagrupamento,
    tabela.nmtabelavalorgeralcef,
    versao.nuversao,
    tabela.sgtabelavalorgeralcef,
    valor.nunivel,
    valor.nureferencia