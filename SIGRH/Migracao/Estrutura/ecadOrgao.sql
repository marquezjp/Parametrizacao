select 
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,
 
 -- Orgao ---
 orgao.sgorgao as sigla_do_orgao,
 orgao.nmorgao as nome_orgao,
 orgao.nucnpj as cnpj_orgao,
 orgao.nuinscestadual as inscricao_estadual_orgao,
 orgao.nuinscricaomunic as inscricao_municipal_orgao,
 tpo.nmtipoorgao as tipo_orgao,
 tpo.cdnaturezajuridicarais as natureza_juridica_rais,
 orgao.nucnpjfonterenda as cnpj_fonte_pagadora,
 orgao.cdorgaosirh as codigo_sirg_orgao,
 orgao.dtiniciovigencia as data_inicio_vigencia_orgao,
 --o.dtfimvigencia as dtfimvigenciaorgao,
 
 --- Telefone do Orgao ---
 orgao.nuddd as ddd_orgao,
 orgao.nutelefone as telefone_orgao,
 orgao.nuramal as ramal_orgao,
 orgao.nudddfax as ddd_fax_orgao,
 orgao.nufax as fax_orgao,
 orgao.nuramalfax as ramal_fax_orgao,

 --- Endereco do Orgao ---
 endorgao.nucep as cep_orgao,
 endorgao.nmtipologradouro as tipo_logradouro_end_orgao,
 endorgao.nmlogradouro as logradouro_endereco_orgao,
 endorgao.nunumero as numero_endreco_orgao,
 endorgao.decomplemento as complemento_endereco_orgao,
 endorgao.nmunidade as unidade_orgao,
 endorgao.nucaixapostal as caixa_postal_orgao,
 endorgao.nmbairro as bairro_endereco_orgao,
 endorgao.nmlocalidade as municipio_endereco_orgao,
 endorgao.sgestado as estado_endereco_orgao,
 endorgao.cdibge as codigo_ibge_endreco_orgao,
 
 orgao.dtiniciovigencia
 --orgao.dtfimvigencia

 --orgao.cdhistorgao
 
from ecadhistorgao orgao
left join ecadorgao oc on oc.cdorgao = orgao.cdorgao
left join ecadagrupamento agrup on agrup.cdagrupamento = oc.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder
left join ecadtipoorgao tpo on tpo.cdtipoorgao = orgao.cdtipoorgao

left join (select e.nucep, tplog.nmtipologradouro, e.nmlogradouro, e.nunumero, e.decomplemento, e.nmunidade, 
                  e.nucaixapostal, b.nmbairro, loc.nmlocalidade, loc.sgestado, loc.cdibge, e.cdendereco
           from ecadendereco e
           left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
           left join ecadbairro b on b.cdbairro = e.cdbairro
           left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
           ) endorgao on endorgao.cdendereco = orgao.cdendereco

where orgao.dtfimvigencia is null
  and orgao.flanulado = 'N'

order by orgao.nucnpj