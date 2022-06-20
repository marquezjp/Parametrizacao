--- Criar Cargos Comissionados com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Grupo Ocupacional dos Cargos Comissionados (ecadGrupoOcupacional)
--- - Relacionamento Grupo Ocupacional e Cargo Comissionados (ecadCargoComissionado)
--- - Cargo Comissionados (ecadEvolucaoCargoComissionado)
--- - Lista de Cargas Horárias Permitidas (ecadEvolucaoCCOCargaHoraria)
--- - Naturezas de Vínculo Permitidas (ecadEvolucaoCCONatVinc)
--- - Relações de Trabalho Permitidas (ecadEvolucaoCCORelTrab)

-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete ecadevolucaoccovalorref;
--delete ecadevolucaocconatvinc;
--delete ecadevolucaoccoreltrab;
--delete ecadevolucaoccocargahoraria;
--delete ecadevolucaocargocomissionado;
--delete ecadcargocomissionado;
--delete ecadgrupoocupacional;

--- Criar ecadGrupoOcupacional
insert into ecadgrupoocupacional
with grupoocupacional as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.degrupoocupacional as nmgrupoocupacional
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.nmrelacaotrabalho in ('COMISSIONADO')
order by
 a.sgagrupamento,
 v.degrupoocupacional
),
grupoocupacional_existe as (
select
 a.sgagrupamento,
 g.nmgrupoocupacional
from ecadgrupoocupacional g
inner join ecadagrupamento a on a.cdagrupamento = g.cdagrupamento
)
select
(select nvl(max(cdgrupoocupacional),0) from ecadgrupoocupacional) + rownum as cdgrupoocupacional,
a.cdagrupamento as cdagrupamento,
g.nmgrupoocupacional as nmgrupoocupacional,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
'N' as flanulado,
null as dtanulado,
systimestamp as dtultalteracao,
'N' as flrecuperacaohist
from grupoocupacional g
inner join ecadagrupamento a on a.sgagrupamento = g.sgagrupamento
left join grupoocupacional_existe gexiste on gexiste.sgagrupamento = g.sgagrupamento and gexiste.nmgrupoocupacional = g.nmgrupoocupacional
where gexiste.sgagrupamento is null
;

-- Criar ecadCargoComissionado e ecadEvolucaoCargoComissionado
declare
  pcdcargocomissionado NUMBER;
  pcdevolucaocargocomissionado NUMBER;
  
  cursor cco is
    with cargocomissionado as (
    select
     a.sgagrupamento as sgagrupamento,
     v.degrupoocupacional as nmgrupoocupacional,
     v.decargo as decargocomissionado,
     v.nmrelacaotrabalho as nmrelacaotrabalho,
     trunc(last_day(min(dtadmissao))-1, 'mm') as dtiniciovigencia,
     case
      when max(case when dtdesligamento is null then 1 else 0 end) = 1 then null
      else last_day(max(nvl(dtdesligamento,last_day(sysdate))))
     end as dtfimvigencia,
     111415 as nuocupacao,
     'SEMANAL' as nmtipocargahoraria
    from sigrh_rr_vinculos v
    left join vcadorgao o on o.sgorgao = v.sgorgao
    left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
    where o.cdorgao is not null
      and v.degrupoocupacional is not null
      and v.decargo is not null
      and v.nmrelacaotrabalho in ('COMISSIONADO')
    group by
     a.sgagrupamento,
     v.degrupoocupacional,
     v.decargo,
     v.nmrelacaotrabalho
    order by
     a.sgagrupamento,
     v.degrupoocupacional,
     v.decargo
    ),
    reltrab as (
    select
     cdrelacaotrabalho,
     translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                     'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                     'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho
    
    from ecadrelacaotrabalho
    ),
    cargocomissionado_existe as (
    select
    a.sgagrupamento as sgagrupamento,
    gp.nmgrupoocupacional as nmgrupoocupacional,
    ecco.decargocomissionado as decargocomissionado
    from ecadevolucaocargocomissionado ecco
    inner join ecadcargocomissionado cco on cco.cdcargocomissionado = ecco.cdcargocomissionado
    inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
    inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
    )
    select
    gp.cdgrupoocupacional as cdgrupoocupacional,
    cco.decargocomissionado as decargocomissionado,
    qlp.cddescricaoqlp as cddescricaoqlp,
    cbo.cdocupacao as cdocupacao,
    cco.dtiniciovigencia as dtiniciovigencia,
    cco.dtfimvigencia as dtfimvigencia,
    tpcho.cdtipocargahoraria as cdtipocargahoraria
    from cargocomissionado cco
    inner join ecadagrupamento a on a.sgagrupamento = cco.sgagrupamento
    inner join ecadgrupoocupacional gp on gp.cdagrupamento = a.cdagrupamento and gp.nmgrupoocupacional = cco.nmgrupoocupacional
    inner join ecadocupacao cbo on cbo.nuocupacao = cco.nuocupacao
    inner join ecadtipocargahoraria tpcho on upper(tpcho.nmtipocargahoraria) = upper(cco.nmtipocargahoraria)
    inner join reltrab on reltrab.nmrelacaotrabalho = cco.nmrelacaotrabalho
    inner join emovdescricaoqlp qlp on qlp.cdagrupamento = a.cdagrupamento and qlp.cdrelacaotrabalho = reltrab.cdrelacaotrabalho
    left join cargocomissionado_existe ccogexiste on ccogexiste.sgagrupamento = cco.sgagrupamento
                                                 and ccogexiste.nmgrupoocupacional = cco.nmgrupoocupacional
                                                 and ccogexiste.decargocomissionado = cco.decargocomissionado
    where ccogexiste.sgagrupamento is null
    ;

