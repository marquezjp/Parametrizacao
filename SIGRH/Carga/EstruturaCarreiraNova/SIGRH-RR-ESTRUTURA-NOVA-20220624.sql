select
 a.sgagrupamento as sgagrupamento,
 ica.deitemcarreira as decarreira,
 igp.deitemcarreira as degrupoocupacional,
 icl.deitemcarreira as declasse,
 icr.deitemcarreira as decargo,
 --icp.deitemcarreira as decompetencia,
 ies.deitemcarreira as deespecialidade,
 iec.deitemcarreira as deitemcarreira,
 ipai.deitemcarreira as deitemcarreirapai,
 ec.*
from ecadestruturacarreira ec
inner join ecadagrupamento a on a.cdagrupamento = ec.cdagrupamento
left join ecaditemcarreira iec on iec.cditemcarreira = ec.cditemcarreira
left join ecadestruturacarreira ecpai on ecpai.cdestruturacarreira = ec.cdestruturacarreirapai
left join ecadestruturacarreira ecca on ecca.cdestruturacarreira = ec.cdestruturacarreiracarreira
left join ecadestruturacarreira ecgp on ecgp.cdestruturacarreira = ec.cdestruturacarreiragrupo
left join ecadestruturacarreira eccr on eccr.cdestruturacarreira = ec.cdestruturacarreiracargo
left join ecadestruturacarreira eccl on eccl.cdestruturacarreira = ec.cdestruturacarreiraclasse
left join ecadestruturacarreira eccp on eccp.cdestruturacarreira = ec.cdestruturacarreiracomp
left join ecadestruturacarreira eces on eces.cdestruturacarreira = ec.cdestruturacarreiraespec

left join ecaditemcarreira ipai on ipai.cditemcarreira = ecpai.cditemcarreira
left join ecaditemcarreira ica on ica.cditemcarreira = ecca.cditemcarreira
left join ecaditemcarreira igp on igp.cditemcarreira = ecgp.cditemcarreira
left join ecaditemcarreira icr on icr.cditemcarreira = eccr.cditemcarreira
left join ecaditemcarreira icl on icl.cditemcarreira = eccl.cditemcarreira
left join ecaditemcarreira icp on icp.cditemcarreira = eccp.cditemcarreira
left join ecaditemcarreira ies on ies.cditemcarreira = eces.cditemcarreira
order by 1 asc nulls first, 2 asc nulls first, 3 asc nulls first, 4 asc nulls first, 5 asc nulls first, 6 asc nulls first
;

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 '' as degrupoocupacional,
 '' as declasse,
 '' as decargo,
 '' as deespecialidade,
 'CARREIRA' as cdtipoitemcarreira,
 'A ' || cef.decarreira as deitemcarreira,
 'N' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
--  and cef.degrupoocupacional is not null
--  and cef.declasse is null
--  and cef.decargo is not null
--  and cef.deespecialidade is null

union

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 cef.degrupoocupacional,
 '' as declasse,
 '' as decargo,
 '' as deespecialidade,
 'GRUPO OCUPACIONAL' as cdtipoitemcarreira,
 cef.degrupoocupacional as deitemcarreira,
 'N' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
  and cef.degrupoocupacional is not null
--  and cef.declasse is null
--  and cef.decargo is not null
--  and cef.deespecialidade is null

union

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 cef.degrupoocupacional,
 cef.declasse,
 '' as decargo,
 '' as deespecialidade,
 'CLASSE' as cdtipoitemcarreira,
 cef.declasse as deitemcarreira,
 'N' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
--  and cef.degrupoocupacional is not null
  and cef.declasse is not null
--  and cef.decargo is not null
--  and cef.deespecialidade is null

union

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 cef.degrupoocupacional,
 cef.declasse,
 cef.decargo,
 '' as deespecialidade,
 'CARGO' as cdtipoitemcarreira,
 cef.decargo as deitemcarreira,
 'N' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
--  and cef.degrupoocupacional is not null
--  and cef.declasse is not null
  and cef.decargo is not null
  and cef.deespecialidade is not null

union

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 cef.degrupoocupacional,
 cef.declasse,
 cef.decargo,
 cef.deespecialidade,
 'CARGO' as cdtipoitemcarreira,
 cef.decargo as deitemcarreira,
 'S' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
--  and cef.degrupoocupacional is not null
--  and cef.declasse is not null
  and cef.decargo is not null
  and cef.deespecialidade is null

union

select distinct
 case when cef.sgorgao != null then a.sgagrupamento else 'ADM-DIR' end as sgagrupamento,
 'A ' || cef.decarreira as decarreira,
 cef.degrupoocupacional,
 cef.declasse,
 cef.decargo,
 cef.deespecialidade,
 'ESPECIALIDADE' as cdtipoitemcarreira,
 cef.deespecialidade as deitemcarreira,
 'S' as flultimo
from sigrh_rr_carreira_cargos cef
left join vcadorgao o on o.sgorgao = cef.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where (cef.sgorgao is null or o.cdorgao is not null)
  and cef.decarreira is not null
--  and cef.degrupoocupacional is not null
--  and cef.declasse is not null
  and cef.decargo is not null
  and cef.deespecialidade is not null

order by 1 asc nulls first, 3 asc nulls first,  4 asc nulls first, 5 asc nulls first, 6 asc nulls first