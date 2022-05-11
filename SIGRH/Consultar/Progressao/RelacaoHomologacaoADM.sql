define bienio = to_number(2022);

with valores as(
select
 tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0) as nivel_referencia,
 valor.vlfixo as valor_referencia
from epagvalorespeccefagrup valor
left join epaghistvalorgeralcefagrup histvlr on histvlr.cdhistvalorgeralcefagrup = valor.cdhistvalorgeralcefagrup
left join epagvalorgeralcefagrupversao versaotabvlr on versaotabvlr.cdvalorgeralcefagrupversao = histvlr.cdvalorgeralcefagrupversao
left join epagvalorgeralcefagrup tabelavlr on tabelavlr.cdvalorgeralcefagrup = versaotabvlr.cdvalorgeralcefagrup
where tabelavlr.fldesativada = 'N'
  and tabelavlr.cdagrupamento = 1
  and versaotabvlr.nuversao = 1
  and histvlr.nuanofimvigencia is null
order by tabelavlr.sgtabelavalorgeralcef || valor.nunivel || lpad(valor.nureferencia, 2, 0)
),

progressoes as (
select cdvinculo, sum(qtde) as meritos_concedidos
from (
select cdvinculo, count(*) as qtde from emovmovcargoefetivo
where flanulado = 'N' and cdmotivotransformacaocef in (1, 5)
group by cdvinculo
union
select cdvinculo, -count(*) as qtde from emovmovcargoefetivo
where flanulado = 'N' and cdmotivotransformacaocef in (3223, 3233)
group by cdvinculo
)
group by cdvinculo
)

select
 --v.cdvinculo,
 --cef.cdvinculo,
 --nivrefcef.cdhistcargoefetivo,
 o.sgorgao as ORGAO,
 lpad(v.numatricula || '-' || v.nudvmatricula,9,0) as MATRICULA,
 lpad(p.nucpf,11,0) as CPF,
 p.nmpessoa as NOME_COMPLETO,
 v.dtadmissao as DATA_ADMISSAO,
 --v.dtdesligamento as DATA_DESLIGAMENTO,
 itemnv1.deitemcarreira as CARREIRA,
 item.deitemcarreira as CARGO,
 cef.nugruposalarial || nivrefcef.nunivelpagamento || nivrefcef.nureferenciapagamento as NIVEL_REFERENCIA,
 vl.valor_referencia as VALOR_REFERENCIA,
 nivel_referencia(cef.nugruposalarial || nivrefcef.nunivelpagamento || nivrefcef.nureferenciapagamento, 1) as NIVEL_REFERENCIA_PROGRESSAO,
 vlp.valor_referencia as VALOR_REFERENCIA_PROGRESSAO,
 
 case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
 + case when v.dtadmissao < '05/06/1998' then 0 else 3 end
 as AnoInicioBienios,
 
 case when mod(&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                          + case when v.dtadmissao < '05/06/1998' then 0 else 3 end),2) = 0 then 'BIENIO ' || (&bienio - 2) || '-' || &bienio
      else 'SEM DIREITO AO BIENIO ' || (&bienio - 2) || '-' || &bienio
 end as HaptoBienio,

 trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                   + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) as Bienios,
 nvl(pg.meritos_concedidos, 0) as CONCEDIDOS
 
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao

inner join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo and flprincipal = 'S' 
                                   and cef.dtfim is null and cef.flanulado = 'N'

inner join ecadestruturacarreira estr on estr.cdestruturacarreira = cef.cdestruturacarreira
inner join ecaditemcarreira item on item.cditemcarreira = estr.cditemcarreira

inner join ecadestruturacarreira estrnv1 on estrnv1.cdestruturacarreira = estr.cdestruturacarreirapai
inner join ecaditemcarreira itemnv1 on itemnv1.cditemcarreira = estrnv1.cditemcarreira and itemnv1.deitemcarreira not like 'MAGISTERIO%'

inner join ecadhistnivelrefcef nivrefcef on nivrefcef.cdhistcargoefetivo = cef.cdhistcargoefetivo
                                        and nivrefcef.dtfim is null and nivrefcef.flanulado = 'N'

left join valores vl on vl.nivel_referencia = cef.nugruposalarial || nivrefcef.nunivelpagamento || nivrefcef.nureferenciapagamento
left join valores vlp on vlp.nivel_referencia = nivel_referencia(cef.nugruposalarial || nivrefcef.nunivelpagamento || nivrefcef.nureferenciapagamento, 1)

left join progressoes pg on pg.cdvinculo = v.cdvinculo

where o.sgorgao = 'SEMED'
  and v.dtdesligamento is null
--  and v.numatricula IN (0001315, 0005487, 0008278, 0022893, 0022899)
  
  and mod(&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                     + case when v.dtadmissao < '05/06/1998' then 0 else 3 end),2) = 0

  and trunc((&bienio - (  case when v.dtadmissao < '05/06/1998' then 2000 else extract(year from v.dtadmissao) end
                        + case when v.dtadmissao < '05/06/1998' then 0 else 3 end)) / 2) > 0

order by
 o.sgorgao,
 p.nucpf,
 v.numatricula