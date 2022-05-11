Insert into emovperiodoaquisitivoferias
(
 cdperiodoaquisitivoferias,
 cdvinculo,
 dtinicio,
 dtfimprevisto,
 dtfim,
 nudiasferiasperdido,
 nudiasferiasabonado,
 cdafastamento,
 nucpfcadastrador,
 dtinclusao,
 dtultalteracao,
 dtfimantesperda,
 cdsituacaoperiodoaqferias,
 dtinicioultpaaproveitado,
 dtfimultpaaproveitado,
 nudiasusufruiraproveitado,
 deobsultpaaproveitado,
 nudiasferiasconcedido,
 flajustedpro,
 vlsaldoindferiasvencidas,
 vlsaldoindferiasprop,
 intipocalculosaldo,
 nuanomesiniciopagrescisao,
 nuperiodosapurados,
 numesesapurados,
 flindenizacaohomologada
)

with anos as (
select 2015 + level - 1 as ano from dual
connect by level <= 6
)

select
 (select max(cdperiodoaquisitivoferias) from emovperiodoaquisitivoferias) + rownum as cdperiodoaquisitivoferias
,cdvinculo
,add_months(v.dtadmissao, 12 * (a.ano - extract(year from v.dtadmissao))) as dtinicio
,add_months(v.dtadmissao, 12 * ((a.ano - extract(year from v.dtadmissao)) + 1)) - 1  as dtfimprevisto
,add_months(v.dtadmissao, 12 * ((a.ano - extract(year from v.dtadmissao)) + 1)) - 1 as dtfim
,'0' as nudiasferiasperdido
,'0' as nudiasferiasabonado
,null as cdafastamento
,'11111111111' as nucpfcadastrador
,to_date(sysdate,'DD/MM/RR') as dtinclusao
,to_timestamp(TO_CHAR(systimestamp,'DD-MON-YYYY HH24:MI:SSXFF'),'DD/MM/RR HH24:MI:SSXFF') as dtultalteracao
,null as dtfimantesperda
,'2' as cdsituacaoperiodoaqferias
,null as dtinicioultpaaproveitado
,null as dtfimultpaaproveitado
,null as nudiasusufruiraproveitado
,null as deobsultpaaproveitado
,'30' as nudiasferiasconcedido
,'N' as flajustedpro
,null as vlsaldoindferiasvencidas
,null as vlsaldoindferiasprop
,null as intipocalculosaldo
,null as nuanomesiniciopagrescisao
,null as nuperiodosapurados
,null as numesesapurados
,null as flindenizacaohomologada

from ecadvinculo v
join anos a on a.ano > extract(year from dtadmissao)
where a.ano not in (select extract(year from aq.dtinicio) from emovperiodoaquisitivoferias aq where aq.cdvinculo = v.cdvinculo)
  and dtdesligamento is null
order by 2, 3