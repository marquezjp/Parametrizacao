--- Criar Parametrização da Estrutura de Carreira dos Cargos Efetivos e Temporarios com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Parametros dos Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios (ecadEvolucaoEstruturaCarreira)
--- - Lista de Cargas Horárias Permitidas (ecadEvolucaoCEFCargaHoraria)
--- - Naturezas de Vínculo Permitidas (ecadEvolucaoCEFNatVinc)
--- - Relações de Trabalho Permitidas (ecadevolucaocefreltrab)
--- - Regimes de Trabalho Permitidos (ecadevolucaocefregtrab)
--- - Regimes Previdenciários Permitidos (ecadevolucaocefregprev)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadEvolucaoCEFCargaHoraria;
--delete ecadEvolucaoCEFNatVinc;
--delete ecadEvolucaoCEFRelTrab;
--delete ecadEvolucaoCEFRegTrab;
--delete ecadEvolucaoCEFRegPrev;

--delete ecadEvolucaoEstruturaCarreira;

--- Criar ecadevolucaoestruturacarreira
insert into ecadevolucaoestruturacarreira
with carreiras as (
select
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia,
 case
  when max(case when v.dtdesligamento is null then 1 else 0 end) = 1 then null
  else last_day(max(nvl(v.dtdesligamento,last_day(sysdate))))
 end as dtfimvigencia,
 count(*) as nuqlp,
 111415 as nuocupacao,
 'CARGO' as nmtipoitemcarreiraapo,
 'SEMANAL' as nmtipocargahoraria,
 'NAO PERMITE ACUMULACAO DE VINCULOS' as nmacumvinculo
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
group by
 a.sgagrupamento,
 v.decarreira
order by
 a.sgagrupamento,
 v.decarreira
),
carreria_existe as (
select
 e.cdagrupamento,
 i.deitemcarreira
from ecadevolucaoestruturacarreira e
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
)

select
(select nvl(max(cdevolucaoestcarreira),0) from ecadevolucaoestruturacarreira) + rownum as cdevolucaoestcarreira,
c.dtiniciovigencia as dtiniciovigencia,
c.dtfimvigencia as dtfimvigencia,
ac.cdacumvinculo as cdacumvinculo,
est.cdestruturacarreira as cdestruturacarreira,
a.cdagrupamento as cdagrupamento,
i.cditemcarreira as cditemcarreira,
tpcho.cdtipocargahoraria as cdtipocargahoraria,
null as cdconceitocarreira,
cbo.cdocupacao as cdocupacao,
null as cdcefabsorvervagas,
null as cddescricaoqlp,
'N' as flregistroprofissional,
'N' as flhabilitacao,
'N' as flpaga,
null as nutempoexp,
tpic.cdtipoitemcarreira as cdtipoitemcarreiraapo,
null as dtextincao,
null as deevolucao,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao,
'N' as flaumentocarga,
'0' as vlreducaocarga,
null as cddocumento,
null as cdtipopublicacao,
null as dtpublicacao,
null as nupublicacao,
null as nupaginicial,
null as cdmeiopublicacao,
null as deoutromeio,
null as flevolucaocefregprev,
null as flevolucaocefregtrab,
null as flevolucaocefitemativ,
null as flevolucaocefreltrab,
null as flevolucaocefnatvinc,
null as flevolucaocefitemformacao,
null as flevolucaocefprereq,
null as flevolucaocefcargahoraria,
null as cdgrauinstrucao,
null as flavancanivrefapo,
'N' as flmagisterio,
null as cdgrupo,
null as nucnpjsindicato
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadocupacao cbo on cbo.nuocupacao = c.nuocupacao
inner join ecadtipocargahoraria tpcho on upper(tpcho.nmtipocargahoraria) = upper(c.nmtipocargahoraria)
inner join ecadtipoitemcarreira tpic on tpic.nmtipoitemcarreira = upper(c.nmtipoitemcarreiraapo)
inner join ecadacumvinculo ac on ac.nmacumvinculo = upper(c.nmacumvinculo)
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.deitemcarreira = c.decarreira
where crexiste.cdagrupamento is null
;

