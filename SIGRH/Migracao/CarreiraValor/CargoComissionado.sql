select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 --upper(poder.nmpoder) as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 --upper(agrup.nmagrupamento) as agrupamento_de_orgao,
 
 --- Cargo Comissionado ---
 grcco.nmgrupoocupacional as grupo_ocupacional_cco,
 trim(cco.decargocomissionado) as cargo_comissionado_cco,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho_cco,

 cco.dtiniciovigencia as data_inicio_vigencia_cco,
 cco.dtfimvigencia as data_fim_vigencia_cco,

 --- Parametros Cargo Comissionado ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria_cco,
 cbo.nuocupacao as codigo_ocupacao_cco,
 upper(cbo.deocupacao) as descricao_ocupacao_cco,
 acmvn.nmacumvinculo as acumulacao_vinculos_cco,
 cco.flpermanente as reservada_cargo_permanente_cco,
 cco.flregistro as necessidade_reg_prof_cco,
 cco.flhabilitacao as necessidade_habilitacao_cco,
 cco.flsubstituicao as permite_substituicao_cco,
 cco.flsubstituto as subst_hierarq_superior_cco,
 cco.flestritamentepolicial as ativ_estritamente_policial_cco,
 cco.flaumentocarga as permite_aumento_carga_hor_cco,
 upper(qlp.nmdescricaoqlp) as quadro_de_cargos_cco,
 upper(reltrabqlp.nmrelacaotrabalho) as rel_trab_quadro_cargos_cco,
 
 cco.cdcargocomissionado,
 reltrabcco.cdrelacaotrabalho
 
from ecadevolucaocargocomissionado cco
left join ecadevolucaoccoreltrab reltrabcco on reltrabcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional

--- Agrupamento ---
left join ecadagrupamento agrup on agrup.cdagrupamento = grcco.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

--- Dominios ---
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = cco.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = cco.cdacumvinculo
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = cco.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlp on reltrabqlp.cdrelacaotrabalho = qlp.cdrelacaotrabalho
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

where cco.flanulado = 'N'

order by 
 poder.sgpoder,
 agrup.sgagrupamento,
 grcco.nmgrupoocupacional,
 trim(cco.decargocomissionado),
 upper(reltrab.nmrelacaotrabalho),
 cco.dtiniciovigencia,
 cco.dtfimvigencia
