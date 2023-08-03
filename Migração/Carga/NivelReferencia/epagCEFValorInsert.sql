--- Insert Valores
insert into epagvalorcarreiracefagrup
with
tpalfa as (select rownum, chr(rownum + 64) as nualfa from all_objects where rownum <= 26),
tpnum as (select rownum, lpad(rownum,2,0) as nunum from all_objects where rownum <= 99),
nivrefpadrao as (
select 'ALFA' as tpnivel, nualfa as nuniv, nunum as nuref from tpalfa join tpnum on nunum is not null union
select 'NUM' as tpnivel, nunum as nuniv, nualfa as nuref from tpnum join tpalfa on nualfa is not null
),
CarreiraFaixas as (
select
tabvl.cdagrupamento,
tabvl.cdestruturacarreira,
faixa.cdhistnivelrefcarrcefagrup,
i.deitemcarreira as decarreira,
faixa.nunivelinicial,
faixa.nunivelfinal,
faixa.nureferenciainicial,
faixa.nureferenciafinal
from epaghistnivelrefcarrcefagrup faixa
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
inner join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrupversao = vigencia.cdnivelrefcefagrupversao
inner join epagnivelrefcefagrup tabvl on tabvl.cdnivelrefcefagrup = versao.cdnivelrefcefagrup
inner join ecadestruturacarreira e on e.cdestruturacarreira = tabvl.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = tabvl.cdagrupamento
                             and i.cdtipoitemcarreira = 1
                             and i.cditemcarreira = e.cditemcarreira
),
ValoresNivRef as (
select
decarreira,
nunivelpara as nunivel,
nureferenciapara as nureferencia,
vlfixo
from sigrhmig.emignivelreferenciacsv v
where nmrelacaotrabalho = 'EFETIVO'
),
Existe as (
select faixa.cdhistnivelrefcarrcefagrup, valor.nunivel, valor.nureferencia, valor.vlfixo
from epagvalorcarreiracefagrup valor
inner join epaghistnivelrefcarrcefagrup faixa on faixa.cdhistnivelrefcarrcefagrup = valor.cdhistnivelrefcarrcefagrup
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
)

select
 (select nvl(max(cdvalorcarreiracefagrup),0) from epagvalorcarreiracefagrup) + rownum as cdvalorcarreiracefagrup,
 faixa.cdhistnivelrefcarrcefagrup as cdhistnivelrefcarrcefagrup,
 nrp.nuniv as nunivel,
 nrp.nuref as nureferencia,
 nvl(v.vlfixo,0) as vlfixo,
 null as deexpressao,
 systimestamp as dtultalteracao

from CarreiraFaixas faixa
join nivrefpadrao nrp on nrp.nuniv between faixa.nunivelinicial and faixa.nunivelfinal
                     and nrp.nuref between faixa.nureferenciainicial and faixa.nureferenciafinal
left join ValoresNivRef v on v.decarreira = faixa.decarreira
                         and v.nunivel = nrp.nuniv
                         and v.nureferencia = nrp.nuref
left join Existe existe on existe.cdhistnivelrefcarrcefagrup = faixa.cdhistnivelrefcarrcefagrup
                       and existe.nunivel = nrp.nuniv
                       and existe.nureferencia = nrp.nuref
where existe.cdhistnivelrefcarrcefagrup is null
order by
faixa.cdagrupamento,
faixa.decarreira,
nrp.nuniv,
nrp.nuref
;
/

