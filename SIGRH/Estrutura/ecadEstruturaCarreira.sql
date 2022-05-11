select
 --- Item da Estrutura de Carreira ---
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
 evlestr.flmagisterio as carreira_magisterio

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

--- Item da Estrutura de Carreira ---
left join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira
left join ecadtipoitemcarreira tpitemnv1 on tpitemnv1.cdtipoitemcarreira = itemnv1.cdtipoitemcarreira

where estr.cdestruturacarreirapai in (select pai.cdestruturacarreira from ecadestruturacarreira pai
                                      inner join ecaditemcarreira i on i.cditemcarreira = pai.cditemcarreira
                                                                   and i.cdtipoitemcarreira = 1
                                                                   and i.deitemcarreira like 'PRESTADORES DE SERVICOS')

order by
  1,
  2,
  evlestr.dtiniciovigencia