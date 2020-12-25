select v.numatricula,
       v.cdregimetrabalho,
       rt.nmregimetrabalho,
       v.cdregimeprevidenciario,
       rp.nmregimeprevidenciario,
       hce.cdrelacaotrabalho,
       rel.nmrelacaotrabalho,
       hce.cdregimetrabalho,
       hrt.nmregimetrabalho,
       hce.cdregimeprevidenciario,
       hrp.nmregimeprevidenciario
from ecadvinculo v
inner join ecadhistcargoefetivo hce on hce.cdvinculo = v.cdvinculo
       and (hce.dtfim > sysdate or  hce.dtfim is null)
inner join ecadregimetrabalho rt on rt.cdregimetrabalho = v.cdregimetrabalho
inner join ecadregimeprevidenciario rp on rp.cdregimeprevidenciario = v.cdregimeprevidenciario
inner join ecadrelacaotrabalho rel on rel.cdrelacaotrabalho = hce.cdrelacaotrabalho
inner join ecadregimetrabalho hrt on hrt.cdregimetrabalho = hce.cdregimetrabalho
inner join ecadregimeprevidenciario hrp on hrp.cdregimeprevidenciario = hce.cdregimeprevidenciario
where v.numatricula in (24200, 4503);

select v.numatricula, v.cdregimetrabalho, v.cdregimeprevidenciario
from ecadvinculo v
where v.numatricula in (0953925, 0019078);

select v.numatricula, hce.cdrelacaotrabalho, hce.cdregimetrabalho, hce.cdregimeprevidenciario
from ecadhistcargoefetivo hce
inner join ecadvinculo v on v.cdvinculo = hce.cdvinculo
where v.numatricula in (0953925, 0019078)
  and (hce.dtfim > sysdate or  hce.dtfim is null)