--- Criar a Lista de Cargas Horárias Permitidas para os Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios
insert into ecadevolucaocefcargahoraria
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nucargahoraria
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by
 a.sgagrupamento,
 v.decarreira,
 v.nucargahoraria
),
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 ecefcho.nucargahoraria as nucargahoraria
from ecadevolucaocefcargahoraria ecefcho
inner join ecadevolucaoestruturacarreira ecef on ecef.cdevolucaoestcarreira = ecefcho.cdevolucaoestcarreira
inner join ecadestruturacarreira est on est.cdagrupamento = ecef.cdagrupamento
                                    and est.cdestruturacarreira = ecef.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = ecef.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = est.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = ecef.cdagrupamento
)
select
(select nvl(max(cdevolucaocefcargahoraria),0) from ecadevolucaocefcargahoraria) + rownum as cdevolucaocefcargahoraria,
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
est.cdestruturacarreira as cdestruturacarreira,
c.nucargahoraria as nucargahoraria,
systimestamp as dtultalteracao
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nucargahoraria = c.nucargahoraria
where crexiste.cdagrupamento is null
;

--- Criar as Naturezas de Vínculo Permitidas para os Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios
insert into ecadevolucaocefnatvinc
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nmnaturezavinculo
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by
 a.sgagrupamento,
 v.decarreira,
 v.nmnaturezavinculo
),
natvinc as (
select
 cdnaturezavinculo,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo

from ecadnaturezavinculo
),
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 natvinc.nmnaturezavinculo
from ecadevolucaocefnatvinc ecefnatvinc
inner join natvinc on natvinc.cdnaturezavinculo = ecefnatvinc.cdnaturezavinculo
inner join ecadevolucaoestruturacarreira e on e.cdestruturacarreira = ecefnatvinc.cdestruturacarreira
inner join ecadestruturacarreira est on est.cdagrupamento = e.cdagrupamento
                                    and est.cdestruturacarreira = e.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
)
select
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
natvinc.cdnaturezavinculo as cdnaturezavinculo,
est.cdestruturacarreira as cdestruturacarreira
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
                                          and e.cditemcarreira = i.cditemcarreira
inner join natvinc on natvinc.nmnaturezavinculo = c.nmnaturezavinculo
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nmnaturezavinculo = c.nmnaturezavinculo
where crexiste.cdagrupamento is null
;

--- Criar as Relações de Trabalho Permitidas para os Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios
insert into ecadevolucaocefreltrab
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nmrelacaotrabalho
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by
 a.sgagrupamento,
 v.decarreira,
 v.nmrelacaotrabalho
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 reltrab.nmrelacaotrabalho
from ecadevolucaocefreltrab ecefreltra
inner join reltrab on reltrab.cdrelacaotrabalho = ecefreltra.cdrelacaotrabalho
inner join ecadevolucaoestruturacarreira e on e.cdestruturacarreira = ecefreltra.cdestruturacarreira
inner join ecadestruturacarreira est on est.cdagrupamento = e.cdagrupamento
                                    and est.cdestruturacarreira = e.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
)
select
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
est.cdestruturacarreira as cdestruturacarreira
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
                                          and e.cditemcarreira = i.cditemcarreira
inner join reltrab on reltrab.nmrelacaotrabalho = c.nmrelacaotrabalho
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nmrelacaotrabalho = c.nmrelacaotrabalho
where crexiste.cdagrupamento is null
;

--- Criar os Regimes de Trabalho Permitidos para os Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios
insert into ecadevolucaocefregtrab
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nmregimetrabalho
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by
 a.sgagrupamento,
 v.decarreira,
 v.nmregimetrabalho
),
regtrab as (
select
 cdregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho

from ecadregimetrabalho
),
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 regtrab.nmregimetrabalho
from ecadevolucaocefregtrab ecefregtrab
inner join regtrab on regtrab.cdregimetrabalho = ecefregtrab.cdregimetrabalho
inner join ecadevolucaoestruturacarreira e on e.cdestruturacarreira = ecefregtrab.cdestruturacarreira
inner join ecadestruturacarreira est on est.cdagrupamento = e.cdagrupamento
                                    and est.cdestruturacarreira = e.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
)
select
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
regtrab.cdregimetrabalho as cdregimetrabalho,
est.cdestruturacarreira as cdestruturacarreira
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
                                          and e.cditemcarreira = i.cditemcarreira
inner join regtrab on regtrab.nmregimetrabalho = c.nmregimetrabalho
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nmregimetrabalho = c.nmregimetrabalho
where crexiste.cdagrupamento is null
;

