select * from ecadtipomatricagrup;

select
 cdagrupamento,
 sgagrupamento,
 cdgrupoagrupamento,
 cdtipomatricagrup
from ecadagrupamento;

select
 cdgrupoagrupamento,
 sggrupoagrupamento,
 nuultmatricula
from ecadgrupoagrupamento;

update ecadagrupamento
set cdtipomatricagrup = 3,
    cdgrupoagrupamento = 1;

update ecadgrupoagrupamento
set nuultmatricula = (select nvl(max(numatricula),0) from ecadvinculo)
where cdgrupoagrupamento = 1;