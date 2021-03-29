select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 --agrup.nmagrupamento as agrupamento_de_orgao,
 
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

 --- Unidade Organizacional ---
 uo.sgunidadeorganizacional as sigla_unidade_organizacional,
 uo.nmunidadeorganizacional as nome_unidade_organizacional,
 uo.nuinep as codigo_inep_unid_organiz,
 tpuo.nmtipounidorg as tipo_unidade_organizacional,
 tpuo.flensino as se_unidade_de_ensino,
 tpuo.flescola as se_unidade_escola,
 uo.cdlotacaosirh as codigo_lotacao_sirh,
 uosup.sgunidadeorganizacional as sigla_unid_organiza_superior,
 uosup.nmunidadeorganizacional as nome_unid_organiz_superior,
 uo.nucargahoraria as carga_horaria_unid_organizl,
 tpch.nmtipocargahoraria as tipo_carga_hor_unid_organiz,
 uo.dtiniciovigencia as data_inicio_vig_unid_organiz
 --uo.dtfimvigencia as data_fim_vig_unid_organiz,
 
 --- Telefone da Unidade Organizacional ---
 uo.nuddd as ddd_unidade_organizacional,
 uo.nutelefone as telefone_unid_organiz,
 uo.nuramal as ramal_unidade_organizacional,
 uo.nudddfax as ddd_fax_unidade_organizacional,
 uo.nufax as fax_unidade_organizacional,
 uo.nuramalfax as ramal_fax_unid_organiz,
 
 --- Endereco da Unidade Organizacional ---
 enduo.nucep as cep_endereco_unid_organiz,
 enduo.nmtipologradouro as tipo_logradouro_unid_organiz,
 enduo.nmlogradouro as logradouro_end_unid_organiz,
 enduo.nunumero as numero_endereco_unid_organiz,
 enduo.decomplemento as complemento_end_unid_organiz,
 enduo.nmunidade as unidade_endereco_unid_organiz,
 enduo.nucaixapostal as caixa_postal_unid_organiz,
 enduo.nmbairro as bairro_endereco_unid_organiz,
 enduo.nmlocalidade as municipio_end_unid_organiz,
 enduo.sgestado as estado_endereco_unid_organiz,
 enduo.cdibge as codigo_ibge_end_unid_organiz,

from ecadhistunidadeorganizacional uo
left join ecadunidadeorganizacional caduo on caduo.cdunidadeorganizacional = uo.cdunidadeorganizacional

left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = uo.cdtipocargahoraria
left join ecadtipounidorg tpuo on tpuo.cdtipounidorg = uo.cdtipounidorg

left join ecadhistunidadeorganizacional uosup on uosup.cdunidadeorganizacional = uo.cduosuphierarq and uosup.dtfimvigencia is null

left join (
  select
   e.nucep,
   tpl.nmtipologradouro,
   e.nmlogradouro,
   e.nunumero,
   e.decomplemento,
   e.nmunidade,
   e.nucaixapostal,
   b.nmbairro,
   l.nmlocalidade,
   l.sgestado,
   l.cdibge,
   e.cdendereco
  from ecadendereco e
  left join ecadtipologradouro tpl on tpl.cdtipologradouro = e.cdtipologradouro
  left join ecadbairro b on b.cdbairro = e.cdbairro
  left join ecadlocalidade l on l.cdlocalidade = e.cdlocalidade
) enduo on enduo.cdendereco = uo.cdendereco

left join ecadhistorgao orgao on orgao.cdorgao = uo.cdorgao
left join ecadorgao cadorg on cadorg.cdorgao = orgao.cdorgao

left join ecadagrupamento agrup on agrup.cdagrupamento = cadorg.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

left join ecadtipoorgao tpo on tpo.cdtipoorgao = orgao.cdtipoorgao

left join (
  select 
   e.nucep,
   tplog.nmtipologradouro,
   e.nmlogradouro,
   e.nunumero,
   e.decomplemento,
   e.nmunidade,
   e.nucaixapostal,
   b.nmbairro,
   loc.nmlocalidade,
   loc.sgestado,
   loc.cdibge,
   e.cdendereco
  from ecadendereco e
  left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
  left join ecadbairro b on b.cdbairro = e.cdbairro
  left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade
) endorgao on endorgao.cdendereco = orgao.cdendereco

where uo.dtfimvigencia is null
  and orgao.dtfimvigencia is null
  and orgao.flanulado = 'N'