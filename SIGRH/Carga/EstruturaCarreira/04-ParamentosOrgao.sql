--- Atualizar as Parametrizações dos Órgãos com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Lista de Carreiras Permitidas no Órgão (sigrh_rr_vinculos)
--- - Regimes de Trabalho Permitidos (ecadOrgaoRegTrabalho)
--- - Regimes Previdenciários Permitidos (ecadOrgaoRegPrev)
--- - Relação de Trabalho Permitidas (ecadOrgaoRelTrabalho)
--- - Naturezas do Vínculo Permitidas (ecadOrgaoNatVinculo)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadOrgaoCarreira;
--delete ecadOrgaoRegTrabalho;
--delete ecadOrgaoRegPrev;
--delete ecadOrgaoRelTrabalho;
--delete ecadOrgaoNatVinculo;

--- Criar a Lista de Carreiras Permitidas para o Orgao
insert into sigrh_rr_vinculos
with carreiras as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.decarreira,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia
from sigrh_rr_vinculos_jotape v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.decarreira is not null
group by a.sgagrupamento, o.sgorgao, v.decarreira
order by a.sgagrupamento, o.sgorgao, v.decarreira
),
carreria_existe as (
select
 a.sgagrupamento,
 o.sgorgao,
 i.deitemcarreira as decarreira
from sigrh_rr_vinculos oc
inner join vcadorgao o on o.cdorgao = oc.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
inner join ecadestruturacarreira e on e.cdagrupamento = a.cdagrupamento and e.cdestruturacarreira = oc.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento and i.cditemcarreira = e.cditemcarreira
)

select
(select nvl(max(cdorgaocarreira),0) from sigrh_rr_vinculos) + rownum as cdorgaocarreira,
o.cdorgao as cdorgao,
e.cdestruturacarreira as cdestruturacarreira,
case when c.dtiniciovigencia < o.dtiniciovigencia then o.dtiniciovigencia else c.dtiniciovigencia end as dtiniciovigencia,
null as dtfimvigencia,
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

--- Criar a Lista de Regimes de Trabalho Permitidos para o Orgao
insert into ecadorgaoregtrabalho
with orgaoregimetrabalho as (
select
 a.sgagrupamento as sgagrupamento,
 o.sgorgao as sgorgao,
 v.nmregimetrabalho,
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia
from sigrh_rr_vinculos_jotape v
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
null as dtfimvigencia,
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
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia
from sigrh_rr_vinculos_jotape v
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
null as dtfimvigencia,
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
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia
from sigrh_rr_vinculos_jotape v
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
null as dtfimvigencia,
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
 trunc(last_day(min(v.dtadmissao))-1, 'mm') as dtiniciovigencia
from sigrh_rr_vinculos_jotape v
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
null as dtfimvigencia,
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

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '4-ParametrosOrgao' as Grupo,  '4.1-ecadOrgaoCarreira'     as Conceito, count(*) as Qtde from ecadOrgaoCarreira union
select '4-ParametrosOrgao' as Grupo,  '4.2-ecadOrgaoRegTrabalho'  as Conceito, count(*) as Qtde from ecadOrgaoRegTrabalho union
select '4-ParametrosOrgao' as Grupo,  '4.3-ecadOrgaoRegPrev'      as Conceito, count(*) as Qtde from ecadOrgaoRegPrev union
select '4-ParametrosOrgao' as Grupo,  '4.4-ecadOrgaorRelTrabalho' as Conceito, count(*) as Qtde from ecadOrgaoRelTrabalho union
select '4-ParametrosOrgao' as Grupo,  '4.5-ecadOrgaoNatVinculo'   as Conceito, count(*) as Qtde from ecadOrgaoNatVinculo
order by 1, 2

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'ecadorgaocarreira'    as Tab, 'SCADORGAOCARREIRA'    as Seq, nvl(max(cdorgaocarreira),0)    as Qtde from ecadOrgaoCarreira union
select 'ecadorgaoregtrabalho' as Tab, 'SCADORGAOREGTRABALHO' as Seq, nvl(max(cdorgaoregtrabalho),0) as Qtde from ecadOrgaoRegTrabalho union
select 'ecadorgaoregprev'     as Tab, 'SCADORGAOREGPREV'     as Seq, nvl(max(cdorgaoregprev),0)     as Qtde from ecadOrgaoRegPrev union
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
'SCADORGAOREGTRABALHO',
'SCADORGAOREGPREV',
'SCADORGAORELTRABALHO',
'SCADORGAONATVINCULO'
);