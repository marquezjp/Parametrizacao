select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 poder.nmpoder as poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 agrup.nmagrupamento as agrupamento_de_orgao,
 
 --- Valor Referencia ---
 vlref.sgvalorreferencia as sigla_valor_referencia,
 vlref.nmvalorreferencia as valor_referencia,
 vlrefversao.nuversao as versao,

 hvlref.nuanoiniciovigencia || lpad(hvlref.numesiniciovigencia, 2, 0) as anomes_inicio_vigencia,
 hvlref.nuanofimvigencia || lpad(hvlref.numesfimvigencia, 2, 0) as anomes_fim_vigencia,
 hvlref.vlreferencia as valor,
 case hvlref.intiporeferencia
  when 'I' then 'Indice'
  when 'V' then 'Valor'
  else to_char(hvlref.intiporeferencia)
 end as tipo_referencia,
 hvlref.cdvalorgeralcefagrup as idicador_cargo_efetivo,
 hvlref.qtvalorreferencia as quantidade,
 lpad(hvlref.nunivel, 4, ' ') || lpad(hvlref.nureferencia, 3, 0) as nivel_referencia,
 hvlref.nupercentual as percentual_nivel_referencia

from epaghistvalorreferencia hvlref
left join epagvalorreferenciaversao vlrefversao on vlrefversao.cdvalorreferenciaversao = hvlref.cdvalorreferenciaversao
left join epagvalorreferencia vlref on vlref.cdvalorreferencia = vlrefversao.cdvalorreferencia

--- Agrupamento ---
left join ecadagrupamento agrup on agrup.cdagrupamento = vlref.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

order by 
 poder.sgpoder,
 agrup.sgagrupamento,
 vlref.sgvalorreferencia,
 vlrefversao.nuversao,
 hvlref.nuanoiniciovigencia,
 hvlref.numesiniciovigencia,
 hvlref.nuanofimvigencia