--- Insert Faixas
insert all
into epagnivelrefcefagrup values (
cdnivelrefcefagrup,
cdagrupamento,
cdestruturacarreira
)

into epagnivelrefcefagrupversao values (
cdnivelrefcefagrupversao,
cdnivelrefcefagrup,
nuversao
)

into epaghistnivelrefcefagrup values (
cdhistnivelrefcefagrup,
cdnivelrefcefagrupversao,
nuanoiniciovigencia,
numesiniciovigencia,
nuanofimvigencia,
numesfimvigencia,
flnivelnumerico,
flreferencianumerica,
cdvalorgeralcefagrup,
cddocumento,
cdmeiopublicacao,
cdtipopublicacao,
dtpublicacao,
nupaginicial,
nupublicacao,
deoutromeio,
nucpfcadastrador,
dtinclusao,
dtultalteracao,
intabelautilizada
)

into epaghistnivelrefcarrcefagrup values (
cdhistnivelrefcarrcefagrup,
cdhistnivelrefcefagrup,
cdestruturacarreira,
nunivelinicial,
nureferenciainicial,
nunivelfinal,
nureferenciafinal,
flutilizatabgeral,
nucargahorariapadrao,
nucpfcadastrador,
dtinclusao,
dtultalteracao,
flnivelnumerico,
flreferencianumerica,
cdvalorgeralcefagrup
)

with
CarreirasCHO as (
select e.cdagrupamento, e.cdestruturacarreira, max(echo.nucargahoraria) as nucargahorariapadrao
from ecadevolucaocefcargahoraria echo
inner join ecadevolucaoestruturacarreira e on e.cdevolucaoestcarreira = echo.cdevolucaoestcarreira
where e.dtfimvigencia is not null
group by e.cdagrupamento, e.cdestruturacarreira
),
Carreira as (
select e.cdagrupamento, e.cdestruturacarreira, carreira.deitemcarreira as decarreira, nvl(cho.nucargahorariapadrao,'40') as nucargahorariapadrao
from ecadestruturacarreira e 
inner join ecaditemcarreira carreira on carreira.cdagrupamento = e.cdagrupamento and carreira.cdtipoitemcarreira = 1 and carreira.cditemcarreira = e.cditemcarreira
left join CarreirasCHO cho on cho.cdagrupamento = e.cdagrupamento and cho.cdestruturacarreira = e.cdestruturacarreira
where e.cdestruturacarreiracarreira is null
  and e.cdagrupamento = 1
),
ValoresNivRef as (
select
decarreira,
nunivelpara as nunivel,
nureferenciapara as nureferencia,
vlfixo
from sigrhmig.emignivelreferenciacsv
where nmrelacaotrabalho = 'EFETIVO'
),
FaixaNivelRef as (
select decarreira,
min(nunivel) as nunivelinicial,
min(nureferencia) as nureferenciainicial,
max(nunivel) as nunivelfinal,
max(nureferencia) as nureferenciafinal
from ValoresNivRef
group by decarreira
),
CarreiraFaixas as (
select
c.cdagrupamento,
c.cdestruturacarreira,
c.decarreira,
c.nucargahorariapadrao,
nvl2(f.decarreira,f.nunivelinicial,'A') as nunivelinicial,
nvl2(f.decarreira,f.nureferenciainicial,'01') as nureferenciainicial,
nvl2(f.decarreira,f.nunivelfinal,'A') as nunivelfinal,
nvl2(f.decarreira,f.nureferenciafinal,'01') as nureferenciafinal,
case
 when f.decarreira is null then 'ALFA'
 when trim(TRANSLATE(nunivelinicial, '0123456789 -,.', ' ')) is null then 'NUM'
 else 'ALFA'
end nunivelnumerico,
case
 when f.decarreira is null then 'NUM'
 when trim(TRANSLATE(nureferenciainicial, '0123456789 -,.', ' ')) is null then 'NUM'
 else 'ALFA'
end nureferencianumerico
from Carreira c
left join FaixaNivelRef f on f.decarreira = c.decarreira
)

select
-- epagnivelrefcefagrup
 (select nvl(max(cdnivelrefcefagrup),0) from epagnivelrefcefagrup) + rownum as cdnivelrefcefagrup,
 c.cdagrupamento as cdagrupamento,
 c.cdestruturacarreira as cdestruturacarreira,

-- epagnivelrefcefagrupversao
 (select nvl(max(cdnivelrefcefagrupversao),0) from epagnivelrefcefagrupversao) + rownum as cdnivelrefcefagrupversao,
 -- cdnivelrefcefagrup,
 '1' as nuversao,

-- epaghistnivelrefcefagrup
 (select nvl(max(cdhistnivelrefcefagrup),0) from epaghistnivelrefcefagrup) + rownum as cdhistnivelrefcefagrup,
 -- cdnivelrefcefagrupversao,
 '1901' as nuanoiniciovigencia,
 '01' as numesiniciovigencia,
 null as nuanofimvigencia,
 null as numesfimvigencia,
 'N' as flnivelnumerico,
 'N' as flreferencianumerica,
 null as cdvalorgeralcefagrup,
 null as cddocumento,
 null as cdmeiopublicacao,
 null as cdtipopublicacao,
 null as dtpublicacao,
 null as nupaginicial,
 null as nupublicacao,
 null as deoutromeio,
 '2' as intabelautilizada,

-- epaghistnivelrefcarrcefagrup
 (select nvl(max(cdhistnivelrefcarrcefagrup),0) from epaghistnivelrefcarrcefagrup) + rownum as cdhistnivelrefcarrcefagrup,
 -- cdhistnivelrefcefagrup,
 -- cdestruturacarreira,
 c.nunivelinicial as nunivelinicial,
 c.nureferenciainicial as nureferenciainicial,
 c.nunivelfinal as nunivelfinal,
 c.nureferenciafinal as nureferenciafinal,
 'N' as flutilizatabgeral,
 c.nucargahorariapadrao as nucargahorariapadrao,

 '11111111111' as nucpfcadastrador,
 trunc(sysdate) as dtinclusao,
 systimestamp as dtultalteracao

from CarreiraFaixas c
--where cdestruturacarreira < 100
--where cdestruturacarreira between 100 and 200
--where cdestruturacarreira > 200
;
/