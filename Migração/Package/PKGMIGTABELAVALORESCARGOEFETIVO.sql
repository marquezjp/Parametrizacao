select * from table(PKGMIGTABELAVALORESCARGOEFETIVO.listarFaixaNivelReferenciaVinculos);

select * from table(PKGMIGTABELAVALORESCARGOEFETIVO.listar);

exec PKGMIGTABELAVALORESCARGOEFETIVO.excluir;

exec PKGMIGTABELAVALORESCARGOEFETIVO.incluir;

-- Remover o Pacote
--drop package PKGMIGTABELAVALORESCARGOEFETIVO;

-- Criar o Especificação do Pacote
create or replace
package PKGMIGTABELAVALORESCARGOEFETIVO is

type rFaixaNivelReferenciaVinculos is record(
 cdagrupamento number(22),
 decarreira varchar2(200),
 nunivelinicial varchar2(3),
 nunivelfinal varchar2(3),
 nureferenciainicial varchar2(3),
 nureferenciafinal varchar2(3) 
);
type tFaixaNivelReferenciaVinculos is table of rFaixaNivelReferenciaVinculos;

type rFaixaNivelReferenciaCarreirasTabelaValores is record(
 sgagrupamento varchar2(15),
 decarreira varchar2(200),
 nuversao number(22),
 nuanoiniciovigencia number(22),
 numesiniciovigencia number(22),
 nunivelinicial varchar2(3),
 nureferenciainicial varchar2(3),
 nunivelfinal varchar2(3),
 nureferenciafinal varchar2(3),
 nucargahorariapadrao number(22),
 flnivelnumerico char(1),
 flreferencianumerica char(1)
);
type tFaixaNivelReferenciaCarreirasTabelaValores is table of rFaixaNivelReferenciaCarreirasTabelaValores;

function listarFaixaNivelReferenciaVinculos return tFaixaNivelReferenciaVinculos pipelined;

function listar return tFaixaNivelReferenciaCarreirasTabelaValores pipelined;

procedure incluir(
--plista_tab in modelo_table,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY'),
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
);

procedure excluir(
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate)
);

end PKGMIGTABELAVALORESCARGOEFETIVO;

-- Criar o Corpo do Pacote
create or replace
package body PKGMIGTABELAVALORESCARGOEFETIVO is

function listarFaixaNivelReferenciaVinculos
return tFaixaNivelReferenciaVinculos pipelined as

cursor cLista is
with
TabCarreiras as (
select
 a.sgagrupamento,
 icar.deitemcarreira as decarreira,
 ic.deitemcarreira as decargo,
 e.cdestruturacarreira as cdestruturacarreira
from ecadestruturacarreira e 
inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
inner join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
inner join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
inner join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
),
CarreirasVinculos as (
select distinct
 a.cdagrupamento,
 tcef.decarreira,
 case
   when trim(TRANSLATE(cef.nunivelpagamento, '0123456789-,.', ' ')) is null then chr(cef.nunivelpagamento + 64)
   else cef.nunivelpagamento
 end as nunivelcef,
 cef.nureferenciapagamento as nureferenciacef
from ecadvinculo v
left join vcadorgao o on o.cdorgao = v.cdorgao
left join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join ecadhistcargoefetivo cef on cef.cdvinculo = v.cdvinculo
left join ecadhistnivelrefcef nr on nr.cdhistcargoefetivo = cef.cdhistcargoefetivo
left join TabCarreiras tcef on tcef.sgagrupamento = a.sgagrupamento
                           and tcef.cdestruturacarreira = cef.cdestruturacarreira
where cef.cdvinculo is not null
  and a.cdagrupamento = 1

union

select distinct
 a.cdagrupamento,
 tcef.decarreira,
 capa.nunivelcef,
 capa.nureferenciacef
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento
inner join vcadorgao o on o.cdorgao = f.cdorgao
inner join ecadagrupamento a on a.cdagrupamento = o.cdagrupamento
left join TabCarreiras tcef on tcef.sgagrupamento = a.sgagrupamento
                           and tcef.cdestruturacarreira = capa.cdestruturacarreira
where f.cdtipocalculo != 3
  and capa.cdrelacaotrabalho in (3, 5)
  and a.cdagrupamento = 1
)

