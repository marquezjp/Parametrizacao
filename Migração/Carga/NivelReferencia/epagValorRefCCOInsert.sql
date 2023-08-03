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