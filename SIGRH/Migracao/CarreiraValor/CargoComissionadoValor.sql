select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 --upper(poder.nmpoder) as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 --upper(agrup.nmagrupamento) as agrupamento_de_orgao,

 --- Tabela de Valors Cargo Comissionado ---
 vlrefcco.decodigonivel as descricao,
 upper(reltrab.nmrelacaotrabalho) as relacao_trabalho,
 lpad(vlrefcco.nucodigo, 4, 0) || lpad(vlrefcco.nunivel, 3, 0) as codigo_nivel,

 vlrefcco.vlfixo as valor,
 vlrefcco.deexpressaocalculo as expressao_calculo,
 vlrefcco.cdvalorreferencia as sigla_valor_referencia,
 vlrefcco.vlgratificacao as valor_gratificacao,
 vlrefcco.cdpadraofucagrup as padrao_funcao,

 vervlrefcco.nuversao as versao_tabela_cco,
 lpad(hvlrefcco.nuanoiniciovigencia, 4, 0) || lpad(hvlrefcco.numesiniciovigencia, 2, 0) as anomes_inicio_vig_tb_vlr_cco,
 lpad(hvlrefcco.nuanofimvigencia, 4, 0)  || lpad(hvlrefcco.numesfimvigencia, 2, 0) as anomes_fim_vig_tb_vlr_cco

from epagvalorrefccoagruporgespec vlrefcco
left join epaghistvalorrefccoagruporgver hvlrefcco on hvlrefcco.cdhistvalorrefccoagruporgver = vlrefcco.cdhistvalorrefccoagruporgver
left join epagvalorrefccoagruporgversao vervlrefcco on vervlrefcco.cdvalorrefccoagruporgversao = hvlrefcco.cdvalorrefccoagruporgversao

--- Dominios ---
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = vlrefcco.cdrelacaotrabalho

--- Agrupamento ---
left join ecadagrupamento agrup on agrup.cdagrupamento = vervlrefcco.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

order by
 poder.sgpoder,
 agrup.sgagrupamento,
 vlrefcco.nucodigo,
 vlrefcco.nunivel
