--- Atualizar as Parametrizações dos Órgãos com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Lista de Carreiras Permitidas no Órgão (ecadorgaocarreira)
--- - Lista de Grupo Ocupacional dos Cargos Comissionados Permitidos no Órgão (ecadorgaocargocom)
--- - Regimes de Trabalho Permitidos (ecadOrgaoRegTrabalho)
--- - Regimes Previdenciários Permitidos (ecadOrgaoRegPrev)
--- - Relação de Trabalho Permitidas (ecadOrgaoRelTrabalho)
--- - Naturezas do Vínculo Permitidas (ecadOrgaoNatVinculo)
--- - Lista de Relacao de Trabalho por Regime de Trabalho Permitidas para o Orgao (ecadRelTrabRegTrab)
--- - Lista de Natureza do Vinculo por Relacao de Trabalho Permitidas para o Agrupamento (ecadNatVincRelTrab)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadNatVincRelTrab;
--delete ecadRelTrabRegTrab;
--delete ecadOrgaoCarreira;
--delete ecadOrgaoCargoCom;
--delete ecadOrgaoRegTrabalho;
--delete ecadOrgaoRegPrev;
--delete ecadOrgaoRelTrabalho;
--delete ecadOrgaoNatVinculo;

--- Criar a Lista de Carreiras Permitidas para o Orgao
insert into ecadorgaocarreira
with carreiras as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.decarreira,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
group by a.sgagrupamento, o.sgorgao, v.decarreira
order by a.sgagrupamento, o.sgorgao, v.decarreira
),
carreria_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 i.deitemcarreira as decarreira
from ecadorgaocarreira oc
inner join vcadorgao o on o.cdorgao = oc.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join ecadestruturacarreira e on e.cdagrupamento = a.cdagrupamento and e.cdestruturacarreira = oc.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento and i.cditemcarreira = e.cditemcarreira
)

select
(select nvl(max(cdorgaocarreira),0) from ecadorgaocarreira) + rownum as cdorgaocarreira,
o.cdorgao as cdorgao,
e.cdestruturacarreira as cdestruturacarreira,
case when c.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else c.dtiniciovigencia end as dtiniciovigencia,
c.dtfimvigencia as dtfimvigencia,
null as cdhistorgaorespanulacao,
'N' as flanulado,
systimestamp as dtultalteracao,
e.cdestruturacarreira as cdestruturacarreirausuario,
'S' as flutilizalpdigital
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = c.sgorgao
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira e on e.cdagrupamento = a.cdagrupamento and e.cditemcarreira = i.cditemcarreira
left join carreria_existe crexist on crexist.sgagrupamento = a.sgagrupamento and crexist.sgorgao = c.sgorgao and crexist.decarreira = c.decarreira
where crexist.sgagrupamento is null
;

--- Criar a Lista de Grupo Ocupacional dos Cargos Comissionados Permitidos para o Orgao
insert into ecadorgaocargocom
with grupoocupacional as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.degrupoocupacional as nmgrupoocupacional,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.nmrelacaotrabalho in ('COMISSIONADO')
group by a.sgagrupamento, o.sgorgao, v.degrupoocupacional
order by a.sgagrupamento, o.sgorgao, v.degrupoocupacional
),
grupoocupacional_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 g.nmgrupoocupacional
from ecadorgaocargocom occo
inner join vcadorgao o on o.cdorgao = occo.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join ecadgrupoocupacional g on g.cdagrupamento = a.cdagrupamento and g.cdgrupoocupacional = occo.cdgrupoocupacional
)

select
(select nvl(max(cdorgaocargocom),0) from ecadorgaocargocom) + rownum as cdorgaocargocom,
o.cdorgao as cdorgao,
null as cdcargocomissionado,
case when gcco.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else gcco.dtiniciovigencia end as dtiniciovigencia,
gcco.dtfimvigencia as dtfimvigencia,
systimestamp as dtultalteracao,
null as cdhistorgaorespanulacao,
'N' as flanulado,
g.cdgrupoocupacional as cdgrupoocupacional

