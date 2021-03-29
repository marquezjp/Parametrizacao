select --- Agrupamento ---
    poder.sgpoder as sigla_do_poder,
    --poder.nmpoder as poder,
    agrup.sgagrupamento as sigla_agrupamento_de_orgao,
    --agrup.nmagrupamento as agrupamento_de_orgao,
    --- Nivel Referencia Carreira --
    estrutura.carreira,
    estrutura.item_da_carreira,
    estrutura.tipo_do_item_de_carreira,
    --- Versao ---
    versao.nuversao,
    --- Historico Nivel Referencia --
    histref.nuanoiniciovigencia || lpad(histref.numesiniciovigencia, 2, 0) as nuanomesiniciovigencia,
    histref.nuanofimvigencia || lpad(histref.numesfimvigencia, 2, 0) as nuanomesfimvigencia,
    tabela.nmtabelavalorgeralcef as tabela_referencia,
    --- Historico Nivel Referencia Carreira CEF ---
    histcarreira.nucargahorariapadrao --histcarreira.nunivelinicial,
    --histcarreira.nureferenciainicial,
    --histcarreira.nunivelfinal,
    --histcarreira.nureferenciafinal
from epaghistnivelrefcarrcefagrup histcarreira
    left join epaghistnivelrefcefagrup histref on histref.cdhistnivelrefcefagrup = histcarreira.cdhistnivelrefcefagrup
    left join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrupversao = histref.cdnivelrefcefagrupversao
    left join epagnivelrefcefagrup nivelref on nivelref.cdnivelrefcefagrup = versao.cdnivelrefcefagrup
    left join epagvalorgeralcefagrup tabela on tabela.cdvalorgeralcefagrup = histref.cdvalorgeralcefagrup
    left join ecadagrupamento agrup on agrup.cdagrupamento = nivelref.cdagrupamento
    left join ecadpoder poder on poder.cdpoder = agrup.cdpoder
    left join (
        select NVL2(
                estrnv4.cdestruturacarreira,
                itemnv4.deitemcarreira || '/',
                ''
            ) || NVL2(
                estrnv3.cdestruturacarreira,
                itemnv3.deitemcarreira || '/',
                ''
            ) || NVL2(
                estrnv2.cdestruturacarreira,
                itemnv2.deitemcarreira || '/',
                ''
            ) || NVL2(
                estrnv1.cdestruturacarreira,
                itemnv1.deitemcarreira,
                item.deitemcarreira
            ) as carreira,
            NVL2(
                estr.cdestruturacarreirapai,
                item.deitemcarreira,
                ''
            ) as item_da_carreira,
            tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,
            estrnv1.cdestruturacarreira
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
    ) estrutura on estrutura.cdestruturacarreira = nivelref.cdestruturacarreira