--- Criar os Regimes Previdenciários Permitidos para os Itens da Estrutura de Carreira dos Cargos Efetivos e Temporarios
insert into ecadevolucaocefregprev
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nmregimeprevidenciario
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by
 a.sgagrupamento,
 v.decarreira,
 v.nmregimeprevidenciario
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
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 regprev.nmregimeprevidenciario
from ecadevolucaocefregprev ecefregprev
inner join regprev on regprev.cdregimeprevidenciario = ecefregprev.cdregimeprevidenciario
inner join ecadevolucaoestruturacarreira e on e.cdestruturacarreira = ecefregprev.cdestruturacarreira
inner join ecadestruturacarreira est on est.cdagrupamento = e.cdagrupamento
                                    and est.cdestruturacarreira = e.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
)
select
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
regprev.cdregimeprevidenciario as cdregimeprevidenciario,
est.cdestruturacarreira as cdestruturacarreira
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
                                          and e.cditemcarreira = i.cditemcarreira
inner join regprev on regprev.nmregimeprevidenciario = c.nmregimeprevidenciario
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nmregimeprevidenciario = c.nmregimeprevidenciario
where crexiste.cdagrupamento is null
;

--- Criar a Lista de Naturezas do Vínculo para o Orgao
insert into ecadevolucaocefnatvinc
with carreiras as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.decarreira,
 v.nmnaturezavinculo
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')
order by  a.sgagrupamento, v.decarreira, v.nmnaturezavinculo
),
natvinc as (
select
 cdnaturezavinculo,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo

from ecadnaturezavinculo
),
carreria_existe as (
select
 a.cdagrupamento as cdagrupamento,
 i.deitemcarreira as decarreira,
 natvinc.nmnaturezavinculo
from ecadevolucaocefnatvinc ecefnatvinc
inner join natvinc on natvinc.cdnaturezavinculo = ecefnatvinc.cdnaturezavinculo
inner join ecadevolucaoestruturacarreira e on e.cdestruturacarreira = ecefnatvinc.cdestruturacarreira
inner join ecadestruturacarreira est on est.cdagrupamento = e.cdagrupamento
                                    and est.cdestruturacarreira = e.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
)
select
e.cdevolucaoestcarreira as cdevolucaoestcarreira,
natvinc.cdnaturezavinculo as cdnaturezavinculo,
est.cdestruturacarreira as cdestruturacarreira
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1 and i.deitemcarreira = c.decarreira
inner join ecadestruturacarreira est on est.cdagrupamento = a.cdagrupamento
                                    and est.cditemcarreira = i.cditemcarreira
inner join ecadevolucaoestruturacarreira e on e.cdagrupamento = a.cdagrupamento
                                          and e.cdestruturacarreira = est.cdestruturacarreira
                                          and e.cditemcarreira = i.cditemcarreira
inner join natvinc on natvinc.nmnaturezavinculo = c.nmnaturezavinculo
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.decarreira = c.decarreira and crexiste.nmnaturezavinculo = c.nmnaturezavinculo
where crexiste.cdagrupamento is null
;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.1-ecadEvolucaoEstruturaCarreira' as Conceito, count(*) as Qtde from ecadEvolucaoEstruturaCarreira union
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.2-ecadEvolucaoCEFCargaHoraria' as Conceito, count(*) as Qtde from ecadEvolucaoCEFCargaHoraria union
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.3-ecadEvolucaoCEFNatVinc' as Conceito, count(*) as Qtde from ecadEvolucaoCEFNatVinc union
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.4-ecadevolucaocefreltrab' as Conceito, count(*) as Qtde from ecadevolucaocefreltrab union
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.5-ecadevolucaocefregtrab' as Conceito, count(*) as Qtde from ecadevolucaocefregtrab union
select '3-ParametrosEstuturaCarreira' as Grupo,  '3.6-ecadevolucaocefregprev' as Conceito, count(*) as Qtde from ecadevolucaocefregprev
order by 1, 2

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'ecadevolucaoestruturacarreira' as Tab, 'SCADEVOLUCAOESTRUTURACARREIRA' as Seq, nvl(max(cdevolucaoestcarreira),0)     as Qtde from ecadEvolucaoEstruturaCarreira union
select 'ecadevolucaocefcargahoraria'   as Tab, 'SCADEVOLUCAOCEFCARGAHORARIA'   as Seq, nvl(max(cdevolucaocefcargahoraria),0) as Qtde from ecadEvolucaoCEFCargaHoraria
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
'SCADEVOLUCAOESTRUTURACARREIRA',
'SCADEVOLUCAOCEFCARGAHORARIA'
);
