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

 o.nuddd as nudddorgao,
 o.nutelefone as nutelefoneorgao,
 o.nuramal as nuramalorgao,
 o.nudddfax as nudddfaxorgao,
 o.nufax as nufaxorgao,
 o.nuramalfax as nuramalfaxorgao,

 endorgao.nucep as nuceporgao,
 endorgao.nmtipologradouro as nmtipologradouroorgao,
 endorgao.nmlogradouro as nmlogradouroorgao,
 endorgao.nunumero as nunumeroorgao,
 endorgao.decomplemento as decomplementoorgao,
 endorgao.nmunidade as nmunidadeorgao,
 endorgao.nucaixapostal as nucaixapostalorgao,
 endorgao.nmbairro as nmbairroorgao,
 endorgao.nmlocalidade as nmlocalidadeorgao,
 endorgao.sgestado as sgestadoorgao,
 endorgao.cdibge as cdibgeorgao,
 
 o.dtiniciovigencia as dtiniciovigenciaorgao,
 --o.dtfimvigencia as dtfimvigenciaorgao,
 
 huo.sgunidadeorganizacional,
 huo.nmunidadeorganizacional,

 huo.nuinep,

 tpuo.nmtipounidorg,
 tpuo.flensino,
 tpuo.flescola,
 
 huo.cdlotacaosirh,
 huosup.sgunidadeorganizacional as sguosuperior,
 huosup.nmunidadeorganizacional as nmuosuperior,

 huo.nucargahoraria,
 tpch.nmtipocargahoraria,

 huo.nuddd as nuddduo,
 huo.nutelefone as nutelefoneuo,
 huo.nuramal as nuramaluo,
 huo.nudddfax as nudddfaxuo,
 huo.nufax as nufaxuo,
 huo.nuramalfax as nuramalfaxuo,

 enduo.nucep as nucepuo,
 enduo.nmtipologradouro as nmtipologradourouo,
 enduo.nmlogradouro as nmlogradourouo,
 enduo.nunumero as nunumerouo,
 enduo.decomplemento as decomplementouo,
 enduo.nmunidade as nmunidadeuo,
 enduo.nucaixapostal as nucaixapostaluo,
 enduo.nmbairro as nmbairrouo,
 enduo.nmlocalidade as nmlocalidadeuo,
 enduo.sgestado as sgestadouo,
 enduo.cdibge as cdibgeuo,
 
 huo.dtiniciovigencia as dtiniciovigenciauo
 --huo.dtfimvigencia as dtfimvigenciauo,

from ecadhistunidadeorganizacional huo
left join ecadunidadeorganizacional uo on uo.cdunidadeorganizacional = huo.cdunidadeorganizacional
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = huo.cdtipocargahoraria
left join ecadtipounidorg tpuo on tpuo.cdtipounidorg = huo.cdtipounidorg
left join ecadhistunidadeorganizacional huosup on huosup.cdunidadeorganizacional = huo.cduosuphierarq and huosup.dtfimvigencia is null
left join (select e.nucep, tpl.nmtipologradouro, e.nmlogradouro, e.nunumero, e.decomplemento, e.nmunidade, e.nucaixapostal,
                  b.nmbairro, l.nmlocalidade,  l.sgestado, l.cdibge, e.cdendereco
           from ecadendereco e
           left join ecadtipologradouro tpl on tpl.cdtipologradouro = e.cdtipologradouro
           left join ecadbairro b on b.cdbairro = e.cdbairro
           left join ecadlocalidade l on l.cdlocalidade = e.cdlocalidade) enduo on enduo.cdendereco = huo.cdendereco

left join ecadhistorgao o on o.cdorgao = huo.cdorgao
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
           ) endorgao on endorgao.cdendereco = o.cdendereco

where huo.dtfimvigencia is null
  and o.dtfimvigencia is null
  and o.flanulado = 'N'