begin
  for cargo in cco
    loop

      select nvl(max(cdcargocomissionado),0) into pcdcargocomissionado from ecadcargocomissionado;
      select nvl(max(cdevolucaocargocomissionado),0) into pcdevolucaocargocomissionado from ecadevolucaocargocomissionado;
      
      insert into ecadcargocomissionado
      values (
      pcdcargocomissionado + 1,
      cargo.cdgrupoocupacional
      )
      ;
      
      insert into ecadevolucaocargocomissionado
      values (
      pcdevolucaocargocomissionado + 1,
      pcdcargocomissionado + 1,
      cargo.decargocomissionado,
      cargo.cddescricaoqlp,
      null,
      cargo.cdocupacao,
      cargo.dtiniciovigencia,
      cargo.dtfimvigencia,
      null,
      'N',
      'N',
      'N',
      'N',
      'N',
      cargo.cdtipocargahoraria,
      null,
      null,
      null,
      null,
      '1',
      null,
      '1',
      null,
      null,
      '11111111111',
      trunc(sysdate),
      'N',
      null,
      systimestamp,
      null,
      'N',
      'N',
      null,
      null,
      null,
      null,
      'N'
      )
      ;

    end loop;
end;

--- Criar ecadEvolucaoCCOCargaHoraria
insert into ecadevolucaoccocargahoraria
with cargocomissionado as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.degrupoocupacional as nmgrupoocupacional,
 v.decargo as decargocomissionado,
 v.nucargahoraria as nucargahoraria
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.decargo is not null
  and v.nmrelacaotrabalho in ('COMISSIONADO')
order by
 a.sgagrupamento,
 v.degrupoocupacional,
 v.decargo
),
cho_existe as (
select
a.sgagrupamento,
gp.nmgrupoocupacional,
ecco.decargocomissionado,
cho.nucargahoraria
from ecadevolucaoccocargahoraria cho
inner join ecadevolucaocargocomissionado ecco on ecco.cdevolucaocargocomissionado = cho.cdevolucaocargocomissionado
inner join ecadcargocomissionado cco on cco.cdcargocomissionado = ecco.cdcargocomissionado
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
)
select
(select nvl(max(cdevolucaoccocargahoraria),0) from ecadevolucaoccocargahoraria) + rownum as cdevolucaoccocargahoraria,
ecco.cdevolucaocargocomissionado as cdevolucaocargocomissionado,
cco.nucargahoraria as nucargahoraria,
'S' as flpadrao
from cargocomissionado cco
inner join ecadagrupamento a on a.sgagrupamento = cco.sgagrupamento
inner join ecadgrupoocupacional gp on gp.cdagrupamento = a.cdagrupamento and gp.nmgrupoocupacional = cco.nmgrupoocupacional
inner join ecadevolucaocargocomissionado ecco on ecco.decargocomissionado = cco.decargocomissionado
inner join ecadcargocomissionado rcco on rcco.cdcargocomissionado = ecco.cdcargocomissionado and rcco.cdgrupoocupacional = gp.cdgrupoocupacional
left join cho_existe on cho_existe.sgagrupamento = cco.sgagrupamento
                    and cho_existe.nmgrupoocupacional = cco.nmgrupoocupacional
                    and cho_existe.decargocomissionado = cco.decargocomissionado
                    and cho_existe.nucargahoraria = cco.nucargahoraria