from grupoocupacional gcco
inner join ecadagrupamento a on a.sgagrupamento = gcco.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = gcco.sgorgao
inner join ecadgrupoocupacional g on g.cdagrupamento = a.cdagrupamento and g.nmgrupoocupacional = gcco.nmgrupoocupacional
left join grupoocupacional_existe gexist on gexist.sgagrupamento = a.sgagrupamento and gexist.sgorgao = gcco.sgorgao and gexist.nmgrupoocupacional = gcco.nmgrupoocupacional
where gexist.sgagrupamento is null
;

--- Criar a Lista de Regimes de Trabalho Permitidos para o Orgao
insert into ecadorgaoregtrabalho
with orgaoregimetrabalho as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmregimetrabalho,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmregimetrabalho is not null
group by a.sgagrupamento, o.sgorgao, v.nmregimetrabalho
order by a.sgagrupamento, o.sgorgao, v.nmregimetrabalho
),
regtrab as (
select
 cdregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho

from ecadregimetrabalho
),
orgaoregimetrabalho_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 regtrab.nmregimetrabalho
from ecadorgaoregtrabalho oregtrab
inner join vcadorgao o on o.cdorgao = oregtrab.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join regtrab on regtrab.cdregimetrabalho = oregtrab.cdregimetrabalho
)

select
(select nvl(max(cdorgaoregtrabalho),0) from ecadorgaoregtrabalho) + rownum as cdorgaoregtrabalho,
o.cdorgao as cdorgao,
regtrab.cdregimetrabalho as cdregimetrabalho,
case when oregtrab.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else oregtrab.dtiniciovigencia end as dtiniciovigencia,
oregtrab.dtfimvigencia as dtfimvigencia,
null as cdhistorgaorespanulacao,
'N' as flanulado,
systimestamp as dtultalteracao
from orgaoregimetrabalho oregtrab
inner join ecadagrupamento a on a.sgagrupamento = oregtrab.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = oregtrab.sgorgao
inner join regtrab on regtrab.nmregimetrabalho = oregtrab.nmregimetrabalho
left join orgaoregimetrabalho_existe oregtrabexist on oregtrabexist.sgagrupamento = a.sgagrupamento and oregtrabexist.sgorgao = oregtrab.sgorgao and oregtrabexist.nmregimetrabalho = oregtrab.nmregimetrabalho
where oregtrabexist.sgagrupamento is null
;

--- Criar a Lista de Regimes Previdenciários Permitidas para o Orgao
insert into ecadorgaoregprev
with orgaoregimeprevidenciario as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmregimeprevidenciario,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmregimeprevidenciario is not null
group by a.sgagrupamento, o.sgorgao, v.nmregimeprevidenciario
order by a.sgagrupamento, o.sgorgao, v.nmregimeprevidenciario
),
regprev as (
select
 cdregimeprevidenciario,
 case when cdregimeprevidenciario = 2 then 'REGIME PROPRIO'
      else translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz')
 end as nmregimeprevidenciario
from ecadregimeprevidenciario
),
orgaoregimeprevidenciario_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 regprev.nmregimeprevidenciario
from ecadorgaoregprev oregprev
inner join vcadorgao o on o.cdorgao = oregprev.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join regprev on regprev.cdregimeprevidenciario = oregprev.cdregimeprevidenciario
)

select
(select nvl(max(cdorgaoregprev),0) from ecadorgaoregprev) + rownum as cdorgaoregprev,
o.cdorgao as cdorgao,
regprev.cdregimeprevidenciario as cdregimeprevidenciario,
case when oregprev.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else oregprev.dtiniciovigencia end as dtiniciovigencia,
oregprev.dtfimvigencia as dtfimvigencia,
null as cdhistorgaorespanulacao,
'N' as flanulado,
systimestamp as dtultalteracao
from orgaoregimeprevidenciario oregprev
inner join ecadagrupamento a on a.sgagrupamento = oregprev.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = oregprev.sgorgao
inner join regprev on regprev.nmregimeprevidenciario = oregprev.nmregimeprevidenciario
left join orgaoregimeprevidenciario_existe oregprevexiste on oregprevexiste.sgagrupamento = oregprev.sgagrupamento and oregprevexiste.sgorgao = oregprev.sgorgao and oregprevexiste.nmregimeprevidenciario = oregprev.nmregimeprevidenciario
where oregprevexiste.sgagrupamento is null
;

