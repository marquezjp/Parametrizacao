--- Item Carreira ---
select pd.sgpoder,
    --pd.nmpoder,
    ag.sgagrupamento,
    --ag.nmagrupamento,
    tpitem.nmtipoitemcarreira,
    item.deitemcarreira
from ecaditemcarreira item
    left join ecadtipoitemcarreira tpitem on tpitem.cdtipoitemcarreira = item.cdtipoitemcarreira
    left join ecadagrupamento ag on ag.cdagrupamento = item.cdagrupamento
    left join ecadpoder pd on pd.cdpoder = ag.cdpoder;
--- Item Carreira ---
select *
from ecaditemcarreira;
--- Estrutura Carreira ---
select *
from Estrutura Carreira;
--- Evolucao Estrutura Carreira ---
select *
from ecadevolucaoestruturacarreira;