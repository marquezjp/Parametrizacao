--- Criar Estrutura de Carreira dos Cargos Efetivos e Temporarios com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Itens de Carreira dos Cargos Efetivos e Temporarios (ecadItemCarreira)
--- - Estrutura de Carreira dos Cargos Efetivos e Temporarios (ecadEstruturaCarreira)
--- - Incluir os Cargos na Estrutura de Carreira dos Cargos Efetivos e Temporarios (ecadEstruturaCarreira)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadOrgaoCarreira;
--delete ecadOrgaoRegTrabalho;
--delete ecadOrgaoRegPrev;
--delete ecadOrgaoRelTrabalho;
--delete ecadOrgaoNatVinculo;

--delete ecadEvolucaoCEFCargaHoraria;
--delete ecadEvolucaoCEFNatVinc;
--delete ecadEvolucaoCEFRelTrab;
--delete ecadEvolucaoCEFRegTrab;
--delete ecadEvolucaoCEFRegPrev;

--delete ecadEvolucaoEstruturaCarreira;

--delete epagValorCarreiraCEFAgrup;
--delete epagHistNivelRefCarrCEFAgrup;
--delete epagHistNivelRefCEFAgrup;
--delete epagNivelRefCEFAgrupVersao;
--delete epagNivelRefCEFAgrup;

--delete ecadEstruturaCarreira;
--delete ecadItemCarreira;