--- Criar a Lista de Relação de Trabalho Permitidas para o Orgao
insert into ecadorgaoreltrabalho
with orgaoreltrabalho as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmrelacaotrabalho,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmrelacaotrabalho is not null
group by a.sgagrupamento, o.sgorgao, v.nmrelacaotrabalho
order by a.sgagrupamento, o.sgorgao, v.nmrelacaotrabalho
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
orgaorelacaotrabalho_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 reltrab.nmrelacaotrabalho
from ecadorgaoreltrabalho oreltrab
inner join vcadorgao o on o.cdorgao = oreltrab.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join reltrab on reltrab.cdrelacaotrabalho = oreltrab.cdrelacaotrabalho
)

select
(select nvl(max(cdorgaoreltrabalho),0) from ecadorgaoreltrabalho) + rownum as cdorgaoreltrabalho,
o.cdorgao as cdorgao,
reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
case when oreltrab.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else oreltrab.dtiniciovigencia end as dtiniciovigencia,
oreltrab.dtfimvigencia as dtfimvigencia,
systimestamp as dtultalteracao,
null as cdhistorgaorespanulacao,
'N' as flanulado
from orgaoreltrabalho oreltrab
inner join ecadagrupamento a on a.sgagrupamento = oreltrab.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = oreltrab.sgorgao
inner join reltrab on reltrab.nmrelacaotrabalho = oreltrab.nmrelacaotrabalho
left join orgaorelacaotrabalho_existe oreltrabexiste on oreltrabexiste.sgagrupamento = oreltrab.sgagrupamento and oreltrabexiste.sgorgao = oreltrab.sgorgao and oreltrabexiste.nmrelacaotrabalho = oreltrab.nmrelacaotrabalho
where oreltrabexiste.sgagrupamento is null
;

--- Criar a Lista de Naturezas do Vínculo para o Orgao
insert into ecadorgaonatvinculo
with orgaonatvinculo as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmnaturezavinculo,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmnaturezavinculo is not null
group by a.sgagrupamento, o.sgorgao, v.nmnaturezavinculo
order by a.sgagrupamento, o.sgorgao, v.nmnaturezavinculo
),
natvinc as (
select
 cdnaturezavinculo,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo

from ecadnaturezavinculo
),
orgaonatvinculo_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 natvinc.nmnaturezavinculo
from ecadorgaonatvinculo onatvinc
inner join vcadorgao o on o.cdorgao = onatvinc.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join natvinc on natvinc.cdnaturezavinculo = onatvinc.cdnaturezavinculo
)

select
(select nvl(max(cdorgaonatvinculo),0) from ecadorgaonatvinculo) + rownum as cdorgaonatvinculo,
o.cdorgao as cdorgao,
natvinc.cdnaturezavinculo as cdnaturezavinculo,
case when onatvinc.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else onatvinc.dtiniciovigencia end as dtiniciovigencia,
onatvinc.dtfimvigencia as dtfimvigencia,
null as cdhistorgaorespanulacao,
'N' as flanulado,
systimestamp as dtultalteracao
from orgaonatvinculo onatvinc
inner join ecadagrupamento a on a.sgagrupamento = onatvinc.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = onatvinc.sgorgao
inner join natvinc on natvinc.nmnaturezavinculo = onatvinc.nmnaturezavinculo
left join orgaonatvinculo_existe onatvincexiste on onatvincexiste.sgagrupamento = onatvinc.sgagrupamento and onatvincexiste.sgorgao = onatvinc.sgorgao and onatvincexiste.nmnaturezavinculo = onatvinc.nmnaturezavinculo
where onatvincexiste.sgagrupamento is null
;

