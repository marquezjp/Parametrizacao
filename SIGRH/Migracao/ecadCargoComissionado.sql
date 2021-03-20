select
 pd.sgpoder as sigla_do_poder,
 pd.nmpoder as poder,
 a.sgagrupamento as sigla_agrupamento_de_orgao,
 a.nmagrupamento as agrupamento_de_orgao,
 
 gcc.nmgrupoocupacional as grupo_ocupacional,
 ecc.decargocomissionado as cargo_comissionado,
 tpch.nmtipocargahoraria as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 cbo.deocupacao as descricao_ocupacao,
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,
 qlp.nmdescricaoqlp as quadro_de_cargos,
 ecc.dtiniciovigencia as data_inicio_vigencia,
 ecc.dtfimvigencia as data_fim_vigencia

 --ecc.deobservacao, --null
 --ecc.deevolucao, --null
 --ecc.cddescricaoqlp,
 --ecc.cdconceitocarreira, --null
 --ecc.cdocupacao,
 --cc.cdgrupoocupacional,
 --ecc.cdgrauinstrucao, --null
 --ecc.cdtempoefeitocontagem, --null
 --ecc.cdtipocargahoraria,
 --ecc.cdacumvinculo,
 --ecc.cdgrupo, --null

 --ecc.vlreducaocarga, --null
 
 --ecc.flpermanente, -- 'N'
 --ecc.flregistro, -- 'N'
 --ecc.flhabilitacao, -- 'N'
 --ecc.flsubstituicao, -- 'N'
 --ecc.flsubstituto, -- 'N'
 --ecc.flestritamentepolicial, -- 'N'
 --ecc.flaumentocarga, -- 'N'
 --ecc.flanulado,
 --ecc.dtanulado,
 --ecc.dtextincao, --null

from ecadevolucaocargocomissionado ecc
left join ecadcargocomissionado cc on cc.cdcargocomissionado = ecc.cdcargocomissionado
left join ecadgrupoocupacional gcc on gcc.cdgrupoocupacional = cc.cdgrupoocupacional

left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = ecc.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = ecc.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = ecc.cdacumvinculo

left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = ecc.cddescricaoqlp

left join ecadagrupamento a on a.cdagrupamento = gcc.cdagrupamento
left join ecadpoder pd on pd.cdpoder = a.cdpoder

where ecc.flanulado = 'N'
