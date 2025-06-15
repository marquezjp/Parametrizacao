declare cursor c1 is
select 'eafaafastamentovinculo'     as Tab, 'SAFAAFASTAMENTOVINCULO'     as Seq, nvl(max(cdafastamento),0)            as Qtde from eafaafastamentovinculo
order by 1, 2;

begin
  for item in c1
    loop
      dbms_output.put_line('Tabname = ' || item.Tab || ' Sequence = ' || item.Seq || ' Qtde = ' || item.Qtde);
    
      execute immediate 'alter sequence ' || item.Seq || ' restart start with ' || case when item.Qtde = 0 then 1 else item.Qtde end;
      execute immediate 'analyze table ' || upper(item.Tab) || ' compute statistics';

    end loop;
end;

--Lista Vinculos 
select count(*)
from ecadvinculo
where dtdesligamento is null
  and cdvinculo not in (select distinct cdvinculo from (
select distinct cdvinculo from epagcapahistrubricavinculo
where cdfolhapagamento in (select cdfolhapagamento from epagfolhapagamento
where nuanoreferencia = 2022 and numesreferencia = 05)
  and vlproventos != 0
union
select distinct cdvinculo from epaghistoricorubricavinculo
where cdfolhapagamento in (select cdfolhapagamento from epagfolhapagamento
where nuanoreferencia = 2022 and numesreferencia = 05)
));

/*
insert into eafaafastamentovinculo (
cdafastamento,
cdvinculo,
fltipoafastamento,
cdmotivoafasttemporario,
dtinicio,
flretornoconfirmado,
flretornoindefinido,
nucpfcadastrador,
dtinclusao,
flanulado,
dtultalteracao,
flremunerado,
flalteradosemlaudo,
flcertidaotempocontribuicao,
flrecuperacaohistorico,
flpgtocontribprev
)
*/

with
folhas as (
select cdfolhapagamento from epagfolhapagamento
where nuanoreferencia = 2022 and numesreferencia = 05
),
lista_vinculos_sem_pagamentos as (
select v.cdvinculo from ecadvinculo v
left join  (
select distinct cdvinculo from epagcapahistrubricavinculo capa
inner join folhas f on f.cdfolhapagamento = capa.cdfolhapagamento
where vlproventos != 0
union
select distinct cdvinculo from epaghistoricorubricavinculo pag
inner join folhas f on f.cdfolhapagamento = pag.cdfolhapagamento
) pag on pag.cdvinculo = v.cdvinculo
where v.dtdesligamento is null
  and pag.cdvinculo is null
),
lista_vinculos_afastamento as (
select
 a.cdagrupamento,
 o.cdorgao,
 v.cdvinculo,
 'TEMPORARIO SEM REMUNERACAO - CALCULO PARALELO' as nmgrupomotivoafastamento,
 'PARALELO DA FOLHA SEM REMUNERACAO' as demotivoafasttemporario,
 to_date('30/04/2022','DD/MM/YYYY') as dtinicio
from ecadvinculo v
inner join lista_vinculos_sem_pagamentos sp on sp.cdvinculo = v.cdvinculo
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
where dtdesligamento is null
),
existe as (
select
cdvinculo,
cdmotivoafasttemporario,
dtinicio
from eafaafastamentovinculo
)

select
(select nvl(max(cdafastamento),0) from eafaafastamentovinculo) + rownum as cdafastamento,
a.cdvinculo as cdvinculo,
'T' as fltipoafastamento,
afamottemp.cdmotivoafasttemporario as cdmotivoafasttemporario,
a.dtinicio as dtinicio,
'N' as flretornoconfirmado,
'N' as flretornoindefinido,
'11111111111' as nucpfcadastrador,
trunc(sysdate) as dtinclusao,
'N' as flanulado,
systimestamp as dtultalteracao,
'N' as flremunerado,
'N' as flalteradosemlaudo,
'N' as flcertidaotempocontribuicao,
'N' as flrecuperacaohistorico,
'N' as flpgtocontribprev
from lista_vinculos_afastamento a
inner join eafahistmotivoafasttemp afamottemphist on afamottemphist.demotivoafasttemporario = a.demotivoafasttemporario
inner join eafamotivoafasttemporario afamottemp on afamottemp.cdmotivoafasttemporario = afamottemphist.cdmotivoafasttemporario
inner join eafagrupomotivoafastamento afagrumot on afagrumot.cdgrupomotivoafastamento = afamottemphist.cdgrupomotivoafastamento
                                               and afagrumot.nmgrupomotivoafastamento = a.nmgrupomotivoafastamento
                                               and afagrumot.cdagrupamento = a.cdagrupamento
left join existe on existe.cdvinculo = a.cdvinculo
                and existe.cdmotivoafasttemporario = afamottemp.cdmotivoafasttemporario
                and existe.dtinicio = a.dtinicio
where existe.cdvinculo is null
;

insert into etrbhistisencaopartecontrib
select
(select nvl(max(cdhistisencaopartecontrib),0) from etrbhistisencaopartecontrib) + rownum as cdhistisencaopartecontrib,
cdisencaopartecontribuicao as cdisencaopartecontribuicao,
3 as cdsitregistroisencao, -- 'Incluído (atestado automaticamente)'
2024 as nuanoiniciovigencia,
11 as numesiniciovigencia,
null as nuanofimvigencia,
null as numesfimvigencia,
to_date('30/10/2024', 'DD/MM/YYYY') as dtconcessaoisencao,
null as dtateste,
'N' as flisencaolaudopericial,
null as cddocumento,
null as cdtipopublicacao,
null as dtpublicacao,
null as nupublicacao,
null as nupaginicial,
null as cdmeiopublicacao,
null as deoutromeio,
systimestamp as dtultalteracao, 
'Vínculo de Cargo Comissionado concomitante com Vínculo de Cargo Efetivo.' as dejustificativa,
'N' as flanulado,
null as dtanulado
from etrbisencaopartecontribuicao;