--- Criar a Lista de Relacao de Trabalho por Regime de Trabalho Permitidas para o Orgao
insert into ecadreltrabregtrab
with regimetrabalho as (
select distinct
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmregimetrabalho as nmregimetrabalho,
 v.nmrelacaotrabalho as nmrelacaotrabalho
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmregimetrabalho is not null
  and v.nmrelacaotrabalho is not null
order by a.sgagrupamento, o.sgorgao, v.nmregimetrabalho, v.nmrelacaotrabalho
),
regtrab as (
select
 cdregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho

from ecadregimetrabalho
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
regimetrabalho_existe as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 regtrab.nmregimetrabalho as nmregimetrabalho,
 reltrab.nmrelacaotrabalho as nmrelacaotrabalho,
 rrt.nutransacao
from ecadreltrabregtrab rrt
inner join vcadorgao o on o.cdorgao = rrt.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join regtrab on regtrab.cdregimetrabalho = rrt.cdregimetrabalho
inner join reltrab on reltrab.cdrelacaotrabalho = rrt.cdrelacaotrabalho
order by a.sgagrupamento, o.sgorgao, regtrab.nmregimetrabalho, reltrab.nmrelacaotrabalho
)

select
o.cdorgao as cdorgao,
reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
regtrab.cdregimetrabalho as cdregimetrabalho,
'1' as nutransacao
from regimetrabalho oreltrab
inner join ecadagrupamento a on a.sgagrupamento = oreltrab.sgagrupamento
inner join vcadorgao o on o.cdagrupamento = a.cdagrupamento and o.sgorgao = oreltrab.sgorgao
inner join regtrab on regtrab.nmregimetrabalho = oreltrab.nmregimetrabalho
inner join reltrab on reltrab.nmrelacaotrabalho = oreltrab.nmrelacaotrabalho
left join regimetrabalho_existe orrtexist on orrtexist.sgagrupamento = a.sgagrupamento
                                         and orrtexist.sgorgao = oreltrab.sgorgao
                                         and orrtexist.nmregimetrabalho = oreltrab.nmregimetrabalho
                                         and orrtexist.nmrelacaotrabalho = oreltrab.nmrelacaotrabalho
where orrtexist.sgagrupamento is null
;

--- Criar a Lista de Natureza do Vinculo por Relacao de Trabalho Permitidas para o Agrupamento
insert into ecadnatvincreltrab
with relacaotrabalho as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.nmrelacaotrabalho as nmrelacaotrabalho,
 v.nmnaturezavinculo as nmnaturezavinculo
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.nmrelacaotrabalho is not null
  and v.nmnaturezavinculo is not null
order by a.sgagrupamento, v.nmrelacaotrabalho, v.nmnaturezavinculo
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
natvinc as (
select
 cdnaturezavinculo,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo

from ecadnaturezavinculo
),
relacaotrabalho_existe as (
select
 a.sgagrupamento as sgagrupamento,
 reltrab.nmrelacaotrabalho as nmrelacaotrabalho,
 natvinc.nmnaturezavinculo as nmnaturezavinculo,
 nvrt.nutransacao
from ecadnatvincreltrab nvrt
inner join ecadagrupamento a on a.cdagrupamento = nvrt.cdagrupamento
inner join natvinc on natvinc.cdnaturezavinculo = nvrt.cdnaturezavinculo
inner join reltrab on reltrab.cdrelacaotrabalho = nvrt.cdrelacaotrabalho
order by a.sgagrupamento, reltrab.nmrelacaotrabalho, natvinc.nmnaturezavinculo
)

