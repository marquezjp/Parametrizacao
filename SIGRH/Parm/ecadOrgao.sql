select 
 pd.sgpoder,
 pd.nmpoder,
 a.sgagrupamento,
 a.nmagrupamento,
 
 o.sgorgao,
 o.nmorgao,
 o.nucnpj,
 o.nuinscestadual,
 o.nuinscricaomunic,
 
 tpo.nmtipoorgao,
 tpo.cdnaturezajuridicarais,
 o.nucnpjfonterenda,
 o.cdorgaosirh,

 o.nuddd,
 o.nutelefone,
 o.nuramal,
 o.nudddfax,
 o.nufax,
 o.nuramalfax,

 end.nucep,
 end.nmtipologradouro,
 end.nmlogradouro,
 end.nunumero,
 end.decomplemento,
 end.nmunidade,
 end.nucaixapostal,
 end.nmbairro,
 end.nmlocalidade,
 end.sgestado,
 end.cdibge,
 
 o.dtiniciovigencia,
 --o.dtfimvigencia,

 o.cdhistorgao
 
from ecadhistorgao o
left join ecadorgao oc on oc.cdorgao = o.cdorgao
left join ecadagrupamento a on a.cdagrupamento = oc.cdagrupamento
left join ecadpoder pd on pd.cdpoder = a.cdpoder
left join ecadtipoorgao tpo on tpo.cdtipoorgao = o.cdtipoorgao

left join (select e.nucep, tplog.nmtipologradouro, e.nmlogradouro, e.nunumero, e.decomplemento, e.nmunidade, 
                  e.nucaixapostal, b.nmbairro, loc.nmlocalidade, loc.sgestado, loc.cdibge, e.cdendereco
           from ecadendereco e
           left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
           left join ecadbairro b on b.cdbairro = e.cdbairro
           left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
           ) end on end.cdendereco = o.cdendereco

where o.dtfimvigencia is null
  and o.flanulado = 'N'

order by o.nucnpj