select
 cdagrupamento,
 decarreira,
 min(nunivelcef) as nunivelinicial,
 max(nunivelcef) as nunivelfinal,
 min(nureferenciacef) as nureferenciainicial,
 max(nureferenciacef) as nureferenciafinal
from CarreirasVinculos
group by
 cdagrupamento,
 decarreira
;

begin
  for item in cLista loop
    pipe row(rFaixaNivelReferenciaVinculos(
    item.cdagrupamento,
    item.decarreira,
    item.nunivelinicial,
    item.nunivelfinal,
    item.nureferenciainicial,
    item.nureferenciafinal
    ));
  end loop;    
end listarFaixaNivelReferenciaVinculos;


function listar
return tFaixaNivelReferenciaCarreirasTabelaValores pipelined as

cursor cLista is
select 
 a.sgagrupamento,
 i.deitemcarreira as decarreira,
 versao.nuversao,
 vigencia.nuanoiniciovigencia,
 vigencia.numesiniciovigencia,
 faixa.nunivelinicial,
 faixa.nureferenciainicial,
 faixa.nunivelfinal,
 faixa.nureferenciafinal,
 faixa.nucargahorariapadrao,
 faixa.flnivelnumerico,
 faixa.flreferencianumerica
from epaghistnivelrefcarrcefagrup faixa
inner join epaghistnivelrefcefagrup vigencia on vigencia.cdhistnivelrefcefagrup = faixa.cdhistnivelrefcefagrup
inner join epagnivelrefcefagrupversao versao on versao.cdnivelrefcefagrupversao = vigencia.cdnivelrefcefagrupversao
inner join epagnivelrefcefagrup valorcarreira on valorcarreira.cdnivelrefcefagrup = versao.cdnivelrefcefagrup
inner join ecadagrupamento a on a.cdagrupamento = valorcarreira.cdagrupamento
inner join ecadestruturacarreira ecar on ecar.cdagrupamento = a.cdagrupamento and ecar.cdestruturacarreira = valorcarreira.cdestruturacarreira
inner join ecaditemcarreira i on i.cdagrupamento = a.cdagrupamento and i.cdtipoitemcarreira = 1 and i.cditemcarreira = ecar.cditemcarreira
;

begin
  for item in cLista loop
    pipe row(rFaixaNivelReferenciaCarreirasTabelaValores(
    item.sgagrupamento,
    item.decarreira,
    item.nuversao,
    item.nuanoiniciovigencia,
    item.numesiniciovigencia,
    item.nunivelinicial,
    item.nureferenciainicial,
    item.nunivelfinal,
    item.nureferenciafinal,
    item.nucargahorariapadrao,
    item.flnivelnumerico,
    item.flreferencianumerica
    ));
  end loop;    
end listar;

procedure incluir(
--plista_tab in modelo_table,
pdtinicio date default to_date(last_day(add_months(sysdate,-1)),'DD/MM/YYYY'),
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate),
pdtultalteracao in timestamp default systimestamp
)
is

