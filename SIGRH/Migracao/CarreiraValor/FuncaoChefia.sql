select
 --- Agrupamento ---
 poder.sgpoder as sigla_do_poder,
 agrup.sgagrupamento as sigla_agrupamento_de_orgao,
 orgao.sgorgao as sigla_do_orgao,

 --- Funcao de Chefia ---
 evolucao.nmfuncaochefia,
 evolucao.deevolucao,
 tipo.nmtipofuncaochefia,
 padrao.nmpadrao,
 padrao.depadrao,

 --- Propriedade ---
 case when evolucao.cdorgao is null then 'DO AGRUPAMENTO' else 'DO ORGAO' end as gestao,
 ref.qtunidade,
 ref.vlfuncao,
 ref.cdevolucaofucvalorref
 
from ecadevolucaofuncaochefia evolucao
left join ecadevolucaofucvalorref ref on ref.cdevolucaofuncaochefia = evolucao.cdevolucaofuncaochefia
left join epagpadraofucagrup padrao on padrao.cdpadraofucagrup = ref.cdpadraofucagrup

left join ecadtipofuncaochefia tipo on tipo.cdtipofuncaochefia = evolucao.cdtipofuncaochefia

left join vcadorgao orgao on orgao.cdorgao = evolucao.cdorgao

left join ecadagrupamento agrup on agrup.cdagrupamento = evolucao.cdagrupamento
left join ecadpoder poder on poder.cdpoder = agrup.cdpoder

order by 
 nvl(orgao.sgorgao, ' '),
 evolucao.nmfuncaochefia,
 evolucao.deevolucao
 