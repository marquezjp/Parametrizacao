select cdvinculo from ecadvinculo
where numatricula = 947481;

select
 lpad(v.numatricula || '-' || nudvmatricula,9,0) as matricula
,v.dtadmissao as data_admissao
,v.dtdesligamento as data_desligamento
,lpad(p.nucpf, 11, 0) CPF
,p.nmpessoa as nome_completo
--,cef.cdvinculo
,cef.cdrelacaotrabalho
,cef.cdregimetrabalho
--,v.cdregimetrabalho
,cef.cdnaturezavinculo
,cef.cdregimeprevidenciario
--,v.cdregimeprevidenciario
,cef.cdsituacaoprevidenciaria
--,v.cdsituacaoprevidenciaria
,cef.cdestruturacarreira
,e.cdestruturacarreirapai
from ecadhistcargoefetivo cef
inner join  ecadvinculo v on v.cdvinculo = cef.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadestruturacarreira e on e.cdestruturacarreira = cef.cdestruturacarreira
where e.cdestruturacarreirapai in (843, 844, 845)
  and cef.cdrelacaotrabalho = 3
--  and (cef.cdregimetrabalho != 1 or cef.cdnaturezavinculo != 4)
--  and v.numatricula = 947444
-- and v.cdregimetrabalho != cef.cdregimetrabalho
--      or v.cdregimeprevidenciario != cef.cdregimeprevidenciario
--      or v.cdsituacaoprevidenciaria != cef.cdsituacaoprevidenciaria)
;

update ecadhistcargoefetivo
set
 cdrelacaotrabalho = 3
,cdregimetrabalho = 1
,cdnaturezavinculo = 4
,cdregimeprevidenciario = 1
,cdsituacaoprevidenciaria = 1
where cdvinculo in (
select cef.cdvinculo
from ecadhistcargoefetivo cef
inner join  ecadvinculo v on v.cdvinculo = cef.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadestruturacarreira e on e.cdestruturacarreira = cef.cdestruturacarreira
where e.cdestruturacarreirapai in (843, 844, 845)
and cef.cdrelacaotrabalho = 3
and ( cef.cdregimetrabalho != 1 or cef.cdnaturezavinculo != 4)
);

update ecadvinculo
set cdregimetrabalho = 1
where cdvinculo in (
select v.cdvinculo
from ecadhistcargoefetivo cef
inner join  ecadvinculo v on v.cdvinculo = cef.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join ecadestruturacarreira e on e.cdestruturacarreira = cef.cdestruturacarreira
where e.cdestruturacarreirapai in (843, 844, 845)
  and cef.cdrelacaotrabalho = 3
 and v.cdregimetrabalho != cef.cdregimetrabalho
)
;