select
a.cdagrupamento as cdagrupamento,
natvinc.cdnaturezavinculo as cdnaturezavinculo,
reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
'1' as nutransacao
from relacaotrabalho anvrt
inner join ecadagrupamento a on a.sgagrupamento = anvrt.sgagrupamento
inner join natvinc on natvinc.nmnaturezavinculo = anvrt.nmnaturezavinculo
inner join reltrab on reltrab.nmrelacaotrabalho = anvrt.nmrelacaotrabalho
left join relacaotrabalho_existe anvrtexist on anvrtexist.sgagrupamento = anvrt.sgagrupamento
                                           and anvrtexist.nmrelacaotrabalho = anvrt.nmrelacaotrabalho
                                           and anvrtexist.nmnaturezavinculo = anvrt.nmnaturezavinculo
where anvrtexist.sgagrupamento is null
;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '6-ParametrosOrgao' as Grupo,  '6.1-ecadOrgaoCarreira'     as Conceito, count(*) as Qtde from ecadOrgaoCarreira    union
select '6-ParametrosOrgao' as Grupo,  '6.2-ecadOrgaoCargoCom'     as Conceito, count(*) as Qtde from ecadOrgaoCargocom    union
select '6-ParametrosOrgao' as Grupo,  '6.3-ecadOrgaoRegTrabalho'  as Conceito, count(*) as Qtde from ecadOrgaoRegTrabalho union
select '6-ParametrosOrgao' as Grupo,  '6.4-ecadOrgaoRegPrev'      as Conceito, count(*) as Qtde from ecadOrgaoRegPrev     union
select '6-ParametrosOrgao' as Grupo,  '6.5-ecadOrgaorRelTrabalho' as Conceito, count(*) as Qtde from ecadOrgaoRelTrabalho union
select '6-ParametrosOrgao' as Grupo,  '6.6-ecadOrgaoNatVinculo'   as Conceito, count(*) as Qtde from ecadOrgaoNatVinculo  union
select '6-ParametrosOrgao' as Grupo,  '6.7-ecadRelTrabRegTrab'    as Conceito, count(*) as Qtde from ecadRelTrabRegTrab   union
select '6-ParametrosOrgao' as Grupo,  '6.8-ecadNatVincRelTrab'    as Conceito, count(*) as Qtde from ecadNatVincRelTrab
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'ecadorgaocarreira'    as Tab, 'SCADORGAOCARREIRA'    as Seq, nvl(max(cdorgaocarreira),0)    as Qtde from ecadOrgaoCarreira    union
select 'ecadorgaocargocom'    as Tab, 'SCADORGAOCARGOCOM'    as Seq, nvl(max(cdorgaocargocom),0)    as Qtde from ecadOrgaoCargoCom    union
select 'ecadorgaoregtrabalho' as Tab, 'SCADORGAOREGTRABALHO' as Seq, nvl(max(cdorgaoregtrabalho),0) as Qtde from ecadOrgaoRegTrabalho union
select 'ecadorgaoregprev'     as Tab, 'SCADORGAOREGPREV'     as Seq, nvl(max(cdorgaoregprev),0)     as Qtde from ecadOrgaoRegPrev     union
select 'ecadorgaoreltrabalho' as Tab, 'SCADORGAORELTRABALHO' as Seq, nvl(max(cdorgaoreltrabalho),0) as Qtde from ecadOrgaoRelTrabalho union
select 'ecadorgaonatvinculo'  as Tab, 'SCADORGAONATVINCULO'  as Seq, nvl(max(cdorgaonatvinculo),0)  as Qtde from ecadOrgaoNatVinculo
order by 1, 2;

begin
  for item in c1
    loop
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Qtde = ' || item.Qtde);
    
      execute immediate 'alter sequence ' || item.Seq || ' restart start with ' || case when item.Qtde = 0 then 1 else item.Qtde end;
      execute immediate 'analyze table ' || upper(item.Tab) || ' compute statistics';

    end loop;
end;

-- Listar Valor da Sequence dos Conceitos Envolvidos
select sequence_name, last_number from user_sequences
where sequence_name in (
'SCADORGAOCARREIRA',
'SCADORGAOCARGOCOM',
'SCADORGAOREGTRABALHO',
'SCADORGAOREGPREV',
'SCADORGAORELTRABALHO',
'SCADORGAONATVINCULO'
);
