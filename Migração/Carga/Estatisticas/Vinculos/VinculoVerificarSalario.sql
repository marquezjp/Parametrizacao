with
cargos as (
select e.cdagrupamento, 5 as cdrelacaotrabalho, e.cdestruturacarreira as cdcargo,
a.sgagrupamento, icar.deitemcarreira as decarreira, ic.deitemcarreira as decargo, e.cdestruturacarreiracarreira as cdestruturacarreira
from ecadestruturacarreira e 
left join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
left join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
left join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
left join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
where icar.cditemcarreira is not null
union all
select gp.cdagrupamento, 6 as cdrelacaotrabalho, ecco.cdcargocomissionado as cdcargo,
a.sgagrupamento as sgagrupamento, gp.nmgrupoocupacional as decarreira, ecco.decargocomissionado as decargo, cco.cdgrupoocupacional as cdestruturacarreira
from ecadevolucaocargocomissionado ecco
inner join ecadcargocomissionado cco on cco.cdcargocomissionado = ecco.cdcargocomissionado
inner join ecadgrupoocupacional gp on gp.cdgrupoocupacional = cco.cdgrupoocupacional
inner join ecadagrupamento a on a.cdagrupamento = gp.cdagrupamento
),
salariocef as (
select tabvl.cdagrupamento, tabvl.cdestruturacarreira,
a.sgagrupamento, i.deitemcarreira as decarreira,
valor.nunivel, valor.nureferencia, valor.vlfixo
from epagvalorcarreiracefagrup valor
inner join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcarrcefagrup = valor.cdhistnivelrefcarrcefagrup
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
inner join epagnivelrefcefagrupversao versao on versao.nuversao = 1 and versao.cdnivelrefcefagrupversao = vigencia.cdnivelrefcefagrupversao
inner join epagnivelrefcefagrup tabvl on tabvl.cdnivelrefcefagrup = versao.cdnivelrefcefagrup
inner join ecadagrupamento a on a.cdagrupamento = tabvl.cdagrupamento
left join ecadestruturacarreira e on e.cdestruturacarreira = tabvl.cdestruturacarreira
left join ecaditemcarreira i on i.cdtipoitemcarreira = 1 and i.cdagrupamento = tabvl.cdagrupamento
                            and i.cditemcarreira = e.cditemcarreira
where (vigencia.nuanofimvigencia is not null and vigencia.numesfimvigencia is not null)
),
salariocco as(
select versao.cdagrupamento, valor.cdrelacaotrabalho,
a.sgagrupamento, upper(reltrab.nmrelacaotrabalho) as nmrelacaotrabalho,
valor.nucodigo, valor.nunivel, valor.vlfixo
from epagvalorrefccoagruporgespec valor
inner join epaghistvalorrefccoagruporgver vigencia on vigencia.cdhistvalorrefccoagruporgver = valor.cdhistvalorrefccoagruporgver
inner join epagvalorrefccoagruporgversao versao on versao.nuversao = 1 and versao.cdvalorrefccoagruporgversao = vigencia.cdvalorrefccoagruporgversao
inner join ecadagrupamento a on a.cdagrupamento = versao.cdagrupamento
left join ecadrelacaotrabalho reltrab on reltrab.cdrelacaotrabalho = valor.cdrelacaotrabalho
where (vigencia.nuanofimvigencia is null and vigencia.numesfimvigencia is null)
),
pagos as (
select o.cdagrupamento, pag.cdvinculo,
max(pag.vlpagamento) as vlpagamento
from epaghistoricorubricavinculo pag
inner join epagfolhapagamento f on f.cdfolhapagamento = pag.cdfolhapagamento
                               and f.flcalculodefinitivo = 'S'
                               and f.nuanoreferencia = 2024 and f.numesreferencia = 11
                               and f.cdtipocalculo = 1 and f.nusequencialfolha = 1
inner join epagtipofolhapagamento tfo on tfo.cdtipofolha = 1 and tfo.cdtipofolhapagamento = f.cdtipofolhapagamento
inner join ecadvinculo v on v.cdvinculo = pag.cdvinculo
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join vpagrubrica rub on rub.cdrubricaagrupamento = pag.cdrubricaagrupamento and rub.cdtiporubrica != 9
where pag.vlpagamento != 0 and o.cdagrupamento not in (1)
  and rub.cdtiporubrica in (1, 2, 4, 10, 12)
  and rub.nurubrica in (0001, 0002, 0181, 0524, 2040)
  and pag.vlindicerubrica = 30
group by o.cdagrupamento, pag.cdvinculo
having count(*) = 1
),
vinculos as (
select a.sgagrupamento, o.sgorgao, --v.cdvinculo,
v.numatricula, v.nuseqmatricula,
--v.dtdesligamento, cef.dtfim,
case when cef.cdvinculo is null then upper(reltrabcco.nmrelacaotrabalho) else upper(reltrabcef.nmrelacaotrabalho) end as nmrelacaotrabalho,
--case when cef.cdvinculo is null then cco.cdcargocomissionado else cef.cdestruturacarreira end as cdcargo,
cargos.decarreira, cargos.decargo,
case when cef.cdvinculo is null then cco.nunivel else cef.nunivelpagamento end as nunivel,
case when cef.cdvinculo is null then cco.nureferencia else cef.nureferenciapagamento end as nureferencia,
pagos.vlpagamento as salario_pago,
case when cef.cdvinculo is null then salcco.vlfixo else salcef.vlfixo end as salario_bruto
from ecadvinculo v
inner join ecadpessoa p on p.cdpessoa = v.cdpessoa
inner join vcadorgao o on o.cdorgao = v.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
  and (cef.dtfim is null or cef.dtfim >= sysdate)
left join ecadhistcargocom cco on cco.cdvinculo = v.cdvinculo
  and (cco.dtfim is null or cco.dtfim >= sysdate)
left join ecadrelacaotrabalho reltrabcef on reltrabcef.cdrelacaotrabalho = cef.cdrelacaotrabalho
left join ecadrelacaotrabalho reltrabcco on reltrabcco.cdrelacaotrabalho = cco.cdrelacaotrabalho
left join cargos on cargos.cdagrupamento = o.cdagrupamento
  and cargos.cdrelacaotrabalho = case when cef.cdvinculo is null then 6 else 5 end
  and cargos.cdcargo = case when cef.cdvinculo is null then cco.cdcargocomissionado else cef.cdestruturacarreira end
left join salariocef salcef on salcef.cdagrupamento = o.cdagrupamento
  and salcef.cdestruturacarreira = cargos.cdestruturacarreira
  and salcef.nunivel = cef.nunivelpagamento
  and salcef.nureferencia = cef.nureferenciapagamento
left join salariocco salcco on salcco.cdagrupamento = o.cdagrupamento
  and salcco.cdrelacaotrabalho = cco.cdrelacaotrabalho
  and salcco.nucodigo = cco.nureferencia
  and salcco.nunivel = cco.nunivel
left join pagos on pagos.cdagrupamento = o.cdagrupamento
  and pagos.cdvinculo = v.cdvinculo
where o.cdagrupamento not in (1)
  and (v.dtdesligamento is null or v.dtdesligamento >= sysdate)
--order by 1, 2, 4, 5
)

--select * from vinculos
--where sgagrupamento = 'MILITAR'
--  and salario_pago is null
--  and nunivel not in  ('HRA', 'DRV')
--;
--/

select
sgagrupamento, sgorgao,
nmrelacaotrabalho, decarreira, decargo,
nunivel, nureferencia,
round(avg(salario_pago),2) as salario_pago_med,
min(salario_pago) as salario_pago_min,
max(salario_pago) as salario_pago_max,
case when min(salario_pago) != max(salario_pago) or max(salario_pago) is null then 'INCONSISTENTE' else null end nivrefconsistente,
count(*) as vinculos
from vinculos v
group by
sgagrupamento, sgorgao,
nmrelacaotrabalho, decarreira, decargo,
nunivel, nureferencia
order by
sgagrupamento, sgorgao,
nmrelacaotrabalho, decarreira, decargo,
nunivel, nureferencia
;
/