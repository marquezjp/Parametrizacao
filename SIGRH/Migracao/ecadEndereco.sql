select e.nucep, tplog.nmtipologradouro, e.nmlogradouro, e.nunumero, e.decomplemento, e.nmunidade, e.nucaixapostal, b.nmbairro, loc.nmlocalidade, loc.sgestado, loc.cdibge, e.cdendereco
from ecadendereco e
left join ecadtipologradouro tplog on tplog.cdtipologradouro = e.cdtipologradouro
left join ecadbairro b on b.cdbairro = e.cdbairro
left join ecadlocalidade loc on loc.cdlocalidade = e.cdlocalidade