begin

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
  TabCarreiras as (
  select
   a.sgagrupamento,
   icar.deitemcarreira as decarreira,
   ic.deitemcarreira as decargo,
   e.cdestruturacarreira as cdestruturacarreira
  from ecadestruturacarreira e 
  inner join ecadagrupamento a on a.cdagrupamento = e.cdagrupamento
  inner join ecaditemcarreira ic on ic.cdagrupamento = e.cdagrupamento and ic.cdtipoitemcarreira = 3 and ic.cditemcarreira = e.cditemcarreira
  inner join ecadestruturacarreira ecar on ecar.cdagrupamento = e.cdagrupamento and ecar.cdestruturacarreira = e.cdestruturacarreiracarreira
  inner join ecaditemcarreira icar on icar.cdagrupamento = ecar.cdagrupamento and icar.cdtipoitemcarreira = 1 and icar.cditemcarreira = ecar.cditemcarreira
  )
  select
  -- epagnivelrefcefagrup
   (select nvl(max(cdnivelrefcefagrup),0) from epagnivelrefcefagrup) + rownum as cdnivelrefcefagrup,
   a.cdagrupamento as cdagrupamento,
   tcef.cdestruturacarreira as cdestruturacarreira,
  
  -- epagnivelrefcefagrupversao
   (select nvl(max(cdnivelrefcefagrupversao),0) from epagnivelrefcefagrupversao) + rownum as cdnivelrefcefagrupversao,
   '1' as nuversao,
  
  -- epaghistnivelrefcefagrup
   (select nvl(max(cdhistnivelrefcefagrup),0) from epaghistnivelrefcefagrup) + rownum as cdhistnivelrefcefagrup,
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
   '1' as intabelautilizada,
  
  -- epaghistnivelrefcarrcefagrup
   (select nvl(max(cdhistnivelrefcarrcefagrup),0) from epaghistnivelrefcarrcefagrup) + rownum as cdhistnivelrefcarrcefagrup,
   c.nunivelinicial as nunivelinicial,
   c.nureferenciainicial as nureferenciainicial,
   c.nunivelfinal as nunivelfinal,
   c.nureferenciafinal as nureferenciafinal,
   'N' as flutilizatabgeral,
   '40' as nucargahorariapadrao,
--   'N' as flnivelnumerico,
--   'N' as flreferencianumerica,
--   null as cdvalorgeralcefagrup,
  
   pnucpfcadastrador as nucpfcadastrador,
   pdtinclusao as dtinclusao,
   pdtultalteracao as dtultalteracao
  
  from  table(listarFaixaNivelReferenciaVinculos) c
  inner join ecadagrupamento a on a.cdagrupamento = c.cdagrupamento
  inner join TabCarreiras tcef on tcef.sgagrupamento = a.sgagrupamento
                              and tcef.decarreira = c.decarreira
  
  --left join existe on existe.sgagrupamento = a.sgagrupamento
  --                and existe.decarreira = c.decarreira
  --                and existe.nuversao = '1'
  --                and existe.nuanoiniciovigencia = '1901'
  --                and existe.numesiniciovigencia = '01'
  --where existe.sgagrupamento is null
  
  order by 
   c.cdagrupamento,
   c.decarreira
  ;

end incluir;

procedure excluir(
pnucpfcadastrador in char default '22222222222',
pdtinclusao in date default trunc(sysdate)
)
is

begin

  delete from epaghistnivelrefcarrcefagrup
  where nucpfcadastrador = pnucpfcadastrador
    and dtinclusao = pdtinclusao
    and cdhistnivelrefcarrcefagrup not in (select distinct cdhistnivelrefcarrcefagrup from epagvalorcarreiracefagrup)
  ;
  
  delete from epaghistnivelrefcefagrup
  where nucpfcadastrador = pnucpfcadastrador
    and dtinclusao = pdtinclusao
    and cdhistnivelrefcefagrup not in (select distinct cdhistnivelrefcefagrup from epaghistnivelrefcarrcefagrup)
  ;
  
  delete from epagnivelrefcefagrupversao
  where cdnivelrefcefagrupversao not in (select distinct cdnivelrefcefagrupversao from epaghistnivelrefcefagrup)
  ;
  
  delete from epagnivelrefcefagrup
  where cdnivelrefcefagrup not in (select distinct cdnivelrefcefagrup from epagnivelrefcefagrupversao)
  ;

end excluir;

end PKGMIGTABELAVALORESCARGOEFETIVO;