where cho_existe.sgagrupamento is null
;

--- Criar ecadEvolucaoCCONatVinc
insert into ecadevolucaocconatvinc
with cargocomissionado as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.degrupoocupacional as nmgrupoocupacional,
 v.decargo as decargocomissionado,
 v.nmnaturezavinculo as nmnaturezavinculo
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.decargo is not null
  and v.nmrelacaotrabalho in ('COMISSIONADO')
order by
 a.sgagrupamento,
 v.degrupoocupacional,
 v.decargo
),
natvinc as (
select
 cdnaturezavinculo,
 translate(regexp_replace(upper(trim(nmnaturezavinculo)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmnaturezavinculo

from ecadnaturezavinculo
),
natvinc_existe as (
select
a.sgagrupamento,
gp.nmgrupoocupacional,
ecco.decargocomissionado,
natvinc.nmnaturezavinculo
from ecadevolucaocconatvinc cconatvinc
inner join ecadevolucaocargocomissionado ecco on ecco.cdevolucaocargocomissionado = cconatvinc.cdevolucaocargocomissionado
inner join ecadcargocomissionado cco on cco.cdcargocomissionado = ecco.cdcargocomissionado
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
inner join natvinc on natvinc.cdnaturezavinculo = cconatvinc.cdnaturezavinculo
)
select
ecco.cdevolucaocargocomissionado as cdevolucaocargocomissionado,
natvinc.cdnaturezavinculo as cdnaturezavinculo
from cargocomissionado cco
inner join ecadagrupamento a on a.sgagrupamento = cco.sgagrupamento
inner join ecadgrupoocupacional gp on gp.cdagrupamento = a.cdagrupamento and gp.nmgrupoocupacional = cco.nmgrupoocupacional
inner join ecadevolucaocargocomissionado ecco on ecco.decargocomissionado = cco.decargocomissionado
inner join ecadcargocomissionado rcco on rcco.cdcargocomissionado = ecco.cdcargocomissionado and rcco.cdgrupoocupacional = gp.cdgrupoocupacional
inner join natvinc on natvinc.nmnaturezavinculo = cco.nmnaturezavinculo
left join natvinc_existe on natvinc_existe.sgagrupamento = cco.sgagrupamento
                        and natvinc_existe.nmgrupoocupacional = cco.nmgrupoocupacional
                        and natvinc_existe.decargocomissionado = cco.decargocomissionado
                        and natvinc_existe.nmnaturezavinculo = cco.nmnaturezavinculo
where natvinc_existe.sgagrupamento is null
;

--- Criar ecadEvolucaoCCORelTrab
insert into ecadevolucaoccoreltrab
with cargocomissionado as (
select distinct
 a.sgagrupamento as sgagrupamento,
 v.degrupoocupacional as nmgrupoocupacional,
 v.decargo as decargocomissionado,
 v.nmrelacaotrabalho as nmrelacaotrabalho
from sigrh_rr_vinculos v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where o.cdorgao is not null
  and v.degrupoocupacional is not null
  and v.decargo is not null
  and v.nmrelacaotrabalho in ('COMISSIONADO')
order by
 a.sgagrupamento,
 v.degrupoocupacional,
 v.decargo
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
reltrab_existe as (
select
a.sgagrupamento,
gp.nmgrupoocupacional,
ecco.decargocomissionado,
reltrab.nmrelacaotrabalho
from ecadevolucaoccoreltrab ccoreltrab
inner join ecadevolucaocargocomissionado ecco on ecco.cdevolucaocargocomissionado = ccoreltrab.cdevolucaocargocomissionado
inner join ecadcargocomissionado cco on cco.cdcargocomissionado = ecco.cdcargocomissionado
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
inner join reltrab on reltrab.cdrelacaotrabalho = ccoreltrab.cdrelacaotrabalho
)
select
ecco.cdevolucaocargocomissionado as cdevolucaocargocomissionado,
reltrab.cdrelacaotrabalho as cdrelacaotrabalho
from cargocomissionado cco
inner join ecadagrupamento a on a.sgagrupamento = cco.sgagrupamento
inner join ecadgrupoocupacional gp on gp.cdagrupamento = a.cdagrupamento and gp.nmgrupoocupacional = cco.nmgrupoocupacional
inner join ecadevolucaocargocomissionado ecco on ecco.decargocomissionado = cco.decargocomissionado
inner join ecadcargocomissionado rcco on rcco.cdcargocomissionado = ecco.cdcargocomissionado and rcco.cdgrupoocupacional = gp.cdgrupoocupacional
inner join reltrab on reltrab.nmrelacaotrabalho = cco.nmrelacaotrabalho
left join reltrab_existe on reltrab_existe.sgagrupamento = cco.sgagrupamento
                        and reltrab_existe.nmgrupoocupacional = cco.nmgrupoocupacional
                        and reltrab_existe.decargocomissionado = cco.decargocomissionado
                        and reltrab_existe.nmrelacaotrabalho = cco.nmrelacaotrabalho
where reltrab_existe.sgagrupamento is null
;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '5-Cargo Comissionado' as Grupo, '5.1-ecadGrupoOcupacional'          as Conceito, count(*) as Qtde from ecadgrupoocupacional          union
select '5-Cargo Comissionado' as Grupo, '5.2-ecadCargoComissionado'         as Conceito, count(*) as Qtde from ecadcargocomissionado         union
select '5-Cargo Comissionado' as Grupo, '5.3-ecadEvolucaoCargoComissionado' as Conceito, count(*) as Qtde from ecadevolucaocargocomissionado union
select '5-Cargo Comissionado' as Grupo, '5.4-ecadEvolucaoCCOCargaHoraria'   as Conceito, count(*) as Qtde from ecadevolucaoccocargahoraria   union
select '5-Cargo Comissionado' as Grupo, '5.5-ecadEvolucaoCCONatVinc'        as Conceito, count(*) as Qtde from ecadevolucaocconatvinc        union
select '5-Cargo Comissionado' as Grupo, '5.6-ecadEvolucaoCCORelTrab'        as Conceito, count(*) as Qtde from ecadevolucaoccoreltrab        union
select '5-Cargo Comissionado' as Grupo, '5.7-ecadEvolucaoCCOValorRef'       as Conceito, count(*) as Qtde from ecadevolucaoccovalorref
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'ecadgrupoocupacional'          as Tab, 'SCADGRUPOOCUPACIONAL'          as Seq, nvl(max(cdgrupoocupacional),0)          as Qtde from ecadgrupoocupacional          union
select 'ecadcargocomissionado'         as Tab, 'SCADCARGOCOMISSIONADO'         as Seq, nvl(max(cdcargocomissionado),0)         as Qtde from ecadcargocomissionado         union
select 'ecadEvolucaoCargoComissionado' as Tab, 'SCADEVOLUCAOCARGOCOMISSIONADO' as Seq, nvl(max(cdevolucaocargocomissionado),0) as Qtde from ecadevolucaocargocomissionado union
select 'ecadevolucaoccocargahoraria'   as Tab, 'SCADEVOLUCAOCCOCARGAHORARIA'   as Seq, nvl(max(cdevolucaoccocargahoraria),0)   as Qtde from ecadevolucaoccocargahoraria   union
select 'ecadevolucaoccovalorref'       as Tab, 'SCADEVOLUCAOCCOVALORREF'       as Seq, nvl(max(cdevolucaoccovalorref),0)       as Qtde from ecadevolucaoccovalorref 
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
'SCADGRUPOOCUPACIONAL',
'SCADCARGOCOMISSIONADO',
'SCADEVOLUCAOCARGOCOMISSIONADO',
'SCADEVOLUCAOCCOCARGAHORARIA',
'SCADEVOLUCAOCCOVALORREF'
);

