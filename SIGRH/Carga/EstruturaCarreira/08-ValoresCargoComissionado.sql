--- Criar Tabela de Valores dos Cargos Comissionados com base nos Layout de Cadastro dos Vinculos
--- Conceitos envolvidos:
--- - Versao Tabela de Valores dos Cargos Comissionados por Agrupamento (epagValorRefCCOAgrupOrgVersao)
--- - Vigencia da Versao Tabela de Valores dos Cargos Comissionados por Agrupamento (epagHistValorRefCCOAgrupOrgVer)
--- - Valores dos Nivel/Referencia dos Cargos Comissionados por Agrupamento (epagValorRefCCOAgrupOrgEspec)


-- Excluir os Registros dos Conceitos Envolvidos na Ordem de Filho para Pais
--delete epagValorRefCCOAgrupOrgEspec;
--delete epagHistValorRefCCOAgrupOrgVer;
--delete epagValorRefCCOAgrupOrgVersao;

--- Criar a Lista de Versao Tabela de Valores dos Cargos Comissionados por Agrupamento
--- Criar a Lsita de Vigencias da Versao Tabela de Valores dos Cargos Comissionados por Agrupamento
insert all
into epagvalorrefccoagruporgversao values(
cdvalorrefccoagruporgversao,
cdagrupamento,
cdorgao,
nuversao
)

into epaghistvalorrefccoagruporgver values(
cdhistvalorrefccoagruporgver,
cdvalorrefccoagruporgversao,
nuanoiniciovigencia,
numesiniciovigencia,
nuanofimvigencia,
numesfimvigencia,
cddocumento,
cdmeiopublicacao,
cdtipopublicacao,
nupublicacao,
dtpublicacao,
nupaginicial,
deoutromeio,
nucpfcadastrador,
dtinclusao,
dtultalteracao
)

with agrupamentos_vinculos as (
select distinct
 nvl2(a.cdagrupamento,a.sgagrupamento,'INDIR-DETRAM/RR') as sgagrupamento
from sigrhmig.emigvinculocomissionado v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
order by 1
),
existe as (
select
 cdagrupamento,
 nuversao
from epagvalorrefccoagruporgversao
where cdorgao is null
  and nuversao = '1'
)
select
 (select nvl(max(cdvalorrefccoagruporgversao),0) from epagvalorrefccoagruporgversao) + rownum as cdvalorrefccoagruporgversao,
 a.cdagrupamento as cdagrupamento,
 null as cdorgao,
 '1' as nuversao,

 (select nvl(max(cdhistvalorrefccoagruporgver),0) from epaghistvalorrefccoagruporgver) + rownum as cdhistvalorrefccoagruporgver,
 '1901' as nuanoiniciovigencia,
 '1' as numesiniciovigencia,
 null as nuanofimvigencia,
 null as numesfimvigencia,
 null as cddocumento,
 null as cdmeiopublicacao,
 null as cdtipopublicacao,
 null as nupublicacao,
 null as dtpublicacao,
 null as nupaginicial,
 null as deoutromeio,
 '11111111111' as nucpfcadastrador,
 trunc(sysdate) as dtinclusao,
 systimestamp as dtultalteracao

from agrupamentos_vinculos v
inner join ecadagrupamento a on a.sgagrupamento = v.sgagrupamento
left join existe on existe.cdagrupamento = a.cdagrupamento
where existe.cdagrupamento is null
;


--- Criar Valores dos Nivel/Referencia dos Cargos Comissionados por Agrupamento (epagValorRefCCOAgrupOrgEspec)
insert into epagvalorrefccoagruporgespec
with valores_cargos_comissionados as (
select distinct
 nvl2(a.cdagrupamento,a.sgagrupamento,'INDIR-DETRAM/RR') as sgagrupamento,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho,
 nunivel,
 nureferencia
from sigrhmig.emigvinculocomissionado v
left join vcadorgao o on o.sgorgao = v.sgorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where nunivel is not null and nunivel <> '0'
  and nureferencia is not null and nureferencia <> 0
order by 1, 2, 3, 4
),
reltrab as (
select
 cdrelacaotrabalho,
 translate(regexp_replace(upper(trim(nmrelacaotrabalho)), '[[:space:]]+', chr(32)),
                 'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
                 'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz') as nmrelacaotrabalho

from ecadrelacaotrabalho
),
existe as (
select
 vvlcco.cdagrupamento,
 vlcco.nucodigo,
 vlcco.nunivel,
 vlcco.cdrelacaotrabalho
from epagvalorrefccoagruporgespec vlcco
inner join epaghistvalorrefccoagruporgver hvvlcco on hvvlcco.cdhistvalorrefccoagruporgver = vlcco.cdhistvalorrefccoagruporgver
                                                 and hvvlcco.nuanoiniciovigencia = '1901'
                                                 and hvvlcco.numesiniciovigencia = '01'
inner join epagvalorrefccoagruporgversao vvlcco on vvlcco.cdvalorrefccoagruporgversao = hvvlcco.cdvalorrefccoagruporgversao
                                               and vvlcco.nuversao = 1
)

