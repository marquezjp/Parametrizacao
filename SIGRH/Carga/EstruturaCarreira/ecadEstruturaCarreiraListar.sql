select
 e.cdestruturacarreira,
 e.cdestruturacarreirapai,
 e.cdestruturacarreiracarreira,
 e.cdestruturacarreiracargo,
 e.cditemcarreira,
 a.sgagrupamento,
 icar.deitemcarreira as decarreira,
 ic.deitemcarreira as decargo
from ecadestruturacarreira e 
left join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
left join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
left join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
left join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
order by
 a.sgagrupamento,
 icar.deitemcarreira,
 ic.deitemcarreira
;

select
 a.sgagrupamento as sigla_agrupamento_de_orgao,
 
 --- Item da Estrutura de Carreira ---
 NVL2(estrnv4.cdestruturacarreira, itemnv4.deitemcarreira || '/', '') ||
 NVL2(estrnv3.cdestruturacarreira, itemnv3.deitemcarreira || '/', '') ||
 NVL2(estrnv2.cdestruturacarreira, itemnv2.deitemcarreira || '/', '') ||
 NVL2(estrnv1.cdestruturacarreira, itemnv1.deitemcarreira, item.deitemcarreira) as carreira,
 NVL2(estr.cdestruturacarreirapai, item.deitemcarreira, '' ) as item_da_carreira,
 tpitem.nmtipoitemcarreira as tipo_do_item_de_carreira,
 evlestr.dtiniciovigencia as inicio_vigencia,
 evlestr.flmagisterio as carreira_magisterio,

 --- Quadro de Cargos ---
 qlp.nmdescricaoqlp as quadro_cargos,
 reltrab.nmrelacaotrabalho as relacao_trabalho_quadro_cargos

from ecadestruturacarreira estr
left join ecaditemcarreira item on item.cdagrupamento = estr.cdagrupamento and item.cditemcarreira = estr.cditemcarreira

--- Dominios ---
left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
left join ecadevolucaoestruturacarreira evlestr on evlestr.cdagrupamento = estr.cdagrupamento and evlestr.cdestruturacarreira = estr.cdestruturacarreira
left join emovdescricaoqlp qlp on qlp.cdagrupamento = estr.cdagrupamento and qlp.cddescricaoqlp = estr.cddescricaoqlp
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = qlp.cdrelacaotrabalho

--- Agrupamento ---
left join ecadagrupamento a on a.cdagrupamento = estr.cdagrupamento

--- Item da Estrutura de Carreira ---
left join ecadestruturacarreira estrnv1 on estrnv1.cdagrupamento = estr.cdagrupamento and estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
left join ecaditemcarreira itemnv1 on itemnv1.cdagrupamento = estr.cdagrupamento and itemnv1.cditemcarreira = estrnv1.cditemcarreira
left join ecadtipoitemcarreira tpitemnv1 on tpitemnv1.cdtipoitemcarreira = itemnv1.cdtipoitemcarreira

left join ecadestruturacarreira estrnv2 on estrnv2.cdagrupamento = estr.cdagrupamento and estrnv2.cdestruturacarreira = estrnv1.cdestruturacarreirapai
left join ecaditemcarreira itemnv2 on itemnv2.cdagrupamento = estr.cdagrupamento and itemnv2.cditemcarreira = estrnv2.cditemcarreira
left join ecadtipoitemcarreira tpitemnv2 on tpitemnv2.cdtipoitemcarreira = itemnv2.cdtipoitemcarreira

left join ecadestruturacarreira estrnv3 on estrnv3.cdagrupamento = estr.cdagrupamento and estrnv3.cdestruturacarreira = estrnv2.cdestruturacarreirapai
left join ecaditemcarreira itemnv3 on itemnv3.cdagrupamento = estr.cdagrupamento and itemnv3.cditemcarreira = estrnv3.cditemcarreira
left join ecadtipoitemcarreira tpitemnv3 on tpitemnv3.cdtipoitemcarreira = itemnv3.cdtipoitemcarreira

left join ecadestruturacarreira estrnv4 on estrnv4.cdagrupamento = estr.cdagrupamento and estrnv4.cdestruturacarreira = estrnv3.cdestruturacarreirapai
left join ecaditemcarreira itemnv4 on itemnv4.cdagrupamento = estr.cdagrupamento and itemnv4.cditemcarreira = estrnv4.cditemcarreira
left join ecadtipoitemcarreira tpitemnv4 on tpitemnv4.cdtipoitemcarreira = itemnv4.cdtipoitemcarreira

order by
  a.sgagrupamento,
  2,
  tpitem.nmtipoitemcarreira desc,
  3,
  evlestr.dtiniciovigencia