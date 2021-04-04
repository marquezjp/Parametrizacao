select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 upper(poder.nmpoder) as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 upper(agrup.nmagrupamento) as agrupamento_de_orgao,

 --- Cargo Comissionado ---
 grcco.nmgrupoocupacional as grupo_ocupacional,
 cco.decargocomissionado as cargo_comissionado,
 vlrefcco.decodigonivel as descricao,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho,

 cco.dtiniciovigencia as data_inicio_vigencia,
 cco.dtfimvigencia as data_fim_vigencia,
 lpad(refcco.nucodigo, 4, 0) || lpad(refcco.nureferencia, 3, 0) as codigo_nivel,

 lpad(hvlrefcco.nuanoiniciovigencia, 4, 0) || lpad(hvlrefcco.numesiniciovigencia, 2, 0) as anomes_inicio_vigencia,
 lpad(hvlrefcco.nuanofimvigencia, 4, 0) || lpad(hvlrefcco.numesfimvigencia, 2, 0) as anomes_inicio_vigencia,
 vlrefcco.vlfixo as valor,

 --- Parametros Cargo Comissionado ---
 upper(tpch.nmtipocargahoraria) as tipo_da_carga_horaria,
 cbo.nuocupacao as codigo_ocupacao,
 upper(cbo.deocupacao) as descricao_ocupacao,
 acmvn.nmacumvinculo as atributo_acumulacao_vinculos,
 cco.flpermanente as reservada_cargo_permanente,
 cco.flregistro as necessidade_reg_profissional,
 cco.flhabilitacao as necessidade_habilitacao,
 cco.flsubstituicao as permite_substituicao,
 cco.flsubstituto as subst_hierarq_igual_superior,
 cco.flestritamentepolicial as ativ_estritamente_policial,
 cco.flaumentocarga as permite_aumento_carga_horaria,
 refcco.flnovanomeacao as permite_novas_nomecoes,
 upper(qlp.nmdescricaoqlp) as quadro_de_cargos,
 upper(reltrabqlp.nmrelacaotrabalho) as relacao_trabalho_quadro_cargos,
 vlrefcco.deexpressaocalculo as expressao_calculo,
 vlrefcco.cdvalorreferencia as sigla_valor_referencia,
 vlrefcco.vlgratificacao as valor_gratificacao,
 vlrefcco.cdpadraofucagrup as padrao_funcao,
 
 cco.cdcargocomissionado,
 refcco.nucodigo,
 refcco.nureferencia,
 reltrabcco.cdrelacaotrabalho
 
from ecadevolucaocargocomissionado cco
left join ecadevolucaoccoreltrab reltrabcco on reltrabcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join ecadcargocomissionado cadcco on cadcco.cdcargocomissionado = cco.cdcargocomissionado
left join ecadgrupoocupacional grcco on grcco.cdgrupoocupacional = cadcco.cdgrupoocupacional

left join ecadevolucaoccovalorref refcco on refcco.cdevolucaocargocomissionado = cco.cdevolucaocargocomissionado
left join epagvalorrefccoagruporgespec vlrefcco on vlrefcco.nucodigo = refcco.nucodigo
                                               and vlrefcco.nunivel = refcco.nureferencia
                                               and vlrefcco.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

left join epaghistvalorrefccoagruporgver hvlrefcco on hvlrefcco.cdhistvalorrefccoagruporgver = vlrefcco.cdhistvalorrefccoagruporgver
left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao

--- Dominios ---
left join ecadtipocargahoraria tpch on tpch.cdtipocargahoraria = cco.cdtipocargahoraria
left join ecadocupacao cbo on cbo.cdocupacao = cco.cdocupacao
left join ecadacumvinculo acmvn on acmvn.cdacumvinculo = cco.cdacumvinculo
left join emovdescricaoqlp qlp on qlp.cddescricaoqlp = cco.cddescricaoqlp
left join ecadrelacaotrabalho reltrabqlp on reltrabqlp.cdrelacaotrabalho = qlp.cdrelacaotrabalho
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = reltrabcco.cdrelacaotrabalho

--- Agrupamento ---
left join ecadagrupamento agrup on agrup.cdagrupamento = grcco.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

where cco.flanulado = 'N'

order by
 poder.sgpoder,
 agrup.sgagrupamento,
 grcco.nmgrupoocupacional,
 cco.decargocomissionado,
 vlrefcco.nucodigo,
 vlrefcco.nunivel