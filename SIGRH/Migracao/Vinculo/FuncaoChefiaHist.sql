select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 o.sgorgao,

 --- Vinculo ---
 lpad(v.numatricula, 7, 0) || '-' || v.nudvmatricula as matricula,
 lpad(p.nucpf, 11, 0) as cpf,
 p.nmpessoa,
 
 --- Funcao Chefia ---
 evolucao.nmfuncaochefia,
 evolucao.deevolucao,
 
 fc.dtinicio,
 fc.dtfim,
 fc.dtfimprevista,
 fc.qtdias,

 --- Propriedades ---
 fc.cdrelacaotrabalho,
 fc.cdregimetrabalho,
 fc.cdnaturezavinculo,
 fc.cdsituacaoprevidenciaria,
 fc.cdregimeprevidenciario,
 
 fc.cdhistcargoefetivoorigem,
 fc.cdfuncaochefia,
 fc.cdtipoocupacaouo,
 fc.cdtipocargahoraria,
 
 fc.flefetivacao,
 fc.flocupacao
 
from ecadhistfuncaochefia fc
left join ecadvinculo v on v.cdvinculo = fc.cdvinculo
left join ecadpessoa p on p.cdpessoa = v.cdpessoa
left join vcadorgao o on o.cdorgao = v.cdorgao

left join ecadevolucaofuncaochefia evolucao on evolucao.cdfuncaochefia = fc.cdfuncaochefia

left join ecadfuncaochefia tpfc on tpfc.cdfuncaochefia = fc.cdfuncaochefia

left join ecadagrupamento agrup on agrup.cdagrupamento = evolucao.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

where fc.flanulado = 'N'
  and fc.dtfim is null

order by
 poder.sgpoder,
 agrup.sgagrupamento,
 o.sgorgao,
 v.numatricula,
 evolucao.nmfuncaochefia,
 fc.dtinicio,
 fc.dtfim