select
 (select nvl(max(cdvalorrefccoagruporgespec),0) from epagvalorrefccoagruporgespec) + rownum as cdvalorrefccoagruporgespec,
 hvvlcco.cdhistvalorrefccoagruporgver,
 vlcco.nunivel as nucodigo,
 vlcco.nureferencia as nunivel,
 reltrab.cdrelacaotrabalho as cdrelacaotrabalho,
 vlcco.nunivel as decodigonivel,
 0 as vlfixo,
 null asdeexpressaocalculo,
 systimestamp as dtultalteracao
from valores_cargos_comissionados vlcco
inner join reltrab on reltrab.nmrelacaotrabalho = vlcco.nmrelacaotrabalho
inner join ecadagrupamento a on a.sgagrupamento = vlcco.sgagrupamento
inner join reltrab on reltrab.nmrelacaotrabalho = vlcco.nmrelacaotrabalho
inner join epagvalorrefccoagruporgversao vvlcco on vvlcco.cdagrupamento = a.cdagrupamento
                                               and vvlcco.cdorgao is null
                                               and vvlcco.nuversao = 1
inner join epaghistvalorrefccoagruporgver hvvlcco on vvlcco.cdvalorrefccoagruporgversao = hvvlcco.cdvalorrefccoagruporgversao
                                                 and hvvlcco.nuanoiniciovigencia = '1901'
                                                 and hvvlcco.numesiniciovigencia = '01'

left join existe on existe.cdagrupamento = a.cdagrupamento
                and existe.nucodigo = vlcco.nunivel
                and existe.nunivel = vlcco.nureferencia
                and existe.cdrelacaotrabalho = reltrab.cdrelacaotrabalho
;

--delete epagValorRefCCOAgrupOrgEspec;
--delete epagHistValorRefCCOAgrupOrgVer;
--delete epagValorRefCCOAgrupOrgVersao;

-- Listar Quantidade de Registros Incluisdos nos Conceitos Envolvidos
select '8-Valores dos Cargo Comissionado' as Grupo, '8.1-epagValorRefCCOAgrupOrgVersao'  as Conceito, count(*) as Qtde from epagvalorrefccoagruporgversao  union
select '8-Valores dos Cargo Comissionado' as Grupo, '8.2-epagHistValorRefCCOAgrupOrgVer' as Conceito, count(*) as Qtde from epaghistvalorrefccoagruporgver union
select '8-Valores dos Cargo Comissionado' as Grupo, '8.3-epagValorRefCCOAgrupOrgEspec'   as Conceito, count(*) as Qtde from epagvalorrefccoagruporgespec
order by 1, 2
;

-- Ajustar a Sequence dos Conceitos Envolvidos para o Total de Registros
declare cursor c1 is
select 'epagvalorrefccoagruporgversao'  as Tab, 'SPAGVALORREFCCOAGRUPORGVERSAO'  as Seq, nvl(max(cdvalorrefccoagruporgversao),0)  as Qtde from epagvalorrefccoagruporgversao  union
select 'epaghistvalorrefccoagruporgver' as Tab, 'SPAGHISTVALORREFCCOAGRUPORGVER' as Seq, nvl(max(cdhistvalorrefccoagruporgver),0) as Qtde from epaghistvalorrefccoagruporgver union
select 'epagvalorrefccoagruporgespec'   as Tab, 'SPAGVALORREFCCOAGRUPORGESPEC'   as Seq, nvl(max(cdvalorrefccoagruporgespec),0)   as Qtde from epagvalorrefccoagruporgespec
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
'SPAGVALORREFCCOAGRUPORGVERSAO',
'SPAGHISTVALORREFCCOAGRUPORGVER',
'SPAGVALORREFCCOAGRUPORGESPEC'
);