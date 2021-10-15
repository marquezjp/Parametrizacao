-- Listar as Carreira/Cargos habilitados em um Orgão

select
 oc.cdorgaocarreira,
 oc.cdorgao,
 oc.cdestruturacarreira,
 estrutura.carreira,
 estrutura.cargo,
 oc.dtiniciovigencia,
 oc.dtfimvigencia,
 oc.cdhistorgaorespanulacao,
 oc.flanulado,
 oc.dtultalteracao,
 oc.cdestruturacarreirausuario,
 oc.flutilizalpdigital
 
from ecadorgaocarreira oc

left join (
select
 e.cdestruturacarreira as cdestruturacarreira,
 nvl2(e.cdestruturacarreirapai, itemc.deitemcarreira, item.deitemcarreira) as carreira,
 nvl2(e.cdestruturacarreirapai, item.deitemcarreira, '') as cargo

from ecadestruturacarreira e
left join ecaditemcarreira item on item.cditemcarreira = e.cditemcarreira
left join ecadestruturacarreira ec on ec.cdestruturacarreira = e.cdestruturacarreirapai
left join ecaditemcarreira itemc on itemc.cditemcarreira = ec.cditemcarreira
) estrutura on estrutura.cdestruturacarreira = oc.cdestruturacarreira

where cdorgao in (select cdorgao from ecadhistorgao where sgorgao = 'SEMAS')

order by cdorgao, dtiniciovigencia, cdestruturacarreira;

-- Inserir Carreira/Cargos habilitados em um Orgão

insert into ecadorgaocarreira
(
 cdorgaocarreira,
 cdorgao,
 cdestruturacarreira,
 dtiniciovigencia,
 dtfimvigencia,
 cdhistorgaorespanulacao,
 flanulado,
 dtultalteracao,
 cdestruturacarreirausuario,
 flutilizalpdigital
)
select
 ROWNUM + (select max(cdorgaocarreira) from ecadorgaocarreira) as cdorgaocarreira,
 o.cdorgao as cdorgao,
 e.cdestruturacarreira as cdestruturacarreira,
 o.dtiniciovigencia as dtiniciovigencia,
 o.dtfimvigencia as dtfimvigencia,
 nvl2(o.dtfimvigencia, o.cdhistorgao, Null) as cdhistorgaorespanulacao,
 'N' as flanulado,
 o.dtultalteracao as dtultalteracao,
 e.cdestruturacarreira as cdestruturacarreirausuario,
 'N' as flutilizalpdigital
 
from ecadhistorgao o
left join (
select e.cdestruturacarreira from ecadestruturacarreira e
inner join ecaditemcarreira c on c.cditemcarreira = e.cditemcarreira

where c.cdtipoitemcarreira = 1 and c.deitemcarreira like 'CONTRATO TEMPORARIO - SEMAS%'

) e on e.cdestruturacarreira is not null

where sgorgao = 'SEMAS';