--- Criar ecadItemCarreira
insert into ecaditemcarreira
with vinculos as (
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,
 null as decarreira,
 translate(regexp_replace(upper(trim(nmgrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 null as decargo,
 null as declasse,
 null as decompetencia,
 null as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahorariacom as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 trim(nunivel) as nunivel,
 nureferencia as nureferencia,
 translate(regexp_replace(upper(trim(nvl(nmopcaoremuneracao,'PELO CARGO COMISSIONADO'))), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao
from sigrhmig.emigvinculocomissionado
union
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,

 translate(regexp_replace(upper(trim(decarreira)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decarreira,
 translate(regexp_replace(upper(trim(degrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 translate(regexp_replace(upper(trim(decargo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decargo,
 translate(regexp_replace(upper(trim(declasse)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as declasse,
 translate(regexp_replace(upper(trim(decompetencia)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decompetencia,
 translate(regexp_replace(upper(trim(deespecialidade)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahoraria as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 nunivelpagamento as nunivel,
 nureferenciapagamento as nureferencia,
 null as nmopcaoremuneracao 
from sigrhmig.emigvinculoefetivo
),
itens_carreira as (
select distinct
 a.sgagrupamento as sgagrupamento,
 'CARREIRA' as nmtipoitemcarreira,
 v.decarreira as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.decarreira is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

union

select distinct
 a.sgagrupamento as sgagrupamento,
 'GRUPO OCUPACIONAL' as nmtipoitemcarreira,
 v.degrupoocupacional as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

union

select distinct
 a.sgagrupamento as sgagrupamento,
 'CARGO' as nmtipoitemcarreira,
 v.decargo as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.decargo is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

union

select distinct
 a.sgagrupamento as sgagrupamento,
 'CLASSE' as nmtipoitemcarreira,
 v.declasse as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.declasse is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

union

select distinct
 a.sgagrupamento as sgagrupamento,
 'COMPETÊNCIA' as nmtipoitemcarreira,
 v.decompetencia as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.decompetencia is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

union

select distinct
 a.sgagrupamento as sgagrupamento,
 'ESPECIALIDADE' as nmtipoitemcarreira,
 v.deespecialidade as deitemcarreira
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.deespecialidade is not null
  and v.nmrelacaotrabalho in ('EFETIVO', 'ACT - ADMITIDO EM CARATER TEMPORARIO')

order by 1, 2 desc, 3
),
itens_carreira_existe as (
select
 a.sgagrupamento,
 tp.nmtipoitemcarreira,
 i.deitemcarreira
from ecaditemcarreira i
inner join ecadagrupamento a on a.cdagrupamento = i.cdagrupamento
inner join ecadtipoitemcarreira tp on tp.cdtipoitemcarreira = i.cdtipoitemcarreira
order by i.cditemcarreira
)
select
(select nvl(max(cditemcarreira),0) from ecaditemcarreira) + rownum  as cditemcarreira,
tp.cdtipoitemcarreira as cdtipoitemcarreira,
a.cdagrupamento as cdagrupamento,
i.deitemcarreira as deitemcarreira,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
'N' as flanulado,
null as dtanulado,
systimestamp as dtultalteracao,
null as cdcargosirh,
case when i.nmtipoitemcarreira = 'CARREIRA' and  i.deitemcarreira like upper('%policia%') then 3
     when i.nmtipoitemcarreira = 'CARREIRA' and (i.deitemcarreira like upper('%SEED%') or i.deitemcarreira like upper('%educacao%')) then 2
     when i.nmtipoitemcarreira = 'CARREIRA' then 1
     else null
end as inquadro
from itens_carreira i
inner join ecadagrupamento a on a.sgagrupamento = i.sgagrupamento
inner join ecadtipoitemcarreira tp on tp.nmtipoitemcarreira = i.nmtipoitemcarreira
left join itens_carreira_existe iexiste on iexiste.sgagrupamento = i.sgagrupamento and iexiste.nmtipoitemcarreira = i.nmtipoitemcarreira and iexiste.deitemcarreira = i.deitemcarreira
where iexiste.sgagrupamento is null
;

--- Criar ecadEstruturaCarreira, incluir as Carreira
insert into ecadestruturacarreira
with vinculos as (
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,
 null as decarreira,
 translate(regexp_replace(upper(trim(nmgrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 null as decargo,
 null as declasse,
 null as decompetencia,
 null as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahorariacom as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 trim(nunivel) as nunivel,
 nureferencia as nureferencia,
 translate(regexp_replace(upper(trim(nvl(nmopcaoremuneracao,'PELO CARGO COMISSIONADO'))), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao
from sigrhmig.emigvinculocomissionado
union
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,

 translate(regexp_replace(upper(trim(decarreira)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decarreira,
 translate(regexp_replace(upper(trim(degrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 translate(regexp_replace(upper(trim(decargo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decargo,
 translate(regexp_replace(upper(trim(declasse)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as declasse,
 translate(regexp_replace(upper(trim(decompetencia)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decompetencia,
 translate(regexp_replace(upper(trim(deespecialidade)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahoraria as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 nunivelpagamento as nunivel,
 nureferenciapagamento as nureferencia,
 null as nmopcaoremuneracao 
from sigrhmig.emigvinculoefetivo
),
carreiras as (
select
 a.sgagrupamento as sgagrupamento,
 decarreira,
 nmrelacaotrabalho,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia

from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
group by a.sgagrupamento, decarreira, nmrelacaotrabalho
order by a.sgagrupamento, decarreira, nmrelacaotrabalho
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
qlp as (
select
 cddescricaoqlp,
 cdagrupamento,
 cdrelacaotrabalho,
 nmdescricaoqlp
from emovdescricaoqlp
where nmdescricaoqlp like 'QLP IMPLANTACAO%'
),
carreria_existe as (
select
 e.cdagrupamento,
 i.deitemcarreira
from ecadestruturacarreira e 
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
)

select
(select nvl(max(cdestruturacarreira),0) from ecadestruturacarreira) + rownum as cdestruturacarreira,
c.dtiniciovigencia as dtiniciovigencia,
null as cdacumvinculo,
a.cdagrupamento as cdagrupamento,
i.cditemcarreira as cditemcarreira,
null as cdestruturacarreirapai,
null as cdestruturacarreiracarreira,
null as cdestruturacarreiragrupo,
null as cdestruturacarreiracargo,
null as cdestruturacarreiraclasse,
null as cdestruturacarreiracomp,
null as cdestruturacarreiraespec,
'N' as flultimo,
null as cdhierarquiapai,
null as cdtipoitemcarreiraapo,
qlp.cddescricaoqlp as cddescricaoqlp,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao,
'N' as flanulado,
null as dtanulado,
null as cdquadrosirh
from carreiras c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 1
							 and i.deitemcarreira = c.decarreira
inner join reltrab on reltrab.nmrelacaotrabalho = c.nmrelacaotrabalho
inner join qlp on qlp.cdagrupamento = a.cdagrupamento and qlp.cdrelacaotrabalho = reltrab.cdrelacaotrabalho
left join carreria_existe crexiste on crexiste.cdagrupamento = a.cdagrupamento and crexiste.deitemcarreira = c.decarreira
where crexiste.cdagrupamento is null
;

--- Criar ecadEstruturaCarreira, incluir os Cargos na Carreira
insert into ecadestruturacarreira
with vinculos as (
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,
 null as decarreira,
 translate(regexp_replace(upper(trim(nmgrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 null as decargo,
 null as declasse,
 null as decompetencia,
 null as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahorariacom as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 trim(nunivel) as nunivel,
 nureferencia as nureferencia,
 translate(regexp_replace(upper(trim(nvl(nmopcaoremuneracao,'PELO CARGO COMISSIONADO'))), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmopcaoremuneracao
from sigrhmig.emigvinculocomissionado
union
select
 translate(regexp_replace(upper(trim(sgorgao)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as sgorgao,
 matricula_legado as numatriculalegado,
 to_date(dtadmissao, 'YYYY-MM-DD') as dtadmissao,
 to_date(dtdesligamento, 'YYYY-MM-DD') as dtdesligamento,

 translate(regexp_replace(upper(trim(decarreira)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decarreira,
 translate(regexp_replace(upper(trim(degrupoocupacional)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as degrupoocupacional,
 translate(regexp_replace(upper(trim(decargo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decargo,
 translate(regexp_replace(upper(trim(declasse)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as declasse,
 translate(regexp_replace(upper(trim(decompetencia)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as decompetencia,
 translate(regexp_replace(upper(trim(deespecialidade)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as deespecialidade,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmregimetrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimetrabalho,
 translate(regexp_replace(upper(trim(nmregimeprevidenciario)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmregimeprevidenciario,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo,
 nmtipocargahoraria as nmtipocargahoraria,
 nucargahoraria as nucargahoraria,
 nunivelpagamento as nunivel,
 nureferenciapagamento as nureferencia,
 null as nmopcaoremuneracao 
from sigrhmig.emigvinculoefetivo
),
cargos as (
select distinct
 a.sgagrupamento as sgagrupamento,
 decarreira,
 decargo
from vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and decarreira is not null
  and decargo is not null
order by a.sgagrupamento, decarreira, decargo
),
carrerias as (
select
 a.sgagrupamento,
 i.deitemcarreira as decarreira,
 e.cdestruturacarreira,
 e.dtiniciovigencia,
 e.cditemcarreira,
 e.cdestruturacarreirapai,
 e.cdestruturacarreiracarreira,
 e.cddescricaoqlp
from ecadestruturacarreira e 
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
inner join ecaditemcarreira i on i.cdagrupamento = e.cdagrupamento and i.cdtipoitemcarreira = 1 and i.cditemcarreira = e.cditemcarreira
),
cargo_existe as (
select
 a.sgagrupamento,
 icar.deitemcarreira as decarreira,
 ic.deitemcarreira as decargo
from ecadestruturacarreira e 
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
inner join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
inner join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
inner join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
)

select
(select max(cdestruturacarreira) from ecadestruturacarreira) + rownum as cdestruturacarreira,
carr.dtiniciovigencia as dtiniciovigencia,
null as cdacumvinculo,
a.cdagrupamento as cdagrupamento,
i.cditemcarreira as cditemcarreira,
carr.cdestruturacarreira as cdestruturacarreirapai,
carr.cdestruturacarreira as cdestruturacarreiracarreira,
null as cdestruturacarreiragrupo,
null as cdestruturacarreiracargo,
null as cdestruturacarreiraclasse,
null as cdestruturacarreiracomp,
null as cdestruturacarreiraespec,
'S' as flultimo,
null as cdhierarquiapai,
null as cdtipoitemcarreiraapo,
carr.cddescricaoqlp as cddescricaoqlp,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
systimestamp as dtultalteracao,
'N' as flanulado,
null as dtanulado,
null as cdquadrosirh
from cargos c
inner join ecadagrupamento a on a.sgagrupamento = c.sgagrupamento
inner join carrerias carr on carr.sgagrupamento = c.sgagrupamento and carr.decarreira = c.decarreira
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento
                             and i.cdtipoitemcarreira = 3
                             and i.deitemcarreira = c.decargo
left join cargo_existe cexist on cexist.sgagrupamento = a.sgagrupamento
                             and cexist.decarreira = c.decarreira
                             and cexist.decargo = c.decargo
where cexist.sgagrupamento is null
;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '2-EstuturaCarreira' as Grupo,  '2.1-ecadItemCarreira' as Conceito, count(*) as Qtde from ecadItemCarreira union
select '2-EstuturaCarreira' as Grupo,  '2.2-ecadEstruturaCarreira' as Conceito, count(*) as Qtde from ecadEstruturaCarreira
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'ecaditemcarreira'              as Tab, 'SCADITEMCARREIRA'              as Seq, nvl(max(cditemcarreira),0) as Qtde from ecadItemCarreira union
select 'ecadestruturacarreira'         as Tab, 'SCADESTRUTURACARREIRA'         as Seq, nvl(max(cdestruturacarreira),0) as Qtde from ecadEstruturaCarreira
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
'SCADITEMCARREIRA',
'SCADESTRUTURACARREIRA'
);
