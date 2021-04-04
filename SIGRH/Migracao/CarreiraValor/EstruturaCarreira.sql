select
 --- Agrupamento ---
 pd.sgpoder as sigla_do_poder,
 pd.nmpoder as poder,
 a.sgagrupamento as sigla_agrupamento_de_orgao,
 a.nmagrupamento as agrupamento_de_orgao,
 
 --- Item da Estrutura de Carreira ---
 NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
 NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
 NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
 NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira,
 NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '' ) as item_da_carreira,
 tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,
 evlestr.dtiniciovigencia as inicio_vigencia,
 
 --- Parametros Item da Estrutura de Carreira ---
 tpch.nmtipocargahoraria as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 cbo.deocupacao as descricao_ocupacao,
 cbofml.nufamiliaocupacao as numero_famalia_cbo,
 cbofml.defamiliaocupacao as descricao_famalia_cbo,
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,
 evlestr.flregistroprofissional as registro_profissional,
 grninst.nmgrauinstrucao as grau_instrucao,
 evlestr.nucnpjsindicato as cnpj_sindicato_categoria,
 evlestr.nutempoexp as tempo_experiencia_cargo,
 evlestr.flhabilitacao as necessidade_habilitacao,
 evlestr.flpaga as paga_diferenca_substituicao,
 evlestr.flavancanivrefapo as avancar_nivref_aposentar,
 evlestr.flmagisterio as carreira_magisterio,

 --- Quadro de Cargos ---
 qlp.nmdescricaoqlp as quadro_cargos,
 reltrab.nmrelacaotrabalho as relacao_trabalho_quadro_cargos,

 --- Tabela de Valores ---
 tabelavlr.nmtabelavalorgeralcef as tabela_valores,
 tabelavlr.sgtabelavalorgeralcef as sigla_tabela_valores,
 versaonivelref.nuversao as versao_tabela_valores,
 histref.nuanoiniciovigencia || lpad(histref.numesiniciovigencia, 2, 0) as ano_mes_inicio_vig_tab_valores,
 histref.nuanofimvigencia || lpad(histref.numesfimvigencia, 2, 0) as ano_mes_fim_vig_tab_valores

 --estr.cditemcarreira as codigo_item_carreira

from ecadestruturacarreira estr
left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

--- Dominios ---
left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
left join ecadevolucaoestruturacarreira evlestr on evlestr.cdestruturacarreira = estr.cdestruturacarreira
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = evlestr.cdacumvinculo
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = evlestr.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = evlestr.cdocupacao
left join ecadfamiliaocupacao cbofml on cbofml.cdfamiliaocupacao = cbo.cdfamiliaocupacao
left join ecadgrauinstrucao grninst on grninst.cdgrauinstrucao = evlestr.cdgrauinstrucao
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = estr.cddescricaoqlp
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = qlp.cdrelacaotrabalho

--- Agrupamento ---
left join ecadagrupamento a on a.cdagrupamento = estr.cdagrupamento
left join ecadpoder pd on pd.cdpoder = a.cdpoder

--- Item da Estrutura de Carreira ---
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

--- Tabela de Valores --- 
left join epagnivelrefcefagrup nivelref on nivelref.cdestruturacarreira
                                         = NVL(NVL(NVL(NVL(NVL(estrnv4.cdestruturacarreirapai,
                                           estrnv4.cdestruturacarreira),
                                           estrnv3.cdestruturacarreira),
                                           estrnv2.cdestruturacarreira),
                                           estrnv1.cdestruturacarreira),
                                           estr.cdestruturacarreira)
left join epagnivelrefcefagrupversao versaonivelref on versaonivelref.cdnivelrefcefagrup = nivelref.cdnivelrefcefagrup
left join epaghistnivelrefcefagrup histref on histref.cdnivelrefcefagrupversao = versaonivelref.cdnivelrefcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = histref.cdvalorgeralcefagrup

--where evlestr.flavancanivrefapo is not null

order by
  pd.sgpoder,
  a.sgagrupamento,
  5,
  6,
  evlestr.dtiniciovigencia