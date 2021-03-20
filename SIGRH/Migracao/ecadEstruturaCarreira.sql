select
 --- Item da Estrutura de Carreira ---
 pd.sgpoder as sigla_do_poder,
 pd.nmpoder as poder,
 a.sgagrupamento as sigla_agrupamento_de_orgao,
 a.nmagrupamento as agrupamento_de_orgao,
 
 NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
 NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
 NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
 NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira,
 NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '' ) as item_da_carreira,
 tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,

 tpch.nmtipocargahoraria as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 cbo.deocupacao as descricao_ocupacao,
 
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,

 evlestr.flregistroprofissional as registro_profissional,

 grninst.nmgrauinstrucao,
 evlestr.cdgrupo,
 evlestr.cdcefabsorvervagas,
 evlestr.nucnpjsindicato,
 evlestr.nutempoexp,
 evlestr.flhabilitacao,
 evlestr.flpaga,
 evlestr.flevolucaocefregprev,
 evlestr.flevolucaocefregtrab,
 evlestr.flevolucaocefitemativ,
 evlestr.flevolucaocefreltrab,
 evlestr.flevolucaocefnatvinc,
 evlestr.flevolucaocefitemformacao,
 evlestr.flevolucaocefprereq,
 evlestr.flevolucaocefcargahoraria,
 evlestr.flavancanivrefapo,
 evlestr.flmagisterio,

 qlp.nmdescricaoqlp as quadro_de_cargos,
 evlestr.dtiniciovigencia as inicio_vigencia,

 estr.cditemcarreira as codigo_item_carreira


from ecadestruturacarreira estr

left join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
left join ecadevolucaoestruturacarreira evlestr on evlestr.cdestruturacarreira = estr.cdestruturacarreira
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = evlestr.cdacumvinculo
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = evlestr.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = evlestr.cdocupacao
left join ecadgrauinstrucao grninst on grninst.cdgrauinstrucao = evlestr.cdgrauinstrucao

left join ecadagrupamento a on a.cdagrupamento = estr.cdagrupamento
left join ecadpoder pd on pd.cdpoder = a.cdpoder

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

left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = estr.cddescricaoqlp

order by 1, 2